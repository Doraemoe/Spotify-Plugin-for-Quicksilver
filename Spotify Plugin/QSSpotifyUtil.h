//
//  QSSpotifyUtil.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-28.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@class QSSpotifyPrefPane;

@interface QSSpotifyUtil : NSObject <SPSessionDelegate> {
    QSSpotifyPrefPane *prefPane;
}

@property (retain) QSSpotifyPrefPane *prefPane;

+ (QSSpotifyUtil *)sharedInstance;

- (void)attemptLoginWithName:(NSString *)name password:(NSString *)pass;
- (int)getLoginState;
- (void)attemptLoginWithCredential;
- (void)signOut;
- (void)starSongWithURI:(NSString *) URI;

@end
