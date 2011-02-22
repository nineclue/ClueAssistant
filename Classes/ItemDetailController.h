//
//  ItemDetailController.h
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 2. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EntityDetailController.h"
#import "Section.h"
#import "EntityAttributesDefinitions.h"

#define kItemAttributeSection 0
#define kItemNameAttributeRow 0
#define kItemPriceAttributeRow 1
#define kItemMemoAttributeRow 2
#define kItemCreationDateAttributeRow 3
#define kItemDoneDateAttribucteRow 4

@interface ItemDetailController : EntityDetailController <UITextFieldDelegate, UIActionSheetDelegate> {
	Section *currentSection;
}
@property (nonatomic, retain) Section *currentSection;
- (id)initWithParent:(UITableViewController *)parentController entityName:(NSString *)entityNameString inSection:(Section *)section;
// - (id)initWithStyle:(UITableViewStyle)style inSection:(Section *)section;
@end
