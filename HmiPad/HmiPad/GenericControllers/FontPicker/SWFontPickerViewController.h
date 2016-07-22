//
//  SWFontPickerViewController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewController.h"

@class SWFontPickerViewController;

@protocol SWFontPickerDelegate <NSObject>

- (void)fontPicker:(SWFontPickerViewController*)picker didSelectFontName:(NSString*)fontName;

@end

@interface SWFontPickerViewController : SWTableViewController
{
    NSArray *_fontFamilyNames;
    NSArray *_fontList;
    NSArray *_indexTitles;
}

@property (nonatomic, strong) NSString *selectedFontName;
@property (nonatomic, weak) id <SWFontPickerDelegate> delegate;

@end
