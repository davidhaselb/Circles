//
//  DHGRWhiteColorView.m
//  Groups
//
//  Created by David Haselberger on 03/02/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRWhiteColorView.h"

@implementation DHGRWhiteColorView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  [ctx saveGraphicsState];
  [super drawRect:dirtyRect];
  [ctx restoreGraphicsState];

  [ctx saveGraphicsState];
  NSColor *mGray =
      [NSColor colorWithCalibratedRed:0.9f green:0.9f blue:0.9f alpha:1.0];
  [mGray setFill];
  NSRectFill(dirtyRect);
  [ctx restoreGraphicsState];
  NSRect rect = [self bounds];
  NSRect newRect = NSMakeRect(rect.origin.x + 4, rect.origin.y + 4,
                              rect.size.width - 5, rect.size.height - 8);
  NSBezierPath *textViewSurround =
      [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:5 yRadius:5];
  [textViewSurround setLineWidth:1.0f];
  NSColor *grayDarker =
      [NSColor colorWithCalibratedRed:0.98f green:0.98f blue:0.98f alpha:1.0];
  [grayDarker set];
  [textViewSurround stroke];
  CGFloat greyFloat = 245.0 / 255.0;
  NSColor *grayWhite = [NSColor colorWithCalibratedRed:greyFloat
                                                 green:greyFloat
                                                  blue:greyFloat
                                                 alpha:1.0];
  [grayWhite set];
  [textViewSurround fill];
}

@end
