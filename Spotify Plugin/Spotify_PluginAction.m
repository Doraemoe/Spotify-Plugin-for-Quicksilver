//
//  Spotify_PluginAction.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//

#import "Spotify_PluginAction.h"

@implementation QSSpotify_PluginControlProvider

- (id)init
{
    if (self = [super init]) {
        Spotify = QSSpotify();
    }
    return self;
}


- (void)play
{
    if ([Spotify playerState] != SpotifyEPlSPlaying) {
        [Spotify play];
    }
}

- (void)pause
{
    if ([Spotify playerState] != SpotifyEPlSPaused) {
        [Spotify pause];
    }
}

- (void)togglePlayPause
{
    [Spotify playpause];
}

- (void)next
{
    [Spotify nextTrack];
}

- (void)previous
{
    [Spotify previousTrack];
}

- (void)volumeIncrease
{
    [Spotify setSoundVolume:[Spotify soundVolume] + 5];
}

- (void)volumeDecrease
{
    [Spotify setSoundVolume:[Spotify soundVolume] - 5];
}

- (void)volumeMute
{
    [Spotify setSoundVolume:0];
}
/*
- (void)copyTrackURLToClipboard
{
    NSString *url = [[Spotify currentTrack] spotifyUrl];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:url forType:NSStringPboardType];
}
*/
- (void)sendTrackToTwitter
{
    NSImage *albumImg = [[Spotify currentTrack] artwork];
    NSString *artist = [[Spotify currentTrack] artist];
    NSString *album = [[Spotify currentTrack] album];
    NSString *name = [[Spotify currentTrack] name];
    
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    NSString *shareString = [NSString stringWithFormat:@"#NowPlaying %@ - %@ by %@", name, album, artist];
    
    NSArray *shareItems = @[shareString, albumImg];
    
    service.delegate = self;
    if ([service canPerformWithItems:shareItems]) {
        [service performWithItems:shareItems];
    }
}
/*
- (void)openInBrowser
{
    NSString *urlString = [[Spotify currentTrack] spotifyUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    [[NSWorkspace sharedWorkspace] openURL:url];
}
*/
- (void)toggleRepeat
{
    [Spotify setRepeating:![Spotify repeatingEnabled]];
}

- (void)toggleShuffling
{

    [Spotify setShuffling:![Spotify shufflingEnabled]];
    
}

@end