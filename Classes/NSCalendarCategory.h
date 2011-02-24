//
//  NSCalendarCategory.h
//  Untitled
//
//  Created by 서구 허 on 11. 1. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "RepeatCriteria.h"
#include "RepeatRule.h"

#define kRepeatCalendarUnits NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit

@interface NSCalendar (repeat) 
- (NSUInteger) lastdayOfMonth:(NSDate *)date;
- (NSRange) rangeOfWeeksInMonth:(NSDate *)date;
- (NSArray *) interpretate:(NSDate *)date repeatUnit:(NSCalendarUnit)unit;
- (NSDate *) nextDateWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule fromDate:(NSDate *)date;
- (NSDate *) firstDateWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule withLastDate:(NSDate *)lastDate after:(NSDate *)startDate before:(NSDate *)endDate;
- (NSArray *) datesWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule withLastDate:(NSDate *)lastDate after:(NSDate *)startDate before:(NSDate *)endDate;
// - (NSDate *) dateWithCriteria:(CRepeatCriteria *)criteria monthDateComponents:(NSDateComponents *)dateComponent;
@end

