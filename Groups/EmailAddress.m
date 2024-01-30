//
//  EmailAddress.m
//  Circles
//
//  Created by David Haselberger on 29/08/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "EmailAddress.h"
#import "DHGRStudent.h"


@implementation EmailAddress

@dynamic email;
@dynamic person;

+ (NSArray *)emailKeys {
    static NSArray *emailKeys = nil;
    
    if (emailKeys == nil)
        emailKeys =
        @[@"label", @"email"];
    
    return emailKeys;
}

- (NSDictionary *)emailDictionary {
    return [self dictionaryWithValuesForKeys:[[self class] emailKeys]];
}

@end
