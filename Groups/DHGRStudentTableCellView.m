//
//  DHGRReportTableCellView.m
//  Circles
//
//  Created by David Haselberger on 12/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRStudentTableCellView.h"

@implementation DHGRStudentTableCellView

@synthesize button;

- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)awakeFromNib {
    [[self.button cell] setBezelStyle:NSBezelStyleBadge];
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}

- (void)viewWillDraw {
  [super viewWillDraw];
  if (![[self.button title] isEqualToString:@""]) {
    [self.button sizeToFit];
    [[self.button cell] setHighlightsBy:0];
    [self.button setHidden:NO];
    NSRect buttonFrame = self.button.frame;
    buttonFrame.origin.x = NSWidth(self.frame) - NSWidth(buttonFrame) - 3.0;
    self.button.frame = buttonFrame;
  } else {
    [self.button setHidden:YES];
  }
}

- (void)dealloc
{
    self.button = nil;
}

@end
