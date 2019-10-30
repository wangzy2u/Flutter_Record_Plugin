//
//  FlutterAudioRecordEngine.h
//  pedi
//
//  Created by li xiaolin on 2017/12/11.
//  Copyright © 2017年 北京嘉润云众健康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlutterAudioRecordDelegate <NSObject>
- (void)recordProgress:(float)seconds;
- (void)recordComplete:(NSString *)mp3Path recordSeconds:(float)recordSeconds;
- (void)recordError:(NSString *)error;
@end


@interface FlutterAudioRecordEngine : NSObject
- (instancetype)initWithDelegate:(id<FlutterAudioRecordDelegate>)delegate;

- (void)setMaxDuration:(float)seconds;

- (BOOL)start;
- (void)reset;

- (void)pause;
- (void)record;
- (void)stop;
@end
