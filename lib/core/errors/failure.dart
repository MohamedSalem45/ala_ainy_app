import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<Object?> properties;
  const Failure([this.properties = const <Object?>[]]);

  @override
  List<Object?> get props => properties;
}

// General Failures
class ServerFailure extends Failure {
  final String? message;
  const ServerFailure({this.message}) : super(const []);
}

class CacheFailure extends Failure {
  final String? message;
  const CacheFailure({this.message}) : super(const []);
}

class NetworkFailure extends Failure {
  final String? message;
  const NetworkFailure({this.message}) : super(const []);
}

class UnknownFailure extends Failure {
  final String? message;
  const UnknownFailure({this.message}) : super(const []);
}

// Auth Failures
class AuthFailure extends Failure {
  final String? message;
  const AuthFailure({this.message}) : super(const []);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({super.message});
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({super.message});
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure({super.message});
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure({super.message});
}
