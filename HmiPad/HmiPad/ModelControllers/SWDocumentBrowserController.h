//
//  SWDocumentBrowserController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWDocument;

@interface SWDocumentBrowserController : UITableViewController /*<NSFetchedResultsControllerDelegate>*/ {
    
    //NSMutableArray *_documentUrls;
    SWDocument *_currentDocument;
    
    NSMutableArray *_localFiles;
    NSMutableArray *_iCloudFiles;
    
    // iCloud
    NSMetadataQuery *_query;

}

- (IBAction)addDocument:(id)sender;

@end
