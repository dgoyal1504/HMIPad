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
@optional
- (UIImage*)imagePickerView:(SWImagePickerView*)imagePickerView imageAtIndex:(NSInteger)index;
- (NSString*)imagePickerView:(SWImagePickerView*)imagePickerView imagePathAtIndex:(NSInteger)index;

@end

@protocol SWImagePickerViewDelegate <UIScrollViewDelegate>

@optional
- (void)imagePickerView:(SWImagePickerView*)imagePickerView didSelectImageAtIndex:(NSInteger)index;

@end

@interface SWImagePickerView : UIScrollView

- (void)reloadData;

- (NSIndexSet*)selectedImageIndexes;

- (void)insertImagesAtIndexes:(NSIndexSet*)indexSet;
- (void)deleteImagesAtIndexes:(NSIndexSet*)indexSet;
- (void)selectImagesAtIndexes:(NSIndexSet*)indexSet;
- (void)highlightImageAtIndex:(NSInteger)index;

@property (nonatomic, assign) CGFloat thumbnailSide;
@property (nonatomic, assign, getter = isEditing) BOOL editing;
@property (nonatomic, assign) BOOL borderedImages;
@property (nonatomic, weak) id <SWImagePickerViewDataSource> dataSource;
@property (nonatomic, weak) id <SWImagePickerViewDelegate> delegate;

@end
