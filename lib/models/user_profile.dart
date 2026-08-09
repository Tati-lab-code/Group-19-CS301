class UserProfile {
  final String username;
  final String password;
  final String email;

  UserProfile({required this.username, required this.password, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
    };
  }

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }
}
