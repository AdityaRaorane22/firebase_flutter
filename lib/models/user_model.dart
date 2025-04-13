// lib/models/user_model.dart
class UserModel {
  final String firstName;
  final String lastName;
  final String dob;
  final String gender;
  final String phone;
  final String address1;
  final String address2;
  final String landmark;
  final String password;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.address1,
    required this.address2,
    required this.landmark,
    required this.password,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      address1: map['address1'] ?? '',
      address2: map['address2'] ?? '',
      landmark: map['landmark'] ?? '',
      password: map['password'] ?? '', // You can skip this in production for security
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'gender': gender,
      'phone': phone,
      'address1': address1,
      'address2': address2,
      'landmark': landmark,
      'password': password,
    };
  }
}
