//
//  WebViewController.m
//  MeetMeUp
//
//  Created by Iván Mervich on 8/4/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;

@property UIActivityIndicatorView *activityIndicatorView;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
	self.activityIndicatorView.center = self.view.center;

	NSURL *url = [NSURL URLWithString:self.urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:request];
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self.activityIndicatorView startAnimating];
	[self.view addSubview:self.activityIndicatorView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	self.backButton.enabled = webView.canGoBack;
	self.forwardButton.enabled = webView.canGoForward;
	[self removeActivityIndicatorView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self removeActivityIndicatorView];
}

#pragma mark IBActions

- (IBAction)onBackButtonPressed:(UIButton *)sender
{
	if (self.webView.canGoBack) {
		[self.webView goBack];
	}
}

- (IBAction)onForwardButtonPressed:(UIButton *)sender
{
	if (self.webView.canGoForward) {
		[self.webView goForward];
	}
}

#pragma mark Helper methods

- (void)removeActivityIndicatorView
{
	[self.activityIndicatorView stopAnimating];
	[self.activityIndicatorView removeFromSuperview];
}

@end
