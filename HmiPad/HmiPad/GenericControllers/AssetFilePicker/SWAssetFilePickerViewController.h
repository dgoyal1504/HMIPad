//
//  SWFontPickerViewController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewController.h"

@class SWAssetFilePickerViewController;

@protocol SWAssetFilePickerDelegate <NSObject>

- (void)assetFilePicker:(SWAssetFilePickerViewController*)picker didSelectAssetAtPath:(NSString*)path;

@end

@interface SWAssetFilePickerViewController : SWTableViewController
{
    NSMutableArray *_filePaths;
    NSString *_selectedFilePath;
}

- (id)initWithContentsAtPath:(NSString*)path;

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *selectedFileName;
@property (nonatomic, weak) id <SWAssetFilePickerDelegate> delegate;

@end
