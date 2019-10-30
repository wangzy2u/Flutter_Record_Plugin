//
//  FlutterAudioPlayEngine.h
//  pedi
//
//  Created by li xiaolin on 2017/12/11.
//  Copyright © 2017年 北京嘉润云众健康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlutterAudioPlayDelegate <NSObject>
- (void)playComplete;
- (void)playError:(NSString *)error;
@end

@interface FlutterAudioPlayEngine : NSObject
- (instancetype)initWithDelegate:(id<FlutterAudioPlayDelegate>)delegate;

- (BOOL)start:(NSString *)mp3Path;

- (void)pause;
- (void)play;
- (void)stop;
@end
