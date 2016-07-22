//
//  AccountsTableController.m
//  iPhoneDomusSwitch_090421
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//


#import "DownloadFromServerController.h"
//#import "ViewControllerHelper.h"
#import "ControlViewCell.h"
#import "SWTableViewMessage.h"
//#import "PdfViewController.h"

//#import "DetailTagsViewController.h"

//#import "MainSplitViewController.h"
#import "SWTableFieldsController.h"
#import "URLDownloadObject.h"

//#import "AppModel.h"
#import "UserDefaults.h"
#import "SWColor.h"



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark FilesViewController
#pragma mark
///////////////////////////////////////////////////////////////////////////////////////////



//-----------------------------------------------------------------------------------------
@implementation DownloadFromServerController


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Constants
///////////////////////////////////////////////////////////////////////////////////////////

enum sectionsInTable
{
    //kSourceFilesSection = 0,
    //kExampleTemplatesSection,
    kDownloadFromServerSection,
    kDownloadFromServerButtonSection,
    TotalSectionsInTable,
    
//   kFileServerSection,  // posar abans de TotalSectionsInTable si es vol
};



enum rowsInDownloadFromServerSection
{
    kDownloadServerUrlRow = 0,
    kDownloadFileNameRow,
    //kDownloadFromServerButtonRow,
    TotalRowsInDownloadFromServerSection
};

enum rowsInDownloadButtonSection
{
    kDownloadFromServerButtonRow = 0,
    TotalRowsInDownloadFromServerButtonSection
};



///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Properties
///////////////////////////////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Convenience methods
///////////////////////////////////////////////////////////////////////////////////////////////



//---------------------------------------------------------------------------------------------
- (void)establishDoneButton:(BOOL)putIt animated:(BOOL)animated
{
    UIBarButtonItem *button = nil ;
    if ( putIt )
    {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doDone:)] ;
    }
    [[self navigationItem] setLeftBarButtonItem:button animated:animated];
    //[button release] ;
}


//---------------------------------------------------------------------------------------------
- (void)doDone:(id)sender
{
    // recuperem els sources i fem un reload de la seccio complerta
    //[self dismissModalViewControllerAnimated:YES] ;
    [self dismissViewControllerAnimated:YES completion:nil];
}

//---------------------------------------------------------------------------------------------
- (void)stablishDownload:(BOOL)value
{
    downloading = value ;
    NSInteger section = kDownloadFromServerButtonSection ;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kDownloadFromServerButtonRow inSection:section] ;
    [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade] ;   //$$
}

///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Download
///////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)getDownloadUrlText
{
    NSString *serverUrl = [defaults() downloadServerName] ;
    NSString *proto = @"http:" ;
    
    NSArray *parts = [serverUrl componentsSeparatedByString:@"//"] ;
    if ( [parts count] > 1 )
    {
        proto = [parts objectAtIndex:0] ;
        serverUrl = [parts lastObject] ;
    }
    
    NSString *fileName = [defaults() downloadFileName] ;
    //NSString *fileName = [self downloadFileName] ;
    NSString *urlString = [serverUrl stringByAppendingPathComponent:fileName] ;
    return [NSString stringWithFormat:@"%@//%@", proto, urlString] ;
}


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Message View
///////////////////////////////////////////////////////////////////////////////////////////////

- (SWTableFieldsController *)rightButton
{ 
    if ( rightButton == nil )
    {
        rightButton = [[SWTableFieldsController alloc] initWithOwner:self];
    }
    return rightButton ;
}



//---------------------------------------------------------------------------------------------------
- (ManagedTextFieldCell*)downloadServerNameCell
{
    if ( downloadServerNameCell == nil )
    {
        id tmpObj ;
        downloadServerNameCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:[self rightButton] reuseIdentifier:nil] ;
        [downloadServerNameCell setMainText:NSLocalizedString(@"Server",nil)];
        //[[downloadServerNameCell cellContentView] setMainTextColor:[ControlViewCell theSystemDarkBlueColor]] ;
        //[[downloadServerNameCell cellContentView] setMainTextFont:[UIFont italicSystemFontOfSize:17]] ;
        //[downloadServerNameCell setTabWidth:1] ;
        //[downloadServerNameCell setLeadingTabWidth:0];
        [tmpObj=[downloadServerNameCell textField] setPlaceholder:@"http://www.server.com"];
        [tmpObj setText:[defaults() downloadServerName]];
        [tmpObj setKeyboardType:UIKeyboardTypeURL] ;
        [tmpObj setReturnKeyType:UIReturnKeyNext];
    }
    return downloadServerNameCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setDownloadServerNameCell:(ManagedTextFieldCell*)aCell
{
    downloadServerNameCell = aCell ;
}


//---------------------------------------------------------------------------------------------------
- (ManagedTextFieldCell*)downloadFileNameCell
{
    if ( downloadFileNameCell == nil )
    {
        id tmpObj ;
        downloadFileNameCell = [[ManagedTextFieldCell alloc] initWithSWTableFieldsController:[self rightButton] reuseIdentifier:nil] ;
        //[[host2NameViewCell label] setText:NSLocalizedString(@"Host",nil)];
        [downloadFileNameCell setMainText:NSLocalizedString(@"File",nil)];
        //[[downloadFileNameCell cellContentView] setMainTextColor:[ControlViewCell theSystemDarkBlueColor]] ;
        //[[downloadFileNameCell cellContentView] setMainTextFont:[UIFont italicSystemFontOfSize:17]] ;
        //[downloadFileNameCell setTabWidth:1] ;
        //[downloadFileNameCell setLeadingTabWidth:0];
        [tmpObj=[downloadFileNameCell textField] setPlaceholder:@"MyProject.hmipad"];     //**
        [tmpObj setText:[defaults() downloadFileName]];
        //[tmpObj setText:[self downloadFileName]];
        [tmpObj setKeyboardType:UIKeyboardTypeURL] ;
        [tmpObj setReturnKeyType:UIReturnKeyDone];
    }
    return downloadFileNameCell ;
}

//---------------------------------------------------------------------------------------------------
- (void)setDownloadFileNameCell:(ManagedTextFieldCell*)aCell
{
    downloadFileNameCell = aCell;
}



//---------------------------------------------------------------------------------------------
- (SWTableViewMessage *)messageDownload
{
    if ( messageDownload == nil )
    {
        messageDownload = [[SWTableViewMessage alloc] initForSectionFooter] ;
        [messageDownload setMessage:NSLocalizedString(@"MessageDownload" ,nil)] ;
    }
    return messageDownload ;
}




///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TextField Delegates and NavigationButtonController callbacks
///////////////////////////////////////////////////////////////////////////////////////////


//----------------------------------------------------------------------------------
- (void)tableFieldsController:(SWTableFieldsController*)controller 
			didProvideControl:(UIControl*)aControl animated:(BOOL)animated
{
	UIBarButtonItem *barItem = nil ;
    if ( aControl ) barItem = [[UIBarButtonItem alloc] initWithCustomView:aControl];
    [[self navigationItem] setRightBarButtonItem:barItem animated:animated] ;
}

//--------------------------------------------------------------------------------
// aquest es cridat per el NavigationButtonController
- (void)tableFieldsControllerCancel:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    //[self getHostAddrTextsFromModel];
}

//--------------------------------------------------------------------------------
// aquest es cridat per el NavigationButtonController
- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    NSArray *textFields = [controller textResponders] ;
    for ( UITextField *textField in textFields )
    {
        NSString *text = [textField text] ;

        if ( textField == [downloadServerNameCell textField] )
        {
            [defaults() setDownloadServerName:text] ;
        }
        
        else if ( textField == [downloadFileNameCell textField] )
        {
            [defaults() setDownloadFileName:text] ;
        }
    }
}

//-----------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    ManagedTextFieldCell *responderCell = nil ;
    
    if ( textField == [downloadServerNameCell textField] )
    {
    	responderCell = downloadFileNameCell ;
    }
    
    if ( responderCell )
    {
        [[responderCell textField] becomeFirstResponder] ;
    	return NO ;
    }

    return YES ;
}


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark DownloadFromServer methods
///////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------------------
- (id)initWithFileCategory:(int)category
{
    //NSLog( @"DownloadFromServer: init") ;
    self = [super initWithStyle:UITableViewStyleGrouped];
    if ( self )
    {
        [self setTitle:NSLocalizedString(@"Download",nil)] ;
        fileCategory = category ;
    }
    return self;
}



//---------------------------------------------------------------------------------------------
- (void)disposeProperties
{
    //NSLog( @"DownloadFromServer: disposeProperties") ;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
    downloading = NO ;
    rightButton = nil ;
    downloadFileNameCell = nil ;
    messageDownload = nil ;

}

//---------------------------------------------------------------------------------------------
- (void)dealloc
{
    // NSLog( @"DownloadFromServer: dealloc") ;
    [self disposeProperties] ;
}


//---------------------------------------------------------------------------------------------
- (void)loadView
{
    [super loadView];
}


//---------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self setDeviceBasedTintColor] ;
    viewAppeared = NO ;
    dataNeedsReload = NO ;
    
    [self establishDoneButton:YES animated:NO] ;
}

//---------------------------------------------------------------------------------------------
- (void)viewDidUnload
{
    //NSLog( @"DownloadFromServerController viewDidUnload" );
    [super viewDidUnload] ;
    [self disposeProperties] ;
}

//---------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated 
{
    //NSLog( @"DownloadFromServerController viewWillAppear" );
    [super viewWillAppear:animated];
    
    if ( dataNeedsReload )
    {
        [[self tableView] reloadData] ;
        dataNeedsReload = NO ;
    }
    
    viewAppeared = YES ;
    
}

//---------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated 
{
    //viewAppeared = YES ;

    [super viewDidAppear:animated];
}


//---------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated 
{
    //NSLog( @"DownloadFromServerController viewWillDissappear" ) ;
    
    viewAppeared = NO ;
    
	[super viewWillDisappear:animated];
    
}


//---------------------------------------------------------------------------------------------
- (void)viewDidDisappear:(BOOL)animated 
{
    //NSLog( @"DownloadFromServerController viewDidDissappear: %@", [[self navigationController] topViewController] ) ;
    
	[super viewDidDisappear:animated];
}


//---------------------------------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES ;
}

//---------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning 
{

    //NSLog( @"DownloadFromServerController didReceiveMemoryWarning" ) ;
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TableView Data Source methods
///////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return TotalSectionsInTable ;
}

//---------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger number ;
    
    switch ( section )
    {
        case kDownloadFromServerSection:
            number = TotalRowsInDownloadFromServerSection ;
            break ;
            
        case kDownloadFromServerButtonSection:
            number = TotalRowsInDownloadFromServerButtonSection ;
            break ;
            
        default:
            number = 0 ;
            break ;
    }
    return number ;
}


//---------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section 
{
    if ( section == kDownloadFromServerSection ) return NSLocalizedString( @"Download File From HTTP or FTP Server", nil ) ; 
    return nil ;
}

//---------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ( section == kDownloadFromServerSection ) return NSLocalizedString(@"MessageServerDownload", nil) ;
    else if ( section == kDownloadFromServerButtonSection ) return NSLocalizedString(@"MessageDownload" ,nil) ; 
    return nil ;
}

//---------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ButtonCellIdentifier = @"ButtonCell";
    NSString *identifier = nil ; ;
    
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section] ;
    
    if ( section == kDownloadFromServerSection )
    {
        if ( row == kDownloadServerUrlRow ) return [self downloadServerNameCell] ;
        else if ( row == kDownloadFileNameRow ) return [self downloadFileNameCell] ;
    }
    
    else if ( section == kDownloadFromServerButtonSection )
    {
        if ( row == kDownloadFromServerButtonRow ) identifier = ButtonCellIdentifier ;
    }

    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[LabelViewCell alloc] initWithReuseIdentifier:identifier];
        //ControlViewCellContentView *cellContentView = [cell cellContentView] ;
    
        if ( identifier == ButtonCellIdentifier )
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            [cell setIsButtonLikeCell:YES];
            //[cellContentView setCenteredMainText:YES] ;
        }
    }

    
    
    // Set up the cell...
    
    // Teoricament es podria posar el tipus d'accesori a la creacio de la celda, pero degut
    // a un bug de UIKit, quan es reusa una celda que ha estat esborrada, el accesori queda
    // a UITableViewCellAccessoryNone. Per tant l'establim explicitament aqui cada vegada
    
    /*
    if ( identifier == StartServerCellIdentifier ) 
    {
        //[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell ;
    }
    */
    
    NSString *name ;
    NSString *size ;
    
    if ( identifier == ButtonCellIdentifier )
    {
        ControlViewCellContentView *cellContentView = [cell cellContentView] ;
    
        if ( section == kDownloadFromServerButtonSection )
        {
            if ( downloading )
            {
                name = NSLocalizedString( @"Downloading...", nil ) ;                   
                [cellContentView setMainTextFont:[UIFont italicSystemFontOfSize:15]] ;
                [cellContentView setMainTextColor:[UIColor grayColor]];
            }
            else
            {
                name = NSLocalizedString( @"Download File", nil ) ;
                [(LabelViewCell*)cell setIsButtonLikeCell:YES];
//                [cellContentView setMainTextFont:[UIFont systemFontOfSize:15]] ;
//                [cellContentView setMainTextColor:UIColorWithRgb(SystemDarkerBlueColor)];
            }
            [cell setAccessoryType:UITableViewCellAccessoryNone] ;
            [cellContentView setCenteredMainText:YES] ;
        }
        size = @"" ;
    }
       
    //[[cell label] setText:name];
    if ( name ) [cell setMainText:name];
    if ( size ) [[cell secondLabel] setText:size];  
    return cell;
}


//---------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    //NSInteger section = [indexPath section];
    //if ( section == (kSourceFilesSection && !emptySources)  ) return YES ;  // fa que desaparegui el disclosure excepte si tenim setHidesAccessoryWhenEditing:NO
    return NO;
}


//---------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO; // fa que no apareguin les barres de moure
}


/*
//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
 
}
*/

/*
//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog1(@"FilesViewController Moving File from %@ to %@", fromIndexPath, toIndexPath) ;
}
*/

///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark TableView Delegate methods
///////////////////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------------------

/*
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger offset = [self sectionOffsetForSection:section] ;
    section += offset ; 
    if ( section == kSourceFilesSection ) return NO ;  // si es YES mou el backgrownd cap a la dreta
    else return NO;
}
*/




/*
//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ( section == kDownloadFromServerButtonSection ) return [self messageDownload] ;
    return nil ;
}

//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{ 
    if ( section == kDownloadFromServerButtonSection ) return [[self messageDownload] messageHeight] ;
    //else if ( section == kOtherFilesSection ) return [[self messageView2] messageHeight] ;
    
    return 0.0f;
}
*/


/*
//---------------------------------------------------------------------------------------------
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //NSLog1( @"viewForHeaderInSection section:%d", section) ;
    
    if ( section == kLoadTemplatesSection ) return [self messageTemplatesView] ;
    
    return nil ;
}


//---------------------------------------------------------------------------------------------
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ( section == kLoadTemplatesSection ) return [[self messageTemplatesView] messageHeight] ;

    return 0.0f;
}
*/



/*
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog1(@"FilesViewController WillSelectRow") ;
    return indexPath;
}
*/


//---------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
    NSInteger row = [indexPath row] ;
    NSInteger section = [indexPath section] ;
    
    UIViewController *viewController = nil ;
    
    if ( section == kDownloadFromServerButtonSection )
    {
        if ( row == kDownloadFromServerButtonRow )
        {
            if ( !downloading )
            {
                if ( [rightButton isStarted] )
                {
                    [rightButton stopWithCancel:NO animated:YES] ; // acceptem els canvis
                }
                
                NSString *fileName = [self getDownloadUrlText] ;
                //NSLog1( @"Download from server executing %@", fileName ) ;
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
                [nc addObserver:self selector:@selector(downloadEndedNotification:) name:URLDownloadObjectEnded object:nil] ;
                [URLDownloadObject downloadFileWithUrlName:fileName withFileCategory:fileCategory] ;
                [self stablishDownload:YES] ;
                
            }
            [tableView deselectRowAtIndexPath:indexPath animated:YES] ;  //$$   // si animated es YES es crea un contorn al voltant dels objectes
        }
    }
    
    // si hem creat un controlador fem push i l'alliverem
    if ( viewController != nil )
    {
        [[self navigationController] pushViewController:viewController animated:YES];
    }
}

/*
//---------------------------------------------------------------------------------------------
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if ( section == kOtherFilesSection ) return UITableViewCellEditingStyleDelete;
    else return UITableViewCellEditingStyleNone;
}
*/

/*
//---------------------------------------------------------------------------------------------
- (NSIndexPath *)tableView:(UITableView *)tableView 
                            targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath 
                            toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
//    int row = [proposedDestinationIndexPath row];
//    if ( row == 0 ) row = 1 ;
//    return [NSIndexPath indexPathForRow:row inSection:0];
    return proposedDestinationIndexPath ;
}
*/

    


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark CallBacks dels controllers en push
///////////////////////////////////////////////////////////////////////////////////////////////
/*
//----------------------------------------------------------------------------------------
// Crea i mostra un alertView amb el missatge especificat especificant self com a delegat
- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil 
                        cancelButtonTitle:NSLocalizedString( @"OK", nil )
                        otherButtonTitles:nil ] ;
    [alertView show] ;
    [alertView release] ;  // es retinguda per la aplicació, per tant podem decrementar el retain count
}
*/

/*
//---------------------------------------------------------------------------------------------
- (void)topViewControllerDidCancel:(UITableViewController*)topController
{
    NSLog1( @"FilesViewController topViewControllerDidCancel") ;
    [[self navigationController] popViewControllerAnimated:YES];
}
*/

/*
//---------------------------------------------------------------------------------------------
- (void)topViewControllerDidSave:(UITableViewController*)topController
{
    NSLog1( @"FilesViewController topViewControllerDidSave") ;
    [[self tableView] reloadData];
    [[self navigationController] popViewControllerAnimated:YES];
}
*/

///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark DownloadObject notifications
///////////////////////////////////////////////////////////////////////////////////////////////


//---------------------------------------------------------------------------------------------
- (void)downloadEndedNotification:(NSNotification*)note
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc removeObserver:self name:URLDownloadObjectEnded object:nil] ;
    [self stablishDownload:NO] ;
    // aqui treure spinner
    //NSLog( @"downloadEnded" ) ;
}


@end

