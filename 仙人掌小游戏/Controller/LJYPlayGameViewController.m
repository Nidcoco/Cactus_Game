//
//  LJYPlayGameViewController.m
//  仙人掌小游戏
//
//  Created by 李俊宇 on 2018/10/18.
//  Copyright © 2018年 李俊宇. All rights reserved.
//

#import "LJYPlayGameViewController.h"

#define kLifeImageTag 100

#define kGameOverAlert 1
#define kPauseAlert 2




@interface LJYPlayGameViewController ()

@end

@implementation LJYPlayGameViewController

- (void)viewDidLoad
{
//    [[ICFGameCenterManager sharedManager] setDelegate: self];
    //初始化
    //分数为零，5颗心
    score = 0;
    life = 5;
    
    //当前游戏的状态
    gameOver = NO;
    paused = NO;
    
    [super viewDidLoad];
    
    [self updateLife];
    
    //make one cactus right away
    
    //游戏开始就弹出一个仙人掌
    [self performSelector: @selector(spawnCactus)];
    
    //一秒后再弹出一个
    [self performSelector:@selector(spawnCactus) withObject:nil afterDelay:1.0];
}

#pragma mark -
#pragma mark Actions


//暂停单击事件
- (IBAction)pause:(id)sender
{
    paused = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Game Paused!" delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Resume", nil];
    alert.tag = kPauseAlert;
    [alert show];
}

#pragma mark -
#pragma mark Game Play

- (void)spawnCactus;
{
    if(gameOver)
    {
        return;
    }
    
    if(paused)
    {
        [self performSelector:@selector(spawnCactus) withObject:nil afterDelay:1];
        return;
    }
    
    //一个表示仙人掌出现的行，一个表示x轴上一个随机位置
    int rowToSpawnIn = arc4random()%3;
    int horizontalLocation = (arc4random()%667);
    
    //随机一个大小的仙人掌，有三种大小的仙人掌
    int cactusSize = arc4random()%3;
    UIImage *cactusImage = nil;
    //仙人掌
    switch (cactusSize)
    {
        case 0:
            cactusImage = [UIImage imageNamed: @"CactusLarge.png"];
            break;
        case 1:
            cactusImage = [UIImage imageNamed: @"CactusMed.png"];
            break;
        case 2:
            cactusImage = [UIImage imageNamed: @"CactusSmall.png"];
            break;
        default:
            break;
    }
    
    //防止仙人掌出现在屏幕最右边看不见
    if(horizontalLocation > 667 - cactusImage.size.width)
        horizontalLocation = 667 - cactusImage.size.width;
    
    UIImageView *duneToSpawnBehind = nil;
    //仙人掌随机出现在第几层沙丘
    switch (rowToSpawnIn)
    {
        case 0:
            duneToSpawnBehind = duneOne;
            break;
        case 1:
            duneToSpawnBehind = duneTwo;
            break;
        case 2:
            duneToSpawnBehind = duneThree;
            break;
        default:
            break;
    }
    
    float cactusHeight = cactusImage.size.height;
    float cactusWidth = cactusImage.size.width;
    
    UIButton *cactus = [[UIButton alloc] initWithFrame:CGRectMake(horizontalLocation, (duneToSpawnBehind.frame.origin.y), cactusWidth, cactusHeight)];
    [cactus setImage:cactusImage forState: UIControlStateNormal];
    [cactus addTarget:self action:@selector(cactusHit:) forControlEvents:UIControlEventTouchDown];
    [self.view insertSubview:cactus belowSubview:duneToSpawnBehind];
    
    
    //动画标识slideInCactus，UIViewAnimationCurveEaseInOut开始和结束减速
    [UIView beginAnimations: @"slideInCactus" context:nil];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 0.25];
    cactus.frame = CGRectMake(horizontalLocation, (duneToSpawnBehind.frame.origin.y)-cactusHeight/2, cactusWidth, cactusHeight);
    [UIView commitAnimations];
    
    [self performSelector:@selector(cactusMissed:) withObject:cactus afterDelay:2.0];
    
}

- (void)cactusMissed:(UIButton *)sender;
{
    if([sender superview] == nil)
    {
        return;
    }
    
    if(paused)
    {
        return;
    }
    
    
    CGRect frame = sender.frame;
    frame.origin.y += sender.frame.size.height;
    
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options: UIViewAnimationCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         sender.frame = frame;
     }
                     completion:^(BOOL finished)
     {
         [sender removeFromSuperview];
         [self performSelector:@selector(spawnCactus) withObject:nil afterDelay:(arc4random()%3) + .5];
         life--;
         [self updateLife];
     }];
}

//仙人掌点击事件
- (void)cactusHit:(id)sender;
{
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options: UIViewAnimationCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         [sender setAlpha: 0];
     }
                     completion:^(BOOL finished)
     {
         [sender removeFromSuperview];
     }];
    
    score++;
    [self displayNewScore: score];
    
    [self performSelector:@selector(spawnCactus) withObject:nil afterDelay:(arc4random()%3) + .5];
    
}

//心变少
-(void)updateLife
{
    UIImage *lifeImage = [UIImage imageNamed:@"heart.png"];
    
    for(UIView *view in [self.view subviews])
    {
        if(view.tag == kLifeImageTag)
        {
            [view removeFromSuperview];
        }
    }
    
    
    for (int x = 0; x < life; x++)
    {
        UIImageView *lifeImageView = [[UIImageView alloc] initWithImage: lifeImage];
        lifeImageView.tag = kLifeImageTag;
        
        CGRect frame = lifeImageView.frame;
        frame.origin.x = 685 - (x * 30);
        frame.origin.y = 20;
        lifeImageView.frame = frame;
        
        [self.view addSubview: lifeImageView];
    }
    
    if(life == 0)
    {
        //report score
//        [[ICFGameCenterManager sharedManager] reportScore: (int64_t)score forCategory:@"com.dragonforged.whackacac.leaderboard"];
        
        gameOver = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over!" message: [NSString stringWithFormat: @"You scored %0.0f points!", score] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        alert.tag = kGameOverAlert;
        [alert show];
    }
}

- (void)displayNewScore:(float)updatedScore;
{
    int scoreInt = score;
    
    if(scoreInt % 10 == 0 && score <= 50)
    {
        [self spawnCactus];
    }
    
    scoreLabel.text = [NSString stringWithFormat: @"%06.0f", updatedScore];
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kGameOverAlert)
    {
        [self.navigationController popViewControllerAnimated: YES];
    }
    
    else if (alertView.tag == kPauseAlert)
    {
        if(buttonIndex == 0) //exit
        {
            //report score
//            [[ICFGameCenterManager sharedManager] reportScore: (int64_t)score forCategory:@"com.dragonforged.whackacac.leaderboard"];
            
            [self.navigationController popViewControllerAnimated: YES];
        }
        else //resume
        {
            paused = NO;
        }
    }
}

#pragma mark -
#pragma mark GameCenterManagerDelegate

-(void)gameCenterScoreReported:(NSError *)error;
{
    if(error != nil)
    {
        NSLog(@"An error occurred trying to report a score to Game Center: %@", [error localizedDescription]);
        
    }
    
    else
    {
        NSLog(@"Successfully submitted score");
    }
}

#pragma mark -
#pragma mark Cleanup

-(void)viewDidUnload
{
    scoreLabel = nil;
    duneOne = nil;
    duneTwo = nil;
    duneThree = nil;
    [super viewDidUnload];
}


//
////强制旋转屏幕
//- (void)orientationToPortrait:(UIInterfaceOrientation)orientation {
//    SEL selector = NSSelectorFromString(@"setOrientation:");
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//    [invocation setSelector:selector];
//    [invocation setTarget:[UIDevice currentDevice]];
//    int val = orientation;
//    [invocation setArgument:&val atIndex:2];//前两个参数已被target和selector占用
//    [invocation invoke];
//}
//-(void)viewWillAppear{
//    
//    [self orientationToPortrait:UIInterfaceOrientationLandscapeLeft];
//}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"InterfaceOrientation" object:@"YES"];

    [self orientationToPortrait:UIInterfaceOrientationLandscapeRight];
}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    
//    isPotrait = !isPotrait;
//    
//    if (isPotrait) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    }else {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"InterfaceOrientation" object:@"NO"];
//    
//}
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


@end
