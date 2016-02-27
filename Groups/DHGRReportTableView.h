//
//  DHGRReportTableView.h
//  Groups
//
//  Created by David Haselberger on 10/7/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DHGRExportController.h"

@interface DHGRReportTableView : NSTableView {
}

@property(strong) IBOutlet NSArrayController *myReportArrayController;

- (IBAction)deleteReportEntry:(id)sender;
- (IBAction)startEditingEntry:(id)sender;
- (IBAction)exportCSV:(id)sender;
- (IBAction)exportPDF:(id)sender;

@end
