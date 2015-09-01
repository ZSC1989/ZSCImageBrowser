//
//  ZSCLabel.h
//  111
//
//  Created by ZSC on 15/5/29.
//  Copyright (c) 2015年 ZSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZSCLabel : NSObject

//设置两端(左右)对齐 和首行缩进
+ (void)setZSCNSTextAlignmentJustifiedWithLabel:(UILabel *)label andFirstLineHeadIndent:(CGFloat)width;

//获取字符串宽度
+(CGFloat)getZSCTextWidth:(NSString *)textStr andHeight:(CGFloat)height andTextFontSize:(NSInteger)fontSize;

//获取字符串高度
+ (CGFloat)getZSCTextHight:(NSString *)textStr andWidth:(CGFloat)width andTextFontSize:(NSInteger)fontSize;

//设置删除线
+ (void)setZSCStrickoutWithLabel:(UILabel *)label andTextFontSize:(NSInteger)fontSize andColor:(UIColor *)color andRange:(NSRange)range;

//设置下划线
+ (void)setZSCUnderlineWithLabel:(UILabel *)label andTextFontSize:(NSInteger)fontSize andColor:(UIColor *)color andRange:(NSRange)range;

//设置字体大小和颜色
+ (void)setZSCLabelFontAndColorWithLabel:(UILabel *)label andTextFontSize:(NSInteger)fontSize andColor:(UIColor *)color andRange:(NSRange)range;

@end
