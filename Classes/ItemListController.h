//
//  ItemListController.h
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 2. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityListController.h"
#import "ItemDetailController.h"
#import "Section.h"
#import	"Item.h"
#import "EntityAttributesDefinitions.h"
#import "HistoryListController.h"

#define kDoneSheetQuestion @"일이 완료되었습니까?"
#define kDoneSheetCancel @"아니요"
#define kDoneSheetDestruction @"예"

#define kItemCellOrderLabelTag 0
#define kItemCellNameLabelTag 1
#define kItemCellPriceLabelTag 2

#define kSummaryLabelOpacity 0.9

@interface ItemListController : EntityListController <UIActionSheetDelegate> {
	Section *currentSection;
	Item *doneItem;
	UILabel *summaryLabel;
	NSInteger selectedRow;
}
@property (nonatomic, retain) Section *currentSection;
@property (nonatomic, retain) Item *doneItem;
@property (nonatomic, retain) UILabel *summaryLabel;
@property NSInteger selectedRow;

// - (void)makeDefaultSection;
// - (Section *)firstSection;
- (void)chooseSection;
// - (EntityDetailController *)customDetailController;
- (void)leftSegmentHandler:(id)sender;
- (void)customSelectionHandlerWithRow:(NSUInteger)row;
- (void)handleSelectedObject:(NSManagedObject *)selectedObject;
- (void)updateSummaryLabelToRow:(NSInteger)row;
- (NSDecimalNumber *)sumOfItemsToRow:(NSInteger)row nilInformation:(BOOL *)hasNilObject;
- (void)hideSummaryLabel;
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer;
@end
