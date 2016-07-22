//
//  SWModelBrowserProtocols.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 7/23/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWModelManagerTypes.h"

@class SWValue;
@class SWObject;
@class SWDocumentModel;

@protocol SWModelBrowserViewController;

@protocol SWModelBrowserDelegate <NSObject>

@optional
- (void)modelBrowser:(UIViewController<SWModelBrowserViewController>*)controller didSelectValue:(SWValue*)value;
@end


@protocol SWModelBrowserViewController <NSObject>

@required
@property (nonatomic, assign) SWModelBrowsingStyle browsingStyle;
@property (nonatomic, weak) id <SWModelBrowserDelegate> delegate;
@property (nonatomic, readonly) id identifiyingObject;
- (id)initWithObject:(id)object classIdentifierObject:(id)identifyingObject;
@end

