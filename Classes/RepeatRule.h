//
//  RepeatRule.h
//  Untitled
//
//  Created by 서구 허 on 11. 1. 23..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CRepeatRule : NSObject {
    NSCalendarUnit repeatUnit;
    NSUInteger repeatNumber;
}
@property NSCalendarUnit repeatUnit;
@property NSUInteger repeatNumber;
@end
