//
//  ReaderOverlayController.h
//  HmiPad
//
//  Created by Joan Lluch on 02/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.


typedef enum {
    OVERLAY_MODE_DONE,
    OVERLAY_MODE_CANCEL
} ReaderOverlayMode;

@protocol ReaderOverlayDelegate<NSObject>
- (void) readerOverlayDidDismiss;

@optional
- (BOOL)shouldShowCameraPositionControl ;
- (void)readerOverlayFlip;
- (CGFloat)getFps ;
@end


@interface ReaderOverlayView : UIView
{
    __weak id<ReaderOverlayDelegate> _delegate;

    //UIView *_view ;
    UIToolbar *_toolbar0;
    UIToolbar *_toolbar1;
    UILabel *_label ;
    UILabel *_progressLabel ;
    UILabel *_helpView ;
    UIView *_shutter ;
    UIView *_guide ;
    CFRunLoopTimerRef _getFpsTimer ;
}

//- (id)initWithText:(NSString*)text view:(UIView*)aView delegate:(id<ReaderOverlayDelegate>)obj;
- (void)setShowProgress:(BOOL)show orText:(NSString*)text;
- (void)setShutterOn:(BOOL)on animated:(BOOL)animated;
@property (nonatomic,weak) id<ReaderOverlayDelegate> delegate;
@property (nonatomic) NSString *supportText;
@property (nonatomic) CGFloat topLayoutGuideLength;

@end
