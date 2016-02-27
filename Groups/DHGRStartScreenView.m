//
//  DHGRStartScreenView.m
//  Circles
//
//  Created by David Haselberger on 12/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRStartScreenView.h"

@implementation DHGRStartScreenView

- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)awakeFromNib {
  [self setDrawsBackground:YES];
  CGFloat rFloat = 230.0 / 255.0;
  CGFloat gFloat = 230.0 / 255.0;
  CGFloat bFloat = 230.0 / 255.0;
  NSColor *myGray = [NSColor colorWithCalibratedRed:rFloat
                                              green:gFloat
                                               blue:bFloat
                                              alpha:1.0];
  [self setBackgroundColor:myGray];
  [self setWantsLayer:YES];
  [self.layer setBackgroundColor:[myGray CGColor]];
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];
  CGFloat rFloat = 230.0 / 255.0;
  CGFloat gFloat = 230.0 / 255.0;
  CGFloat bFloat = 230.0 / 255.0;
  NSColor *myGray = [NSColor colorWithCalibratedRed:rFloat
                                              green:gFloat
                                               blue:bFloat
                                              alpha:1.0];
  [myGray set];
  [NSBezierPath fillRect:dirtyRect];
  NSRectFill(dirtyRect);
  [ctx restoreGraphicsState];
  [super drawRect:dirtyRect];
}

@end
