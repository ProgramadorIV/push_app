part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.notifactions = const [],
    this.status = AuthorizationStatus.notDetermined,
  });

  final List<PushMessage> notifactions;
  final AuthorizationStatus status;

  @override
  List<Object> get props => [status, notifactions];

  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<PushMessage>? notifactions,
  }) =>
      NotificationsState(
        notifactions: notifactions ?? this.notifactions,
        status: status ?? this.status,
      );
}
