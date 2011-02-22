//
//  HistoryListController.h
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 2. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Section.h"
#import "Item.h"
#import "EntityListController.h"
#import "EntityAttributesDefinitions.h"
#import "ItemDetailController.h"

#define kHistorySortKeyFrequency 0
#define kHistorySortKeyDoneDate 1
#define kHistorySortKeyName 2

#define kCopySheetQuestion @"%@ 항목을 복사하여 새로 만들겠습니까?"
#define kCopySheetCancel @"아니오"
#define kCopySheetDestruction @"네"

@interface HistoryListController : UITableViewController <UITableViewDelegate, UIActionSheetDelegate> {
	NSManagedObjectContext *moc;
	Section *currentSection;
	NSArray *historyList;
	NSArray *historyKeys;
	UISegmentedControl *modeControl;
	Item *copyItem;
	EntityListController *parent;
}
@property (nonatomic, retain) NSManagedObjectContext *moc;
@property (nonatomic, retain) Section *currentSection;
@property (nonatomic, retain) NSArray *historyList;
@property (nonatomic, retain) NSArray *historyKeys;
// @property BOOL *historyOrders;
@property (nonatomic, retain) UISegmentedControl *modeControl;
@property (nonatomic, retain) Item *copyItem;
@property (nonatomic, retain) EntityListController *parent;
- (void)updateHistoryList:(NSUInteger)mode;
- (void)segmentHandler:(id)sender;
- (void)updateList:(NSManagedObject *)editedData;
@end
