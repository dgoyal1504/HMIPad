//
//  SWDocument.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/6/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SystemExpressions.h"
#import "RpnBuilder.h"
#import "QuickCoder.h"
#import "SymbolicCoder.h"
#import "SWQuickDocument.h"


@class SWDocument;
@class SWDocumentModel;
@class SWItem;

@protocol SWDocumentModelDelegate <NSObject>

@end

@protocol DocumentModelObserver <NSObject>

@optional

- (void)documentModel:(SWDocumentModel*)docModel didChangeSelectedPage:(NSInteger)index;
- (void)documentModel:(SWDocumentModel*)docModel didInsertPageAtIndex:(NSInteger)index;
- (void)documentModel:(SWDocumentModel*)docModel didRemovePageAtIndex:(NSInteger)index;
- (void)documentModel:(SWDocumentModel*)docModel didMovePageAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex;

@end

@class SWPage;

@interface SWDocumentModel : NSObject <QuickCoding ,SymbolicCoding> 
{
    NSMutableArray *_observers;
}

@property (nonatomic, weak) SWDocument *document ;
@property (nonatomic, weak) id <SWDocumentModelDelegate> delegate;

@property (nonatomic, readonly, strong) RpnBuilder *builder;
@property (nonatomic, readonly, strong) SystemExpressions *sysExpressions;
@property (nonatomic, readwrite, strong) NSMutableArray *pages;
@property (nonatomic, readwrite, strong) NSString * name;
@property (nonatomic, readwrite, strong) NSString * about;
@property (nonatomic, readwrite, strong) NSMutableArray *sourceItems;
@property (nonatomic, readwrite, assign) NSInteger selectedPageIndex;
@property (nonatomic, readonly, strong) NSString *uuid;

- (NSUndoManager*)undoManager ;

// -- Page management -- //
- (void)addPage:(SWPage*)page;
- (void)insertPage:(SWPage*)page atIndex:(NSInteger)index;
- (void)movePageAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;
- (void)removePageAtIndex:(NSUInteger)index;

- (NSInteger)indexOfPageWithUUID:(NSString*)uuid;

- (void)setSelectedPageIndex:(NSInteger)selectedPageIndex registerIntoUndoManager:(BOOL)undo;

// -- Source management -- //
- (void)igniteSources ;
- (void)clausureSources ;

// -- Observers -- //
- (void)addObserver:(id<DocumentModelObserver>)observer;
- (void)removeObserver:(id<DocumentModelObserver>)observer;

@end

typedef enum
{
    SWDocumentSavingTypeBinary,
    SWDocumentSavingTypeSymbolic,
} SWDocumentSavingType;


@interface SWDocument : SWQuickDocument
{
    NSString *_savingFileType;
}

+ (void)convertToSymbolicDataDocumentModel:(SWDocumentModel*)documentModel completion:(void (^)(NSData *data))completion;
+ (void)convertToBinaryDataDocumentModel:(SWDocumentModel*)documentModel completion:(void (^)(NSData *data))completion;
+ (void)convertToBinarySymbolicData:(NSData*)symbolicData completion:(void (^)(NSData *binaryData))completion;
+ (void)convertToSymbolicBinaryData:(NSData*)symbolicData completion:(void (^)(NSData *symbolicData))completion;

@property (nonatomic, assign) SWDocumentSavingType savingType;
@property (nonatomic, readonly, strong) SWDocumentModel *docModel;

@end
