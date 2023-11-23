class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime sentDate;
  final Map<String, dynamic>? data;
  final String? imgUrl;

  PushMessage({
    required this.messageId,
    required this.title,
    required this.body,
    required this.sentDate,
    this.data,
    this.imgUrl,
  });

  @override
  String toString() {
    return """
PushMessage
  messageId: $messageId
  title: $title
  body: $body
  sentDate: $sentDate
  data: $data
  imgUrl: $imgUrl
""";
  }
}
