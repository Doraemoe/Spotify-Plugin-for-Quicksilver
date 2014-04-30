//
//  QSSpotifyUtil.m
//  Spotify Plugin
//
//  Created by Jin Yifan on 14-4-28.
//  Copyright (c) 2014年 Jin Yifan. All rights reserved.
//

#import "QSSpotifyUtil.h"
#import "QSSpotifyPrefPane.h"
#include "appkey.c"

@implementation QSSpotifyUtil

@synthesize prefPane;

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
        NSError *error = nil;
        [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] userAgent:@"com.qsapp.spotify" loadingPolicy:SPAsyncLoadingManual error:&error];
        if(error != nil) {
            NSLog(@"CocoaLibSpotify init failed: %@", error);
            abort();
        }
        
        [[SPSession sharedSession] setDelegate:self];
    }
    return self;
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


#pragma mark -
#pragma mark Spotify login

- (void)attemptLoginWithCredential {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *usrName = [defaults valueForKey:@"spotifyUser"];
    
    
    if (usrName == nil) {
        
    }
    else {
        OSStatus status;
        void *passwordData = NULL;
        SecKeychainItemRef itemRef = NULL;
        UInt32 passwordDataLength = 0;
        char *usr = (char *)[usrName UTF8String];
        
        status = GetPasswordKeychain(&passwordData, &passwordDataLength, &itemRef, usr);
        if (status == noErr) {
            NSString *password = [[NSString alloc] initWithBytes:passwordData length:passwordDataLength encoding:NSUTF8StringEncoding];
            SecKeychainItemFreeContent(NULL, passwordData);
            
            [[SPSession sharedSession] attemptLoginWithUserName:usrName existingCredential:password];
            [prefPane setPseudoContext];
        }
        else if (status == errSecItemNotFound) {
            NSLog(@"error not found");
            SecKeychainItemFreeContent(NULL, passwordData);
        }
    }
    
}

- (void)attemptLoginWithName:(NSString *)name password:(NSString *)pass {
    
    if ([name length] > 0 && [pass length] > 0) {
        [[SPSession sharedSession] attemptLoginWithUserName:name password:pass];
        
    }
    else {
        [prefPane setWarningMessage:@"Please enter username and password" withColor:[NSColor redColor]];
        [prefPane endAnimation];
        NSBeep();
    }
}

-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
    NSLog(@"saving Credentials");
    OSStatus status;
    
    char *usr = (char *)[userName UTF8String];
    void *password = (char *)[credential UTF8String];
    
    size_t passwordLength = strlen(password);
    assert(passwordLength <= 0xffffffff);
    
    void *passwordData = NULL;
    SecKeychainItemRef itemRef = NULL;
    UInt32 passwordDataLength = 0;
    
    status = GetPasswordKeychain(&passwordData, &passwordDataLength, &itemRef, usr);
    
    if (status == noErr) {
        //already in keychain
        status = SecKeychainItemFreeContent(NULL, passwordData);
    }
    else if (status == errSecItemNotFound) {
        status = StorePasswordKeychain(password, (UInt32)passwordLength, usr);
    }
    
}

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    [prefPane finishLogin];
    NSLog(@"success");
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
    //delete saved credentials if exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *usrName = [defaults valueForKey:@"spotifyUser"];
    
    if (usrName == nil) {
        
    }
    else {
        OSStatus status;
        char *usr = (char *)[usrName UTF8String];
        status = DelPasswordKeychain(usr);
    }
    
    [prefPane setWarningMessage:[error localizedDescription] withColor:[NSColor redColor]];
    [prefPane endAnimation];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error {
    [prefPane setWarningMessage:[error localizedDescription] withColor:[NSColor redColor]];
    [prefPane endAnimation];
}

-(void)sessionDidLogOut:(SPSession *)aSession {
    NSLog(@"log out");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *usrName = [defaults valueForKey:@"spotifyUser"];
    
    if (usrName == nil) {
        
    }
    else {
        OSStatus status;
        char *usr = (char *)[usrName UTF8String];
        status = DelPasswordKeychain(usr);
    }
}

-(void)signOut {
    [[SPSession sharedSession] logout:^{
    }];
}

-(int)getLoginState {
    return [[SPSession sharedSession] connectionState];
}
@end
