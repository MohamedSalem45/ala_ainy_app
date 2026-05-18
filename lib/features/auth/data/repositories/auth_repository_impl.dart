import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return const Left(UserNotFoundFailure());
      } else if (e.code == 'wrong-password') {
        return const Left(InvalidCredentialsFailure());
      }
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name,
        email,
        password,
        phone,
        role,
      );
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return const Left(EmailAlreadyInUseFailure());
      } else if (e.code == 'weak-password') {
        return const Left(WeakPasswordFailure());
      }
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
