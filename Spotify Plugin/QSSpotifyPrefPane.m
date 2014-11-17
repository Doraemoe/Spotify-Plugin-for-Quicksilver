//
//  QSSpotifyPrefPane.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-27.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import "QSSpotifyPrefPane.h"
#import "QSSpotifyUtil.h"

@implementation QSSpotifyPrefPane

- (NSView *)loadMainView {
    NSView *view = [super loadMainView];
    [[QSSpotifyUtil sharedInstance] setPrefPane:self];
    [self updateUI];
    return view;
}

- (void)startAnimation {
    [_ind setHidden:NO];
    [_ind startAnimation:self];
}

- (void)endAnimation {
    [_ind stopAnimation:self];
    [_ind setHidden:YES];

}


- (IBAction)authenticate:(id)sender {
    if ([[_signInOutButton title]  isEqual: @"Sign In"]) {
        [self startAnimation];
        QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
        
        [su attemptLogin];
    }
    else {
        [self startAnimation];
        [[QSSpotifyUtil sharedInstance] signOut];
        [self finishLogout];
    }
}

- (void)finishLogin {
    [_signInOutButton setTitle:@"Sign Out"];
    [self setWarningMessage:@"Login Successful" withColor:[NSColor greenColor]];
    [self endAnimation];
    
}

- (void)finishLogout {
    [_signInOutButton setTitle:@"Sign In"];
    [self setWarningMessage:@"Logout Successful" withColor:[NSColor greenColor]];
    [self endAnimation];
}

- (void)setWarningMessage:(NSString *)msg withColor:(NSColor *)color {
    [_warning setTextColor:color];
    [_warning setStringValue:msg];
}

- (void)updateUI {
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    
    [self startAnimation];
    //[_signInOutButton setEnabled:NO];
    
    [su requestingAccessTokenFromRefreshToken];
    
    if ([su.refreshToken compare:@"RefreshTokenPlaceholder"] == NSOrderedSame) {
        [self finishLogout];
        NSLog(@"first no data");
    }
    else {
        NSLog(@"%@", su.refreshToken);
        [self finishLogin];
    }
}

@end
