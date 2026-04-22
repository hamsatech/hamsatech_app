import 'package:equatable/equatable.dart';

class AthleteProfileEntity extends Equatable {
  const AthleteProfileEntity({
    required this.name,
    required this.age,
    required this.sportDomain,
    required this.experienceLevel,
    required this.familySupport,
    required this.pressureSources,
    required this.baselineScores,
  });

  final String name;
  final int age;
  final String sportDomain;
  final String experienceLevel;
  final String familySupport;
  final List<String> pressureSources;
  final Map<String, double> baselineScores;

  double get overallReadiness {
    if (baselineScores.isEmpty) return 0;
    final focus = baselineScores['focus'] ?? 0;
    final emotional = baselineScores['emotionalStability'] ?? 0;
    final decision = baselineScores['decisionStyle'] ?? 0;
    final motivation = baselineScores['motivation'] ?? 0;
    return focus * 0.30 + emotional * 0.25 + decision * 0.25 + motivation * 0.20;
  }

  @override
  List<Object?> get props => [
        name,
        age,
        sportDomain,
        experienceLevel,
        familySupport,
        pressureSources,
        baselineScores,
      ];
}
