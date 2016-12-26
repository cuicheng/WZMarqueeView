//
//  CCMethods.h
//  MainProject
//
//  Created by cui on 16/11/18.
//  Copyright © 2016年 ZhongRuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
typedef void(^TouchIDSuccess)(NSString *status);
typedef void(^TouchIDFailed)(NSString *status);
@interface CCMethods : NSObject
typedef void (^finishBlock)(NSString *status);
+(CCMethods*)shareSelf;
//动画
typedef void(^AddAnimationBLock)(NSString *status);
//动画
+(void)addAnimationWithTime:(CGFloat)time andBlock:(AddAnimationBLock)block;
//指纹
+(void)showIDWithSuccess:(TouchIDSuccess)successBlock andFailed:(TouchIDFailed)failedBlock;
//距离
typedef void (^distanceCloseBlock)(NSString *status);
typedef void (^distancefarBlock)(NSString *status);
@property (nonatomic,copy) void (^close1)(NSString *status);
@property (nonatomic,copy) void (^far1)(NSString *status);
//距离
-(void)startListenDistanceChange:(distanceCloseBlock)close1 andFar:(distancefarBlock)far1;

//加速计
typedef void (^shakeBlock)(NSString *data);
typedef void (^stepBlock)(CMPedometerData*data);
-(void)startListonAcceleration:(shakeBlock)shake;
//计步器
-(void)startStepCount:(stepBlock)stepBlock;
//AES加密
+(NSData *)AddData:(NSData *)data AESKey:(NSString *)key;
+(NSData *)subDataWithData:(NSData *)data andAESKey:(NSString *)key;
+(NSString *)addAESWithStr:(NSString *)str andKey:(NSString *)key;
+(NSString *)subAESWithStr:(NSString *)str andKey:(NSString *)key;
//SHA1
+(NSString *)addSHA1WithStr:(NSString *)str;
//md5
+ (NSString *) md5_32:(NSString *)str;
//录音
-(void)startListen:(NSString *)tempFile;
-(void)stopListen;
//转码
+(void)changeWavToMp3WithWavFile:(NSString *)wavFile andMp3File:(NSString *)mp3File andFinishBlock:(finishBlock)finish;
//播放
-(void)playMp3WithFile:(NSString *)filePath andView:(UIView *)view;
//label
+(UILabel *)createLabelWithWidth:(CGFloat)width andText:(NSString *)str andFont:(NSInteger)font andFrame:(CGRect)frame;
+(UILabel *)createLabelWithText:(NSString *)str andFont:(NSInteger)font andFrame:(CGRect)frame;
#pragma mark - 语音合成
//    中文 @"zh-Hans"  zh-HK 粤语
//    韩语 @"ko_KP"  안녕하세요,:사랑해요!
//    日语 @"ja_JP" なんで、なんでお前は他人のためにここまで。 nan de,nan de o ma e wa ta nin no ta me ni ko ko ma de?
//俄语  “ru_KZ” Я люблю тебя
//英语 en_CM hello,my Name is liangjinming , i am a stupid ,i am a son of bitch
//法语  fr_HT    Je t'aime!
-(void)speakWithStr:(NSString *)str andLanguage:(NSString *)language andRate:(CGFloat)rate;
#pragma mark - 阴影
+(void)addBlackLayerWithView:(UIView *)view;
@end
