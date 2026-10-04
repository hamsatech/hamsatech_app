import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneOrEmail,
    required super.token,
    required super.isNewUser,
    required super.nextStep,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phoneOrEmail: json['phoneOrEmail'] as String,
        token: json['token'] as String,
        isNewUser: json['isNewUser'] as bool? ?? false,
        nextStep:
            AuthNextStep.fromApi(json['nextStep'] as String? ?? 'HOME'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneOrEmail': phoneOrEmail,
        'token': token,
        'isNewUser': isNewUser,
        'nextStep': nextStep.toApi(),
      };

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        phoneOrEmail: entity.phoneOrEmail,
        token: entity.token,
        isNewUser: entity.isNewUser,
        nextStep: entity.nextStep,
      );
}
