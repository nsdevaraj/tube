//
//  ViewController.h
//  Test5
//
//  Created by Devaraj NS on 28/01/13.
//  Copyright (c) 2013 Devaraj NS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionView.h"
@interface ViewController : UIViewController <SectionView>{
    UITableView *tableview;
    UITabBarItem *tabItem;
    NSMutableArray *subjectsArray;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView; 
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, retain) IBOutlet UITabBarItem *tabItem;

@end