//
//  TestTableViewCell.m
//  图片九宫格
//
//  Created by ZSC on 15/5/5.
//  Copyright (c) 2015年 ZSC. All rights reserved.
//

#import "TestTableViewCell.h"
#import "TestInfo.h"
#import "MyControl.h"
#import "UIImageView+WebCache.h"
#import "ZSCPicShowView.h"
#import "ZSCLabel.h"
#import "PicInfo.h"

#define kPicTag 100

@interface TestTableViewCell ()
{
    UIWindow *_window;
    NSMutableArray *_picInfoArr;
}


@property (nonatomic,strong)ZSCPicShowView *zscShowView;
@property (nonatomic,strong)TestInfo *info;
@property (nonatomic,strong)UILabel *topLabel;
@property (nonatomic,strong)UIView *midView;
@property (nonatomic,strong)UILabel *bottomLabel;
@property (nonatomic,strong)UIButton *showBtn;

@end

@implementation TestTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self createUI];
    }
    return self;
}
- (void)createUI
{
    
    _picInfoArr = [[NSMutableArray alloc]init];
    _window = [UIApplication sharedApplication].keyWindow; //获取当前显示的窗口
    
    [self createTopContent];
    [self createMidView];
    [self createBottomView];
}

- (void)createMidView
{
    self.midView = [[UIView alloc]initWithFrame:CGRectMake(0, _topLabel.frame.size.height, SCREEN_WIDTH, 0)];
    //self.midView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.midView];
    
    CGFloat x = 10*SCALE;
    CGFloat y = 5*SCALE;
    CGFloat w = 60*SCALE;
    CGFloat h = 60*SCALE;
    for (int i = 0; i<9; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
        imageView.tag = kPicTag+i;
        imageView.hidden = YES;
        imageView.userInteractionEnabled = YES;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 5*SCALE;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.midView addSubview:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealTap:)];
        [imageView addGestureRecognizer:tap];
        
        //改变坐标
        if (i%3 != 2) {
            x = x + w+5*SCALE;
        }
        else //换行
        {
            x=10*SCALE;
            y = y +h+5*SCALE;
        }
    }
}

- (void)dealTap:(UITapGestureRecognizer *)tap
{
    //NSLog(@"第%ld张图片被点击",tap.view.tag-kPicTag);
    
    //为图片模型数组保存frame
    for (int i=0; i<_picInfoArr.count; i++) {
        UIImageView *imageView = (UIImageView *)[self.midView viewWithTag:kPicTag+i];
        PicInfo *info = _picInfoArr[i];
        info.picOldFrame=[imageView convertRect:imageView.bounds toView:_window];
    }
    
    _zscShowView = [[ZSCPicShowView alloc]init];
    [_zscShowView createUIWithPicInfoArr:_picInfoArr andIndex:tap.view.tag-kPicTag];
}

- (void)createBottomView
{
    _bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(5*SCALE, _topLabel.frame.size.height+_midView.frame.size.height, SCREEN_WIDTH-10*SCALE, 0)];
    _bottomLabel.textColor = [UIColor brownColor];
    _bottomLabel.textAlignment = NSTextAlignmentLeft;
    _bottomLabel.numberOfLines = 0;
    _bottomLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_bottomLabel];
    
    _showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_showBtn setTitle:@"全部展开" forState:UIControlStateNormal];
    [_showBtn setTitle:@"全部收起" forState:UIControlStateSelected];
    _showBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_showBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_showBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:_showBtn];
}

- (void)btnClick:(UIButton *)button
{
    button.selected = !button.selected;
    _info.isSelected = button.selected;
    _showBtnBlocks();
}

- (void)createTopContent
{
    _topLabel = [[UILabel alloc]initWithFrame:CGRectMake(5*SCALE, 0, SCREEN_WIDTH-10*SCALE, 60*SCALE)];
    _topLabel.textColor = [UIColor blackColor];
    _topLabel.textColor = [UIColor purpleColor];
    _topLabel.textAlignment = NSTextAlignmentLeft;
    _topLabel.numberOfLines = 0;
    _topLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_topLabel];
}

#pragma mark - 设置info数据模型的数据
- (void)setCellDataWithTestInfo:(TestInfo *)info
{
    self.info = info;
    [self resetSubViews];
    [self setSubViews];
}

#pragma mark - 清空以前的数据
- (void)resetSubViews
{
    //清空图片信息(如frame)数组
    [_picInfoArr removeAllObjects];
    
    for (int i=0; i<9; i++) {
        UIImageView *imageView = (UIImageView *)[self.midView viewWithTag:kPicTag+i];
        imageView.hidden = YES;
    }
    
    _showBtn.selected = NO;
}

#pragma mark - 设置现在的数据
- (void)setSubViews
{
    _topLabel.text = _info.topText;
    //设置两端对齐
    [ZSCLabel setZSCNSTextAlignmentJustifiedWithLabel:_topLabel andFirstLineHeadIndent:25];
    CGFloat top_H = [self setTextHight:_topLabel andTextStr:_topLabel.text andTextFontOfSize:12];
    
    for (int i=0; i<_info.picArr.count; i++) {
        UIImageView *imageView = (UIImageView *)[self.midView viewWithTag:kPicTag+i];
        imageView.hidden = NO;
        //使用默认图片，而且用block 在完成后做一些事情
//        [imageView sd_setImageWithURL:[NSURL URLWithString:_info.picArr[i]] placeholderImage:[UIImage imageNamed:@"zhanwei.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            
//            //NSLog(@"图片加载完成后做的事情");
//            
//        }];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:_info.picArr[i]] placeholderImage:[UIImage imageNamed:@"zhanwei.png"] options:SDWebImageRetryFailed];
        
        PicInfo *info = [[PicInfo alloc]init];
        info.picUrlStr = _info.picArr[i];
        [_picInfoArr addObject:info];
    }
    
    CGFloat h;
    if (_info.picArr.count<=3) {
        h = 60*SCALE+5*2*SCALE;
    }else if (_info.picArr.count>3&&_info.picArr.count<=6){
        h = 60*SCALE*2+5*3*SCALE;
    }else{
        h = 60*SCALE*3+5*4*SCALE;
    }
    self.midView.frame = CGRectMake(0,top_H,SCREEN_WIDTH,h);
    
    //获取原始字符串
    NSString *newContentStr = nil;
    NSString *originalContentStr = _info.bottomText;
    if (originalContentStr.length>=20) {
        //NSMakeRange（4，2）    从第4个字符开端截取，长度为2个字符，（字符串都是从第0个字符开端数的哦～！）
        NSMutableString *tempStr = [[NSMutableString alloc]initWithString:[originalContentStr substringWithRange:NSMakeRange(0,19)]];
        [tempStr appendString:@"..."];//截取前7位,第8位拼接省略号
        newContentStr = [NSString stringWithFormat:@"%@",tempStr];
    }else{
        newContentStr = originalContentStr;
    }

    _bottomLabel.text = _info.isSelected?originalContentStr:newContentStr;
    //设置两端对齐
    [ZSCLabel setZSCNSTextAlignmentJustifiedWithLabel:_bottomLabel andFirstLineHeadIndent:25];
    CGFloat bottom_H = [self getTextHight:_bottomLabel.text andWidth:SCREEN_WIDTH-10*SCALE andTextFontOfSize:12];
    _bottomLabel.frame = CGRectMake(5*SCALE, top_H+h, SCREEN_WIDTH-10*SCALE, bottom_H);
    
    
    _showBtn.frame = CGRectMake(SCREEN_WIDTH-100*SCALE,top_H+h+bottom_H, 80*SCALE, 15*SCALE);
    _showBtn.selected = _info.isSelected;
    
}

//获取字符串高度
- (CGFloat)getTextHight:(NSString *)textStr andWidth:(CGFloat)width andTextFontOfSize:(NSInteger)fontOfSize
{
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontOfSize]};
    CGSize size = [textStr boundingRectWithSize:CGSizeMake(width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size.height;
}

//设置可变文本高度
- (CGFloat)setTextHight:(UIView *)view andTextStr:(NSString *)textStr andTextFontOfSize:(NSInteger)fontOfSize
{
    //高度可变文本
    CGRect textFrame = view.frame;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontOfSize]};
    CGSize size = [textStr boundingRectWithSize:CGSizeMake(view.frame.size.width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    textFrame.size.height = size.height+5;
    view.frame = textFrame;
    return textFrame.size.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
