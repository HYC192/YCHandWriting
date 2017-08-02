//
//  YCHandWriteView.h
//  YCHandWriting
//
//  Created by mac on 2017/8/2.
//  Copyright © 2017年 HYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YCHandWriteViewDelegate <NSObject>

@optional
- (void)getHandWiteImageView:(UIImage*)image;
@end

@interface YCHandWriteView : UIView

@property (nonatomic, assign) CGFloat min;
@property (nonatomic, assign) CGFloat max;
@property (nonatomic, assign) CGRect originRect;
@property (nonatomic, assign) CGFloat origionX;
@property (nonatomic, assign) CGFloat totalWidth;

@property (nonatomic, getter=isSure) BOOL sure;

/**
 手写完成的水印文字
 */
@property (strong,nonatomic) NSString *showMessage;

@property(nonatomic,assign)id<YCHandWriteViewDelegate> delegate;
- (void)clearMessage;
- (void)sureMessage;
@end
