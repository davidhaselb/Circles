//
//  DHGRSplitView.m
//  Circles
//
//  Created by David Haselberger on 12/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRSplitView.h"

@implementation DHGRSplitView

- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
}

- (CGFloat)dividerThickness {
  return 0.5;
}

@end
