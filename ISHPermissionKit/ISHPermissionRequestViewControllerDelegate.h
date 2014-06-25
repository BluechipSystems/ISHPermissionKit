//
//  ISHPermissionRequestViewControllerDelegate.h
//  ISHPermissionKit
//
//  Created by Felix Lamouroux on 26.06.14.
//  Copyright (c) 2014 iosphere GmbH. All rights reserved.
//

#import "ISHPermissionRequest.h"
@class ISHPermissionRequestViewController;

@protocol ISHPermissionRequestViewControllerDelegate <NSObject>
- (void)permissionRequestViewController:(ISHPermissionRequestViewController *)vc didCompleteWithState:(ISHPermissionState)state;
@end