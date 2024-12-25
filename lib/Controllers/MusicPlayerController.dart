import 'package:FFinance/gen/assets.gen.dart';
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
    try {
      // Tambahkan log untuk debug
      print('Loading audio file: ${Assets.audios.song1.path}');

      await _audioPlayer.setAudioSource(
        AudioSource.asset(Assets.audios.song1.path),
        // Tambahkan initialPosition
        initialPosition: Duration.zero,
        // Tambahkan preload
        preload: true,
      );

      // Tambahkan error handling
      _audioPlayer.playbackEventStream.listen(
            (event) {
          // Handle playback events
        },
        onError: (Object e, StackTrace st) {
          print('A stream error occurred: $e');
        },
      );

      _audioPlayer.playerStateStream.listen(
            (playerState) {
          isPlaying.value = playerState.playing;
          if (playerState.processingState == ProcessingState.ready) {
            duration.value = _audioPlayer.duration!.inMilliseconds.toDouble();
          }
        },
        onError: (e) {
          print('Error on playerStateStream: $e');
        },
      );

      _audioPlayer.positionStream.listen(
            (position) {
          currentPosition.value = position.inMilliseconds.toDouble();
        },
        onError: (e) {
          print('Error on positionStream: $e');
        },
      );
    } catch (e, stack) {
      print('Error initializing audio player: $e');
      print('Stack trace: $stack');
    }
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
