import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../api/coach_api.dart';

// ── Events ─────────────────────────────────────────────────────────────────────

abstract class AuraChatEvent {}

class SendAuraMessageEvent extends AuraChatEvent {
  final String message;
  SendAuraMessageEvent(this.message);
}

class LoadAuraHistoryEvent extends AuraChatEvent {
  final int page;
  LoadAuraHistoryEvent({this.page = 1});
}

// ── States ─────────────────────────────────────────────────────────────────────

abstract class AuraChatState {}

class AuraChatInitial extends AuraChatState {}

class AuraChatLoading extends AuraChatState {}

/// AI is processing a response
class AuraTyping extends AuraChatState {}

/// AI responded successfully
class AuraResponseReceived extends AuraChatState {
  final String responseText;
  AuraResponseReceived(this.responseText);
}

/// An error occurred
class AuraChatError extends AuraChatState {
  final String error;
  AuraChatError(this.error);
}

// ── BLoC ───────────────────────────────────────────────────────────────────────

class AuraChatBloc extends Bloc<AuraChatEvent, AuraChatState> {
  final CoachApi _coachApi;

  AuraChatBloc({CoachApi? coachApi})
      : _coachApi = coachApi ?? CoachApi(),
        super(AuraChatInitial()) {
    on<SendAuraMessageEvent>(_onSendMessage);
    on<LoadAuraHistoryEvent>(_onLoadHistory);
  }

  Future<void> _onSendMessage(
      SendAuraMessageEvent event, Emitter<AuraChatState> emit) async {
    emit(AuraTyping());

    try {
      final result = await _coachApi.sendMessage(event.message);
      final responseText = result['responseText'] as String? ?? 
                          result['message']?['message_body'] as String? ??
                          'I could not generate a response. Please try again.';
      emit(AuraResponseReceived(responseText));
    } catch (e) {
      emit(AuraChatError(e.toString()));
    }
  }

  Future<void> _onLoadHistory(
      LoadAuraHistoryEvent event, Emitter<AuraChatState> emit) async {
    emit(AuraChatLoading());

    try {
      final history = await _coachApi.getHistory(page: event.page);
      // For now we just signal loading is done — the view manages its own message list
      emit(AuraChatInitial());
    } catch (e) {
      emit(AuraChatError(e.toString()));
    }
  }
}
