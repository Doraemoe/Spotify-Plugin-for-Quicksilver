//
//  Spotify_PluginSource.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 13-7-28.
//

#import "Spotify_PluginSource.h"

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

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry
{
	NSMutableArray *controlObjects = [NSMutableArray arrayWithCapacity:1];
	QSCommand *command = nil;
	NSDictionary *commandDict = nil;
	QSAction *newObject = nil;
	NSString *actionID = nil;
	NSDictionary *actionDict = nil;
	// create catalog objects using info specified in the plist (under QSCommands)
	NSArray *controls = @[@"QSSpotifyPlay", @"QSSpotifyNextSong", @"QSSpotifySendToTwitter", @"QSSpotifyPreviousSong", @"QSSpotifyIncreaseVolume", @"QSSpotifyMute", @"QSSpotifyPause", @"QSSpotifyDecreaseVolume", @"QSSpotifyPlayPause"];
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