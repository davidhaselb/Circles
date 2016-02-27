//
//  DHGRReportsTableViewController.h
//  Groups
//
//  Created by David Haselberger on 7/23/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHGRReportsTableViewController
    : NSObject <NSTableViewDelegate, NSPopoverDelegate,
                        NSDatePickerCellDelegate, NSTextViewDelegate,
                        NSTextDelegate, NSSplitViewDelegate> {
  NSArray *tracksSortDescriptors; 
}

@property(strong) IBOutlet NSArrayController *reportsArrayController;
@property(strong) IBOutlet NSArrayController *studentsArrayController;
@property(strong) IBOutlet NSTextView *myInputTextView;
@property(strong) IBOutlet NSSearchField *reportSearchField;
@property(strong) IBOutlet NSButton *myEditButton;
@property(strong) IBOutlet NSTableView *reportsList;
@property(strong) IBOutlet NSButton *popoverTriggerButton;
@property(strong) IBOutlet NSPopover *popover;
@property(strong) IBOutlet NSDatePicker *myDatePicker;
@property(strong) IBOutlet NSButton *ratingsPopoverTriggerButton;
@property(strong) IBOutlet NSPopover *ratingsPopover;
@property(strong) IBOutlet NSTextField* ratingsTextFieldA;
@property(strong) IBOutlet NSTextField* ratingsTextFieldB;
@property(strong) IBOutlet NSButton *ratingsSetButton;
@property(strong) IBOutlet NSButton *additionsPopoverTriggerButton;
@property(strong) IBOutlet NSPopover *additionsPopover;
@property(strong) IBOutlet NSTextField* additionsTextField;
@property(strong) IBOutlet NSButton *additionsSetButton;
@property(strong) IBOutlet NSSplitView *smallerSplitView;
@property(strong) NSString *editingString;
@property(nonatomic, assign) BOOL isEditing;
@property(nonatomic, assign) BOOL initialized;
@property BOOL gotNotifiedOfEditing;
@property BOOL selectionChangeBool;
@property NSUInteger editingIndex;

- (IBAction)addContent:(id)sender;
- (IBAction)editButtonClicked:(id)sender;
- (IBAction)rowDoubleClicked:(id)sender;
- (IBAction)unpackReportValueDictionary:(id)sender;
- (IBAction)togglePopover:(id)sender;
- (IBAction)toggleRatingsPopover:(id)sender;
- (IBAction)setNewRatings:(id)sender;
- (IBAction)toggleAdditionsPopover:(id)sender;
- (IBAction)setNewAddedPoints:(id)sender;
- (IBAction)updateFilterAction:(id)sender;
- (void)editSelection:(id)sender;

- (NSAttributedString *)styledDateStringFromDate:(NSDate *)newDate;

@end
