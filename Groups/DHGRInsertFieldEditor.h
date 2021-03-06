//
//  DHGRInsertFieldEditor.h
//  Groups
//
//  Created by David Haselberger on 10/7/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DHGRInsertFieldEditor : NSTextView <NSTextStorageDelegate> {
  BOOL autocomplete;
  BOOL isAutoCompleting;
}

- (void)addSyntaxHighlighting:(NSTextStorage *)myTextStorage;
- (void)textSyntaxHighlighting:(NSNotification *)note;

@end
