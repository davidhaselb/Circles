//
//  DHGRStudentTableView.h
//  Groups
//
//  Created by David Haselberger on 14.06.13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DHGRImage.h"

@interface DHGRStudentTableView : NSTableView {
  IBOutlet NSArrayController *myStudentArrayController;
}

- (IBAction)deleteStudentEntry:(id)sender;


@end