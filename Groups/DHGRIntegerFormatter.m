//
//  DHGRIntegerFormatter.m
//  Circles
//
//  Created by David Haselberger on 17/01/15.
//  Copyright (c) 2015 David Haselberger. All rights reserved.
//

#import "DHGRIntegerFormatter.h"

@implementation DHGRIntegerFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error
{
    if([partialString length] == 0) {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        return NO;
    }
    
    return YES;
}

@end
