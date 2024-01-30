//
//  DHGRSharingServiceController.m
//  Circles
//
//  Created by David Haselberger on 24/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRSharingServiceController.h"

@implementation DHGRSharingServiceController

@synthesize mySharingServiceButton;
@synthesize reportsToExport;

- (void)awakeFromNib {
    [self.mySharingServiceButton sendActionOn:NSEventMaskLeftMouseDown];
}

- (NSString *)csvOfReport {
  if ([[self.reportsToExport arrangedObjects] count] > 0) {
    NSMutableArray *csvStringsToBeJoined = [[NSMutableArray alloc] init];

    for (NSManagedObject *aReport in [self.reportsToExport arrangedObjects]) {
        NSString *separator = @"| ";
        NSDate *entryDate = [aReport valueForKey:@"date"];
        NSString *dateOfEntry =
        [NSDateFormatter localizedStringFromDate:entryDate
                                       dateStyle:NSDateFormatterLongStyle
                                       timeStyle:NSDateFormatterShortStyle];
        NSString *entryContent = [aReport valueForKey:@"contentString"];
        NSString* textQualifier = [NSString stringWithFormat:@"\""];
        NSArray* contentArray = [NSArray arrayWithObjects:textQualifier, entryContent, textQualifier, nil];
        NSString *myContent = [contentArray componentsJoinedByString:@" "];
        NSString *noNewlineContentString = [[myContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        NSString *adds = [[aReport valueForKey:@"points"] stringValue];
        NSString *entryRating = [[aReport valueForKey:@"rating"] stringValue];
        NSString *ratingForEntry = entryRating ? entryRating : @"0";
        NSArray *entryAttributes = @[dateOfEntry, noNewlineContentString, adds, ratingForEntry];
        NSString *myEntry = [entryAttributes componentsJoinedByString:separator];
        [csvStringsToBeJoined addObject:myEntry];
    }
    NSString *csv =
        [[csvStringsToBeJoined copy] componentsJoinedByString:@"\n"];
    return csv;
  }
  return [NSString stringWithFormat:@""];
}

- (NSString *)messageOfReportEntry {
    if ([[self.reportsToExport selectedObjects] count] > 0) {
        NSMutableArray *csvStringsToBeJoined = [[NSMutableArray alloc] init];
        
        for (NSManagedObject *aReport in [self.reportsToExport selectedObjects]) {
            NSDate *entryDate = [aReport valueForKey:@"date"];
            NSString *dateOfEntry =
            [NSDateFormatter localizedStringFromDate:entryDate
                                           dateStyle:NSDateFormatterLongStyle
                                           timeStyle:NSDateFormatterShortStyle];
            NSString *entryContent = [aReport valueForKey:@"contentString"];
            NSString* textQualifier = [NSString stringWithFormat:@"\""];
            NSArray* contentArray = [NSArray arrayWithObjects:textQualifier, entryContent, textQualifier, nil];
            NSString *myContent = [contentArray componentsJoinedByString:@" "];
            NSString *noNewlineContentString = [[myContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
            NSArray *entryAttributes = @[dateOfEntry, noNewlineContentString];
            NSString *myEntry = [entryAttributes componentsJoinedByString:@"\n"];
            [csvStringsToBeJoined addObject:myEntry];
        }
        NSString *csv =
        [[csvStringsToBeJoined copy] componentsJoinedByString:@"\n\n"];
        return csv;
    }
    return [NSString stringWithFormat:@""];
}

- (NSString *)suggestedFileName {
  if ([[self.reportsToExport arrangedObjects] count] > 0) {
    NSManagedObject *thePerson =
        [[self.reportsToExport arrangedObjects][0]
            valueForKey:@"belongsTo"];
    NSString *name = [thePerson valueForKey:@"firstName"];
    NSString *fileName = [[self.mySharingServiceButton window] title];
    NSString *fileNameForReal;
    NSString *regEx = [NSString stringWithFormat:@"Untitled*"];
    NSRange range =
        [fileName rangeOfString:regEx options:NSRegularExpressionSearch];

    if (range.location == NSNotFound) {
      fileNameForReal =
          [fileName substringToIndex:[fileName rangeOfString:@"."].location];
    } else {
      fileNameForReal = [NSString stringWithFormat:@"Untitled"];
    }
    if (!name) {
      name = [NSString stringWithFormat:@"Person"];
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *exportDate = [dateFormat stringFromDate:[NSDate date]];
    NSString *suggestion = [NSString
        stringWithFormat:@"%@_%@_%@.csv", fileNameForReal, name, exportDate];
    return suggestion;
  }
  return [NSString stringWithFormat:@""];
}

- (void)saveCSV:(NSString *)currentCSV
    withSuggestedFileName:(NSString *)suggestedFileName {
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setNameFieldStringValue:suggestedFileName];
  [panel beginSheetModalForWindow:[self.mySharingServiceButton window]
                completionHandler:^(NSInteger result) {
      if (result == NSModalResponseOK) {
                      [currentCSV writeToURL:[panel URL]
                                  atomically:YES
                                    encoding:NSMacOSRomanStringEncoding
                                       error:nil];
                    }
                }];
}

- (IBAction)chooseFromSharingServicePicker:(id)sender {
  NSMutableArray *shareItems =
      [NSMutableArray arrayWithObject:[self messageOfReportEntry]];
  NSSharingServicePicker *sharingServicePicker =
      [[NSSharingServicePicker alloc] initWithItems:shareItems];
  sharingServicePicker.delegate = self;
  [sharingServicePicker showRelativeToRect:[self.mySharingServiceButton bounds]
                                    ofView:self.mySharingServiceButton
                             preferredEdge:NSMaxYEdge];
}

#pragma mark - Sharing service picker delegate methods

- (id<NSSharingServiceDelegate>)
         sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker
    delegateForSharingService:(NSSharingService *)sharingService {
  return self;
}

- (void)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker
     didChooseSharingService:(NSSharingService *)service {
}

#pragma mark - Sharing service delegate methods

- (NSRect)sharingService:(NSSharingService *)sharingService
    sourceFrameOnScreenForShareItem:(id<NSPasteboardWriting>)item {
  return NSZeroRect;
}

- (NSWindow *)sharingService:(NSSharingService *)sharingService
    sourceWindowForShareItems:(NSArray *)items
          sharingContentScope:(NSSharingContentScope *)sharingContentScope {
  return self.mySharingServiceButton.window;
}

- (void)dealloc
{
    self.mySharingServiceButton = nil;
    self.reportsToExport = nil;
}

@end
