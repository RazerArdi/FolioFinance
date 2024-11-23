import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerController extends GetxController {
  final _audioPlayer = AudioPlayer();
  RxBool isPlaying = false.obs;
  RxDouble currentPosition = 0.0.obs;
  RxDouble duration = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setAudioSource(AudioSource.asset('assets/audio/music1.mp3')); // Ganti dengan path audio Anda
    _audioPlayer.playerStateStream.listen((playerState) {
      isPlaying.value = playerState.playing;
      if (playerState.processingState == ProcessingState.ready) {
        duration.value = _audioPlayer.duration!.inMilliseconds.toDouble();
      }
    });
    _audioPlayer.positionStream.listen((position) {
      currentPosition.value = position.inMilliseconds.toDouble();
    });
  }

  void play() async {
    await _audioPlayer.play();
  }

  void pause() async {
    await _audioPlayer.pause();
  }

  void seek(double position) {
    _audioPlayer.seek(Duration(milliseconds: position.toInt()));
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}