class UserModel {
  final String uid;
  final String email;
  final String name;
  final String location;
  final String createdAt;
  final bool isVerified;
  final bool verificationRequested;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.location,
    required this.createdAt,
    this.isVerified = false,
    this.verificationRequested = false,
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'location': location,
      'createdAt': createdAt,
      'isVerified': isVerified,
      'verificationRequested': verificationRequested,
      'isAdmin': isAdmin,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      createdAt: map['createdAt'] ?? '',
      isVerified: map['isVerified'] ?? false,
      verificationRequested: map['verificationRequested'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
    );
  }
}
