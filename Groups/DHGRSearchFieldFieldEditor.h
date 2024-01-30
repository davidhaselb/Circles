//
//  DHGRSearchFieldFieldEditor.h
//  Groups
//
//  Created by David Haselberger on 17/12/13.
//  Copyright (c) 2013 David Haselberger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DHGRSearchFieldFieldEditor : NSTextView <NSTextStorageDelegate> {
  BOOL autocomplete;
  BOOL isAutoCompleting;
}

@end
