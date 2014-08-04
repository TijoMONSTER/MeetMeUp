//
//  WebViewController.m
//  MeetMeUp
//
//  Created by Iván Mervich on 8/4/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSURL *url = [NSURL URLWithString:self.urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:request];
}

@end
