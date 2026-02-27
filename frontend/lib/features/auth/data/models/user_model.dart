class UserModel {
  final String token;
  final String username;

  const UserModel({required this.token, required this.username});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        token: json['token'] as String,
        username: json['username'] as String,
      );
}
