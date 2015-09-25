//
//  QSSpotifyPrefPane.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-27.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import "QSSpotifyPrefPane.h"
#import "QSSpotifyUtil.h"
#import "QSSpotifyDefines.h"

@implementation QSSpotifyPrefPane

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(profileGet:)
                                                     name:UserProfileDidGetNotification
                                                   object:nil];

    }
    return self;
}

- (void)profileGet:(NSNotification *)note {
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    [self finishLoginWithUsername:su.displayName];
}

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
        su.needUserID = YES;
        su.needPlaylists = YES;
        [su attemptLoginWithPrivate:[_privateCheckBox state]];
    }
    else {
        [self startAnimation];
        [[QSSpotifyUtil sharedInstance] signOut];
        [self finishLogout];
    }
}

- (void)finishLoginWithUsername:(NSString *)username {
    [_signInOutButton setTitle:@"Sign Out"];
    [_username setStringValue:[NSString stringWithFormat:@"Signed in as: %@", username]];
    [self endAnimation];
    
}

- (void)finishLogout {
    [_signInOutButton setTitle:@"Sign In"];
    [_username setStringValue:@"Not signed in"];
    [self endAnimation];
}

- (void)updateUI {
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    
    [self startAnimation];
    su.needUserID = YES;
    su.needPlaylists = YES;
    [su requestAccessTokenFromRefreshToken];
    
    if ([su.refreshToken compare:@"RefreshTokenPlaceholder"] == NSOrderedSame) {
        su.needUserID = NO;
        su.needPlaylists = NO;
        [self finishLogout];
        //NSLog(@"first no data");
    }
    else {
        //NSLog(@"refresh token:%@", su.refreshToken);
    }
}

@end
