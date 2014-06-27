//
//  ISHPermissionRequestNotificationsLocal.m
//  ISHPermissionKit
//
//  Created by Felix Lamouroux on 27.06.14.
//  Copyright (c) 2014 iosphere GmbH. All rights reserved.
//

#import "ISHPermissionRequestNotificationsLocal.h"

@interface ISHPermissionRequestNotificationsLocal ()
@property (strong) ISHPermissionRequestCompletionBlock completionBlock;
@end

@implementation ISHPermissionRequestNotificationsLocal

- (instancetype)init {
    self = [super init];
    if (self) {
        self.noticationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert
                                                                    categories:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (ISHPermissionState)permissionState {
    if (!NSClassFromString(@"UIUserNotificationSettings")) {
        return ISHPermissionStateAuthorized;
    }
    
    UIUserNotificationSettings *noticationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (!noticationSettings || (noticationSettings.types == UIUserNotificationTypeNone)) {
        return [self internalPermissionState];
    }
    
    // To be discussed: should types/categories differing from self.noticationSettings lead to denied state?
    return ISHPermissionStateAuthorized;
}

- (void)requestUserPermissionWithCompletionBlock:(ISHPermissionRequestCompletionBlock)completion {
    NSAssert(completion, @"requestUserPermissionWithCompletionBlock requires a completion block");
    NSAssert(self.noticationSettings, @"Requested notification settings should be set for request before requesting user permission");
    // ensure that the app delegate implements the didRegisterMethods:
    NSAssert([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:didRegisterUserNotificationSettings:)], @"AppDelegate must implement application:didRegisterUserNotificationSettings: and post notification ISHPermissionNotificationApplicationDidRegisterUserNotificationSettings");
    
    ISHPermissionState currentState = self.permissionState;
    if (!ISHPermissionStateAllowsUserPrompt(currentState)) {
        completion(self, currentState, nil);
        return;
    }
    
    // avoid asking again (system state does not correctly reflect if we asked already).
    [self setInternalPermissionState:ISHPermissionStateDontAsk];
    
    self.completionBlock = completion;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ISHPermissionNotificationApplicationDidRegisterUserNotificationSettings:)
                                                 name:ISHPermissionNotificationApplicationDidRegisterUserNotificationSettings
                                               object:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:self.noticationSettings];
}

- (void)ISHPermissionNotificationApplicationDidRegisterUserNotificationSettings:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.completionBlock) {
        self.completionBlock(self, self.permissionState, nil);
        self.completionBlock = nil;
    }
}

@end
