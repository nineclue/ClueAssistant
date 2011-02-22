//
//  Section.h
//  ClueAssistant
//
//  Created by Suhku Huh on 11. 1. 27..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class List;

@interface Section :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSSet* list;

@end


@interface Section (CoreDataGeneratedAccessors)
- (void)addListObject:(List *)value;
- (void)removeListObject:(List *)value;
- (void)addList:(NSSet *)value;
- (void)removeList:(NSSet *)value;

@end

