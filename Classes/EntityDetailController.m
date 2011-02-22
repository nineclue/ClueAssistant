//
//  EntityDetailController.m
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 30..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntityDetailController.h"


@implementation EntityDetailController
@synthesize editObject, moc, entityName, parent, entityChanged;

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

- (id)initWithParent:(UITableViewController *)parentController entityName:(NSString *)entityNameString {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) {
		self.parent = parentController;
		self.entityName = entityNameString;

		ClueAssistantAppDelegate *appDelegate = (ClueAssistantAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.moc = [appDelegate managedObjectContext];
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	/*
	 if (self.moc == nil) {
		ClueAssistantAppDelegate *appDelegate = (ClueAssistantAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.moc = [appDelegate managedObjectContext];
	}*/
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:kDoneString style:UIBarButtonItemStylePlain target:self action:@selector(saveItem)];
	self.navigationItem.rightBarButtonItem = button;
	
	if (self.editObject == nil) {
		self.title = kAddModeString;
		button.enabled = NO;
	} else {
		self.title = kEditModeString;
	}
	[button release];

	if (self.parent != nil) {
		UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:[self.parent.navigationItem title] style:UIBarButtonItemStylePlain target:self action:@selector(cancelItem)];
		// button = [[UIBarButtonItem alloc] initWithTitle:[self.parent title] style:UIBarButtonItemStylePlain target:self action:@selector(cancelItem)];
		self.navigationItem.leftBarButtonItem = button2;
		[button2 release];
	}
	self.entityChanged = NO;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	NSUInteger indices[] = {0,0};
	NSIndexPath *index = [[NSIndexPath alloc] initWithIndexes:indices length:2];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
	UITextField *nameField = (UITextField *)[cell viewWithTag:kTextFieldTag];
	[nameField becomeFirstResponder];
    [index release];
}

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
// called when save button pressed
// create or update object and call parent's updateList method
// return BOOL value is used at [self textFieldShouldReturn]
- (BOOL)saveItem {
	NSUInteger indices[] = {0,0};
	NSIndexPath *index = [[NSIndexPath alloc] initWithIndexes:indices length:2];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
	UITextField *nameField = (UITextField *)[cell viewWithTag:kTextFieldTag];
	NSString *trimmedName = [nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	[index release];
	
	if ([trimmedName length] == 0) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Empty Name" message:@"이름을 입력하셔야 합니다." delegate:nil cancelButtonTitle:@"네" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return NO;
	} else {
		if (self.editObject == nil) {
			self.editObject = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:moc];
			[self.editObject setValue:nil forKey:kManagedObjectOrderKey];
		}
		[self.editObject setValue:trimmedName forKey:kManagedObjectNameKey];

		// [nameField resignFirstResponder];

		/* this doesn't work as expected, after popView command viewControllers are empty
		NSArray *ancestors = self.navigationController.viewControllers;
		EntityListController *parent = (EntityListController *)[ancestors lastObject];
		*/
		
		[self.navigationController popViewControllerAnimated:YES];
		
		[self.parent updateList:self.editObject];
		return YES;
	}
}

- (void)cancelItem {
	if (self.entityChanged) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:kConfirmCancelMessage delegate:self cancelButtonTitle:kCancelCancelButtonMessage destructiveButtonTitle:kDoCancelButtonMessage otherButtonTitles:nil];
		UITabBar *tabBar = [[(ClueAssistantAppDelegate *)[[UIApplication sharedApplication] delegate] rootController] tabBar];
		[actionSheet showFromTabBar:tabBar];
		[actionSheet release];
	} else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void) flagChange {
	self.entityChanged = YES;
}

#pragma mark -
#pragma mark ActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [actionSheet cancelButtonIndex])
		[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"EntityEdit";
	UILabel *label;
    UITextField *name;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
	label.font = [UIFont boldSystemFontOfSize:16];
	label.text = @"이 름";
	label.textAlignment = UITextAlignmentRight;
	label.tag = kLabelTag;
	[cell.contentView addSubview:label];
	[label release];
	
	name = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
	name.clearsOnBeginEditing = NO;
	name.tag = kTextFieldTag;
	name.returnKeyType = UIReturnKeyDone;
	name.enablesReturnKeyAutomatically = YES;
	name.delegate = self;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flagChange) name:UITextFieldTextDidChangeNotification object:name];
	if (self.editObject != nil) {
		name.text = [editObject valueForKey:kManagedObjectNameKey];
	}
	[cell.contentView addSubview:name];
	[name release];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -
#pragma mark TextField delegate
// enable / disable save button, for name field only 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	UIBarButtonItem *button = self.navigationItem.rightBarButtonItem;
	NSUInteger textLength = [textField.text length];

	// deletion and deleted length equals text length
	if (([string length] == 0) && ((textLength - range.length) == 0)) {
		button.enabled = NO;
	} else {
		button.enabled = YES;
	}
	// NSLog(@"shouldeChangeCharacters... text : %d range : %d, %d replace : %@", textLength, range.location, range.length, string);
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return [self saveItem];
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
	// self.editObject = nil;
	self.moc = nil;
	// self.entityName = nil;
	// self.parent = nil;
}


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[parent release];
	[entityName release];
	[moc release];
	// [editObject release];
    [super dealloc];
}


@end

