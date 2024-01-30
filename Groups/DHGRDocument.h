//
//  DHGRDocument.h
//  Groups
//
//  Created by David Haselberger on 01.06.13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>

@interface DHGRDocument : NSPersistentDocument <NSWindowDelegate> {
  NSTextView *myCustomFieldEditor;
  NSTextView *mySearchFieldFieldEditor;
  BOOL searchPanelIsOpen;
}
@property(strong) IBOutlet NSObjectController *courseObjectController;
@property(strong) IBOutlet NSArrayController *personsArrayController;
@property(strong) IBOutlet NSArrayController *theReportsArrayController;
@property(strong) IBOutlet NSView *myOverlayView;
@property(strong) IBOutlet NSView *mainView;
@property(strong) IBOutlet NSSplitView *majorView;
@property(nonatomic, strong) NSManagedObject *course;

- (IBAction)reportBug:(id)sender;
- (IBAction)getHelp:(id)sender;
- (void)setOverlayView:(NSNotification *)note;
- (IBAction)switchToMajorView:(id)sender;
- (IBAction)updatePersonSearch:(id)sender;


- (IBAction)showAddPersonsPanel:(id)sender;

- (IBAction)showFindPanel:(id)sender;
- (IBAction)hideFindPanel:(id)sender;


@end
