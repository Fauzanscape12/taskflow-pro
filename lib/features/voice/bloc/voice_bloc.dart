import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

/// Voice Command State
class VoiceState extends Equatable {
  final bool isListening;
  final bool isAvailable;
  final String recognizedText;
  final String? error;

  const VoiceState({
    this.isListening = false,
    this.isAvailable = false,
    this.recognizedText = '',
    this.error,
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isAvailable,
    String? recognizedText,
    String? error,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isAvailable: isAvailable ?? this.isAvailable,
      recognizedText: recognizedText ?? this.recognizedText,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isListening, isAvailable, recognizedText, error];
}

/// Voice Events
abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object?> get props => [];
}

class VoiceInitialize extends VoiceEvent {}

class VoiceStartListening extends VoiceEvent {}

class VoiceStopListening extends VoiceEvent {}

class VoiceTextChanged extends VoiceEvent {
  final String text;

  const VoiceTextChanged(this.text);

  @override
  List<Object?> get props => [text];
}

class VoiceReset extends VoiceEvent {}

/// Voice Command Bloc
class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final SpeechToText _speechToText = SpeechToText();

  VoiceBloc() : super(const VoiceState()) {
    on<VoiceInitialize>(_onInitialize);
    on<VoiceStartListening>(_onStartListening);
    on<VoiceStopListening>(_onStopListening);
    on<VoiceTextChanged>(_onTextChanged);
    on<VoiceReset>(_onReset);
  }

  Future<void> _onInitialize(
      VoiceInitialize event, Emitter<VoiceState> emit) async {
    try {
      // Initialize speech to text
      final available = await _speechToText.initialize();

      if (available) {
        _speechToText.statusListener = (status) {
          if (status == 'notListening' || status == 'done') {
            emit(state.copyWith(isListening: false));
          }
        };

        _speechToText.errorListener = (error) {
          emit(state.copyWith(error: error.toString(), isListening: false));
        };
      }

      emit(state.copyWith(isAvailable: available));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onStartListening(
      VoiceStartListening event, Emitter<VoiceState> emit) async {
    if (!state.isAvailable) {
      emit(state.copyWith(error: 'Speech recognition tidak tersedia'));
      return;
    }

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      emit(state.copyWith(error: 'Izin mikrofon diperlukan'));
      return;
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          add(VoiceTextChanged(result.recognizedWords));
        },
        listenFor: Duration.zero,
        pauseFor: Duration.zero,
        partialResults: true,
        localeId: 'id_ID', // Indonesian
      );

      emit(state.copyWith(isListening: true, error: null));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onStopListening(
      VoiceStopListening event, Emitter<VoiceState> emit) async {
    try {
      await _speechToText.stop();
      emit(state.copyWith(isListening: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onTextChanged(
      VoiceTextChanged event, Emitter<VoiceState> emit) async {
    emit(state.copyWith(recognizedText: event.text));
  }

  Future<void> _onReset(VoiceReset event, Emitter<VoiceState> emit) async {
    emit(state.copyWith(recognizedText: '', error: null));
  }

  @override
  Future<void> close() {
    _speechToText.cancel();
    return super.close();
  }
}
