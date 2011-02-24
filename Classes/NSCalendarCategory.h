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
// 날이 있는 달의 마지막 날
- (NSUInteger) lastdayOfMonth:(NSDate *)date;
// 현재 날의 달 주수(1부터 시작)와 달의 남은 주를 NSRange로 반환
- (NSRange) rangeOfWeeksInMonth:(NSDate *)date;
// repeatUnit에 따라 현재 날의 해석가능한 조합(RepeatCriteria의 Array)을 반환
- (NSArray *) interpretate:(NSDate *)date repeatUnit:(NSCalendarUnit)unit;
- (NSDate *) dateWithCriteria:(CRepeatCriteria *)criteria monthDateComponents:(NSDateComponents *)dateComponent;
- (NSDate *) nextDateWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule fromDate:(NSDate *)date;
- (NSDate *) firstDateWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule withLastDate:(NSDate *)lastDate after:(NSDate *)startDate before:(NSDate *)endDate;
- (NSArray *) datesWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule withLastDate:(NSDate *)lastDate after:(NSDate *)startDate before:(NSDate *)endDate;
@end

