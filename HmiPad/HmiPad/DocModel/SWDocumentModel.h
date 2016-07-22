//
//  SWDocumentModel.h
//  HmiPad
//
//  Created by Joan on 10/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RpnBuilder.h"
#import "QuickCoder.h"
#import "SymbolicCoder.h"
#import "SWEnumTypes.h"

@class SWObject;
@class SWDocument;
@class SWDocumentModel;
@class SWPage;
@class SWItem;

@class SWSystemTable;

@class SWSystemItemProject;
@class SWSystemItemSystem;
@class SWSystemItemUsersManager;
@class SWBackgroundItem;

@class SWSourceItem;
@class SWAlarm;
@class SWProjectUser;
@class SWDataLoggerItem;

@class SWEventCenter;
@class SWHistoAlarms;
@class SWHistoValues;
@class SWRestApiSessions;

#pragma mark - SWDocumentModel

typedef enum
{
    SWArrayTypeUnknown,
    SWArrayTypeSystemItems,
    SWArrayTypePages,
    SWArrayTypeBackgroundItems,
    SWArrayTypeSources,
    SWArrayTypeAlarms,
    SWArrayTypeProjectUsers,
    SWArrayTypeDataLoggers,
    SWArrayTypeRestApiItems,
} SWArrayType;


#define DocumentThumbnailSize (CGSizeMake(70, 70))

extern NSString *kProjectUserDidChangeNotification;

#pragma mark - DocumentModelObserver

@protocol DocumentModelObserver <NSObject>

@optional

// checkpointChangeNotification
- (void)documentModelChangeCheckpoint:(SWDocumentModel*)docModel;

// saveCheckpointNotification
- (void)documentModelSaveCheckpoint:(SWDocumentModel*)docModel;

// arrays of object
- (void)documentModel:(SWDocumentModel*)docModel willInsertObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didInsertObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel willRemoveObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didRemoveObjectsOfType:(SWArrayType)type atIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didMoveObjectOfType:(SWArrayType)type atIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;
- (void)documentModel:(SWDocumentModel*)docModel didSelectObjectOfType:(SWArrayType)type atIndex:(NSInteger)index oldIndex:(NSInteger)oldIndex; // only pages so far

// pages
- (void)documentModel:(SWDocumentModel*)docModel selectedPageDidChange:(NSInteger)index direction:(NSInteger)direction;
- (void)documentModel:(SWDocumentModel*)docModel selectedPageDidChangeToIndex:(NSInteger)index oldIndex:(NSInteger)oldIndex;

- (void)documentModel:(SWDocumentModel*)docModel willInsertPagesAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didInsertPagesAtIndexes:(NSIndexSet*)indexes;

- (void)documentModel:(SWDocumentModel*)docModel willRemovePagesAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didRemovePagesAtIndexes:(NSIndexSet*)indexes;

- (void)documentModel:(SWDocumentModel*)docModel didMovePageAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;

// background items
- (void)documentModel:(SWDocumentModel*)docModel didInsertBackgroundItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel willRemoveBackgroundItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didRemoveBackgroundItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didMoveBackgroundItemAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;

// sources
- (void)documentModel:(SWDocumentModel*)docModel didInsertSourceItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel willRemoveSourceItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didRemoveSourceItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didMoveSourceItemAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;
- (void)documentModelEnableConnectionsDidChange:(SWDocumentModel*)docModel;

// alarm items
- (void)documentModel:(SWDocumentModel*)docModel didInsertAlarmItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didRemoveAlarmItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel willRemoveAlarmItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didMoveAlarmItemAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;

// project user items
- (void)documentModel:(SWDocumentModel*)docModel selectedProjectUserDidChange:(SWProjectUser*)user;
- (void)documentModel:(SWDocumentModel*)docModel didInsertProjectUsersAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didRemoveProjectUsersAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel willRemoveProjectUsersAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didMoveProjectUserAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;

// data logger items
- (void)documentModel:(SWDocumentModel*)docModel didInsertDataLoggerItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didRemoveDataLoggerItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel willRemoveDataLoggerItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didMoveDataLoggerItemAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;

// rest api items
- (void)documentModel:(SWDocumentModel*)docModel didInsertRestApiItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didRemoveRestApiItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel willRemoveRestApiItemsAtIndexes:(NSIndexSet*)indexes;
- (void)documentModel:(SWDocumentModel*)docModel didMoveRestApiItemAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;

// editing
- (void)documentModel:(SWDocumentModel*)docModel editingModeDidChangeAnimated:(BOOL)animated;
- (void)documentModelEditingPropertiesDidChange:(SWDocumentModel*)docModel;
- (void)documentModelInterfaceIdiomDidChange:(SWDocumentModel*)docModel;

// fileList
- (void)documentModelFileListDidChange:(SWDocumentModel*)docModel;
- (void)documentModelEmbeddedAssetsDidChange:(SWDocumentModel*)docModel;

// thumbnail
- (void)documentModelThumbnailDidChange:(SWDocumentModel*)docModel;

// shortTitle
- (void)documentModelTitleDidChange:(SWDocumentModel*)docModel;

// allowed orientation
- (void)documentModelAllowedOrientationDidChange:(SWDocumentModel*)docModel;

// pages visibility
- (void)documentModelPagesVisibilityDidChange:(SWDocumentModel*)docModel;

// project users availability
- (void)documentModelUsersAvailableDidChange:(SWDocumentModel*)docModel;

@end


#pragma mark - DocumentModel

// Document model. The model can be saved with coders and is handled by the SWDocument class.

@interface SWDocumentModel : NSObject <QuickCoding ,SymbolicCoding>
{
    NSMutableArray *_observers; // List of observers
    NSMutableArray *_pages;
    NSMutableArray *_visiblePages;
    NSMutableArray *_systemItems;
    NSMutableArray *_backgroundItems;
    NSMutableArray *_sourceItems;
    NSMutableArray *_alarmItems;
    NSMutableArray *_projectUsers;
    NSMutableArray *_dataLoggerItems;
    NSMutableArray *_restApiItems;
    BOOL _waitChangePageVisibility;
    __weak SWDocument *_document;
}

// Weak Reference to the document class and common convenience accessors.
- (void)setDocument:(SWDocument*)document;  // <-- only call just after initialization
@property (nonatomic, readonly) NSString *redeemedName;
@property (nonatomic, readonly) NSString *documentName;

// Object Identifier & owner
@property (nonatomic) NSString *uuid;

// Integrator Service owner identifier // ignored for integrator projects
@property (nonatomic) UInt32 ownerID;

// ThumbnailImage
@property (nonatomic) UIImage *thumbnailImage;

// Model Builder. Each value or expression of this model should use this builder.
@property (nonatomic, readonly) RpnBuilder *builder;
@property (nonatomic, readonly) SWSystemTable *systemTable;

// Array of system items. unique items supporting several things
@property (nonatomic, readonly) NSArray *systemItems;
@property (nonatomic, readonly) SWSystemItemProject *systemItemProject;
@property (nonatomic, readonly) SWSystemItemSystem *systemItemSystem;
@property (nonatomic, readonly) SWSystemItemUsersManager *systemItemUsersManager;

// Project properties
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *shortTitle;
- (SWProjectAllowedOrientation)allowedOrientationForCurrentIdiom;

// Array of pages. Objects are instances of SWPage.
@property (nonatomic, readonly) NSArray *pages;
@property (nonatomic, readonly) NSInteger selectedPageIndex;

// Array of visible pages (Objects are instances of SWPage) and convenience method to determine whether a page is visible
@property (nonatomic, readonly) NSArray *visiblePages;
- (BOOL)pageIsVisible:(SWPage*)page;

// Array of items without UI (timers, single expressions, etc.). Items are subclasses of SWBackgroundItem.
@property (nonatomic, readonly) NSArray *backgroundItems;

// Source Items. Array of PLC connectors.
@property (nonatomic, assign) BOOL enableConnections;
@property (nonatomic, readonly) NSArray *sourceItems;

// Array of alarms. Objects are instances of SWAlarm. Contains all SWAlarm instances in the model.
@property (nonatomic, readonly) NSArray *alarmItems;

// Project Users
@property (nonatomic, readonly) NSArray *projectUsers;
@property (nonatomic, readonly) SWProjectUser *selectedProjectUser;

// Array of dataLogger items
@property (nonatomic, readonly) NSArray *dataLoggerItems;

// Array of restapi items
@property (nonatomic, readonly) NSArray *restApiItems;

// Event Center
@property (nonatomic, readonly) SWEventCenter *eventCenter;

// Histo Center
@property (nonatomic, readonly) SWHistoAlarms *histoAlarms;
@property (nonatomic, readonly) SWHistoValues *histoValues;

// Rest Api Center
@property (nonatomic, readonly) SWRestApiSessions *restSessions;

// Model Undo Manager.
@property (nonatomic, readonly) NSUndoManager *undoManager;

// Editing properties
@property (nonatomic) BOOL editMode;
- (void)setEditMode:(BOOL)editMode animated:(BOOL)animated;

// Editing tool properties
@property (nonatomic) BOOL allowFrameEditing;
@property (nonatomic) BOOL autoAlignItems;
@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic) BOOL showsErrorFrameInEditMode;
@property (nonatomic) BOOL showsHiddenItemsInEditMode;

@property (nonatomic) BOOL enableFineFramePositioning;
@property (nonatomic) CGPoint portraitResizerPosition;
@property (nonatomic) CGPoint landscapeResizerPosition;

@property (nonatomic) SWDeviceInterfaceIdiom interfaceIdiom;

// Project Assets properties
@property (nonatomic) NSArray *fileList;

// Properties to provide hints on project assets management
@property (nonatomic) BOOL embeededAssets;

// Observers
- (void)addObserver:(id<DocumentModelObserver>)observer;
- (void)removeObserver:(id<DocumentModelObserver>)observer;

// ChangeCheckpoint
- (void)changeCheckpointNotification;   // <-- sent by the document
- (void)saveCheckpointNotification;     // <-- sent by the document

// Project
- (void)updateTitleNotification;                // <-- sent by the systemItemDocument
- (void)updateAllowedOrientationNotification;   // <-- sent by the systemItemDocument

// Page Visibility
- (void)setPagesVisibilityDirty;   // <-- sent by pages

// Generic array manipulation
- (NSArray*)objectsOfType:(SWArrayType)type;
- (void)addObject:(id)object ofType:(SWArrayType)type;
- (void)insertObjects:(NSArray*)array atIndexes:(NSIndexSet *)indexes ofType:(SWArrayType)type;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes ofType:(SWArrayType)type;
- (void)moveObjectAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex ofType:(SWArrayType)type;

// Page management
- (void)selectPageAtIndex:(NSInteger)selectedPageIndex;
- (void)selectPageWithPageIdentifier:(NSString*)pageIdentifier;
- (void)addPage:(SWPage*)page;
- (void)insertPages:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removePagesAtIndexes:(NSIndexSet *)indexes;
- (void)movePageAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

// Background Items
- (void)addBackgroundItem:(SWBackgroundItem*)object;
- (void)insertBackgroundItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeBackgroundItemsAtIndexes:(NSIndexSet *)indexes;
- (void)moveBackgroundItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

// Source management
- (void)addSourceItem:(SWSourceItem*)object;
- (void)insertSourceItems:(NSArray *)array atIndexes:(NSIndexSet*)indexes;
- (void)removeSourceItemsAtIndexes:(NSIndexSet*)indexes;

// Source ignition
- (void)igniteSources;
- (void)clausureSources;

// Alarm Items
- (void)addAlarmItem:(SWAlarm*)alarm;
- (void)insertAlarmItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeAlarmItemsAtIndexes:(NSIndexSet *)indexes;
- (void)moveAlarmItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

// Events
- (void)addSystemEventWithLabel:(NSString*)label comment:(NSString*)comment;

// Project Users
- (void)selectProjectUser:(SWProjectUser*)user;
- (void)addProjectUser:(SWProjectUser*)user;
- (void)insertProjectUsers:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeProjectUsersAtIndexes:(NSIndexSet *)indexes;
- (void)moveProjectUserAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;
- (void)showProjectUserLoginIfNeeded;
- (void)showProjectUserLogin;
- (void)dismissProjectUserLogin;

// DataLogger Items
- (void)addDataLoggerItem:(SWDataLoggerItem*)dataLogger;
- (void)insertDataLoggerItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeDataLoggerItemsAtIndexes:(NSIndexSet *)indexes;
- (void)moveDataLoggerItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

// RestApi Items
- (void)addRestApiItem:(SWDataLoggerItem*)dataLogger;
- (void)insertRestApiItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void)removeRestApiItemsAtIndexes:(NSIndexSet *)indexes;
- (void)moveRestApiItemAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;

@end


@interface SWDocumentModel(primitiveSetThumbnail)

- (void)primitiveSetThumbnail:(UIImage*)image;

@end

