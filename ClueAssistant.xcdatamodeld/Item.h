//
//  Item.h
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 28..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Category;
@class Section;

@interface Item :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * doneDate;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Category * category;
@property (nonatomic, retain) Section * section;

- (void)markDone:(NSManagedObjectContext *)context;
@end



