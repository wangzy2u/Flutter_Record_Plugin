import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

typedef void OnTimerCallback(int second);

///录音工具类
class RecordPlugin {
  static const MethodChannel _channel = const MethodChannel('record_plugin');

  bool _isPlaying = false;

  static StreamController<PlayStatus> _playerController;
  static StreamController<String> _recorderController;

  Stream<String> get onRecorderStateChanged => _recorderController.stream;

  Stream<PlayStatus> get onPlayerStateChanged => _playerController.stream;

  RecordPlugin();

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future startRecord() async {
    final String version = await _channel.invokeMethod('startRecord');
    _setRecorderCallback();
    return version;
  }

  Future pauseRecord() async {
    final String version = await _channel.invokeMethod('pauseRecord');
    return version;
  }

  Future resumeRecord() async {
    final String version = await _channel.invokeMethod('resumeRecord');
    return version;
  }

  Future stopRecord() async {
    final String version = await _channel.invokeMethod('stopRecord');
    _removeRecorderCallback();
    return version;
  }

  Future<void> _setRecorderCallback() async {
    if (_recorderController == null) {
      _recorderController = new StreamController.broadcast();
    }

    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case 'PAUSE':
          if (_recorderController != null) _recorderController.add('PAUSE');
          break;
        case "IDLE":
          break;
        case "RECORDING":
          break;
        case "STOP":
          if (_recorderController != null) _recorderController.add('STOP');
          break;
        case "FINISH":
          if (_recorderController != null) _recorderController.add('FINISH');
          _removeRecorderCallback();
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method} ');
      }
      return null;
    });
  }

  ///播放相关
  Future<String> startPlayer(String uri) async {
    if (this._isPlaying) {
      throw PlayerRunningException('Player is already playing.');
    }

    try {
      String result = await _channel.invokeMethod('startPlay', {
        'path': uri,
      });
      print('startPlayer result: $result');
      this._isPlaying = true;
      _setPlayerCallback();

      return result;
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<String> stopPlayer() async {
    if (!this._isPlaying) {
      throw PlayerStoppedException('Player already stopped.');
    }
    this._isPlaying = false;

    String result = await _channel.invokeMethod('stopPlay');
    _removePlayerCallback();
    return result;
  }

  Future<String> pausePlayer() async {
    String result = await _channel.invokeMethod('pausePlay');
    return result;
  }

  Future<String> resumePlayer() async {
    String result = await _channel.invokeMethod('resumePlay');
    return result;
  }

  Future<void> _setPlayerCallback() async {
    if (_playerController == null) {
      _playerController = new StreamController.broadcast();
    }

    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "updateProgress":
          Map<String, dynamic> result = jsonDecode(call.arguments);
          if (_playerController != null)
            _playerController.add(new PlayStatus.fromJSON(result));
          break;
        case "audioPlayerDidFinishPlaying":
          this._isPlaying = false;
          Map<String, dynamic> result = jsonDecode(call.arguments);
          PlayStatus status = new PlayStatus.fromJSON(result);
          if (status.currentPosition != status.duration) {
            status.currentPosition = status.duration;
          }
          if (_playerController != null) _playerController.add(status);

          _removePlayerCallback();
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method}');
      }
      return null;
    });
  }

  Future<void> _removeRecorderCallback() async {
    if (_recorderController != null) {
      _recorderController
        ..add(null)
        ..close();
      _recorderController = null;
    }
  }

  Future<void> _removePlayerCallback() async {
    if (_playerController != null) {
      _playerController
        ..add(null)
        ..close();
      _playerController = null;
    }
  }
}

class PlayStatus {
  final double duration;
  double currentPosition;

  PlayStatus.fromJSON(Map<String, dynamic> json)
      : duration = double.parse(json['duration']),
        currentPosition = double.parse(json['current_position']);

  @override
  String toString() {
    return 'duration: $duration, '
        'currentPosition: $currentPosition';
  }
}

class PlayerRunningException implements Exception {
  final String message;

  PlayerRunningException(this.message);
}

class PlayerStoppedException implements Exception {
  final String message;

  PlayerStoppedException(this.message);
}

class RecorderRunningException implements Exception {
  final String message;

  RecorderRunningException(this.message);
}

class RecorderStoppedException implements Exception {
  final String message;

  RecorderStoppedException(this.message);
}
