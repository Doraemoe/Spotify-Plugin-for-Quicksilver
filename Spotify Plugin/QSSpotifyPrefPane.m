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
    [self startAnimation];
    [signInOutButton setEnabled:NO];
    [self updateUI];
    return view;
}

- (void)startAnimation {
    [ind setHidden:NO];
    [ind startAnimation:self];
}

- (void)endAnimation {
    [ind stopAnimation:self];
    [ind setHidden:YES];

}

- (void)setPseudoContext {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *usrName = [defaults valueForKey:@"spotifyUser"];
    
    [usr setStringValue:usrName];
    [pass setStringValue:@"FAKE"];
}


- (IBAction)authenticate:(id)sender {
    if ([[signInOutButton title]  isEqual: @"Sign In"]) {
        [signInOutButton setEnabled:NO];
        [self startAnimation];
        QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
        [su attemptLoginWithName:[usr stringValue] password:[pass stringValue]];
    }
    else {
        [signInOutButton setEnabled:NO];
        [self startAnimation];
        [[QSSpotifyUtil sharedInstance] signOut];
        [self finishLogout];
    }
    
}

- (void)finishLogin {
    [usr setEditable:NO];
    [usr setBackgroundColor:[NSColor secondarySelectedControlColor]];
    [pass setEditable:NO];
    [pass setBackgroundColor:[NSColor secondarySelectedControlColor]];
    [signInOutButton setTitle:@"Sign Out"];
    [self setWarningMessage:@"Login Successful" withColor:[NSColor greenColor]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *usrName = [usr stringValue];
    [defaults setValue:usrName forKey:@"spotifyUser"];
    [signInOutButton setEnabled:YES];
    [self endAnimation];
    
}

- (void)finishLogout {
    [usr setEditable:YES];
    [usr setBackgroundColor:[NSColor clearColor]];
    [pass setEditable:YES];
    [pass setBackgroundColor:[NSColor clearColor]];
    [pass setStringValue:@""];
    [signInOutButton setTitle:@"Sign In"];
    [self setWarningMessage:@"Logout Successful" withColor:[NSColor greenColor]];
    [signInOutButton setEnabled:YES];
    [self endAnimation];
}

- (void)setWarningMessage:(NSString *)msg withColor:(NSColor *)color {
    [warning setTextColor:color];
    [warning setStringValue:msg];
}

- (void)updateUI {
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    if ([su getLoginState] == SP_CONNECTION_STATE_LOGGED_OUT || [su getLoginState] == SP_CONNECTION_STATE_UNDEFINED) {
        NSLog(@"logged out");
        [su attemptLoginWithCredential];
        [signInOutButton setEnabled:YES];
        [self endAnimation];
    }
    else if([su getLoginState] == SP_CONNECTION_STATE_LOGGED_IN){
        NSLog(@"already logged in");
        [self finishLogin];
    }
    else {
        NSLog(@"%d", [su getLoginState]);
        [signInOutButton setEnabled:YES];
        [self endAnimation];
    }
}

@end
