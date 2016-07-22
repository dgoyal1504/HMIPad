//
//  SWImagePickerViewCell.h
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWImagePickerViewCell;

@protocol SWImagePickerViewCellDelegate <NSObject>

- (void)tapReceivedInImagePickerViewCell:(SWImagePickerViewCell*)cell;

@end

@interface SWImagePickerViewCell : UIView

- (void)prepareForReuse;

@property (nonatomic, readwrite) UIImage *image;
@property (nonatomic, assign) BOOL showBorder;
@property (nonatomic, assign, getter = isSelected) BOOL selected;

@property (nonatomic, weak) id <SWImagePickerViewCellDelegate> delegate;

@end
