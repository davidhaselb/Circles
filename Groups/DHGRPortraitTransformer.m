//
//  DHGRPortraitTransformer.m
//  Groups
//
//  Created by David Haselberger on 03/01/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRPortraitTransformer.h"

@implementation DHGRPortraitTransformer

+ (Class)transformedValueClass {
  return [NSImage class];
}
- (id)transformedValue:(id)value {
  if (value == nil) {
    return nil;
  } else {
    return [[NSImage alloc] initWithData:value];
  }
}

@end
