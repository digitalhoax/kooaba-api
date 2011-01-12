//
//  KooabaQueryAppAppDelegate.h
//  KooabaQueryApp
//
//  Created by Joachim Fornallaz on 12.01.11.
//  Copyright 2011 kooaba AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KooabaQueryAppViewController;

@interface KooabaQueryAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    KooabaQueryAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet KooabaQueryAppViewController *viewController;

@end

