//
//  DHGRDateButtonCell.m
//  Groups
//
//  Created by David Haselberger on 03/04/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRDateButtonCell.h"

@implementation DHGRDateButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
  NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
  CGFloat roundedRadius = 3.0f;
  NSColor *black = [NSColor blackColor];
  NSColor *gray = [NSColor grayColor];
  NSColor *white = [NSColor whiteColor];
  if ([self isHighlighted]) {
    [ctx saveGraphicsState];
    NSBezierPath *backgroundPath =
        [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.0f, 2.0f)
                                        xRadius:roundedRadius
                                        yRadius:roundedRadius];
    [backgroundPath setClip];
    NSRect bezBounds = [backgroundPath bounds];
    [black set];
    [NSBezierPath fillRect:bezBounds];
      NSRect whiteRect = NSMakeRect(bezBounds.origin.x, bezBounds.size.height - (bezBounds.size.height/1.8), bezBounds.size.width, bezBounds.size.height);
    [white set];
    [NSBezierPath fillRect:whiteRect];
    [gray set];
    [backgroundPath setLineWidth:1.5f];
    [backgroundPath stroke];
    [ctx restoreGraphicsState];
  } else {
    [ctx saveGraphicsState];
    NSBezierPath *backgroundPath =
        [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(frame, 2.0f, 2.0f)
                                        xRadius:roundedRadius
                                        yRadius:roundedRadius];
    [backgroundPath setClip];

    NSRect bezBounds = [backgroundPath bounds];
    [black set];
    [NSBezierPath fillRect:bezBounds];
    NSRect whiteRect = NSMakeRect(bezBounds.origin.x, bezBounds.size.height - (bezBounds.size.height/1.8), bezBounds.size.width, bezBounds.size.height);
    [white set];
    [NSBezierPath fillRect:whiteRect];
    [ctx restoreGraphicsState];
  }
}

@end
