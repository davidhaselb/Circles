//
//  DHGRStuentTableViewController.m
//  Groups
//
//  Created by David Haselberger on 18.06.13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRStudentTableViewController.h"
#import "DHGRReport.h"
#import "EmailAddress.h"
#import "PhoneNumber.h"

NSString *const DHGRPersonPBoardType = @"DHGRPersonPBoardType";

@import UniformTypeIdentifiers;

@implementation DHGRStudentTableViewController


@synthesize currentIndexOfStudentList;
@synthesize studentList;
@synthesize students;
@synthesize listOfReports;
@synthesize reports;
@synthesize largerSplitView;


- (instancetype)init {
  if (self = [super init]) {
  }
  return self;
}

#pragma mark Splitview methods (big splitview)
- (CGFloat)splitView:(NSSplitView *)splitView
    constrainMaxCoordinate:(CGFloat)proposedMaximumPosition
               ofSubviewAt:(NSInteger)dividerIndex {
  return proposedMaximumPosition - 200.0;
}

- (CGFloat)splitView:(NSSplitView *)splitView
constrainMinCoordinate:(CGFloat)proposedMinimumPosition
         ofSubviewAt:(NSInteger)dividerIndex {
    return proposedMinimumPosition + 200.0;
}


- (BOOL)splitView:(NSSplitView *)splitView
    canCollapseSubview:(NSView *)subview {
  return NO;
}

- (void)awakeFromNib {
  [self.studentList removeAllToolTips];
  [self.studentList
      registerForDraggedTypes:@[(NSString *)UTTypeVCard.identifier,
                                                   @"ABPeopleUIDsPboardType",
                                                   @"ABGroupsUIDsPboardType",
                                                   DHGRPersonPBoardType,
                                                   [self.students entityName]]];
  [self.studentList setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(reloadAddressbookData:)
             name:kABDatabaseChangedNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(reloadAddressbookData:)
             name:kABDatabaseChangedExternallyNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(reloadTableViewData:)
             name:NSManagedObjectContextObjectsDidChangeNotification
           object:[self.students managedObjectContext]];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(showPersonSheet:)
     name:@"dHGRshowAddPersonsSheet"
     object:nil];
}

- (IBAction)removeSelectedItems:(id)sender {
  NSArray *selectedItems = [self.students selectedObjects];
  int count;
  for (count = 0; count < [selectedItems count]; count++) {
    NSManagedObject *currentObject = selectedItems[count];
    [[self.students managedObjectContext] deleteObject:currentObject];
  }
}

#pragma mark datasource methods (writing to pasteboard)

- (BOOL)tableView:(NSTableView *)tv
    writeRowsWithIndexes:(NSIndexSet *)rowIndexes
            toPasteboard:(NSPasteboard *)pboard {
  NSArray *selectedObjects =
      [[self.students arrangedObjects] objectsAtIndexes:rowIndexes];
  NSData *copyData;
  if ([selectedObjects count] != 0) {
    NSArray *currentReports;
    NSSet* emails;
    NSSet* phones;
    NSUInteger i, count;
    [self selectionShouldChangeInTableView:self.studentList];
    DHGRStudent *newPerson;
    newPerson = (DHGRStudent *)selectedObjects[0];
    emails = [[NSSet alloc] initWithSet:[[newPerson emailAddresses] valueForKey:@"emailDictionary"]];
    phones = [[NSSet alloc] initWithSet:[[newPerson phoneNumbers] valueForKey:@"phoneDictionary"]];
    currentReports =
        [[newPerson mutableSetValueForKey:@"ownsReport"] allObjects];
    count = [currentReports count];
    NSMutableArray *copyReportsArray =
        [NSMutableArray arrayWithCapacity:count];
      for (i = 0; i < count; i++) {
          [copyReportsArray
           addObject:[currentReports[i] reportDictionary]];
      }
      NSDictionary* personDict = [[NSDictionary alloc] initWithDictionary:[newPerson studentDictionary]];
      NSMutableArray* copyArray = [[NSMutableArray alloc] init];
      [copyArray addObject:personDict];
      [copyArray addObject:emails];
      [copyArray addObject:phones];
      [copyArray addObject:copyReportsArray];
      NSArray* myCopyArray = [copyArray copy];
      NSArray* myKeys = [NSArray arrayWithObjects:@"studentDictionary", @"emails", @"phones", @"reportList",nil];
      NSDictionary* copyDictionary = [[NSDictionary alloc] initWithObjects:myCopyArray forKeys:myKeys];
    //[copyObjectsArray addObject:[newPerson studentDictionary]];
    //NSMutableArray *copyStringsArray =
      //[NSMutableArray arrayWithCapacity:[selectedObjects count]];
    //[copyStringsArray addObject:[newPerson displayString]];
    copyData = [NSKeyedArchiver archivedDataWithRootObject:copyDictionary requiringSecureCoding:YES error:nil];
  }
  [pboard declareTypes:@[DHGRPersonPBoardType,
                                                 (NSString *)UTTypeVCard.identifier,
                                                 [self.students entityName]]
                 owner:self];
  if (copyData) {
    [pboard setData:copyData forType:DHGRPersonPBoardType];
  }
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes requiringSecureCoding:YES error:nil];
  [pboard setData:data forType:[self.students entityName]];
  return YES;
}

#pragma mark drag and drop work

- (NSDragOperation)tableView:(NSTableView *)tableView
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(int)row
       proposedDropOperation:(NSTableViewDropOperation)operation {
  if ([info draggingSource] == self.studentList) {
    if (operation == NSTableViewDropOn)
      [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
    return NSDragOperationMove;
  } else {
    if (operation == NSTableViewDropOn)
      [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
    return NSDragOperationMove;
  }
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(int)row
    dropOperation:(NSTableViewDropOperation)operation {
  NSDictionary *bindingInfo = [self.students infoForBinding:@"contentArray"];
  NSMutableOrderedSet *s = [bindingInfo[NSObservedObjectKey]
      mutableOrderedSetValueForKeyPath:bindingInfo[NSObservedKeyPathKey]];
  BOOL success = NO;
  NSPasteboard *pboard = [info draggingPasteboard];
  if ([info draggingSource] == self.studentList) {
    [self selectionShouldChangeInTableView:self.studentList];
    NSData *rowData = [pboard dataForType:[self.students entityName]];
    NSIndexSet *rowIndexes =
      [NSKeyedUnarchiver unarchivedObjectOfClass:[NSIndexSet class] fromData: rowData error:nil];
    if ([rowIndexes firstIndex] > row) {
      [s moveObjectsAtIndexes:rowIndexes toIndex:row];
    } else {
      [s moveObjectsAtIndexes:rowIndexes toIndex:row - [rowIndexes count]];
    }
    success = YES;
  }
  else {
    if([self checkAddressBookAvailability])
    {
        NSArray *groupList = [pboard propertyListForType:@"ABGroupsUIDsPboardType"];
        NSArray *recordList =
            [pboard propertyListForType:@"ABPeopleUIDsPboardType"];
        NSData *movedPerson = [pboard dataForType:DHGRPersonPBoardType];
        NSMutableArray *myPersonsArray = [[NSMutableArray alloc] init];
        if (recordList) {
          for (id adressBookDragDropObject in recordList) {
            NSString *recordId = adressBookDragDropObject;
            ABRecord *record =
                [[ABAddressBook sharedAddressBook] recordForUniqueId:recordId];
            if ([[self.students arrangedObjects] count] > 0) {
              for (id obj in [self.students arrangedObjects]) {
                NSString *comparisonId = [obj valueForKey:@"uniqueAddressBookID"];
                if ([comparisonId isEqualToString:recordId]) {
                  success = NO;
                  break;
                } else {
                  if (![myPersonsArray containsObject:record]) {
                    [myPersonsArray addObject:(ABPerson *)record];
                  }
                  success = YES;
                }
              }
            }
          }
        }
        if (groupList) {
          for (id groupObject in groupList) {
            NSString *recordId = groupObject;
            ABRecord *groupRecord =
                [[ABAddressBook sharedAddressBook] recordForUniqueId:recordId];
            if ([groupRecord isKindOfClass:[ABGroup class]]) {
              NSArray *myMembers = [(ABGroup *)groupRecord members];
              for (ABPerson *currentMember in myMembers) {
                success = YES;
                NSString *uniqueID;
                uniqueID = [currentMember uniqueId];
                if ([[self.students arrangedObjects] count] > 0) {
                  for (id obj in [self.students arrangedObjects]) {
                    NSString *comparisonId =
                        [obj valueForKey:@"uniqueAddressBookID"];

                    if ([comparisonId isEqualToString:uniqueID]) {
                      success = NO;
                      break;
                    } else {
                      if (![myPersonsArray containsObject:currentMember]) {
                        [myPersonsArray addObject:(ABPerson *)currentMember];
                      }
                      success = YES;
                    }
                  }
                }
              }
            }
          }
        }

        if ([myPersonsArray count] > 0) {
          NSSortDescriptor *nameSort = [NSSortDescriptor
              sortDescriptorWithKey:@"firstName"
                          ascending:YES
                           selector:@selector(caseInsensitiveCompare:)];
          NSSortDescriptor *lastNameSort = [NSSortDescriptor
              sortDescriptorWithKey:@"lastName"
                          ascending:YES
                           selector:@selector(caseInsensitiveCompare:)];
          NSArray *mySortedPersonsArray = [myPersonsArray
              sortedArrayUsingDescriptors:
                  @[nameSort, lastNameSort]];

          for (ABPerson *actualMember in mySortedPersonsArray) {
            for (id obj in [self.students arrangedObjects]) {
              NSString *comparisonId = [obj valueForKey:@"uniqueAddressBookID"];

              if ([comparisonId isEqualToString:[actualMember uniqueId]]) {
                success = NO;
                break;
              } else {
                success = YES;
              }
            }

            if (success) {
              NSManagedObject *student = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Student"
                           inManagedObjectContext:[self.students managedObjectContext]];
              NSManagedObject *course;
              NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
              NSError *fetchError = nil;
              NSArray *fetchResults;
              NSEntityDescription *entity = [NSEntityDescription
                           entityForName:@"Course"
                  inManagedObjectContext:[self.students managedObjectContext]];
              [fetchRequest setEntity:entity];
              fetchResults =
                  [[self.students managedObjectContext] executeFetchRequest:fetchRequest
                                                                 error:&fetchError];
              if ((fetchResults != nil) && ([fetchResults count] == 1) &&
                  (fetchError == nil)) {
                course = fetchResults[0];
              }
              if (fetchError != nil) {
                NSLog(@"%@", fetchError);
              }
    #pragma mark InsertPerson
              NSString *firstName;
              NSString *lastName;
              NSString *uniqueID;
              NSData *portraitData;
              firstName = [actualMember valueForProperty:@"firstName"];
              lastName = [actualMember valueForProperty:@"lastName"];
              uniqueID = [actualMember uniqueId];
              portraitData = [(ABPerson *)actualMember imageData];
              [student setValue:firstName forKey:@"firstName"];
              [student setValue:lastName forKey:@"lastName"];
              [student setValue:uniqueID forKey:@"uniqueAddressBookID"];
              [student setValue:portraitData forKey:@"portrait"];
              [student setValue:course forKey:@"takesCourse"];
              [self importEmailsFromABPerson:actualMember toMine:(DHGRStudent *)student];
              [self importPhonesFromABPerson:actualMember toMine:(DHGRStudent *)student];
              [self.students rearrangeObjects];
              success = YES;
            }
          }
        }

        if (movedPerson) {
          NSManagedObjectContext *moc = [self.students managedObjectContext];
          NSDictionary *insertedPersonsDictionary =
            [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:movedPerson error:nil];
          //, count = [insertedPersonsArray count];

          if (insertedPersonsDictionary) {
            success = NO;
            NSString *recordId = [[insertedPersonsDictionary objectForKey:@"studentDictionary"]
                valueForKey:@"uniqueAddressBookID"];

            if ([[self.students arrangedObjects] count] > 0) {
              for (id obj in [self.students arrangedObjects]) {
                NSString *comparisonId = [obj valueForKey:@"uniqueAddressBookID"];

                if ([comparisonId isEqualToString:recordId]) {
                  success = NO;
                  break;
                } else {
                  success = YES;
                }
              }
              if (success) {
                DHGRStudent *newStudent;
                newStudent = (DHGRStudent *)
                    [NSEntityDescription insertNewObjectForEntityForName:@"Student"
                                                  inManagedObjectContext:moc];
                
                [newStudent setValuesForKeysWithDictionary:[insertedPersonsDictionary objectForKey:@"studentDictionary"]];
                NSArray* reportsList = [[NSArray alloc] initWithArray:[insertedPersonsDictionary objectForKey:@"reportList"]];
                NSMutableSet *reportsSet = [NSMutableSet setWithCapacity:[reportsList count]];
                NSUInteger i = 0;
                NSUInteger count = [reportsList count];
                for (i = 0; i < count; i++) {
                  DHGRReport *newlyAddedReport;
                  newlyAddedReport = (DHGRReport *)
                      [NSEntityDescription insertNewObjectForEntityForName:@"Report"
                                                    inManagedObjectContext:moc];
                  [newlyAddedReport
                      setValuesForKeysWithDictionary:reportsList[i]];
                  [reportsSet addObject:newlyAddedReport];
                }
                NSSet* emailDictionariesSet = [insertedPersonsDictionary objectForKey:@"emails"];
                NSMutableSet* emailSet =[NSMutableSet setWithCapacity:[emailDictionariesSet count]];
                  for (NSDictionary* emailDictionary in emailDictionariesSet) {
                      EmailAddress* address = (EmailAddress *)[NSEntityDescription insertNewObjectForEntityForName:@"EmailAddress"
                                                                            inManagedObjectContext:moc];
                      [address setValuesForKeysWithDictionary:emailDictionary];
                      [emailSet addObject:address];
                  }
                  NSSet* phoneDictionariesSet = [insertedPersonsDictionary objectForKey:@"phones"];
                  NSMutableSet* phoneSet =[NSMutableSet setWithCapacity:[phoneDictionariesSet count]];
                  for (NSDictionary* phoneDictionary in phoneDictionariesSet) {
                      PhoneNumber* number = (PhoneNumber *)[NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber"
                                                                                            inManagedObjectContext:moc];
                      [number setValuesForKeysWithDictionary:phoneDictionary];
                      [phoneSet addObject:number];
                  }
                [newStudent setValue:[reportsSet copy] forKey:@"ownsReport"];
                [newStudent setEmailAddresses:[emailSet copy]];
                [newStudent setPhoneNumbers:[phoneSet copy]];
                NSManagedObject *course;
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSError *fetchError = nil;
                NSArray *fetchResults;
                NSEntityDescription *entity = [NSEntityDescription
                             entityForName:@"Course"
                    inManagedObjectContext:[self.students managedObjectContext]];
                [fetchRequest setEntity:entity];
                fetchResults = [[self.students managedObjectContext]
                    executeFetchRequest:fetchRequest
                                  error:&fetchError];
                if ((fetchResults != nil) && ([fetchResults count] == 1) &&
                    (fetchError == nil)) {
                  course = fetchResults[0];
                }
                if (fetchError != nil) {
                  NSLog(@"%@", fetchError);
                }
                [newStudent setValue:course forKey:@"takesCourse"];
                success = YES;
              }
            }
          }
        }
      }
  }
  [self.students rearrangeObjects];
  [self reloadTableViewData:nil];
  return success;
}

- (void)reloadAddressbookData:(NSNotification *)notification {
  for (id obj in [self.students arrangedObjects]) {
    NSString *recordId = [obj valueForKey:@"uniqueAddressBookID"];
    ABRecord *record =
        [[ABAddressBook sharedAddressBook] recordForUniqueId:recordId];
    if (record) {
        [self setPropertiesOf:(ABPerson *)record forPerson:obj];
    }
    else
    {
      ABAddressBook* addressBook = [ABAddressBook sharedAddressBook] ;
      ABSearchElement* firstNameIsIdentical = [ABPerson searchElementForProperty:kABFirstNameProperty  label:nil  key:nil  value:[obj valueForKey:@"firstName"]  comparison:kABEqualCaseInsensitive ];
      ABSearchElement* lastNameIsIdentical = [ABPerson searchElementForProperty:kABLastNameProperty  label:nil  key:nil  value:[obj valueForKey:@"lastName"]  comparison:kABEqualCaseInsensitive ];
      
        NSSet* phoneNumbers = [obj valueForKey:@"phoneNumbers"];
        NSMutableArray* searchElements = [[NSMutableArray alloc] initWithObjects:firstNameIsIdentical, lastNameIsIdentical, nil];
        for (NSManagedObject* number in phoneNumbers) {
            [searchElements addObject:[ABPerson searchElementForProperty:kABPhoneProperty  label:nil  key:nil  value:[number valueForKey:@"phoneNumber"]  comparison:kABEqual]];
        }
        NSSet* emailAddresses = [obj valueForKey:@"emailAddresses"];
        for (NSManagedObject* email in emailAddresses) {
            [searchElements addObject:[ABPerson searchElementForProperty:kABEmailProperty  label:nil  key:nil  value:[email valueForKey:@"email"]  comparison:kABEqual]];
        }
        ABSearchElement* isSamePersonEntry = [ABSearchElement searchElementForConjunction:kABSearchAnd children:[searchElements copy]];
        NSArray* personsFound = [addressBook recordsMatchingSearchElement:isSamePersonEntry];
        
        if ([personsFound count] == 1)
        {
            [self setPropertiesOf:[personsFound objectAtIndex:0] forPerson:obj];
        }
        else if ([personsFound count] > 1)
        {
            NSMutableArray* personsWithImages = [[NSMutableArray alloc] init];
            for (ABPerson* person in personsFound) {
                NSImage* picture = [[NSImage alloc] initWithData:[person imageData]];
                if (picture)
                {
                    [personsWithImages addObject:person];
                }
            }
            if ([personsWithImages count] > 0)
            {
                if ([personsWithImages count] == 1)
                {
                    [self setPropertiesOf:[personsWithImages objectAtIndex:0] forPerson:obj];
                }
                else
                {
                    NSMutableArray* modificationDates = [[NSMutableArray alloc] init];
                    for (ABPerson* person in personsWithImages)
                    {
                        NSString* contactId = [person uniqueId];
                        NSDate* modificationDate = [person valueForProperty:kABModificationDateProperty];
//                        ABMultiValue* emails = [person valueForProperty:kABEmailProperty];
//                        ABMultiValue* phones = [person valueForProperty:kABPhoneProperty];
//                        if (!emails && !phones)
//                        {
//                            [self setPropertiesOf:person forPerson:obj];
//                        }
//                        else
//                        {
                            [modificationDates addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:contactId,modificationDate, nil] forKeys:[NSArray arrayWithObjects:@"contactID",@"modificationDate", nil]]];
                        //}
                    }
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:TRUE];
                    [modificationDates sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    [self setPropertiesOf:(ABPerson *)[addressBook recordForUniqueId:[[modificationDates firstObject] valueForKey:@"contactID"]] forPerson:obj];
                }
            }
            else
            {
                NSMutableArray* modificationDates = [[NSMutableArray alloc] init];
                for (ABPerson* person in personsFound)
                {
                    NSString* contactId = [person uniqueId];
                    NSDate* modificationDate = [person valueForProperty:kABModificationDateProperty];
                    [modificationDates addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:contactId,modificationDate, nil] forKeys:[NSArray arrayWithObjects:@"contactID",@"modificationDate", nil]]];
                }
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:TRUE];
                [modificationDates sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                [self setPropertiesOf:(ABPerson *)[addressBook recordForUniqueId:[[modificationDates firstObject] valueForKey:@"contactID"]] forPerson:obj];            }
        }
        
    }
  }
  [self.studentList reloadData];
}

#pragma mark comparison to addressbook
-(void)setPropertiesOf:(ABPerson *)record forPerson:(DHGRStudent *)person
{
    NSString *firstName;
    NSString *lastName;
    NSData *portraitData;
    firstName = [record valueForProperty:@"firstName"];
    lastName = [record valueForProperty:@"lastName"];
    portraitData = [(ABPerson *)record imageData];
    NSString *recordId = [record uniqueId];
    [person setValue:firstName forKey:@"firstName"];
    [person setValue:lastName forKey:@"lastName"];
    [person setValue:recordId forKey:@"uniqueAddressBookID"];
    [person setValue:portraitData forKey:@"portrait"];}

#pragma mark selection changes
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView {
  if ([aTableView isKindOfClass:[DHGRStudentTableView class]]) {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver =
        [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
    if ([self.reports selectionIndexes]) {
      [archiver encodeRootObject:[self.reports selectionIndexes]];
      NSData *dataToBeInserted = [data copy];
      [[[self.students selectedObjects] firstObject]
          setValue:dataToBeInserted
            forKey:@"currentReportSelection"];
    }
  }

  return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
  NSTableView *myNotifTabView = [aNotification object];
  NSIndexSet *theSelection = [self.students selectionIndexes];
  if ([myNotifTabView isKindOfClass:[DHGRStudentTableView class]] &&
      theSelection != currentIndexOfStudentList) {
    NSIndexSet *toBeChanged = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSIndexSet class] fromData: [[[self.students selectedObjects] firstObject] valueForKey:@"currentReportSelection"]error:nil];
   // NSInteger theCount = [[self.reports arrangedObjects] count];
    NSInteger numberOfRows = [self.listOfReports numberOfRows];
    if (numberOfRows > 0 && myNotifTabView != nil) {
      if (toBeChanged != nil) {
        [self.reports setSelectionIndexes:toBeChanged];
         NSInteger toScrollTo = [toBeChanged firstIndex];
         [self.listOfReports scrollRowToVisible:toScrollTo];
         [self.listOfReports selectRowIndexes:toBeChanged byExtendingSelection:NO];
        currentIndexOfStudentList = [self.students selectionIndexes];
      }
    }else
    {
         [self.listOfReports scrollRowToVisible:0];
    }
  }
}

#pragma mark doubleClick on Person TableView

- (IBAction)peopleRowDoubleClicked:(id)sender {
  if ([[self.students arrangedObjects] count] > 0) {
    NSString *uniqueID =
        [[self.students arrangedObjects][[self.studentList selectedRow]]
            valueForKey:@"uniqueAddressBookID"];
    NSString *urlString =
        [NSString stringWithFormat:@"addressbook://%@", uniqueID];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]];
  }
}

#pragma mark modalPeoplePickerPanel
- (BOOL)checkAddressBookAvailability
{
    if ([ABAddressBook sharedAddressBook] != nil) {
        return YES;
    }else{
        NSLog(@"No Addressbook available. Access denied.");
        [[NSWorkspace sharedWorkspace] openURL:
         [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Contacts"]];
        return NO;
    }
}

- (void)showPersonSheet:(NSNotification *)note
{
    if ([[[self studentList] window] isKeyWindow]) {
        [self openPeoplePickerSheet:[self studentList]];
    }
}


- (IBAction)openPeoplePickerSheet:(id)sender {
     if([self checkAddressBookAvailability])
     {
        [[sender window] beginSheet:thePeoplePanel completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseOK) {
                NSArray *recordsToInsert = [self personArrayWithNoDublicatesFromArray:[self->peoplePicker selectedRecords]];
                NSArray *myGroupsToInsert = [self->peoplePicker selectedGroups];
                NSManagedObject *course;
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSError *fetchError = nil;
                NSArray *fetchResults;
                NSEntityDescription *entity =
                [NSEntityDescription entityForName:@"Course"
                            inManagedObjectContext:[self.students managedObjectContext]];
                [fetchRequest setEntity:entity];
                fetchResults =
                [[self.students managedObjectContext] executeFetchRequest:fetchRequest
                                                                    error:&fetchError];
                if ((fetchResults != nil) && ([fetchResults count] == 1) &&
                    (fetchError == nil)) {
                    course = fetchResults[0];
                }
                if (fetchError != nil) {
                    NSLog(@"%@", fetchError);
                }
                for (ABPerson* record in recordsToInsert) {
                    if ([record isKindOfClass:[ABPerson class]]) {
                        
                        BOOL toInsert = YES;
                        NSString *firstName;
                        NSString *lastName;
                        NSString *uniqueID;
                        NSData *portraitData;
                        firstName = [record valueForProperty:@"firstName"];
                        lastName = [record valueForProperty:@"lastName"];
                        uniqueID = [record uniqueId];
                        portraitData = [(ABPerson *)record imageData];
                        if ([[self.students arrangedObjects] count] > 0) {
                            for (id obj in [self.students arrangedObjects]) {
                                NSString *comparisonId = [obj valueForKey:@"uniqueAddressBookID"];
                                
                                if ([comparisonId isEqualToString:uniqueID]) {
                                    toInsert = NO;
                                    break;
                                }
                            }
                        }
                        if (toInsert) {
    #pragma mark InsertPerson
                            NSManagedObject *student = [NSEntityDescription
                                                        insertNewObjectForEntityForName:@"Student"
                                                        inManagedObjectContext:[self.students managedObjectContext]];
                            [student setValue:firstName forKey:@"firstName"];
                            [student setValue:lastName forKey:@"lastName"];
                            [student setValue:uniqueID forKey:@"uniqueAddressBookID"];
                            [student setValue:portraitData forKey:@"portrait"];
                            [student setValue:course forKey:@"takesCourse"];
                            [self importEmailsFromABPerson:record toMine:(DHGRStudent *)student];
                            [self importPhonesFromABPerson:record toMine:(DHGRStudent *)student];
                            [self.students rearrangeObjects];
                            [self reloadTableViewData:nil];
                        }
                    }
                }
                
                for (ABGroup* record in myGroupsToInsert) {
                    if ([record isKindOfClass:[ABGroup class]] && [recordsToInsert count] == 0) {
                        NSArray *myMembers = [record members];
                        NSSortDescriptor *nameSort = [NSSortDescriptor
                                                      sortDescriptorWithKey:@"firstName"
                                                      ascending:YES
                                                      selector:@selector(caseInsensitiveCompare:)];
                        NSSortDescriptor *lastNameSort = [NSSortDescriptor
                                                          sortDescriptorWithKey:@"lastName"
                                                          ascending:YES
                                                          selector:@selector(caseInsensitiveCompare:)];
                        NSArray *mySortedMemberArray = [myMembers
                                                        sortedArrayUsingDescriptors:
                                                        @[nameSort, lastNameSort]];
                        for (ABPerson *currentMember in mySortedMemberArray) {
                            BOOL toInsert = YES;
                            NSString *firstName;
                            NSString *lastName;
                            NSString *uniqueID;
                            NSData *portraitData;
                            firstName = [currentMember valueForProperty:@"firstName"];
                            lastName = [currentMember valueForProperty:@"lastName"];
                            uniqueID = [currentMember uniqueId];
                            portraitData = [(ABPerson *)currentMember imageData];
                            
                            if ([[self.students arrangedObjects] count] > 0) {
                                for (id obj in [self.students arrangedObjects]) {
                                    NSString *comparisonId = [obj valueForKey:@"uniqueAddressBookID"];
                                    
                                    if ([comparisonId isEqualToString:uniqueID]) {
                                        toInsert = NO;
                                        break;
                                    }
                                }
                            }
                            
                            if (toInsert) {
    #pragma mark InsertPerson
                                NSManagedObject *student = [NSEntityDescription
                                                            insertNewObjectForEntityForName:@"Student"
                                                            inManagedObjectContext:[self.students
                                                                                    managedObjectContext]];
                                [student setValue:firstName forKey:@"firstName"];
                                [student setValue:lastName forKey:@"lastName"];
                                [student setValue:uniqueID forKey:@"uniqueAddressBookID"];
                                [student setValue:portraitData forKey:@"portrait"];
                                [student setValue:course forKey:@"takesCourse"];
                                [self importEmailsFromABPerson:currentMember toMine:(DHGRStudent *)student];
                                [self importPhonesFromABPerson:currentMember toMine:(DHGRStudent *)student];
                                [self.students rearrangeObjects];
                                [self reloadTableViewData:nil];
                            }
                        }
                    }
                }
                
                
            }

        }];
     }
}

- (IBAction)theSheetOK:(id)sender {
  [[thePeoplePanel sheetParent] endSheet:thePeoplePanel returnCode:NSModalResponseOK];
  [thePeoplePanel orderOut:nil];
}

- (IBAction)theSheetCancel:(id)sender {
  [[thePeoplePanel sheetParent] endSheet:thePeoplePanel returnCode:NSModalResponseCancel];
  [thePeoplePanel orderOut:nil];
}


- (NSArray *)personArrayWithNoDublicatesFromArray:(NSArray *)array
{
    NSMutableArray* dictArray = [[NSMutableArray alloc] init];
    NSMutableArray* toKeep = [[NSMutableArray alloc] init];

    for (ABPerson* person in array)
    {
        NSString* contactId = [person uniqueId];
        NSDate* modificationDate = [person valueForProperty:kABModificationDateProperty];
        ABMultiValue* emails = [person valueForProperty:kABEmailProperty];
        NSMutableDictionary* emailDictionary = [[NSMutableDictionary alloc] init];
        for ( NSUInteger i = 0, max = [emails count]; i < max; i++ )
        {
            NSString * label = [emails labelAtIndex: i];
            NSString * email = [emails valueAtIndex: i];
            if ( label == nil || email == nil )
                continue;
            [emailDictionary setValue:email forKey:label];
        }
        ABMultiValue* phones = [person valueForProperty:kABPhoneProperty];
        NSMutableDictionary* phoneDictionary = [[NSMutableDictionary alloc] init];
        for ( NSUInteger i = 0, max = [phones count]; i < max; i++ )
        {
            NSString * label = [phones labelAtIndex: i];
            NSString * phone = [phones valueAtIndex: i];
            if ( label == nil || phone == nil )
                continue;
            [phoneDictionary setValue:phone forKey:label];
        }
        NSString *firstName;
        NSString *lastName;
        NSData *portraitData;
        firstName = [person valueForProperty:@"firstName"];
        lastName = [person valueForProperty:@"lastName"];
        NSMutableString *displayString = [NSMutableString stringWithCapacity:0];
        if (firstName) {
            [displayString appendString:firstName];
        }
        if (firstName && lastName) {
            [displayString appendFormat:@" "];
        }
        if (lastName) {
            [displayString appendString:lastName];
        }
        portraitData = [(ABPerson *)person imageData];
        NSMutableDictionary* personValues = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:contactId, modificationDate, nil] forKeys:[NSArray arrayWithObjects:@"contactId", @"modificationDate", nil]];
        if (displayString) {
            [personValues setObject:displayString forKey:@"displayString"];
        }
        if (emailDictionary) {
            [personValues setObject:emailDictionary forKey:@"emails"];
        }
        if (phoneDictionary) {
            [personValues setObject:phoneDictionary forKey:@"phones"];
        }
        if (portraitData) {
            [personValues setObject:portraitData forKey:@"portraitData"];
        }
        [dictArray addObject:personValues];
    }
    NSMutableSet* withoutDublicateNames = [NSMutableSet setWithArray:[dictArray valueForKey:@"displayString"]];
    for (NSString* name in withoutDublicateNames)
    {
        NSPredicate* nameSearch = [NSPredicate predicateWithFormat:@"displayString like %@", name];
        NSArray* nameArray = [dictArray filteredArrayUsingPredicate:nameSearch];
        if ([nameArray count] > 1)
        {
            for (id obj in nameArray)
            {
                NSPredicate* mailsAndPhones = [NSPredicate predicateWithFormat:@"emails == %@ AND phones == %@", [obj valueForKey:@"emails"], [obj valueForKey:@"phones"]];
                NSArray* sameMailsAndPhones = [nameArray filteredArrayUsingPredicate:mailsAndPhones];
                if ([sameMailsAndPhones count] == 1) {
                    [toKeep addObject:[sameMailsAndPhones objectAtIndex:0]];
                }
                else if ([sameMailsAndPhones count] > 1)
                {
                    NSMutableArray* personsWithImages = [[NSMutableArray alloc] init];
                    for (id person in sameMailsAndPhones)
                    {
                        NSImage* picture = [[NSImage alloc] initWithData:[person objectForKey:@"portraitData"]];
                        if (picture) {
                            [personsWithImages addObject:person];
                        }
                    }
                        if ([personsWithImages count] > 0)
                        {
                            if ([personsWithImages count] == 1)
                            {
                                [toKeep addObject:[personsWithImages objectAtIndex:0]];
                            }
                            else
                            {
                                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:TRUE];
                                [personsWithImages sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                [toKeep addObject:[personsWithImages firstObject]];
                            }
                        }
                        else
                        {
                            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:TRUE];
                            NSMutableArray* mailsAndPhonesArray = [sameMailsAndPhones mutableCopy];
                            [mailsAndPhonesArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                            [toKeep addObject:[mailsAndPhonesArray firstObject]];
                        }
                    
                }
            }
        }
        else if ([nameArray count] == 1)
        {
            [toKeep addObject:[nameArray objectAtIndex:0]];
        }
    
    }
    NSMutableArray* returnedArray = [[NSMutableArray alloc] init];
    if ([toKeep count] > 0)
    {
        NSSet* idSet = [NSSet setWithArray:[toKeep valueForKeyPath:@"contactId"]];
        for (NSString* currentId in idSet)
        {
            ABRecord *record =
            [[ABAddressBook sharedAddressBook] recordForUniqueId:currentId];
            [returnedArray addObject:record];
        }
    }
    return [returnedArray copy];
}




- (void)reloadTableViewData:(NSNotification *)notification {
  NSIndexSet *index = [self.studentList selectedRowIndexes];
  [studentList reloadData];
  [studentList selectRowIndexes:index byExtendingSelection:NO];
}


- (void)dealloc
{
    [self.largerSplitView setDelegate:nil];
    self.largerSplitView = nil;
    self.listOfReports = nil;
    [self.studentList setDataSource:nil];
    [self.studentList setDelegate:nil];
    self.studentList = nil;
    [self.reports setContent:nil];
    self.reports = nil;
    [self.students setContent:nil];
    self.students = nil;
    self.currentIndexOfStudentList = nil;
}

#pragma mark addressbook importers

- (void)importEmailsFromABPerson:(ABPerson *)abPerson toMine:(DHGRStudent *)myPerson
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmailAddress"
                                              inManagedObjectContext:[self.students managedObjectContext]];
    ABMultiValue * abEmails = [abPerson valueForProperty: kABEmailProperty];
    for ( NSUInteger i = 0, max = [abEmails count]; i < max; i++ )
    {
        NSString * label = [abEmails labelAtIndex: i];
        NSString * email = [abEmails valueAtIndex: i];
        if ( label == nil || email == nil )
            continue;
        EmailAddress * e = [[EmailAddress alloc] initWithEntity: entity
                                 insertIntoManagedObjectContext: [self.students managedObjectContext]];
        e.label = ABLocalizedPropertyOrLabel(label);
        e.email = email;
        e.person = myPerson;
        NSError * validationError = nil;
        if ( [e validateForUpdate: &validationError] == NO )
        {
            [[self.students managedObjectContext] performBlockAndWait: ^{
                [[self.students managedObjectContext] deleteObject: e];
            }];
            continue;
        }
    }
}

- (void)importPhonesFromABPerson:(ABPerson *)abPerson toMine:(DHGRStudent *)myPerson
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhoneNumber"
                                              inManagedObjectContext:[self.students managedObjectContext]];
    ABMultiValue * abPhones = [abPerson valueForProperty: kABPhoneProperty];
    for ( NSUInteger i = 0, max = [abPhones count]; i < max; i++ )
    {
        NSString * label = [abPhones labelAtIndex: i];
        NSString * phone = [abPhones valueAtIndex: i];
        if ( label == nil || phone == nil )
            continue;
        PhoneNumber *p = [[PhoneNumber alloc] initWithEntity:entity
                              insertIntoManagedObjectContext:[self.students managedObjectContext]];
        p.label = ABLocalizedPropertyOrLabel(label);
        p.phoneNumber = phone;
        p.person = myPerson;
        NSError * validationError = nil;
        if ( [p validateForUpdate: &validationError] == NO )
        {
            [[self.students managedObjectContext] performBlockAndWait: ^{
                [[self.students managedObjectContext] deleteObject: p];
            }];
            continue;
        }
    }
}





@end
