class HumanFormats {
  static String cleanMessageId(String messageId) {
    final RegExp regExp = RegExp(r'(:|%)');
    return messageId.replaceAll(regExp, '');
  }
}
