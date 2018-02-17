//
//  ViewController.m
//  StretchHeadView-Objc
//
//  Created by Liu Chuan on 2018/2/17.
//  Copyright © 2018年 LC. All rights reserved.
//

#import "ViewController.h"

#pragma mark - 宏定义
#define headerviewH     300
#define screenW         [[UIScreen mainScreen] bounds].size.width
#define screenH         [[UIScreen mainScreen] bounds].size.height
#define statusBarH      [UIApplication sharedApplication].statusBarFrame.size.height
#define navigationH     self.navigationController.navigationBar.frame.size.height;
#define CellID          @"cellID"
#define darkGreen       [UIColor colorWithHue:0.40 saturation:0.78 brightness:0.68 alpha:1.00]


@interface ViewController ()

#pragma mark - 视图属性
/**
 表格视图
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/**
 头部视图
 */
@property (retain, nonatomic) UIView* Headerview;
/**
 分割线
 */
@property (retain, nonatomic) UIView* lineView;
/**
 头部视图图片
 */
@property (retain, nonatomic) UIImageView* HeaderImage;

@end


@implementation ViewController


#pragma mark - 系统回调函数
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTableView];
    [self configHeaderView];
    
}
#pragma mark - 视图即将出现时, 调用
- (void)viewWillAppear:(BOOL)animated {
    
    //隐藏导航栏, 带动画
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - 设置状态栏风格
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - custom method
/**
 配置TableView
 */
- (void)configTableView {
    
    if (@available(iOS 11.0, *)) {  // iOS 11.0 及以后的版本
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {     // iOS 11.0 之前
        // iOS7以后, 导航控制器中ScrollView\tableView顶部会添加 64 的额外高度
        // 取消自动调整滚动视图间距
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 设置表格顶部间距, 使得HaderView不被遮挡
    self.tableView.contentInset = UIEdgeInsetsMake(headerviewH, 0, 0, 0);
    // 设置指示器的间距, 等于表格顶部的间距
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell self] forCellReuseIdentifier:CellID];
}


/**
 配置HaderView
 */
- (void)configHeaderView {
    
    _Headerview = [[UIView alloc] initWithFrame: CGRectMake(0, 0, screenW, headerviewH)];
    _Headerview.backgroundColor = darkGreen;
    
    // 初始化头部视图图片对象
    _HeaderImage = [[UIImageView alloc] initWithFrame: _Headerview.bounds];
    
    // 设置图像
    _HeaderImage.image = [UIImage imageNamed:@"Girl"];
    
    // 设置图像显示比例
    _HeaderImage.contentMode = UIViewContentModeScaleAspectFill;
    
    // 设置图像裁切
    _HeaderImage.clipsToBounds = YES;
    
    // 添加分割线: 1个像素点
    // 1个像素点 / 分辨率
    CGFloat lineH = 1 / UIScreen.mainScreen.scale;
    // 设置分割线
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, headerviewH - lineH, screenW, lineH)];
    _lineView.backgroundColor = [UIColor lightGrayColor];
    
    // 添加控件
    [_Headerview addSubview:_lineView];
    [_Headerview addSubview:_HeaderImage];
    [self.view addSubview:_Headerview];
}



#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath: indexPath];
    
    // 获取单元格的行
    NSInteger rowNo = [indexPath row];
    
    // 字符串拼接
    NSString *str = [NSString stringWithFormat:@"%ld", (long)rowNo];
    cell.textLabel.text = str;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
/*
     contentOffset: 即偏移量,contentOffset.y = 内容的顶部和frame顶部的差值,contentOffset.x = 内容的左边和frame左边的差值.
     contentInset:  即内边距,contentInset = 在内容周围增加的间距(粘着内容),contentInset的单位是UIEdgeInsets
*/
    // 偏移量: -300 + 顶部边距: 300, 等于0
    CGFloat offsetY = scrollView.contentOffset.y + scrollView.contentInset.top;
    //NSLog(@"%f", offsetY);
    
    if (offsetY <= 0) {         //MARK: 放大图像
        // 调整HeaderView\ HeaderImage
        // 1>. 用一个临时变量保存返回值。
        CGRect temp = self.Headerview.frame;
        
        // 2>. 给这个变量赋值
        temp.origin.y = 0;
        
        // 增大 Headerview 高度
        temp.size.height = headerviewH - offsetY;
        _Headerview.alpha = 1;
        
        // 3>. 修改frame的值
        self.Headerview.frame = temp;
        
        // 设置分割线的位置
        CGRect temp2 = self.lineView.frame;
        CGFloat lineFrame = _Headerview.frame.size.height - _lineView.frame.size.height;
        temp2.origin.y = lineFrame;
        self.lineView.frame = temp2;
        
        // 设置图像视图高度
        CGRect temp3 = self.HeaderImage.frame;
        temp3.size.height = _Headerview.frame.size.height;
        self.HeaderImage.frame = temp3;
        
    }else {                //MARK: 整体移动
        CGRect temp4 = self.Headerview.frame;
        temp4.size.height = headerviewH;
        temp4.origin.y = -offsetY;
       
        /// HeaderView最小的Y值
       // CGFloat headerViewMinY = headerviewH - navigationH - statusBarH;
        CGFloat headerViewMinY = headerviewH - navigationH;
        
        // min函数: 取最小值
        temp4.origin.y = -MIN(headerViewMinY, offsetY);
        
        self.Headerview.frame = temp4;
        
        // 设置透明度
        // 根据输出, 得知当 offsetY / headerViewMinY == 1时,不可见图像
        //NSLog(@"%f", offsetY / headerViewMinY);
        CGFloat progress = 1 - (offsetY / headerViewMinY);
        _HeaderImage.alpha = progress;
    }
}




@end
