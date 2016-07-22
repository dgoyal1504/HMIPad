//
//  SWWebItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/4/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWWebItemController.h"

#import "AppModelFilePaths.h"

#import "SWExpression.h"
#import "SWWebItem.h"
#import "SWPdfView.h"


#import "Reachability.h"

@interface SWWebItemController ()
{
    SWPdfView *_swPdfView;
}

- (SWWebItem*)_webItem;
- (void)_refreshViewFromURLExpression;

@end

@implementation SWWebItemController


- (void)loadView
{
    _swPdfView = [[SWPdfView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    _swPdfView.scalesPageToFit = YES;
    self.view = _swPdfView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _swPdfView = nil;
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Reachability sharedReachability];  // <- Ens asegurem que la reachability esta activada
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_reachabilityChangeNotification:) name:kReachabilityChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _refreshViewFromURLExpression];
}

#pragma mark - Private Methods

- (SWWebItem*)_webItem
{
    if ([self.item isKindOfClass:[SWWebItem class]])
        return (SWWebItem*)self.item;
    
    return nil;
}



//- (void)_refreshViewFromURLExpressionVV
//{
//    SWWebItem *item = [self _webItem];
//    
//    NSString *urlString = [item.urlExpression valueAsStringWithFormat:nil];
//    
//    //if (![_lastURLPath isEqualToString:urlString])
//    {
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//        
//        if (_webView.isLoading)
//            [_webView stopLoading];
//        
//        [_webView loadRequest:request];
//        _lastURLPath = urlString;
//    }
//}


- (void)_refreshViewFromURLExpression
{
    SWWebItem *item = [self _webItem];
    
    NSString *urlString = [item.urlExpression valueAsStringWithFormat:nil];
    //NSString *fullPath = [filesModel() fullViewerUrlPathForTextUrl:urlString /*forCategory:kFileCategoryAssetFile*/];
    NSString *fullPath = [filesModel().filePaths fullViewerUrlPathForTextUrl:urlString inDocumentName:item.redeemedName];
    
    [_swPdfView setPdfUrlText:fullPath];
    [_swPdfView reloadPage];
}


- (void)refreshZoomScaleFactor:(CGFloat)contentScaleFactor
{
 
//    [super refreshZoomScaleFactor:contentScaleFactor];    // <-- no fa res, ho comentem fora
//    [self setZoomScaleFactorDeep];                        // <-- no fa res, ho comentem fora
}


#pragma mark Protocol Value Observer

- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed
{
    SWWebItem *item = [self _webItem];
    
    if (value == item.urlExpression)
    {
        [self _refreshViewFromURLExpression];
    }
    
    else if (value == item.goBackExpression)
    {
        BOOL doIt = [value valueAsBool];
        if ( doIt )
            [_swPdfView goBack];
    }
    
    else if ( value == item.goForwardExpression)
    {
        BOOL doIt = [value valueAsBool];
        if ( doIt )
            [_swPdfView goForward];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}



#pragma mark protocol Reachability Change notification

- (void)_reachabilityChangeNotification:(NSNotification *)notification
{
    Reachability *reachability = [notification object];
    ReachabilityStatus previousStatus = [reachability previousStatus];
    ReachabilityStatus status = [reachability status];
    if ( previousStatus == kNoReachability && status != kNoReachability )
    {
        [self _refreshViewFromURLExpression];
    }
}




@end
