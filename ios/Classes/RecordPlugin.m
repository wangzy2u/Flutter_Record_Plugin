//
//  RecordPlugin.m
//  Runner
//
//  Created by WY on 2019/10/10.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "RecordPlugin.h"
#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import "PDAudioPlayEngine.h"
#import "PDAudioRecordEngine.h"

#define KMaxRecrodLength 180.0

@interface RecordPlugin() <PDAudioPlayDelegate, PDAudioRecordDelegate>
@property (nonatomic, strong) PDAudioPlayEngine *playEngine;
@property (nonatomic, strong) PDAudioRecordEngine *recordEngine;

@property (nonatomic, strong) FlutterMethodChannel *channel;

@property (nonatomic, strong) FlutterResult lastResult;
@end

@implementation RecordPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    RecordPlugin *plugin = [[RecordPlugin alloc] initWithRegistrar: registrar];
    [registrar addMethodCallDelegate:plugin channel:plugin.channel];
}

- (RecordPlugin *)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    if (self = [super init]) {
        _channel = [FlutterMethodChannel methodChannelWithName:@"record_plugin" binaryMessenger:registrar.messenger];

        _playEngine = [[PDAudioPlayEngine alloc] initWithDelegate:self];
        _recordEngine = [[PDAudioRecordEngine alloc] initWithDelegate:self];
        [_recordEngine setMaxDuration:KMaxRecrodLength];
    }
    return self;
}

- (void)playComplete {
    NSLog(@"playComplete");
    [_channel invokeMethod:@"audioPlayerDidFinishPlaying" arguments:nil];
}

- (void)playError:(NSString *)error {
    NSLog(@"playError");
}

- (void)recordProgress:(float)seconds {
    NSLog(@"recordProgress %f", seconds);
}

- (void)recordComplete:(NSString *)mp3Path recordSeconds:(float)recordSeconds {
    NSLog(@"recordComplete");
    _lastResult(mp3Path);
}

- (void)recordError:(NSString *)error {
    NSLog(@"recordError");
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"startRecord" isEqualToString:call.method]) {
        [self startRecord: result];
    } else if ([@"pauseRecord" isEqualToString:call.method]) {
        [self pauseRecord: result];
    } else if ([@"resumeRecord" isEqualToString:call.method]) {
        [self resumeRecord: result];
    } else if ([@"stopRecord" isEqualToString:call.method]) {
        [self stopRecord: result];
    } else if ([@"startPlay" isEqualToString:call.method]) {
        NSString *path = call.arguments[@"path"];
        [self startPlay: result path: path];
    } else if ([@"pausePlay" isEqualToString:call.method]) {
        [self pausePlay: result];
    } else if ([@"resumePlay" isEqualToString:call.method]) {
        [self resumePlay: result];
    } else if ([@"stopPlay" isEqualToString:call.method]) {
        [self stopPlay: result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}


- (void)startPlay:(FlutterResult)result path:(NSString *)path {
    NSLog(@"startPlay %@", path);
    [_playEngine start:path];
    result(@"true");
}

- (void)pausePlay:(FlutterResult)result {
    NSLog(@"pausePlay");
    [_playEngine pause];
    result(@"true");
}

- (void)resumePlay:(FlutterResult)result {
    NSLog(@"resumePlay");
    [_playEngine play];
    result(@"true");
}

- (void)stopPlay:(FlutterResult)result {
    NSLog(@"stopPlay");
    [_playEngine stop];
    result(@"true");
}


- (void)startRecord:(FlutterResult)result {
    NSLog(@"startRecord");
    [_recordEngine start];
    result(@"true");
}

- (void)pauseRecord:(FlutterResult)result {
    NSLog(@"pauseRecord");
    [_recordEngine pause];
    result(@"true");
}

- (void)resumeRecord:(FlutterResult)result {
    NSLog(@"resumeRecord");
    [_recordEngine record];
    result(@"true");
}

- (void)stopRecord:(FlutterResult)result {
    NSLog(@"stopRecord");
    [_recordEngine stop];
    _lastResult = result;
}



@end
