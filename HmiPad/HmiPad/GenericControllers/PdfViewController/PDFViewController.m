//
//  pdfViewController.m
//  ScadaMobile_090714
//
//  Created by Joan on 16/07/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import "PDFViewController.h"
//#import "ViewControllerHelper.h"
//#import "BubbleView.h"
//#import "IncidentView.h"
#import "SWColor.h"
#import "SWPdfView.h"


@interface PDFViewController()<UIToolbarDelegate>
{
    //BubbleView *bubbleView ;
    //UIToolbar *toolbar0 ;
    //UIBarButtonItem *leftItem ;
    //UIButton *reloadBtn ;
    //UIActivityIndicatorView *activityView ;
    
    //UIWebView *webView;
    //IncidentView *incidentView ;
    //BOOL isFile ;
    
    SWPdfView *_swPdfView;
    
    BOOL isSpinning ;
}

//@property (nonatomic, retain) NSString *errMsg;

@end


//---------------------------------------------------------------------------------------------

@implementation PDFViewController

//@synthesize pdfUrlText ;
//@synthesize errMsg;
//@synthesize bubbleView; 

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

//---------------------------------------------------------------------------------------------
- (id)init
{
    if ( (self = [super init]) )
    {
        //[webView setDelegate:self] ;
    }
    return self ;
}




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark delegat de BubbleView i Button action
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////



////---------------------------------------------------------------------------------------------
//- (void)establishIncidentViewWithMessage:(NSString*)msg secMessage:(NSString*)sMsg
//{
//    if ( msg ) 
//    {
//        [self establishIncidentViewWithMessage:nil secMessage:nil] ; // ens carreguem possible incidentView
//        incidentView = [[IncidentView alloc] initWithFrame:[webView frame]] ;  // el mateix frame que el webView
//        
//        // això és per que si es desplaça el view no es vegi un color diferent a sobre i sota
//        [[self view] addSubview:incidentView] ;
//        [[incidentView mainLabel] setText:msg] ;
//        [[incidentView secondaryLabel] setText:sMsg] ;
//    }
//    else if ( incidentView && msg == nil )
//    {
//        /*UIView *incident = incidentView ;
//        [UIView animateWithDuration:0.3 
//        animations:
//        ^{
//            [incident setAlpha:0.0f] ;
//        } 
//        completion:^(BOOL finished) 
//        {
//            [incident removeFromSuperview] ;
//        }] ;
//        */
//        [incidentView removeFromSuperview] ;
//        incidentView = nil ;
//    }    
//}


/*
//---------------------------------------------------------------------------------------------
- (void)establishBubbleViewWithMessage:(NSString*)msg forView:(UIView*)view
{

    if ( view )
    {
        [self establishBubbleViewWithMessage:nil forView:nil] ;
        UIView *theParent = [self view] ;
        
        CGPoint center = [view center] ;
        CGPoint thePoint = [theParent convertPoint:center fromView:view] ;
        
        
        bubbleView = [[BubbleView alloc] initWithView:theParent atPoint:thePoint vGap:0 message:msg] ;
        [bubbleView setDelegate:self] ;
        [theParent addSubview:bubbleView] ;
    }

    else if ( bubbleView )
    {
        // eliminacio animada del bubbleView
        UIView *bubble = bubbleView ;
        [UIView animateWithDuration:0.3 
        animations:
        ^{
            [bubble setAlpha:0.0f] ;
        } 
        completion:^(BOOL finished) 
        {
            [bubble removeFromSuperview] ;
        }] ;
        dispose( bubbleView ) ;
    }
}
*/






/*
//---------------------------------------------------------------------------------------------
- (void)infoButtonAction:(UIButton*)sender
{
    [self establishBubbleViewWithMessage:[self errMsg] forView:sender] ;
}
*/
/*
//---------------------------------------------------------------------------------------------
- (void)bubbleViewTouched:(BubbleView *)sender
{
    [self establishBubbleViewWithMessage:nil forView:nil] ;
}
*/


////---------------------------------------------------------------------------------------------
//- (void)reloadPage
//{
//    if ( pdfUrlText )
//    {
//        NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch ;
//        NSRange range1, range2 ;
//        range1 = [pdfUrlText rangeOfString:@"http://" options:options] ;
//        range2 = [pdfUrlText rangeOfString:@"https://" options:options] ;
//    
//        if ( range1.length || range2.length ) 
//        {
//            isFile = NO ;
//            NSString *fullPath = [pdfUrlText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
//            NSURL *url = [NSURL URLWithString:fullPath] ;
//            [webView loadRequest:[NSURLRequest requestWithURL:url]];
//        }
//        else
//        {
//            isFile = YES ;
//            NSString *lastComponent = [pdfUrlText pathExtension] ;
//            range1 = [lastComponent rangeOfString:@"csv" options:options] ;
//            range2 = [lastComponent rangeOfString:@"smcsv" options:options] ;
//            if ( range1.length || range2.length ) 
//            { 
//                NSData *data = [[NSData alloc] initWithContentsOfFile:pdfUrlText] ;
//                //ISO-8859-1-Windows-3.0-Latin-1
//                [webView loadData:data MIMEType:@"text/csv" textEncodingName:@"ISO-8859-1" baseURL:[NSURL URLWithString:@"http://www.unknown.com"]] ;
//            }
//            else
//            {
//                NSURL *url = [NSURL fileURLWithPath:pdfUrlText] ;
//                [webView loadRequest:[NSURLRequest requestWithURL:url]];
//            }
//        }
//    }
//    
//    else 
//    {
//        [self establishIncidentViewWithMessage:NSLocalizedString(@"PdfViewerMain", nil) 
//                secMessage:NSLocalizedString(@"PdfViewerNoFileGiven", nil)] ;
//    }
//}


//---------------------------------------------------------------------------------------------
- (void)setPdfUrlText:(NSString *)pdfUrlText
{
    _pdfUrlText = pdfUrlText;
    [self reloadPage];
}

//---------------------------------------------------------------------------------------------
- (void)reloadPage
{
    [_swPdfView setPdfUrlText:_pdfUrlText];
    [_swPdfView reloadPage];
}


//---------------------------------------------------------------------------------------------
- (void)infoButtonAction:(UIButton*)sender
{
    [self reloadPage] ;
}

//---------------------------------------------------------------------------------------------
- (void)establishLeftItemWithSpinner:(BOOL)wantsSpinner
{
    UIBarButtonItem *leftItem = nil ;
    if ( wantsSpinner && !isSpinning )
    {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] ;
        [activityView startAnimating] ;
        [activityView setColor:[UIColor darkGrayColor]];
        leftItem = [[UIBarButtonItem alloc] initWithCustomView:activityView] ;
        isSpinning = YES ;
    }
    else if ( !wantsSpinner && isSpinning )
    {
        
        leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(infoButtonAction:)] ;
        isSpinning = NO ;
    }
    
    if (leftItem )
    {
//        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[toolbar0 items]] ;
//        [items replaceObjectAtIndex:0 withObject:leftItem] ;
//        [toolbar0 setItems:items] ;
        
        [[self navigationItem] setRightBarButtonItem:leftItem];
    }
    
}

//---------------------------------------------------------------------------------------------
// Implement loadView to create a view hierarchy programmatically, without using a nib.

//- (void)loadView
//{
//    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,320)] ;
//    
////    if ( IS_IOS7 )
////    {
//        webView = [[UIWebView alloc] initWithFrame:contentView.bounds] ;
////    }
////    else
////    {
////        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,44,320,320-44)] ;
////    }
//    
//    [webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight] ;
//    [webView setDelegate:self] ;
//    [webView setAllowsInlineMediaPlayback:YES];
//    [contentView addSubview:webView] ;
//    
//    [self setView:contentView] ;
//}

//---------------------------------------------------------------------------------------------
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
    _swPdfView = [[SWPdfView alloc] initWithFrame:CGRectMake(0,0,320,320)];
    _swPdfView.scalesPageToFit = YES;
    self.view = _swPdfView;
}

#define thickness 44

//---------------------------------------------------------------------------------------------
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{	
    [super viewDidLoad];
 
    //[webView setScalesPageToFit:YES] ;
    
    // Tells the webView to load pdfUrl
    //[self reloadPage] ;
}



- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadPage];
   // [webView.scrollView setContentOffset:CGPointMake(0,-44) animated:animated];
}

- (void)viewDidLayoutSubviews
{
//    CGRect bounds = self.view.bounds;
    
//    CGFloat topGuide = 0;
//    if ( IS_IOS7 )
//        topGuide = self.topLayoutGuide.length;
    
//    CGRect toolbarFrame = toolbar0.frame;
//    toolbarFrame.origin.y = topGuide;
//    toolbar0.frame = toolbarFrame;
    
//    CGFloat inset = toolbarFrame.origin.y + toolbarFrame.size.height;
    
    // Hem d'ajustar el frame en lloc del inset perque si ajustem el inset: (1) el content offset no queda be; (2) el indicador de pagina queda a sota
//    CGRect webFrame = webView.frame;
//    webFrame.origin.y = inset;
//    webFrame.size.height = bounds.size.height-inset;
//    webView.frame = webFrame;
    
    // aquesta hauria de ser la implementacio correcta
//    UIScrollView *scrollView = webView.scrollView;
//    [scrollView setContentInset:UIEdgeInsetsMake(inset, 0, 0, 0)];
//    [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(inset, 0, 0, 0)];
//    [scrollView setContentOffset:CGPointMake(0,-inset)];     // NO VA !!
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

// http://stackoverflow.com/questions/12602899/mpmovieplayercontroller-breaks-stops-after-going-to-fullscreen-in-ios6
// ^ comentem el codi seguent per aixo. He posat el mateix codi al dismiss del model controller

//    NSURL *url = [NSURL URLWithString:@"about:blank"] ;
//    [webView loadRequest:[NSURLRequest requestWithURL:url]] ;  // evitem que fitxers de audio continuin sonan
}



//---------------------------------------------------------------------------------------------
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    return YES ;
}



////---------------------------------------------------------------------------------------------
//- (void)dismiss
//{
//    //UIViewController *parent = [self parentViewController] ;
//
//    NSURL *url = [NSURL URLWithString:@"about:blank"] ;
//    [webView loadRequest:[NSURLRequest requestWithURL:url]] ;  // evitem que fitxers de audio continuin sonan
//    
//    //[self dismissModalViewControllerAnimated:YES] ;
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

//---------------------------------------------------------------------------------------------
- (void)dismiss
{
    [_swPdfView dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark delegats de UIWebView
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType

{

    NSLog(@"expected:%d, got:%d", UIWebViewNavigationTypeLinkClicked, navigationType);
    if (navigationType == UIWebViewNavigationTypeLinkClicked) 
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
        return NO;
    }


    NSLog( @"ara si" ) ;
    return YES ;
}
*/

//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    NSLog(@"webViewDidStartLoad") ;
//
//    [self establishIncidentViewWithMessage:nil secMessage:nil] ;
//    [self establishLeftItemWithSpinner:YES] ;
//}
//
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    NSLog(@"webViewDidFinishLoad") ;
//    [self establishLeftItemWithSpinner:NO] ;
//}
//
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//
//    NSLog(@"didFailLoadWithError") ;
//    NSString *mMsg = NSLocalizedString(@"PdfViewerMain", nil) ;
//    //NSString *sMsg = [error localizedDescription] ;
//
//    NSString *sMsg = nil ;
//    if ( [pdfUrlText length] )
//    {    
//        NSString *path ;
//        
//        // ignorem el error "Plug-in handled load"
//        if ( ! ([[error domain] isEqualToString:@"WebKitErrorDomain"] && [error code] == 204) )
//        {
//            if ( isFile ) path = [pdfUrlText lastPathComponent] ;
//            else path = pdfUrlText ;
//            sMsg = [NSString stringWithFormat:@"%@\n%@", [error localizedDescription], path] ;
//        }
//    }
//    else
//    {
//        sMsg = NSLocalizedString(@"PdfViewerNoFileGiven", nil) ;
//    }
//    if ( sMsg ) [self establishIncidentViewWithMessage:mMsg secMessage:sMsg] ;
//    [self establishLeftItemWithSpinner:NO] ;
//}


@end
