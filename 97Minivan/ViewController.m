//
//  ViewController.m
//  97Minivan
//
//  Created by Sofwathullah Mohamed on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "DAAnisotropicImage.h"
#import <Socialize/Socialize.h>
#import "YRDropdownView.h"
#import "Reachability.h"

#include <AudioToolbox/AudioQueue.h>
#include <AudioToolbox/AudioFile.h>
#include <AudioToolbox/AudioConverter.h>
#include <AudioToolbox/AudioToolbox.h>


@interface ViewController () {
    UIImageView *_anisotropicImageView;
    UISlider *_anisotropicSlider;
}
- (void)twitterAction:(id)sender;
- (void)facebookAction:(id)sender;
- (void)mailAction:(id)sender;
@end

@implementation ViewController
@synthesize twitter;



@synthesize comment;
@synthesize user;

@synthesize progressView;
@synthesize playPauseButton;
@synthesize player;

CGFloat kMovieViewOffsetX = 20.0;
CGFloat kMovieViewOffsetY = 20.0;

//@implementation ViewController 



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

    UIImage *toolBarIMG = [UIImage imageNamed: @"blktopbar.png"];  
    
    [[UINavigationBar appearance] setBackgroundImage:toolBarIMG forBarMetrics:UIBarMetricsDefault];
    
    NSURL* resourcePath ; 
    resourcePath = [NSURL URLWithString:@"http://178.159.0.13:8162"];

    
    minivanPlayer = [[MPMoviePlayerController alloc] initWithContentURL:resourcePath];
    
    minivanPlayer.view.frame = self.view.bounds;
    [self.view insertSubview:minivanPlayer.view atIndex:0];
    
   
    minivanPlayer.controlStyle = MPMovieControlStyleEmbedded;
    minivanPlayer.shouldAutoplay = NO;
    
    minivanPlayer.movieSourceType = MPMovieSourceTypeStreaming;
    
    minivanPlayer.useApplicationAudioSession = YES;
    
    [minivanPlayer prepareToPlay];
    
    
    
    /* Indicate the movie player allows AirPlay movie playback. */
    minivanPlayer.allowsAirPlay = YES;
    
    
    // UI
    
    [DAAnisotropicImage startAnisotropicUpdatesWithHandler:^(UIImage *image) {
        [_anisotropicImageView setImage:image];
        [_anisotropicSlider setThumbImage:image forState:UIControlStateNormal];
        [_anisotropicSlider setThumbImage:image forState:UIControlStateHighlighted];
    }];
    
    _anisotropicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(102.0f, 40.0f, 116.0f, 116.0f)];
    //[self.view addSubview:_anisotropicImageView];
    
    _anisotropicSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0f, 400.0f, 280.0f, 40.0f)];
    [_anisotropicSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_anisotropicSlider];
    [_anisotropicSlider setValue:0.5f];
    
    // The following is for aesthetic purposes, so it looks like the iOS6 Music player
    UIImage *stretchableFillImage = [[UIImage imageNamed:@"slider-fill"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    UIImage *stretchableTrackImage = [[UIImage imageNamed:@"slider-track"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f)];
    [_anisotropicSlider setMinimumTrackImage:stretchableFillImage forState:UIControlStateNormal];
    [_anisotropicSlider setMaximumTrackImage:stretchableTrackImage forState:UIControlStateNormal];
    
    
    // Set the image with a default state (nil accelerometer data)
    UIImage *initialImage = [DAAnisotropicImage imageFromAccelerometerData:nil];
    [_anisotropicImageView setImage:initialImage];
    [_anisotropicSlider setThumbImage:initialImage forState:UIControlStateNormal];
    [_anisotropicSlider setThumbImage:initialImage forState:UIControlStateHighlighted];
    _anisotropicSlider.minimumValue = 0.0;
    _anisotropicSlider.maximumValue = 1.0;
    // 
    
    self.player = [[CEPlayer alloc] init] ;
    self.player.delegate = self;
    
    UIColor *tintColor = [UIColor grayColor];
    [[UISlider appearance] setMinimumTrackTintColor:tintColor];
    [[CERoundProgressView appearance] setTintColor:tintColor];
    
    self.progressView.trackColor = [UIColor colorWithWhite:0.80 alpha:1.0];
    
    self.progressView.startAngle = (3.0*M_PI)/2.0;

    //[minivanPlayer stop];
    
    
    // background
  
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:)name:MPMoviePlayerPlaybackDidFinishNotification object:minivanPlayer]; 
   
    
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory);
    AudioSessionSetActive (true);
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_CurrentHardwareOutputVolume ,
                                     audioVolumeChangeListenerCallback,
                                     (__bridge void*)_anisotropicSlider
                                     );
    
    
}

- (BOOL)isDataSourceAvailable
{
    static BOOL checkNetwork = YES;
    static BOOL _isDataSourceAvailable = NO;
    if (checkNetwork) { // Since checking the reachability of a host can be expensive, cache the result and perform the reachability check once.
        checkNetwork = NO;
        
        Boolean success;
        const char *host_name = "twitter.com"; // your data source host name
        
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    return _isDataSourceAvailable;
}



- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            [minivanPlayer play];
            break;
        case UIEventSubtypeRemoteControlPause:
            [minivanPlayer pause];
            break;
        default:
            break;
    }
}


- (void)viewDidUnload
{
    [self setComment:nil];
    [self setUser:nil];
    [self setUser:nil];
    [self setTwitter:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    AudioSessionRemovePropertyListenerWithUserData(
                                                   kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                   audioVolumeChangeListenerCallback,
                                                   (__bridge void*)_anisotropicSlider);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);

    //return NO;
}


- (IBAction)playPauseButton:(UIButton *)sender 
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    if(sender.selected) // Shows the Pause symbol
    {
        [minivanPlayer pause];
        
        minivanPlayer.useApplicationAudioSession = NO;
        
        sender.selected = NO;
        

        [self.player pause];

        [audioSession setActive:NO error:nil];

    }
    else    // Shows the Play symbol
    {
        
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [reachability currentReachabilityStatus];
        if (internetStatus != NotReachable) {
            //my web-dependent code
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(moviePlayBackDidFinish:)
                                                         name:MPMoviePlayerPlaybackDidFinishNotification
                                                       object:minivanPlayer];
            
            minivanPlayer.controlStyle = MPMovieControlStyleEmbedded;

            [minivanPlayer play];
            
            //minivanPlayer.useApplicationAudioSession = YES;
            
            
            sender.selected = YES;
            [self.player play];
            
            //[audioSession setActive:YES error:nil];

        }
        else {
            //there-is-no-connection warning
            [YRDropdownView showDropdownInView:self.view.window
                                         title:@"Warning"
                                        detail:@"Sorry! Cannot reach the streaming server. Please check your internet (3G/Wi-Fi) connection and try again."
                                         image:[UIImage imageNamed:@"dropdown-alert"]
                                      animated:YES
                                     hideAfter:3];
        }

        

    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:minivanPlayer];
    
    
    if ([player respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}


// MARK: CEPlayerDelegate methods

- (void) player:(CEPlayer *)player didReachPosition:(float)position
{
    self.progressView.progress = position;
}

- (void) playerDidStop:(CEPlayer *)player
{
    self.playPauseButton.selected = NO;
    self.progressView.progress = 0.0;
}



- (IBAction)makecomment:(id)sender {
    //SZEntity *entity = [SZEntity entityWithKey:@"97Minivan" name:@"97Minivan"];
    //[SZCommentUtils showCommentsListWithViewController:self entity:entity completion:nil];
    
    SZEntity *entity = [SZEntity entityWithKey:@"97Minivan" name:@"97Minivan"];
    SZCommentsListViewController *comments = [[SZCommentsListViewController alloc] initWithEntity:entity];
    comments.completionBlock = ^{
        
        // Dismiss however you want here
        [self dismissModalViewControllerAnimated:NO];
    };
    
    // Present however you want here
    [self presentModalViewController:comments animated:NO];
}



- (IBAction)showsettings:(id)sender {
    [SZUserUtils showUserProfileInViewController:self user:nil completion:^(id<SZFullUser> user) {
        NSLog(@"Done showing profile");
    }];

}
- (IBAction)twitterpost:(id)sender {
        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        
        // Set the initial tweet text. See the framework for additional properties that can be set.
        //[tweetViewController setInitialText:[NSString stringWithFormat:@"%@", Tweet_Message]];
        [tweetViewController setInitialText:@"Listening to @97Minivan on 97Minivan iPhone App. "];

        
        [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
            switch (result) {
                case TWTweetComposeViewControllerResultCancelled:
                    // The cancel button was tapped.
                    NSLog(@"Tweet cancelled.");
                    break;
                case TWTweetComposeViewControllerResultDone:
                    // The tweet was sent.
                    NSLog(@"Tweet done.");
                    break;
                default:
                    break;
            }
            [self dismissModalViewControllerAnimated:YES];
        }];
        
        // Present the tweet composition view controller modally.
        [self presentModalViewController:tweetViewController animated:YES];

}



-(void) sliderAction:(id) sender
{
    NSLog(@"%f Volume :",_anisotropicSlider.value);
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:_anisotropicSlider.value];
};

// AVAudiosession Delegate Method
- (void)endInterruptionWithFlags:(NSUInteger)flags
{
    // When interruption ends - set the apps audio session active again
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if( flags == AVAudioSessionInterruptionFlags_ShouldResume ) {
        // Resume playback of radio here!!!
    }
}

// Hardware Button Volume Callback
void audioVolumeChangeListenerCallback (
                                        void                      *inUserData,
                                        AudioSessionPropertyID    inID,
                                        UInt32                    inDataSize,
                                        const void                *inData)
{
    UISlider * volumeSlider = (__bridge UISlider *) inUserData;
    Float32 newGain = *(Float32 *)inData;
    [volumeSlider setValue:newGain animated:YES];
}

// My UISlider Did Change Callback
- (IBAction)volChanged:(id)sender
{
    CGFloat oldVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];
    CGFloat newVolume = ((UISlider*)sender).value;
    
    // Don't change the volume EVERYTIME but in discrete steps.
    // Performance will say "THANK YOU"
    if( fabsf(newVolume - oldVolume) > 0.05 || newVolume == 0 || newVolume == 1  )
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:newVolume];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set the volume slider to the correct value on appearance of the view
    _anisotropicSlider.value = [[MPMusicPlayerController applicationMusicPlayer] volume];
}


@end
