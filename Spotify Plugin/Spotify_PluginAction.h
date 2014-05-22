//
//  Spotify_PluginAction.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//

#import "SpotifyBridge.h"

@interface QSSpotify_PluginControlProvider : QSActionProvider <NSApplicationDelegate, NSSharingServiceDelegate, NSSharingServicePickerDelegate, NSTextViewDelegate>
{
    SpotifyApplication *Spotify;
}

- (void)play;
- (void)pause;
- (void)togglePlayPause;
- (void)next;
- (void)previous;
- (void)volumeIncrease;
- (void)volumeDecrease;
- (void)volumeMute;
- (void)star;
- (void)sendTrackToTwitter;

@end