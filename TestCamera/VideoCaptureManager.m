//
//  VideoCaptureManager.m
//
//  Created by Go Hayakawa on 2014/03/02.
//  Copyright (c) 2014年 Go Hayakawa. All rights reserved.
//

#import "VideoCaptureManager.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoCaptureManager()

@property AVCaptureSession *session;

@property id<VideoCaputreManagerOutputDelegate> delegate;

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end

@implementation VideoCaptureManager

/**
 * キャプチャの準備
 */
- (id) init
{
    self = [super init];
    
    // セッション作成
    self.session = [[AVCaptureSession alloc] init];
    
    // 入力を追加する
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [self.session addInput:input];
    
    // 出力を追加する
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA) };
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:output];
    
    return self;
}

/**
 * キャプチャを開始
 */
- (void) start:(id<VideoCaputreManagerOutputDelegate>) delegete;
{
    self.delegate = delegete;
    [self.session startRunning];
}

/**
 * キャプチャを停止
 */
- (void) stop
{
    [self.session stopRunning];
}

/**
 * AVCaptureVideoDataOutputSampleBufferDelegateのデリゲートメソッド
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    // VideoCaputreManagerOutputDelegateのデリゲートメソッドを呼び出す
    [self.delegate captureOutput:image];
}

/**
 * サンプルバッファからUIImageを生成する
 */
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // イメージバッファの取得
    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // イメージバッファのロック
    CVPixelBufferLockBaseAddress(buffer, 0);
    // イメージバッファ情報の取得
    uint8_t *base = CVPixelBufferGetBaseAddress(buffer);
    size_t width = CVPixelBufferGetWidth(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    // ビットマップコンテキストの作成
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace,
                                                   kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    // 画像の作成
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    UIImage* image = [UIImage imageWithCGImage:cgImage scale:1.0f
                                   orientation:UIImageOrientationRight]; // 90度右に回転
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    // イメージバッファのアンロック
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}

@end
