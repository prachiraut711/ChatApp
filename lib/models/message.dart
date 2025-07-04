enum Type { text, image }

class Message {
  Message({
    required this.msg,
    required this.read,
    required this.toId,
    required this.type,
    required this.sent,
    required this.fromid,
  });

  late final String msg;
  late final String read;
  late final String toId;
  late final String sent;
  late final String fromid;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    read = json['read'].toString();
    toId = json['toId'].toString(); // ✅ fixed typo
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
    fromid = json['fromid'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['toId'] = toId; 
    data['type'] = type.name;
    data['sent'] = sent;
    data['fromid'] = fromid;
    return data;
  }
}
