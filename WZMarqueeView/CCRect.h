//
//  CCRect.h
//  MainProject
//
//  Created by cui on 16/11/18.
//  Copyright © 2016年 ZhongRuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define  WIDTH  [UIScreen mainScreen].bounds.size.width
#define  HEIGHT  [UIScreen mainScreen].bounds.size.height
#define CCRECT(x,y,width,height) [self returnWithCCrect:CGRectMake(x, y, width, height)]
@interface CCRect : NSObject
+(CGRect )returnWithCCrect:(CGRect)frame;
@end
