//
//  SWDocumentBrowserController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWDocumentBrowserController.h"
#import "SWModelTypes.h"
//#import "NSFileManager+Directories.h"
#import "SWFileRepresentation.h"
#import "SWDocumentController.h"

@interface SWDocumentBrowserController (Private)

- (void)fileListReceived;

@end

@implementation SWDocumentBrowserController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    _localFiles = [NSMutableArray array];
    _iCloudFiles = [NSMutableArray array];
            
    NSURL *localDirectoryURL = [[NSFileManager defaultManager] localDocumentsDirectoryURL];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localDirectoryURL.path error:nil];
    for (NSString *path in contents) 
    {
        if ([[path pathExtension] isEqualToString:binaryfileExtension]) 
        {
            NSURL *url = [localDirectoryURL URLByAppendingPathComponent:path];
            //NSLog(@"Selecting document path : %@", url.description);
            
            SWFileRepresentation *fileRepresentation = [[SWFileRepresentation alloc] initWithFileName:[path lastPathComponent] url:url];
            [_localFiles addObject:fileRepresentation];
        }
    }
    
    NSURL *iCloudDirectoryURL = [[NSFileManager defaultManager] iCloudDocumentsDirectoryURL];
    contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:iCloudDirectoryURL.path error:nil];
    for (NSString *path in contents) 
    {
        if ([[path pathExtension] isEqualToString:binaryfileExtension]) 
        {
            NSURL *url = [iCloudDirectoryURL URLByAppendingPathComponent:path];
            //NSLog(@"Selecting document path : %@", url.description);
            
            SWFileRepresentation *fileRepresentation = [[SWFileRepresentation alloc] initWithFileName:[path lastPathComponent] url:url];
            [_iCloudFiles addObject:fileRepresentation];
        }
    }
    
    [super awakeFromNib];
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
    // -- iCloud Documents -- //
    _query = [[NSMetadataQuery alloc] init];
    [_query setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, nil]];
    [_query setPredicate:[NSPredicate predicateWithFormat:@"%K LIKE '*.sm'",NSMetadataItemFSNameKey]];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(fileListReceived) 
                   name:NSMetadataQueryDidFinishGatheringNotification 
                 object:nil];
    [center addObserver:self 
               selector:@selector(fileListReceived) 
                   name:NSMetadataQueryDidUpdateNotification 
                 object:nil];
    [_query startQuery];
    // ---------------------- // 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _currentDocument = nil ;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}



#pragma mark - Main Methods

- (IBAction)addDocument:(id)sender
{
    NSURL *directoryURL = [[NSFileManager defaultManager] localDocumentsDirectoryURL];
    NSDate *date = [NSDate date];
    NSURL *fileURL = [[directoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"HmiPad_%d",(int)date.timeIntervalSince1970]] URLByAppendingPathExtension:binaryfileExtension];
    NSLog(@"New Document at fileURL: %@",fileURL.path);
    SWDocument *document = [[SWDocument alloc] initWithFileURL:fileURL];
        
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        NSLog(@"Succesfully Saved for Creation");
    }];
    
    SWFileRepresentation *fileRepresentation = [[SWFileRepresentation alloc] initWithFileName:[fileURL.path lastPathComponent] url:fileURL];
    [_localFiles addObject:fileRepresentation];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_localFiles.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 2;
    
    if (_query.results.count > 0) {
        return  2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger row = 0;
    
    switch (section) {
        case 0:
            row = [_localFiles count];
            break;
        
        case 1:
            row = [_iCloudFiles count];
            break;
        default:
            break;
    }
    
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"workspaceCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    SWFileRepresentation *fileRepresentation;
    
    if (indexPath.section == 0) {
        fileRepresentation = [_localFiles objectAtIndex:indexPath.row];
    } else {
        fileRepresentation = [_iCloudFiles objectAtIndex:indexPath.row];
    }
    
    NSDate *modificationDate = nil;
    
    if (fileRepresentation.isFileIniCloud) {
        modificationDate = [fileRepresentation.metadataItem valueForAttribute:NSMetadataItemFSContentChangeDateKey];
    } else {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileRepresentation.url.path error:nil];
        modificationDate = [attributes fileModificationDate];
    }
    
    cell.textLabel.text = fileRepresentation.filename;
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    if (modificationDate) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Last Change: %@", [dateFormatter stringFromDate:modificationDate]];
    } else {
        cell.detailTextLabel.text = @"New File";
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section) {
        case 0:
            title = @"Local Files";
            break;
        case 1:
            title = @"iCloud Storage";
            break;
        default:
            break;
    }
    
    return title;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footer = nil;
    
    switch (section) {
        case 0:
            footer = nil;
            break;
        case 1:
            footer = @"iCloud files are automatically sync, allowing you to access the same files in multiple devices.";
            break;
        default:
            break;
    }
    
    return footer;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source        
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        SWFileRepresentation *fileRepresentation = nil;
        
        if (indexPath.section == 0) {
            fileRepresentation =[_localFiles objectAtIndex:indexPath.row];
            [_localFiles removeObjectAtIndex:indexPath.row];
        } else {
            fileRepresentation =[_iCloudFiles objectAtIndex:indexPath.row];
            [_iCloudFiles removeObjectAtIndex:indexPath.row];
        }
        
        [fileRepresentation deleteFile];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
        // TODO
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    if (fromIndexPath.section == toIndexPath.section) {
        
        NSMutableArray *array = nil;
        
        if (fromIndexPath.section == 0) {
            array = _localFiles;
        } else {
            array = _iCloudFiles;
        }
        
        SWFileRepresentation *fileRepresentation = [array objectAtIndex:fromIndexPath.row];
        [array removeObjectIdenticalTo:fileRepresentation];
        [array insertObject:fileRepresentation atIndex:toIndexPath.row];
    
    } else if (fromIndexPath.section == 0) { // Moving from local to iCloud
        NSLog(@"Should move to iCloud");
        
        SWFileRepresentation *fileRepresentation = [_localFiles objectAtIndex:fromIndexPath.row];
        
        [_localFiles removeObjectIdenticalTo:fileRepresentation];
        [_iCloudFiles insertObject:fileRepresentation atIndex:toIndexPath.row];
        
        [fileRepresentation moveToiCloudWithCompletion:nil];
        
    } else { // Moving from iCloud to local
        NSLog(@"Should move to local");
        
        SWFileRepresentation *fileRepresentation = [_iCloudFiles objectAtIndex:fromIndexPath.row];
        
        [_iCloudFiles removeObjectIdenticalTo:fileRepresentation];
        [_localFiles insertObject:fileRepresentation atIndex:toIndexPath.row];
        
        [fileRepresentation moveToLocalStorageWithCompletion:nil];
    }
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


#pragma mark - Table view delegate

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentDocument = [_documents objectAtIndex:indexPath.row];
    [_currentDocument openWithCompletionHandler:^(BOOL success) {
        SWDocumentController *documentController = [[SWDocumentController alloc] initWithDocument:_currentDocument];
        [self.navigationController pushViewController:documentController animated:YES]; 
    }];
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWFileRepresentation *fileRepresentation;
    
    if (indexPath.section == 0) {
        fileRepresentation = [_localFiles objectAtIndex:indexPath.row];
    } else {
        fileRepresentation = [_iCloudFiles objectAtIndex:indexPath.row];
    }
    
    _currentDocument = [[SWDocument alloc] initWithFileURL:fileRepresentation.url];
    
//    //[_currentDocument openWithCompletionHandler:^(BOOL success) {
//        SWDocumentController *documentController = [[SWDocumentController alloc] initWithDocument:_currentDocument];
//        [self.navigationController pushViewController:documentController animated:YES]; 
//    //}];
    
    [_currentDocument openWithCompletionHandler:^(BOOL success) {
        SWDocumentController *documentController = [[SWDocumentController alloc] initWithDocument:_currentDocument];
        [self.navigationController pushViewController:documentController animated:YES]; 
    }];
}

@end

@implementation SWDocumentBrowserController (Private)

- (void)fileListReceived
{
    NSArray *results = [_query results];
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    for (NSMetadataItem *result in results) {
        NSString *filename = [result valueForAttribute:NSMetadataItemFSNameKey];
        NSURL *url = [result valueForAttribute:NSMetadataItemURLKey];
        
        SWFileRepresentation *fileRepresentation = [[SWFileRepresentation alloc] initWithFileName:filename url:url];
        fileRepresentation.metadataItem = result;
        
        [_iCloudFiles addObject:fileRepresentation];
        
        [indexPaths addObject:[NSIndexPath indexPathForRow:[_iCloudFiles indexOfObjectIdenticalTo:fileRepresentation] inSection:1]];
    }
    
    if (results.count > 0) {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];   
    }
}

@end


