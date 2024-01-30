//
//  DHGRStudent.h
//  Groups
//
//  Created by David Haselberger on 7/15/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>

@class EmailAddress;

@interface DHGRStudent : NSManagedObject {
}

+ (NSArray *)studentKeys;
//- (void)reloadAddressbookData;

@property(readonly) BOOL isRated;
@property(readonly) BOOL gotPoints;
@property(readonly) BOOL gotEntries;
@property(readonly) NSDictionary *studentDictionary;
@property(readonly) NSString *displayString;
@property(readonly) NSString *myRating;
@property(readonly) NSString *myPoints;
@property(readonly) NSString *myEntries;
@property(readonly) NSData *myPortrait;

@property (nonatomic, retain) NSSet *emailAddresses;
@property (nonatomic, retain) NSSet *phoneNumbers;

@end

@interface DHGRStudent (CoreDataGeneratedAccessors)

- (void)addEmailAddressesObject:(EmailAddress *)value;
- (void)removeEmailAddressesObject:(EmailAddress *)value;
- (void)addEmailAddresses:(NSSet *)values;
- (void)removeEmailAddresses:(NSSet *)values;

- (void)addPhoneNumbersObject:(NSManagedObject *)value;
- (void)removePhoneNumbersObject:(NSManagedObject *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;

@end
