//
//  SWImagePickerController.h
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWImagePickerView.h"

@class SWImagePickerController;

@protocol SWImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePickerController:(SWImagePickerController*)imagePicker didSelectImageAtPath:(NSString*)path;
- (void)imagePickerController:(SWImagePickerController*)imagePicker didSelectImage:(UIImage*)image;

@end

@interface SWImagePickerController : UIViewController <SWImagePickerViewDelegate, SWImagePickerViewDataSource, UIActionSheetDelegate>

- (id)initWithContentsAtPath:(NSString*)path;

@property (nonatomic, readonly, strong) NSString *path;
@property (nonatomic, assign) BOOL allowsDeletion;
@property (nonatomic, weak) IBOutlet id <SWImagePickerControllerDelegate> delegate;

@end
