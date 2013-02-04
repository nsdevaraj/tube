//
//  WebController.m
//  Test5
//
//  Created by Devaraj NS on 29/01/13.
//  Copyright (c) 2013 Devaraj NS. All rights reserved.
//

#import "WebController.h"
#import "AppDelegate.h"
@implementation WebController

@synthesize padWeb;
@synthesize backBtn;
@synthesize viewElement;
 
- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self embedYouTube: CGRectMake(0, 0, appDelegate.window.bounds.size.width, appDelegate.window.bounds.size.height-70) :appDelegate.videocode];
}

- (void)embedYouTube :(CGRect)frame :(NSString*) urlcode{
    NSString *url=@"http://youtube.com/embed/";
    url = [url stringByAppendingString:urlcode];
    NSString *videoHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <head>\
                           <style type=\"text/css\">\
                           iframe {position:absolute; top:20%%; margin-top:-130px;}\
                           body {background-color:#000; margin:0;}\
                           </style>\
                           </head>\
                           <body>\
                           <iframe width=\"100%%\" height=\"400px\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
                           </body>\
                           </html>", url];
    padWeb = [[UIWebView alloc] initWithFrame:frame];
    [padWeb loadHTMLString:videoHTML baseURL:nil];
    [self.view insertSubview:padWeb aboveSubview:viewElement];
}

//set autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (IBAction)homeBtnPressed:(id)sender {
    [padWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com"]]];
    [self performSegueWithIdentifier:@"backHome" sender:self];
}

- (IBAction)backBtnPressed:(id)sender {
    [padWeb loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.youtube.com"]]];
    [self performSegueWithIdentifier:@"backList" sender:self];
} 
@end
