import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phoneOrEmail,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phoneOrEmail: json['phoneOrEmail'] as String,
        token: json['token'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneOrEmail': phoneOrEmail,
        'token': token,
      };

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        phoneOrEmail: entity.phoneOrEmail,
        token: entity.token,
      );
}
