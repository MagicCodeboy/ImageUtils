
//
//  ImageUtils.m
//  自定义算法修改像素点
//
//  Created by lalala on 2017/5/17.
//  Copyright © 2017年 lsh. All rights reserved.
//

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

#import "ImageUtils.h"
#import "Color.h"
@implementation ImageUtils
//美白
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
    //第二点： 一行内存大小 = 像素点 * width = 4* width
    //参数六： 颜色空间
    //参数七： 是否需要透明度(布局排版方式) 分为大端字节序和小端字节序
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

//马赛克（有问题，未解决）
+(UIImage *)imageMosaic:(UIImage *)image{
    //分析实现的原理
    //第一步 确定图片的大小
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    //第二步： 创建颜色空间（打码处理： 彩色图片、灰色图片）
    //现在不知道图片到底是彩色还是灰色
    //动态获取图片的颜色空间(方法) ---> 开源框架--->OpenCV 源码
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //第三步： 创建图片的上下文
    //参数， 数据源 宽 高 图像学中的ARGB分量大小（像素点分量大小： 8位 = 1字节） --> 固定  每一行的大小
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
    
    //第四步 ： 根据图片上下文绘制图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    //第五步： 获取图片像素数组指针（将图片 --> 像素数组）
    unsigned char *bitmapDataArray = (unsigned char *)CGBitmapContextGetData(contextRef);
    //第六步 ： 马赛克算法
    //实现算法
    //每一个像素点4个通道（ARGB、四个通道）
    //马赛克点大小 3*3矩形
    NSUInteger currentIndex,preCurrentIndex,size = 15;
    unsigned char* pixels[4] = {0};
    //指定区域打码
    /*
     for (int i = 200 ; i < 370 - 1; i++) {
     for (int j = 200; i< 370 - 1; j++) {
     */
    for (NSUInteger i = 200 ; i < height - 1; i++) {
        for (NSUInteger j = 200; i < width - 1; j++) {
            //筛选矩形区域 --> 指针位移
            currentIndex = i * width + j;
            if (i % size == 0) {
                //处理宽(处理第一行 i = 0)
                if (j % size == 0) {
                     //矩形开始位置（左上角） C语言API --> 拷贝数据函数
                    //参数一；目标 参数二 原始数据 参数三 长度（截取长度）
                    memcpy(pixels, bitmapDataArray + 4*currentIndex, 4);
                } else {
                    //j % size == 1 --->第二个像素点
                    //将左上角原点像素点值 --> 赋值给后面聚星区域像素点值
                    memcpy(bitmapDataArray + 4 * currentIndex, pixels, 4);
                }
            } else {
                //处理宽(处理第二行 i = 1)
                //处理宽(处理第三行 i = 2)
                //计算下标（作用： 为了我们拷贝数据提供下标）
                //获取上一行第一个像素点值（相对的）
                preCurrentIndex = (i - 1) * width + j;
                //dsct 当前的像素点
                //以此类推。。。。
                memcpy(bitmapDataArray + 4 * currentIndex, bitmapDataArray + 4 * preCurrentIndex, 4);
            }
        }
    }
    //第七步： 将像素数组 --> iOS数据集合
   CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitmapDataArray, width * height * 4, NULL);
    
    //第八步： 创建马赛克的图片
   CGImageRef masaicImageRef = CGImageCreate(width, height, 8, 4 * 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast, providerRef, NULL, NO, kCGRenderingIntentDefault);
    //第九步： 创建图片马赛克上下文
    CGContextRef outPutContextRef = CGBitmapContextCreate(nil, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
    //第十步： 绘制马赛克图片
    CGContextDrawImage(outPutContextRef, CGRectMake(0, 0, width, height), masaicImageRef);
    
    //创建输出图片
   CGImageRef resultImageRef = CGBitmapContextCreateImage(outPutContextRef);
    UIImage * resultImage = [UIImage imageWithCGImage:resultImageRef];
    //第十二步： 释放内存
    CGImageRelease(resultImageRef);
    CGImageRelease(masaicImageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(providerRef);
    CGContextRelease(contextRef);
    CGContextRelease(outPutContextRef);
    return resultImage;
}
//给图片打马赛克（已经实现）
+ (UIImage *)imageMosaic:(UIImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              kCGImageAlphaPremultipliedLast,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    return resultImage;
    
}
@end
