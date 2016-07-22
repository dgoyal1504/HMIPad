//
//  pdfViewController.h
//  ScadaMobile_090714
//
//  Created by Joan on 16/07/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "SubstitutableDetailViewController.h"

@class BubbleView ;

@interface PDFViewController : UIViewController<UIWebViewDelegate>
{
    //NSString *pdfUrlText;
}

//@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *pdfUrlText;

@end
