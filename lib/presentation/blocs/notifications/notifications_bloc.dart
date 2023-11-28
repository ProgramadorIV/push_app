import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_app/config/helpers/human_formats.dart';
import 'package:push_app/domain/entities/push_message.dart';

import 'package:push_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int notificationId = 0;

  final Future<void> Function()? requestLocalNotificationPermissions;
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data,
  })? showLocalNotification;

  NotificationsBloc({
    this.requestLocalNotificationPermissions,
    this.showLocalNotification,
  }) : super(const NotificationsState()) {
    on<NotificationStatusChange>(_notificationStatusChange);

    on<NotificationRecieved>(_notificationRecieved);

    //Verificar el estado de las notificaciones
    _initialStatusCheck();

    //Listener de notificaciones en Foreground
    _onForegroundMessage();
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChange(settings.authorizationStatus));
  }

  // Firebase cloud messaging
  static Future<void> initalizeFCM() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;
    final token = await messaging.getToken();
    print(token);
  }
  //----------------------------------------

  // This method is destined to handle all the notifications
  void handleRemoteMessage(RemoteMessage remoteMessage) {
    if (remoteMessage.notification == null) return;

    final PushMessage notification = PushMessage(
      messageId: remoteMessage.messageId != null
          ? HumanFormats.cleanMessageId(remoteMessage.messageId!)
          : '',
      title: remoteMessage.notification!.title ?? '',
      body: remoteMessage.notification!.body ?? '',
      sentDate: remoteMessage.sentTime ?? DateTime.now(),
      data: remoteMessage.data,
      imgUrl: Platform.isAndroid
          ? remoteMessage.notification!.android?.imageUrl
          : remoteMessage.notification!.apple?.imageUrl,
    );

    if (showLocalNotification != null) {
      showLocalNotification!(
        id: ++notificationId,
        body: notification.body,
        data: notification.messageId,
        title: notification.title,
      );
    }

    add(NotificationRecieved(notification));
  }

  //Foreground notifications listener
  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    //Solicitar permiso para local notifications
    if (requestLocalNotificationPermissions != null) {
      await requestLocalNotificationPermissions!();
    }

    add(NotificationStatusChange(settings.authorizationStatus));
  }

  //Events handlers --------------------------------

  void _notificationStatusChange(
      NotificationStatusChange event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(status: event.status));
    _getFCMToken();
  }

  void _notificationRecieved(
      NotificationRecieved event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(
      notifactions: [event.notification, ...state.notifactions],
    ));
  }

  //----------------------------------------------------

  PushMessage? getNotificationById(String id) {
    final exist = state.notifactions.any((element) => element.messageId == id);

    if (!exist) return null;
    return state.notifactions.firstWhere((element) => element.messageId == id);
  }
}
