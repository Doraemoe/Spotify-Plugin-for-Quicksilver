//
//  QSSpotifyUtil.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-28.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "AFNetworking.h"
#import "SpotifyBridge.h"


@class QSSpotifyPrefPane;

@interface QSSpotifyUtil : NSObject <NSWindowDelegate>

@property QSSpotifyPrefPane *prefPane;
@property NSString *accessToken;
@property NSString *refreshToken;

@property NSString *userID;
@property NSString *displayName;
@property NSMutableArray *playlists;
@property NSMutableDictionary *tracksInPlaylist;
@property NSSet *oldPlaylistsSet;
@property NSString *trackID;
@property NSString *trackURI;
@property NSString *playlistID;


@property NSUInteger totalPlaylistsNumber;
@property WebView *web;
@property NSWindow *codeWindow;

@property NSInteger tokenStartTime;
@property NSInteger tokenExpiresIn;

@property BOOL needUserID;
@property BOOL needPlaylists;
@property BOOL needSaveTrack;
@property BOOL needTrackInPlaylist;
@property BOOL needSaveTrackToPlaylist;
@property BOOL needFollowArtist;

@property SpotifyApplication *Spotify;


+ (QSSpotifyUtil *)sharedInstance;


- (void)attemptLoginWithPrivate:(NSInteger)allowPrivate;
- (void)signOut;
- (void)saveSongWithID:(NSString *)ID;
- (void)followArtistWithID:(NSString *)ID;
- (void)requestAccessTokenFromRefreshToken;
- (void)getPlaylists;
- (void)accessUserProfile;
- (void)addTrack:(NSString *)uri toPlaylist:(NSString *)playlistID;
- (void)showCurrentTrackNotification;


@end
