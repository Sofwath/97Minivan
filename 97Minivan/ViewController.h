//
//  ViewController.h
//  97Minivan
//
//  Created by Sofwathullah Mohamed on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CERoundProgressView.h"
#import "CEPlayer.h"
#import <Socialize/Socialize.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface ViewController : UIViewController <CEPlayerDelegate> {
    MPMoviePlayerController *minivanPlayer;
}


- (IBAction)_anisotropicSlider:(UISlider *)sender;

@property (retain, nonatomic) IBOutlet CERoundProgressView *progressView;
- (IBAction)playPauseButton:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIButton *playPauseButton;

@property (retain, nonatomic) CEPlayer *player;

@property (nonatomic, retain) SZActionBar *actionBar;
@property (nonatomic, retain) id<SZEntity> entity;
- (IBAction)makecomment:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *comment;

@property (weak, nonatomic) IBOutlet UIButton *user;
- (IBAction)showsettings:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *twitter;

- (IBAction)twitterpost:(id)sender;


@end
