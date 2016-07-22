//
//  SWDocumentController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/29/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWMasterDetailViewController.h"


//extern NSString * const SWProjectButtonActionNotification;
extern NSString * const SWAllowFrameEditingDidChangeNotification;
//extern NSString * const SWEditingFrameStatusKey;
extern NSString * const SWDocumentDidBeginEditingNotification;
extern NSString * const SWDocumentDidEndEditingNotification;
extern NSString * const SWDocumentCheckPointNotification;

extern NSString * const SWDocumentControllerPartialRevealNotification;
extern NSString * const SWDocumentControllerFullRevealNotification;
extern NSString * const SWDocumentControllerAllowedInterfaceIdiomOrientationNotification;

@class SWDocumentModel;
@class SWDocument;

@interface SWDocumentController : SWMasterDetailViewController

- (id)initWithDocument:(SWDocument*)document;

@property (nonatomic, readonly, strong) SWDocument *document;
@property (nonatomic, readonly, strong) SWDocumentModel *docModel;


@end

