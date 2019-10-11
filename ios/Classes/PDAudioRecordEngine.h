//
//  PDAudioRecordEngine.h
//  pedi
//
//  Created by li xiaolin on 2017/12/11.
//  Copyright © 2017年 北京嘉润云众健康科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PDAudioRecordDelegate <NSObject>
- (void)recordProgress:(float)seconds;
- (void)recordComplete:(NSString *)mp3Path recordSeconds:(float)recordSeconds;
- (void)recordError:(NSString *)error;
@end


@interface PDAudioRecordEngine : NSObject
- (instancetype)initWithDelegate:(id<PDAudioRecordDelegate>)delegate;

- (void)setMaxDuration:(float)seconds;

- (void)start;
- (void)reset;

- (void)pause;
- (void)record;
- (void)stop;
@end
