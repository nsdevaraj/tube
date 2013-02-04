//
//  TableController.h
//  Test5
//
//  Created by Devaraj NS on 29/01/13.
//  Copyright (c) 2013 Devaraj NS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableController : UITableViewController{
    UITableView *tableview;
    NSMutableArray *subjectsArray;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger openSectionIndex;
@end