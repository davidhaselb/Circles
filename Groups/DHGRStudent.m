//
//  DHGRStudent.m
//  Groups
//
//  Created by David Haselberger on 7/15/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRStudent.h"

@implementation DHGRStudent

@dynamic emailAddresses;
@dynamic phoneNumbers;

+ (NSArray *)studentKeys {
  static NSArray *studentKeys = nil;

  if (studentKeys == nil)
    studentKeys = @[@"firstName", @"lastName", @"displayString",
                        @"portrait", @"uniqueAddressBookID",
                        @"currentReportSelection"];
  return studentKeys;
}

- (NSDictionary *)studentDictionary {
  return [self dictionaryWithValuesForKeys:[[self class] studentKeys]];
}

- (void)awakeFromFetch {
  //[self reloadAddressbookData];
  [super awakeFromFetch];
}

- (void)awakeFromInsert {
  [super awakeFromInsert];
  [self willChangeValueForKey:@"currentReportSelection"];
  NSIndexSet *initialIndexSet = [NSIndexSet indexSetWithIndex:0];
  NSMutableData *indexData = [NSMutableData data];
  NSKeyedArchiver *archiver =
      [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
  [archiver encodeRootObject:initialIndexSet];
  NSData *indexDataToBeInserted = [indexData copy];
  [self setValue:indexDataToBeInserted forKey:@"currentReportSelection"];
  [self didChangeValueForKey:@"currentReportSelection"];
}

//- (void)reloadAddressbookData {
//  NSString *recordId = [self valueForKey:@"uniqueAddressBookID"];
//  if (recordId) {
//    ABRecord *record =
//        [[ABAddressBook sharedAddressBook] recordForUniqueId:recordId];
//    if (record) {
//      NSString *firstName;
//      NSString *lastName;
//      NSData *portraitData;
//      firstName = [record valueForProperty:@"firstName"];
//      lastName = [record valueForProperty:@"lastName"];
//      portraitData = [(ABPerson *)record imageData];
//      [self setValue:firstName forKey:@"firstName"];
//      [self setValue:lastName forKey:@"lastName"];
//      [self setValue:recordId forKey:@"uniqueAddressBookID"];
//      [self setValue:portraitData forKey:@"portrait"];
//    }
//  }
//}

- (NSString *)displayString {
  NSString *firstNameString = [self valueForKey:@"firstName"];
  NSString *lastNameString = [self valueForKey:@"lastName"];
  NSMutableString *nameMutableString = [NSMutableString stringWithCapacity:0];
  if (firstNameString) {
    [nameMutableString appendString:firstNameString];
  }
  if (firstNameString && lastNameString) {
    [nameMutableString appendFormat:@" "];
  }
  if (lastNameString) {
    [nameMutableString appendString:lastNameString];
  }

  return nameMutableString;
}

- (NSString *)myRating {
  NSArray *myReports = [self valueForKey:@"ownsReport"];
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSInteger myRating = 0;
  int divisor = 0;
  for (NSManagedObject *obj in myReports) {
    if ([obj valueForKey:@"rating"] != nil) {
      myRating += [[obj valueForKey:@"rating"] intValue];
      divisor = divisor + 1;
    }
  }
  if (divisor > 0) {
    myRating = myRating / divisor;
  }

  NSString *thirdText = [NSString stringWithFormat:@"%d%%", (int)myRating];
  if (myRating && ![prefs boolForKey:@"isStandard"])
  {
    return thirdText;
  } else {
    return [NSString stringWithFormat:@""];
  }
}

- (NSString *)myPoints {
  NSNumber *myP = [self valueForKeyPath:@"ownsReport.@sum.points"];
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSString *myPointString = [NSString stringWithFormat:@"%@", myP];
  if ([myP intValue] > 0 && ![prefs boolForKey:@"isStandard"]) {
    return myPointString;
  } else {
    return [NSString stringWithFormat:@""];
  }
}

- (NSString *)myEntries {
  NSNumber *myEn = [self valueForKeyPath:@"ownsReport.@count"];
  NSString *myEntryString = [NSString stringWithFormat:@"%@", myEn];
  if ([myEn intValue] > 0) {
    return myEntryString;
  } else {
    return [NSString stringWithFormat:@""];
  }
}

- (NSData *)myPortrait {
  NSData *currentP = [self valueForKey:@"portrait"];
  if (currentP == nil) {
    currentP = [[NSImage imageNamed:@"NSUser"] TIFFRepresentation];
  }
  return currentP;
}

- (BOOL)gotEntries {
  if ([self valueForKeyPath:@"ownsReport.@count"] > 0) {
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)gotPoints {
  Boolean pointsValue = YES;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs boolForKey:@"isStandard"])
    {
      NSNumber *myP = [self valueForKeyPath:@"ownsReport.@sum.points"];
      if ([myP intValue] > 0) {
        pointsValue = NO;
      }
    }
  return pointsValue;
}

- (BOOL)isRated {
  Boolean ratedValue = YES;
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  if (![prefs boolForKey:@"isStandard"])
  {
      NSArray *myReports = [self valueForKey:@"ownsReport"];
      for (NSManagedObject *obj in myReports) {
          if ([obj valueForKey:@"rating"] != nil) {
              ratedValue = NO;
              break;
          }
      }
  }
  return ratedValue;
}

@end
