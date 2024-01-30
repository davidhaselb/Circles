//
//  DHGRSearchFieldFieldEditor.m
//  Groups
//
//  Created by David Haselberger on 17/12/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRSearchFieldFieldEditor.h"

@implementation DHGRSearchFieldFieldEditor

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setFieldEditor:YES];
    autocomplete = NO;
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}

- (void)didChangeText {
  [super didChangeText];
  if (!isAutoCompleting) {
    isAutoCompleting = YES;

    if (autocomplete) {
      [self complete:nil];
    }
    isAutoCompleting = NO;
  }
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

@end
