//
//  Spotify_PluginSource.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//

#import "Spotify_PluginSource.h"
#import "QSSpotifyUtil.h"
#import "QSSpotifyDefines.h"

@implementation QSSpotifyControlSource

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
	// rescan only if the indexDate is prior to the last launch
	NSDate *launched = [[NSRunningApplication currentApplication] launchDate];
	if (launched) {
		return ([launched compare:indexDate] == NSOrderedAscending);
	} else {
		// Quicksilver wasn't launched by LaunchServices - date unknown - rescan to be safe
		return NO;
	}
}

- (BOOL)entryCanBeIndexed:(NSDictionary *)theEntry
{
    // make sure controls are rescanned on every launch, not read from disk
    return NO;
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry
{
	NSMutableArray *controlObjects = [NSMutableArray arrayWithCapacity:1];
	QSCommand *command = nil;
	NSDictionary *commandDict = nil;
	QSAction *newObject = nil;
	NSString *actionID = nil;
	NSDictionary *actionDict = nil;
	// create catalog objects using info specified in the plist (under QSCommands)
	NSArray *controls = @[@"QSSpotifyPlay",
                          @"QSSpotifyNextSong",
                          @"QSSpotifySendToTwitter",
                          @"QSSpotifyPreviousSong",
                          @"QSSpotifyIncreaseVolume",
                          @"QSSpotifyMute",
                          @"QSSpotifyPause",
                          @"QSSpotifyDecreaseVolume",
                          @"QSSpotifyPlayPause",
                          @"QSSpotifySave",
                          @"QSSpotifyFollowArtist"];
	for (NSString *control in controls) {
		command = [QSCommand commandWithIdentifier:control];
		if (command) {
			commandDict = [command commandDict];
			actionID = commandDict[@"directID"];
			actionDict = commandDict[@"directArchive"][@"data"][QSActionType];
			if (actionDict) {
				newObject = [QSAction actionWithDictionary:actionDict identifier:actionID];
				[controlObjects addObject:newObject];
			}
		}
	}
	return controlObjects;
}
@end

@implementation QSSpotifyObjectSource

- (id)init
{
    if (self = [super init]) {
        _Spotify = QSSpotify();
    }
    return self;
}

- (BOOL)entryCanBeIndexed:(NSDictionary *)theEntry
{
    return NO;
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    su.needPlaylists = YES;
    su.needUserID = YES;
    [su requestAccessTokenFromRefreshToken];
    
    return NO;
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
    //NSLog(@"update");
    
    _PlaylistsObjects = nil;
    
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    NSArray *playlists = [su playlists];
    
    if (playlists != nil) {
        _PlaylistsObjects = [NSMutableArray arrayWithCapacity:su.totalPlaylistsNumber];
        
        for (NSDictionary *playlist in playlists) {
            
            NSString *name = [playlist valueForKey:@"name"];
            NSString *playlistID = [playlist valueForKey:@"id"];
            if ([name isEqualToString:@"Starred"]) {
                playlistID = @"0000000000000000000000";
            }
            NSString *uri = [playlist valueForKey:@"uri"];
            NSString *url = [[playlist valueForKey:@"external_urls"] valueForKey:@"spotify"];
            NSString *tracksNumber = [[[playlist valueForKey:@"tracks"] valueForKey:@"total"] stringValue];
            NSString *tracksLocation = [[playlist valueForKey:@"tracks"] valueForKey:@"href"];
            
            QSObject *newObject = [QSObject objectWithString:[name stringByAppendingString:@" Playlist"]];
            [newObject setLabel:name];
            [newObject setObject:uri forType:QSSpotifyPlaylistType];
            [newObject setPrimaryType:QSSpotifyPlaylistType];
            [newObject setObject:url forType:QSURLType];
            [newObject setIdentifier:[@"SpotifyPlaylist" stringByAppendingString:playlistID]];
            [newObject setDetails:[tracksNumber stringByAppendingString:@" tracks"]];
            [newObject setObject:tracksLocation forMeta:@"tracksEndpoint"];
            [newObject setObject:tracksNumber forMeta:@"tracksNumber"];
            
            [_PlaylistsObjects addObject:newObject];
        }
    }
    else {
        su.needPlaylists = YES;
        su.needUserID = YES;
        [su requestAccessTokenFromRefreshToken];
    }
    
    return _PlaylistsObjects;
}

- (void)setQuickIconForObject:(QSObject *)object {
    [object setIcon:[QSResourceManager imageNamed:@"￼￼/Applications/Spotify.app/Contents/Resources/local_files.icns"]];
}

- (BOOL)loadIconForObject:(QSObject *)object {
    if ([[object identifier] isEqualToString:@"SpotifyCurrentTrackProxy"]) {
        [object setIcon:[object objectForMeta:@"coverImage"]];
        return YES;
    }
    
    if ([[object primaryType] isEqualToString:QSSpotifyTrackType]) {
        NSURL *coverURL = [NSURL URLWithString:[object objectForMeta:@"coverImage"]];
        NSImage *cover = [[NSImage alloc] initWithContentsOfURL:coverURL];
        [object setIcon:cover];
        return YES;
    }
    
    return NO;
}

- (BOOL)loadChildrenForObject:(QSObject *)object {
    if ([[object primaryType] isEqualToString:QSSpotifyPlaylistType]) {
        QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
        NSDictionary *tracksInPlaylist = [su tracksInPlaylist];
        
        if (tracksInPlaylist != nil) {
            NSArray *children = [tracksInPlaylist objectForKey:[object label]];
            [object setChildren:children];
        }
        return YES;
    }
    else if ([[object primaryType] isEqualToString:QSFilePathType]) {
        [object setChildren:_PlaylistsObjects];
        return YES;
    }
    return NO;
}

- (BOOL)objectHasChildren:(QSObject *)object {
    if ([object containsType:QSSpotifyTrackType]) {
        return NO;
    }
    else {
        return YES;
    }
}

- (QSObject *)resolveProxyObject:(QSProxyObject *)proxy {
    QSObject *resolved = nil;
    
    //NSLog(@"resolving proxy object");
    //NSLog(@"%@", [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"]);
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.spotify.client"] count] == 0) {
        return nil;
    }
    
    
    if ([_Spotify playerState] == SpotifyEPlSPlaying || [_Spotify playerState] == SpotifyEPlSPaused) {
        SpotifyTrack *track = [_Spotify currentTrack];
        NSString *name = [track name];
        NSString *trackID = [track id];
        NSString *uri = [track spotifyUrl];
        NSString *artist = [track artist];
        NSImage *cover = [track artwork];
        //NSLog(@"name: %@, trackID: %@, uri %@, artist %@, cover %@", name, trackID, uri, artist, cover);
        
        if ((NSNull *)name != [NSNull null] && (NSNull *)trackID != [NSNull null] && (NSNull *)uri != [NSNull null] && (NSNull *)artist != [NSNull null]) {
            resolved = [QSObject objectWithString:name];
            [resolved setLabel:name];
            [resolved setObject:uri forType:QSSpotifyTrackType];
            [resolved setPrimaryType:QSSpotifyTrackType];
            [resolved setIdentifier:@"SpotifyCurrentTrackProxy"];
            [resolved setDetails:artist];
            [resolved setObject:cover forMeta:@"coverImage"];
        }
    }
    return resolved;
}

- (NSArray *)typesForProxyObject:(QSProxyObject *)proxy {
    NSString *ident = [proxy identifier];
    if ([ident isEqualToString:@"SpotifyCurrentTrackProxy"]) {
        return [NSArray arrayWithObject:QSSpotifyTrackType];
    }
    return nil;
}

@end