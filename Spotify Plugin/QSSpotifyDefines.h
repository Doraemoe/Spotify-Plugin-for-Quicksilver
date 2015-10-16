//
//  QSSpotifyDefines.h
//  Spotify Plugin
//
//  Created by Jin Yifan on 30/12/2014.
//  Copyright (c) 2014 Jin Yifan. All rights reserved.
//

#import "QSSpotifySecret.h"

#ifndef Spotify_Plugin_QSSpotifyDefines_h
#define Spotify_Plugin_QSSpotifyDefines_h


#define kRedirect @"https://tuidao.me/callback"
#define kToken @"https://accounts.spotify.com/api/token"
#define kAuthorization @"https://accounts.spotify.com/authorize"
#define kCurrectUserProfile @"https://api.spotify.com/v1/me"
#define kUserPlaylistsWildcard @"https://api.spotify.com/v1/users/USERID/playlists"
#define kSaveTrackForMe @"https://api.spotify.com/v1/me/tracks?ids=TRACKID"
#define kSaveTrackForPlaylist @"https://api.spotify.com/v1/users/USERID/playlists/PLAYLISTID/tracks?uris=URI"
#define kTrackInfo @"https://api.spotify.com/v1/tracks/TRACKID"
#define kFollowArtist @"https://api.spotify.com/v1/me/following"

#define QSSpotifyPlaylistType @"com.spotify.playlist"
#define QSSpotifyTrackType @"com.spotify.track"

#define PlaylistItemsAddedJobFinishedNotification @"PlaylistItemsAddedJobFinishedNotification"
#define UserProfileDidGetNotification @"UserProfileDidGetNotification"
#define AccessTokenDidGetNotification @"AccessTokenDidGetNotification"
#define TrackChangeNotification @"QSSpotifyTrackChangedEvent"

#define kAccessTokenPlaceholder @"AccessTokenPlaceholder"
#define kRefreshTokenPlaceholder @"RefreshTokenPlaceholder"
#define kDisplayNamePlaceholder @"NamePlaceholder"
#define kTrackIDPlaceholder @"trackIDPlaceholder"

#define kTrackURIPlaceholder @"trackURIPlaceholder"
#define kPlaylistIDPlaceholder @"playlistIDPlaceholder"

#endif
