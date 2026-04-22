import 'package:equatable/equatable.dart';

abstract class ReflectionEvent extends Equatable {
  const ReflectionEvent();
  @override
  List<Object?> get props => [];
}

class ReflectionLoadRequested extends ReflectionEvent {
  const ReflectionLoadRequested();
}

class ReflectionAddEntryRequested extends ReflectionEvent {
  const ReflectionAddEntryRequested({
    required this.content,
    this.emotion,
  });
  final String content;
  final String? emotion;
  @override
  List<Object?> get props => [content, emotion];
}

class ReflectionDeleteEntryRequested extends ReflectionEvent {
  const ReflectionDeleteEntryRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
