//
//  DHGRReportsTableCellView.m
//  Circles
//
//  Created by David Haselberger on 23/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRReportsTableCellView.h"

@implementation DHGRReportsTableCellView

- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}


- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
  [super setBackgroundStyle:backgroundStyle];
  for (NSView *subview in [self subviews]) {
    if ([subview isKindOfClass:[NSButton class]]) {
        if ([self backgroundStyle] == NSBackgroundStyleNormal) {
        [(NSButton *)subview
            setImage:[NSImage imageNamed:@"circles-icon-edit_16x16.pdf"]];
      } else {
        if ([[[self window] firstResponder]
                isKindOfClass:[NSTableView class]]) {
          [(NSButton *)subview
              setImage:[NSImage imageNamed:@"circles-icon-edit_inv_16x16_Template.pdf"]];
        } else {
          [(NSButton *)subview
              setImage:[NSImage imageNamed:@"circles-icon-edit_16x16_Template.pdf"]];
        }
      }
    }
  }
}

@end
