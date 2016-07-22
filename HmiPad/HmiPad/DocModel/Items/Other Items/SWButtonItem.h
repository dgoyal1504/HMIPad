//
//  SWButtonItem.h
//  HmiPad
//
//  Created by Joan on 03/07/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWControlItem.h"

@interface SWButtonItem : SWControlItem

@property (nonatomic, readonly) SWValue *buttonStyle;
@property (nonatomic, readonly) SWExpression *value;
@property (nonatomic, readonly) SWExpression *color;

@property (nonatomic, readonly) SWExpression *title;
@property (nonatomic, readonly) SWValue *textAlignment;
@property (nonatomic, readonly) SWValue *verticalTextAlignment;
@property (nonatomic, readonly) SWExpression *font;
@property (nonatomic, readonly) SWExpression *fontSize;

@property (nonatomic, readonly) SWValue *aspectRatio;
@property (nonatomic, readonly) SWExpression *imagePath;
@property (nonatomic, readonly) SWExpression *animationDuration;

@property (nonatomic, readonly) SWExpression *active;
@property (nonatomic, readonly) SWExpression *linkToPage;
@end
