//
//  SWCodeScannerViewController.h
//  HmiPad
//
//  Created by Joan Lluch on 02/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class SWCodeScannerViewController;


@protocol SWCodeScannerViewControllerDelegate<NSObject>

- (void)codeScannerViewController:(SWCodeScannerViewController*)controller didScanText:(NSString*)text;
- (void)codeScannerViewController:(SWCodeScannerViewController*)controller didCancelWithError:(BOOL)err;

@optional
- (void)codeScannerViewControllerDidDismiss:(SWCodeScannerViewController*)controller;
- (void)codeScannerViewController:(SWCodeScannerViewController*)controller didFlipCameraToPosition:(AVCaptureDevicePosition)position;

@end



@interface SWCodeScannerViewController : UIViewController

@property (nonatomic,weak) id<SWCodeScannerViewControllerDelegate> delegate;
@property (nonatomic) NSString *supportText;
@property (nonatomic) CGFloat scannerZoomFactor;
@property (nonatomic) AVCaptureDevicePosition cameraPosition;

@end
