class UserModel {
  final String username;
  final String passwordHash;
  final String? photoPath;

  UserModel({
    required this.username,
    required this.passwordHash,
    this.photoPath,
  });

  Map<String, dynamic> toMap() => {
        'username': username,
        'password': passwordHash,
        'photoPath': photoPath,
      };

  factory UserModel.fromMap(Map map) => UserModel(
        username: map['username'],
        passwordHash: map['password'],
        photoPath: map['photoPath'],
      );
}
