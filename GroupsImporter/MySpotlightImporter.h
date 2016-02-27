//
//  MySpotlightImporter.h
//  GroupsImporter
//
//  Created by David Haselberger on 01.06.13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MySpotlightImporter : NSObject

@property(readonly, strong, nonatomic)
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic)
    NSManagedObjectContext *managedObjectContext;

- (BOOL)importFileAtPath:(NSString *)filePath
              attributes:(NSMutableDictionary *)attributes
                   error:(NSError **)error;

@end
