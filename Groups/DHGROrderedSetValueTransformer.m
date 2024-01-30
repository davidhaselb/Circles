//
//  DHGROrderedSetValueTransformer.m
//  Circles
//
//  Created by David Haselberger on 30/05/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGROrderedSetValueTransformer.h"

@implementation DHGROrderedSetValueTransformer

+ (Class)transformedValueClass {
  return [NSArray class];
}

+ (BOOL)allowsReverseTransformation {
  return YES;
}

- (id)transformedValue:(id)value {
  return [(NSOrderedSet *)value array];
}

- (id)reverseTransformedValue:(id)value {
  return [NSOrderedSet orderedSetWithArray:value];
}

@end
