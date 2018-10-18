//
//  LJYGameViewViewController.m
//  仙人掌小游戏
//
//  Created by 李俊宇 on 2018/10/18.
//  Copyright © 2018年 李俊宇. All rights reserved.
//

#import "LJYGameViewViewController.h"
#import "LJYPlayGameViewController.h"



@interface LJYGameViewViewController ()

@end

@implementation LJYGameViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InterfaceOrientation" object:@"YES"];
    
    [self orientationToPortrait:UIInterfaceOrientationPortrait];
}

//强制旋转屏幕
- (void)orientationToPortrait:(UIInterfaceOrientation)orientation {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];//前两个参数已被target和selector占用
    [invocation invoke];
    
}


- (IBAction)play:(id)sender {
    LJYPlayGameViewController *gameVC = [[LJYPlayGameViewController alloc] init];
    [self.navigationController pushViewController:gameVC animated:YES];
}



@end
