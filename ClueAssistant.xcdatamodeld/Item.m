// 
//  Item.m
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 28..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

#import "Category.h"
#import "Section.h"

@implementation Item 

@dynamic doneDate;
@dynamic order;
@dynamic creationDate;
@dynamic memo;
@dynamic price;
@dynamic name;
@dynamic category;
@dynamic section;

- (void)markDone:(NSManagedObjectContext *)context {
	self.doneDate = [NSDate date];
	self.order = nil;
	NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"Error %@, %@", error, [error userInfo]);
		abort();
	}
}
@end
