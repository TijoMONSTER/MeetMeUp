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

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.searchTextField.delegate = self;
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

	NSString *urlString = [NSString stringWithFormat:@"https://api.meetup.com/2/open_events.json?zip=60604&text=%@&text_format=plain&time=,1w&key=351723317853a106e26501915763d41", keyword];
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

		if (connectionError == nil) {
			NSDictionary *decodedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			self.events = decodedJSON[@"results"];
			[self.tableView reloadData];
			NSLog(@"Huzzah!");
		} else {
			NSLog(@"Error %@", [connectionError localizedDescription]);
		}

		[self.activityIndicatorView stopAnimating];
		[self.activityIndicatorView removeFromSuperview];
	}];
}

@end
