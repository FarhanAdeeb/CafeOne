class ChatRooMmodel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastmessage;
  String? datetime;

  ChatRooMmodel({this.chatroomid, this.participants, this.lastmessage});

  ChatRooMmodel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastmessage = map["lastmessage"];
    datetime = map["datetime"];
  }
  Map<String, dynamic> tomap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastmessage,
      "datetime": datetime
    };
  }
}
