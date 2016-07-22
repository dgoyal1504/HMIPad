//
//  SWPdfView.h
//  HmiPad
//
//  Created by Joan Lluch on 11/11/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWPdfView : UIView

@property (nonatomic) NSString *pdfUrlText;
@property (nonatomic) BOOL scalesPageToFit;

- (void)reloadPage;
- (void)dismiss;
- (void)goBack;
- (void)goForward;

@end
