import '../../domain/entities/athlete_profile_entity.dart';

class AthleteProfileModel extends AthleteProfileEntity {
  const AthleteProfileModel({
    required super.name,
    required super.age,
    required super.sportDomain,
    required super.experienceLevel,
    required super.familySupport,
    required super.pressureSources,
    required super.baselineScores,
  });

  factory AthleteProfileModel.fromJson(Map<String, dynamic> json) =>
      AthleteProfileModel(
        name: json['name'] as String,
        age: json['age'] as int,
        sportDomain: json['sportDomain'] as String,
        experienceLevel: json['experienceLevel'] as String,
        familySupport: json['familySupport'] as String,
        pressureSources: List<String>.from(json['pressureSources'] as List),
        baselineScores: (json['baselineScores'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'sportDomain': sportDomain,
        'experienceLevel': experienceLevel,
        'familySupport': familySupport,
        'pressureSources': pressureSources,
        'baselineScores': baselineScores,
      };

  factory AthleteProfileModel.fromEntity(AthleteProfileEntity e) =>
      AthleteProfileModel(
        name: e.name,
        age: e.age,
        sportDomain: e.sportDomain,
        experienceLevel: e.experienceLevel,
        familySupport: e.familySupport,
        pressureSources: e.pressureSources,
        baselineScores: e.baselineScores,
      );
}
