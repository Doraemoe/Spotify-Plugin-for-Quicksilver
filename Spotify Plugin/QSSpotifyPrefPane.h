//
//  QSSpotifyPrefPane.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-27.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//


@interface QSSpotifyPrefPane : QSPreferencePane
    
@property (weak) IBOutlet NSProgressIndicator *ind;
@property (weak) IBOutlet NSButton *signInOutButton;
@property (weak) IBOutlet NSTextField *username;
@property (weak) IBOutlet NSButton *privateCheckBox;
@property (weak) IBOutlet NSButton *notificationCheckBox;
@property (weak) IBOutlet NSButton *trackNotificationCheckBox;

- (IBAction)authenticate:(id)sender;
- (IBAction)toggleNotification:(id)sender;
- (IBAction)toggleTrackNotification:(id)sender;
- (void)startAnimation;
- (void)endAnimation;
- (void)finishLoginWithUsername:(NSString *)username;
- (void)finishLogout;

@end
