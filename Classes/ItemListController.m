//
//  ItemListController.m
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 2. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemListController.h"


@implementation ItemListController
@synthesize currentSection, doneItem, summaryLabel, selectedRow;

// TODO
// . Summary label의 lateral boundary를 property로
// . Category 추가
// . Done mode : 2011/2/10
// . define들을 하나의 header로 : done
// . 일부 method들은 Section, Item등 class로 이동 : section의 inactive method와 같이 debug 힘든 에러 발생 -> release of NSManagedObject 때문에
// . cell decoration -> 번호 붙이고 summary에 몇번까지인지 보여줌 : partially implemented, 2011/2/21

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	// self.summaryLabel = [[UILabel alloc] init];
	self.summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 340, 50)];
	self.summaryLabel.font = [UIFont systemFontOfSize:18];
	self.summaryLabel.backgroundColor = [UIColor grayColor]; 
	self.summaryLabel.alpha = 0.9;
	self.summaryLabel.textAlignment = UITextAlignmentRight;
	
	self.currentSection = [Section firstSection:self.moc];
	[self.currentSection addObserver:self forKeyPath:kManagedObjectNameKey options:NSKeyValueObservingOptionNew context:nil];
	self.selectedRow = -1;
	[self updateEntityList];
	self.navigationItem.title = [self.currentSection valueForKey:kManagedObjectNameKey];

	UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"섹션", @"이전", nil]];
	segmentControl.momentary = YES;
	segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentControl addTarget:self action:@selector(leftSegmentHandler:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *segmentButton = [[UIBarButtonItem alloc] initWithCustomView:segmentControl];
	self.navigationItem.leftBarButtonItem = segmentButton;
	[segmentButton release];
	[segmentControl release];
		
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	[self.tableView addGestureRecognizer:longPressRecognizer];
	[longPressRecognizer release];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ItemList";
    // UILabel *orderLabel, *nameLabel, *priceLabel;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		
    }

    // Configure the cell...
    NSManagedObject *mo = [self.entityList objectAtIndex:[indexPath row]];
	cell.textLabel.text = [mo valueForKey:kManagedObjectNameKey];
	NSInteger itemOrder = [[mo valueForKey:kManagedObjectOrderKey] intValue];
	// NSLog(@"%d %d", itemOrder, self.selectedRow);
	if (itemOrder == self.selectedRow) {
		cell.textLabel.textColor = [UIColor blueColor];
	} else {
		cell.textLabel.textColor = [UIColor blackColor];
	}
	NSDecimalNumber *price = [mo valueForKey:kManagedObjectPriceKey];
	if (price != [NSDecimalNumber notANumber]) 
		cell.detailTextLabel.text = [price stringValue];
	
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

#pragma mark -
#pragma mark custom functions

- (void)leftSegmentHandler:(id)sender {
	UISegmentedControl *button = (UISegmentedControl *)sender;
	
	switch ([button selectedSegmentIndex]) {
		case 0:
			[self chooseSection];
			break;
		case 1:
			NSLog(@"History");
			HistoryListController *historyController = [[HistoryListController alloc] initWithStyle:UITableViewStylePlain];
			// historyController.moc = self.moc;
			historyController.currentSection = self.currentSection;
			historyController.parent = self;
			[self.navigationController pushViewController:historyController animated:YES];
            [historyController release];
			break;
		default:
			NSLog(@"Unknown segment index at ListViewController.segmentHandler");
			break;
	}
}

// for selecting other section
- (void)chooseSection {
	EntityListController *sectionController = [[EntityListController alloc] initWithStyle:UITableViewStylePlain];
	sectionController.parent = self;
	sectionController.entityName = kSectionName;
	sectionController.moc = self.moc;
	[self.navigationController pushViewController:sectionController animated:YES];
    [sectionController release];
}

// 섹션 선택할때 현재 section에 대해 observe, section 이름이 변경되면 호출
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	Item *item = object;
	self.navigationItem.title = item.name;
}

// update item list according to a new section
- (void)handleSelectedObject:(NSManagedObject *)selectedObject {
	if (self.currentSection != selectedObject) {
		[self.currentSection removeObserver:self forKeyPath:kManagedObjectNameKey];
		self.currentSection = (Section *)selectedObject;
		[self.currentSection addObserver:self forKeyPath:kManagedObjectNameKey options:NSKeyValueObservingOptionNew context:nil];
		self.navigationItem.title = [selectedObject valueForKey:kManagedObjectNameKey];
		self.selectedRow = -1;
		[self updateEntityList];
		[self.tableView reloadData];
	} 
}

- (void)customSelectionHandlerWithRow:(NSUInteger)row {
	// NSLog(@"custom selection handler... selected row %d", row);
	NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil];
	if ((row != self.selectedRow) && (self.selectedRow >=0)) { // reload previously selected row also
		[indexPaths addObject:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
	}
	self.selectedRow = row;
	[self updateSummaryLabelToRow:row];
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:NO];
	[indexPaths release];
	// [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:NO];
}

- (void)updateSummaryLabelToRow:(NSInteger)row {
	BOOL hasNilObject;
	NSDecimalNumber *sum = [self sumOfItemsToRow:row nilInformation:&hasNilObject];
	NSString *summary;
	
	if ([sum floatValue] == 0.0) {
		summary = @"";
	} else if (hasNilObject) {
		summary = [NSString stringWithFormat:@"Total : %@ + alpha   ", sum];
	} else {
		summary = [NSString stringWithFormat:@"Total : %@   ", sum];
	} 
	self.summaryLabel.text = summary;
	if (([summary length] == 0) && (self.summaryLabel.hidden == NO)) {
		[UIView animateWithDuration:0.5 animations:^(void) {
			self.summaryLabel.alpha = 0;
		}];
		[self performSelector:@selector(hideSummaryLabel) withObject:nil afterDelay:0.5];
		// self.summaryLabel.hidden = YES;
	} else if (([summary length] > 0) && (self.summaryLabel.hidden == YES)) {
		self.summaryLabel.hidden = NO;
		[UIView animateWithDuration:0.5 animations:^(void) {
			self.summaryLabel.alpha = kSummaryLabelOpacity;
		}];
	}
	// NSLog(@"updating summary label... with setNeedsDisplay");
	// [self.tableView.tableFooterView setNeedsDisplay];
}

- (void)hideSummaryLabel {
	self.summaryLabel.hidden = YES;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return self.summaryLabel;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSInteger fromRow = [fromIndexPath row];
	NSInteger toRow = [toIndexPath row];

	if (fromRow == toRow)
		return;
	
	if (fromRow == self.selectedRow) {
		self.selectedRow = toRow;
	} else if (fromRow < self.selectedRow) {
		if (self.selectedRow <= toRow) {
			self.selectedRow = self.selectedRow - 1;
		} 			
	} else if (self.selectedRow >= toRow) {
		self.selectedRow = self.selectedRow + 1;
	}
	
	[super tableView:tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}

#pragma mark -
#pragma mark utility functions

- (void)updateEntityList {
	NSEntityDescription *itemEntity = [NSEntityDescription entityForName:kItemName inManagedObjectContext:self.moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:itemEntity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY section = %@ AND ANY order != NIL", self.currentSection];
	[request setPredicate:predicate];
	NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sd]];
	
	self.entityList = [self.moc executeFetchRequest:request error:nil];
	[sd release];
	[request release];
	
	// count가 0인 경우는 sumOfItems... method에서 handle
	if (self.selectedRow < 0) {
		[self updateSummaryLabelToRow:([self.entityList count]-1)];
	} else {
		[self updateSummaryLabelToRow:self.selectedRow];
	}
}

- (void)addNewEntity {
	ItemDetailController *addController = [[ItemDetailController alloc] initWithParent:self entityName:self.entityName inSection:self.currentSection];
	[self.navigationController pushViewController:addController animated:YES];
	[addController release];
}

- (void)editEntity:(NSManagedObject *)entity {
	ItemDetailController *editController = [[ItemDetailController alloc] initWithParent:self entityName:self.entityName inSection:self.currentSection];	
	editController.editObject = entity;
	[self.navigationController pushViewController:editController animated:YES];
	[editController release];		
}


- (NSDecimalNumber *)sumOfItemsToRow:(NSInteger)row nilInformation:(BOOL *)hasNilObject {
	NSDecimalNumber *sum = [NSDecimalNumber zero];
	NSDecimalNumber *price;
	Item *item;
	
	*hasNilObject = NO;
	if (row <0) {	// zero items
		return sum;
	}
	
	for (NSUInteger i=0; i<=row; i++) {
		item = (Item *)[self.entityList objectAtIndex:i];
		price = [item valueForKey:kManagedObjectPriceKey];
		if (price == nil) {
			*hasNilObject = YES;
		} else {
			sum = [sum decimalNumberByAdding:price];
		}
	}
	return sum;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
	if ((!self.editing) && (longPressRecognizer.state == UIGestureRecognizerStateBegan)) {
		NSIndexPath *index = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
		if (index && (index.row != NSNotFound) && (index.section != NSNotFound)) {
			self.doneItem = [self.entityList objectAtIndex:index.row];
			UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:kDoneSheetQuestion delegate:self cancelButtonTitle:kDoneSheetCancel destructiveButtonTitle:kDoneSheetDestruction otherButtonTitles:nil];
			UITabBar *tabBar = [[(ClueAssistantAppDelegate *)[[UIApplication sharedApplication] delegate] rootController] tabBar];
			[sheet showFromTabBar:tabBar];
			[sheet release];
			// self.doneItem = nil;
			// NSLog(@"returned from action sheet");
		}
	}
}

#pragma mark -
#pragma mark ActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [actionSheet destructiveButtonIndex]) {
		NSUInteger doneRow = [self.entityList indexOfObject:self.doneItem];
		if (doneRow != NSNotFound) {
			NSIndexPath *index = [NSIndexPath indexPathForRow:doneRow inSection:0];
			[self.doneItem markDone:self.moc];
			[self updateEntityList];
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationRight];
			// NSLog(@"Job done : row %u, %@, %@", doneRow, [self.doneItem valueForKey:@"name"], [self.doneItem valueForKey:@"price"]);
			 self.doneItem = nil;
		}
	}
}

#pragma mark -
#pragma mark memory related methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.summaryLabel = nil;
	self.selectedRow = -1;
	[self.currentSection removeObserver:self forKeyPath:kManagedObjectNameKey];
}


- (void)dealloc {
	[summaryLabel release];
	// [doneItem release];
	// [currentSection release];
    [super dealloc];
}


@end
