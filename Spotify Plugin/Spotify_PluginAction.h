//
//  Spotify_PluginAction.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//

#import "SpotifyBridge.h"

@interface QSSpotify_PluginControlProvider : QSActionProvider <NSApplicationDelegate, NSSharingServiceDelegate, NSSharingServicePickerDelegate, NSTextViewDelegate>

@property SpotifyApplication *Spotify;


- (void)play;
- (void)pause;
- (void)togglePlayPause;
- (void)next;
- (void)previous;
- (void)volumeIncrease;
- (void)volumeDecrease;
- (void)volumeMute;
- (void)save;
- (void)sendTrackToTwitter;

@end

@interface QSSpotifyActionProvider : QSActionProvider

@property SpotifyApplication *Spotify;

- (QSObject *)playPlaylist:(QSObject *)dObject;
- (QSObject *)playTrack:(QSObject *)dObject;
- (QSObject *)addTrack:(QSObject *)dObject toPlaylist:(QSObject *)iObject;
- (QSObject *)search:(QSObject *)dObject;

@end