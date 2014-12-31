//
//  QSSpotifyUtil.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-28.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "AFNetworking.h"

@class QSSpotifyPrefPane;

@interface QSSpotifyUtil : NSObject

@property QSSpotifyPrefPane *prefPane;
@property NSString *accessToken;
@property NSString *refreshToken;

@property NSString *userID;
@property NSString *displayName;
@property NSMutableArray *playlists;
@property NSSet *oldPlaylistsSet;


@property NSUInteger totalPlaylistsNumber;
@property WebView *web;
@property NSWindow *codeWindow;

@property NSInteger tokenStartTime;
@property NSInteger tokenExpiresIn;

@property BOOL needUserID;
@property BOOL needPlaylists;


+ (QSSpotifyUtil *)sharedInstance;

- (void)attemptLogin;
- (void)signOut;
- (void)starSongWithURI:(NSString *) URI;
- (void)requestAccessTokenFromRefreshToken;
- (void)getPlaylists;
- (void)accessUserProfile;

@end
