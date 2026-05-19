import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/api_result.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../screens/chat_screen.dart';

/// Recording state
enum _VoiceState { idle, recording, processing }

class VoiceButton extends ConsumerStatefulWidget {
  /// Called with the transcribed text (or a placeholder while backend is not wired).
  final ValueChanged<String> onVoiceResult;
  final String lang;

  const VoiceButton({super.key, required this.onVoiceResult, this.lang = 'ur'});

  @override
  ConsumerState<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends ConsumerState<VoiceButton>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderReady = false;
  _VoiceState _state = _VoiceState.idle;
  String? _recordedPath;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return;
    await _recorder.openRecorder();
    setState(() => _recorderReady = true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_recorderReady) {
      await _initRecorder();
      if (!_recorderReady) return;
    }
    setState(() => _state = _VoiceState.recording);
    await _recorder.startRecorder(
      toFile: 'voice_input.aac',
      codec: Codec.aacADTS,
    );
  }

  Future<void> _stopRecording() async {
    setState(() => _state = _VoiceState.processing);
    _recordedPath = await _recorder.stopRecorder();

    bool isSuccess = false;
    String transcript = '';

    if (_recordedPath != null) {
      try {
        final repo = ref.read(bookingRepositoryProvider);
        final sessionId = ref.read(sessionIdProvider);
        final result = await repo.submitAudioRequest(_recordedPath!, sessionId: sessionId, lang: widget.lang);
        if (result is ApiSuccess<Map<String, dynamic>>) {
          debugPrint('=== [UstaadNow AI Audio API Response] ===');
          try {
            debugPrint(const JsonEncoder.withIndent('  ').convert(result.data));
          } catch (_) {
            debugPrint(result.data.toString());
          }
          debugPrint('=========================================');
          
          final text = result.data['whisper_transcript'] ??
              result.data['transcript'] ??
              result.data['input'] ??
              '';
          if (text.toString().trim().isNotEmpty) {
            transcript = text.toString();
            isSuccess = true;
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _state = _VoiceState.idle);
      if (isSuccess) {
        widget.onVoiceResult(transcript);
      } else {
        ref.read(chatMessagesProvider.notifier).addAiMessage('Backend not reachable');
      }
    }
  }

  Future<void> _toggle() async {
    if (_state == _VoiceState.recording) {
      await _stopRecording();
    } else if (_state == _VoiceState.idle) {
      await _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _state == _VoiceState.recording;
    final isProcessing = _state == _VoiceState.processing;

    return GestureDetector(
      onTap: isProcessing ? null : _toggle,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: isRecording ? _pulseAnim.value : 1.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse ring
                if (isRecording)
                  Container(
                    width: AppDimensions.voiceButtonSize + 10,
                    height: AppDimensions.voiceButtonSize + 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withOpacity(0.15),
                    ),
                  ),
                // Main button
                Container(
                  width: AppDimensions.voiceButtonSize,
                  height: AppDimensions.voiceButtonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording
                        ? AppColors.error
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: isRecording ? Colors.white : AppColors.textSecondary,
                          size: 22,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
