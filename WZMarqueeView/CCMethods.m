//
//  CCMethods.m
//  MainProject
//
//  Created by cui on 16/11/18.
//  Copyright © 2016年 ZhongRuan. All rights reserved.
//

#import "CCMethods.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "Debug.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"
#import "TBPlayer.h"
@implementation CCMethods
{
    CMMotionManager *manager;
    CMPedometer *stepCounter;
    //声音
    AVAudioRecorder *_audioRecorder;
    NSDate *_recordOldDate;
    AVPlayer *_avPlayer;
    //合成
    AVSpeechSynthesizer *_speak;
    AVSpeechSynthesisVoice *_voice;
}
+(CCMethods*)shareSelf
{
    static CCMethods *method;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method=[[CCMethods alloc] init];
        
    });
    return method;
}
-(id)init
{
    if(self=[super init]){
        _speak=[[AVSpeechSynthesizer alloc] init];
    }
    return self;
}
#pragma mark - 语音合成
-(void)speakWithStr:(NSString *)str andLanguage:(NSString *)language andRate:(CGFloat)rate
{
    AVSpeechUtterance *utterane=[AVSpeechUtterance speechUtteranceWithString:str];
    utterane.rate=rate;
    _voice=[AVSpeechSynthesisVoice voiceWithLanguage:language];
    utterane.voice=_voice;
    [_speak speakUtterance:utterane];
}
#pragma mark - 动画
+(void)addAnimationWithTime:(CGFloat)time andBlock:(AddAnimationBLock)block
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:time];
    block(@"success");
    [UIView commitAnimations];
}
#pragma mark - 指纹
+(void)showIDWithSuccess:(TouchIDSuccess)successBlock andFailed:(TouchIDFailed)failedBlock
{
    LAContext *context=[[LAContext alloc] init];
    NSError *error;
    if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]){
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请输入指纹" reply:^(BOOL success, NSError * _Nullable error) {
            if(success){
                successBlock(@"success");
            }else{
                if(failedBlock){
                failedBlock(@"failed");
                }
            }
        }];
    }else{
        if(failedBlock){
        failedBlock(@"failed");
        }
    }
}
#pragma mark - 距离传感器
-(void)startListenDistanceChange:(distanceCloseBlock)close1 andFar:(distancefarBlock)far1
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(distanceChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    //距离传感器
    [UIDevice currentDevice].proximityMonitoringEnabled=YES;
    _close1=close1;
    _far1=far1;
}
-(void)distanceChanged:(NSNotification *)nf
{
     if ([UIDevice currentDevice].proximityState == YES) {
         if(_close1){
             self.close1(@"close");
         }
     }else{
         if(self.far1){
             self.far1(@"far");
         }
     }
}
#pragma mark - 加速计传感器
-(void)startListonAcceleration:(shakeBlock)shake
{
    manager=[[CMMotionManager alloc] init];
    if(manager.isAccelerometerAvailable){
        manager.accelerometerUpdateInterval=1.0/10.0;
        [manager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            if(shake){
                
                shake([NSString stringWithFormat:@"%f,%f,%f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z]);
            }
        }];
    }else{
        CCLog(@"加速计不好用");
    }
}
#pragma mark  - 计步器
-(void)startStepCount:(stepBlock)stepBlock
{
    if (![CMPedometer isStepCountingAvailable]) {
        CCLog(@"计步器不可用");
        return;
    }
    stepCounter = [[CMPedometer alloc] init];
    
    [stepCounter startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        if (error) return;
        // 4.获取采样数据
        if(stepBlock){
            stepBlock(pedometerData);
        }

    }];

}
#pragma mark - AES加密
+(NSData *)AddData:(NSData *)data AESKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}
+(NSData *)subDataWithData:(NSData *)data andAESKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        
    }
    free(buffer);
    return nil;
}
+(NSString *)addAESWithStr:(NSString *)str andKey:(NSString *)key
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    //对数据进行加密
    NSData *result = [CCMethods AddData:data AESKey:key];
    
    //转换为2进制字符串
    if (result && result.length > 0) {
        
        Byte *datas = (Byte*)[result bytes];
        NSMutableString *output = [NSMutableString stringWithCapacity:result.length * 2];
        for(int i = 0; i < result.length; i++){
            [output appendFormat:@"%02x", datas[i]];
        }
        return output;
    }
    return nil;
}
+(NSString *)subAESWithStr:(NSString *)str andKey:(NSString *)key
{
    NSMutableData *data = [NSMutableData dataWithCapacity:str.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [str length] / 2; i++) {
        byte_chars[0] = [str characterAtIndex:i*2];
        byte_chars[1] = [str characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    //对数据进行解密
    NSData* result = [CCMethods subDataWithData:data andAESKey:key];
    if (result && result.length > 0) {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}
#pragma mark - 20、64位SHA1
+(NSString *)addSHA1WithStr:(NSString *)str
{
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSData * base64 = [[NSData alloc]initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    base64 = [GTMBase64 encodeData:base64];
    
    NSString * output = [[NSString alloc] initWithData:base64 encoding:NSUTF8StringEncoding];
    return output;
}
#pragma mark - md5
+ (NSString *) md5_32:(NSString *)str
 {
        const char *cStr = [str UTF8String];
        unsigned char result[16];
        CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
        return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
        ];
}
#pragma mark - 录音
-(void)startListen:(NSString *)tempFile
{
    if(_audioRecorder.recording){
        CCLog(@"正在播放中...");
        return;
    }
    
    if(!_audioRecorder){
        [self customeListen:tempFile];
        
    }else{
        [_audioRecorder recordAtTime:[[NSDate date] timeIntervalSinceDate:_recordOldDate]];
    }
}
-(void)stopListen
{
    if(_audioRecorder.recording){
        _recordOldDate=[NSDate date];
        [_audioRecorder stop];
        CCLog(@"录音结束");
    }
}
-(void)pauseListon
{
    if(_audioRecorder.recording){
        _recordOldDate=[NSDate date];
        [_audioRecorder pause];
        CCLog(@"录音暂停");
    }
}
-(void)customeListen:(NSString *)tempFile
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:tempFile];
    //    NSMutableDictionary  需要加入五个设置值(线性PCM)
    NSMutableDictionary *recordSettings =
    [[NSMutableDictionary alloc] initWithCapacity:10];
    //1 ID号
    [recordSettings setObject:
     [NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //2 采样率 44100.0 96000.0
    [recordSettings setObject:
     [NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
    
    //3 通道的数目
    [recordSettings setObject:
     [NSNumber numberWithInt:2]
                       forKey:AVNumberOfChannelsKey];
    
    //4 采样位数  默认 16
    [recordSettings setObject:
     [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    //5
    [recordSettings setObject:
     [NSNumber numberWithBool:NO]
                       forKey:AVLinearPCMIsBigEndianKey];
    
    
    _audioRecorder=[[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    if(error){
        CCLog(@"开始录音失败%@",error);
    }else{
        CCLog(@"开始录音成功");
    }
    [_audioRecorder record];
}
#pragma mark - 转码
+(void)changeWavToMp3WithWavFile:(NSString *)wavFile andMp3File:(NSString *)mp3File andFinishBlock:(finishBlock)finish
{
    NSString *cafFilePath = wavFile;
    
    NSString *mp3FilePath = mp3File;
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        if(finish){
            finish(@"success");
        }
    }
    
}
#pragma mark - 播放
-(void)playMp3WithFile:(NSString *)filePath andView:(UIView *)view
{
    NSURL *url;
    if([filePath hasPrefix:@"http"]){
        url = [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }else{
        url=[NSURL fileURLWithPath:filePath];
    }
    
    [[TBPlayer sharedInstance] playWithUrl:url showView:view];
}
#pragma mark - 创建Label
+(UILabel *)createLabelWithWidth:(CGFloat)width andText:(NSString *)str andFont:(NSInteger)font andFrame:(CGRect)frame
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.text=str;
    label.numberOfLines=0;
    label.font=[UIFont systemFontOfSize:15];
    CGRect rect = [str boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    label.frame=CGRectMake(label.frame.origin.x,label.frame.origin.y , label.frame.size.width, rect.size.height);
    return label;
    
}
+(UILabel *)createLabelWithText:(NSString *)str andFont:(NSInteger)font andFrame:(CGRect)frame
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.text=str;
    label.numberOfLines=0;
    label.font=[UIFont systemFontOfSize:15];
    CGRect rect = [str boundingRectWithSize:CGSizeMake(400, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    label.frame=CGRectMake(label.frame.origin.x,label.frame.origin.y , rect.size.width, rect.size.height);
    return label;
    
}
#pragma mark - 阴影
+(void)addBlackLayerWithView:(UIView *)view
{
    view.layer.masksToBounds=NO;
    view.layer.shadowOpacity=0.7;
    view.layer.shadowColor=[UIColor grayColor].CGColor;
    view.layer.shadowOffset=CGSizeMake(5,5);
    view.layer.shadowRadius=5;
}
@end
