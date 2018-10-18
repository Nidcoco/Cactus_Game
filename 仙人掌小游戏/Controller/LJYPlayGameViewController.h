//
//  LJYPlayGameViewController.h
//  仙人掌小游戏
//
//  Created by 李俊宇 on 2018/10/18.
//  Copyright © 2018年 李俊宇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJYPlayGameViewController : UIViewController<UIAlertViewDelegate>

{
    IBOutlet UILabel *scoreLabel;
    
    float score;
    int life;
    
    BOOL gameOver;
    BOOL paused;
    
    
    IBOutlet UIImageView *duneOne;
    IBOutlet UIImageView *duneTwo;
    IBOutlet UIImageView *duneThree;
    
}

- (IBAction)pause:(id)sender;
- (void)cactusHit:(id)sender;
- (void)displayNewScore:(float)updatedScore;
- (void)spawnCactus;
- (void)cactusMissed:(UIButton *)sender;
-(void)updateLife;




@end
