//
//  FlutterAudioRecordEngine.m
//  pedi
//
//  Created by li xiaolin on 2017/12/11.
//  Copyright © 2017年 北京嘉润云众健康科技有限公司. All rights reserved.
//

#import "FlutterAudioRecordEngine.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#define KRecordFolderPath @"shortAnswer"
#define KTempFileName @"record.caf"
#define KMp3FileName @"record.mp3"


@interface FlutterAudioRecordEngine () <AVAudioRecorderDelegate>
@property (nonatomic, weak) id<FlutterAudioRecordDelegate> delegate;

@property (nonatomic, copy) NSString *tempFilePath;
@property (nonatomic, copy) NSString *mp3FilePath;

@property (nonatomic, assign) CGFloat sampleRate;
@property (nonatomic, assign) float maxDuration;
@property (nonatomic, assign) float recordSeconds;

@property (nonatomic, strong) NSDictionary *recordSetting;

@property (nonatomic, strong) NSTimer *recordTimer;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@end


@implementation FlutterAudioRecordEngine

- (instancetype)initWithDelegate:(id<FlutterAudioRecordDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;

        _sampleRate = 11025.f;
        _maxDuration = 120;
        _recordSeconds = 0;

        [self setFolder];
        [self setRecordSetting];
    }
    return self;
}

- (void)setFolder {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
                      stringByAppendingPathComponent:KRecordFolderPath];
    _tempFilePath = [path stringByAppendingPathComponent:KTempFileName];
    _mp3FilePath = [path stringByAppendingPathComponent:KMp3FileName];

    NSFileManager *mgr = [NSFileManager defaultManager];
    if (![mgr fileExistsAtPath:path]) {
        [mgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (void)setRecordSetting {
    _recordSetting = [[NSMutableDictionary alloc] init];
    // You can change the settings for the voice quality
    [_recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [_recordSetting setValue:[NSNumber numberWithFloat:_sampleRate] forKey:AVSampleRateKey];
    [_recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    [_recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityLow] forKey:AVEncoderAudioQualityKey];
//    [_recordSetting setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];//线性采样位数
}

- (void)setMaxDuration:(float)seconds {
    _maxDuration = seconds;
}

- (void)start {
    [self cleanFolder];

    if (![self checkRecordPermission]) {
        [self showRecordPermissionAlert];
        
        return;
    }

    [self setRecordSession];

    NSURL *url = [NSURL fileURLWithPath:_tempFilePath];
    NSError *error = nil;
    _audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:_recordSetting error:&error];
    if (_audioRecorder == nil) {
        NSString *message = [NSString stringWithFormat:@"start %@", [[error userInfo] description]];
        [_delegate recordError:message];
        return;
    }
    [_audioRecorder setDelegate:self];
    [_audioRecorder prepareToRecord];

    [_audioRecorder record];

    _recordSeconds = 0;
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(uFlutterateTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_recordTimer forMode:NSRunLoopCommonModes];
}

- (void)cleanFolder {
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:_tempFilePath error:nil];
    [mgr removeItemAtPath:_mp3FilePath error:nil];
}

- (BOOL)checkRecordPermission {
    __block BOOL result = NO;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            result = granted;
        }];
    }
    return result;
}

- (void)showRecordPermissionAlert {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"应用需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil];
//    [alertView showWithCompletionHandler:^(NSInteger buttonIndex) {
//        if (buttonIndex == 0) {
//            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//            [[UIApplication sharedApplication] openURL:url];
//        }
//    }];
}

- (void)setRecordSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSString *message = [NSString stringWithFormat:@"setRecordSession setCategory %@", [[error userInfo] description]];
        [_delegate recordError:message];
        return;
    }
    [audioSession setActive:YES error:&error];
    if (error) {
        NSString *message = [NSString stringWithFormat:@"setRecordSession setActive %@", [[error userInfo] description]];
        [_delegate recordError:message];
    }
}

- (void)setNormalSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSString *message = [NSString stringWithFormat:@"setRecordSession setCategory %@", [[error userInfo] description]];
        [_delegate recordError:message];
        return;
    }
    [session setActive:YES error:&error];
    if (error) {
        NSString *message = [NSString stringWithFormat:@"setRecordSession setActive %@", [[error userInfo] description]];
        [_delegate recordError:message];
    }
}

- (void)uFlutterateTime {
    _recordSeconds += 0.1;
    [_delegate recordProgress:_recordSeconds];

    if (_recordSeconds >= _maxDuration) {
        [self stop];
    }
}

- (void)reset {
    [_recordTimer invalidate];
    _recordTimer = nil;

    if ([_audioRecorder isRecording]) {
//        [KEY_WINDOW showLoadingMeg:@""];
        [_audioRecorder stop];
    }
    [self setNormalSession];
}

- (void)pause {
    if ([_audioRecorder isRecording]) {
        [_audioRecorder pause];
        [_recordTimer setFireDate:[NSDate distantFuture]];
    }
}

- (void)record {
    if (![_audioRecorder isRecording]) {
        [_audioRecorder record];
        [_recordTimer setFireDate:[NSDate date]];
    }
}

- (void)stop {
    [_recordTimer invalidate];
    _recordTimer = nil;

//    [KEY_WINDOW showLoadingMeg:@""];
    [_audioRecorder stop];
    [self setNormalSession];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (!flag) {
        [_delegate recordError:@"audioRecorderDidFinishRecording"];
    } else {
        [self transcode];
    }
}

- (void)transcode {
    __weak typeof (self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [weakSelf cafToMp3WithCafPath:weakSelf.tempFilePath mp3Path:weakSelf.mp3FilePath];

        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:weakSelf.tempFilePath] options:nil];
        float seconds =CMTimeGetSeconds(audioAsset.duration);
        NSLog(@"%f", seconds);
    });
}

- (void)cafToMp3WithCafPath:(NSString *)cafPath mp3Path:(NSString *)mp3Path {
    @try {
        int read, write;

        FILE *pcm = fopen([cafPath cStringUsingEncoding:1], "rb");// source
        fseek(pcm, 4*1024, SEEK_CUR);// skip file header
        FILE *mp3 = fopen([mp3Path cStringUsingEncoding:1], "wb");// output

        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];

        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, _sampleRate);
//        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);

        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }

            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        __weak typeof (self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *message = [NSString stringWithFormat:@"cafToMp3WithCafPath %@", [exception description]];
            [weakSelf.delegate recordError:message];
        });
    }
    @finally {
        __weak typeof (self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
//            [KEY_WINDOW hideLoading];
            [weakSelf.delegate recordComplete:weakSelf.mp3FilePath recordSeconds:weakSelf.recordSeconds];
        });
    }
}


- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags {
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags {
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder {
}

@end
