//
//  DHGRStudentTableView.m
//  Groups
//
//  Created by David Haselberger on 14.06.13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRStudentTableView.h"
#import "DHGRStudent.h"
#import "EmailAddress.h"
#import "PhoneNumber.h"
#import "DHGRReport.h"

@interface DHGRStudentTableView (privateMethods)

- (void)alertDidEnd:(NSAlert *)alert
         returnCode:(NSInteger)returnCode
        contextInfo:(void *)contextInfo;
- (void)_deleteRecord:(NSManagedObject *)obj;

@end

@implementation DHGRStudentTableView

- (void)awakeFromNib {
  [self setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
}

- (void)keyDown:(NSEvent *)event {
  BOOL keyWasHandled = NO;
  if ([event keyCode] == 51) {
    [self deleteStudentEntry:self];
    keyWasHandled = YES;
  }
  if ([event keyCode] == 49) {
    if ([[myStudentArrayController arrangedObjects] count] > 0) {
      NSString *uniqueID = [[myStudentArrayController arrangedObjects][[self selectedRow]] valueForKey:@"uniqueAddressBookID"];
      NSString *urlString =
          [NSString stringWithFormat:@"addressbook://%@", uniqueID];
      [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
    }
    keyWasHandled = YES;
  }

  if (!keyWasHandled) {
    [super keyDown:event];
  }
}




#pragma mark deletion
- (IBAction)deleteStudentEntry:(id)sender {
  NSManagedObject *selectedStudentRecord =
      [myStudentArrayController selectedObjects][0];
  NSString *studentName = [NSString
      stringWithFormat:@"%@",
                       [selectedStudentRecord valueForKey:@"displayString"]];
  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"Delete"];
  [alert addButtonWithTitle:@"Cancel"];
  [alert setMessageText:[NSString stringWithFormat:@"Remove %@ from Group?",
                                                   studentName]];
  NSImage *newImage = [NSImage alloc];
  if ([selectedStudentRecord valueForKey:@"portrait"]) {
    newImage =
        [newImage initWithData:[selectedStudentRecord valueForKey:@"portrait"]];
  } else {
    newImage = [NSImage imageNamed:NSImageNameUser];
  }
  NSImage *iconImage = [DHGRImage roundCorners:newImage];

  [alert setIcon:iconImage];
    [alert setAlertStyle:NSAlertStyleWarning];
  [alert beginSheetModalForWindow:[self window]
                completionHandler:^(NSInteger result) {
                    if (result == NSAlertFirstButtonReturn) {
                      [self _deleteRecord:selectedStudentRecord];
                    }
                }];
}

- (void)_deleteRecord:(NSManagedObject *)obj {

 NSOrderedSet* myReports = [(DHGRStudent *)obj valueForKey:@"ownsReport"];
 for (DHGRReport * theReport in myReports)
 {
    [[myStudentArrayController managedObjectContext] deleteObject:[[myStudentArrayController managedObjectContext] objectWithID:theReport.objectID]];
  }
    NSSet* myEmailAddresses = [(DHGRStudent *)obj valueForKey:@"emailAddresses"];
    for (EmailAddress* theMailAddress in myEmailAddresses)
    {
        [[myStudentArrayController managedObjectContext] deleteObject:[[myStudentArrayController managedObjectContext] objectWithID:theMailAddress.objectID]];
    }
    NSSet* myPhoneNumbers = [(DHGRStudent *)obj valueForKey:@"phoneNumbers"];
    for (PhoneNumber* thePhoneNumber in myPhoneNumbers)
    {
        [[myStudentArrayController managedObjectContext] deleteObject:[[myStudentArrayController managedObjectContext] objectWithID:thePhoneNumber.objectID]];
    }
  [[myStudentArrayController managedObjectContext] deleteObject:obj];
}

@end
