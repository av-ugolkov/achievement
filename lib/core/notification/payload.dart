class Payload {
  final String command;
  final int achievementId;

  Payload(this.command, this.achievementId);

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(json['command'] as String, json['id'] as int);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['command'] = command;
    map['id'] = achievementId;
    return map;
  }

  @override
  String toString() {
    return '{commamnd: $command; id: $achievementId}';
  }
}
