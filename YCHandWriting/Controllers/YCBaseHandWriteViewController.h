//
//  YCBaseHandWriteViewController.h
//  YCHandWriting
//
//  Created by mac on 2017/8/2.
//  Copyright © 2017年 HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCHandWriteView.h"

@interface YCBaseHandWriteViewController :UIViewController<YCHandWriteViewDelegate>

/**
 保存手写图片
 */
@property (nonatomic, strong) UIImage *saveImage;
/**
 保存手写视图
 */
@property (nonatomic, strong) UIView *saveView;
/**
 手写视图
 */
@property (strong,nonatomic) YCHandWriteView *handWriteView;
@end
