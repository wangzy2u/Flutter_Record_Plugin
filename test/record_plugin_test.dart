import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record_plugin/record_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('record_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    //expect(await RecordPlugin.platformVersion, '42');
  });
}
