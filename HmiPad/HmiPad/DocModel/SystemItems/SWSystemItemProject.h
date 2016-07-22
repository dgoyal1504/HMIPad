//
//  SWSystemItemProject.h
//  HmiPad
//
//  Created by Joan on 31/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWSystemItem.h"
#import "SWDocumentModel.h"

@interface SWSystemItemProject : SWSystemItem<DocumentModelObserver>

@property (nonatomic,readonly) SWExpression *currentPageIdentifier;
@property (nonatomic,readonly) SWValue *title;
@property (nonatomic,readonly) SWValue *shortTitle;
@property (nonatomic,readonly) SWValue *allowedOrientation;
@property (nonatomic,readonly) SWValue *allowedOrientationPhone;

- (void)updateCurrentPageIdentifierIfNeeded;
@end
