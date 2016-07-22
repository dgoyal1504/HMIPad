//
//  SWImagePickerViewCell.h
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWImagePickerViewCell;
@class SWImageDescriptor;

@protocol SWImagePickerViewCellDelegate <NSObject>

- (void)tapReceivedInImagePickerViewCell:(SWImagePickerViewCell*)cell;

@end

@interface SWImagePickerViewCell : UIView

- (void)prepareForReuse;

@property (nonatomic, readwrite) UIImage *image;
//@property (nonatomic, strong) SWImageDescriptor *imageDescriptor;
@property (nonatomic, assign) BOOL showBorder;
@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;

@property (nonatomic, weak) id <SWImagePickerViewCellDelegate> delegate;

-(void)setImageWithDescriptor:(SWImageDescriptor *)imageDescriptor;

@end
