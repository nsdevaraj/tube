//
//  VideoListController.h
//  Test5
//
//  Created by Devaraj NS on 01/02/13.
//  Copyright (c) 2013 Devaraj NS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoListController : UIViewController{ 
    NSMutableArray *vidArray; 
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
- (IBAction)backBtnPressed:(id)sender;
@property (retain, nonatomic) IBOutlet UITableView *videolist;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarItem;
@property (retain, nonatomic) NSMutableArray *videosArray;
@end
