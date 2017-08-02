//
//  ViewController.m
//  YCHandWriting
//
//  Created by mac on 2017/8/2.
//  Copyright © 2017年 HYC. All rights reserved.
//

#import "ViewController.h"
#import "YCBaseHandWriteViewController.h"
#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *testBtn = [[UIButton alloc] init];
    testBtn.backgroundColor = [UIColor orangeColor];
    [testBtn setTitle:@"测试一下" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(didClickedTestAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:testBtn];
    
    [testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
}

#pragma mark - Action
- (void)didClickedTestAction:(id)sender{
    YCBaseHandWriteViewController *testVC = [[YCBaseHandWriteViewController alloc] init];
    [self.navigationController pushViewController:testVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
