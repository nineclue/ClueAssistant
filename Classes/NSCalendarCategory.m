//
//  NSCalendarCategory.m
//  Untitled
//
//  Created by 서구 허 on 11. 1. 22..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSCalendarCategory.h"


@implementation NSCalendar (repeat)
- (NSUInteger) lastdayOfMonth:(NSDate *)date {
	return [self rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (NSRange) rangeOfWeeksInMonth:(NSDate *)date {
	NSUInteger lastday = [self lastdayOfMonth:date];
	NSDateComponents *comp = [[NSDateComponents alloc] init];
	comp = [self components:NSDayCalendarUnit fromDate:date];
    
    NSInteger day = comp.day;
    NSUInteger currentWeek = (day-1)/7+1;
	NSUInteger remainingWeek = (lastday-day)/7;
    [comp release];
	return NSMakeRange(currentWeek, remainingWeek);
}

/*
 self의 가능한 repeatUnit들을 찾아 array로 반환
 가능한 CRepeatCriteria 조합에 숫자들을 넣어놓고 적절한 조합이 입력된 경우들만 반환
*/
- (NSArray *) interpretate:(NSDate *)date repeatUnit:(NSCalendarUnit)unit {
    CRepeatCriteria *dayInfo = [[CRepeatCriteria alloc] init];         
    CRepeatCriteria *monthDayInfo = [[CRepeatCriteria alloc] init];
    CRepeatCriteria *lastdayInfo = [[CRepeatCriteria alloc] init];
    CRepeatCriteria *weekInfo = [[CRepeatCriteria alloc] init];
    CRepeatCriteria *monthWeekInfo = [[CRepeatCriteria alloc] init];
    CRepeatCriteria *lastweekInfo = [[CRepeatCriteria alloc] init];
    
	NSArray *interpretateArrays = [[NSArray alloc] initWithObjects:dayInfo, monthDayInfo, lastdayInfo,
								   weekInfo, monthWeekInfo, lastweekInfo, nil];

	NSDateComponents *comp = [self components:kRepeatCalendarUnits fromDate:date];
	if ((NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) & unit) {
        [weekInfo setCriteriaUnit:NSWeekdayCalendarUnit criteriaNumber:comp.weekday];
		if (unit != NSWeekCalendarUnit) {
            NSRange weekRange = [self rangeOfWeeksInMonth:date];
            
			if (unit == NSYearCalendarUnit) {
                [weekInfo setCriteriaUnit:NSWeekCalendarUnit criteriaNumber:comp.week];   // 매 *년 *째주

                [monthWeekInfo setCriteriaUnit:NSMonthCalendarUnit criteriaNumber:comp.month];  
                [monthWeekInfo setCriteriaUnit:NSWeekCalendarUnit criteriaNumber:weekRange.location];
                [monthWeekInfo setCriteriaUnit:NSWeekdayCalendarUnit criteriaNumber:comp.weekday];
                
                if (weekRange.length == 0) {    // 매 *년 *월 마지막 주
                    [lastweekInfo copyCriteria:monthWeekInfo];
                    [lastweekInfo setCriteriaUnit:NSWeekCalendarUnit criteriaNumber:-1];
                }
            } else { // NSMonthCalendarUnit
                [weekInfo setCriteriaUnit:NSWeekCalendarUnit criteriaNumber:weekRange.location];  // 매 *월 *째주

                if (weekRange.length == 0) {   // 매 *월 마지막 주
                    [lastweekInfo copyCriteria:weekInfo];
                    [lastweekInfo setCriteriaUnit:NSWeekCalendarUnit criteriaNumber:-1];
                }
            }
		}
	}
    
    if ((NSMonthCalendarUnit | NSYearCalendarUnit) & unit) {
        // 년도나 월에 따라 적절한 값이 반환됨
        NSUInteger dayNumber = [self ordinalityOfUnit:NSDayCalendarUnit inUnit:unit forDate:date];  
        [dayInfo setCriteriaUnit:NSDayCalendarUnit criteriaNumber:dayNumber];
        if (unit == NSYearCalendarUnit) {
            [monthDayInfo setCriteriaUnit:NSMonthCalendarUnit criteriaNumber:comp.month];
            [monthDayInfo setCriteriaUnit:NSDayCalendarUnit criteriaNumber:comp.day];
        }
        if (comp.day == [self lastdayOfMonth:date]) {
            if (unit == NSYearCalendarUnit)
                [lastdayInfo copyCriteria:monthDayInfo];
            else
                [lastdayInfo copyCriteria:dayInfo];
            [lastdayInfo setCriteriaUnit:NSDayCalendarUnit criteriaNumber:-1];
        }
    }
    
	NSMutableArray *result = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
    for (CRepeatCriteria *criteria in interpretateArrays) {
        if (criteria.type != CRepeatCriteriaNotInitialized)
            [result addObject:criteria];
    }

	[dayInfo release];
	[monthDayInfo release];
	[lastdayInfo release];
	[weekInfo release];
	[monthWeekInfo release];
	[lastweekInfo release];
	[interpretateArrays release];
	return result;
}

/*
 - (NSDate *) nextDateWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule fromDate:(NSDate *)date 에서 내부적으로 사용하는 함수
 dateComponent의 년,월을 가지고 criteria에 해당하는 날을 찾아 반환한다

*/
- (NSDate *) dateWithCriteria:(CRepeatCriteria *)criteria monthDateComponents:(NSDateComponents *)dateComponent {
    if (dateComponent.year == 0 || dateComponent.month == 0)
        raise (-1);
    
    NSDate *firstday;
    dateComponent.day = 1;
    firstday = [self dateFromComponents:dateComponent];
    if (criteria.type == CRepeatCriteriaDay || criteria.type == CRepeatCriteriaMonthDay) {
        dateComponent.day = criteria.day;
        // CRepeatCriteriaDay - repeat unit이 month, CRepeatCriteriaMonthDay - repeat unit이 year
    } else if (criteria.type == CRepeatCriteriaNegativeDay)
        dateComponent.day = [self lastdayOfMonth:firstday];
    else if (criteria.type == CRepeatCriteriaWeek || criteria.type == CRepeatCriteriaMonthWeek) {
        NSDateComponents *firstdayComponent = [self components:NSWeekdayCalendarUnit fromDate:firstday];
        dateComponent.day = (criteria.week - 1) * 7 + 1;
        if (criteria.weekday < firstdayComponent.weekday) 
            dateComponent.day += criteria.weekday - firstdayComponent.weekday + 7;
        else
            dateComponent.day += criteria.weekday - firstdayComponent.weekday;
    } else if (criteria.type == CRepeatCriteriaNegativeWeek) {
        NSDateComponents *firstdayComponent = [self components:NSWeekdayCalendarUnit fromDate:firstday];
        NSInteger lastday = [self lastdayOfMonth:firstday];
        NSInteger lastdayWeekday = lastday % 7 + firstdayComponent.weekday - 1;
        if (lastdayWeekday > 7)
            lastdayWeekday -= 7;
        if (lastdayWeekday < criteria.weekday)
            lastdayWeekday += 7;
        dateComponent.day = lastday - (lastdayWeekday - criteria.weekday);
    } else
        NSLog(@"Wrong criteria type :%d in dateWithCriteria: dateComponents:", criteria.type);
    return [self dateFromComponents:dateComponent];
}

/*
 date 이후 repeat rule의 간격을 더한 criteria의 날을 반환
*/
- (NSDate *) nextDateWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule fromDate:(NSDate *)date {
    NSDate *newDate = nil;
    NSDateComponents *newComp = [[NSDateComponents alloc] init];
    NSDateComponents *intervalComp = [[NSDateComponents alloc] init];
    NSDateComponents *dateComp;
    
    switch (rule.repeatUnit) {
        case NSDayCalendarUnit:
            intervalComp.day = rule.repeatNumber;
            newDate = [self dateByAddingComponents:intervalComp toDate:date options:0];
            break;
        case NSWeekCalendarUnit:
            intervalComp.week = rule.repeatNumber;
            newDate = [self dateByAddingComponents:intervalComp toDate:date options:0];
            break;
        case NSMonthCalendarUnit:
            dateComp = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
            NSUInteger newMonth = dateComp.month + rule.repeatNumber;
            if (newMonth <= 12) {
                newComp.year = dateComp.year;
                newComp.month = newMonth;
            } else {
                newComp.year = dateComp.year + 1;
                newComp.month = newMonth - 12;
            }
            if (criteria.type == CRepeatCriteriaDay || criteria.type == CRepeatCriteriaWeek ||
                criteria.type == CRepeatCriteriaNegativeDay || criteria.type == CRepeatCriteriaNegativeWeek) {
                newDate = [self dateWithCriteria:criteria monthDateComponents:newComp];
            } else {
                NSLog(@"nextDateWithCriteria: repeatRule: fromDate: - #1 wrong criteria.type %d", criteria.type);
            }
            break;
        case NSYearCalendarUnit:
            dateComp = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
            newComp.year = dateComp.year + rule.repeatNumber;
            if (criteria.type == CRepeatCriteriaDay || criteria.type == CRepeatCriteriaWeek) {
                newComp.month = 1;
                newComp.day = 1;
                NSDate *newYearDay = [self dateFromComponents:newComp];
                if (criteria.type == CRepeatCriteriaDay) {
                    intervalComp.day = criteria.day - 1;
                    newDate = [self dateByAddingComponents:intervalComp toDate:newYearDay options:0];
                } else {
                    NSDateComponents *newYearComp = [self components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:newYearDay];
                    intervalComp.day = (criteria.week - 1) * 7;
                    if (criteria.weekday < newYearComp.weekday) {
                        intervalComp.day = intervalComp.day + 7 - (newYearComp.weekday - criteria.weekday);
                    } else {
                        intervalComp.day = intervalComp.day + (criteria.weekday - newYearComp.weekday);                        
                    }
                    newDate = [self dateByAddingComponents:intervalComp toDate:newYearDay options:0];
                }
            } else if (criteria.type == CRepeatCriteriaMonthDay || criteria.type == CRepeatCriteriaMonthWeek ||
                       criteria.type == CRepeatCriteriaNegativeDay || criteria.type == CRepeatCriteriaNegativeWeek) {
                newComp.month = criteria.month;
                newDate = [self dateWithCriteria:criteria monthDateComponents:newComp];
            } else {
                NSLog(@"nextDateWithCriteria: repeatRule: fromDate: - #2 wrong criteria.type %d", criteria.type);
            }
            break;
        default:
            raise(-1);
    }
    
    [newComp release];
    [intervalComp release];
    return newDate;
}

- (NSDate *) firstDateWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule withLastDate:(NSDate *)lastDate after:(NSDate *)startDate before:(NSDate *)endDate {
    while (lastDate < startDate) 
        lastDate = [self nextDateWithCriteria:criteria repeatRule:rule fromDate:lastDate];
    if (lastDate > endDate) 
        return nil;
    else
        return lastDate;
}

- (NSArray *) datesWithCriteria:(CRepeatCriteria *)criteria repeatRule:(CRepeatRule *)rule withLastDate:(NSDate *)lastDate after:(NSDate *)startDate before:(NSDate *)endDate {
    NSMutableArray *result = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    NSComparisonResult compare;
    
    while ([lastDate compare:startDate] == NSOrderedAscending) 
        lastDate = [self nextDateWithCriteria:criteria repeatRule:rule fromDate:lastDate];
    while (((compare = [lastDate compare:endDate]) == NSOrderedSame || (compare == NSOrderedAscending))) {
        [result addObject:lastDate];
        lastDate = [self nextDateWithCriteria:criteria repeatRule:rule fromDate:lastDate];
    }
    return result;
}

@end
