//
//  VideoCaptureManager.h
//
//  Created by Go Hayakawa on 2014/03/02.
//  Copyright (c) 2014年 Go Hayakawa. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

// デリゲートを定義
@protocol VideoCaputreManagerOutputDelegate <NSObject>
- (void)captureOutput:(UIImage*) image;
@end

@interface VideoCaptureManager : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>
- (void) start:(id<VideoCaputreManagerOutputDelegate>) delegete;
- (void) stop;
@end