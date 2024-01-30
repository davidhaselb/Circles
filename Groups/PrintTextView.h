//
//  PrintTextView.h
//
//

#import <Cocoa/Cocoa.h>


@interface PrintTextView : NSTextView {

    NSString *printJobTitle;
}
@property (copy, readwrite) NSString *printJobTitle;



@end
