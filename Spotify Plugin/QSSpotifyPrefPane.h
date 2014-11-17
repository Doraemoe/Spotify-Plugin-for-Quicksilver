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
@property (weak) IBOutlet NSButton *signInOutButton;
@property (weak) IBOutlet NSTextField *username;

- (IBAction)authenticate:(id)sender;
- (void)startAnimation;
- (void)endAnimation;
- (void)finishLoginWithUsername:(NSString *)username;
- (void)finishLogout;

@end
