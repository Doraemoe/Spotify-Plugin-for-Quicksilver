//
//  Spotify_PluginAction.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//

#import "Spotify_PluginAction.h"
#import "QSSpotifyUtil.h"
#import "QSSpotifyDefines.h"

@implementation QSSpotify_PluginControlProvider

- (id)init
{
    if (self = [super init]) {
        _Spotify = QSSpotify();
    }
    return self;
}

#pragma mark -
#pragma mark Spotify control

- (void)play
{
    if ([_Spotify playerState] != SpotifyEPlSPlaying) {
        [_Spotify play];
    }
}

- (void)pause
{
    if ([_Spotify playerState] != SpotifyEPlSPaused) {
        [_Spotify pause];
    }
}

- (void)togglePlayPause
{
    [_Spotify playpause];
}

- (void)next
{
    [_Spotify nextTrack];
}

- (void)previous
{
    [_Spotify previousTrack];
}

- (void)volumeIncrease
{
    [_Spotify setSoundVolume:[_Spotify soundVolume] + 5];
}

- (void)volumeDecrease
{
    [_Spotify setSoundVolume:[_Spotify soundVolume] - 5];
}

- (void)volumeMute
{
    [_Spotify setSoundVolume:0];
}

- (void)star
{
    SpotifyTrack *track = [_Spotify currentTrack];
    NSString *uri = [track spotifyUrl];
    QSSpotifyUtil* ut = [QSSpotifyUtil sharedInstance];
    [ut starSongWithURI:uri];
    
}

- (void)sendTrackToTwitter
{
    NSImage *albumImg = [[_Spotify currentTrack] artwork];
    NSString *artist = [[_Spotify currentTrack] artist];
    NSString *album = [[_Spotify currentTrack] album];
    NSString *name = [[_Spotify currentTrack] name];
    
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    NSString *shareString = [NSString stringWithFormat:@"#NowPlaying %@ - %@ by %@", name, album, artist];
    
    NSArray *shareItems = @[shareString, albumImg];
    
    service.delegate = self;
    if ([service canPerformWithItems:shareItems]) {
        [service performWithItems:shareItems];
    }
}
@end

@implementation QSSpotifyActionProvider

- (id)init
{
    if (self = [super init]) {
        _Spotify = QSSpotify();
    }
    return self;
}

- (QSObject *)playPlaylist:(QSObject *)dObject {
    NSString *uri = [dObject objectForType:QSSpotifyPlaylistType];
    NSLog(@"%@", uri);
    return nil;
}


@end