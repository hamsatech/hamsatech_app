import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/reflection_repository.dart';
import 'reflection_event.dart';
import 'reflection_state.dart';

class ReflectionBloc extends Bloc<ReflectionEvent, ReflectionState> {
  ReflectionBloc(this._repository) : super(const ReflectionInitial()) {
    on<ReflectionLoadRequested>(_onLoad);
    on<ReflectionAddEntryRequested>(_onAdd);
    on<ReflectionDeleteEntryRequested>(_onDelete);
  }

  final ReflectionRepository _repository;

  void _onLoad(ReflectionLoadRequested event, Emitter<ReflectionState> emit) {
    emit(ReflectionLoaded(_repository.getEntries()));
  }

  Future<void> _onAdd(
    ReflectionAddEntryRequested event,
    Emitter<ReflectionState> emit,
  ) async {
    await _repository.addEntry(event.content, event.emotion);
    emit(ReflectionLoaded(_repository.getEntries()));
  }

  Future<void> _onDelete(
    ReflectionDeleteEntryRequested event,
    Emitter<ReflectionState> emit,
  ) async {
    await _repository.deleteEntry(event.id);
    emit(ReflectionLoaded(_repository.getEntries()));
  }
}
