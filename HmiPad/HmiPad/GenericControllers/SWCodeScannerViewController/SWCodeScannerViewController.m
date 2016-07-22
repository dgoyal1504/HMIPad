//
//  SWCodeScannerViewController.m
//  HmiPad
//
//  Created by Joan Lluch on 02/03/14.
//  Copyright (c) 2014 SweetWilliam, SL. All rights reserved.
//


#import "SWCodeScannerViewController.h"

#import "ReaderOverlayView.h"
//#import "UserDefaults.h"


@interface SWScannerHighlightLayer : CALayer
{
    CGRect _highlightRect;
}

- (void)setHighlightRect:(CGRect)highlightRect;

@end

@implementation SWScannerHighlightLayer





- (void)drawInContext:(CGContextRef)ctx
{

}


- (void)setHighlightRect:(CGRect)highlightRect
{
    _highlightRect = highlightRect;
}

@end



@interface SWCodeScannerViewController ()

@end


@interface SWCodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate,ReaderOverlayDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    ReaderOverlayView *_overlay;
    CALayer *_highlightLayer;
    dispatch_queue_t _scanQueue;
    AVAudioPlayer *_audioPlayer;
}
@end

@implementation SWCodeScannerViewController
{
    //SystemSoundID _sSBeepId;
    BOOL _startedScanning;
}


+ (BOOL)supportsCamera
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,320)];
    self.view = view;
}



//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    UIView *selfView = self.view;
//
//    _overlayView = [[UIView alloc] initWithFrame:selfView.bounds];
//    [_overlayView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
//    [selfView addSubview:_overlayView];
//    
//    _overlay = [[ReaderOverlayController alloc] initWithText:_supportText view:_overlayView delegate:self] ;
//    
//    [_overlay setShutterOn:YES animated:NO];
//    _startedScanning = NO;
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *selfView = self.view;

    _overlay = [[ReaderOverlayView alloc] initWithFrame:selfView.bounds];
    [_overlay setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_overlay setDelegate:self];
    [_overlay setSupportText:_supportText];
    [selfView addSubview:_overlay];
    
    [_overlay setShutterOn:YES animated:NO];
    _startedScanning = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated] ;
    
//    UIApplication *app = [UIApplication sharedApplication] ;
//    statusBarStyle = [app statusBarStyle] ;
//    [app setStatusBarStyle:UIStatusBarStyleLightContent animated:YES] ;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(avCaptureFailed:) name:AVCaptureSessionRuntimeErrorNotification object:nil];
    [nc addObserver:self selector:@selector(avCaptureStarted:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    [nc addObserver:self selector:@selector(avCaptureStoped:) name:AVCaptureSessionDidStopRunningNotification object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated] ;
    [self startScanning] ;
}


- (void)viewWillDisappear:(BOOL)animated
{
//    UIApplication *app = [UIApplication sharedApplication] ;
//    [app setStatusBarStyle:statusBarStyle animated:YES] ;
    [super viewWillDisappear:animated] ;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated] ;
    if ( [_delegate respondsToSelector:@selector(codeScannerViewControllerDidDismiss:)] )
    {
        [_delegate codeScannerViewControllerDidDismiss:self] ;
    }
}


// NO ESBORRAR - DEIXAR PER REFERENCIA
//- (void)sw_rotatePreviewToInterfaceOrientationV:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    CGFloat angle=0 ;
//    CGFloat tx=0, ty=0 ;
//    
//    //return ;
//    
//    //CGAffineTransform t = [reader previewTransform] ;
//    //NSLog( @"transform a:%g b:%g c:%g d:%g tx:%g ty:%g", t.a, t.b, t.c, t.d, t.tx, t.ty ) ;
//    if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ) angle = M_PI_2, tx = -54, ty = -(54+27) ;
//    else if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ) angle = -M_PI_2, tx = 54, ty = 54+27 ;
//    else if ( toInterfaceOrientation == UIInterfaceOrientationPortrait ) angle = 0, tx = 0, ty = 27 ;
//    else if ( toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) angle = M_PI, tx = 0, ty = -27 ;
//
//    CGAffineTransform transform = CGAffineTransformMakeRotation( angle ) ;
//    //NSLog( @"transform a:%g b:%g c:%g d:%g tx:%g ty:%g", t.a, t.b, t.c, t.d, t.tx, t.ty ) ;
//    
//    transform = CGAffineTransformTranslate( transform, tx, ty ) ;
//    //NSLog( @"transform a:%g b:%g c:%g d:%g tx:%g ty:%g", t.a, t.b, t.c, t.d, t.tx, t.ty ) ;
//    
//    //[self setPreviewTransform:transform] ;
//    
//    CATransform3D transform3D = CATransform3DMakeAffineTransform(transform);
//    [_prevLayer setTransform:transform3D];
//}


- (void)sw_rotatePreviewToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ) videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    else if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeRight ) videoOrientation = AVCaptureVideoOrientationLandscapeRight ;
    else if ( toInterfaceOrientation == UIInterfaceOrientationPortrait ) videoOrientation = AVCaptureVideoOrientationPortrait;
    else if ( toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown ;
    
    [_prevLayer.connection setVideoOrientation:videoOrientation];
}


- (void)sw_delayedAdjustRectOfInterest:(NSArray*)data
{
    //NSLog( @"bounds :%@", NSStringFromCGRect(_prevLayer.bounds ));
    AVCaptureVideoPreviewLayer *prevLayer = data[0];
    AVCaptureMetadataOutput *output = data[1];
    
    CGRect rectOfInterest = [prevLayer metadataOutputRectOfInterestForRect:prevLayer.bounds];
    [output setRectOfInterest:rectOfInterest];
}


- (void)sw_adjustRectOfInterest
{
    // ho fem delayed perque en cas contrari no s'ajusta correctament encara que els bounds del _prevLayer son correctes (bug de Apple ?)
    if ( _prevLayer && _output )
    {
        [self performSelector:@selector(sw_delayedAdjustRectOfInterest:) withObject:@[_prevLayer, _output] afterDelay:0];
    }
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self sw_rotatePreviewToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation];
}


- (void)viewDidLayoutSubviews
{
    UIView *selfView = self.view;
    CGRect selfBounds = selfView.bounds;
    _prevLayer.frame = selfBounds;
    
    CGFloat top = self.topLayoutGuide.length;
    _overlay.topLayoutGuideLength = top;
    
    [self sw_adjustRectOfInterest];
}


//- (SystemSoundID)sSBeepId
//{
//    if ( _sSBeepId == 0)
//    {
//        NSURL *soundUrl = [[NSBundle mainBundle] URLForResource: @"scan1" withExtension: @"caf"] ;
//        AudioServicesCreateSystemSoundID( (__bridge CFURLRef)soundUrl, &_sSBeepId );
//        if( !_sSBeepId ) NSLog(@"ERROR loading sound:" ) ;
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance] ;
//        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil] ;
//    }
//    return _sSBeepId ;
//}


- (AVAudioPlayer*)audioPlayer
{
    if ( _audioPlayer == nil )
    {

        NSURL *soundUrl = [[NSBundle mainBundle] URLForResource: @"scan1" withExtension: @"caf"] ;
        NSError *error;
    
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
        if (error)
        {
            NSLog(@"Could not play beep file.");
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            [_audioPlayer prepareToPlay];
        }
    }
    return _audioPlayer;
}


- (void)selectCameraPosition:(int)pos       // AVCaptureDevicePositionFront, AVCaptureDevicePositionBack
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSInteger devCount = devices.count;
 
    AVCaptureDevice *device = nil;
    for ( NSInteger i=0 ; i<devCount ; i++ )
    {
        device = [devices objectAtIndex:i];
        if ( [device position] == pos )
        {
            break;
        }
    }
    
    if ( device == nil )
    {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        pos = device.position;
    }

    BOOL success = YES;
    NSError *error = nil;

    // eliminem qualsevol input que hi pogues haver
    [_session removeInput:_input];
    _input = nil;
    
    // determinem el zoom maxim permes
    AVCaptureDeviceFormat *captureDeviceFormat = device.activeFormat;
    CGFloat maxZoomFactor = [captureDeviceFormat videoMaxZoomFactor];
            
    // comprovem que el zoom factor no passar del maxim
    CGFloat zoomFactor = _scannerZoomFactor;
    if ( zoomFactor > maxZoomFactor ) zoomFactor = maxZoomFactor;
            
    // ajustem el zoom factor
    success = [device lockForConfiguration:&error];
    if ( success )
    {
        [device setVideoZoomFactor:zoomFactor];
        [device unlockForConfiguration];
            
        // hi afegim un nou input
        _input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        success = (_input != nil);
        if ( success )
        {
            [_session addInput:_input];
        }
    }

    // guardem la posicio de la camera
    _cameraPosition = pos;
    
    if ( [_delegate respondsToSelector:@selector(codeScannerViewController:didFlipCameraToPosition:)] )
        [_delegate codeScannerViewController:self didFlipCameraToPosition:_cameraPosition];
    
    if ( !success )
    {
        NSLog(@"Error: %@", error);
    }
}


- (void)flipCamera
{
    int newPosition;
    
    if ( _cameraPosition == AVCaptureDevicePositionBack ) newPosition = AVCaptureDevicePositionFront;
    else newPosition = AVCaptureDevicePositionBack;
    
    [self selectCameraPosition:newPosition];
    [self sw_adjustRectOfInterest];
}


//static void MyAudioServicesSystemSoundCompletionProc( SystemSoundID  ssID, void *clientData )
//{
//    AudioServicesRemoveSystemSoundCompletion( ssID ) ;
//    AudioServicesDisposeSystemSoundID( ssID ) ;
//    SWCodeScannerViewController *self = (__bridge SWCodeScannerViewController*)clientData ;
//    self->_sSBeepId = 0 ;
//    [self stopScanning] ;
//}
//
//
//- (void)performBeepV
//{
//    AudioServicesPlaySystemSound( [self sSBeepId ] ) ;    
//    AudioServicesAddSystemSoundCompletion( _sSBeepId, NULL, NULL, MyAudioServicesSystemSoundCompletionProc, (__bridge void *)(self) ) ;
//}


- (void)performBeep
{
    [[self audioPlayer] play];
}


- (void)startScanning
{
    if ( _startedScanning )
        return;

    if ( ! [[self class] supportsCamera] )
        return;
    
    if ( _session == nil )
    {
        // preparem la capture session
        {
            _session = [[AVCaptureSession alloc] init];
            [_session setSessionPreset:AVCaptureSessionPresetHigh];  // per defecte es aquest (permet zoom)
        }
        
        // preparem layers per la capture session
        {
            [_highlightLayer removeFromSuperlayer];
            [_prevLayer removeFromSuperlayer];
        
            UIView *selfView = self.view;
            CGRect bounds = selfView.bounds;
            _prevLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
            _prevLayer.frame = bounds;
            _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            [selfView.layer insertSublayer:_prevLayer atIndex:0];
        
            //[self sSBeepId] ;
            [self audioPlayer];
            [_overlay setShowProgress:YES orText:nil];
        }
        
        // preparem el output
        _output = [[AVCaptureMetadataOutput alloc] init];
        
        // ajustem el rect of interest
        [self sw_adjustRectOfInterest];

        // seleccionem la posicio de la camera (el layer i el output han d'estar inicialitzats)
        [self selectCameraPosition:_cameraPosition];
        
        // afegim el output a la sessio (ha de ser despres de seleccionar la camera)
        [_session addOutput:_output];
        
        // afegim els metadatatypes al output ( ha de ser despres de afegir l'output a la sessio)
        {
            NSMutableArray *objectTypes = [[_output availableMetadataObjectTypes] mutableCopy];
            [objectTypes removeObject:AVMetadataObjectTypeFace];  // <-- No ens interessa el recoinexement de cares.
            _output.metadataObjectTypes = objectTypes;
        }

        // el delegat del output som nosaltres mateixos
        if ( _scanQueue == nil )
            _scanQueue = dispatch_queue_create( NULL, DISPATCH_QUEUE_SERIAL);
        
        [_output setMetadataObjectsDelegate:self queue:_scanQueue /*dispatch_get_main_queue()*/];
        
        // ajustem la orientacio
        [self sw_rotatePreviewToInterfaceOrientation:[self interfaceOrientation]] ;

        // posem la sessio de captura en marxa
        [_session startRunning];
    }
    
    // activem el shutter
    [_overlay setShutterOn:NO animated:YES];
}


-(void)stopScanning
{
    if ( !_startedScanning )
        return;

    [_session stopRunning] ;
    _session = nil;
}


#pragma mark reader

- (void)didScanText:(NSString*)text
{
    [_overlay setShowProgress:NO orText:text];
    [self stopScanning];
    [_delegate codeScannerViewController:self didScanText:text] ;
}


- (void)didCancelWithError:(BOOL)err
{
    [_overlay setShowProgress:NO orText:nil] ;
    [self stopScanning];
    [_delegate codeScannerViewController:self didCancelWithError:err] ;
}


#pragma mark AVCaptureNotifications

- (void)avCaptureFailed:(NSNotification*)note
{
    [_overlay setShutterOn:YES animated:YES];
    _startedScanning = NO;
}

- (void)avCaptureStarted:(NSNotification*)note
{
    [_overlay setShutterOn:NO animated:YES];
    _startedScanning = YES;
}

- (void)avCaptureStoped:(NSNotification*)note
{
    [_overlay setShutterOn:YES animated:YES];
    _startedScanning = NO;
}


#pragma mark AVCaptureOutput delegate

//- (void)captureOutputV:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
//{
//    CGRect highlightViewRect = CGRectZero;
//    
//    AVMetadataMachineReadableCodeObject *barCodeObject;
//    NSString *detectionString = nil;
//
//    for (AVMetadataObject *metadata in metadataObjects)
//    {
//        barCodeObject = (id)[_prevLayer transformedMetadataObjectForMetadataObject:metadata];
//        highlightViewRect = barCodeObject.bounds;
//            
//        if ( [metadata isKindOfClass:[AVMetadataMachineReadableCodeObject class]] )
//        {
//            AVMetadataMachineReadableCodeObject *machineMetada = (id)metadata;
//            detectionString = [machineMetada stringValue];
//        }
//            
//        if ( [metadata isKindOfClass:[AVMetadataFaceObject class]] )  // no hauria de passar mai
//        {
//            AVMetadataFaceObject *faceMetadata = (id)metadata;
//            detectionString = [NSString stringWithFormat:@"yaw:%g roll:%g", faceMetadata.yawAngle, faceMetadata.rollAngle];
//        }
//
//        if (detectionString != nil)
//        {
//            break;
//        }
//    }
//    
//    
//    [self _endCapturingOutputAtRect:highlightViewRect detectionString:detectionString];
//    
////    [_highlightLayer removeFromSuperlayer];
////    _highlightLayer = [[CALayer alloc] init];
////    
////    _highlightLayer.borderColor = [UIColor greenColor].CGColor;
////    _highlightLayer.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2].CGColor;
////    _highlightLayer.borderWidth = 4;
////    
////    CGRect rect = highlightViewRect;
////    
////    CGRect bounds1 = rect;
////    bounds1.origin.x = 0;
////    bounds1.origin.y = 0;
////    if (bounds1.size.height < 40 ) bounds1.size.height = 40;
////    if (bounds1.size.width < 40 ) bounds1.size.width = 40;
////    
////    CGRect bounds0 = bounds1;
////    bounds0.size.height += 50;
////    bounds0.size.width += 50;
////
////    CGPoint center = CGPointMake( rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2 );
////    _highlightLayer.position = center ;
////    
////    [_prevLayer addSublayer:_highlightLayer];
////    
////    CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
////    boundsAnim.fromValue = [NSValue valueWithCGRect:bounds0];
////    boundsAnim.toValue = [NSValue valueWithCGRect:bounds1];
////    boundsAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
////    boundsAnim.duration = 0.2;
////    [_highlightLayer addAnimation:boundsAnim forKey:nil];
////    
////    [_overlay setShowProgress:NO orText:detectionString];
////    [self stopScanning];
////    
////    [self performBeep];  // beep despres de stopScanning, si no no sona
////    [self performSelector:@selector(didScanText:) withObject:detectionString afterDelay:0.3] ;  // esperem 0.3 segons per tenir temps de visualitzar la animacio final del shutter
//}




- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    AVMetadataMachineReadableCodeObject *capturedMetadata = nil;
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ( [metadata isKindOfClass:[AVMetadataMachineReadableCodeObject class]] )
        {
            capturedMetadata = (id)metadata;
            break;
        }
    }
    
    dispatch_async( dispatch_get_main_queue(), ^
    {
        [self _endCapturingOutputWithMetadataObject:capturedMetadata];
    });
}



- (void)_endCapturingOutputWithMetadataObject:(AVMetadataMachineReadableCodeObject*)metadata
{
    AVMetadataObject *barCodeObject = (id)[_prevLayer transformedMetadataObjectForMetadataObject:metadata];
    CGRect highlightViewRect = barCodeObject.bounds;
    
    NSString *detectionString = [metadata stringValue];

    [_highlightLayer removeFromSuperlayer];
    _highlightLayer = [[CALayer alloc] init];
    
    _highlightLayer.borderColor = [UIColor greenColor].CGColor;
    _highlightLayer.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2].CGColor;
    _highlightLayer.borderWidth = 4;
    
    CGRect rect = highlightViewRect;
    
    CGRect bounds1 = rect;
    bounds1.origin.x = 0;
    bounds1.origin.y = 0;
    if (bounds1.size.height < 40 ) bounds1.size.height = 40;
    if (bounds1.size.width < 40 ) bounds1.size.width = 40;
    
    CGRect bounds0 = bounds1;
    bounds0.size.height += 50;
    bounds0.size.width += 50;

    CGPoint center = CGPointMake( rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2 );
    _highlightLayer.position = center ;
    
    [_prevLayer addSublayer:_highlightLayer];
    
    CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnim.fromValue = [NSValue valueWithCGRect:bounds0];
    boundsAnim.toValue = [NSValue valueWithCGRect:bounds1];
    boundsAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
    boundsAnim.duration = 0.2;
    [_highlightLayer addAnimation:boundsAnim forKey:nil];
    
    [_overlay setShowProgress:NO orText:detectionString];
    [self stopScanning];
    
    [self performBeep];  // beep despres de stopScanning, si no no sona
    //[self performSelector:@selector(performBeep) withObject:nil afterDelay:0.0];
    [self performSelector:@selector(didScanText:) withObject:detectionString afterDelay:0.3] ;  // esperem 0.3 segons per tenir temps de visualitzar la animacio final del shutter
}




//- (void)_endCapturingOutputAtRect:(CGRect)highlightViewRect detectionString:(NSString*)detectionString
//{
//    [_highlightLayer removeFromSuperlayer];
//    _highlightLayer = [[CALayer alloc] init];
//    
//    _highlightLayer.borderColor = [UIColor greenColor].CGColor;
//    _highlightLayer.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.2].CGColor;
//    _highlightLayer.borderWidth = 4;
//    
//    CGRect rect = highlightViewRect;
//    
//    CGRect bounds1 = rect;
//    bounds1.origin.x = 0;
//    bounds1.origin.y = 0;
//    if (bounds1.size.height < 40 ) bounds1.size.height = 40;
//    if (bounds1.size.width < 40 ) bounds1.size.width = 40;
//    
//    CGRect bounds0 = bounds1;
//    bounds0.size.height += 50;
//    bounds0.size.width += 50;
//
//    CGPoint center = CGPointMake( rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2 );
//    _highlightLayer.position = center ;
//    
//    [_prevLayer addSublayer:_highlightLayer];
//    
//    CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
//    boundsAnim.fromValue = [NSValue valueWithCGRect:bounds0];
//    boundsAnim.toValue = [NSValue valueWithCGRect:bounds1];
//    boundsAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut] ;
//    boundsAnim.duration = 0.2;
//    [_highlightLayer addAnimation:boundsAnim forKey:nil];
//    
//    [_overlay setShowProgress:NO orText:detectionString];
//    [self stopScanning];
//    
//    [self performBeep];  // beep despres de stopScanning, si no no sona
//    [self performSelector:@selector(didScanText:) withObject:detectionString afterDelay:0.3] ;  // esperem 0.3 segons per tenir temps de visualitzar la animacio final del shutter
//}


#pragma mark ReaderOverlayDelegate

- (void)readerOverlayDidDismiss
{
    [self didCancelWithError:NO] ;
}


- (void)readerOverlayFlip
{
    [self flipCamera] ;
}


- (BOOL)shouldShowCameraPositionControl
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] ;
    return [devices count] > 1 ;
}


- (CGFloat)getFps ;
{
//    ZBarCaptureReader *captureReader = [reader captureReader] ;
//    return [captureReader framesPerSecond] ;

    return 1.2;
}

@end
