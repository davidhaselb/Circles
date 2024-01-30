//
//  DHGRExportController.h
//  Circles
//
//  Created by David Haselberger on 28/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHGRExportController : NSObject {
}

- (void)exportAsCSVfromArray:(NSArray *)reportsToExport
                    inWindow:(NSWindow *)actualWindow;

- (void)exportAsPDFfromArray:(NSArray *)reportsToExport
                    inWindow:(NSWindow *)actualWindow;

@end
