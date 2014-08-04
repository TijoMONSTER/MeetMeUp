//
//  DetailViewController.m
//  MeetMeUp
//
//  Created by Iván Mervich on 8/4/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rsvpCountsLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostingGroupInfoLabel;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.eventNameLabel.text = self.event[@"name"];
	self.rsvpCountsLabel.text = [NSString stringWithFormat:@"%@", self.event[@"yes_rsvp_count"]];

	NSDictionary *hostingGroup = self.event[@"group"];
	self.hostingGroupInfoLabel.text = hostingGroup[@"name"];

	self.eventDescriptionTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
	self.eventDescriptionTextView.layer.borderWidth = 1.0f;
	self.eventDescriptionTextView.text = self.event[@"description"];

	self.urlLabel.text = self.event[@"event_url"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	WebViewController *webVC = (WebViewController *)segue.destinationViewController;
	webVC.urlString = self.event[@"event_url"];
}

@end
