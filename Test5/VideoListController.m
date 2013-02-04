//
//  VideoListController.m
//  Test5
//
//  Created by Devaraj NS on 01/02/13.
//  Copyright (c) 2013 Devaraj NS. All rights reserved.
//

#import "VideoListController.h"
#import "AppDelegate.h"
#import "VideoItem.h"
#import "CellItemView.h"
@implementation VideoListController
@synthesize backBtn;
@synthesize videosArray;
@synthesize navBarItem;
- (IBAction)backBtnPressed:(id)sender { 
    [self performSegueWithIdentifier:@"backtoHome" sender:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.videolist.sectionHeaderHeight = 45;
    self.videolist.sectionFooterHeight = 0; 
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    navBarItem.title = appDelegate.videoTitle;
    videosArray = appDelegate.videosArray;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videosArray count];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     VideoItem *vi= [videosArray objectAtIndex: indexPath.row];
     NSArray *listItems = [vi.embedcode componentsSeparatedByString:@"v="];
     listItems = [[listItems objectAtIndex:[listItems count] -1 ]componentsSeparatedByString:@"&"];
     appDelegate.videocode = [listItems objectAtIndex:0];
    [self performSegueWithIdentifier:@"web" sender:self];
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StatusCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[CellItemView alloc] init];        
    }
    UIImage *defaultImage=nil;
    
    VideoItem *vi= [videosArray objectAtIndex: indexPath.row];
    defaultImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:vi.thumburl]]];    
    [cell.imageView setImage:defaultImage];
    cell.textLabel.text = vi.name;
    return cell;
}
@end