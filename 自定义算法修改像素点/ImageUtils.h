//
//  ImageUtils.h
//  自定义算法修改像素点
//
//  Created by lalala on 2017/5/17.
//  Copyright © 2017年 lsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//图像处理
@interface ImageUtils : NSObject
//美白处理
+(UIImage *)imageProcess:(UIImage *)image;
//图片打上马赛克处理(未实现)
+(UIImage *)imageMosaic:(UIImage *)image;
//为图片打上马赛克（已经实现）
+ (UIImage *)imageMosaic:(UIImage*)orginImage blockLevel:(NSUInteger)level;
@end
