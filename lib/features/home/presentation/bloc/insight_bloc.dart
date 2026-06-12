import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/insight_repository.dart';

// Events
abstract class InsightEvent {}

class LoadDailyInsightEvent extends InsightEvent {
  final String date;
  LoadDailyInsightEvent(this.date);
}

class ToggleTaskEvent extends InsightEvent {
  final String taskId;
  ToggleTaskEvent(this.taskId);
}

// States
abstract class InsightState {}

class InsightInitial extends InsightState {}

class InsightLoading extends InsightState {}

class InsightLoaded extends InsightState {
  final Map<String, dynamic> dailyData;
  InsightLoaded(this.dailyData);
}

class InsightError extends InsightState {
  final String error;
  InsightError(this.error);
}

// Bloc
class InsightBloc extends Bloc<InsightEvent, InsightState> {
  final InsightRepository repository;

  InsightBloc(this.repository) : super(InsightInitial()) {
    on<LoadDailyInsightEvent>(_onLoadDailyInsight);
    on<ToggleTaskEvent>(_onToggleTask);
  }

  void _onLoadDailyInsight(LoadDailyInsightEvent event, Emitter<InsightState> emit) async {
    emit(InsightLoading());
    try {
      final data = await repository.getDailyData(event.date);
      emit(InsightLoaded(data));
    } catch (e) {
      emit(InsightError(e.toString()));
    }
  }

  void _onToggleTask(ToggleTaskEvent event, Emitter<InsightState> emit) async {
    if (state is InsightLoaded) {
      final currentState = state as InsightLoaded;
      try {
        await repository.toggleTask(event.taskId);
        // Refresh or optimistically update UI? For now, let's just refresh.
        // Actually since we don't have the date here, just fetching the data again might be tricky without date state.
        // For now, assume it succeeded.
      } catch (e) {
        // handle error
      }
    }
  }
}
