//
//  BlutoothManager.m
//  DataFrameWork
//
//  Created by cui on 16/8/9.
//  Copyright © 2016年 ccc. All rights reserved.
//

#import "BlutoothManager.h"
#import "GetInfo.h"
@implementation BlutoothManager
{
    CBPeripheralManager *_postManager;
    
    CBCentralManager *_getManager;
    NSDictionary *_currentDevice;
    CBPeripheral *_currentPerinal;
    CBCharacteristic *_writeCharact;
    NSMutableArray *_notAllowArray;
    BOOL _isShow;
}
+(BlutoothManager*)shareSelf
{
    static BlutoothManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[BlutoothManager alloc] init];
    });
    return manager;
}
#pragma mark - 扫描
-(void)startFindDevice
{
    [_postManager stopAdvertising];
    if(!_getManager){
        _getManager=[[CBCentralManager alloc] initWithDelegate:self queue:dispatch_queue_create("new", DISPATCH_QUEUE_CONCURRENT)];
    }else{
        [_getManager scanForPeripheralsWithServices:nil
                                            options:@{CBCentralManagerScanOptionAllowDuplicatesKey :
                                                          @YES }];
    }
}
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"扫描状态%ld",(long)central.state);
    if(central.state==5){
        [_getManager scanForPeripheralsWithServices:nil
                                            options:nil];
    }
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict
{
    
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%@",peripheral.name);
    if([advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"]&&[[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] isKindOfClass:[NSArray class]]){
        CBUUID *UUID=[[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] firstObject];
        NSString *UUIDStr=UUID.UUIDString;
        if(UUIDStr){
            _currentPerinal=peripheral;
            if(_isShow==YES){
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.findNewDeviceBlock){
                    _isShow=YES;
                    self.findNewDeviceBlock(@{@"name":peripheral.name,@"UUID":UUIDStr});
                }
            });
        }
    }
    
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"链接成功");
    [_getManager stopScan];
    [_currentDevice setValue:peripheral forKey:@"1"];
    peripheral.delegate=self;
    [peripheral discoverServices:nil];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"链接失败");
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"中心断开连接了");
    [_getManager stopScan];
    [_getManager connectPeripheral:peripheral options:nil];
}

#pragma mark - 发送
-(void)startPostDeviceInfo
{
    [_getManager stopScan];
    if(!_postManager){
        _postManager=[[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_queue_create("new", DISPATCH_QUEUE_CONCURRENT)];
    }else{
        NSString *name=[[GetInfo getIphoneInfo] objectForKey:@"所有者"];
        NSString *UUID=[[GetInfo getIphoneInfo] objectForKey:@"UUID"];
        [_postManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:UUID]],CBAdvertisementDataLocalNameKey:name}];
    }
}
#pragma mark - post
-(void)customePost
{
    NSString *UUID=@"48022E37-CED8-4EC7-9F67-6B980A6B8DE2";
//    [[GetInfo getIphoneInfo] objectForKey:@"UUID"];
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:@"18C5B0FC-422C-4BE0-BB8D-3E40E31C556B"];
    // Creates the characteristic read
    CBMutableCharacteristic * _customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:
                                                       characteristicUUID properties:CBCharacteristicPropertyNotify
                                                                                              value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableCharacteristic *write = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"E182EA6A-7E93-43F5-8D41-4680C35AE684"] properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
    // Creates the service UUID
    CBUUID *serviceUUID = [CBUUID UUIDWithString:UUID];
    // Creates the service and adds the characteristic to it 一个周边服务可以有多个特征
    CBMutableService * customService = [[CBMutableService alloc] initWithType:serviceUUID
                                                                      primary:YES];
    // Sets the characteristics for this service
    [customService setCharacteristics:
     @[_customCharacteristic,write]];
    // Publishes the service
    [_postManager addService:customService];
    
//    //characteristics字段描述
//    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
//    /*
//     可以通知的Characteristic
//     properties：CBCharacteristicPropertyNotify
//     permissions CBAttributePermissionsReadable
//     */
//    CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"48022E37-CED8-4EC7-9F67-6B980A6B8DE2"] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
//    /*
//     可读写的characteristics
//     properties：CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead
//     permissions CBAttributePermissionsReadable | CBAttributePermissionsWriteable
//     */
//    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"0E2D6134-B5B1-475C-B9EB-9EA2E3202698"] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
//    //设置description
//    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
//    [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
//    /*
//     只读的Characteristic
//     properties：CBCharacteristicPropertyRead
//     permissions CBAttributePermissionsReadable
//     */
//    CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"18C5B0FC-422C-4BE0-BB8D-3E40E31C556B"] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
//    //service1初始化并加入两个characteristics
//    CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:@"E182EA6A-7E93-43F5-8D41-4680C35AE684"] primary:YES];
//    [service1 setCharacteristics:@[notiyCharacteristic,readwriteCharacteristic]];
//    //service2初始化并加入一个characteristics
//    CBMutableService *service2 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:@"F96C1E2A-5B6C-47DF-9C51-3DD7287C683E"] primary:YES];
//    [service2 setCharacteristics:@[readCharacteristic]];
//    //添加后就会调用代理的- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
//    [_postManager addService:service1];
//    [_postManager addService:service2];
    
    
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"外设状态%ld",(long)peripheral.state);
    if(peripheral.state==5){
        [self customePost];
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *, id> *)dict
{
    
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error
{
    if(error){
        NSLog(@"外设advertising失败%@",error.description);
    }else{
        NSLog(@"外设成功");
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error
{
    if(!error){
        NSString *name=[[GetInfo getIphoneInfo] objectForKey:@"所有者"];
          [_postManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:@"48022E37-CED8-4EC7-9F67-6B980A6B8DE2"]],CBAdvertisementDataLocalNameKey:name}];
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests
{
    for (CBATTRequest*request in requests) {
        NSLog(@"%@",request.value);
        NSString *str=[[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
        NSLog(@"收到数据:%@",str);
    }
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    
}
#pragma mark - 发送post
#pragma mark - get 解析
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices{
    
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    if (error)
    {
        NSLog(@"解析设备失败%@",error);
        return;
    }
    for (CBService*service in peripheral.services) {
        if([[service UUID].UUIDString isEqualToString:@"48022E37-CED8-4EC7-9F67-6B980A6B8DE2"]){
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error
{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    for (CBCharacteristic *character in service.characteristics) {
        NSLog(@"%@",character.UUID.UUIDString);
        if([character.UUID.UUIDString isEqualToString:@"E182EA6A-7E93-43F5-8D41-4680C35AE684"]){
            _writeCharact=character;
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if(error){
        NSLog(@"%lu",(unsigned long)characteristic.properties);
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    
}

-(void)allowConnect:(NSString *)UUID
{
    _isShow=NO;
    [_getManager connectPeripheral:_currentPerinal options:nil];
}
-(void)NotConnect:(NSString *)UUID
{
    _isShow=NO;
    if(!_notAllowArray){
        _notAllowArray=[[NSMutableArray alloc] init];
    }
    [_notAllowArray addObject:UUID];
}
#pragma mark - 发送
-(void)postSomeThing:(NSData *)data
{
     [_currentPerinal writeValue:data forCharacteristic:_writeCharact type:CBCharacteristicWriteWithResponse];
}
@end
