//
//  ISHPermissionRequestPhotoCamera.m
//  ISHPermissionKit
//
//  Created by Felix Lamouroux on 27.06.14.
//  Copyright (c) 2014 iosphere GmbH. All rights reserved.
//

#import "ISHPermissionRequestPhotoCamera.h"
@import AVFoundation;

@implementation ISHPermissionRequestPhotoCamera
- (ISHPermissionState)permissionState {    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            return ISHPermissionStateGranted;

        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            return ISHPermissionStateDenied;
            
        case AVAuthorizationStatusNotDetermined:
            return [self internalPermissionState];
    }

}

- (void)requestUserPermissionWithCompletionBlock:(ISHPermissionRequestCompletionBlock)completion {
    NSAssert(completion, @"requestUserPermissionWithCompletionBlock requires a completion block");
    ISHPermissionState currentState = self.permissionState;
    if (!ISHPermissionStateAllowsUserPrompt(currentState)) {
        completion(self, currentState, nil);
        return;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(self, granted, nil);
        });
    }];
}
@end