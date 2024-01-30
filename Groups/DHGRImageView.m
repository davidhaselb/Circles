//
//  DHGRImageCell.m
//  Circles
//
//  Created by David Haselberger on 28/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRImageView.h"
#import "DHGRImage.h"

@implementation DHGRImageView

- (void)awakeFromNib {
//  [self setWantsLayer:YES];
//  self.layer.cornerRadius = self.frame.size.width / 2.0f;
//  self.layer.masksToBounds = YES;
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    
    [NSGraphicsContext saveGraphicsState];
     NSRect imageRect = NSMakeRect(self.frame.origin.x-3, self.frame.origin.y-3, self.frame.size.width, self.frame.size.height);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:imageRect xRadius:45 yRadius:45];
    [path addClip];
    
    //set the size
    [[self image] setSize:imageRect.size];
    
    //draw the image
    [[self image] drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    [NSGraphicsContext restoreGraphicsState];
    //[super drawRect:dirtyRect];

}

@end
