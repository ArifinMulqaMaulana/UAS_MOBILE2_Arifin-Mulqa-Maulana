class UserModel {
  String? id;
  String? username;
  String? email;
  String? profileImageUrl;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }
}
