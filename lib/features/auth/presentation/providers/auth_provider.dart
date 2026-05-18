import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

// 1. Providers for Firebase Instances
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// 2. Providers for Data Sources and Repositories
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

// 3. Providers for Usecases
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
});

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  return RegisterUsecase(ref.watch(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.watch(authRepositoryProvider));
});

// 4. The Main Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final LogoutUsecase _logoutUsecase;

  AuthNotifier({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required LogoutUsecase logoutUsecase,
  }) : _loginUsecase = loginUsecase,
       _registerUsecase = registerUsecase,
       _logoutUsecase = logoutUsecase,
       super(AuthInitial());

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    final result = await _loginUsecase(email: email, password: password);

    result.fold(
      (failure) => state = AuthError(_mapFailureToMessage(failure)),
      (user) => state = Authenticated(user),
    );
  }

  Future<void> logout() async {
    state = AuthLoading();
    await _logoutUsecase();
    state = AuthInitial();
  }

  // دالة مساعدة لترجمة الأخطاء وعرضها للمستخدم بشكل أنيق
  String _mapFailureToMessage(Failure failure) {
    if (failure is UserNotFoundFailure) {
      return 'المستخدم غير موجود، يرجى إنشاء حساب.';
    } else if (failure is InvalidCredentialsFailure) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    } else if (failure is EmailAlreadyInUseFailure) {
      return 'البريد الإلكتروني مستخدم بالفعل لحساب آخر.';
    } else if (failure is WeakPasswordFailure) {
      return 'كلمة المرور ضعيفة جداً.';
    } else if (failure is AuthFailure) {
      return failure.message ?? 'حدث خطأ في المصادقة.';
    } else if (failure is ServerFailure) {
      return failure.message ?? 'حدث خطأ في الاتصال بالخادم.';
    }
    return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.';
  }
}

// 5. The StateNotifierProvider that the UI will listen to
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    loginUsecase: ref.watch(loginUsecaseProvider),
    registerUsecase: ref.watch(registerUsecaseProvider),
    logoutUsecase: ref.watch(logoutUsecaseProvider),
  );
});
