//
//  HistoryListController.m
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 2. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryListController.h"


@implementation HistoryListController
@synthesize moc, currentSection, historyList, historyKeys, modeControl, copyItem, parent;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	if (self.moc == nil) {
		ClueAssistantAppDelegate *appDelegate = (ClueAssistantAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.moc = [appDelegate managedObjectContext];
	}
	self.historyKeys = [[NSArray alloc] initWithObjects:kManagedObjectNameCountKey, kManagedObjectDoneDateKey, kManagedObjectNameKey, nil];

	self.navigationItem.title = @"History";
	self.modeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"빈도순", @"최근", @"이름", nil]];
	self.modeControl.segmentedControlStyle = UISegmentedControlStyleBar;
	self.modeControl.selectedSegmentIndex = kHistorySortKeyFrequency;
	[self.modeControl addTarget:self action:@selector(segmentHandler:) forControlEvents:UIControlEventValueChanged];
	[self updateHistoryList:kHistorySortKeyFrequency];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark custom functions
- (void)updateHistoryList:(NSUInteger)mode {
	static BOOL historyOrders[] = {YES, NO, YES};

	/*
	NSEntityDescription *itemEntity = [NSEntityDescription entityForName:kItemName inManagedObjectContext:self.moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:itemEntity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY section = %@ AND doneDate != NIL", self.currentSection];
	[request setPredicate:predicate];
	NSSortDescriptor *sd;
	if (mode == kHistorySortKeyDoneDate) {
		sd = [[NSSortDescriptor alloc] initWithKey:kManagedObjectDoneDateKey ascending:NO];
	} else {
		sd = [[NSSortDescriptor alloc] initWithKey:kManagedObjectNameKey ascending:YES];
	}
	[request setSortDescriptors:[NSArray arrayWithObject:sd]];
	self.historyList = [self.moc executeFetchRequest:request error:nil];
	[sd release];
	[request release];
	*/
	self.historyList = [self.currentSection inactiveItems:self.moc orderBy:[self.historyKeys objectAtIndex:mode] ascending:historyOrders[mode]];
	[self.tableView reloadData];
}

- (void)segmentHandler:(id)sender {
	[self updateHistoryList:[self.modeControl selectedSegmentIndex]];
}

- (void)updateList:(NSManagedObject *)editedData {
	NSError *error;
	
	if (![self.moc save:&error]) {
		NSLog(@"Error %@, %@", error, [error userInfo]);
	}
	[self updateHistoryList:[self.modeControl selectedSegmentIndex]];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.historyList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"HistoryListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	Item *item = (Item *)[self.historyList objectAtIndex:[indexPath row]];
    cell.textLabel.text = item.name;
	cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:item.doneDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	self.copyItem = [self.historyList objectAtIndex:[indexPath row]];
	// NSLog(@"Copy or not? : %@", item.name);	

	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:kCopySheetQuestion, self.copyItem.name] delegate:self cancelButtonTitle:kCopySheetCancel destructiveButtonTitle:kCopySheetDestruction otherButtonTitles:nil];
	UITabBar *tabBar = [[(ClueAssistantAppDelegate *)[[UIApplication sharedApplication] delegate] rootController] tabBar];
	[sheet showFromTabBar:tabBar];
	[sheet release];
}

#pragma mark -
#pragma mark ActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [actionSheet destructiveButtonIndex]) {
		NSLog(@"Copy %@", self.copyItem.name);
		Item *newItem = [NSEntityDescription insertNewObjectForEntityForName:kItemName inManagedObjectContext:self.moc];
		newItem.name = self.copyItem.name;
		newItem.price = self.copyItem.price;
		newItem.creationDate = [NSDate date];
		newItem.section = self.currentSection;
		newItem.order = nil;
		self.copyItem = nil;
		[self.navigationController popViewControllerAnimated:YES];
		[self.parent updateList:newItem];		
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ItemDetailController *detailController = [[ItemDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	detailController.parent = self;
	detailController.moc = self.moc;
	detailController.editObject = [self.historyList objectAtIndex:[indexPath row]];
	detailController.currentSection = self.currentSection;
	
	[self.navigationController pushViewController:detailController animated:YES];
    [detailController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 33.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return self.modeControl;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.moc = nil;
	self.historyList = nil;
	self.historyKeys = nil;
	self.modeControl = nil;
	self.copyItem = nil;
}


- (void)dealloc {
	[copyItem release];
	[moc release];
	[historyList release];
	[historyKeys release];
	[modeControl release];
    [super dealloc];
}


@end
