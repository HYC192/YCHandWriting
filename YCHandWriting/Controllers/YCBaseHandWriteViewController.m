//
//  YCBaseHandWriteViewController.m
//  YCHandWriting
//
//  Created by mac on 2017/8/2.
//  Copyright © 2017年 HYC. All rights reserved.
//

#import "YCBaseHandWriteViewController.h"
#define kYCScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kYCScreenHeight [[UIScreen mainScreen] bounds].size.height
@interface YCBaseHandWriteViewController ()

@end

@implementation YCBaseHandWriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    self.handWriteView = [[YCHandWriteView alloc] initWithFrame:CGRectMake(0,64, kYCScreenWidth, 100)];
    self.handWriteView.backgroundColor = [UIColor whiteColor];
    self.handWriteView.delegate =self;
    self.handWriteView.showMessage =@"完成";
    [self.view addSubview:self.handWriteView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"重签"forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHue:72 saturation:106 brightness:123 alpha:0.7] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(20,self.handWriteView.frame.origin.y+120,130, 40)];
    button.layer.cornerRadius =5.0;
    button.clipsToBounds =YES;
    button.layer.borderWidth =1.0;
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.layer.borderColor = [[UIColor blackColor] CGColor];
    [button addTarget:self action:@selector(clear:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"确认"forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont systemFontOfSize:17];
    button2.backgroundColor = [UIColor blueColor];
    [button2 setFrame:CGRectMake(170,self.handWriteView.frame.origin.y+120,130, 40)];
    button2.layer.cornerRadius =5.0;
    button2.clipsToBounds =YES;
    [button2 addTarget:self action:@selector(add:)forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    _saveView = [[UIView alloc] initWithFrame:CGRectMake(10, button2.frame
                                                       .origin.y+60,300, 140)];
    _saveView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_saveView];
}

- (void)add:(UIButton *)sender
{
    [self.handWriteView sureMessage];
    
}

- (void)clear:(UIButton *)sender
{
    NSLog(@"重签");
    [self.handWriteView clearMessage];
    for(UIView *view in self.saveView.subviews)
    {
        [view removeFromSuperview];
    }
}

- (void)getHandWiteImageView:(UIImage*)image
{
    if(image)
    {
        NSLog(@"haveImage");
        
        UIImageView *image1 = [[UIImageView alloc] initWithImage:image];
        image1.frame =CGRectMake((self.saveView.frame.size.width-image.size.width)/2, (self.saveView.frame.size.height-image.size.height)/2, image.size.width, image.size.height) ;
        [self.saveView addSubview:image1];
        
        self.saveImage = image;
        [self saveImage:self.saveImage];
        //[self makeUpLoad];
        
    }
    else
    {
        NSLog(@"NoImage");
        
    }
    
}

//图片保存到本地
- (void)saveImage:(UIImage *)image
{
    //设置图片名
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *dateStr = [NSString stringWithFormat:@"%@.png",currentDateStr];
    
    
    NSString *path = [NSTemporaryDirectory()stringByAppendingFormat:@"%@",dateStr];
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil];
    if ( existed  )
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    NSData *imgData = UIImageJPEGRepresentation(image, 1);
    [imgData writeToFile:path atomically:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
