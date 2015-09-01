//
//  ZSCPicShowView.h
//  ZSC图片放大
//
//  Created by ZSC on 15/5/8.
//  Copyright (c) 2015年 ZSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicInfo.h"

@interface ZSCPicShowView : UIView

//多张图片
//marr:保存图片模型的数组
//index:当前点击的图片
- (void)createUIWithPicInfoArr:(NSMutableArray *)marr andIndex:(NSInteger)index;

@end
