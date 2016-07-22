//
//  SWColorCoverView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/13/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWZoomableViewController.h"

@interface SWColorCoverView : UIView<SWZoomableViewController>

//- (id)initWithFrame:(CGRect)frame andColor:(UIColor*)color;
- (id)initForRect:(CGRect)frame andColor:(UIColor*)color;

@property (nonatomic, strong) UIColor *coverColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) BOOL editMode;
@property (nonatomic, assign) BOOL showsCoverInEditMode;

@end
