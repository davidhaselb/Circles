//
//  DHGRReportsTableViewController.m
//  Groups
//
//  Created by David Haselberger on 7/23/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRReportsTableViewController.h"
#import "DHGRStudentTableView.h"
#import "DHGRReport.h"
#import "DHGRReportsTableCellView.h"

@implementation DHGRReportsTableViewController

@synthesize reportsList;
@synthesize reportsArrayController;
@synthesize studentsArrayController;
@synthesize myInputTextView;
@synthesize reportSearchField;
@synthesize myEditButton;
@synthesize popoverTriggerButton;
@synthesize popover;
@synthesize ratingsPopoverTriggerButton;
@synthesize ratingsPopover;
@synthesize myDatePicker;
@synthesize ratingsTextFieldA;
@synthesize ratingsTextFieldB;
@synthesize ratingsSetButton;
@synthesize additionsPopoverTriggerButton;
@synthesize additionsPopover;
@synthesize additionsTextField;
@synthesize additionsSetButton;
@synthesize isEditing;
@synthesize gotNotifiedOfEditing;
@synthesize selectionChangeBool;
@synthesize editingIndex;
@synthesize editingString;
@synthesize smallerSplitView;
@synthesize initialized;

NSPredicate *predicateTemplateOne;
NSPredicate *predicateTemplateTwo;

- (instancetype)init {

  self = [super init];
  if (self) {
      self.isEditing = NO;
      self.gotNotifiedOfEditing = NO;
      self.selectionChangeBool = NO;
      self.editingIndex = [self.studentsArrayController selectionIndex];
      self.editingString = @"";
      self.initialized = NO;
  }
  return self;
}

- (void)awakeFromNib {
    if (!initialized) {
        self.myDatePicker.dateValue = [NSDate date];
        self.initialized = YES;
    }
    [self.popoverTriggerButton
     setAttributedTitle:[self styledDateStringFromDate:[NSDate date]]];
  [self.reportsList setDelegate:self];
  predicateTemplateOne = [NSPredicate
      predicateWithFormat:@"contentString contains[cd] $searchString"];
  predicateTemplateTwo =
      [NSPredicate predicateWithFormat:@"ALL $tagsList in[cd] contentString"];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(unpackReportValueDictionary:)
             name:@"dHGRReportSpacebarSelect"
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(editSelection:)
             name:@"dHGRReportBeginEditingEntry"
           object:self.reportsList];
  [self.studentsArrayController addObserver:self
                            forKeyPath:@"selection"
                               options:0
                               context:nil];

}

#pragma mark search
- (IBAction)updateFilterAction:(id)sender {

  NSPredicate *predicateOne;
  NSPredicate *predicateTwo;
  NSString *searchString = [self.reportSearchField stringValue];
  NSMutableDictionary *bindVariables = [[NSMutableDictionary alloc] init];

  if ([searchString isEqualToString:@""]) {
    predicateOne = nil;
    predicateTwo = nil;
  } else {
    NSError *error;
    NSString *myPatternTag = [NSString stringWithFormat:@"#\\w+"];
    NSRegularExpression *regexTag = [NSRegularExpression
        regularExpressionWithPattern:myPatternTag
                             options:NSRegularExpressionCaseInsensitive
                               error:&error];
    NSArray *matchesTag =
        [regexTag matchesInString:searchString
                          options:0
                            range:NSMakeRange(0, [searchString length])];
    NSMutableArray *tagsToBeInserted;
    NSMutableString *myNewString = [searchString mutableCopy];
    tagsToBeInserted = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in matchesTag) {
      NSRange matchRange = [match range];
      NSString *theTag = [searchString substringWithRange:matchRange];
      if (![tagsToBeInserted containsObject:theTag]) {
        [tagsToBeInserted addObject:theTag];
      }
      NSRange replaceRange = [myNewString rangeOfString:theTag];
      if (replaceRange.location != NSNotFound) {
        [myNewString replaceCharactersInRange:replaceRange withString:@""];
      }
    }
    // scan up to punctations and add strings to "tagsToBeInserted"
    NSString *scannerSearchString = [myNewString copy];
    NSMutableCharacterSet *charactersToSkip =
        [NSMutableCharacterSet punctuationCharacterSet];
    NSScanner *searchScanner =
        [NSScanner scannerWithString:scannerSearchString];
    NSString *partialSearchString;

    while ([searchScanner isAtEnd] == NO) {
      [searchScanner scanUpToCharactersFromSet:charactersToSkip
                                    intoString:&partialSearchString];
      [searchScanner scanCharactersFromSet:charactersToSkip intoString:NULL];
      if (partialSearchString) {
        [tagsToBeInserted addObject:partialSearchString];
      }
    }
    bindVariables[@"searchString"] = searchString;
    bindVariables[@"tagsList"] = [tagsToBeInserted copy];
    predicateOne =
        [predicateTemplateOne predicateWithSubstitutionVariables:bindVariables];
    predicateTwo =
        [predicateTemplateTwo predicateWithSubstitutionVariables:bindVariables];
  }

  [self.reportsArrayController setFilterPredicate:predicateOne];
  if (([[self.reportsArrayController arrangedObjects] count] == 0) &&
      ([bindVariables[@"tagsList"] count] > 0)) {
    [self.reportsArrayController setFilterPredicate:predicateTwo];
  }
}

#pragma mark Splitview methods
- (CGFloat)splitView:(NSSplitView *)splitView
    constrainMaxCoordinate:(CGFloat)proposedMaximumPosition
               ofSubviewAt:(NSInteger)dividerIndex {
  return splitView.frame.size.height - 100.0;
}

- (BOOL)splitView:(NSSplitView *)splitView
    canCollapseSubview:(NSView *)subview {
  return NO;
}

#pragma mark addContent method

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector {
  if (aSelector == @selector(insertNewline:)) {
    [self addContent:aTextView];
    return YES;
  }
  return NO;
}

- (IBAction)addContent:(id)sender {
  [self.reportsArrayController setFilterPredicate:nil];
  NSString *newContentForReportEntry = [sender string];
  if (self.isEditing && [newContentForReportEntry isEqualToString:@""]) {
    newContentForReportEntry = self.editingString;
  }
  NSMutableAttributedString *presentedString =
      [[NSMutableAttributedString alloc]
          initWithString:newContentForReportEntry];
  NSDictionary *usualAttributes =
      @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};
  [presentedString
      addAttributes:usualAttributes
              range:NSMakeRange(0, [presentedString string].length)];
  NSManagedObject *myNewEntry = [NSEntityDescription
      insertNewObjectForEntityForName:@"Report"
               inManagedObjectContext:[self.reportsArrayController
                                              managedObjectContext]];
  int addedPoints = 0;

#pragma mark pattern matching

  NSDictionary *boldAttributes =
      @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]};
  NSError *error = NULL;

#pragma mark points pattern matching
  NSInteger myPointMatches;
  NSString *myPatternP = [NSString stringWithFormat:@"@P\\([0-9]+\\/[0-9]+\\)"];
  NSRegularExpression *regexP = [NSRegularExpression
      regularExpressionWithPattern:myPatternP
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];

  NSArray *matchesP = [regexP
      matchesInString:newContentForReportEntry
              options:0
                range:NSMakeRange(0, [newContentForReportEntry length])];
  NSMutableArray *myPointsArray = [[NSMutableArray alloc] init];
  for (NSTextCheckingResult *match in matchesP) {
    NSRange matchRange = [match range];
    NSString *pointsMatchString =
        [newContentForReportEntry substringWithRange:matchRange];

    NSCharacterSet *pointsCharacterSet =
        [NSCharacterSet characterSetWithCharactersInString:@"@Pp()"];
    NSScanner *pointScanner = [NSScanner scannerWithString:pointsMatchString];
    NSInteger firstP;
    NSInteger secondP;
    [pointScanner scanCharactersFromSet:pointsCharacterSet intoString:NULL];
    [pointScanner scanInteger:&firstP];
    [pointScanner scanString:@"/" intoString:NULL];
    [pointScanner scanInteger:&secondP];
    if (firstP <= secondP) {
      float division = (float)firstP / (float)secondP;
      float myP = division * 100;
      long theFinalP = (long)myP;
      [presentedString addAttributes:boldAttributes range:matchRange];
      [myPointsArray addObject:@(theFinalP)];
    }
  }
  if ([[myPointsArray copy] count] > 0) {

    NSInteger sum = 0;
    for (NSNumber *num in [myPointsArray copy]) {
      sum += [num floatValue];
    }
    myPointMatches = sum / [[myPointsArray copy] count];
  }
  NSInteger theRatingArrayCount = [[myPointsArray copy] count];

#pragma mark add pattern matching

  NSString *myPatternA = [NSString stringWithFormat:@"@A\\([0-9]+\\)"];
  NSRegularExpression *regexA = [NSRegularExpression
      regularExpressionWithPattern:myPatternA
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];

  NSArray *matchesA = [regexA
      matchesInString:newContentForReportEntry
              options:0
                range:NSMakeRange(0, [newContentForReportEntry length])];

  for (NSTextCheckingResult *match in matchesA) {
    NSRange matchRange = [match range];
    NSString *addedPointsMatchString =
        [newContentForReportEntry substringWithRange:matchRange];

    NSCharacterSet *addedPointsCharacterSet =
        [NSCharacterSet characterSetWithCharactersInString:@"@Aa()"];
    NSScanner *addedPointScanner =
        [NSScanner scannerWithString:addedPointsMatchString];
    NSInteger freshPoints;
    [addedPointScanner scanCharactersFromSet:addedPointsCharacterSet
                                  intoString:NULL];
    [addedPointScanner scanInteger:&freshPoints];
    if (freshPoints > 0) {
      addedPoints += freshPoints;
      [presentedString addAttributes:boldAttributes range:matchRange];
    }
  }

#pragma mark link checker
  NSDataDetector *myDataDetector = [NSDataDetector
      dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypeDate
                      error:&error];

  [myDataDetector
      enumerateMatchesInString:newContentForReportEntry
                       options:kNilOptions
                         range:NSMakeRange(0, [newContentForReportEntry length])
                    usingBlock:^(NSTextCheckingResult *match,
                                 NSMatchingFlags flags, BOOL *stop) {
                        NSRange matchRange = [match range];
                        if ([match resultType] == NSTextCheckingTypeLink) {
                          NSString *myURL = [[match URL] absoluteString];
                          [presentedString addAttribute:NSLinkAttributeName
                                                  value:myURL
                                                  range:matchRange];
                          [presentedString
                              addAttribute:NSUnderlineStyleAttributeName
                                     value:@(NSUnderlineStyleSingle)
                                     range:matchRange];
                        }
                    }];

#pragma mark tagging pattern matching
  NSString *myPatternTag = [NSString stringWithFormat:@"#\\w+"];
  NSRegularExpression *regexTag = [NSRegularExpression
      regularExpressionWithPattern:myPatternTag
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];

  NSArray *matchesTag = [regexTag
      matchesInString:newContentForReportEntry
              options:0
                range:NSMakeRange(0, [newContentForReportEntry length])];

  NSMutableArray *tagsToBeInserted;
  NSArray *currentTags =
      [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"myTags"];
  if (currentTags) {
    tagsToBeInserted = [currentTags mutableCopy];
  } else {
    tagsToBeInserted = [[NSMutableArray alloc] init];
  }

  for (NSTextCheckingResult *match in matchesTag) {
    NSRange matchRange = [match range];
    [presentedString addAttributes:boldAttributes range:matchRange];
    NSUInteger newLocation = matchRange.location + 1;
    NSUInteger newLength = matchRange.length - 1;
    NSRange tagStringRange = NSMakeRange(newLocation, newLength);
    NSString *theTag =
        [newContentForReportEntry substringWithRange:tagStringRange];
    if (![tagsToBeInserted containsObject:theTag]) {
      [tagsToBeInserted addObject:theTag];
    }
  }
  [[NSUserDefaults standardUserDefaults] setObject:[tagsToBeInserted copy]
                                            forKey:@"myTags"];

#pragma mark enter data

  [myNewEntry setValue:[self.myDatePicker dateValue] forKey:@"date"];
  if (theRatingArrayCount > 0) {
    NSNumber *myPoints = @((int)myPointMatches);
    [myNewEntry setValue:myPoints forKey:@"rating"];
  }
  NSNumber *myFreshAddedPoints = @(addedPoints);
  [myNewEntry setValue:myFreshAddedPoints forKey:@"points"];
  [myNewEntry setValue:presentedString forKey:@"rtfString"];
  if (self.isEditing) {
      [myNewEntry setValue:[[self.studentsArrayController arrangedObjects] objectAtIndex:self.editingIndex]
                  forKey:@"belongsTo"];
  } else {
    [myNewEntry
     setValue:[[self.studentsArrayController selectedObjects] objectAtIndex:0]
          forKey:@"belongsTo"];
  }
  [self.reportsList reloadData];
  [self.reportsList scrollRowToVisible:[[self.reportsArrayController arrangedObjects]
                                      indexOfObject:myNewEntry]];
  if (!self.selectionChangeBool) {
    [self.reportsList
            selectRowIndexes:
                [NSIndexSet
                    indexSetWithIndex:[[self.reportsArrayController arrangedObjects]
                                          indexOfObject:myNewEntry]]
        byExtendingSelection:NO];
  }
  [sender setSelectedRange:NSMakeRange(0, [[sender textStorage] length])];
  [sender insertText:@""];
  NSDictionary *cleanAttributes =
      @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone), NSForegroundColorAttributeName: [NSColor blackColor],
                        NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};
  [sender setTypingAttributes:cleanAttributes];
  if (self.popover.shown) {
    [self.popover close];
      [self.popoverTriggerButton setState:NSControlStateValueOff];
  }
  [self.myDatePicker setDateValue:[NSDate date]];
  self.isEditing = NO;
  self.gotNotifiedOfEditing = NO;
  self.selectionChangeBool = NO;
  [self updateFilterAction:self];
}

#pragma mark doubleClick on Report TableView

- (IBAction)rowDoubleClicked:(id)sender {
  //    if ([[reportsArrayController arrangedObjects] count] > 0)
  //    {
  //    NSDictionary* theValueDictionary = [[[reportsArrayController
  //    arrangedObjects] objectAtIndex:[reportsList selectedRow]]
  //    valueForKey:@"reportDictionary"];
  //    [self setReportToInsertTextView:theValueDictionary];
  //    }
}

- (IBAction)editButtonClicked:(id)sender {
  [[sender window] makeFirstResponder:self.reportsList];
  NSDictionary *theValueDictionary = [[self.reportsArrayController arrangedObjects][[self.reportsList rowForView:sender]]
      valueForKey:@"reportDictionary"];
  [self.reportsArrayController
      removeObject:[self.reportsArrayController arrangedObjects][[self.reportsList rowForView:sender]]];
  if (self.isEditing) {
    [self addContent:self.myInputTextView];
  }
  self.isEditing = YES;
  self.editingIndex = [self.studentsArrayController selectionIndex];
  self.editingString = [theValueDictionary valueForKey:@"contentString"];
  [self setReportToInsertTextView:theValueDictionary];
}

- (void)editSelection:(id)sender {
  if (!self.gotNotifiedOfEditing) {
    NSDictionary *theValueDictionary =
      [[[self.reportsArrayController selectedObjects] objectAtIndex: 0]
            valueForKey:@"reportDictionary"];
    [self.reportsArrayController
        removeObject:[[self.reportsArrayController selectedObjects] firstObject]];
    if (self.isEditing) {
      [self addContent:self.myInputTextView];
    }
    self.isEditing = YES;
    self.editingIndex = [self.studentsArrayController selectionIndex];
    self.editingString = [theValueDictionary valueForKey:@"contentString"];
    self.gotNotifiedOfEditing = YES;
    [self setReportToInsertTextView:theValueDictionary];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"selection"]) {
    self.selectionChangeBool = YES;
    if (self.isEditing) {
      [self addContent:self.myInputTextView];
    }
    [self.myDatePicker setDateValue:[NSDate date]];
    [self.popoverTriggerButton
       setAttributedTitle:[self styledDateStringFromDate:[NSDate date]]];
  }
}

- (IBAction)unpackReportValueDictionary:(id)sender {
  NSDictionary *reportValueDictionary = [sender object];
  [self setReportToInsertTextView:reportValueDictionary];
}

- (void)setReportToInsertTextView:(NSDictionary *)objectValueDictionary {
  NSDate *theDate = [objectValueDictionary valueForKey:@"date"];
  [self.myDatePicker setDateValue:theDate];
  [self.popoverTriggerButton
      setAttributedTitle:[self styledDateStringFromDate:theDate]];
  NSString *myInsertString = [NSString
      stringWithFormat:@"%@",
                       [objectValueDictionary valueForKey:@"contentString"]];
  [self.myInputTextView
      setSelectedRange:NSMakeRange(0, [[self.myInputTextView textStorage] length])];
  [self.myInputTextView insertText:myInsertString];
  [[self.myInputTextView window] makeFirstResponder:self.myInputTextView];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:@"dHGRTextToEditChanged"
                    object:self];
}

#pragma mark TableView Delegate Methods

- (BOOL)tableView:(NSTableView *)tableView
    shouldTrackCell:(NSCell *)cell
     forTableColumn:(NSTableColumn *)tableColumn
                row:(NSInteger)row {
  return YES;
}

- (NSArray *)reportsSortDescriptors {
  return
      @[[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                             ascending:YES]];
}


- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSManagedObject *entry =
        [self.reportsArrayController arrangedObjects][row];
    NSAttributedString* reportContent = [self attributedStringFromReportManagedObject:entry];
    //this solution seems to have most effect so far
    NSTableColumn *tableColoumn = [[self.reportsList tableColumns] objectAtIndex:0];
    CGFloat heightOfRow = 0;
    if (tableColoumn)
    {
        NSCell *dataCell = [tableColoumn dataCell];
        [dataCell setWraps:YES];
        [dataCell setAttributedStringValue:reportContent];
        NSRect myRect = NSMakeRect(0, 0, [tableColoumn width] - 30, CGFLOAT_MAX);
        heightOfRow =  [dataCell cellSizeForBounds:myRect].height;
    }
    
   // DHGRReportsTableCellView* result = [self.reportsList makeViewWithIdentifier:@"MyTableCellView" owner:self];
    //float height = [self calculateIdealHeightForCell:result andAttributedString:reportContent andFrame: [result frame]];
    return heightOfRow + 33;
}

//- (CGFloat) calculateIdealHeightForCell: (NSTableCellView *) cellView andAttributedString: (id) item andFrame: (CGRect) outlineFrame
//{
//    NSTextField *valueLabel = [cellView textField];
//    [valueLabel setEditable:YES];
//    [valueLabel setEnabled:YES];
//    [valueLabel setAttributedStringValue:item];
//    CGSize newSize = valueLabel.frame.size;
//    newSize.height = CGFLOAT_MAX;
//    NSTableColumn* tabCol = [[self.reportsList tableColumns] objectAtIndex:0];
//    newSize.width = tabCol.width - 30.0;
//    NSTextStorage * storage = [[NSTextStorage alloc] initWithAttributedString: item];
//    NSTextContainer * container = [[NSTextContainer alloc] initWithContainerSize: newSize];
//    [container setLineFragmentPadding: 0.0];
//    NSLayoutManager * manager = [[NSLayoutManager alloc] init];
//    [manager addTextContainer: container];
//    [storage addLayoutManager: manager];
//    [manager glyphRangeForTextContainer: container];
//    NSRect idealRect = [manager usedRectForTextContainer: container];
//    return idealRect.size.height + 30.0;
//}

- (void)tableView:(NSTableView *)tv
    didAddRowView:(NSTableRowView *)rowView
           forRow:(NSInteger)row {
  if (tv == self.reportsList) {
    [self.reportsList
        noteHeightOfRowsWithIndexesChanged:
            [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, 1)]];
  }
}

- (void)tableViewColumnDidResize:(NSNotification *)aNotification {
  [self.reportsList reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView
    viewForTableColumn:(NSTableColumn *)tableColumn
                   row:(NSInteger)row {
  DHGRReportsTableCellView *result =
      [tableView makeViewWithIdentifier:@"MyTableCellView" owner:self];
  if (result == nil) {
    NSPoint origin = {0, 0};
    NSSize tableSize = {[tableColumn width], 10};
    NSRect resultRect = {origin, tableSize};
    result = [[DHGRReportsTableCellView alloc] initWithFrame:resultRect];
    result.identifier = @"MyTableCellView";
    result.textField.drawsBackground = NO;
  }
  result.textField.enabled = YES;
  result.textField.selectable = YES;
  result.textField.allowsEditingTextAttributes = YES;
  return result;
}

#pragma mark popover

- (IBAction)togglePopover:(id)sender {
  if (!self.popover.shown) {
    [self.popover showRelativeToRect:[self.popoverTriggerButton bounds]
                              ofView:self.popoverTriggerButton
                       preferredEdge:NSMaxYEdge];

  } else {
    [self.popoverTriggerButton
        setAttributedTitle:
            [self styledDateStringFromDate:[self.myDatePicker dateValue]]];
    [self.popover close];
  }
}

- (NSAttributedString *)styledDateStringFromDate:(NSDate *)newDate {
  NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
  [dayFormatter setDateFormat:@"d"];
  NSString *currentDay = [dayFormatter stringFromDate:newDate];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"MMM"];
  [formatter setTimeZone:[NSTimeZone systemTimeZone]];
  NSString *currentMonth = [formatter stringFromDate:newDate];

  NSString *monthToDraw = [NSString stringWithFormat:@"%@", currentMonth];

  NSColor *foregroundColor = [NSColor whiteColor];
  NSMutableParagraphStyle *myParaStyleTwo =
      [[NSMutableParagraphStyle alloc] init];
    [myParaStyleTwo setAlignment:NSTextAlignmentCenter];
  [myParaStyleTwo setMaximumLineHeight:10.0f];
  NSDictionary *monthButtonAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Light" size:10], NSForegroundColorAttributeName: foregroundColor,
          NSParagraphStyleAttributeName: myParaStyleTwo};
  NSMutableParagraphStyle *myParaStyle = [[NSMutableParagraphStyle alloc] init];
    [myParaStyle setAlignment:NSTextAlignmentCenter];
  [myParaStyle setLineHeightMultiple:0.5f];
  [myParaStyle setMinimumLineHeight:0.3f];
  [myParaStyle setMaximumLineHeight:14.0f];
  [myParaStyle setParagraphSpacingBefore:10.2f];

  NSDictionary *dayButtonAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Light"
                                                   size:13], NSParagraphStyleAttributeName: myParaStyle};
  NSMutableAttributedString *myMonthString =
      [[NSMutableAttributedString alloc] initWithString:monthToDraw
                                             attributes:monthButtonAttributes];
  NSAttributedString *myDayString =
      [[NSAttributedString alloc] initWithString:currentDay
                                      attributes:dayButtonAttributes];
  NSString *newline = @"\r";
  NSAttributedString *myNewLine =
      [[NSAttributedString alloc] initWithString:newline
                                      attributes:monthButtonAttributes];
  [myMonthString appendAttributedString:myNewLine];
  [myMonthString appendAttributedString:myDayString];
  return myMonthString;
}

- (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell
    validateProposedDateValue:(NSDate **)proposedDateValue
                 timeInterval:(NSTimeInterval *)proposedTimeInterval {
  NSDate *newDate = *proposedDateValue;
  [self.popoverTriggerButton
      setAttributedTitle:[self styledDateStringFromDate:newDate]];
}


- (BOOL)textShouldBeginEditing:(NSText *)aTextObject {
  [self.popoverTriggerButton setAttributedTitle:[self styledDateStringFromDate:
                                                     [self.myDatePicker dateValue]]];
  [self.popover close];
  [ratingsTextFieldA setStringValue:@""];
  [ratingsTextFieldB setStringValue:@""];
  [self.ratingsPopover close];
  [additionsTextField setStringValue:@""];
  [self.additionsPopover close];
  return YES;
}


#pragma mark ratings popover
- (IBAction)toggleRatingsPopover:(id)sender {
    if (!self.ratingsPopover.shown) {
        [self.ratingsPopover showRelativeToRect:[self.ratingsPopoverTriggerButton bounds]
                                  ofView:self.ratingsPopoverTriggerButton
                           preferredEdge:NSMaxYEdge];
        
    } else {
        [self.ratingsPopover close];
    }
}

- (IBAction)setNewRatings:(id)sender
{
    
    if ([ratingsTextFieldA stringValue].length > 0 && [ratingsTextFieldB stringValue].length > 0) {
        NSInteger firstP = [ratingsTextFieldA integerValue];
        NSInteger secondP = [ratingsTextFieldB integerValue];
        if (firstP <= secondP)
        {
            NSString* tobeInserted = [NSString stringWithFormat:@"@p(%li/%li)", (long)firstP, (long) secondP];
            [myInputTextView insertText:tobeInserted];
            [ratingsTextFieldA setStringValue:@""];
            [ratingsTextFieldB setStringValue:@""];
            [self.ratingsPopover close];
        }
        else
        {
            [[ratingsTextFieldA window] makeFirstResponder:ratingsTextFieldA];
        }
    }else{
        if ([ratingsTextFieldA stringValue].length > 0 | [ratingsTextFieldB stringValue].length > 0)
        {
            [[ratingsTextFieldA window] makeFirstResponder:ratingsTextFieldA];
        }
        else{
            [ratingsTextFieldA setStringValue:@""];
            [ratingsTextFieldB setStringValue:@""];
            [self.ratingsPopover close];
        }
    }

}

#pragma mark additional points popover
- (IBAction)toggleAdditionsPopover:(id)sender
{
    if (!self.additionsPopover.shown) {
        [self.additionsPopover showRelativeToRect:[self.additionsPopoverTriggerButton bounds]
                                         ofView:self.additionsPopoverTriggerButton
                                  preferredEdge:NSMaxYEdge];
        
    } else {
        [self.additionsPopover close];
    }

}

- (IBAction)setNewAddedPoints:(id)sender
{
    if ([additionsTextField stringValue].length > 0) {
            NSInteger toBeAdded = [additionsTextField integerValue];
            NSString* tobeInserted = [NSString stringWithFormat:@"@a(%li)", (long)toBeAdded];
        [myInputTextView insertText:tobeInserted];
        [additionsTextField setStringValue:@""];
        [self.additionsPopover close];
    }else{
        [additionsTextField setStringValue:@""];
        [self.additionsPopover close];
    }
}


#pragma mark deallocation
- (void)dealloc
{
    [self.smallerSplitView setDelegate:nil];
    self.smallerSplitView = nil;
    self.myInputTextView = nil;
    [self.studentsArrayController setContent:nil];
    self.studentsArrayController = nil;
    [self.reportsArrayController setContent:nil];
    self.reportsArrayController = nil;
    self.myDatePicker = nil;
    [self.reportsList setDelegate:nil];
    self.reportsList = nil;
    self.popover = nil;
    self.popoverTriggerButton = nil;
}

#pragma mark helper

- (NSAttributedString *)attributedStringFromReportManagedObject:(NSManagedObject *)myReport
{
    NSDate *dateOfReport = [myReport valueForKey:@"date"];
    NSString *dateString =
    [NSDateFormatter localizedStringFromDate:dateOfReport
                                   dateStyle:NSDateFormatterLongStyle
                                   timeStyle:NSDateFormatterShortStyle];
    NSString *myContent = [myReport valueForKey:@"contentString"];
    NSDictionary *usualAttributes =
    @{NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};
    NSAttributedString* myAttribContent = [[NSAttributedString alloc] initWithString:[myContent copy] attributes:usualAttributes];
    NSMutableAttributedString *completeString = [[NSMutableAttributedString alloc]
                                                 initWithString:[NSString stringWithFormat:@"%@\r", dateString]]; // \n
    [completeString appendAttributedString:myAttribContent];
    NSMutableParagraphStyle *myParaStyle = [[NSMutableParagraphStyle alloc] init];
    [myParaStyle setAlignment:NSTextAlignmentRight];
    NSDictionary *dateAttributes = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: myParaStyle};
    [completeString
     addAttributes:dateAttributes
     range:[[completeString string]
            rangeOfString:[NSString
                           stringWithFormat:@"%@", dateString]]];
    
    return completeString;
}

@end
