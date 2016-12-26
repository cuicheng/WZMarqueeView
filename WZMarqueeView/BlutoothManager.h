//
//  BlutoothManager.h
//  DataFrameWork
//
//  Created by cui on 16/8/9.
//  Copyright © 2016年 ccc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BlutoothManager : NSObject <CBCentralManagerDelegate,CBPeripheralManagerDelegate,CBPeripheralDelegate>
+(BlutoothManager*)shareSelf;
//查找
-(void)startFindDevice;
//发送
-(void)startPostDeviceInfo;
//准许配对
@property (nonatomic,copy)void (^findNewDeviceBlock)(NSDictionary*info);
//准许链接
-(void)allowConnect:(NSString *)UUID;
-(void)NotConnect:(NSString *)UUID;
//发送
-(void)postSomeThing:(NSData *)data;
@end
