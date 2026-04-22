import 'package:equatable/equatable.dart';
import '../../domain/entities/journal_entry_entity.dart';

abstract class ReflectionState extends Equatable {
  const ReflectionState();
  @override
  List<Object?> get props => [];
}

class ReflectionInitial extends ReflectionState {
  const ReflectionInitial();
}

class ReflectionLoading extends ReflectionState {
  const ReflectionLoading();
}

class ReflectionLoaded extends ReflectionState {
  const ReflectionLoaded(this.entries);
  final List<JournalEntryEntity> entries;
  @override
  List<Object?> get props => [entries];
}

class ReflectionError extends ReflectionState {
  const ReflectionError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
