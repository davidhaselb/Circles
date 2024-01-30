//
//  DHGRReportTextField.m
//  Groups
//
//  Created by David Haselberger on 10/7/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRReportTextField.h"

@implementation DHGRReportTextField

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)awakeFromNib {
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}

- (void)mouseDownForTextFields:(NSEvent *)theEvent {
    if ((NSEventModifierFlagCommand | NSEventModifierFlagShift) & [theEvent modifierFlags])
    return;
  NSPoint selfPoint =
      [self convertPoint:theEvent.locationInWindow fromView:nil];
  // for (NSView* subview in [self subviews])
  // if ([subview isKindOfClass:[NSTextField class]])
  if (NSPointInRect(selfPoint, [self frame])) {
  }
}

@end
