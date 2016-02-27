//
//  DHGRStuentTableViewController.h
//  Groups
//
//  Created by David Haselberger on 18.06.13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "DHGRStudentTableView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPeoplePickerView.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABGroup.h>
#import "DHGRStudent.h"



@interface DHGRStudentTableViewController
    : NSObject <NSTableViewDelegate, NSSplitViewDelegate> {
  IBOutlet NSPanel *thePeoplePanel;
  IBOutlet ABPeoplePickerView *peoplePicker;
}

@property(strong) IBOutlet NSArrayController *reports;
@property(strong) IBOutlet NSTableView *listOfReports;
@property(strong) IBOutlet NSArrayController *students;
@property(strong) IBOutlet NSTableView *studentList;
@property(strong) IBOutlet NSSplitView *largerSplitView;
@property(strong) NSIndexSet *currentIndexOfStudentList;

- (IBAction)removeSelectedItems:(id)sender;
- (IBAction)peopleRowDoubleClicked:(id)sender;
- (IBAction)openPeoplePickerSheet:(id)sender;
- (void)showPersonSheet:(NSNotification *)note;
- (IBAction)theSheetOK:(id)sender;
- (IBAction)theSheetCancel:(id)sender;
- (void)reloadAddressbookData:(NSNotification *)notification;
- (void)reloadTableViewData:(NSNotification *)notification;


@end
