//
//  TestTableViewCell.h
//  图片九宫格
//
//  Created by ZSC on 15/5/5.
//  Copyright (c) 2015年 ZSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TestInfo;
@interface TestTableViewCell : UITableViewCell

@property (nonatomic,weak)id delegate;
//展示按钮回调
@property (nonatomic,copy)void(^showBtnBlocks)();

- (void)setCellDataWithTestInfo:(TestInfo *)info;

@end
