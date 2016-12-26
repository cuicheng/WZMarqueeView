//
//  CCRect.m
//  MainProject
//
//  Created by cui on 16/11/18.
//  Copyright © 2016年 ZhongRuan. All rights reserved.
//

#import "CCRect.h"

@implementation CCRect
+(CGRect)returnWithCCrect:(CGRect)frame
{
    if(WIDTH==375){
        //6s
        return CGRectMake(frame.origin.x/2.0, frame.origin.y/2.0, frame.size.width/2.0, frame.size.height/2.0);
    }else if(WIDTH==320&&HEIGHT==568){
        //5s
        return CGRectMake(frame.origin.x/2*0.853333, frame.origin.y/2*0.853, frame.size.width/2*0.853333, frame.size.height/2*0.853);
    }else if(WIDTH==414){
        //plus
        return CGRectMake(frame.origin.x/2*1.104, frame.origin.y/2*1.11, frame.size.width/2*1.104, frame.size.height/2*1.11);
    }else if(WIDTH==320&&HEIGHT==480){
        //单独适配 变形严重
        return frame;
    }else{
        return frame;
    }

}
@end
