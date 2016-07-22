//
//  SWPdfView.m
//  HmiPad
//
//  Created by Joan Lluch on 11/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWPdfView.h"
#import "IncidentView.h"


@interface SWPdfView()<UIWebViewDelegate>
{
    UIWebView *_webView;
    IncidentView *_incidentView;
    UIActivityIndicatorView *_activity;
    BOOL _isFile;
}

@end


@implementation SWPdfView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        _webView = [[UIWebView alloc] initWithFrame:self.bounds] ;
    
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight] ;
        [_webView setDelegate:self] ;
        [_webView setAllowsInlineMediaPlayback:YES];
        
        [self addSubview:_webView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    _webView.scalesPageToFit = scalesPageToFit ;
}

- (BOOL)scalesPageToFit
{
    return _webView.scalesPageToFit;
}

- (void)reloadPage
{
    if ( _pdfUrlText )
    {
        NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch ;
        NSRange range1, range2 ;
        range1 = [_pdfUrlText rangeOfString:@"http://" options:options] ;
        range2 = [_pdfUrlText rangeOfString:@"https://" options:options] ;
    
        if ( range1.length || range2.length ) 
        {
            _isFile = NO ;
            NSString *fullPath = [_pdfUrlText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
            NSURL *url = [NSURL URLWithString:fullPath] ;
            [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
        else
        {
            _isFile = YES ;
            NSString *lastComponent = [_pdfUrlText pathExtension] ;
            range1 = [lastComponent rangeOfString:@"csv" options:options] ;
            range2 = [lastComponent rangeOfString:@"smcsv" options:options] ;
            if ( range1.length || range2.length ) 
            { 
                NSData *data = [[NSData alloc] initWithContentsOfFile:_pdfUrlText] ;
                //ISO-8859-1-Windows-3.0-Latin-1
                [_webView loadData:data MIMEType:@"text/csv" textEncodingName:@"ISO-8859-1" baseURL:[NSURL URLWithString:@"http://www.unknown.com"]] ;
            }
            else
            {
                NSURL *url = [NSURL fileURLWithPath:_pdfUrlText] ;
                [_webView loadRequest:[NSURLRequest requestWithURL:url]];
            }
        }
    }
    
    else 
    {
        [self _establishIncidentViewWithMessage:NSLocalizedString(@"PdfViewerMain", nil)
                secMessage:NSLocalizedString(@"PdfViewerNoFileGiven", nil)] ;
    }
}


- (void)dismiss
{
    NSURL *url = [NSURL URLWithString:@"about:blank"] ;
    [_webView loadRequest:[NSURLRequest requestWithURL:url]] ;  // evitem que fitxers de audio continuin sonan
}


- (void)goBack
{
    [_webView goBack];
}


- (void)goForward
{
    [_webView goForward];
}


- (void)_establishActivityIndicator:(BOOL)showIt
{
    if ( showIt )
    {
        if ( _activity == nil )
        {
            _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [_activity setColor:[UIColor grayColor]];
            [_activity setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|
                UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        
            UIView *selfView = self;
            CGSize size = selfView.bounds.size;
            CGPoint center = CGPointMake( size.width/2, size.height/2 );
            [_activity setCenter:center];
            [selfView addSubview:_activity];
        }
        [_activity startAnimating];
    }
    else
    {
        [_activity stopAnimating];
        [_activity removeFromSuperview];
        _activity = nil;
    }
}

- (void)_establishIncidentViewWithMessage:(NSString*)msg secMessage:(NSString*)sMsg
{
    if ( msg ) 
    {
        [self _establishIncidentViewWithMessage:nil secMessage:nil] ; // ens carreguem possible incidentView
        _incidentView = [[IncidentView alloc] initWithFrame:[_webView frame]] ;  // el mateix frame que el webView
        
        // això és per que si es desplaça el view no es vegi un color diferent a sobre i sota
        [self addSubview:_incidentView] ;
        [[_incidentView mainLabel] setText:msg] ;
        [[_incidentView secondaryLabel] setText:sMsg] ;
    }
    else if ( _incidentView && msg == nil )
    {
        /*UIView *incident = incidentView ;
        [UIView animateWithDuration:0.3 
        animations:
        ^{
            [incident setAlpha:0.0f] ;
        } 
        completion:^(BOOL finished) 
        {
            [incident removeFromSuperview] ;
        }] ;
        */
        [_incidentView removeFromSuperview] ;
        _incidentView = nil ;
    }    
}


#pragma mark webView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad") ;

    [self _establishIncidentViewWithMessage:nil secMessage:nil] ;
    [self _establishActivityIndicator:YES] ;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad") ;
    [self _establishActivityIndicator:NO] ;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

    NSLog(@"didFailLoadWithError") ;
    NSString *mMsg = NSLocalizedString(@"PdfViewerMain", nil) ;
    //NSString *sMsg = [error localizedDescription] ;

    NSString *sMsg = nil ;
    if ( [_pdfUrlText length] )
    {    
        NSString *path ;
        
        // ignorem el error "Plug-in handled load"
        if ( ! ([[error domain] isEqualToString:@"WebKitErrorDomain"] && [error code] == 204) )
        {
            if ( _isFile ) path = [_pdfUrlText lastPathComponent] ;
            else path = _pdfUrlText ;
            sMsg = [NSString stringWithFormat:@"%@\n%@", [error localizedDescription], path] ;
        }
    }
    else
    {
        sMsg = NSLocalizedString(@"PdfViewerNoFileGiven", nil) ;
    }
    if ( sMsg ) [self _establishIncidentViewWithMessage:mMsg secMessage:sMsg] ;
    [self _establishActivityIndicator:NO] ;
}




@end
