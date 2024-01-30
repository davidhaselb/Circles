//
//  DHGRDocument.m
//  Groups
//
//  Created by David Haselberger on 01.06.13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRDocument.h"
#import "DHGRReportTextField.h"
#import "DHGRReportTableView.h"
#import "DHGRStudentTableView.h"
#import "DHGRInsertFieldEditor.h"
#import "DHGRSearchFieldFieldEditor.h"
#import "DHGRStudent.h"
#import "DHGRReport.h"
#import "DHGRExportController.h"
#import "EmailAddress.h"
#import "PhoneNumber.h"
#import "PrintTextView.h"
#import "DHGRImage.h"
#import "DHGRRibbonBGView.h"

NSString *DHGRPersonsPBoardType = @"DHGRPersonsPBoardType";
NSString *DHGRReportsPBoardType = @"DHGRReportsPBoardType";

@interface NSManagedObject (CourseAccessors)
@property(retain) NSString *title;
@property(retain) NSString *institution;
@property(retain) NSString *notes;
@property(retain) NSImage *picture;
@end

@implementation DHGRDocument

@synthesize course;
@synthesize courseObjectController;
@synthesize personsArrayController;
@synthesize theReportsArrayController;
@synthesize myOverlayView;
@synthesize majorView;
@synthesize mainView;



+ (BOOL)autosavesInPlace {
  return YES;
}

+ (BOOL)preservesVersions {
  return YES;
}

- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (instancetype)initWithType:(NSString *)type error:(NSError **)error {
  self = [super initWithType:type error:error];
  if (self != nil) {
    [[self.managedObjectContext undoManager] disableUndoRegistration];
    self.course = [NSEntityDescription
        insertNewObjectForEntityForName:@"Course"
                 inManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext processPendingChanges];
    [[self.managedObjectContext undoManager] enableUndoRegistration];
    searchPanelIsOpen = NO;
  }
  return self;
}

-(void)awakeFromNib
{
    
}

- (NSManagedObject *)course {
  if (course != nil) {
    return course;
  }
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSError *fetchError = nil;
  NSEntityDescription *entity =
      [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  NSArray *fetchResults =
      [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
  if ((fetchResults != nil) && ([fetchResults count] == 1) &&
      (fetchError == nil)) {
    course = fetchResults[0];
    self.course = course;
    return course;
  }
  if (fetchError != nil) {
    [self presentError:fetchError];
  } else {
  }
  return nil;
}

- (NSString *)windowNibName {
  return @"DHGRDocument";
}

- (void)makeWindowControllers {
    NSWindowController *mainWindowController = [[NSWindowController alloc] initWithWindowNibName:@"DHGRDocument" owner:self];
    
    [mainWindowController setShouldCloseDocument:YES];
    [self addWindowController:mainWindowController];
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
  [self.course addObserver:self
                forKeyPath:@"includesStudent"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
  [super windowControllerDidLoadNib:aController];
  [myOverlayView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [myOverlayView setFrame:[mainView frame]];
  [self observeValueForKeyPath:@"includesStudent"
                      ofObject:self.course
                      change:nil
                      context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"includesStudent"]) {
    NSArray *personsArray =
        [[self.course mutableOrderedSetValueForKey:@"includesStudent"] array];
    if (personsArray) {
      if ([personsArray count] > 0) {
        [self switchToMajorView:nil];
      } else {
        [self setOverlayView:nil];
      }
    }
  }
}

- (IBAction)switchToMajorView:(id)sender {
  if ([[mainView subviews] containsObject:myOverlayView]) {
    NSRect mainRect = [mainView frame];
    [majorView
        setFrame:NSMakeRect(mainRect.origin.x, mainRect.origin.y + 32.0,
                            mainRect.size.width, mainRect.size.height - 32.0)];
    [majorView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [myOverlayView setHidden:YES];
  }
  [majorView setHidden:NO];
}

- (void)setOverlayView:(NSNotification *)note {
  if ([[mainView subviews] containsObject:majorView]) {
    [majorView setHidden:YES];
  }
  if (![[mainView subviews] containsObject:myOverlayView]) {
    NSRect mainRect = [mainView frame];
    [myOverlayView
        setFrame:NSMakeRect(mainRect.origin.x, mainRect.origin.y + 32.0,
                            mainRect.size.width, mainRect.size.height - 32.0)];
    [myOverlayView
        setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [mainView addSubview:myOverlayView];
  }
}

#pragma mark reverting

- (BOOL)revertToContentsOfURL:(NSURL *)inAbsoluteURL
                       ofType:(NSString *)inTypeName
                        error:(NSError **)outError {
    self.course = nil;
    self.myOverlayView = nil;
    self.mainView = nil;
    self.majorView = nil;
    [courseObjectController setContent:nil];
    self.courseObjectController = nil;
    [personsArrayController setContent:nil];
    self.personsArrayController = nil;
    [theReportsArrayController setContent:nil];
    self.theReportsArrayController = nil;
    [[[self windowControllers][0] window] close];
    [self close];
    BOOL reverted = [super revertToContentsOfURL:inAbsoluteURL
                                        ofType:inTypeName
                                         error:outError];
    if (reverted) {
    }
    return YES;
}

#pragma mark saving

- (void)saveToURL:(NSURL *)url
               ofType:(NSString *)typeName
     forSaveOperation:(NSSaveOperationType)saveOperation
    completionHandler:(void (^)(NSError *errorOrNil))completionHandler {
  [super saveToURL:url
                 ofType:typeName
       forSaveOperation:saveOperation
      completionHandler:completionHandler];
}

#pragma mark Fieldeditor

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject {
  if ([anObject isKindOfClass:[DHGRReportTextField class]]) {
    if (!myCustomFieldEditor) {
      myCustomFieldEditor = [[DHGRInsertFieldEditor alloc] init];
      [myCustomFieldEditor setFieldEditor:YES];
    }
    return myCustomFieldEditor;
  }
  if ([anObject isKindOfClass:[NSSearchField class]]) {
    if (!mySearchFieldFieldEditor) {
      mySearchFieldFieldEditor = [[DHGRSearchFieldFieldEditor alloc] init];
      [mySearchFieldFieldEditor setFieldEditor:YES];
    }
    return mySearchFieldFieldEditor;
  }

  return nil;
}

#pragma mark metadata

- (BOOL)setMetadataForStoreAtURL:(NSURL *)url {
  NSPersistentStoreCoordinator *psc =
      [[self managedObjectContext] persistentStoreCoordinator];
  NSPersistentStore *pStore = [psc persistentStoreForURL:url];
  NSMutableArray *personIDs = [[NSMutableArray alloc] init];
  NSManagedObjectContext *moc = [self managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setAffectedStores:@[pStore]];
  NSError *fetchError = nil;
  NSArray *fetchResults;
  NSEntityDescription *entity =
      [NSEntityDescription entityForName:@"Course" inManagedObjectContext:moc];
  [fetchRequest setEntity:entity];
  fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
  if ((fetchResults != nil) && ([fetchResults count] == 1) &&
      (fetchError == nil)) {
    NSManagedObject *myGroup = fetchResults[0];
    NSArray *myPersons = [[myGroup valueForKey:@"includesStudent"] array];
    for (NSManagedObject *person in myPersons) {
      NSString *first = [person valueForKey:@"firstName"];
      NSString *last = [person valueForKey:@"lastName"];
      [personIDs addObject:[NSString stringWithFormat:@"%@ %@", first, last]];
    }
  }
  if (pStore != nil) {
    NSDictionary *metadata = [psc metadataForPersistentStore:pStore];
    if (metadata == nil) {
      // metadata = [NSMutableDictionary dictionary];
    } else {
      NSError *error;
      NSMutableDictionary *newMetadata = [metadata mutableCopy];
      newMetadata[(NSString *)kMDItemContactKeywords] = [personIDs copy];
      [NSPersistentStore setMetadata:newMetadata
           forPersistentStoreWithURL:[pStore URL]
                               error:&error];
    }
    return YES;
  }
  return NO;
}

- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url
                                           ofType:(NSString *)fileType
                               modelConfiguration:(NSString *)configuration
                                     storeOptions:(NSDictionary<NSString *,id> *)storeOptions
                                            error:(NSError * _Nullable *)error {
  
    
    //NSDictionary* options = @{
    //                            NSMigratePersistentStoresAutomaticallyOption : @YES,
    //                            NSInferMappingModelAutomaticallyOption : @YES};
    BOOL ok = [super configurePersistentStoreCoordinatorForURL:url
                                                        ofType:fileType
                                                    modelConfiguration:configuration
                                                          storeOptions:storeOptions
                                                                 error:error];
  if (ok) {
    NSPersistentStoreCoordinator *psc =
        [[self managedObjectContext] persistentStoreCoordinator];
    NSPersistentStore *pStore = [psc persistentStoreForURL:url];
    id existingMetadata = [psc metadataForPersistentStore:pStore][(NSString *)kMDItemKeywords];
    if (existingMetadata == nil) {
      ok = [self setMetadataForStoreAtURL:url];
    }
  }
  return ok;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL
                 ofType:(NSString *)typeName
       forSaveOperation:(NSSaveOperationType)saveOperation
    originalContentsURL:(NSURL *)absoluteOriginalContentsURL
                  error:(NSError **)error {
  if ([self fileURL] != nil) {
    [self setMetadataForStoreAtURL:[self fileURL]];
  }
  return [super writeToURL:absoluteURL
                    ofType:typeName
          forSaveOperation:saveOperation
       originalContentsURL:absoluteOriginalContentsURL
                     error:error];
}

#pragma mark copy, cut, paste
- (void)copy:(id)sender {
  if ([[[[self windowControllers][0] window] firstResponder]
          isKindOfClass:[DHGRStudentTableView class]]) {
    NSArray *selectedObjects = [personsArrayController selectedObjects];
    
    if ([selectedObjects count] == 0) {
      return;
    }
    NSSet* emails;
    NSSet* phones;
    NSArray *currentReports = [theReportsArrayController arrangedObjects];
    NSUInteger i, count = [currentReports count];
    NSMutableArray *copyReportsArray =
        [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *copyStringsArray =
        [NSMutableArray arrayWithCapacity:[selectedObjects count]];

    DHGRStudent *newPerson;
    newPerson = (DHGRStudent *)selectedObjects[0];
    emails = [[NSSet alloc] initWithSet:[[newPerson emailAddresses] valueForKey:@"emailDictionary"]];
    phones = [[NSSet alloc] initWithSet:[[newPerson phoneNumbers] valueForKey:@"phoneDictionary"]];

    //[copyReportsArray addObject:[newPerson studentDictionary]];
    [copyStringsArray addObject:[newPerson displayString]];

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
      NSData* copyData = [NSKeyedArchiver archivedDataWithRootObject:copyDictionary requiringSecureCoding:YES error:nil];

      
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    [generalPasteboard
        declareTypes:@[DHGRPersonsPBoardType,
                       NSPasteboardTypeString]
               owner:self];
    [generalPasteboard setData:copyData forType:DHGRPersonsPBoardType];
    [generalPasteboard
        setString:[copyStringsArray componentsJoinedByString:@"\n"]
     forType:NSPasteboardTypeString];
  }
  if ([[[[self windowControllers][0] window] firstResponder]
          isKindOfClass:[DHGRReportTableView class]]) {
    NSArray *selectedReports = [theReportsArrayController selectedObjects];
    NSUInteger i, count = [selectedReports count];
    if (count == 0) {
      return;
    }
    NSMutableArray *copyObjectsArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *copyStringsArray = [NSMutableArray arrayWithCapacity:count];

    for (i = 0; i < count; i++) {
      [copyObjectsArray
          addObject:[selectedReports[i] reportDictionary]];
      [copyStringsArray addObject:[selectedReports[i]
                                      valueForKey:@"contentString"]];
    }
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    [generalPasteboard
        declareTypes:@[DHGRReportsPBoardType,
                       NSPasteboardTypeString]
               owner:self];
      NSData *copyData = [NSKeyedArchiver archivedDataWithRootObject:copyObjectsArray requiringSecureCoding:YES error:nil];
    [generalPasteboard setData:copyData forType:DHGRReportsPBoardType];
    [generalPasteboard
        setString:[copyStringsArray componentsJoinedByString:@"\n"]
     forType:NSPasteboardTypeString];
  }
}

- (void)paste:sender {
  NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
  NSData *data = [generalPasteboard dataForType:DHGRPersonsPBoardType];
  if (data == nil) {
    data = [generalPasteboard dataForType:DHGRReportsPBoardType];
    ;
  } else {
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSMutableOrderedSet *coursePersons =
        [self.course mutableOrderedSetValueForKey:@"includesStudent"];

      NSDictionary *insertedPersonsDictionary =
      [NSKeyedUnarchiver unarchivedObjectOfClass:[NSDictionary class] fromData:data error:nil];
      //, count = [insertedPersonsArray count];
      
      if (insertedPersonsDictionary) {
          BOOL success = NO;
          NSString *recordId = [[insertedPersonsDictionary objectForKey:@"studentDictionary"]
                                valueForKey:@"uniqueAddressBookID"];
          
          if ([[self.personsArrayController arrangedObjects] count] > 0) {
              for (id obj in [self.personsArrayController arrangedObjects]) {
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
                  NSManagedObject *currentCourse;
                  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                  NSError *fetchError = nil;
                  NSArray *fetchResults;
                  NSEntityDescription *entity = [NSEntityDescription
                                                 entityForName:@"Course"
                                                 inManagedObjectContext:[self.personsArrayController managedObjectContext]];
                  [fetchRequest setEntity:entity];
                  fetchResults = [[self.personsArrayController managedObjectContext]
                                  executeFetchRequest:fetchRequest
                                  error:&fetchError];
                  if ((fetchResults != nil) && ([fetchResults count] == 1) &&
                      (fetchError == nil)) {
                      currentCourse = fetchResults[0];
                  }
                  if (fetchError != nil) {
                      NSLog(@"%@", fetchError);
                  }
                  [newStudent setValue:currentCourse forKey:@"takesCourse"];
                  [coursePersons addObject:newStudent];
      }
      return;
    }
  }
  }
  if (data == nil) {
    return;
  }

  NSManagedObjectContext *moc = [self managedObjectContext];
    NSArray *insertedReportsArray = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:data error:nil];
  NSUInteger i, count = [insertedReportsArray count];
  DHGRStudent *currentStudent =
      [personsArrayController selectedObjects][0];
  for (i = 0; i < count; i++) {
    DHGRReport *newlyAddedReport;
    newlyAddedReport = (DHGRReport *)
        [NSEntityDescription insertNewObjectForEntityForName:@"Report"
                                      inManagedObjectContext:moc];
    [newlyAddedReport
        setValuesForKeysWithDictionary:insertedReportsArray[i]];
    [newlyAddedReport setValue:currentStudent forKey:@"belongsTo"];
  }
}

- (void)cut:sender {
  [self copy:sender];
  // select if report or person
  if ([[[[self windowControllers][0] window] firstResponder]
          isKindOfClass:[DHGRStudentTableView class]]) {
    NSArray *selectedPersons = [personsArrayController selectedObjects];
    if ([selectedPersons count] == 0) {
      return;
    }
    NSManagedObjectContext *moc = [self managedObjectContext];
    for (DHGRStudent *aPerson in selectedPersons) {
      [moc deleteObject:aPerson];
    }
  }
  if ([[[[self windowControllers][0] window] firstResponder]
          isKindOfClass:[DHGRReportTableView class]]) {
    NSArray *selectedReports = [theReportsArrayController selectedObjects];
    if ([selectedReports count] == 0) {
      return;
    }
    NSManagedObjectContext *moc = [self managedObjectContext];
    for (DHGRReport *aReport in selectedReports) {
      [moc deleteObject:aReport];
    }
  }
}

#pragma mark addPersons Panel

- (IBAction)showAddPersonsPanel:(id)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"dHGRshowAddPersonsSheet"
     object:nil];
}



#pragma mark Find Persons

- (IBAction)showFindPanel:(id)sender
{
    NSView* studentView = [[majorView subviews] objectAtIndex:0];
    if ([[studentView subviews] count] > 1) {
        for (NSUInteger i = [[studentView subviews] count] - 1; i >= 1; i--) {
            [[[studentView subviews] objectAtIndex:i] removeFromSuperview];
        }
        NSView* studentListing = [[studentView subviews] objectAtIndex:0];
        [studentListing setFrame:NSMakeRect(studentView.frame.origin.x - 1, studentView.frame.origin.y - 1, studentView.frame.size.width + 2, studentView.frame.size.height + 2)];
        [self.personsArrayController setFilterPredicate:nil];
        searchPanelIsOpen = NO;
    }
    else{
        NSView* studentListing = [[studentView subviews] objectAtIndex:0];
        [studentListing setFrame:NSMakeRect(studentView.frame.origin.x - 1, studentView.frame.origin.y - 1, studentView.frame.size.width + 2, studentView.frame.size.height - 30)];
        NSRect frame = NSMakeRect(studentView.frame.origin.x - 1, studentView.frame.size.height - 31, studentView.frame.size.width + 2, 30);
        DHGRRibbonBGView* findView = [[DHGRRibbonBGView alloc] initWithFrame:frame];
        [findView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [studentView addSubview:findView];
        NSRect buttonFrame = NSMakeRect(frame.size.width - 60, frame.origin.y + 5, 50, 20);
        NSButton *button = [[NSButton alloc] initWithFrame:buttonFrame];
        [button setBezelStyle:NSBezelStyleAccessoryBarAction];
        [button setTitle:@"Done"];
        [button setTarget:self];
        [button setAlignment:NSTextAlignmentCenter];
        [button setAction:@selector(hideFindPanel:)];
        [button setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin];
        [studentView addSubview:button];
        [button setNextKeyView:[[studentView subviews] objectAtIndex:0]];
        NSRect searchViewFrame = NSMakeRect(frame.origin.x + 5, frame.origin.y + 5, frame.size.width - 80, 20);
        NSSearchField* personSearchField = [[NSSearchField alloc] initWithFrame:searchViewFrame];
        [personSearchField setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [personSearchField setAction:@selector(updatePersonSearch:)];
        [personSearchField setTarget:self];
        [studentView addSubview:personSearchField];
        [personSearchField setNextKeyView:button];
        [[studentView window] makeFirstResponder:personSearchField];
        searchPanelIsOpen = YES;
    }
    
}


- (IBAction)hideFindPanel:(id)sender
{
    NSView* studentView = [[majorView subviews] objectAtIndex:0];
    if ([[studentView subviews] count] > 1) {
        for (NSUInteger i = [[studentView subviews] count] - 1; i >= 1; i--) {
            [[[studentView subviews] objectAtIndex:i] removeFromSuperview];
        }
        NSView* studentListing = [[studentView subviews] objectAtIndex:0];
        [studentListing setFrame:NSMakeRect(studentView.frame.origin.x - 1, studentView.frame.origin.y - 1, studentView.frame.size.width + 2, studentView.frame.size.height + 2)];
        [self.personsArrayController setFilterPredicate:nil];
        searchPanelIsOpen = NO;
    }
}


- (IBAction)updatePersonSearch:(id)sender
{
    NSPredicate *personSearchPredicate = nil;
    if([[sender stringValue] isEqualToString:@""])
    {
        personSearchPredicate = nil;
    }
    else
    {
    personSearchPredicate = [NSPredicate predicateWithFormat:@"displayString CONTAINS[cd] %@",[sender stringValue]];
    }
    [self.personsArrayController setFilterPredicate:personSearchPredicate];
}


#pragma mark contact and bug reporting

- (void)reportBug:(id)sender {

  NSString *supportString = @"https://github.com/soleil-alpin/Circles/issues";
  NSURL *supportURL = [NSURL URLWithString:supportString];
  [[NSWorkspace sharedWorkspace] openURL:supportURL];
}

- (void)getHelp:(id)sender {

  NSString *supportString = @"https://soleil-alpin.com/Circles-Help.html";
  NSURL *supportURL = [NSURL URLWithString:supportString];
  [[NSWorkspace sharedWorkspace] openURL:supportURL];
}

- (void)dealloc
{
    self.course = nil;
    self.myOverlayView = nil;
    self.mainView = nil;
    self.majorView = nil;
    self.courseObjectController = nil;
    self.personsArrayController = nil;
    self.theReportsArrayController = nil;
}

#pragma mark Printing
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings error:(NSError **)outError
{
    NSPrintInfo *pInfo = [self printInfo];
    [pInfo setHorizontalPagination:NSPrintingPaginationModeFit];
    [pInfo setVerticallyCentered:NO];
    [[pInfo dictionary] setValue:[NSNumber numberWithBool:YES] forKey:NSPrintHeaderAndFooter];
    [[pInfo dictionary] addEntriesFromDictionary:printSettings];
    PrintTextView *printView = [[PrintTextView alloc] initWithFrame:[pInfo imageablePageBounds]];
    printView.printJobTitle = [[self displayName] stringByDeletingPathExtension];
    unichar pagebreakChar = NSFormFeedCharacter;
    NSString *pageBreakString = [NSString stringWithCharacters:&pagebreakChar length:1];
    NSAttributedString *formfeed = [[NSAttributedString alloc] initWithString:pageBreakString attributes:nil];
    unichar myChar = NSParagraphSeparatorCharacter;
    NSString *parSeparatorString = [NSString stringWithCharacters:&myChar length:1];
    
    NSMutableParagraphStyle *firstParaStyle = [[NSMutableParagraphStyle alloc] init];
    [firstParaStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary *firstAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-CondensedBold" size:24], NSParagraphStyleAttributeName: firstParaStyle};
    NSString* printBeginString = [[NSString alloc] initWithFormat:@"%@", [[self displayName] stringByDeletingPathExtension]];
    [[printView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:printBeginString attributes:firstAttributes]];
    [[printView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
    [[printView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
      [[printView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            for (DHGRStudent *p in [personsArrayController arrangedObjects]) {
            NSMutableAttributedString* myPrintString = [[NSMutableAttributedString alloc] initWithString:@""];

            NSMutableParagraphStyle *nameParaStyle = [[NSMutableParagraphStyle alloc] init];
                [nameParaStyle setAlignment:NSTextAlignmentCenter];
            NSDictionary *nameAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Light" size:24], NSParagraphStyleAttributeName: nameParaStyle};
            
            
            NSImage * imageNotRound = [[NSImage alloc] initWithData:[p valueForKey:@"portrait"]];
            if (imageNotRound == nil) {
                imageNotRound = [NSImage imageNamed:@"NSUser"];
            }
            NSImage * portrait = [DHGRImage roundCorners:imageNotRound];
            [portrait setSize:NSMakeSize(60, 60)];
            NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:portrait];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            [attachment setAttachmentCell: attachmentCell];
            NSAttributedString *portraitAttrString = [NSAttributedString  attributedStringWithAttachment:attachment];
            NSMutableAttributedString* portMut = [[NSMutableAttributedString alloc] initWithAttributedString:portraitAttrString];
            [portMut beginEditing];
            [portMut addAttribute:NSParagraphStyleAttributeName value:nameParaStyle range:NSMakeRange(0, [portMut length])];
            [portMut endEditing];
            [myPrintString appendAttributedString:[portMut copy]];
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];

            NSAttributedString* nameString = [[NSAttributedString alloc] initWithString:[p valueForKey:@"displayString"] attributes:nameAttributes];
            [myPrintString appendAttributedString:nameString];
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            
            NSMutableParagraphStyle *pointsParaStyle = [[NSMutableParagraphStyle alloc] init];
                [pointsParaStyle setAlignment:NSTextAlignmentCenter];
            NSDictionary *pointsAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-UltraLight" size:18], NSParagraphStyleAttributeName: nameParaStyle};
            NSMutableAttributedString* attribString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:pointsAttributes];
            NSString *rating = [p myRating];
            NSString *points = [p myPoints];
            if ([rating length] > 0|[points length] > 0) {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:@" ("]];
            }
            if ([rating length] > 0)
            {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:rating]];
            }
            if ([rating length] > 0 && [points length] > 0) {
                     [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
            }
            if ([points length] > 0)
            {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:points]];
            }
            if ([rating length] > 0|[points length] > 0) {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:@")"]];
            }
            [attribString setAttributes:pointsAttributes range:NSMakeRange(0, [attribString length])];
            if ([attribString length] > 0)
            {
                [myPrintString appendAttributedString:[attribString copy]];
            }
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            NSArray* myReports = [p valueForKey:@"ownsReport"];
            NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:dateSort];
            NSArray *sortedReports = [myReports sortedArrayUsingDescriptors:sortDescriptors];
            for (DHGRReport* theReport in sortedReports)
            {
                [myPrintString appendAttributedString:[theReport valueForKey:@"reportString"]];
                [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
                [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            }
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            
            [[printView textStorage] appendAttributedString:[myPrintString copy]];
            [[printView textStorage] appendAttributedString:formfeed];
        }
    
    NSImage * circlesImage = [NSImage imageNamed:@"circles-icon_512x512@2x"];
    [circlesImage setSize:NSMakeSize(30, 30)];
    NSTextAttachmentCell *circlesAttachmentCell = [[NSTextAttachmentCell alloc] initImageCell:circlesImage];
    NSTextAttachment *circlesAtt = [[NSTextAttachment alloc] init];
    [circlesAtt setAttachmentCell: circlesAttachmentCell];
    NSAttributedString *circlesAttrString = [NSAttributedString  attributedStringWithAttachment:circlesAtt];
    NSMutableAttributedString* circlesMut = [[NSMutableAttributedString alloc] initWithAttributedString:circlesAttrString];
    [circlesMut beginEditing];
    [circlesMut addAttribute:NSParagraphStyleAttributeName value:firstParaStyle range:NSMakeRange(0, [circlesMut length])];
    [circlesMut endEditing];
    [[printView textStorage] appendAttributedString:[circlesMut copy]];
    NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:printView printInfo:pInfo];
    return printOp;
}




@end
