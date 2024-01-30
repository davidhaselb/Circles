//
//  DHGRInsertTextView.h
//  Groups
//
//  Created by David Haselberger on 03/02/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DHGRInsertTextView : NSTextView <NSTextStorageDelegate> {
  BOOL autocomplete;
  BOOL isAutoCompleting;
}

- (void)addSyntaxHighlighting:(NSTextStorage *)myTextStorage;
- (void)textSyntaxHighlighting:(NSNotification *)note;

@end
