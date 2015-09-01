//
//  ViewController.m
//  Demo1
//
//  Created by ZSC on 15/5/12.
//  Copyright (c) 2015年 ZSC. All rights reserved.
//

#import "ViewController.h"
#import "TestInfo.h"
#import "TestTableViewCell.h"

//适配时放缩比例
#define SCALE ([UIScreen mainScreen].bounds.size.width/320.0)
//屏幕宽高
#define  SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define  SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataArr;   //题目数据
}

@property (nonatomic,strong) UITableView *testTableView;
@property (nonatomic,strong) UIImageView *navImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self getData];
    [self createNav];
    [self createMyTableView];
}

- (void)getData
{
    
    _dataArr = [[NSMutableArray alloc]init];
   // NSArray *arr = @[@"1.png",@"2.png",@"3.png",@"4.png",@"5.png",@"6.png",@"7.png",@"2.png",@"3.png"];
   // http://api.map.baidu.com/images/weather/night/yin.png
    NSArray *arr = @[@"http://www.sinaimg.cn/dy/slidenews/4_img/2015_11/704_1575572_721187.jpg",@"http://img0.bdstatic.com/img/image/6446027056db8afa73b23eaf953dadde1410240902.jpg",@"http://a.hiphotos.baidu.com/image/w%3D310/sign=1b3032f459afa40f3cc6c8dc9b66038c/060828381f30e924d05919f74f086e061c95f773.jpg",@"http://g.hiphotos.baidu.com/image/w%3D310/sign=c4e6670a67d0f703e6b293dd38fb5148/359b033b5bb5c9ea5b3b32fed039b6003bf3b3e6.jpg",@"http://e.hiphotos.baidu.com/image/w%3D310/sign=3f5c37f7a28b87d65042ad1e37092860/08f790529822720e80b3673c78cb0a46f31fabf3.jpg",@"http://e.hiphotos.baidu.com/image/w%3D310/sign=144a1a1dec24b899de3c7f395e071d59/0b46f21fbe096b63ca566e4d09338744ebf8ac5b.jpg",@"http://a.hiphotos.baidu.com/image/w%3D310/sign=7853e91baac379317d688028dbc5b784/1c950a7b02087bf40a727cf4f7d3572c11dfcf14.jpg",@"http://g.hiphotos.baidu.com/image/w%3D310/sign=742cafe00fd162d985ee641d21dfa950/1b4c510fd9f9d72a167df139d12a2834349bbbfd.jpg",@"http://a.hiphotos.baidu.com/image/w%3D310/sign=d65bc1d7f81f4134e037037f151f95c1/b7fd5266d0160924db5dfe2fd10735fae6cd348d.jpg"];
    
    
    for (int i = 0; i<9; i++) {
        NSMutableArray *marr = [[NSMutableArray alloc]init];
        for (int j=0; j<=i; j++) {
            [marr addObject:arr[j]];
        }
        TestInfo *info = [[TestInfo alloc]init];
        info.picArr = marr;
        info.topText = @"JPEGmini 是Mac上一款界面简洁、操作简洁、功能强大的JPG图片压缩软件。只需把要压缩的 JPG图片拖拽到 JPEGmini 软件窗口，就能在不影响画质和像素尺寸的情况下，大幅压缩图片的体积。";
        info.bottomText = @"唐朝著名学者陆羽，从小是个孤儿，被智积禅师抚养长大。陆羽虽身在庙中，却不愿终日诵经念佛，而是喜欢吟读诗书。陆羽执意下山求学，遭到了禅师的反对。禅师为了给陆羽出难题，同时也是为了更好地教育他，便叫他学习冲茶。在钻研茶艺的过程中，陆羽碰到了一位好心的老婆婆，不仅学会了复杂的冲茶的技巧，更学会了不少读书和做人的道理。当陆羽最终将一杯热气腾腾的苦丁茶端到禅师面前时，禅师终于答应了他下山读书的要求。后来，陆羽撰写了广为流传的《茶经》，把祖国的茶艺文化发扬光大！ ";
        [_dataArr addObject:info];
    }
    [self.testTableView reloadData];

}


- (void)createNav
{
    _navImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20*SCALE, SCREEN_WIDTH, 44*SCALE)];
    _navImageView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_navImageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200*SCALE, 44*SCALE)];
    label.center = _navImageView.center;
    label.text = @"论坛";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:label];
}

- (void)createMyTableView
{
    _testTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64*SCALE, SCREEN_WIDTH, SCREEN_HEIGHT-64*SCALE) style:UITableViewStylePlain];
    //_testTableView.backgroundColor = [UIColor redColor];
    _testTableView.delegate = self;
    _testTableView.dataSource = self;
    //_testTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_testTableView];
}

#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestInfo *info = _dataArr[indexPath.row];

    CGFloat t_h = [self getTextHight:info.topText andWidth:SCREEN_WIDTH-10*SCALE andTextFontOfSize:12];
    CGFloat b_h = [self getTextHight:info.isSelected?info.bottomText:@"text" andWidth:SCREEN_WIDTH-10*SCALE andTextFontOfSize:12];
    
    if (info.picArr.count<=3) {
        return 60*SCALE+5*2*SCALE+t_h+b_h+30*SCALE;
    }else if (info.picArr.count>3&&info.picArr.count<=6){
        return 60*SCALE*2+5*3*SCALE+t_h+b_h+30*SCALE;
    }else{
        return 60*SCALE*3+5*4*SCALE+t_h+b_h+30*SCALE;
    }
}

//获取字符串高度
- (CGFloat)getTextHight:(NSString *)textStr andWidth:(CGFloat)width andTextFontOfSize:(NSInteger)fontOfSize
{
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontOfSize]};
    CGSize size = [textStr boundingRectWithSize:CGSizeMake(width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    TestInfo *info = _dataArr[indexPath.row];
  
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        //单元格复用cellID要一致
        cell = [[TestTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        
        cell.delegate = self;
        
        cell.showBtnBlocks = ^{
            [self.testTableView reloadData];
        };
    }
    //cell点击效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //传递数据模型info
    [cell setCellDataWithTestInfo:info];
    
    return cell;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
