//
//  DHGRReport.m
//  Groups
//
//  Created by David Haselberger on 7/15/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import "DHGRReport.h"
@interface DHGRReport (ExtraAccessors)

- (void)setPrimitiveRtfString:(NSAttributedString *)value;
- (void)setContentString:(NSString *)value;

@end

@implementation DHGRReport


- (void)awakeFromInsert {
  [super awakeFromInsert];
}

+ (NSArray *)reportKeys {
  static NSArray *reportKeys = nil;

  if (reportKeys == nil)
    reportKeys =
        @[@"contentString", @"date", @"points",
                                         @"rating", @"rtfString"];

  return reportKeys;
}

- (NSDictionary *)reportDictionary {
  return [self dictionaryWithValuesForKeys:[[self class] reportKeys]];
}

- (void)setRtfString:(NSAttributedString *)value {

  [self willChangeValueForKey:@"rtfString"];
  [self setPrimitiveRtfString:value];
  NSString *pureString = [value string];
  [self setContentString:pureString];
  [self didChangeValueForKey:@"rtfString"];
}

- (NSAttributedString *)reportString {
  NSDate *dateOfReport = [self valueForKey:@"date"];
  NSString *dateString =
      [NSDateFormatter localizedStringFromDate:dateOfReport
                                     dateStyle:NSDateFormatterLongStyle
                                     timeStyle:NSDateFormatterShortStyle];
  NSAttributedString *myContent = [self valueForKey:@"rtfString"];
  NSMutableAttributedString *completeString = [[NSMutableAttributedString alloc]
      initWithString:[NSString stringWithFormat:@"%@\r", dateString]]; // \n
  [completeString appendAttributedString:myContent];
  NSMutableParagraphStyle *myParaStyle = [[NSMutableParagraphStyle alloc] init];
    [myParaStyle setAlignment:NSTextAlignmentRight];
  NSDictionary *dateAttributes = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: myParaStyle};
  [completeString
      addAttributes:dateAttributes
              range:[[completeString string]
                        rangeOfString:[NSString
                                          stringWithFormat:@"%@", dateString]]];

  return completeString;
}

@end
