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
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    
    if ([_Spotify playerState] != SpotifyEPlSPlaying) {
        [_Spotify play];
    }
}

- (void)pause
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    if ([_Spotify playerState] != SpotifyEPlSPaused) {
        [_Spotify pause];
    }
}

- (void)togglePlayPause
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    [_Spotify playpause];
}

- (void)next
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    [_Spotify nextTrack];
}

- (void)previous
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    [_Spotify previousTrack];
}

- (void)volumeIncrease
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    if ([_Spotify soundVolume] > 95) {
        [_Spotify setSoundVolume:100];
    }
    else {
        [_Spotify setSoundVolume:[_Spotify soundVolume] + 5];

    }
}

- (void)volumeDecrease
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    if ([_Spotify soundVolume] < 5) {
        [_Spotify setSoundVolume:0];
    }
    else {
        [_Spotify setSoundVolume:[_Spotify soundVolume] - 5];
    }
}

- (void)volumeMute
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    [_Spotify setSoundVolume:0];
}

- (void)save
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    SpotifyTrack *track = [_Spotify currentTrack];
    NSString *uri = [track spotifyUrl];
    NSArray *uriArray = [uri componentsSeparatedByString:@":"];
    QSSpotifyUtil* ut = [QSSpotifyUtil sharedInstance];
    [ut saveSongWithID:uriArray[2]];
    
}

- (void)followArtist
{
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    SpotifyTrack *track = [_Spotify currentTrack];
    NSString *uri = [track spotifyUrl];
    NSArray *uriArray = [uri componentsSeparatedByString:@":"];
    QSSpotifyUtil* ut = [QSSpotifyUtil sharedInstance];
    [ut followArtistWithID:uriArray[2]];
    
}

- (void)sendTrackToTwitter
{
    NSArray *shareItems;
    
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return;
    }
    NSImage *albumImg = [[_Spotify currentTrack] artwork];
    NSString *artist = [[_Spotify currentTrack] artist];
    NSString *album = [[_Spotify currentTrack] album];
    NSString *name = [[_Spotify currentTrack] name];
    
    NSSharingService * service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    NSString *shareString = [NSString stringWithFormat:@"#NowPlaying %@ - %@ by %@", name, album, artist];
    
    if (albumImg == nil) {
        //NSLog(@"why image is nil?");
        shareItems = @[shareString];
    }
    else {
        shareItems = @[shareString, albumImg];
    }
    
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
    if ([[dObject primaryType] isEqualToString:QSSpotifyPlaylistType]) {
        [self playPlaylist:dObject];
    }
    else if ([[dObject primaryType] isEqualToString:QSSpotifyTrackType]) {
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
    
    //NSLog(@"playlist URI: %@, track URI: %@", playlistURI, trackURI);
    
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

- (QSObject *)addTrack:(QSObject *)dObject toPlaylist:(QSObject *)iObject {
    if ([[iObject label] caseInsensitiveCompare:@"starred"] == NSOrderedSame) {
        return nil;
    }
    NSArray *uri = [[iObject objectForType:QSSpotifyPlaylistType] componentsSeparatedByString:@":"];
    NSString *playlistID = uri[4];
    
    NSString *trackURI = [dObject objectForType:QSSpotifyTrackType];
    //NSLog(@"id %@, uri %@", playlistID, trackURI);
    
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    [su addTrack:trackURI toPlaylist:playlistID];
    
    return nil;
}

- (QSObject *)addPlayingTrackToPlaylist:(QSObject *)dObject {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return nil;
    }
    
    if ([[dObject label] caseInsensitiveCompare:@"starred"] == NSOrderedSame) {
        return nil;
    }
    
    NSArray *uri = [[dObject objectForType:QSSpotifyPlaylistType] componentsSeparatedByString:@":"];
    NSString *playlistID = uri[4];
    
    SpotifyTrack *track = [_Spotify currentTrack];
    NSString *trackUri = [track spotifyUrl];
    
    //NSString *trackURI = [dObject objectForType:QSSpotifyTrackType];
    //NSLog(@"id %@, uri %@", playlistID, trackURI);
    
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    [su addTrack:trackUri toPlaylist:playlistID];
    
    return nil;
}


- (QSObject *)search:(QSObject *)dObject {
    NSMutableString *query = [NSMutableString stringWithString:[dObject stringValue]];
    [query replaceOccurrencesOfString:@" " withString:@"%20" options:NSLiteralSearch range:NSMakeRange(0, [query length])];
    NSString *urlString = [@"https://play.spotify.com/search/" stringByAppendingString:query];
    NSURL *url = [NSURL URLWithString:urlString];
    [[NSWorkspace sharedWorkspace] openURL:url];
    
    return nil;
}

@end