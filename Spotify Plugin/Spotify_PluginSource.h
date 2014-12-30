//
//  Spotify_PluginSource.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//
#import "SpotifyBridge.h"

#define QSSpotify_PluginType @"QSSpotify_PluginType"

@interface QSSpotifyControlSource : QSObjectSource

@end

@interface QSCommand (Spotify)
- (NSDictionary *)commandDict;
@end

@interface QSSpotifyObjectSource : QSObjectSource


@end