//
//  EntityDetailController.h
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 30..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClueAssistantAppDelegate.h"
#import	"EntityAttributesDefinitions.h"

#define kEditModeString @"수 정"
#define kAddModeString @"추 가"
#define kDoneString @"저장"

#define kLabelTag 0
#define kTextFieldTag 1

// actionSheet message
#define kConfirmCancelMessage @"저장하지 않고 끝냅니까?"
#define kDoCancelButtonMessage @"네"
#define kCancelCancelButtonMessage @"아니요"

@class EntityListController;

@interface EntityDetailController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
	NSManagedObject *editObject;
	NSManagedObjectContext *moc;
	NSString *entityName;
	UITableViewController *parent;
	BOOL entityChanged;
}

@property (nonatomic, retain) NSManagedObject *editObject;
@property (nonatomic, retain) NSManagedObjectContext *moc;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) UITableViewController *parent;
@property BOOL entityChanged;
// @property (nonatomic, retain) UITextField *nameField;
- (id)initWithParent:(UITableViewController *)parentController entityName:(NSString *)entityNameString;
- (BOOL) saveItem;
- (void) cancelItem;
- (void)flagChange;
@end
