//
//  SWAuxiliarFilesViewController.h
//  HmiPad
//
//  Created by Joan on 08/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppModelCategories.h"

#pragma mark SWAuxiliarFilesViewController

@class SWDocument;

@interface SWAuxiliarFilesViewController : UIViewController
{
}

- (id)initWithFileCategory:(FileCategory)aCategory;
//- (id)initWithFileCategory:(int)aCategory forDocument:(SWDocument*)document;
@end
