//
//  Spotify_PluginSource.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//

#import "Spotify_PluginSource.h"
#import "QSSpotifyUtil.h"

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
                          @"QSSpotifyStar"];
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

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    
    if (su.isPlaylistChanged) {
        su.playlistChanged = NO;
        return YES;
    }
    else {
        return NO;
    }
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
    NSLog(@"update");
    
    NSMutableArray *PlaylistsObjects = nil;
    
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    NSArray *playlists = [su playlists];
    
    if (playlists != nil) {
        PlaylistsObjects = [NSMutableArray arrayWithCapacity:20];
        
        for (NSDictionary *playlist in playlists) {
            NSString *name = [playlist valueForKey:@"name"];
            NSString *playlistID = [playlist valueForKey:@"id"];
            NSString *uri = [playlist valueForKey:@"uri"];
            NSString *url = [[playlist valueForKey:@"external_urls"] valueForKey:@"spotify"];
            NSString *trackNumber = [[[playlist valueForKey:@"tracks"] valueForKey:@"total"] stringValue];
            
            QSObject *newObject = [QSObject objectWithName:[name stringByAppendingString:@" Playlist"]];
            [newObject setLabel:name];
            [newObject setObject:uri forType:@"QSSpotifyPlaylistType"];
            [newObject setObject:url forType:@"QSURLType"];
            [newObject setIdentifier:playlistID];
            [newObject setDetails:[trackNumber stringByAppendingString:@" tracks"]];
            [newObject setIcon:[QSResourceManager imageNamed:@"￼￼/Applications/Spotify.app/Contents/Resources/local_files.icns"]];
            [newObject setPrimaryType:@"QSSpotifyPlaylistType"];
            
            [PlaylistsObjects addObject:newObject];
        }
    }
    

    
    return PlaylistsObjects;
}

- (void)setQuickIconForObject:(QSObject *)object {
    [object setIcon:[QSResourceManager imageNamed:@"￼￼/Applications/Spotify.app/Contents/Resources/local_files.icns"]];
}


@end