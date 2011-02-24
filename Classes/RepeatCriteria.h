//
//  RepeatCriteria.h
//  Untitled
//
//  Created by 서구 허 on 11. 1. 23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum _CRepeatCriteriaType {
    CRepeatCriteriaNotInitialized,
    CRepeatCriteriaDay,
    CRepeatCriteriaMonthDay,
    CRepeatCriteriaNegativeDay,
    CRepeatCriteriaWeek,
    CRepeatCriteriaMonthWeek,
    CRepeatCriteriaNegativeWeek
};
typedef enum _CRepeatCriteriaType CRepeatCriteriaType;

@interface CRepeatCriteria : NSObject {
    enum _CRepeatCriteriaType type;
    NSInteger month;
    NSInteger day;
    NSInteger week;
    NSInteger weekday;    
}
@property (assign) enum _CRepeatCriteriaType type;
@property NSInteger month, day, week, weekday;

- (id)init;
- (void)copyCriteria:(CRepeatCriteria *)source;
- (void)setCriteriaUnit:(NSCalendarUnit)unit criteriaNumber:(NSInteger)number;
- (void)updateCriteriaType;
@end
