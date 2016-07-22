//
//  SWImagePickerView.h
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWImagePickerView;

@protocol SWImagePickerViewDataSource <NSObject>

@required
- (NSInteger)numberOfImagesForImagePickerView:(SWImagePickerView*)imagePickerView;
- (UIImage*)imagePickerView:(SWImagePickerView*)imagePickerView imageAtIndex:(NSInteger)index;

@end

@protocol SWImagePickerViewDelegate <UIScrollViewDelegate>

@optional
- (void)imagePickerView:(SWImagePickerView*)imagePickerView didSelectImageAtIndex:(NSInteger)index;

@end

@interface SWImagePickerView : UIScrollView

- (void)reloadData;

- (NSIndexSet*)selectedImages;

- (void)insertImagesAtIndexes:(NSIndexSet*)indexSet;
- (void)deleteImagesAtIndexes:(NSIndexSet*)indexSet;

@property (nonatomic, assign) CGFloat thumbnailSide;
@property (nonatomic, assign, getter = isEditing) BOOL editing;
@property (nonatomic, assign) BOOL borderedImages;
@property (nonatomic, weak) IBOutlet id <SWImagePickerViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <SWImagePickerViewDelegate> delegate;

@end
