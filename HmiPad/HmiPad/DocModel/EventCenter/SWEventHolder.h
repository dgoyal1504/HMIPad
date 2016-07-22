//
//  SWEventHolder.h
//  HmiPad
//
//  Created by Joan Martin on 8/7/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWEvent;

@protocol SWEventHolder <NSObject>

- (NSString*)titleForEvent;
- (NSString*)commentForEvent;
- (BOOL)activeStateForEvent;
- (NSString*)fullSoundUrlTextForEvent;
- (BOOL)shouldShowAlertForEvent;

@end
