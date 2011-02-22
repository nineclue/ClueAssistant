//
//  EntityListController.m
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntityListController.h"


@implementation EntityListController
@synthesize entityName, parent, entityList, moc;

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
	
	if (self.entityName == nil) {
		NSLog(@"Nil entity name in EntityListController viewDidLoad");
		self.entityName = kDefaultListName;
	} else {
		[self updateEntityList];
	}
	
	if (!self.navigationItem.title) 
		self.navigationItem.title = self.entityName;
	
	UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:kSegmentedControlEditString, kSegmentedControlAddString, nil]];
	segmentControl.momentary = YES;
	segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentControl addTarget:self action:@selector(segmentHandler:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *segmentButton = [[UIBarButtonItem alloc] initWithCustomView:segmentControl];
	self.navigationItem.rightBarButtonItem = segmentButton;
	[segmentButton release];
	[segmentControl release];
}

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

// toggles edit mode or call detail controller
- (void)segmentHandler:(id)sender {
	UISegmentedControl *button = (UISegmentedControl *)sender;
	
	switch ([button selectedSegmentIndex]) {
		case kEditButtonIndex:
			if (self.editing) {
				[button setTitle:kSegmentedControlEditString forSegmentAtIndex:kEditButtonIndex];
				[self setEditing:NO animated:YES];
			} else {
				[button setTitle:kSegmentedControlDoneString forSegmentAtIndex:kEditButtonIndex];
				[self setEditing:YES animated:YES];
			}
			break;
		case kAddButtonIndex:
			[self addNewEntity];
			break;
		default:
			NSLog(@"Unknown segment index at ListViewController.segmentHandler");
			break;
	}
}

- (void)addNewEntity {
	EntityDetailController *addController = [[EntityDetailController alloc] initWithParent:self entityName:self.entityName];
	[self.navigationController pushViewController:addController animated:YES];
	[addController release];
}

- (void)editEntity:(NSManagedObject *)entity {
	EntityDetailController *editController = [[EntityDetailController alloc] initWithParent:self entityName:self.entityName];
	editController.editObject = entity;
	[self.navigationController pushViewController:editController animated:YES];
	[editController release];		
}

// call back from detail controller
// insert a new row or update row
- (void)updateList:(NSManagedObject *)editedData {
	NSNumber *num = [editedData valueForKey:@"order"];
	NSError *error;
	UITableView *table = [self tableView];
	
	if (num == nil) {
		NSLog(@"New item");
		NSInteger newOrder = [self.entityList count];
		[editedData setValue:[NSNumber numberWithInt:newOrder] forKey:kManagedObjectOrderKey];
		if (![moc save:&error]) {
			NSLog(@"Error %@, %@", error, [error userInfo]);
		}
		[self updateEntityList];
		
		NSIndexPath *newIndex = [NSIndexPath indexPathForRow:newOrder inSection:0];
		NSIndexPath *lastIndex = [[table indexPathsForVisibleRows] lastObject];
		[table beginUpdates];
		[table insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndex]  withRowAnimation:UITableViewRowAnimationFade];
		[table endUpdates];
		if (([newIndex row] - [lastIndex row]) > 1) {
			NSLog(@"Scroll to bottom");
			[table scrollToRowAtIndexPath:newIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		}
	} else {
		NSLog(@"Edit item : %@", num);
		if (![moc save:&error]) {
			NSLog(@"Error %@, %@", error, [error userInfo]);
		}
		[self updateEntityList];
		NSIndexPath *currentIndex = [NSIndexPath indexPathForRow:[num intValue] inSection:0];
		/*
		UITableViewCell *cell = [table cellForRowAtIndexPath:currentIndex];
		cell.textLabel.text = [editedData valueForKey:kManagedObjectNameKey];
		 */
		[table beginUpdates];
		[table reloadRowsAtIndexPaths:[NSArray arrayWithObject:currentIndex]  withRowAnimation:UITableViewRowAnimationFade];
		[table endUpdates];		
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.entityList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"EntityList";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSManagedObject *mo = [self.entityList objectAtIndex:[indexPath row]];
	cell.textLabel.text = [mo valueForKey:kManagedObjectNameKey];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSUInteger deleteRow = [indexPath row];
		NSUInteger lastRow = [self.entityList count]-1;
		NSManagedObject *deleteObject = [self.entityList objectAtIndex:deleteRow];
		NSError *error;
		
		NSLog(@"Delete data %@", [deleteObject valueForKey:kManagedObjectNameKey]);
		[self.moc deleteObject:deleteObject];
		if (deleteRow != lastRow) 
			[self shiftDownFrom:(deleteRow+1) to:lastRow];
		if (![moc save:&error]) {
			NSLog(@"Error %@, %@", error, [error userInfo]);
		}
		[self updateEntityList];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];
	
	if (fromRow == toRow)
		return;

	NSLog(@"Move from %d to %d", fromRow, toRow);

	NSManagedObject *mover = [self.entityList objectAtIndex:fromRow];
	[mover setValue:[NSNumber numberWithInt:toRow] forKey:kManagedObjectOrderKey];
	
	if (fromRow < toRow) {
		[self shiftDownFrom:(fromRow+1) to:toRow];
	} else {
		[self shiftUpFrom:toRow to:(fromRow-1)];
	}
	NSError *error;
	if (![moc save:&error]) {
		NSLog(@"Error %@, %@", error, [error userInfo]);
	}
	[self updateEntityList];	
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((self.parent != nil) && ([self.parent respondsToSelector:@selector(handleSelectedObject:)])) {
		NSManagedObject *selectedObject = [self.entityList objectAtIndex:[indexPath row]];
		[self.navigationController popViewControllerAnimated:YES];
		[self.parent handleSelectedObject:selectedObject];
	} else if ([self respondsToSelector:@selector(customSelectionHandlerWithRow:)]) {
			[self customSelectionHandlerWithRow:[indexPath row]];
		// NSManagedObject *selectedObject = [self.entityList objectAtIndex:[indexPath row]];
		// NSLog(@"I'm alone... Name : %@ Order :%@", [selectedObject valueForKey:kManagedObjectNameKey], [selectedObject valueForKey:kManagedObjectOrderKey]);
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// call detail controller for editing
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *selectedObject = [self.entityList objectAtIndex:[indexPath row]];
	[self editEntity:selectedObject];
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
	// self.entityName = nil;
	self.entityList = nil;
	self.moc = nil;
	// self.parent = nil;
}


- (void)dealloc {
	[parent release];
	[entityName release];
	[entityList release];
	[moc release];
    [super dealloc];
}

#pragma mark -
#pragma mark Utility Functions

- (NSArray *)list:(NSString *)entity {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *ed = [NSEntityDescription entityForName:entity inManagedObjectContext:moc];
	[request setEntity:ed];
	NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sd]];
	
	NSError *error;
	NSArray *result = [moc executeFetchRequest:request error:&error];
	if (result == nil) {
		NSLog(@"Error!!!");
	}
	[request release];
	[sd release];
	return result;
}

- (NSUInteger)listCount:(NSString *)entity {
	return [[self list:entity] count];
}

- (void)updateEntityList {
	self.entityList = [self list:[self entityName]];
}

/*
- (NSArray *)list:(NSString *)entityName withPredicate:(NSPredicate *)predicate {
	// TODO
}
*/

- (void)shiftUpFrom:(NSUInteger)fromRow to:(NSUInteger)toRow {
	NSManagedObject *mover;
	NSUInteger currentOrder;
	
	NSLog(@"Shifting Up from:%d to %d", fromRow, toRow);
	for (NSUInteger i=fromRow; i<=toRow; i++) {
		mover = [self.entityList objectAtIndex:i];
		currentOrder = [[mover valueForKey:kManagedObjectOrderKey] intValue];
		[mover setValue:[NSNumber numberWithInt:(currentOrder+1)] forKey:kManagedObjectOrderKey];
	}
}

- (void)shiftDownFrom:(NSUInteger)fromRow to:(NSUInteger)toRow {
	NSManagedObject *mover;
	NSUInteger currentOrder;
	
	NSLog(@"Shifting Down from:%d to %d", fromRow, toRow);
	for (NSUInteger i=fromRow; i<=toRow; i++) {
		mover = [self.entityList objectAtIndex:i];
		currentOrder = [[mover valueForKey:kManagedObjectOrderKey] intValue];
		[mover setValue:[NSNumber numberWithInt:(currentOrder-1)] forKey:kManagedObjectOrderKey];
	}
}
@end

