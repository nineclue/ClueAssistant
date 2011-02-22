// 
//  Section.m
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 28..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Section.h"
#import "Item.h"
#import "EntityAttributesDefinitions.h"

@implementation Section 

@dynamic name;
@dynamic order;
@dynamic items;

+ (Section *)firstSection:(NSManagedObjectContext *)context {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *ed = [NSEntityDescription entityForName:kSectionName inManagedObjectContext:context];
	[request setEntity:ed];
	NSPredicate *pd = [NSPredicate predicateWithFormat:@"order = 0"];
	[request setPredicate:pd];
		
	NSError *error;
	NSArray *result = [context executeFetchRequest:request error:&error];
	[request release];
	if (result == nil) {
		NSLog(@"Error!!!");
		return nil;
	}
	if ([result count] == 0)
		return [self makeDefaultSection:context];
	else
		return (Section *)[result objectAtIndex:0];
}

+ (Section *)makeDefaultSection:(NSManagedObjectContext *)context {
	NSManagedObject *wishlist = [NSEntityDescription insertNewObjectForEntityForName:kSectionName inManagedObjectContext:context];
	NSError *error;
	[wishlist setValue:kDefaultSectionName forKey:@"name"];
	[wishlist setValue:[NSNumber numberWithInt:0] forKey:@"order"];
	if (![context save:&error]) {
		NSLog(@"Error %@, %@", error, [error userInfo]);
		abort();
	}
	return (Section *)wishlist;
}

- (NSArray *)inactiveItems:(NSManagedObjectContext *)context orderBy:(NSString *)orderField ascending:(BOOL)ascendingFlag {
	NSEntityDescription *itemEntity = [NSEntityDescription entityForName:kItemName inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:itemEntity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY section = %@ AND doneDate != NIL", self];
	[request setPredicate:predicate];
	NSArray *sda;
	if ([orderField compare:kManagedObjectNameCountKey] == NSOrderedSame) {
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:kManagedObjectNameKey ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:kManagedObjectCreationDateKey ascending:NO];
		sda = [NSArray arrayWithObjects:sd1, sd2, nil];
		[sd1 release];
		[sd2 release];
	} else {
		NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:orderField ascending:ascendingFlag];
		sda = [NSArray arrayWithObject:sd];
		[sd release];
	} 
	[request setSortDescriptors:sda];
	
	NSError *error = nil;
	NSArray *result = [context executeFetchRequest:request error:&error];
	if (result == nil) {
		NSLog(@"Error : Session.inactiveItems, %@ %@", error, [error userInfo]);
	}
	[request release];

	if ([orderField compare:kManagedObjectNameCountKey] == NSOrderedSame) {
		NSMutableDictionary *counterDict = [[NSMutableDictionary alloc] init];
		NSString *previousName = nil;
		NSUInteger counter;
		NSManagedObject *previousObject = nil;
		for (Item *item in result) {
			if ([item.name compare:previousName] != NSOrderedSame) {
				if (previousObject != nil) {
					[counterDict setObject:[NSNumber numberWithInt:counter] forKey:[previousObject objectID]];
				}
				previousName = item.name;
				previousObject = item;
				counter = 1;
			} else {
				counter++;
			}
		}
		if (previousObject != nil) {
			[counterDict setObject:[NSNumber numberWithInt:counter] forKey:[previousObject objectID]];
		}

		NSArray *intermediateResult = [counterDict keysSortedByValueUsingComparator: ^(id id1, id id2) {
			NSNumber *number1 = id1;
			NSNumber *number2 = id2;
			if ([number1 integerValue] > [number2 integerValue]) {
				return NSOrderedAscending;
			} else if ([number1 integerValue] < [number2 integerValue]) {
				return NSOrderedDescending;
			} else {
				return NSOrderedSame;
			} 
		}];
		NSMutableArray *finalResult = [[[NSMutableArray alloc] init] autorelease];
		for (NSManagedObjectID *OID in intermediateResult) {
			NSManagedObject *item = [context objectWithID:OID];
			[finalResult addObject:item];
		}
		[counterDict release];
		return finalResult;
	} else {
		return result;
	}
}

/*
- (NSArray *)distinctInactiveItems:(NSManagedObjectContext *)context orderyBy:(NSString *)orderField ascending:(BOOL)ascendingFlag {
	NSEntityDescription *itemEntity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:itemEntity];
	[request setResultType:NSDictionaryResultType];
	[request setReturnsDistinctResults:YES];
	
	NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"name"];
	NSExpression *expression = [NSExpression expressionForFunction:@"count" arguments:[NSArray arrayWithObjects:keyPathExpression, nil]];
	NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName:@"numberOfItems"];
	[expressionDescription setExpression:expression];
	[expressionDescription setExpressionResultType:NSInteger16AttributeType];
	[request setPropertiesToFetch:[NSArray arrayWithObjects:expressionDescription, nil]];
	[expressionDescription release];

	[request setPropertiesToFetch:[NSArray arrayWithObjects:@"name", nil]];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY section = %@ AND doneDate != NIL", self];
	[request setPredicate:predicate];
	
	NSArray *result = [context executeFetchRequest:request error:nil];
	[request release];
	NSLog(@"distinct item : %@", result);
}
*/

/*
- (void)willTurnIntoFault {
    NSLog(@"Section will turn into fault");
}

- (void)didTurnIntoFault {
    NSLog(@"Section did turn into fault");
}
*/

@end
