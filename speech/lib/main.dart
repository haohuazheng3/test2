import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:another_audio_recorder/another_audio_recorder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AnotherAudioRecorder _recorder;
  late stt.SpeechToText _speech;
  bool _isRecording = false;
  bool _isListening = false;
  String _text = 'Press to talk';
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    _hasPermission = await AnotherAudioRecorder.hasPermissions;
    if (_hasPermission) {
      await _initRecorder();
    } else {
      setState(() {
        _text = 'Not Authoried';
      });
    }
    _speech.initialize();
  }

  Future<void> _initRecorder() async {
    final dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    _recorder = AnotherAudioRecorder(path, audioFormat: AudioFormat.AAC);
    await _recorder.initialized;
}

void _toggleRecording() async {
    if (!_hasPermission) {
      setState(() {
        _text = 'Not Authoried';
      });
      return;
    }
    if (_isRecording) {
      var result = await _recorder.stop();
      if (result != null && result.path != null) {
        File file = File(result.path!);
        setState(() {
          _isRecording = false;
          _text = 'Successeful. Saved:${file.path}';
        });
      } else {
        setState(() {
          _isRecording = false;
          _text = 'Failed, Cannot save the file';
        });
      }
      await _initRecorder(); 
    } else {
      await _recorder.start();
      setState(() {
        _isRecording = true;
        _text = 'recording';
      });
    }
    _toggleListening();
}

  void _toggleListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
      );
      setState(() => _isListening = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FloatingActionButton(
                onPressed: _toggleRecording,
                child: Icon(_isRecording ? Icons.stop : Icons.mic),
              ),
              SizedBox(height: 20),
              Text(_text),
            ],
          ),
        ),
      ),
    );
  }
}