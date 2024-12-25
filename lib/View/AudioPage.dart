import 'dart:math';
import 'package:FFinance/Controllers/AudioController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AudioPage extends StatelessWidget {
  final AudioController controller = Get.put(AudioController());

  // Definisi warna tema
  final Color primaryColor = Color(0xFF6C63FF);  // Ungu kebiruan modern
  final Color secondaryColor = Color(0xFF8F8FFF); // Ungu muda
  final Color backgroundColor = Color(0xFFF8F9FE); // Abu-abu sangat muda
  final Color cardColor = Colors.white;
  final Color textColor = Color(0xFF2D3142); // Abu-abu tua

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Voice Recorder',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(height: 16),
              _buildRecorderSection(),
              SizedBox(height: 24),
              _buildVisualizerSection(),
              SizedBox(height: 24),
              _buildRecordingsHeader(),
              SizedBox(height: 8),
              _buildRecordingsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecorderSection() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => Text(
            controller.isRecording.value ? 'Recording...' : 'Tap to Record',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: controller.isRecording.value ? Color(0xFFFF6B6B) : textColor,
              letterSpacing: 0.3,
            ),
          )),
          SizedBox(height: 24),
          Obx(() => GestureDetector(
            onTapDown: (_) async {
              if (!controller.isRecording.value) {
                await controller.startRecording();
              }
            },
            onTapUp: (_) async {
              if (controller.isRecording.value) {
                await controller.stopRecording();
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.isRecording.value ? Color(0xFFFF6B6B) : primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: (controller.isRecording.value ? Color(0xFFFF6B6B) : primaryColor).withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                controller.isRecording.value ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildVisualizerSection() {
    return Container(
      height: 100,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => CustomPaint(
        painter: AudioVisualizerPainter(
          amplitude: controller.amplitude.value,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
        ),
        size: Size.infinite,
      )),
    );
  }

  Widget _buildRecordingsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Text(
            'Recordings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Spacer(),
          Obx(() => Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.recordings.length} items',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecordingsList() {
    return Expanded(
      child: Obx(() => ListView.builder(
        itemCount: controller.recordings.length,
        padding: EdgeInsets.only(top: 8, bottom: 16),
        itemBuilder: (context, index) {
          final record = controller.recordings[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.06),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.audio_file_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              title: Text(
                record.title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(record.timestamp),
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPlayButton(record.id),
                  SizedBox(width: 8),
                  _buildDeleteButton(context, record.id),
                ],
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildPlayButton(String recordId) {
    return Obx(() {
      final isPlaying = controller.currentPlayingId.value == recordId;
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isPlaying ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Icon(
            isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: primaryColor,
            size: 24,
          ),
          padding: EdgeInsets.zero,
          onPressed: () async {
            if (isPlaying) {
              await controller.stopPlaying();
            } else {
              await controller.playRecording(recordId);
            }
          },
        ),
      );
    });
  }

  Widget _buildDeleteButton(BuildContext context, String recordId) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFFF6B6B),
          size: 24,
        ),
        padding: EdgeInsets.zero,
        onPressed: () => _showDeleteConfirmation(context, recordId),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Recording',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this recording?',
          style: TextStyle(color: textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: textColor.withOpacity(0.8)),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              controller.deleteRecording(recordId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class AudioVisualizerPainter extends CustomPainter {
  final double amplitude;
  final Color primaryColor;
  final Color secondaryColor;

  AudioVisualizerPainter({
    required this.amplitude,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(0.6),
          secondaryColor.withOpacity(0.3),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    final path = Path();
    path.moveTo(0, centerY);

    for (var i = 0; i < width; i++) {
      final x = i.toDouble();
      final normalizedAmplitude = (amplitude / 100) * 30;
      final y = centerY + (normalizedAmplitude * sin(x * 0.04));
      path.lineTo(x, y);
    }

    path.lineTo(width, centerY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AudioVisualizerPainter oldDelegate) =>
      oldDelegate.amplitude != amplitude;
}