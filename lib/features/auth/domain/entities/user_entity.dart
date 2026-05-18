import 'package:equatable/equatable.dart';

enum UserRole { admin, merchant, customer }

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    role,
    profileImageUrl,
    createdAt,
  ];
}
