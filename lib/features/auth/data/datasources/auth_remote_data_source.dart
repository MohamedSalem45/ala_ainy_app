import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String phone,
    UserRole role,
  );
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  @override
  Future<UserModel> login(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception('Login failed: User is null');
    }

    final doc = await _firestore
        .collection(AppConstants.firestoreUserCollection)
        .doc(userCredential.user!.uid)
        .get();

    if (!doc.exists) {
      throw Exception('User data not found in Firestore');
    }

    return UserModel.fromJson(doc.data()!);
  }

  @override
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String phone,
    UserRole role,
  ) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception('Registration failed: User is null');
    }

    final userModel = UserModel(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.firestoreUserCollection)
        .doc(userModel.id)
        .set(userModel.toJson());

    return userModel;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore
        .collection(AppConstants.firestoreUserCollection)
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }
}
