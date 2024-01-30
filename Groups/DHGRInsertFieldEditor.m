//
//  DHGRInsertFieldEditor.m
//  Groups
//
//  Created by David Haselberger on 10/7/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRInsertFieldEditor.h"

@implementation DHGRInsertFieldEditor

- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
      [self registerForDraggedTypes:@[NSPasteboardTypeURL]];
    [self setFieldEditor:YES];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(textSyntaxHighlighting:)
               name:@"dHGRTextToEditChanged"
             object:nil];
    [[self textStorage] setDelegate:self];
    autocomplete = NO;
    NSDictionary *linkAttributes =
        @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSForegroundColorAttributeName: [NSColor blackColor],
                          NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};
    [self setLinkTextAttributes:linkAttributes];
    [self addSyntaxHighlighting:[self textStorage]];
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}

- (void)awakeFromNib {
  [self addSyntaxHighlighting:[self textStorage]];
  [self checkTextInDocument:nil];
}

- (void)didChangeText {
  [super didChangeText];
  [self addSyntaxHighlighting:[self textStorage]];

  if (!isAutoCompleting) {
    isAutoCompleting = YES;

    if (autocomplete) {
      [self complete:nil];
    }
    isAutoCompleting = NO;
  }
}

- (void)addSyntaxHighlighting:(NSTextStorage *)myTextStorage {

  NSString *string = [myTextStorage string];
  NSUInteger length = [string length];

  NSRange area = NSMakeRange(0, [myTextStorage length]);
  [myTextStorage removeAttribute:NSFontAttributeName range:area];
  [myTextStorage removeAttribute:NSUnderlineStyleAttributeName range:area];
  [myTextStorage addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:[NSFont systemFontSize]]
                        range:area];
    
    
    //CHECK FOR CODE OF REGEX BEFORE OPEN SOURCE!!
  NSRegularExpression *linkRegEx = [NSRegularExpression
      regularExpressionWithPattern:@"(?i)\\b((?:[a-z][\\w-]+:(?:/"
                                   @"{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9."
                                   @"\\-]+[.][a-z]{2,4}/"
                                   @")(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^"
                                   @"\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|("
                                   @"\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{}"
                                   @";:'\".,<>?«»“”‘’]))"
                           options:NSRegularExpressionCaseInsensitive
                             error:NULL];
  NSArray *matchesL =
      [linkRegEx matchesInString:string options:0 range:NSMakeRange(0, length)];

  for (NSTextCheckingResult *match in matchesL) {
    NSRange matchRange = [match range];
    NSString *myURL =
        [[[self textStorage] string] substringWithRange:matchRange];

    NSDictionary *myLinkAttributes =
        @{NSLinkAttributeName: myURL,
                          NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSForegroundColorAttributeName: [NSColor blackColor],
                          NSFontAttributeName: [NSFont systemFontOfSize:[NSFont systemFontSize]]};
    [myTextStorage addAttributes:myLinkAttributes range:matchRange];
  }

  NSDictionary *boldAttributes =
      @{NSFontAttributeName: [NSFont boldSystemFontOfSize:[NSFont systemFontSize]]};
  NSError *error = NULL;

  NSString *myPatternP = [NSString stringWithFormat:@"@P\\([0-9]+\\/[0-9]+\\)"];
  NSRegularExpression *regexP = [NSRegularExpression
      regularExpressionWithPattern:myPatternP
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];

  NSArray *matchesP =
      [regexP matchesInString:string options:0 range:NSMakeRange(0, length)];

  for (NSTextCheckingResult *match in matchesP) {
    NSRange matchRange = [match range];
    NSString *pointsMatchString = [string substringWithRange:matchRange];

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
      [myTextStorage addAttributes:boldAttributes range:matchRange];
    }
  }

  NSString *myPatternA = [NSString stringWithFormat:@"@A\\([0-9]+\\)"];
  NSRegularExpression *regexA = [NSRegularExpression
      regularExpressionWithPattern:myPatternA
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];

  NSArray *matchesA =
      [regexA matchesInString:string options:0 range:NSMakeRange(0, length)];

  for (NSTextCheckingResult *match in matchesA) {
    NSRange matchRange = [match range];
    NSString *addedPointsMatchString = [string substringWithRange:matchRange];

    NSCharacterSet *addedPointsCharacterSet =
        [NSCharacterSet characterSetWithCharactersInString:@"@Aa()"];
    NSScanner *addedPointScanner =
        [NSScanner scannerWithString:addedPointsMatchString];
    NSInteger freshPoints;
    [addedPointScanner scanCharactersFromSet:addedPointsCharacterSet
                                  intoString:NULL];
    [addedPointScanner scanInteger:&freshPoints];
    if (freshPoints > 0) {
      [myTextStorage addAttributes:boldAttributes range:matchRange];
    }
  }

  NSString *myPatternTag = [NSString stringWithFormat:@"#\\w+"];
  NSRegularExpression *regexTag = [NSRegularExpression
      regularExpressionWithPattern:myPatternTag
                           options:NSRegularExpressionCaseInsensitive
                             error:&error];

  NSArray *matchesTag =
      [regexTag matchesInString:string options:0 range:NSMakeRange(0, length)];

  for (NSTextCheckingResult *match in matchesTag) {
    NSRange matchRange = [match range];
    [myTextStorage addAttributes:boldAttributes range:matchRange];
  }
}

#pragma mark method on insert in textfield
- (void)textSyntaxHighlighting:(NSNotification *)note {
  [self addSyntaxHighlighting:[self textStorage]];
}

#pragma mark autocomletion suggestions
- (NSArray *)completionsForPartialWordRange:(NSRange)charRange
                        indexOfSelectedItem:(NSInteger *)index {

  NSArray *suggestedTags =
      [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"myTags"];

  NSMutableArray *matchedTags = [NSMutableArray array];
  NSString *toMatch = [[self string] substringWithRange:charRange];
  for (NSString *tag in suggestedTags) {
    if ([tag hasPrefix:toMatch]) {
      [matchedTags addObject:tag];
    }
  }

  return matchedTags;
}

#pragma mark handling autocomplete flag

- (void)keyUp:(NSEvent *)theEvent {
  if ([[theEvent characters] isEqualToString:@"#"]) {
    autocomplete = YES;
  }
  if ([[theEvent characters] isEqualToString:@" "]) {
    autocomplete = NO;
  }

  [super keyUp:theEvent];
}

- (void)insertLineBreak:(id)sender {
  autocomplete = NO;
  [super insertLineBreak:sender];
}

- (void)insertNewline:(id)sender {
  autocomplete = NO;
  [super insertNewline:sender];
}

- (void)insertBacktab:(id)sender {
  autocomplete = NO;
  [super insertBacktab:sender];
}

- (void)insertTab:(id)sender {
  autocomplete = NO;
  [super insertTab:sender];
}

- (void)insertContainerBreak:(id)sender {
  autocomplete = NO;
  [super insertContainerBreak:sender];
}

- (void)insertParagraphSeparator:(id)sender {
  autocomplete = NO;
  [super insertParagraphSeparator:sender];
}

- (void)deleteBackward:(id)sender {

  autocomplete = NO;
  [super deleteBackward:sender];
  NSUInteger insertionPoint = [self selectedRange].location;
  int i = (int)insertionPoint;
  for (; i > 0.0; i--) {
    if ((NSUInteger)i != NSNotFound) {
      if ([[[self textStorage] string] characterAtIndex:(NSUInteger)i - 1] ==
          ' ') {
        autocomplete = NO;
        break;
      } else if ([[self string] characterAtIndex:(NSUInteger)i - 1] == '#') {
        autocomplete = YES;
        break;
      }
    }
  }
}

- (void)deleteForward:(id)sender {

  autocomplete = NO;
  [super deleteForward:sender];
  NSUInteger insertionPoint = [self selectedRange].location;
  int i = (int)insertionPoint;
  for (; i > 0.0; i--) {
    if ((NSUInteger)i != NSNotFound) {
      if ([[[self textStorage] string] characterAtIndex:(NSUInteger)i - 1] ==
          ' ') {
        autocomplete = NO;
        break;
      } else if ([[self string] characterAtIndex:(NSUInteger)i - 1] == '#') {
        autocomplete = YES;
        break;
      }
    }
  }
}

#pragma mark drag and drop

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  NSPasteboard *pboard = [sender draggingPasteboard];

    if ([[pboard types] containsObject:NSPasteboardTypeURL]) {
    NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
    NSString *myURL = [fileURL absoluteString];
    [self insertText:myURL];
  }
  return YES;
}

@end
