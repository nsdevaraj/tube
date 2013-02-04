//
//  WebController.h
//  Test5
//
//  Created by Devaraj NS on 29/01/13.
//  Copyright (c) 2013 Devaraj NS. All rights reserved.
//
 
#import <UIKit/UIKit.h>
@interface WebController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeBtn;
@property (retain, nonatomic) IBOutlet UIWebView *padWeb;
- (IBAction)homeBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewElement;

@end
