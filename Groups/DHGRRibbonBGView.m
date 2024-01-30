//
//  DHGRRibbonBGView.m
//  Groups
//
//  Created by David Haselberger on 23/05/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRRibbonBGView.h"

@implementation DHGRRibbonBGView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];
  NSColor *mGray =
      [NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:1.0];
  [mGray setFill];
  NSRectFill(dirtyRect);
  [ctx restoreGraphicsState];
  [super drawRect:dirtyRect];
}

@end
