//
//  ZSCPicShowView.m
//  ZSC图片放大
//
//  Created by ZSC on 15/5/8.
//  Copyright (c) 2015年 ZSC. All rights reserved.
//

#import "ZSCPicShowView.h"
#import "UIImageView+WebCache.h"
#import "VIPhotoView.h"

//屏幕宽高
#define  kWidth   [UIScreen mainScreen].bounds.size.width
#define  kHeight  [UIScreen mainScreen].bounds.size.height

#define kPicTag 1000
#define kSubScrTag 2000
#define kViewTag 3000

@interface UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size;

@end

@implementation UIImage (VIUtil)

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = CGSizeMake(self.size.width / self.scale,
                                  self.size.height / self.scale);
    
    CGFloat widthRatio = imageSize.width / size.width;
    CGFloat heightRatio = imageSize.height / size.height;
    
    if (widthRatio > heightRatio) {
        imageSize = CGSizeMake(imageSize.width / widthRatio, imageSize.height / widthRatio);
    } else {
        imageSize = CGSizeMake(imageSize.width / heightRatio, imageSize.height / heightRatio);
    }
    
    return imageSize;
}

@end

@interface UIImageView (VIUtil)

- (CGSize)contentSize;

@end

@implementation UIImageView (VIUtil)

- (CGSize)contentSize
{
    return [self.image sizeThatFits:self.bounds.size];
}

@end

@interface ZSCPicShowView ()<UIScrollViewDelegate,UIAlertViewDelegate>
{
    UIWindow *_window;
    NSMutableArray *_picInfoArr; //保存图片模型数组
    BOOL doubleClick;
    UIImage *saveImg;
    NSInteger currentPage;   //当前页数
}

@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIButton *backBtn;   //返回
@property (nonatomic,strong) UIButton *shareBtn;  //分享

@end

@implementation ZSCPicShowView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

//多张图片
- (void)createUIWithPicInfoArr:(NSMutableArray *)marr andIndex:(NSInteger)index
{
    //获取当前显示的窗口
    _window = [UIApplication sharedApplication].keyWindow;
   
    //保存图片模型数组为全局的
    _picInfoArr = marr;
    
    //创建主滚动视图
    [self createMainScrollView];
    
    //创建主滚动视图内容
    [self createMainScrollViewContent];
    
    //根据index判断当前显示第几张图 通过设置主滚动视图偏移量得到
    [self.mainScrollView setContentOffset:CGPointMake(kWidth*index, 0) animated:NO];
    
    currentPage = index;
    
    //把当前显示的图片位置设为原始frame 再通过动画展示出来
    [self createAnimationShowPicWithIndex:index];
    
    [self createBackBtn];
    [self createShareBtn];
}

- (void)createBackBtn
{
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(kWidth-60, 80, 40, 40);
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchDown];
    [_window addSubview:_backBtn];
}

- (void)backBtnClick:(UIButton *)button
{
    //获取第几张图片点击
    PicInfo *info = _picInfoArr[currentPage];
    UIImageView *imageView = (UIImageView *)[self.mainScrollView viewWithTag:kPicTag+currentPage];
    
    imageView.hidden = YES;
    __block UIImageView *tempImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    [tempImageView sd_setImageWithURL:[NSURL URLWithString:info.picUrlStr] placeholderImage:[UIImage imageNamed:@"zhanwei.png"] options:SDWebImageRetryFailed];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_window addSubview:tempImageView];
    
    [UIView animateWithDuration:0.6 animations:^{
        tempImageView.frame=info.picOldFrame;
        self.mainScrollView.alpha=1;
        _backBtn.alpha = 0;
        _shareBtn.alpha = 0;
    } completion:^(BOOL finished) {
        [_backBtn removeFromSuperview];
        [self.mainScrollView removeFromSuperview];
        [tempImageView removeFromSuperview];
        tempImageView = nil;
        self.mainScrollView = nil;
        _backBtn = nil;
        _shareBtn = nil;
    }];
}

- (void)createShareBtn
{
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareBtn.frame = CGRectMake(kWidth-60, kHeight-100, 40, 40);
    [_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchDown];
    [_window addSubview:_shareBtn];
}

- (void)shareBtnClick:(UIButton *)button
{
    NSLog(@"分享");
}

#pragma mark - 创建主滚动视图
- (void)createMainScrollView
{
    self.mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width+10, [UIScreen mainScreen].bounds.size.height)];
    self.mainScrollView.contentSize = CGSizeMake(kWidth*_picInfoArr.count+10*(_picInfoArr.count),kHeight);
    self.mainScrollView.bounces = YES;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.delegate = self;
    self.mainScrollView.minimumZoomScale = 1.0;
    self.mainScrollView.maximumZoomScale = 2.0;
    self.mainScrollView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
    self.mainScrollView.alpha=0;
    [_window addSubview:self.mainScrollView];
}

#pragma mark - 创建主滚动视图内容
- (void)createMainScrollViewContent
{
     doubleClick = YES;
    
    for (int i=0; i<_picInfoArr.count; i++) {
        UIScrollView *subScr = [[UIScrollView alloc]initWithFrame:CGRectMake((kWidth+10)*i, 0, kWidth, kHeight)];
        subScr.contentSize = CGSizeMake(kWidth,kHeight);
        //subScr.bounces = YES;
        //subScr.pagingEnabled = YES; 子滚动视图不能开启分页否则会晃动
        subScr.showsHorizontalScrollIndicator = YES;
        subScr.showsVerticalScrollIndicator = YES;
        subScr.delegate = self;
        subScr.minimumZoomScale = 1.0;
        subScr.maximumZoomScale = 2.0;
        subScr.tag = kSubScrTag+i;
        [self.mainScrollView addSubview:subScr];
        
//        UIView *containerView = [[UIView alloc] initWithFrame:subScr.bounds];
//        containerView.tag = kViewTag + i;
//        containerView.backgroundColor = [UIColor clearColor];
//        [subScr addSubview:containerView];
        
        
        
        PicInfo *info = _picInfoArr[i];
        
        
        UIImageView *picImageView = [[UIImageView alloc]initWithFrame:subScr.bounds];
        picImageView.tag = kPicTag+i;
        picImageView.userInteractionEnabled = YES;
        
        //使用默认图片，而且用block 在完成后做一些事情
        [picImageView sd_setImageWithURL:[NSURL URLWithString:info.picUrlStr] placeholderImage:[UIImage imageNamed:@"zhanwei.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            CGSize imageSize = picImageView.contentSize;
            if (imageSize.width == kWidth) {
                picImageView.frame = CGRectMake(0, (kHeight-imageSize.height)/2.0, imageSize.width, imageSize.height);
            }else{
                picImageView.frame = CGRectMake((kWidth-imageSize.width)/2.0, 0, imageSize.width, imageSize.height);
            }
        }];
        
//        [picImageView sd_setImageWithURL:[NSURL URLWithString:info.picUrlStr] placeholderImage:[UIImage imageNamed:@"zhanwei.png"] options:SDWebImageRetryFailed];
        
        picImageView.contentMode = UIViewContentModeScaleAspectFit;
        [subScr addSubview:picImageView];
        
        UITapGestureRecognizer *oneTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
        oneTap.numberOfTouchesRequired = 1;
        oneTap.numberOfTapsRequired = 1;
        [subScr addGestureRecognizer:oneTap];
        
        UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapBig:)];
        doubleTap.numberOfTapsRequired = 2;
        [picImageView addGestureRecognizer:doubleTap];
        //[A requireGestureRecognizerToFail:B]函数,它可以指定当A手势发生时,即便A已经滿足条件了,也不会立刻触发,会等到指定的手势B确定失败之后才触发。
        [oneTap requireGestureRecognizerToFail:doubleTap];
        
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesDeal:)];
        [subScr addGestureRecognizer:longGes];

    }

}

- (void)longGesDeal:(UILongPressGestureRecognizer *)longGes
{
    if (longGes.state ==UIGestureRecognizerStateBegan) {
        UIImageView *imageView = (UIImageView *)[self.mainScrollView viewWithTag:longGes.view.tag-1000];
        saveImg = imageView.image;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否保存到相册" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
    }else if (buttonIndex == 1){
        UIImageWriteToSavedPhotosAlbum(saveImg, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    if (error) {
        NSLog(@"失败");
    }else {
        NSLog(@"成功");
    }
}


#pragma mark - 把第一次进入的当前显示图片位置设为原始frame 再通过动画展示出来
- (void)createAnimationShowPicWithIndex:(NSInteger)index
{
    //取出当前显示的图片
    PicInfo *info = _picInfoArr[index];
    //原始frame
    CGRect oldframe = info.picOldFrame;
    UIImageView *currentShowPic = (UIImageView *)[self.mainScrollView viewWithTag:kPicTag+index];
    currentShowPic.frame = oldframe;
    currentShowPic.contentMode = UIViewContentModeScaleAspectFit;
    
    self.mainScrollView.alpha=1;
    self.mainScrollView.contentOffset = CGPointMake(index*(kWidth+10), 0);
    [UIView animateWithDuration:0.6 animations:^{
        currentShowPic.frame = CGRectMake(0, 0, kWidth, kHeight);
    } completion:^(BOOL finished) {
        CGSize imageSize = currentShowPic.contentSize;
        if (imageSize.width == kWidth) {
            currentShowPic.frame = CGRectMake(0, (kHeight-imageSize.height)/2.0, imageSize.width, imageSize.height);
        }else{
            currentShowPic.frame = CGRectMake((kWidth-imageSize.width)/2.0, 0, imageSize.width, imageSize.height);
        }

    }];
}

#pragma mark - 图片点击隐藏还原回原来位置
-(void)hideImage:(UITapGestureRecognizer*)tap{
    //获取第几张图片点击
    PicInfo *info = _picInfoArr[tap.view.tag-2000];
    UIImageView *imageView = (UIImageView *)[self.mainScrollView viewWithTag:tap.view.tag-1000];
    
    imageView.hidden = YES;
    __block UIImageView *tempImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    [tempImageView sd_setImageWithURL:[NSURL URLWithString:info.picUrlStr] placeholderImage:[UIImage imageNamed:@"zhanwei.png"] options:SDWebImageRetryFailed];
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_window addSubview:tempImageView];
    
    [UIView animateWithDuration:0.6 animations:^{
        tempImageView.frame=info.picOldFrame;
        self.mainScrollView.alpha=1;
        _backBtn.alpha = 0;
        _shareBtn.alpha = 0;
    } completion:^(BOOL finished) {
        [_backBtn removeFromSuperview];
        [self.mainScrollView removeFromSuperview];
        [tempImageView removeFromSuperview];
        tempImageView = nil;
        self.mainScrollView = nil;
        _backBtn = nil;
        _shareBtn = nil;
    }];
}

#pragma mark - 双击放大
- (void)doubleTapBig:(UITapGestureRecognizer *)tap
{
    CGFloat newscale = 1.9;
    UIScrollView *currentScrollView = (UIScrollView *)[self.mainScrollView viewWithTag:tap.view.tag+1000];
    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[tap locationInView:tap.view] andScrollView:currentScrollView];
    
    if (doubleClick == YES)  {
        [currentScrollView zoomToRect:zoomRect animated:YES];
    }
    else {
        [currentScrollView zoomToRect:currentScrollView.frame animated:YES];
    }
    doubleClick = !doubleClick;
}

- (CGRect)zoomRectForScale:(CGFloat)newscale withCenter:(CGPoint)center andScrollView:(UIScrollView *)scrollV{
    
    CGRect zoomRect = CGRectZero;
    
    zoomRect.size.height = scrollV.frame.size.height / newscale;
    zoomRect.size.width = scrollV.frame.size.width  / newscale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIImageView *imageView = (UIImageView *)[self.mainScrollView viewWithTag:scrollView.tag-1000];
    return imageView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = self.mainScrollView.contentOffset;
    NSInteger page = offset.x / kWidth ;
    
    currentPage = page;
    
    if (page != 0) {
        UIScrollView *scrollV_next = (UIScrollView *)[self.mainScrollView viewWithTag:page+kSubScrTag - 1]; //前一页
        if (scrollV_next.zoomScale != 1.0){
            
            scrollV_next.zoomScale = 1.0;
        }

    }
    if (page != _picInfoArr.count) {
        UIScrollView *scollV_pre = (UIScrollView *)[self.mainScrollView viewWithTag:page+kSubScrTag+1]; //后一页
        if (scollV_pre.zoomScale != 1.0){
            scollV_pre.zoomScale = 1.0;
        }
    }
    
    if (page == 0 ) {
        UIScrollView *scollV_pre = (UIScrollView *)[self.mainScrollView viewWithTag:page+kSubScrTag+1]; //后一页
        if (scollV_pre.zoomScale != 1.0){
            scollV_pre.zoomScale = 1.0;
        }
    }
    
    if (page == _picInfoArr.count) {
        UIScrollView *scrollV_next = (UIScrollView *)[self.mainScrollView viewWithTag:page+kSubScrTag - 1]; //前一页
        if (scrollV_next.zoomScale != 1.0){
            
            scrollV_next.zoomScale = 1.0;
        }
    }
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIImageView *imageView = (UIImageView *)[scrollView viewWithTag:scrollView.tag - 1000];
    CGSize contentSize = scrollView.contentSize;
    CGPoint centerPoint = CGPointMake(contentSize.width / 2, contentSize.height / 2);
    
    // 水平居中
    if (imageView.frame.size.width <= scrollView.frame.size.width) {
        centerPoint.x = scrollView.frame.size.width / 2;
    }
    // 垂直居中
    if (imageView.frame.size.height <= scrollView.frame.size.height) {
        centerPoint.y = scrollView.frame.size.height / 2;
    }
    imageView.center = centerPoint;
}



@end
