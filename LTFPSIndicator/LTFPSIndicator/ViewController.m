//
//  ViewController.m
//  LTFPSIndicator
//
//  Created by 李腾 on 2017/7/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import "ViewController.h"
#import "LTFPSIndicatorMonitor.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController
{
    BOOL isShowIndicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"LTFPSIndicator";
    isShowIndicator = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    
    
    [self initTableView];
    
}

- (void)rightItemClick
{
    if (isShowIndicator) {
        [[LTFPSIndicatorMonitor sharedInstance] stopMonitoring];
        self.navigationItem.rightBarButtonItem.title = @"打开";
    }else{
        [[LTFPSIndicatorMonitor sharedInstance] startMonitoring];
        self.navigationItem.rightBarButtonItem.title = @"关闭";
    }
    isShowIndicator = !isShowIndicator;
}

- (void)initTableView{
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
}

#pragma mark - ************* tableview  delegate && dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1000;
}

static NSString* identifier = @"UITableViewCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"美女2"];
    cell.textLabel.text = [NSString stringWithFormat:@"LOL~~~~~~%ld",(long)indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
