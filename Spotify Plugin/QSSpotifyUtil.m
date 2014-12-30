//
//  QSSpotifyUtil.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-28.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import "QSSpotifyUtil.h"
#import "QSSpotifyPrefPane.h"

NSString *kClientID = @"eb2dca7a77924a878c2c8cb910bf5713";
NSString *kClientSecret = @"";
NSString *kRedirect = @"http://tuidao.me/callback";
NSString *kToken = @"https://accounts.spotify.com/api/token";
NSString *kAuthorization = @"https://accounts.spotify.com/authorize";
NSString *kCurrectUserProfile = @"https://api.spotify.com/v1/me";
NSString *kUserPlaylistsWildcard = @"https://api.spotify.com/v1/users/USERID/playlists";

@implementation QSSpotifyUtil

+ (void)initialize {
    [QSSpotifyUtil sharedInstance];
}

+ (QSSpotifyUtil *)sharedInstance {
    static QSSpotifyUtil *su = nil;
    static dispatch_once_t once_token;
    
    dispatch_once(&once_token, ^{
        su = [[QSSpotifyUtil alloc] init];
    });
    return su;
}

- (id)init
{
    if (self = [super init]) {
        _accessToken = @"AccessTokenPlaceholder";
        _refreshToken = @"RefreshTokenPlaceholder";
        _displayName = @"NamePlaceholder";
        _tokenStartTime = 0;
        _tokenExpiresIn = 0;
        _needPlaylists = NO;
        _needUserID = NO;
        _playlistChanged = NO;
        _totalPlaylistsNumber = 0;
        _oldPlaylists = nil;
        _playlists = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadStart:)
                                                     name:WebViewProgressStartedNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playlistsAdded:)
                                                     name:@"PlaylistItemsAddedJobFinishedNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(profileGet:)
                                                     name:@"UserProfileDidGetNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenGet:)
                                                     name:@"AccessTokenDidGetNotification"
                                                   object:nil];

        
    }
    return self;
}

#pragma mark -
#pragma mark notification

- (void)playlistsAdded:(NSNotification *)note {
    if (_playlists.count == _totalPlaylistsNumber) {
        if (_oldPlaylists == nil) {
            NSLog(@"hard refrsh");
            _oldPlaylists = [NSSet setWithArray:_playlists];
            [[NSNotificationCenter defaultCenter] postNotificationName:QSCatalogSourceInvalidated object:@"QSSpotifyObjectSource"];
        }
        else {
            NSSet *newPlaylistSet = [NSSet setWithArray:_playlists];
            if (![_oldPlaylists isEqual:newPlaylistSet]) {
                NSLog(@"hard refrsh");
                _oldPlaylists = [NSSet setWithArray:_playlists];
                [[NSNotificationCenter defaultCenter] postNotificationName:QSCatalogSourceInvalidated object:@"QSSpotifyObjectSource"];
            }
        }
    }

}

- (void)loadStart:(NSNotification *)note {
    NSString *url = _web.mainFrame.provisionalDataSource.request.URL.absoluteString;
    
    if ([url length] > 26 && [[url substringToIndex:kRedirect.length] compare:kRedirect] == NSOrderedSame) {
        [self finishAuthWithCallback:url];
    }
}

- (void)profileGet:(NSNotification *)note {

}

- (void)tokenGet:(NSNotification *)note {

}

#pragma mark -
#pragma mark auth

- (void)attemptLogin {
    [self createLoginWindow];

    NSDictionary *parameters = @{@"response_type": @"code",
                                 @"redirect_uri": kRedirect,
                                 @"client_id": kClientID,};
    
    NSURLRequest *urlRequest = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                             URLString:kAuthorization
                                                                            parameters:parameters
                                                                                 error:nil];
    
    [[_web mainFrame] loadRequest:urlRequest];

}

- (void)finishAuthWithCallback:(NSString *)callback {
    
    [_codeWindow close];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *clientIDandSecretString = [NSString stringWithFormat:@"%@:%@", kClientID, kClientSecret];
    NSString *encodedIDandSec = [NSString stringWithFormat:@"Basic %@", base64enc(clientIDandSecretString)];
    
    [manager.requestSerializer setValue:encodedIDandSec forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"grant_type": @"authorization_code",
                                 @"code": [callback substringFromIndex:31],
                                 @"redirect_uri": kRedirect
                                 };

    
    [manager POST:kToken
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, NSDictionary *tokenData) {
              
              _accessToken = [tokenData valueForKey:@"access_token"];
              _refreshToken = [tokenData valueForKey:@"refresh_token"];
              _tokenExpiresIn = [[tokenData valueForKey:@"expires_in"] integerValue];
              _tokenStartTime = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue];
              [self storeRefreshToken];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"AccessTokenDidGetNotification" object:nil];
              
              if (_needUserID) {
                  _needUserID = NO;
                  [self accessUserProfile];
              }
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
}

- (void)requestAccessTokenFromRefreshToken {
    
    NSInteger currentTime = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue];

    if (currentTime - _tokenStartTime < _tokenExpiresIn - 10) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AccessTokenDidGetNotification" object:nil];
        
        if (_needUserID) {
            _needUserID = NO;
            [self accessUserProfile];
        }
        
        return;
    }
    
    if ([_refreshToken compare:@"RefreshTokenPlaceholder"] == NSOrderedSame) {
        _refreshToken = [self getRefreshToken];
    }
    
    if ([_refreshToken compare:@"RefreshTokenPlaceholder"] == NSOrderedSame) {
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *clientIDandSecretString = [NSString stringWithFormat:@"%@:%@", kClientID, kClientSecret];
    NSString *encodedIDandSec = [NSString stringWithFormat:@"Basic %@", base64enc(clientIDandSecretString)];
    
    [manager.requestSerializer setValue:encodedIDandSec forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"grant_type": @"refresh_token",
                                 @"refresh_token": _refreshToken
                                 };
    
    [manager POST:kToken
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, NSDictionary *tokenData) {
              _accessToken = [tokenData valueForKey:@"access_token"];
              _tokenExpiresIn = [[tokenData valueForKey:@"expires_in"] integerValue];
              _tokenStartTime = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] integerValue];
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"AccessTokenDidGetNotification" object:nil];
              
              if (_needUserID) {
                  _needUserID = NO;
                  [self accessUserProfile];
              }
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
}

- (void)createLoginWindow {
    NSRect frame = NSMakeRect(100, 100, 640, 480);
    _codeWindow  = [[NSWindow alloc] initWithContentRect:frame
                                               styleMask: NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];
    [_codeWindow setBackgroundColor:[NSColor blueColor]];
    [_codeWindow setTitle:@"Authorization"];
    _web = [WebView new];
    [_codeWindow setContentView:_web];
    [_codeWindow makeKeyAndOrderFront:NSApp];
}

- (void)signOut {
    _accessToken = @"AccessTokenPlaceholder";
    _refreshToken = @"RefreshTokenPlaceholder";
    _displayName = @"NamePlaceholder";
    _tokenStartTime = 0;
    _tokenExpiresIn = 0;
    _needPlaylists = NO;
    _needUserID = NO;
    _playlistChanged = NO;
    
    OSStatus status;
    char *usr = (char *)[@"Spotify" UTF8String];
    status = DelPasswordKeychain(usr);
    
    [_prefPane finishLogout];
}

#pragma mark -
#pragma mark function

- (void)accessUserProfile {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *accessHeader = [NSString stringWithFormat:@"Bearer %@", _accessToken];
    [manager.requestSerializer setValue:accessHeader forHTTPHeaderField:@"Authorization"];
    
    [manager GET:kCurrectUserProfile
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, NSDictionary *userProfile) {
             NSLog(@"access profile");
             _userID = [userProfile valueForKey:@"id"];
             _displayName = [userProfile valueForKey:@"display_name"];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"UserProfileDidGetNotification" object:nil];
             
             if (_needPlaylists) {
                 _needPlaylists = NO;
                 [self getPlaylists];
             }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)getPlaylistsWithOffset:(NSString *)offset limit:(NSString *)limit manager:(AFHTTPRequestOperationManager *)manager {
    
    NSString *url = [kUserPlaylistsWildcard stringByReplacingOccurrencesOfString:@"USERID" withString:_userID];
    
    NSDictionary *parameters = @{@"offset": offset,
                                 @"limit": limit,
                                 };
    
    
    [manager GET:url
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, NSDictionary *playlistData) {
             NSLog(@"limit: %@, offset: %@", [playlistData valueForKey:@"limit"], [playlistData valueForKey:@"offset"]);
             
             [_playlists addObjectsFromArray:[playlistData valueForKey:@"items"]];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistItemsAddedJobFinishedNotification" object:nil];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
    
}

- (void)getPlaylists {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *accessHeader = [NSString stringWithFormat:@"Bearer %@", _accessToken];
    [manager.requestSerializer setValue:accessHeader forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [kUserPlaylistsWildcard stringByReplacingOccurrencesOfString:@"USERID" withString:_userID];
    
    NSDictionary *parameters = @{@"offset": @"0",
                                 @"limit": @"50",
                                 };
    
    
    [manager GET:url
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, NSDictionary *playlistData) {
             
             NSLog(@"total: %@", [playlistData valueForKey:@"total"]);
             NSLog(@"limit: %@, offset: %@", [playlistData valueForKey:@"limit"], [playlistData valueForKey:@"offset"]);
             
             _totalPlaylistsNumber = [[playlistData valueForKey:@"total"] integerValue];
             
             _playlists = [[NSMutableArray alloc] initWithCapacity:_totalPlaylistsNumber];
             
             [_playlists addObjectsFromArray:[playlistData valueForKey:@"items"]];
             
             NSInteger totalLeft = _totalPlaylistsNumber - 50;
             int offset = 50;
             
             while (totalLeft > 0) {
                 [self getPlaylistsWithOffset:[NSString stringWithFormat:@"%d", offset] limit:@"50" manager:manager];
                 totalLeft -= 50;
                 offset += 50;
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistItemsAddedJobFinishedNotification" object:nil];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}



- (void)starSongWithURI:(NSString *) URI {

}

#pragma mark -
#pragma mark keychain

//Call SecKeychainAddGenericPassword to add a new password to the keychain:
OSStatus StorePasswordKeychain (void* password, UInt32 passwordLength, char *acctName)
{
    OSStatus status;
    status = SecKeychainAddGenericPassword (
                                            NULL,            // default keychain
                                            11,              // length of service name
                                            "SpotifyAuth",    // service name
                                            (UInt32)strlen(acctName),              // length of account name
                                            acctName,    // account name
                                            passwordLength,  // length of password
                                            password,        // pointer to password data
                                            NULL             // the item reference
                                            );
    return (status);
}

//Call SecKeychainFindGenericPassword to get a password from the keychain:
OSStatus GetPasswordKeychain (void **passwordData, UInt32 *passwordLength,
                              SecKeychainItemRef *itemRef, char *acctName)
{
    OSStatus status1 ;
    
    
    status1 = SecKeychainFindGenericPassword (
                                              NULL,           // default keychain
                                              11,             // length of service name
                                              "SpotifyAuth",   // service name
                                              (UInt32)strlen(acctName),             // length of account name
                                              acctName,   // account name
                                              passwordLength,  // length of password
                                              passwordData,   // pointer to password data
                                              itemRef         // the item reference
                                              );
    return (status1);
}

OSStatus DelPasswordKeychain (char *acctName) {
    OSStatus status;

    void *passwordData = NULL;
    SecKeychainItemRef itemRef = NULL;
    UInt32 passwordDataLength = 0;
    
    status = GetPasswordKeychain(&passwordData, &passwordDataLength, &itemRef, acctName);
    
    if (status == noErr) {
        SecKeychainItemFreeContent(NULL, passwordData);
        status = SecKeychainItemDelete(itemRef);
        
    }
    else if (status == errSecItemNotFound) {
        //safe
        SecKeychainItemFreeContent(NULL, passwordData);
    }
    
    return status;
}

- (void)storeRefreshToken {
    NSLog(@"saving Token");
    OSStatus status;
    
    char *usr = (char *)[@"Spotify" UTF8String];
    void *password = (char *)[_refreshToken UTF8String];
    
    size_t passwordLength = strlen(password);
    assert(passwordLength <= 0xffffffff);
    
    void *passwordData = NULL;
    SecKeychainItemRef itemRef = NULL;
    UInt32 passwordDataLength = 0;
    
    
    status = GetPasswordKeychain(&passwordData, &passwordDataLength, &itemRef, usr);
    
    if (status == noErr) {
        //already in keychain
        status = DelPasswordKeychain(usr);
        status = StorePasswordKeychain(password, (UInt32)passwordLength, usr);
    }
    else if (status == errSecItemNotFound) {
        status = StorePasswordKeychain(password, (UInt32)passwordLength, usr);
    }
    
}

- (NSString *)getRefreshToken {
    NSString *refreshToken = @"RefreshTokenPlaceholder";
    OSStatus status;
    void *passwordData = NULL;
    SecKeychainItemRef itemRef = NULL;
    UInt32 passwordDataLength = 0;
    char *usr = (char *)[@"Spotify" UTF8String];
    
    status = GetPasswordKeychain(&passwordData, &passwordDataLength, &itemRef, usr);
    if (status == noErr) {
        refreshToken = [[NSString alloc] initWithBytes:passwordData
                                                      length:passwordDataLength
                                                    encoding:NSUTF8StringEncoding];
        SecKeychainItemFreeContent(NULL, passwordData);
    }
    else if (status == errSecItemNotFound) {
        //NSLog(@"error not found");
        SecKeychainItemFreeContent(NULL, passwordData);
    }
    return refreshToken;
}

#pragma mark -
#pragma mark base64encode

static NSData *base64helper(NSData *input, SecTransformRef transform)
{
    NSData *output = nil;
    
    if (!transform)
        return nil;
    
    if (SecTransformSetAttribute(transform, kSecTransformInputAttributeName, (__bridge CFTypeRef)(input), NULL))
        output = (NSData *)CFBridgingRelease(SecTransformExecute(transform, NULL));
    
    CFRelease(transform);
    
    return output;
}

NSString *base64enc(NSString *originalString)
{
    NSData *data = [NSData dataWithBytes:[originalString UTF8String] length:originalString.length];
    
    SecTransformRef transform = SecEncodeTransformCreate(kSecBase64Encoding, NULL);
    
    return [[NSString alloc] initWithData:base64helper(data, transform) encoding:NSASCIIStringEncoding];
}

NSData *base64dec(NSString *input)
{
    SecTransformRef transform = SecDecodeTransformCreate(kSecBase64Encoding, NULL);
    
    return base64helper([input dataUsingEncoding:NSASCIIStringEncoding], transform);
}

@end
