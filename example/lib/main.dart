import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:record_plugin/record_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String path = '';
  RecordPlugin recordPlugin;
  // ignore: unused_field
  StreamSubscription _recorderSubscription;
  @override
  void initState() {
    super.initState();
    recordPlugin = new RecordPlugin();
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  void startRecorder() async{

      recordPlugin.startRecord();
      try {

        recordPlugin.recordCallback = (result){
          setState(() {
            _platformVersion = result;
          });
        };

        _recorderSubscription = recordPlugin.onRecorderStateChanged.listen((e) {

          this.setState(() {
            this._platformVersion = e.toString();
          });
        });
      print('startRecorder: $path');



    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(

            children: <Widget>[

              Container(
                height: 40,
                child: Text('Running on: $_platformVersion\n'),
              ),
              Container(

                height: 40,
                child: FlatButton(
                  onPressed: (){
                    // ignore: unnecessary_statements
                    startRecorder();
                  },
                  child: Text('开始录音'),
                ),
              ),
              Container(
                height: 40,
                child:FlatButton(
                  onPressed: (){
                    recordPlugin.pauseRecord();
                  },
                  child: Text('暂停录音'),
                ),
              ),
              Container(
                height: 40,
                child: FlatButton(
                  onPressed: (){
                    recordPlugin.resumeRecord();
                  },
                  child: Text('继续录音'),
                ),
              ),
              Container(
                height: 40,
                child: FlatButton(
                  onPressed: (){
                    recordPlugin.stopRecord().then((result){
                      setState(() {
                        path = result;
                       // _platformVersion = result;
                        /*if (_recorderSubscription != null) {
                          _recorderSubscription.cancel();
                          _recorderSubscription = null;
                        }*/
                      });
                    });
                  },
                  child: Text('停止录音'),
                ),
              ),
              Container(
                height: 40,
                child: FlatButton(
                  onPressed: (){
                    recordPlugin.startPlayer(path).then((result){
                      setState(() {
                        _platformVersion = result.toString();
                      });
                    });
                  },
                  child: Text('开始播放'),
                ),
              ),
              Container(
                height: 40,
                child: FlatButton(
                  onPressed: (){
                    recordPlugin.pausePlayer().then((result){
                      setState(() {
                        _platformVersion = result.toString();
                      });
                    });
                  },
                  child: Text('暂停播放'),
                ),
              ),
              Container(
                height: 40,
                child: FlatButton(
                  onPressed: (){
                    recordPlugin.resumePlayer().then((result){
                      setState(() {
                        _platformVersion = result.toString();
                      });
                    });
                  },
                  child: Text('继续播放'),
                ),
              ),
              Container(
                height: 40,
                child: FlatButton(
                  onPressed: (){
                    recordPlugin.stopPlayer().then((result){
                      setState(() {
                        _platformVersion = result.toString();
                      });
                    });
                  },
                  child: Text('停止播放'),
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }
}
