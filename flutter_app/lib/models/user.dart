class User {
  final int id;
  final String? username;
  final String phoneNumber;
  final String? nickname;
  final String? avatar;
  final String? token;

  User({
    required this.id,
    this.username,
    required this.phoneNumber,
    this.nickname,
    this.avatar,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String?,
      phoneNumber: json['phone_number'] as String,
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phone_number': phoneNumber,
      'nickname': nickname,
      'avatar': avatar,
    };
  }

  // 显示名称：优先昵称，其次用户名，最后手机号
  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) return nickname!;
    if (username != null && username!.isNotEmpty) return username!;
    return phoneNumber;
  }

  // 是否已设置个人信息
  bool get hasProfile => (nickname != null && nickname!.isNotEmpty) || (avatar != null && avatar!.isNotEmpty);
}
