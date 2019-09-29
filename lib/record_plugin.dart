import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'RecordBus.dart';

///录音工具类
class RecordPlugin {
  static const MethodChannel _channel = const MethodChannel('record_plugin');
  final RecordBus _recordBus = RecordBus();
  bool _isPlaying = false;

  RecordBus get recordBus => _recordBus;

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
          recordBus.fire(RecordStatus(0, call.arguments));
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
      return true;
      //throw PlayerRunningException('Player is already playing.');
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
      return true;
      //throw PlayerStoppedException('Player already stopped.');
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
          recordBus.fire(PlayStatus(0, 'playerFinish'));
          break;
        default:
          throw new ArgumentError('Unknown method ${call.method}');
      }
      return null;
    });
  }
}

class PlayStatus {
  final int status;
  final String message;

  PlayStatus(this.status, this.message);
}

class RecordStatus {
  final int status;
  final String message;

  RecordStatus(this.status, this.message);
}
