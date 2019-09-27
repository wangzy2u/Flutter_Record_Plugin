import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'RecordBus.dart';

typedef void OnTimerCallback(int second);
typedef void RecordCallback(String result);
///录音工具类
class RecordPlugin {
  static const MethodChannel _channel = const MethodChannel('record_plugin');
  final RecordBus _recordBus = RecordBus();
  bool _isPlaying = false;

  RecordCallback _recordCallback;


  RecordBus get recordBus => _recordBus;

  RecordCallback get recordCallback => _recordCallback;

  // ignore: unnecessary_getters_setters
  set recordCallback(RecordCallback value) {
    _recordCallback = value;
  }

  RecordPlugin();




  Future startRecord() async {
    final bool result = await _channel.invokeMethod('startRecord');
    _setRecorderCallback();
    return result;
  }

  Future pauseRecord() async {
    final bool result = await _channel.invokeMethod('pauseRecord');
    return result;
  }

  Future resumeRecord() async {
    final bool result = await _channel.invokeMethod('resumeRecord');
    return result;
  }

  Future stopRecord() async {
    final String result = await _channel.invokeMethod('stopRecord');
    return result;
  }

  Future<void> _setRecorderCallback() async {
    _channel.setMethodCallHandler((MethodCall call) {

      switch (call.method) {
        case 'PAUSE':
          break;
        case "IDLE":
          break;
        case "RECORDING":
          break;
        case "STOP":
          break;
        case "RecordResult":
          if ( _recordCallback !=null ) _recordCallback(call.arguments);
          break;
        case "FINISH":
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method} ');
      }
      return null;
    });
  }

  ///播放相关
  Future<bool> startPlayer(String uri) async {
    if (this._isPlaying) {
      throw PlayerRunningException('Player is already playing.');
    }

    try {
     bool result = await _channel.invokeMethod('startPlay', {
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

  Future<bool> stopPlayer() async {
    if (!this._isPlaying) {
      throw PlayerStoppedException('Player already stopped.');
    }
    this._isPlaying = false;

    bool result = await _channel.invokeMethod('stopPlay');
    return result;
  }

  Future<bool> pausePlayer() async {
    bool result = await _channel.invokeMethod('pausePlay');
    return result;
  }

  Future<bool> resumePlayer() async {
    bool result = await _channel.invokeMethod('resumePlay');
    return result;
  }

  Future<void> _setPlayerCallback() async {
    _channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case "updateProgress":
          Map<String, dynamic> result = jsonDecode(call.arguments);
          break;
        case "audioPlayerDidFinishPlaying":
          this._isPlaying = false;
          recordBus.fire(PlayStatus(0,'playerFinish'));
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method}');
      }
      return null;
    });
  }

}

class PlayStatus {
  final int code;
  final String message;

  PlayStatus(this.code, this.message);
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
