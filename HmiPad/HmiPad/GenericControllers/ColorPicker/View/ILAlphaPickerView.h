//
//  ILAlphaPickerView.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "ILView.h"

typedef enum {
    ILAlphaPickerViewOrientationHorizontal     =   0,
    ILAlphaPickerViewOrientationVertical       =   1
} ILAlphaPickerViewOrientation;

@class ILAlphaPickerView;

@protocol ILAlphaPickerViewDelegate

- (void)alphaPicked:(float)alpha picker:(ILAlphaPickerView*)picker pickingFinished:(BOOL)flag;

@end

@interface ILAlphaPickerView : ILView

@property (weak, nonatomic) IBOutlet id<ILAlphaPickerViewDelegate> delegate;
@property (assign, nonatomic) CGFloat alphaValue;
@property (assign, nonatomic) ILAlphaPickerViewOrientation pickerOrientation;

- (void)setAlphaFromColor:(UIColor *)cc;

@end
