//
//  SWModelManager.h
//  HmiPad
//
//  Created by Joan Martin on 8/28/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>



#import "SWModelBrowserProtocols.h"
#import "SWFontPickerViewController.h"
#import "SWColorPickerViewController.h"
#import "SWImagePickerController.h"


#import "SWModelManagerTypes.h"
#import "SWModelTypes.h"

// FloatingPopover
#import "SWFloatingPopoverManager.h"

@class SWModelManager;
@class SWValue;

@protocol SWModelManagerDelegate <NSObject>

@optional
- (void)modelManager:(SWModelManager*)manager acceptedTypesForValueSeeker:(SWValue*)value;
- (void)modelManager:(SWModelManager*)manager didSelectValue:(SWValue*)value;

@end

@class SWDocumentModel;
@class SWValue;


@interface SWModelManagerCenter : NSObject

+ (SWModelManagerCenter*)defaultCenter;

- (SWModelManager*)managerForDocumentModel:(SWDocumentModel*)documentModel;
- (void)addManagerWithDocumentModel:(SWDocumentModel*)documentModel forPresentingInController:(UIViewController*)presentingController;
- (void)removeManagerWithDocumentModel:(SWDocumentModel*)documentModel; // <----- S'ha de cridar aquest mètode quan es vulgui eliminar el projecte, doncs s'està retenint el manager (i.e. el docModel).

@end




@interface SWModelManager : NSObject <SWFloatingPopoverControllerDelegate>

//+ (SWModelManager*)managerForDocumentModel:(SWDocumentModel*)documentModel;

- (id)initWithDocumentModel:(SWDocumentModel*)documentModel forPresentingInController:(UIViewController*)presentingController;
//- (void)prepareForDeletion; // <----- S'ha de cridar aquest mètode quan es vulgui eliminar el projecte, doncs s'està retenint el manager (i.e. el docModel).

// -- Getting Controller Instances -- //
//- (UINavigationController*)modelBrowser;
- (UINavigationController*)modelBrowserAtStartingObject:(id)object acceptedTypes:(NSIndexSet*)acceptedTypes;
- (UIViewController*)modelSeekerAtStartingObject:(id)object valueType:(SWType)type delegate:(id<SWModelManagerDelegate>)delegate;
- (UIViewController*)modelSeekerForValue:(SWValue*)value delegate:(id<SWModelManagerDelegate>)delegate;
- (id)currentSeekedObject;

// -- Managing the default model browser -- //
- (void)presentModelBrowserAnimated:(BOOL)animated;
- (void)dismissModelBrowserAnimated:(BOOL)animated;
- (BOOL)isModelBrowserPresented;

// -- Managing Configurators -- //
- (void)presentModelConfiguratorForObject:(id)object animated:(BOOL)animated;
- (void)dismissModelConfiguratorForObject:(id)object animated:(BOOL)animated;
- (void)dismissModelConfiguratorForObjects:(NSArray*)array animated:(BOOL)animated;
- (void)dismissAllModelConfiguratorsAnimated:(BOOL)animated;

// -- Managing Floating Popovers -- //
- (void)hidePresentedPopoversAnimated:(BOOL)animated;
- (void)presentHiddenPopoversAnimated:(BOOL)animated;

@property (nonatomic, strong, readonly) SWDocumentModel *documentModel;
@property (nonatomic, assign) CGSize contentSizeInPopover;
@property (nonatomic, assign) CGSize seekerContentSizeInPopover;
//@property (nonatomic, weak) id <SWModelManagerDelegate> delegate;

@end

//#import "SWModelBrowserProtocols.h"
//#import "SWFontPickerViewController.h"
//#import "SWColorPickerViewController.h"
//#import "SWImagePickerController.h"

@interface SWModelManager (Delegates) <SWModelBrowserDelegate, SWColorPickerDelegate, SWFontPickerDelegate, SWImagePickerControllerDelegate>
@end
