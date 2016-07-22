//
//  SWSourceItem.h
//  HmiPad
//
//  Created by Joan on 14/03/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWObject.h"

//#import "CommsObjectDelegate.h"
#import "PlcTagElement.h"
//#import "PlcDevice.h"

#import "UIView+DecoratorView.h"

@class SWPlcTag;
@class SWPlcDevice;

@class SWSourceItem;

#pragma mark - SourceItemObserver

@protocol SourceItemObserver <SWObjectObserver>

@optional
- (void)nodeNameDidChange:(NSString*)name atIndex:(NSInteger)indx;
- (void)sourceItem:(SWSourceItem*)source plcTagDidChange:(SWPlcTag*)plcTag atIndex:(NSInteger)indx;
- (void)plcDeviceDidChange:(SWPlcDevice*)plcDevice;

- (void)sourceItem:(SWSourceItem*)source didInsertSourceNodesAtIndexes:(NSIndexSet*)indexes;
- (void)sourceItem:(SWSourceItem*)source willRemoveSourceNodesAtIndexes:(NSIndexSet*)indexes;
- (void)sourceItem:(SWSourceItem*)source didRemoveSourceNodesAtIndexes:(NSIndexSet*)indexes;
- (void)sourceItem:(SWSourceItem*)source didMoveSourceNodeAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)destinationIndex;

@end

extern NSString *kFinsMonitorDidChangeNotification;
extern NSString *kFinsWillConnectNotification;
extern NSString *kFinsDidLinkNotification;
extern NSString *kFinsErrorOccurredNotification;
extern NSString *kFinsWarningNotification;
extern NSString *kFinsDidCloseNotification;
extern NSString *kFinsDidClausureNotification;

extern NSString *kFinsStateDidChangeNotification; // This notification englobes all previous notifications

extern NSString *kFinsPollUpdateNotification;
extern NSString *kFinsNumberOfTagsDidChangeNotification;


@interface SWSourceItem : SWObject //<CommsObjectDelegate>
{
    CFAbsoluteTime _errorTimeStamp;
    
    NSMutableArray *_addTagsArray;
    NSMutableArray *_removeTagsArray;
    NSMutableArray *_wTagsArray;
    //NSCountedSet *_tagsSet; // conjunt per formar els tags (es fa servir un set per evitar duplicats) (NSCountedSet)
    NSMutableArray *_sourceNodes;
    NSMutableDictionary *_sourceNodesDic;
    
    BOOL _pollingTagsNeedsUpdate;
    BOOL _wPendingCommitTagsSet;
    BOOL _pendingCommitTagsSet;
    BOOL _pendingCommsChangeNotification;
}

// Properties
@property (nonatomic, strong, readonly) SWPlcDevice *plcDevice;
@property (nonatomic, assign, readonly) ProtocolType protocol;
@property (nonatomic, strong, readonly) PlcCommsObject *plcObject;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, assign, readonly) BOOL monitorOn;
@property (nonatomic, assign, readonly) BOOL altHost;
@property (nonatomic, assign, readonly) BOOL plcObjectIgnited;
@property (nonatomic, assign, readonly) BOOL plcObjectStarted;
@property (nonatomic, assign, readonly) BOOL plcObjectLinked;
@property (nonatomic, assign, readonly) int plcObjectRoute ;  // 0: no enllaçat, 1 local, 2, remot
@property (nonatomic, assign, readonly) int numberOfTags;
@property (nonatomic, assign, readonly) float commandsPerSecond;
@property (nonatomic, assign, readonly) float readsPerSecond;

// Expressions
@property (nonatomic, readonly) SWExpression *localIPExpression;
@property (nonatomic, readonly) SWExpression *remoteHostExpression;

// Dynamic properties
@property (nonatomic, readonly) float pollInterval;
@property (nonatomic, readonly) ItemDecorationType decorationType;
@property (nonatomic, readonly) NSString *statusDescription;
@property (nonatomic, readonly) UIColor *statusColor;

// plcObject
- (void)igniteCommunications;
- (void)closeCommunications;
- (void)setMonitorState:(BOOL)value;
- (void)setPollRate:(UInt16)rate;

// plcDevice
- (void)setPlcDevice:(SWPlcDevice*)device;

// nodes
- (NSArray*)sourceNodes;  // conte objectes SWSourceNode
- (void)moveNodeAtIndex:(NSInteger)originIndex toIndex:(NSInteger)finalIndex;
- (BOOL)insertNewVariablesAtIndexes:(NSIndexSet*)indexes;
- (void)insertSourceNodes:(NSArray*)nodes atIndexes:(NSIndexSet*)indexes;
- (void)removeVariablesAtIndexes:(NSIndexSet*)indexes;
- (void)replaceNameAtIndex:(NSInteger)indx byName:(NSString*)varName;
- (void)updateWExpressionAtIndex:(NSInteger)indx withString:(NSString*)string;
- (SWPlcTag*)plcTagCopyAtIndex:(NSInteger)indx;
- (void)replacePlcTagAtIndex:(NSInteger)indx byPlcTag:(SWPlcTag*)plcTag;

// init
//- (id)initInDocument:(SWDocumentModel*)docModel;
- (id)initInDocument:(SWDocumentModel*)docModel protocolString:(NSString*)protocolStr;

// --- Private Api! --- //
//- (void)_plcDeviceChangeNotify;

@end


@interface SWSourceItem (SWSourceNode)

- (void)_wTagsSetAddTag:(SWPlcTag *)plcTag values:(CFDataRef)values texts:(CFArrayRef)texts;
- (void)_tagsSetAddTag:(SWPlcTag *)plcTag;
- (void)_tagsSetRemoveTag:(SWPlcTag *)plcTag;

@end
