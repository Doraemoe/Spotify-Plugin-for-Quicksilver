//
//  Spotify_PluginSource.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//
#import "SpotifyBridge.h"

#define QSSpotify_PluginType @"QSSpotify_PluginType"

@interface QSSpotify_PluginSource : QSObjectSource <SBApplicationDelegate>
{
    SpotifyApplication *Spotify;
}
@end

@interface QSSpotifyControlSource : QSObjectSource

@end