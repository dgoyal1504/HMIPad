//
//  SWImagePickerController.h
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWImagePickerController;

@protocol SWImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerController:(SWImagePickerController*)imagePicker didSelectImageAtPath:(NSString*)path;
//- (void)imagePickerController:(SWImagePickerController*)imagePicker didSelectImage:(UIImage*)image;

@end

@interface SWImagePickerController : UIViewController <UIActionSheetDelegate>

- (id)initWithContentsAtPath:(NSString*)path;

@property (nonatomic, readonly, strong) NSString *path;
@property (nonatomic, strong) NSString *selectedFileName;
@property (nonatomic, assign) BOOL allowsDeletion;
@property (nonatomic, weak) id <SWImagePickerControllerDelegate> delegate;

@end
