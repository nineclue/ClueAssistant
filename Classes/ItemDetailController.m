//
//  ItemDetailController.m
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 2. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemDetailController.h"


@implementation ItemDetailController
@synthesize currentSection;

- (id)initWithParent:(UITableViewController *)parentController entityName:(NSString *)entityNameString inSection:(Section *)section {
	self = [super initWithParent:parentController entityName:entityNameString];
	if (self) {
		self.currentSection = section;
	}
	return self;
}

#pragma mark -
#pragma mark custom functions
- (BOOL)saveItem {
	NSIndexPath *index;
	UITableViewCell *cell;
	UITextField *textField;
	UITextView *textView;
	NSString *trimmedName;
	NSArray *itemKeyArray = [NSArray arrayWithObjects:kManagedObjectNameKey, kManagedObjectPriceKey, kManagedObjectMemoKey, nil];
	
	for (NSUInteger i=kItemNameAttributeRow; i<=kItemMemoAttributeRow; i++) {
		index = [NSIndexPath indexPathForRow:i inSection:kItemAttributeSection];
		cell = [self.tableView cellForRowAtIndexPath:index];
		if (i!=kItemMemoAttributeRow) {
			textField = (UITextField *)[cell viewWithTag:kTextFieldTag];
			trimmedName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		} else {
			textView = (UITextView *)[cell viewWithTag:kTextFieldTag];
			trimmedName = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		}
		if ((i==kItemNameAttributeRow) && ([trimmedName length] == 0)) {
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Empty Name" message:@"이름을 입력하셔야 합니다." delegate:nil cancelButtonTitle:@"네" otherButtonTitles:nil];
			[alert show];
			[alert release];
			return NO;
		}
		if ((i==kItemNameAttributeRow) && (self.editObject == nil)) {
			self.editObject = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:moc];
			[self.editObject setValue:[NSDate date] forKey:kManagedObjectCreationDateKey];
			[self.editObject setValue:nil forKey:kManagedObjectOrderKey];
		}
		if (i==kItemPriceAttributeRow) {
			NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:trimmedName];
			if (price != [NSDecimalNumber notANumber]) {
				[self.editObject setValue:[NSDecimalNumber decimalNumberWithString:trimmedName] forKey:kManagedObjectPriceKey];
			} else {
				[self.editObject setValue:nil forKey:kManagedObjectPriceKey];
			}
		} else
			[self.editObject setValue:trimmedName forKey:[itemKeyArray objectAtIndex:i]];
	}
	
	[self.editObject setValue:self.currentSection forKey:kManagedObjectSectionKey];
	[self.navigationController popViewControllerAnimated:YES];
		
	[self.parent updateList:self.editObject];
	return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == kItemAttributeSection) {
		if (self.editObject == nil) {
			return 3;
		} else if ([self.editObject valueForKey:kManagedObjectDoneDateKey] == nil) {
			return 4;
		} else {
			return 5;
		}
	} else
		return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ItemEdit";
	UILabel *label;
	UITextField *name;
	UITextView *memo;
	NSDate *date;

	// NSLog(@"Making cell... %d : %d", [indexPath section], [indexPath row]);
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	if ([indexPath section] == kItemAttributeSection) {
		NSUInteger row = [indexPath row];
		switch (row) {
			case kItemNameAttributeRow:
			case kItemPriceAttributeRow:
				label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
				label.font = [UIFont boldSystemFontOfSize:16];
				label.textAlignment = UITextAlignmentRight;
				label.tag = kLabelTag;
				if (row == kItemNameAttributeRow) 
					label.text = @"이 름";
				else 
					label.text = @"가 격";
				[cell.contentView addSubview:label];
				[label release];
				
				name = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
				name.clearsOnBeginEditing = NO;
				name.tag = kTextFieldTag;
				name.returnKeyType = UIReturnKeyNext;
				name.enablesReturnKeyAutomatically = YES;
				if (row == kItemNameAttributeRow)
					name.delegate = self;
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flagChange) name:UITextFieldTextDidChangeNotification object:name];
				if (row == kItemNameAttributeRow) {
					name.keyboardType = UIKeyboardTypeDefault;
					if (editObject != nil) 
						name.text = [editObject valueForKey:kManagedObjectNameKey];
				} else {
					name.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
					if (editObject != nil) 
						name.text = [[editObject valueForKey:kManagedObjectPriceKey] stringValue];
				}
				[cell.contentView addSubview:name];
				[name release];				
				break;
			case kItemMemoAttributeRow:
				// cell.contentView.frame = CGRectMake(0, 0, 320, 88);
				label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
				label.font = [UIFont boldSystemFontOfSize:16];
				label.textAlignment = UITextAlignmentRight;
				label.tag = kLabelTag;
				label.text = @"메  모";
				[cell.contentView addSubview:label];
				[label release];
				
				memo = [[UITextView alloc] initWithFrame:CGRectMake(90, 12, 200, 70)];
				// memo = [[UITextView alloc] initWithFrame:CGRectZero];
				memo.tag = kTextFieldTag;
				memo.enablesReturnKeyAutomatically = YES;
				if (self.editObject != nil) {
					memo.text = [editObject valueForKey:kManagedObjectMemoKey];
				}
				// memo.delegate = self;				
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flagChange) name:UITextViewTextDidChangeNotification object:memo];
				[cell.contentView addSubview:memo];
				[memo release];
				break;
			case kItemDoneDateAttribucteRow:
			case kItemCreationDateAttributeRow:
				label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
				label.font = [UIFont boldSystemFontOfSize:16];
				label.textAlignment = UITextAlignmentRight;
				label.tag = kLabelTag;
				if (row == kItemCreationDateAttributeRow)
					label.text = @"생성일";
				else 
					label.text = @"완료일";
				[cell.contentView addSubview:label];
				[label release];

				label = [[UILabel alloc] initWithFrame:CGRectMake(105, 10, 195, 25)];
				label.font = [UIFont systemFontOfSize:16];
				label.textAlignment = UITextAlignmentLeft;
				if (row == kItemCreationDateAttributeRow)
					date = [self.editObject valueForKey:kManagedObjectCreationDateKey];
				else 
					date = [self.editObject valueForKey:kManagedObjectDoneDateKey];
				label.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
				[cell.contentView addSubview:label];
				[label release];
				break;
			default:
				break;
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (([indexPath section] == kItemAttributeSection) && ([indexPath row] == kItemMemoAttributeRow))
		return 88;
	else 
		return 44;
}

#pragma mark -
#pragma mark Table view delegate

// for search or recently used section
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSIndexPath *index;
	UITableViewCell *cell;
	
	for (NSUInteger i=kItemNameAttributeRow; i<=kItemPriceAttributeRow; i++) {
		index = [NSIndexPath indexPathForRow:i inSection:kItemAttributeSection];
		cell = [[self tableView] cellForRowAtIndexPath:index];
		if ([cell.contentView.subviews containsObject:textField]) {
			index = [NSIndexPath indexPathForRow:i+1 inSection:kItemAttributeSection];
			cell = [[self tableView] cellForRowAtIndexPath:index];
			UIResponder *nextField = [cell viewWithTag:kTextFieldTag];
			[nextField becomeFirstResponder];
		}
	}
	return YES;
}	

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

/*
- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	// self.currentSection = nil;
	NSLog(@"View Did Unload");
}
*/


- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end
