//
//  DHGRExportController.m
//  Circles
//
//  Created by David Haselberger on 28/06/14.
//  Copyright (c) 2014 David Haselberger. All rights reserved.
//

#import "DHGRExportController.h"
#import "PrintTextView.h"
#import "DHGRReport.h"
#import "DHGRImage.h"
#import "DHGRStudent.h"

#define exportFormatCSV 1
#define exportFormatPDF 2

@implementation DHGRExportController

- (NSString *)csvOfReportInArray:(NSArray *)reportsToExport {
  if ([reportsToExport count] > 0) {
    NSMutableArray *csvStringsToBeJoined = [[NSMutableArray alloc] init];

    for (NSManagedObject *aReport in reportsToExport) {
      NSString *separator = @"| ";
      NSDate *entryDate = [aReport valueForKey:@"date"];
    NSString *dateOfEntry =
        [NSDateFormatter localizedStringFromDate:entryDate
                                       dateStyle:NSDateFormatterLongStyle
                                       timeStyle:NSDateFormatterShortStyle];
      NSString *entryContent = [aReport valueForKey:@"contentString"];
      NSString* textQualifier = [NSString stringWithFormat:@"\""];
      NSArray* contentArray = [NSArray arrayWithObjects:textQualifier, entryContent, textQualifier, nil];
      NSString *myContent = [contentArray componentsJoinedByString:@" "];
      NSString *noNewlineContentString = [[myContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
      NSString *adds = [[aReport valueForKey:@"points"] stringValue];
      NSString *entryRating = [[aReport valueForKey:@"rating"] stringValue];
        NSString *ratingForEntry = entryRating ? entryRating : @"0";
      NSArray *entryAttributes = @[dateOfEntry, noNewlineContentString, adds, ratingForEntry];
      NSString *myEntry = [entryAttributes componentsJoinedByString:separator];
      [csvStringsToBeJoined addObject:myEntry];
    }
    NSString *csv =
        [[csvStringsToBeJoined copy] componentsJoinedByString:@"\n"];
    return csv;
  }
  return [NSString stringWithFormat:@""];
}

- (NSString *)suggestedFileNameForArray:(NSArray *)reportsToExport withFormat:(int)format
                              andWindow:(NSWindow *)currentWindow {
  if ([reportsToExport count] > 0) {
    NSManagedObject *thePerson =
        [reportsToExport[0] valueForKey:@"belongsTo"];
    NSString *name = [thePerson valueForKey:@"firstName"];
    NSString *fileName = [currentWindow title];
    NSString *fileNameForReal;
    NSString *regEx = [NSString stringWithFormat:@"Untitled*"];
    NSRange range =
        [fileName rangeOfString:regEx options:NSRegularExpressionSearch];

    if (range.location == NSNotFound) {
      if ([[fileName pathExtension] isEqualToString:@".circles"]) {
        fileNameForReal =
            [fileName substringToIndex:[fileName rangeOfString:@"."].location];
      } else {
        fileNameForReal = fileName;
      }
    } else {
      fileNameForReal = [NSString stringWithFormat:@"Untitled"];
    }
    if (!name) {
      name = [NSString stringWithFormat:@"Person"];
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *exportDate = [dateFormat stringFromDate:[NSDate date]];
    NSString* formatString;
    switch (format) {
          case exportFormatCSV:
            formatString = [NSString stringWithFormat:@"csv"];
              break;
        case exportFormatPDF:
            formatString = [NSString stringWithFormat:@"pdf"];
            break;
          default:
            formatString = [NSString stringWithFormat:@"circles"];
            break;
      }

    NSString *suggestion = [NSString
        stringWithFormat:@"%@_%@_%@.%@", fileNameForReal, name, exportDate, formatString];
    return suggestion;
  }
  return [NSString stringWithFormat:@""];
}

- (void)saveCSV:(NSString *)currentCSV
    withSuggestedFileName:(NSString *)suggestedFileName
                 inWindow:(NSWindow *)currentWindow {
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setNameFieldStringValue:suggestedFileName];
  [panel beginSheetModalForWindow:currentWindow
                completionHandler:^(NSInteger result) {
      if (result == NSModalResponseOK) {
                      [currentCSV writeToURL:[panel URL]
                                  atomically:YES
                                    encoding:NSMacOSRomanStringEncoding
                                       error:nil];
                    }
                }];
}

- (void)exportAsCSVfromArray:(NSArray *)reportsToExport
                    inWindow:(NSWindow *)actualWindow {
  if ([reportsToExport count] > 0) {
    NSString *csvString = [self csvOfReportInArray:reportsToExport];
    NSString *fileName =
      [self suggestedFileNameForArray:reportsToExport withFormat:exportFormatCSV andWindow:actualWindow];
    [self saveCSV:csvString
        withSuggestedFileName:fileName
                     inWindow:actualWindow];
  } else {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Ok"];
    [alert setMessageText:[NSString
                              stringWithFormat:
                                  @"No entry collection to export selected."]];
    [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
      [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:actualWindow
                  completionHandler:^(NSInteger result) {
                      if (result == NSAlertFirstButtonReturn) {
                      }
                  }];
  }
}


#pragma mark PDF export

- (void)exportAsPDFfromArray:(NSArray *)reportsToExport
                    inWindow:(NSWindow *)actualWindow
{
    
    if ([reportsToExport count] > 0) {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:[self suggestedFileNameForArray:reportsToExport withFormat:exportFormatPDF andWindow:actualWindow]];
    [panel beginSheetModalForWindow:actualWindow
                    completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
    
            NSPrintInfo *pInfo;
            NSPrintInfo *sharedInfo;
            NSPrintOperation *printOp;
            NSMutableDictionary *printInfoDict;
            NSMutableDictionary *sharedDict;
            
            sharedInfo = [NSPrintInfo sharedPrintInfo];
            sharedDict = [sharedInfo dictionary];
            printInfoDict = [NSMutableDictionary dictionaryWithDictionary: sharedDict];
            
            [printInfoDict setObject:NSPrintSaveJob
                              forKey:NSPrintJobDisposition];
            
            [printInfoDict setObject:[panel URL] forKey:NSPrintJobSavingURL];
            
            pInfo = [[NSPrintInfo alloc] initWithDictionary:printInfoDict];
            [pInfo setVerticalPagination: NSPrintingPaginationModeAutomatic];
            
            
            [pInfo setHorizontalPagination:NSPrintingPaginationModeFit];
            [pInfo setVerticallyCentered:NO];
            [[pInfo dictionary] setValue:[NSNumber numberWithBool:YES] forKey:NSPrintHeaderAndFooter];
            //[[pInfo dictionary] addEntriesFromDictionary:printSettings];
            PrintTextView *printView = [[PrintTextView alloc] initWithFrame:[pInfo imageablePageBounds]];
            
           
            printView.printJobTitle =  [NSString stringWithFormat:@"Report"];
            
            unichar pagebreakChar = NSFormFeedCharacter;
            NSString *pageBreakString = [NSString stringWithCharacters:&pagebreakChar length:1];
            NSAttributedString *formfeed = [[NSAttributedString alloc] initWithString:pageBreakString attributes:nil];
            unichar myChar = NSParagraphSeparatorCharacter;
            NSString *parSeparatorString = [NSString stringWithCharacters:&myChar length:1];
            
            NSMutableParagraphStyle *firstParaStyle = [[NSMutableParagraphStyle alloc] init];
            [firstParaStyle setAlignment:NSTextAlignmentCenter];
            NSDictionary *firstAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-CondensedBold" size:24], NSParagraphStyleAttributeName: firstParaStyle};
            
            NSString* printBeginString = [[NSString alloc] initWithFormat:@"%@", [self suggestedFileNameForArray:reportsToExport withFormat:exportFormatPDF andWindow:actualWindow]];
            
            [[printView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:printBeginString attributes:firstAttributes]];
            [[printView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            [[printView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            [[printView textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            
            NSMutableAttributedString* myPrintString = [[NSMutableAttributedString alloc] initWithString:@""];
                
            NSMutableParagraphStyle *nameParaStyle = [[NSMutableParagraphStyle alloc] init];
            [nameParaStyle setAlignment:NSTextAlignmentCenter];
            NSDictionary *nameAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-Light" size:24], NSParagraphStyleAttributeName: nameParaStyle};
                
                
            NSImage * imageNotRound = [[NSImage alloc] initWithData:[[reportsToExport[0] valueForKey:@"belongsTo"] valueForKey:@"portrait"]];
            if (imageNotRound == nil) {
                    imageNotRound = [NSImage imageNamed:@"NSUser"];
            }
            NSImage * portrait = [DHGRImage roundCorners:imageNotRound];
            [portrait setSize:NSMakeSize(60, 60)];
            NSTextAttachmentCell *attachmentCell = [[NSTextAttachmentCell alloc] initImageCell:portrait];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            [attachment setAttachmentCell: attachmentCell];
            NSAttributedString *portraitAttrString = [NSAttributedString  attributedStringWithAttachment:attachment];
            NSMutableAttributedString* portMut = [[NSMutableAttributedString alloc] initWithAttributedString:portraitAttrString];
            [portMut beginEditing];
            [portMut addAttribute:NSParagraphStyleAttributeName value:nameParaStyle range:NSMakeRange(0, [portMut length])];
            [portMut endEditing];
            [myPrintString appendAttributedString:[portMut copy]];
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
                
            NSAttributedString* nameString = [[NSAttributedString alloc] initWithString:[[reportsToExport[0] valueForKey:@"belongsTo"] valueForKey:@"displayString"] attributes:nameAttributes];
            [myPrintString appendAttributedString:nameString];
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
                
            NSMutableParagraphStyle *pointsParaStyle = [[NSMutableParagraphStyle alloc] init];
            [pointsParaStyle setAlignment:NSTextAlignmentCenter];
            NSDictionary *pointsAttributes = @{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue-UltraLight" size:18], NSParagraphStyleAttributeName: nameParaStyle};
            NSMutableAttributedString* attribString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:pointsAttributes];
            NSString *rating = [[reportsToExport[0] valueForKey:@"belongsTo"] myRating];
            NSString *points = [[reportsToExport[0] valueForKey:@"belongsTo"] myPoints];
            if ([rating length] > 0|[points length] > 0) {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:@" ("]];
            }
            if ([rating length] > 0)
            {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:rating]];
            }
            if ([rating length] > 0 && [points length] > 0) {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
            }
            if ([points length] > 0)
            {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:points]];
            }
            if ([rating length] > 0|[points length] > 0) {
                [attribString appendAttributedString:[[NSAttributedString alloc] initWithString:@")"]];
            }
            [attribString setAttributes:pointsAttributes range:NSMakeRange(0, [attribString length])];
            if ([attribString length] > 0)
            {
                [myPrintString appendAttributedString:[attribString copy]];
            }
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:dateSort];
            NSArray *sortedReports = [reportsToExport sortedArrayUsingDescriptors:sortDescriptors];
            for (DHGRReport* theReport in sortedReports)
            {
                [myPrintString appendAttributedString:[theReport valueForKey:@"reportString"]];
                [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
                [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
            }
            [myPrintString appendAttributedString:[[NSAttributedString alloc] initWithString:parSeparatorString]];
                
            [[printView textStorage] appendAttributedString:[myPrintString copy]];
            [[printView textStorage] appendAttributedString:formfeed];
            
            NSImage * circlesImage = [NSImage imageNamed:@"circles-icon_512x512@2x"];
            [circlesImage setSize:NSMakeSize(30, 30)];
            NSTextAttachmentCell *circlesAttachmentCell = [[NSTextAttachmentCell alloc] initImageCell:circlesImage];
            NSTextAttachment *circlesAtt = [[NSTextAttachment alloc] init];
            [circlesAtt setAttachmentCell: circlesAttachmentCell];
            NSAttributedString *circlesAttrString = [NSAttributedString  attributedStringWithAttachment:circlesAtt];
            NSMutableAttributedString* circlesMut = [[NSMutableAttributedString alloc] initWithAttributedString:circlesAttrString];
            [circlesMut beginEditing];
            [circlesMut addAttribute:NSParagraphStyleAttributeName value:firstParaStyle range:NSMakeRange(0, [circlesMut length])];
            [circlesMut endEditing];
            [[printView textStorage] appendAttributedString:[circlesMut copy]];
            
            printOp = [NSPrintOperation printOperationWithView:printView
                                                     printInfo:pInfo];
            [printOp setShowsPrintPanel:NO];
            [printOp setShowsProgressPanel:NO];
            [printOp runOperation];
        }
       }];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:[NSString
                               stringWithFormat:
                               @"No entry collection to export selected."]];
        [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:actualWindow
                      completionHandler:^(NSInteger result) {
                          if (result == NSAlertFirstButtonReturn) {
                          }
                      }];
    }
}




@end
