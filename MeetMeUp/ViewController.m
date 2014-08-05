//
//  ViewController.m
//  MeetMeUp
//
//  Created by Iván Mervich on 8/4/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

@interface ViewController () <UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property NSArray *events;
@property UIActivityIndicatorView *activityIndicatorView;

@property NSMutableDictionary *eventsThumbImages;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.eventsThumbImages = [NSMutableDictionary dictionary];
	[self loadSearchResultsWithKeyword:self.searchTextField.text];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.events count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
	NSDictionary *event = self.events[indexPath.row];
	NSDictionary *venue = event[@"venue"];

	cell.textLabel.text = event[@"name"];
	cell.detailTextLabel.text = venue[@"address_1"];

	NSString *eventId = event[@"id"];
	NSDictionary *hostingGroup = event[@"group"];
	NSDictionary *hostingGroupPhoto = hostingGroup[@"group_photo"];

	if (hostingGroupPhoto) {
		NSString *thumbImageURLString = hostingGroupPhoto[@"thumb_link"];

		// load image
		if (!self.eventsThumbImages[eventId]) {
			// set placeholder
			cell.imageView.image = [self imagePlaceHolder];

			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{

				NSURL *imageURL = [NSURL URLWithString:thumbImageURLString];
				NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
				UIImage *thumbImage = [UIImage imageWithData:imageData];

				dispatch_async(dispatch_get_main_queue(), ^{
						self.eventsThumbImages[eventId] = thumbImage;
						cell.imageView.image = thumbImage;
						[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				});
			});
		} else {
			cell.imageView.image = self.eventsThumbImages[eventId];
		}
	} else {
		cell.imageView.image = [self imagePlaceHolder];
	}

	return cell;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];

	if ([textField.text length] > 0) {
		[self loadSearchResultsWithKeyword:self.searchTextField.text];
	}
	return YES;
}

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showEventDetailsSegue"]) {

		DetailViewController *detailVC = (DetailViewController *)segue.destinationViewController;
		NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForSelectedRow];
		detailVC.event = self.events[selectedCellIndexPath.row];

		[self.tableView deselectRowAtIndexPath:selectedCellIndexPath animated:NO];
	}
}

#pragma mark Helper methods

- (void)loadSearchResultsWithKeyword:(NSString *)keyword
{
	//show activity indicator
	self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.activityIndicatorView.center = self.view.center;
	[self.activityIndicatorView startAnimating];
	[self.view addSubview:self.activityIndicatorView];

	NSString *urlString = [NSString stringWithFormat:@"https://api.meetup.com/2/open_events.json?zip=60604&text=%@&text_format=plain&fields=group_photo&time=,1w&key=351723317853a106e26501915763d41", keyword];

	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

		if (connectionError == nil) {
			NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			self.events = decodedJSON[@"results"];
			[self.tableView reloadData];

			self.tableView.userInteractionEnabled = YES;
			NSLog(@"Huzzah!");
		} else {
			NSLog(@"Error %@", [connectionError localizedDescription]);
		}

		[self.activityIndicatorView stopAnimating];
		[self.activityIndicatorView removeFromSuperview];
	}];
}

- (UIImage *)imagePlaceHolder
{
	return [UIImage imageNamed:@"event_placeholder"];
}

@end
