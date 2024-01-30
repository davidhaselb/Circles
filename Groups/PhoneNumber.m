//
//  PhoneNumber.m
//  Circles
//
//  Created by David Haselberger on 29/08/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "PhoneNumber.h"
#import "DHGRStudent.h"


@implementation PhoneNumber

@dynamic phoneNumber;
@dynamic person;

+ (NSArray *)phoneKeys {
    static NSArray *phoneKeys = nil;
    
    if (phoneKeys == nil)
        phoneKeys =
        @[@"label", @"phoneNumber"];
    
    return phoneKeys;
}

- (NSDictionary *)phoneDictionary {
    return [self dictionaryWithValuesForKeys:[[self class] phoneKeys]];
}

@end
