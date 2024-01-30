//
//  DHGRReportTableView.m
//  Groups
//
//  Created by David Haselberger on 10/7/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRReportTableView.h"
#import "DHGRReportTextField.h"

@interface DHGRReportTableView (privateMethods)
- (void)_deleteRecord:(NSManagedObject *)obj;
@end

@implementation DHGRReportTableView

@synthesize myReportArrayController;

- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}

- (void)awakeFromNib {
}

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder
                              forEvent:(NSEvent *)event {
  return [super validateProposedFirstResponder:responder forEvent:event];
}

- (void)mouseDown:(NSEvent *)theEvent {
  [super mouseDown:theEvent];

  NSPoint selfPoint =
      [self convertPoint:theEvent.locationInWindow fromView:nil];
  NSInteger row = [self rowAtPoint:selfPoint];
  if (row >= 0) {
    NSTableCellView *myReportsTextFieldCellView =
        [self viewAtColumn:0 row:row makeIfNecessary:NO];
    DHGRReportTextField *myReportsTextField =
        (DHGRReportTextField *)[myReportsTextFieldCellView textField];
    [myReportsTextField mouseDownForTextFields:theEvent];
  }
}

- (void)keyDown:(NSEvent *)event {
  BOOL keyWasHandled = NO;
  if ([event keyCode] == 51) {
    [self deleteReportEntry:self];
    keyWasHandled = YES;
  }
  if ([event keyCode] == 49) {
    if ([[self.myReportArrayController arrangedObjects] count] > 0) {
      NSDictionary *
      myValueDictionary = [[self.myReportArrayController arrangedObjects][[self selectedRow]] valueForKey:@"reportDictionary"];
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"dHGRReportSpacebarSelect"
                        object:myValueDictionary];
    }
    keyWasHandled = YES;
  }

  if (!keyWasHandled) {
    [super keyDown:event];
  }
}

- (IBAction)deleteReportEntry:(id)sender;
{
  if ([[self.myReportArrayController selectedObjects] count] > 0) {
    NSManagedObject *selectedReportRecord =
        [self.myReportArrayController selectedObjects][0];
      NSUInteger i = [[self.myReportArrayController arrangedObjects] indexOfObject:selectedReportRecord];
      NSManagedObject* oneBeforeSelectedRecord;
      if (i > 0 &&[[self.myReportArrayController arrangedObjects] objectAtIndex:i -1] != nil)
      {
          oneBeforeSelectedRecord = [[self.myReportArrayController arrangedObjects] objectAtIndex:i -1];
      }
    NSManagedObjectContext *myManagedObjectContext =
        [selectedReportRecord managedObjectContext];
    [myManagedObjectContext deleteObject:selectedReportRecord];
      if (oneBeforeSelectedRecord)
      {
          [self.myReportArrayController setSelectedObjects:[NSArray arrayWithObject:oneBeforeSelectedRecord]];
      }
  }
}

- (IBAction)startEditingEntry:(id)sender {
    [[NSNotificationCenter defaultCenter]
      postNotificationName:@"dHGRReportBeginEditingEntry"
                    object:self];
}

- (IBAction)exportCSV:(id)sender {
  DHGRExportController *myExportController =
      [[DHGRExportController alloc] init];
  [myExportController
      exportAsCSVfromArray:[self.myReportArrayController arrangedObjects]
                  inWindow:[self window]];
}

- (IBAction)exportPDF:(id)sender
{
    DHGRExportController *myExportController =
    [[DHGRExportController alloc] init];
    [myExportController
     exportAsPDFfromArray:[self.myReportArrayController arrangedObjects]
     inWindow:[self window]];
}



@end
