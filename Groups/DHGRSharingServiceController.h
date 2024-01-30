//
//  DHGRSharingServiceController.h
//  Circles
//
//  Created by David Haselberger on 24/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHGRSharingServiceController
    : NSObject <NSSharingServiceDelegate, NSSharingServicePickerDelegate> {

}

@property(strong) IBOutlet NSArrayController *reportsToExport;
@property(strong) IBOutlet NSButton *mySharingServiceButton;

@end
