
//
//  ImageUtils.m
//  自定义算法修改像素点
//
//  Created by lalala on 2017/5/17.
//  Copyright © 2017年 lsh. All rights reserved.
//

#import "ImageUtils.h"
#import "Color.h"
@implementation ImageUtils
+(UIImage *)imageProcess:(UIImage *)image{
    //第一步: 获取图片的大小
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    //开辟内存空间（创建颜色空间）
    //两种：彩色空间、灰色的空间
    //第一种: CGColorSpaceCreateDeviceRGB -- 彩色空间
    //第二种：CGColorSpaceCreateDeviceGray -- 灰色空间
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    //第三步；创建图片上下文（解析图片的信息）
    /*
     /参数一： 数据源 （图片->像素数组->对应分量（ARGB））
     数组指针——>指向数组首地址
     //分析参数的含义？
     为什么使用的是UInt32*
     calloc --> C/C++ 中的动态内存分配
     //第一点 ： 图像学中的像素点-> 由ARGB组成
     //第二点： ARGB每一个分量的大小是8位
     //第三点： 像素数组每一个像素点大小是多少？你能够确定吗？ 所以我们采用最大像素点（ARGB）
     //第四点： ARGB = 8 * 4 = 32位
     //为什么是U
     //计算机分为有符号和无符号
     /有符号： 每一个分量的取值范围（-128--127）--->Sign-->简写： S
     /无符号： 每一个分量的取值范围（0--255）--通用（Unsigned） --- 简写：U-->一般采用通用取值范围
     */
    UInt32 * imagePixels = (UInt32 *)calloc(width * height, sizeof(UInt32));
    //参数二： 图片宽
    //参数三： 图片高
    //参数四： 每一个像素点，每一个分量的大小（8位）
    //参数五： 每一行大小
    //如何计算(每八位 = 1字节)
    //第一点： 首先计算每一个像素点内存大小= ARGB = 8位* 4 = 4字节
    //第二点： 一行内存大小 = 像素带你 * width = 4* width
    //参数六： 颜色空间
    //参数七： 是否需要透明度(布局排版方式)
    //kCGBitmapByteOrder32Big : 大端字节序
    CGContextRef contextRef = CGBitmapContextCreate(imagePixels, width, height, 8, 4 * width, colorSpaceRef, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    
    //第四步： 根据图片上下文绘制图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    //第五步： 正式开始操作内存（美白）
    //美白 -> 彩色图片 -> 像素数组 -> 像素点（ARGB） -> 操作分量 - > 操作二进制
    //分析图像学的三原色取值特点
    //ARGB ---> 取值范围 --> 0 - 255(颜色变化) ： 值越大，那么越白
    
    //增加亮度 ---> 50
    /*
     原始图片 r: 50 g: 50 b: 100
     修改后 r: 100 g: 100 b: 150
     */
    int lumi = 50;
    //循环遍历每一个像素点  修改分量值
    //外层循环控制列，内层循环控制行
    for ( int  i = 0 ; i< height; i++) {
        for (int j = 0; j< width; j++) {
            //获取当前的像素点 --> 指针位移方式 --> 操作内存
            UInt32 * currentPixels = imagePixels + (i * width) + j;
            //获取像素点的值(* 取值 & 取地址)
            UInt32  color = *currentPixels;
//            NSLog(@"color = %d",color);
            //获取ARGB分量值
            UInt32 thisR,thisG,thisB,thisA;
            
            //获取红色：
            thisR = R(color);
            thisR = thisR + lumi;
            thisR = thisR > 255 ? 255 : thisR;
            //获取绿色
            thisG = G(color);
            thisG = thisG + lumi;
            thisG = thisG > 255 ? 255 : thisG;
            //获取蓝色
            thisB = B(color);
            thisB = thisB + lumi;
            thisB = thisB > 255 ? 255 : thisB;
            //获取透明度
            thisA = A(color);
            //修改像素点的值
            *currentPixels = RGBAMake(thisR, thisG, thisB, thisA);
            
        }
    }
    //第六步： 创建图片
    CGImageRef newImageReg = CGBitmapContextCreateImage(contextRef);
    UIImage * newImage = [UIImage imageWithCGImage:newImageReg];
    //第七步： 释放内存
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(contextRef);
    CGImageRelease(newImageReg);
    free(imagePixels);
    
    return newImage;
}
@end
