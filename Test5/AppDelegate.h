//
//  AppDelegate.h
//  Test5
//
//  Created by Devaraj NS on 28/01/13.
//  Copyright (c) 2013 Devaraj NS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
       NSMutableArray *videosArray;
       NSString *videocode;
        NSString *videoTitle;
}
@property (retain, nonatomic) NSMutableArray *videosArray;
@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) NSString *videocode;
@property (retain, nonatomic) NSString *videoTitle;
@end
