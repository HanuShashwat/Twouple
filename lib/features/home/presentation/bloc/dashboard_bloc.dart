import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../api/insight_api.dart';
import '../../../../../models/daily_insight_model.dart';
import 'package:intl/intl.dart';

// ── Events ─────────────────────────────────────────────────────────────────────

abstract class DashboardEvent {}

class LoadDashboardEvent extends DashboardEvent {
  final DateTime date;
  LoadDashboardEvent(this.date);
}

class ToggleTaskEvent extends DashboardEvent {
  final String taskId;
  ToggleTaskEvent(this.taskId);
}

class AddCustomTaskEvent extends DashboardEvent {
  final String type; // 'do' or 'avoid'
  final String taskText;
  final DateTime date;
  AddCustomTaskEvent(this.type, this.taskText, this.date);
}

// ── States ─────────────────────────────────────────────────────────────────────

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final InsightDashboardModel data;
  final DateTime selectedDate;

  DashboardLoaded(this.data, this.selectedDate);
}

class DashboardError extends DashboardState {
  final String error;
  DashboardError(this.error);
}

// ── BLoC ───────────────────────────────────────────────────────────────────────

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final InsightApi _insightApi;

  DashboardBloc({InsightApi? insightApi})
      : _insightApi = insightApi ?? InsightApi(),
        super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<ToggleTaskEvent>(_onToggleTask);
    on<AddCustomTaskEvent>(_onAddCustomTask);
  }

  Future<void> _onLoadDashboard(
      LoadDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(event.date);
      final data = await _insightApi.getDailyInsight(dateStr);
      emit(DashboardLoaded(data, event.date));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onToggleTask(
      ToggleTaskEvent event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      try {
        final updatedTask = await _insightApi.toggleTaskCompletion(event.taskId);
        
        // Optimistically/actually update the local list
        final updatedTasks = currentState.data.tasks.map((t) {
          if (t.id == event.taskId) {
            return updatedTask;
          }
          return t;
        }).toList();

        final updatedData = InsightDashboardModel(
          insight: currentState.data.insight,
          tasks: updatedTasks,
        );

        emit(DashboardLoaded(updatedData, currentState.selectedDate));
      } catch (e) {
        emit(DashboardError(e.toString()));
        // Could revert or reload on error
      }
    }
  }

  Future<void> _onAddCustomTask(
      AddCustomTaskEvent event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      try {
        final dateStr = DateFormat('yyyy-MM-dd').format(event.date);
        final newTask = await _insightApi.addCustomTask(event.type, event.taskText, dateStr);

        final updatedTasks = List<UserTaskModel>.from(currentState.data.tasks)..add(newTask);
        
        final updatedData = InsightDashboardModel(
          insight: currentState.data.insight,
          tasks: updatedTasks,
        );

        emit(DashboardLoaded(updatedData, currentState.selectedDate));
      } catch (e) {
        emit(DashboardError(e.toString()));
      }
    }
  }
}
