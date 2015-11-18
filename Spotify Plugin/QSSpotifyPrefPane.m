//
//  QSSpotifyPrefPane.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-27.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import "QSSpotifyPrefPane.h"
#import "QSSpotifyUtil.h"
#import "QSSpotifyDefines.h"

@implementation QSSpotifyPrefPane

- (id)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(profileGet:)
                                                     name:UserProfileDidGetNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadFinished:)
                                                     name:WebViewProgressFinishedNotification
                                                   object:nil];

    }
    return self;
}

- (void)profileGet:(NSNotification *)note {
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    [self finishLoginWithUsername:su.displayName];
}

- (NSView *)loadMainView {
    NSView *view = [super loadMainView];
    [[QSSpotifyUtil sharedInstance] setPrefPane:self];
    [self updateUI];
    return view;
}

- (void)startAnimation {
    [_ind setHidden:NO];
    [_ind startAnimation:self];
}

- (void)endAnimation {
    [_ind stopAnimation:self];
    [_ind setHidden:YES];

}


- (IBAction)authenticate:(id)sender {
    if ([[_signInOutButton title]  isEqual: @"Sign In"]) {
        [self startAnimation];
        QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
        su.needUserID = YES;
        su.needPlaylists = YES;
        [self attemptLoginWithPrivate:[_privateCheckBox state]];
    }
    else {
        [self startAnimation];
        [[QSSpotifyUtil sharedInstance] signOut];
        [self finishLogout];
    }
}

- (IBAction)toggleNotification:(id)sender {
    NSInteger checkbox = [_notificationCheckBox state];
    [[NSUserDefaults standardUserDefaults] setInteger:checkbox forKey:@"allowNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)toggleTrackNotification:(id)sender {
    NSInteger checkbox = [_notificationCheckBox state];
    [[NSUserDefaults standardUserDefaults] setInteger:checkbox forKey:@"allowTrackNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)finishLoginWithUsername:(NSString *)username {
    [_signInOutButton setTitle:@"Sign Out"];
    [_username setStringValue:[NSString stringWithFormat:@"Signed in as: %@", username]];
    [self endAnimation];
    
    NSInteger checkbox = [_privateCheckBox state];
    [[NSUserDefaults standardUserDefaults] setInteger:checkbox forKey:@"allowPrivate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)finishLogout {
    [_signInOutButton setTitle:@"Sign In"];
    [_username setStringValue:@"Not signed in"];
    [self endAnimation];
}

- (void)updateUI {
    NSInteger privateCheckbox = [[NSUserDefaults standardUserDefaults] integerForKey:@"allowPrivate"];
    [_privateCheckBox setState:privateCheckbox];
    
    NSInteger notificationCheckbox = [[NSUserDefaults standardUserDefaults] integerForKey:@"allowNotification"];
    [_notificationCheckBox setState:notificationCheckbox];
    
    NSInteger trackNotificationCheckbox = [[NSUserDefaults standardUserDefaults] integerForKey:@"allowTrackNotification"];
    [_trackNotificationCheckBox setState:trackNotificationCheckbox];
    
    QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
    
    [self startAnimation];
    su.needUserID = YES;
    su.needPlaylists = YES;
    [su requestAccessTokenFromRefreshToken];
    
    if ([su.refreshToken compare:@"RefreshTokenPlaceholder"] == NSOrderedSame) {
        su.needUserID = NO;
        su.needPlaylists = NO;
        [self finishLogout];
    }
    //else {
        //NSLog(@"refresh token:%@", su.refreshToken);
    //}
}

#pragma mark -
#pragma mark Login Window

- (void)loadFinished:(NSNotification *)note {
    NSString *url = _web.mainFrame.dataSource.request.URL.absoluteString;
    
    if ([url length] > 26 && [[url substringToIndex:kRedirect.length] compare:kRedirect] == NSOrderedSame) {
        //[self finishAuthWithCallback:url];
        QSSpotifyUtil *su = [QSSpotifyUtil sharedInstance];
        
        [su finishedLoginAndAddCatalogWithCallback:url];
        
    }
}

-(BOOL)windowShouldClose:(id)sender {
    //[self signOut];
    return YES;
}

- (void)createLoginWindow {
    NSRect frame = NSMakeRect(100, 100, 1024, 768);
    _codeWindow  = [[NSWindow alloc] initWithContentRect:frame
                                               styleMask: NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];
    [_codeWindow setReleasedWhenClosed:NO];
    [_codeWindow setDelegate:self];
    [_codeWindow setBackgroundColor:[NSColor blueColor]];
    [_codeWindow setTitle:@"Authorization"];
    _web = [WebView new];
    [_codeWindow setContentView:_web];
    [_codeWindow makeKeyAndOrderFront:NSApp];
}

- (void)attemptLoginWithPrivate:(NSInteger)allowPrivate {
        NSString *scope;
        if (allowPrivate == NSOnState) {
            scope = @"playlist-modify-public user-library-read user-library-modify user-follow-modify playlist-read-private playlist-modify-private";
        }
        else {
            scope = @"playlist-modify-public user-library-read user-library-modify user-follow-modify";
        }
        
        [self createLoginWindow];
        
        NSDictionary *parameters = @{@"response_type": @"code",
                                     @"redirect_uri": kRedirect,
                                     @"client_id": kClientID,
                                     @"scope": scope};
        
        NSURLRequest *urlRequest = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:kAuthorization
                                                                                parameters:parameters
                                                                                     error:nil];
        [[_web mainFrame] loadRequest:urlRequest];
        
    
}

@end
