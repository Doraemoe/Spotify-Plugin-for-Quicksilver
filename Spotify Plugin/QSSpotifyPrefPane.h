//
//  QSSpotifyPrefPane.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-27.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QSSpotifyPrefPane : QSPreferencePane
    
@property (weak) IBOutlet NSProgressIndicator *ind;
@property (weak) IBOutlet NSTextField *warning;
@property (weak) IBOutlet NSButton *signInOutButton;

- (IBAction)authenticate:(id)sender;
- (void)startAnimation;
- (void)endAnimation;
- (void)finishLogin;
- (void)finishLogout;
- (void)setWarningMessage:(NSString *)msg withColor:(NSColor *)color;

@end
