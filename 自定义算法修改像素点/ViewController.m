//
//  ViewController.m
//  自定义算法修改像素点
//
//  Created by lalala on 2017/5/17.
//  Copyright © 2017年 lsh. All rights reserved.
//

#import "ViewController.h"
#import "ImageUtils.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *myImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}
- (IBAction)normal:(id)sender {
    _myImage.image = [UIImage imageNamed:@"824b6372b4950d1ad064a90ee426a339.jpg"];
}
- (IBAction)whiteClick:(id)sender {
    _myImage.image = [ImageUtils imageProcess:_myImage.image];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
