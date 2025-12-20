class User {
  final int id;
  final String phoneNumber;
  final String? token;

  User({
    required this.id,
    required this.phoneNumber,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] as int,
      phoneNumber: json['phone_number'] as String,
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
    };
  }
}
