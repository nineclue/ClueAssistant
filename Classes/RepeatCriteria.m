//
//  RepeatCriteria.m
//  Untitled
//
//  Created by 서구 허 on 11. 1. 23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RepeatCriteria.h"


@implementation CRepeatCriteria
@synthesize type;
@synthesize month, day, week, weekday;

- (id) init {
    self = [super init];
    if (self != nil) {
        self.type = CRepeatCriteriaNotInitialized;
        self.month = 0;
        self.day = 0;
        self.week = 0;
        self.weekday = 0;
    }
    return self;
}

- (void)copyCriteria:(CRepeatCriteria *)source {
    self.type = source.type;
    self.month = source.month;
    self.day = source.day;
    self.week = source.week;
    self.weekday = source.weekday;
}

- (void)setCriteriaUnit:(NSCalendarUnit)unit criteriaNumber:(NSInteger)number {
    switch (unit) {
        case NSMonthCalendarUnit:
            self.month = number;
            break;
        case NSDayCalendarUnit:
            self.day = number;
            break;
        case NSWeekCalendarUnit:
            self.week = number;
            break;
        case NSWeekdayCalendarUnit:
            self.weekday = number;
            break;
        default:
            raise(-1);
    }
    [self updateCriteriaType];
}

/* month, week, day, weekday의 정보에 따라 자신의 type을 결정
   CRepeatCriteriaNegativeDay - 월의 마지막날
   CRepeatCriteriaNegativeWeek - 마지막주 *요일
   CRepeatCriteriaMonthDay - *월 *일
   CRepeatCriteriaMonthWeek - *월 *주 *요일
   CRepeatCriteriaDay - *일 (년, 달 반복 가능)
   CRepeatCriteriaWeek - *주 *요일 (년, 달 반복 가능)
   CRepeatCriteriaNegativeWeek - 마지막주 *요일 (기본적으로 달 반복)
*/
- (void)updateCriteriaType {
    self.type = CRepeatCriteriaNotInitialized;
    if (self.month > 0 && self.month < 13) {
        if (self.day < 0) 
            self.type = CRepeatCriteriaNegativeDay;
        else if (self.week < 0 && self.weekday > 0 && self.weekday < 8)
            self.type = CRepeatCriteriaNegativeWeek;
        else if (self.day > 0 && self.week == 0)
            self.type = CRepeatCriteriaMonthDay;
        else if (self.week > 0 && self.day == 0 && self.weekday > 0 && self.weekday < 8)
            self.type = CRepeatCriteriaMonthWeek;
    } else {
        if (self.day > 0 && self.week == 0) 
            self.type = CRepeatCriteriaDay;
        else if (self.week > 0 && self.day == 0 && self.weekday > 0 && self.weekday < 8)
            self.type = CRepeatCriteriaWeek;
        else if (self.week < 0) 
            self.type = CRepeatCriteriaNegativeWeek;
    }
}
@end
