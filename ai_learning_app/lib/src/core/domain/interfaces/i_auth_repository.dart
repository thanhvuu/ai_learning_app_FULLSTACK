import 'package:ai_learning_app/src/core/domain/result.dart';
import 'package:ai_learning_app/src/core/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  });

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();

  UserEntity? getCurrentUser();
}
