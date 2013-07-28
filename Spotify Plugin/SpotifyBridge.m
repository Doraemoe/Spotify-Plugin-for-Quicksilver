//
//  SpotifyBridge.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//  Copyright (c) 2013年 Jin Yifan. All rights reserved.
//

#import "SpotifyBridge.h"

static SpotifyApplication *Spotify;

SpotifyApplication *QSSpotify()
{
    if (!Spotify) {
        Spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];
    }
    return Spotify;
}
