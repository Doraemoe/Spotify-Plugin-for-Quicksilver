//
//  QSSpotifyPrefPane.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-27.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface QSSpotifyPrefPane : QSPreferencePane {
    IBOutlet NSTextField *usr;
    IBOutlet NSSecureTextField *pass;
    IBOutlet NSProgressIndicator *ind;
    IBOutlet NSTextField *warning;
    IBOutlet NSButton *signInOutButton;
}

- (void)setPseudoContext;
- (IBAction)authenticate:(id)sender;
- (void)startAnimation;
- (void)endAnimation;
- (void)finishLogin;
- (void)setWarningMessage:(NSString *)msg withColor:(NSColor *)color;

@end
