//
//  QSSpotifyUtil.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-28.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import "QSSpotifyUtil.h"
#import "QSSpotifyPrefPane.h"
#include "appkey.c"

@implementation QSSpotifyUtil

@synthesize prefPane;

+ (void)initialize {
    [QSSpotifyUtil sharedInstance];
}

+ (QSSpotifyUtil *)sharedInstance {
    static QSSpotifyUtil *su = nil;
    if (su == nil) {
        su = [[QSSpotifyUtil alloc] init];
    }
    return su;
}

- (id)init
{
    if (self = [super init]) {
        NSError *error = nil;
        [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] userAgent:@"com.qsapp.spotify" loadingPolicy:SPAsyncLoadingManual error:&error];
        if(error != nil) {
            NSLog(@"CocoaLibSpotify init failed: %@", error);
            abort();
        }
        
        [[SPSession sharedSession] setDelegate:self];
        NSLog(@"hahahah");
    }
    return self;
}

#pragma mark -
#pragma mark Spotify login

- (void) attemptLoginWithName:(NSString *)name password:(NSString *)pass {
    
    if ([name length] > 0 && [pass length] > 0) {
        [[SPSession sharedSession] attemptLoginWithUserName:name password:pass];
        
    }
    else {
        [prefPane setWarningMessage:@"Please enter username and password" withColor:[NSColor redColor]];
        [prefPane endAnimation];
        NSBeep();
    }
}

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    [prefPane finishLogin];
    NSLog(@"success");
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
    [prefPane setWarningMessage:[error localizedDescription] withColor:[NSColor redColor]];
    [prefPane endAnimation];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error {
    [prefPane setWarningMessage:[error localizedDescription] withColor:[NSColor redColor]];
    [prefPane endAnimation];
}

-(void)sessionDidLogOut:(SPSession *)aSession {
    NSLog(@"log out");
}
@end
