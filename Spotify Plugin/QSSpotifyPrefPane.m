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
    //[ind setHidden:NO];
    //[ind startAnimation:self];
    //[self updateUI];
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


- (IBAction)authenticate:(id)sender {
    [self startAnimation];
    NSLog(@"%@", [usr stringValue]);
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    [su attemptLoginWithName:[usr stringValue] password:[pass stringValue]];
}

- (void)finishLogin {
    NSLog(@"this");
    [usr setEditable:NO];
    [usr setBackgroundColor:[NSColor grayColor]];
    [pass setEditable:NO];
    [pass setBackgroundColor:[NSColor grayColor]];
    [signInOutButton setTitle:@"Sign Out"];
    [self setWarningMessage:@"Login Successful" withColor:[NSColor greenColor]];
    [self endAnimation];
}

- (void)setWarningMessage:(NSString *)msg withColor:(NSColor *)color {
    [warning setTextColor:color];
    [warning setStringValue:msg];
}

- (void)updateUI {
    //QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
}

@end
