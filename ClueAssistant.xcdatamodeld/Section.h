//
//  Section.h
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 28..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Item;

@interface Section :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSSet* items;

// - (NSArray *)activeItems:(NSManagedObjectContext *)context orderBy:(NSString *)orderField ascending:(BOOL)ascendingFlag;
- (NSArray *)inactiveItems:(NSManagedObjectContext *)context orderBy:(NSString *)orderField ascending:(BOOL)ascendingFlag;
+ (Section *)firstSection:(NSManagedObjectContext *)context;
+ (Section *)makeDefaultSection:(NSManagedObjectContext *)context;
@end


@interface Section (CoreDataGeneratedAccessors)
- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)value;
- (void)removeItems:(NSSet *)value;

@end
