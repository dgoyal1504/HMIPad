//
//  SWPasteboardTypes.h
//  HmiPad
//
//  Created by Joan Martin on 8/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kPasteboardContentDidChangeNotification;
extern NSString * const kSymbolicCodingCollectionKey;

extern NSString * const kPasteboardTypeItemList;
extern NSString * const kPasteboardPageListType;
extern NSString * const kPasteboardAlarmListType;
extern NSString * const kPasteboardProjectUserListType;
extern NSString * const kPasteboardDatabaseListType;
extern NSString * const kPasteboardRestApiItemListType;
extern NSString * const kPasteboardBackgroundItemListType;
extern NSString * const kPasteboardSourceListType;
extern NSString * const kPasteboardTypeTagList;

@interface UIPasteboard (ApplicationPasteboard)

+ (UIPasteboard*)applicationPasteboard;

@end