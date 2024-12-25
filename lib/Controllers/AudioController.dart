// audio_controller.dart
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class AudioRecord {
  final String id;
  final String path;
  final DateTime timestamp;
  final String title;

  AudioRecord({
    required this.id,
    required this.path,
    required this.timestamp,
    required this.title,
  });
}

class AudioController extends GetxController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final _audioRecords = <AudioRecord>[].obs;

  RxBool isRecording = false.obs;
  RxBool isPlaying = false.obs;
  RxString currentPlayingId = ''.obs;
  RxDouble amplitude = 0.0.obs;

  String? _currentRecordingPath;

  @override
  void onInit() {
    super.onInit();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await requestPermissions();
    await _recorder.openRecorder();
    await _player.openPlayer();

    // Setup amplitude listener
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 50));
    _recorder.onProgress!.listen((event) {
      amplitude.value = event.decibels ?? 0;
    });
  }

  Future<void> requestPermissions() async {
    // Meminta izin mikrofon
    if (await Permission.microphone.isDenied) {
      await Permission.microphone.request();
    }

    // Meminta izin penyimpanan
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  Future<void> startRecording() async {
    final tempDir = await getTemporaryDirectory();
    _currentRecordingPath = '${tempDir.path}/${const Uuid().v4()}.m4a';
    await _recorder.startRecorder(
      toFile: _currentRecordingPath,
      codec: Codec.aacMP4,
    );
    isRecording.value = true;
  }

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    if (_currentRecordingPath != null) {
      _audioRecords.add(AudioRecord(
        id: const Uuid().v4(),
        path: _currentRecordingPath!,
        timestamp: DateTime.now(),
        title: 'Recording ${_audioRecords.length + 1}',
      ));
    }
    isRecording.value = false;
    amplitude.value = 0;
  }

  Future<void> playRecording(String recordId) async {
    final record = _audioRecords.firstWhere((element) => element.id == recordId);
    currentPlayingId.value = recordId;
    isPlaying.value = true;

    await _player.startPlayer(
      fromURI: record.path,
      whenFinished: () {
        isPlaying.value = false;
        currentPlayingId.value = '';
      },
    );
  }

  Future<void> stopPlaying() async {
    await _player.stopPlayer();
    isPlaying.value = false;
    currentPlayingId.value = '';
  }

  Future<void> deleteRecording(String recordId) async {
    final record = _audioRecords.firstWhere((element) => element.id == recordId);

    if (currentPlayingId.value == recordId) {
      await stopPlaying();
    }

    final file = File(record.path);
    if (await file.exists()) {
      await file.delete();
    }

    _audioRecords.removeWhere((element) => element.id == recordId);
  }

  List<AudioRecord> get recordings => _audioRecords;

  @override
  void onClose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.onClose();
  }
}