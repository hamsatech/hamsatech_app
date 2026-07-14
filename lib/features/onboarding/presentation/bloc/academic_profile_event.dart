import 'package:equatable/equatable.dart';

abstract class AcademicProfileEvent extends Equatable {
  const AcademicProfileEvent();

  @override
  List<Object?> get props => [];
}

class OnClassChanged extends AcademicProfileEvent {
  final String value;
  const OnClassChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnSchoolNameChanged extends AcademicProfileEvent {
  final String value;
  const OnSchoolNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnAcademicPerformanceChanged extends AcademicProfileEvent {
  final String value;
  const OnAcademicPerformanceChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class OnAcademicProfileSubmit extends AcademicProfileEvent {
  const OnAcademicProfileSubmit();
}
