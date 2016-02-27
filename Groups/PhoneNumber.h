//
//  PhoneNumber.h
//  Circles
//
//  Created by David Haselberger on 29/08/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DHGRAddress.h"

@class DHGRStudent;

@interface PhoneNumber : DHGRAddress

+ (NSArray *)phoneKeys;
@property(readonly) NSDictionary *phoneDictionary;
@property (nonatomic, retain) NSString* phoneNumber;
@property (nonatomic, retain) DHGRStudent *person;

@end
