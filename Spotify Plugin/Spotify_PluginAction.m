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

- (void)save
{
    SpotifyTrack *track = [_Spotify currentTrack];
    NSString *uri = [track spotifyUrl];
    NSArray *uriArray = [uri componentsSeparatedByString:@":"];
    QSSpotifyUtil* ut = [QSSpotifyUtil sharedInstance];
    [ut saveSongWithID:uriArray[2]];
    
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

- (QSObject *)playItem:(QSObject *)dObject {
    if ([dObject containsType:QSSpotifyPlaylistType]) {
        [self playPlaylist:dObject];
    }
    else if ([dObject containsType:QSSpotifyTrackType]) {
        [self playTrack:dObject];
    }
    
    return nil;
}

- (QSObject *)playPlaylist:(QSObject *)dObject {
   // NSString *uri = [dObject objectForType:QSSpotifyPlaylistType];
    //NSLog(@"name: %@, label: %@, identifier %@, icon %@, primaryType %@, primaryObject %@", dObject.name, dObject.label, dObject.identifier, dObject.icon, dObject.primaryType, dObject.primaryObject);
    //NSLog(@"endpoint %@", [dObject objectForMeta:@"tracksEndpoint"]);
    NSArray *children = [dObject children];
    NSString *playlistURI = [dObject objectForType:QSSpotifyPlaylistType];
    NSString *trackURI = [children[0] objectForType:QSSpotifyTrackType];
    
    [_Spotify playTrack:trackURI inContext:playlistURI];
    return nil;
}

- (QSObject *)playTrack:(QSObject *)dObject {
    //NSLog(@"a wild track has appeared");
    NSString *uri = [dObject objectForType:QSSpotifyTrackType];
    //NSLog(@"%@", uri);
    [_Spotify playTrack:uri inContext:nil];
    return nil;
}


@end