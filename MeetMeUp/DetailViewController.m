//
//  DetailViewController.m
//  MeetMeUp
//
//  Created by Iván Mervich on 8/4/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewController.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rsvpCountsLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostingGroupInfoLabel;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;

@property NSArray *comments;

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

	// get comments
	NSString *urlString = [NSString stringWithFormat:@"http://api.meetup.com/2/event_comments?event_id=%@&order=time&desc=desc&offset=0&format=json&key=351723317853a106e26501915763d41", self.event[@"id"]];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[NSURLConnection sendAsynchronousRequest:urlRequest
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

							   if (connectionError == nil) {
								   NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
								   self.comments = decodedJSON[@"results"];
								   [self.commentsTableView reloadData];
								   NSLog(@"event id %@", self.event[@"id"]);

								   self.commentsTableView.userInteractionEnabled = YES;
							   } else {
								   NSLog(@"Error getting comments %@", [connectionError localizedDescription]);
							   }
						   }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
	NSDictionary *comment = self.comments[indexPath.row];

	cell.textLabel.text = comment[@"comment"];

	NSString *epoch = comment[@"time"];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[epoch doubleValue] / 1000];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", comment[@"member_name"], [dateFormatter stringFromDate:date]];

	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	NSDictionary *comment = self.comments[indexPath.row];

	NSString *groupID = comment[@"group_id"];
	NSString *memberID = comment[@"member_id"];

	// get profile url
	NSString *urlString = [NSString stringWithFormat:@"https://api.meetup.com/2/profile/%@/%@?&sign=true&key=351723317853a106e26501915763d41", groupID, memberID];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[NSURLConnection sendAsynchronousRequest:urlRequest
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

							   if (connectionError == nil) {
								   NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
								   [self performSegueWithIdentifier:@"showUserProfileSegue" sender:decodedJSON[@"profile_url"]];
							   } else {
								   NSLog(@"Error getting user profile %@", [connectionError localizedDescription]);
							   }
						   }];
}

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	WebViewController *webVC = (WebViewController *)segue.destinationViewController;

	if ([segue.identifier isEqualToString:@"showEventWebPageSegue"]) {
		webVC.urlString = self.event[@"event_url"];
	}
	else if ([segue.identifier isEqualToString:@"showUserProfileSegue"]) {
		webVC.urlString = sender;
	}
}

#pragma mark IBActions

- (IBAction)unwindFromWebView:(UIStoryboardSegue *)segue
{
}

@end
