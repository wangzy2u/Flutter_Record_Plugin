//
//  FlutterAudioPlayEngine.m
//  pedi
//
//  Created by li xiaolin on 2017/12/11.
//  Copyright © 2017年 北京嘉润云众健康科技有限公司. All rights reserved.
//

#import "FlutterAudioPlayEngine.h"
#import <AVFoundation/AVFoundation.h>

@interface FlutterAudioPlayEngine () <AVAudioPlayerDelegate>
@property (nonatomic, weak) id<FlutterAudioPlayDelegate> delegate;

@property (nonatomic, copy) NSString *mp3FilePath;

@property (nonatomic, assign) float playSeconds;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation FlutterAudioPlayEngine

- (instancetype)initWithDelegate:(id<FlutterAudioPlayDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (BOOL)start:(NSString *)mp3Path {

    [self setRecordSession];

    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:mp3Path] error:&error];
    if (_audioPlayer == nil) {
        NSString *message = [NSString stringWithFormat:@"start %@", [[error userInfo] description]];
        [_delegate playError:message];
        return NO;
    }
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    return YES;
}

- (void)setRecordSession {
//    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
//    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
//                            sizeof(sessionCategory),
//                            &sessionCategory);
//
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                             sizeof (audioRouteOverride),
//                             &audioRouteOverride);
//
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [audioSession setActive:YES error:nil];


    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSString *message = [NSString stringWithFormat:@"setRecordSession setCategory %@", [[error userInfo] description]];
        [_delegate playError:message];
        return;
    }
    [audioSession setActive:YES error:&error];
    if (error) {
        NSString *message = [NSString stringWithFormat:@"setRecordSession setActive %@", [[error userInfo] description]];
        [_delegate playError:message];
    }
}

- (void)setNormalSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSString *message = [NSString stringWithFormat:@"setRecordSession setCategory %@", [[error userInfo] description]];
        [_delegate playError:message];
        return;
    }
    [session setActive:YES error:&error];
    if (error) {
        NSString *message = [NSString stringWithFormat:@"setRecordSession setActive %@", [[error userInfo] description]];
        [_delegate playError:message];
    }
}

- (void)pause {
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer pause];
    }
}

- (void)play {
    if (![_audioPlayer isPlaying]) {
        [_audioPlayer play];
    }
}

- (void)stop {
    [_audioPlayer stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_delegate playComplete];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSString *message = [NSString stringWithFormat:@"audioPlayerDecodeErrorDidOccur %@", [[error userInfo] description]];
    [_delegate playError:message];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags {
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
}

@end
