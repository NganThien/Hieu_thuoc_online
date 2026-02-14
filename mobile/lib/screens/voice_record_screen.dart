import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceRecordScreen extends StatefulWidget {
  const VoiceRecordScreen({super.key});

  @override
  State<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasPermission = false;
  String _status = '';
  String? _lastRecordPath;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final ok = await _recorder.hasPermission();
    if (mounted) {
      setState(() {
        _hasPermission = ok;
        _status = ok ? 'Chạm để bắt đầu ghi âm' : 'Cần cấp quyền micro để ghi âm';
      });
    }
  }

  Future<String> _getRecordPath() async {
    final dir = await getTemporaryDirectory();
    final name = 'ghi_am_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return '${dir.path}/$name';
  }

  Future<void> _toggleRecord() async {
    if (!_hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cấp quyền micro trong Cài đặt')),
      );
      return;
    }

    if (_isRecording) {
      await _stopRecord();
    } else {
      await _startRecord();
    }
  }

  Future<void> _startRecord() async {
    try {
      final path = await _getRecordPath();
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      if (mounted) {
        setState(() {
          _isRecording = true;
          _seconds = 0;
          _status = 'Đang ghi âm...';
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _seconds++);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Lỗi: $e');
      }
    }
  }

  Future<void> _stopRecord() async {
    _timer?.cancel();
    _timer = null;
    final path = await _recorder.stop();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _lastRecordPath = path;
        _status = path != null ? 'Đã lưu ghi âm' : 'Đã dừng';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isRecording) _recorder.stop();
    super.dispose();
  }

  String get _durationText {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('Ghi âm'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _status,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              if (_isRecording) ...[
                const SizedBox(height: 24),
                Text(
                  _durationText,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF009688),
                  ),
                ),
              ],
              if (_lastRecordPath != null && !_isRecording)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'File đã lưu',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: _toggleRecord,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? Colors.red : const Color(0xFF009688),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : const Color(0xFF009688))
                            .withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording ? 'Chạm để dừng' : 'Chạm để ghi âm',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF009688),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
