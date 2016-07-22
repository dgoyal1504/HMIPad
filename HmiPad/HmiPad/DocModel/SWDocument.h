//
//  SWDocument.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/6/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWQuickDocument.h"

@class SWDocumentModel;


#pragma mark - SWDocument

/**
 * Enum typedef for the different types allowed for saving.
 */
typedef enum
{
    SWDocumentSavingTypeBinary,
    SWDocumentSavingTypeSymbolic,
    SWDocumentSavingTypeValuesBinary,
    SWDocumentSavingTypeValuesSymbolic,
    SWDocumentSavingTypeThumbnail,
} SWDocumentSavingType;

/**
 * SWQuickDocument subclass to handle file loading and saving.
 */

@interface SWDocument : SWQuickDocument 

@property (nonatomic, readonly, strong) SWDocumentModel *docModel;
@property (nonatomic, readonly) NSError *lastError;

// initializing
- (id)initWithFileName:(NSString*)fileName;

// geting document info
- (NSData*)getSymbolicData;
- (NSString*)getFileName;
- (NSString*)getName;

// opening, saving, closing
- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler;
- (void)saveWithCompletion:(void (^)(BOOL success))completion; // -- Saving (convenience method)
- (void)closeWithCompletionHandler:(void (^)(BOOL success))completionHandler;

// miscelaneous
- (void)saveForCreatingWithSavingType:(SWDocumentSavingType)savingType completionHandler:(void (^)(BOOL success))completionHandler;
- (void)setHasUnsavedChangesForSavingType:(SWDocumentSavingType)savingType;

@end
