//
//  SWPasteboardTypes.m
//  HmiPad
//
//  Created by Joan Martin on 8/22/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWPasteboardTypes.h"

NSString * const kPasteboardContentDidChangeNotification = @"PasteboardContentDidChangeNotification";
NSString * const kSymbolicCodingCollectionKey = @"SymbolicCodingCollectionKey";

NSString * const kPasteboardTypeItemList = @"PasteboardTypeItemList";
NSString * const kPasteboardPageListType = @"PasteboardPageListType";
NSString * const kPasteboardAlarmListType = @"PasteboardAlarmListType";
NSString * const kPasteboardProjectUserListType = @"PasteboardProjectUserListType";
NSString * const kPasteboardDatabaseListType = @"PasteboardDatabaseListType";
NSString * const kPasteboardRestApiItemListType = @"PasteboardRestApiItemListType";
NSString * const kPasteboardBackgroundItemListType = @"PasteboardBackgroundItemListType";
NSString * const kPasteboardSourceListType = @"PasteboardSourceListType";
NSString * const kPasteboardTypeTagList = @"PasteboardTypeTagList";

@implementation UIPasteboard (ApplicationPasteboard)

+ (UIPasteboard*)applicationPasteboard
{
    static UIPasteboard *pasteboard = nil;
    
    if (!pasteboard)
    {
        NSString *pasteboardName = [[NSBundle mainBundle] bundleIdentifier];
        pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
        pasteboard.persistent = YES;
    }
    
    return pasteboard;
}

@end