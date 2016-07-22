//
//  SWModelManager.h
//  HmiPad
//
//  Created by Joan Martin on 8/28/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWModelManager;
@class SWValue;
@class SWModelBrowserController;

extern NSString * const SWModelManagerDefaultPresentingControllerKey;

@protocol SWModelManagerDelegate <NSObject>

@optional

// enviat quan el usuari selecciona un valor en el picker
- (void)modelManager:(SWModelManager*)manager didSelectValue:(SWValue*)value context:(id)context;

// enviat quan es dismisa el controlador que ha mostrat el picker (DEPRECAT 8-6-13)
//- (void)modelManager:(SWModelManager*)manager willDismissControllerForObject:(id)object value:(SWValue*)value context:(id)context;
//- (void)modelManager:(SWModelManager*)manager didDismissControllerForObject:(id)object value:(SWValue*)value context:(id)context;

// enviat al delegat anterior abans de mostrar un nou picker
//- (void)modelManager:(SWModelManager*)manager willEndPickerWithReferenceObject:(id)object context:(id)context;

// enviat al delegat quan el picker es mostra
- (void)modelManager:(SWModelManager*)manager willBeginPickerForObject:(id)object value:(SWValue*)value context:(id)context;

// enviat al delegat anterior abans de mostrar un nou picker
- (void)modelManager:(SWModelManager*)manager willEndPickerForObject:(id)object value:(SWValue*)value context:(id)context;



@end


@protocol SWModelManagerDataSource <NSObject>

// demana el view a partir del qual s'ha d'animar el picker
- (UIView*)modelManager:(SWModelManager*)manager revealViewForObject:(id)object value:(SWValue*)value context:(id)context;

@optional

- (CGRect)modelManager:(SWModelManager*)manager popoverCenterRectForObject:(id)object value:(SWValue*)value context:(id)context; // HACK: hpique: We need to propagate SWFloatingPopoverManager data source methods because the view can't access it directly.
//- (void)modelManager:(SWModelManager*)manager prepareModelBrowser:(SWModelBrowserController*)modelBrowserController object:(id)object value:(SWValue*)value context:(id)context;

@end

@class SWDocumentModel;

@interface SWModelManagerCenter : NSObject

+ (SWModelManagerCenter*)defaultCenter;

- (SWModelManager*)managerForDocumentModel:(SWDocumentModel*)documentModel;
- (void)addManagerWithDocumentModel:(SWDocumentModel*)documentModel defaultPresentingController:(UIViewController*)presentingController;
- (void)removeManagerWithDocumentModel:(SWDocumentModel*)documentModel; // <----- S'ha de cridar aquest mètode quan es vulgui eliminar el projecte, doncs s'està retenint el manager (i.e. el docModel).

@end


extern NSString * const SWModelManagerDidChangeAcceptedTypesNotification;

@class SWRevealController;
@class SWExpressionInputController;

@interface SWModelManager : NSObject

// -- Initialization -- //
- (id)initWithDocumentModel:(SWDocumentModel*)documentModel defaultPresentingController:(UIViewController*)rootPresentingController;

// -- Getting Seeker Controller Instances -- //
//- (SWRevealController*)modelSeekerAtStartingObject:(id)object withTypeFromValue:(SWValue*)value;
//- (SWRevealController*)modelSeekerForValue:(SWValue*)value;
- (SWValue*)currentSeekedValue;
- (NSIndexSet*)currentAcceptedTypes; // conte indexos que son SWType

// -- Getting Controller Instances -- //

//- (SWRevealController*)modelBrowserAtStartingObject:(id)object; //acceptedTypes:(NSIndexSet*)acceptedTypes;
//- (UIViewController*)modelConfiguratorForObject:(id)object;

// -- Managing the seeker controllers -- //

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)showRootModelPickerOnPresentingControllerWithIdentifier:(NSString*)presentingControllerKey
                        context:(id)context
                        delegate:(id<SWModelManagerDelegate>)delegate
                      dataSource:(id<SWModelManagerDataSource>)dataSource
                 animated:(BOOL)animated;

- (void)showConnectorsPickerOnPresentingControllerWithIdentifier:(NSString*)presentingControllerKey
                        context:(id)context
                        delegate:(id<SWModelManagerDelegate>)delegate
                      dataSource:(id<SWModelManagerDataSource>)dataSource
                 animated:(BOOL)animated;

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)showModelPickerOnPresentingControllerWithIdentifier:(NSString *)presentingControllerKey
                    forObject:(id)object
                       withValue:(SWValue*)value
                         context:(id)context
                        delegate:(id<SWModelManagerDelegate>)delegate
                      dataSource:(id<SWModelManagerDataSource>)dataSource
                        animated:(BOOL)animated;


/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)updateModelPickerForPresentingControllerWithIdentifier:(NSString*)presentingControllerKey
                                forObject:(id)object
                                  withValue:(SWValue*)value
                                    context:(id)context
                                   delegate:(id<SWModelManagerDelegate>)delegate
                                 dataSource:(id<SWModelManagerDataSource>)dataSource
                                   animated:(BOOL)animated;

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)dismissModelSeekerFromControllerWithIdentifier:(NSString*)presentingControllerKey animated:(BOOL)animated;

// -- Managing the default model browser -- //

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)toggleModelBrowserForControllerWithIdentifier:(NSString*)presentingControllerKey animated:(BOOL)animated;

// -- Managing Configurators -- //

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)presentModelConfiguratorOnControllerWithIdentifier:(NSString*)presentingControllerKey forObject:(id)object animated:(BOOL)animated;

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)dismissModelConfiguratorFromControllerWithIdentifier:(NSString*)presentingControllerKey forObject:(id)object animated:(BOOL)animated;

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)removeModelConfiguratorFromControllerWithIdentifier:(NSString*)presentingControllerKey forObject:(id)object animated:(BOOL)animated;

// -- Managing Floating Popovers -- //

- (void)registerPresentingController:(UIViewController*)controller withIdentifier:(NSString*)key;
- (void)unregisterPresentingControllerWithIdentifier:(NSString*)key;

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)hidePresentedPopoversForControllerWithIdentifier:(NSString*)presentingControllerKey animated:(BOOL)animated;

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)presentHiddenPopoversForControllerWithIdentifier:(NSString*)presentingControllerKey animated:(BOOL)animated;

/** @param presentingControllerKey If nil, the root presenting controller will be used.  */
- (void)removeAllModelPopoversFromControllerWithIdentifier:(NSString*)presentingControllerKey  animated:(BOOL)animated;

// -- Managing Expression Input


// -- Properties
@property (nonatomic, strong, readonly) SWDocumentModel *documentModel;
@property (nonatomic, strong, readonly) SWExpressionInputController *inputController;

@property (nonatomic, assign) CGSize contentSizeInPopover;
@property (nonatomic, assign) CGSize seekerContentSizeInPopover;

@end

