//
//  DHGRImage.m
//  Circles
//
//  Created by David Haselberger on 28/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRImage.h"

@implementation DHGRImage

+ (NSImage *)roundCorners:(NSImage *)image {
  NSImage *existingImage = image;
  NSSize existingSize = [existingImage size];
  NSSize newSize;
  if(existingSize.width != 0)
  {
      newSize = NSMakeSize(existingSize.height, existingSize.width);
  }else
  {
      newSize = NSMakeSize(80,80);
  }
  NSImage *composedImage = [[NSImage alloc] initWithSize:newSize];
  [composedImage lockFocus];
  [NSGraphicsContext saveGraphicsState];
  NSRect imageFrame =
      NSRectFromCGRect(CGRectMake(0, 0, newSize.width, newSize.height));
  NSBezierPath *path =
      [NSBezierPath bezierPathWithRoundedRect:imageFrame
                                      xRadius:newSize.width / 2.0
                                      yRadius:newSize.height / 2.0];
    [path setWindingRule:NSWindingRuleEvenOdd];
  [path addClip];
  [image drawInRect:imageFrame
           fromRect:NSZeroRect
          operation:NSCompositingOperationSourceOver
           fraction:1.0];
  [NSGraphicsContext restoreGraphicsState];
  [composedImage unlockFocus];
  return composedImage;
}

@end
