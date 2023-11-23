import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/domain/entities/push_message.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({
    super.key,
    required this.messageId,
  });

  final String messageId;
  @override
  Widget build(BuildContext context) {
    final PushMessage? notification =
        context.watch<NotificationsBloc>().getNotificationById(messageId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification details'),
      ),
      body: notification != null
          ? _DetailsView(notification: notification)
          : const Center(child: Text('Notification does not exists')),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView({required this.notification});

  final PushMessage notification;

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          if (notification.imgUrl != null) Image.network(notification.imgUrl!),
          const SizedBox(
            height: 30,
          ),
          Text(
            notification.title,
            style: textStyles.titleLarge,
          ),
          Text(notification.body),
          const Divider(),
          Text(notification.data.toString()),
        ],
      ),
    );
  }
}
