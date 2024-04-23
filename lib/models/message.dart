class Message {
  final String toId;
  final String msg;
  final String sentAt;
  final String readAt;
  final MessageType type;
  final String fromId;

  bool get isTextMessage => type == MessageType.text;

  Message({
    required this.toId,
    required this.msg,
    required this.sentAt,
    required this.readAt,
    required this.type,
    required this.fromId,
  });

  // 构造函数，用于从 JSON 数据创建一个 Message 实例
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      toId: json['toId'].toString(),
      msg: json['msg'].toString(),
      sentAt: json['sentAt'].toString(),
      readAt: json['readAt'].toString(),
      type: json['type'].toString() == MessageType.image.name
          ? MessageType.image
          : MessageType.text,
      fromId: json['fromId'].toString(),
    );
  }

  // 将 Message 实例转换为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'toId': toId,
      'msg': msg,
      'sentAt': sentAt,
      'readAt': readAt,
      'type': type.name,
      'fromId': fromId,
    };
  }
}

enum MessageType { text, image }
