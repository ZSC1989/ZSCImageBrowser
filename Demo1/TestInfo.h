//
//  TestInfo.h
//  图片九宫格
//
//  Created by ZSC on 15/5/5.
//  Copyright (c) 2015年 ZSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestInfo : NSObject

@property (nonatomic,copy)NSString *topText;
@property (nonatomic,copy)NSString *bottomText;
@property (nonatomic,strong) NSMutableArray *picArr;
@property (nonatomic,assign) BOOL isSelected;



@end
