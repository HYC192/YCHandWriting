//
//  YCHandWriteView.m
//  YCHandWriting
//
//  Created by mac on 2017/8/2.
//  Copyright © 2017年 HYC. All rights reserved.
//

#import "YCHandWriteView.h"
#import <QuartzCore/QuartzCore.h>

#define StrWidth 150
#define StrHeight 20
#define  minDefaultWidth 128 //压缩图片,最长边为128
static CGPoint midpoint(CGPoint p0,CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) /2.0,
        (p0.y + p1.y) /2.0
    };
}

@interface YCHandWriteView ()
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, assign) CGPoint previousPoint;
@end
@implementation YCHandWriteView


#pragma mark ------------------- Privacy ----------------------
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    _path = [UIBezierPath bezierPath];
    [_path setLineWidth:2];
    
    _max = 0;
    _min = 0;
    
    // Capture touches
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = pan.minimumNumberOfTouches =1;
    [self addGestureRecognizer:pan];
    
}

-(void)clearPan
{
    _path = [UIBezierPath bezierPath];
    [_path setLineWidth:3];
    
    [self setNeedsDisplay];
}

void ProviderReleaseData (void *info,const void *data,size_t size)
{
    free((void*)data);
}


- (UIImage*) imageBlackToTransparent:(UIImage*) image
{
    // 分配内存
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i =0; i < pixelNum; i++, pCurPtr++)
    {
        //        if ((*pCurPtr & 0xFFFFFF00) == 0)    //将黑色变成透明
        if (*pCurPtr == 0xffffff)
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] =0;
        }
        
        //改成下面的代码，会将图片转成灰度
        /*uint8_t* ptr = (uint8_t*)pCurPtr;
         // gray = red * 0.11 + green * 0.59 + blue * 0.30
         uint8_t gray = ptr[3] * 0.11 + ptr[2] * 0.59 + ptr[1] * 0.30;
         ptr[3] = gray;
         ptr[2] = gray;
         ptr[1] = gray;*/
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight,ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8,32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // free(rgbImageBuf) 创建dataProvider时已提供释放函数，这里不用free
    
    return resultUIImage;
}


-(void)handelSingleTap:(UITapGestureRecognizer*)tap
{
    return [self imageRepresentation];
}

-(void) imageRepresentation {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO, [UIScreen mainScreen].scale);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    image = [self imageBlackToTransparent:image];
    
    NSLog(@"width:%f,height:%f",image.size.width,image.size.height);
    
    UIImage *img = [self cutImage:image];
    
    if ([_delegate respondsToSelector:@selector(getHandWiteImageView:)]) {
        [_delegate getHandWiteImageView:[self scaleToSize:img]];
    }
}

//压缩图片,最长边为128
- (UIImage *)scaleToSize:(UIImage *)img {
    CGRect rect ;
    CGFloat imageWidth = img.size.width;
    //判断图片宽度
    if(imageWidth >= minDefaultWidth)
    {
        rect = CGRectMake(0,0, minDefaultWidth, self.frame.size.height);
    }
    else
    {
        rect =CGRectMake(0,0, img.size.width,self.frame.size.height);
        
    }
    CGSize size = rect.size;
    UIGraphicsBeginImageContext(size);
    [img drawInRect:rect];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(scaledImage,nil, nil, nil);
    
    [self setNeedsDisplay];
    return scaledImage;
}

//只截取手写部分图片
- (UIImage *)cutImage:(UIImage *)image
{
    CGRect rect ;
    //事件没有发生
    if(_min == 0&&_max == 0)
    {
        rect =CGRectMake(0,0, 0, 0);
    }
    else//手写发生
    {
        rect =CGRectMake(_min-3,0, _max-_min+6,self.frame.size.height);
    }
    CGImageRef imageRef =CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage * img = [UIImage imageWithCGImage:imageRef];
    
    UIImage *lastImage = [self addText:img text:self.showMessage];
    
    [self setNeedsDisplay];
    return lastImage;
}

//手写完成
- (UIImage *) addText:(UIImage *)img text:(NSString *)mark {
    int w = img.size.width;
    int h = img.size.height;
    
    //根据截取图片大小改变文字大小
    CGFloat size = 20;
    UIFont *textFont = [UIFont systemFontOfSize:size];
    CGRect sizeOfTxt = [mark boundingRectWithSize:CGSizeMake(minDefaultWidth,30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil];
    
    if(w<sizeOfTxt.size.width)
    {
        
        while (sizeOfTxt.size.width>w) {
            size --;
            textFont = [UIFont systemFontOfSize:size];
            
            sizeOfTxt = [mark boundingRectWithSize:CGSizeMake(minDefaultWidth,30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil];
        }
        
    }
    else
    {
        
        size =45;
        textFont = [UIFont systemFontOfSize:size];
        sizeOfTxt = [mark boundingRectWithSize:CGSizeMake(minDefaultWidth,30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil];
        while (sizeOfTxt.size.width>w) {
            size ++;
            textFont = [UIFont systemFontOfSize:size];
//            NSLineBreakModeWordWrap
            sizeOfTxt = [mark boundingRectWithSize:CGSizeMake(self.frame.size.width,30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textFont} context:nil];
        }
        
    }
    UIGraphicsBeginImageContext(img.size);
    [[UIColor redColor] set];
    [img drawInRect:CGRectMake(0,0, w, h)];
    [mark drawInRect:CGRectMake((w-sizeOfTxt.size.width)/2,(h-sizeOfTxt.size.height)/2, sizeOfTxt.size.width, sizeOfTxt.size.height) withAttributes:@{NSFontAttributeName:textFont}];
    UIImage *aimg =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return aimg;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint midPoint = midpoint(self.previousPoint, currentPoint);
    NSLog(@"获取到的触摸点的位置为--currentPoint:%@",NSStringFromCGPoint(currentPoint));
    
    CGFloat viewHeight = self.frame.size.height;
    CGFloat currentY = currentPoint.y;
    if (pan.state ==UIGestureRecognizerStateBegan) {
        [self.path moveToPoint:currentPoint];
        
    }
    else if (pan.state ==UIGestureRecognizerStateChanged)
    {
        [self.path addQuadCurveToPoint:midPoint controlPoint:self.previousPoint];
        
        
    }
    
    if(0 <= currentY && currentY <= viewHeight)
    {
        if(_max == 0 && _min == 0)
        {
            _max = currentPoint.x;
            _min = currentPoint.x;
        }
        else
        {
            if(_max <= currentPoint.x)
            {
                _max = currentPoint.x;
            }
            if(_min>=currentPoint.x)
            {
                _min = currentPoint.x;
            }
        }
        
    }
    
    self.previousPoint = currentPoint;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];
    [[UIColor blackColor] setStroke];
    [self.path stroke];
    
    self.layer.cornerRadius =5.0;
    self.clipsToBounds =YES;
    self.layer.borderWidth =0.5;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    if(!self.sure)
    {
        
        NSString *str = @"请绘制签名";
        CGContextSetRGBFillColor (context,  108/255, 108/255,108/255, 0.3);//设置填充颜色
        CGRect rect1 = CGRectMake((rect.size.width -StrWidth)/2, (rect.size.height -StrHeight)/2-5,StrWidth, StrHeight);
        _origionX = rect1.origin.x;
        _totalWidth = rect1.origin.x+StrWidth;
        
        UIFont  *font = [UIFont systemFontOfSize:25];//设置字体
        [str drawInRect:rect1 withAttributes:@{NSFontAttributeName:font}];
    }
    else
    {
        _sure = NO;
    }
    
}

- (void)clearMessage
{
    _max = 0;
    _min = 0;
    _path = [UIBezierPath bezierPath];
    [_path setLineWidth:2];
    
    [self setNeedsDisplay];
}
- (void)sureMessage
{
    //没有签名发生时
    if(_min == 0&&_max == 0)
    {
        _min = 0;
        _max = 0;
    }
    _sure = YES;
    [self setNeedsDisplay];
    return [self imageRepresentation];
}

@end
