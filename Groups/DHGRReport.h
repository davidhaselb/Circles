//
//  DHGRReport.h
//  Groups
//
//  Created by David Haselberger on 7/15/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DHGRReport : NSManagedObject {
}

+ (NSArray *)reportKeys;
@property(readonly) NSDictionary *reportDictionary;
@property(readonly) NSAttributedString *reportString;

@end
