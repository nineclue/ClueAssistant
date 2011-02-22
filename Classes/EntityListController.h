//
//  EntityListController.h
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ClueAssistantAppDelegate.h"
#import "EntityDetailController.h"
#import "EntityAttributesDefinitions.h"

// segmented control index
#define kEditButtonIndex 0
#define kAddButtonIndex 1

// for segmented control label
#define kSegmentedControlEditString @"편집"
#define kSegmentedControlDoneString @"완료"
#define kSegmentedControlAddString @"추가"

@interface EntityListController : UITableViewController {
	NSString *entityName;
	UIViewController *parent;
	NSArray *entityList;
	NSManagedObjectContext *moc;
}
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) UIViewController *parent; 
@property (nonatomic, retain) NSArray *entityList;
@property (nonatomic, retain) NSManagedObjectContext *moc;

- (void)segmentHandler:(id)sender;
- (void)updateList:(NSManagedObject *)editedData;
// - (void)updateListWithPredicate:(NSPredicate *)predicate;
- (NSArray *)list:(NSString *)entity;
- (NSUInteger)listCount:(NSString *)entity;
- (void)updateEntityList;
- (void)shiftUpFrom:(NSUInteger)fromRow to:(NSUInteger)toRow;
- (void)shiftDownFrom:(NSUInteger)fromRow to:(NSUInteger)toRow;
- (void)addNewEntity;
- (void)editEntity:(NSManagedObject *)entity;
@end
