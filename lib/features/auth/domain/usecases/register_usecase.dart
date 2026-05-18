import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
    );
  }
}
