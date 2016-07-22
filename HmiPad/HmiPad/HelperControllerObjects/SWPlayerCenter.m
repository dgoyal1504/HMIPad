

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "SWPlayerCenter.h"
#import "SWKeyboardListener.h"

//#ifndef PlayListName
//    #define PlayListName "HMiPad"
//#endif

@interface TransparentToolbar : UIToolbar
@end

@implementation TransparentToolbar


-(id)initWithFrame:(CGRect)rect
{
    self = [super initWithFrame:rect] ;
    if ( self )
    {
        [self setBackgroundColor:[UIColor clearColor]] ;
    }
    return self ;
}

-(void)drawRect:(CGRect)rect
{
    //do nothing
}


@end


@interface SWPlayerCenter(private)
- (void)doRewind:(id)sender;
- (void)doPlay:(id)sender;
- (void)doClose:(id)sender;
@end


@interface SWPlayerView : UIView
{
    UIWindow *_window ;
    UIToolbar *toolbar ;
    UILabel *label ;
    __unsafe_unretained id delegate ;  //weak
}

- (void)show ;
- (void)hide ;
- (void)setPlaying:(BOOL)state ;

@end


@implementation SWPlayerView


- (id)initWithDelegate:(id)deleg
{
    const int width = 250 ;
    const int labelwidth = width-106 ;
    const int height1 = 44 ;
    const int height2 = 36 ;
	if ( (self = [super initWithFrame:CGRectMake(0, 0, width, height1+height2)]) )
    {
        NSArray *windows = [[UIApplication sharedApplication] windows] ;
        if ( [windows count] > 0 ) 
        {
            _window = [windows objectAtIndex:0] ;
        }
        else 
        {
            //ARC [self release] ;
            return nil ;
        }
    
        delegate = deleg ;
        self.backgroundColor = [UIColor clearColor];
        
        UIBarButtonItem *rewind = [[UIBarButtonItem alloc] 
            initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:delegate action:@selector(doRewind:)] ;
        [rewind setStyle:UIBarButtonItemStylePlain] ;
            
        UIBarButtonItem *play = [[UIBarButtonItem alloc] 
            initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:delegate action:@selector(doPlay:)] ;
        [play setStyle:UIBarButtonItemStylePlain] ;
            
        UIBarButtonItem *space = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:0] ;
            
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:0] ;
        [fixedSpace setWidth:4] ;
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,labelwidth,height1)];
        
        [label setTextColor:[UIColor whiteColor]] ;
        [label setShadowColor:[UIColor blackColor]] ;
        [label setShadowOffset:CGSizeMake(0, 1)] ;
        [label setBackgroundColor:[UIColor clearColor]] ;
        [label setTextAlignment:NSTextAlignmentCenter] ;
        [label setAdjustsFontSizeToFitWidth:YES] ;
        [label setFont:[UIFont boldSystemFontOfSize:19]] ;
        //[label setMinimumFontSize:13] ;
        [label setMinimumScaleFactor:0.6];
        
        UIBarButtonItem *name = [[UIBarButtonItem alloc] initWithCustomView:label] ;
        
        //UIBarButtonItem *name = [[UIBarButtonItem alloc]
        //    initWithTitle:@"playing" style:UIBarButtonItemStylePlain target:nil action:0] ;
            
        UIBarButtonItem *close = [[UIBarButtonItem alloc] 
            initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:delegate action:@selector(doClose:)] ;
        [close setStyle:UIBarButtonItemStylePlain] ;
        
    
        toolbar = [[TransparentToolbar alloc] initWithFrame:CGRectMake(0,0,width,height1)] ;
        [toolbar setItems:[NSArray arrayWithObjects:rewind,fixedSpace,play,space,name,space,close,nil]] ;       
        //ARC[rewind release] ;
        //ARC[play release] ;
        //ARC[name release] ;
        //ARC[space release] ;
        //ARC[fixedSpace release] ;
        //ARC[close release] ;

        [self addSubview:toolbar] ;
        
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10,height1,width-20,height2)] ;
        [self addSubview:volumeView] ;
        //ARC[volumeView release] ;
    }
	return self;	
}

- (void)dealloc
{
    //ARC[toolbar release] ;
    //ARC[label release] ;
    //ARC[super dealloc] ;
}


- (void)drawRoundRectangleInRect:(CGRect)rect withRadius:(CGFloat)radius
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rrect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );

	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFill);
}


- (void)drawRect:(CGRect)rect
{
	[[UIColor colorWithWhite:0 alpha:0.8] set];
	[self drawRoundRectangleInRect:rect withRadius:10];
}


static CGRect subtractRect(CGRect wf,CGRect kf)
{    
	if( ! CGPointEqualToPoint(CGPointZero,kf.origin) )
    {
		if( kf.origin.x > 0 ) kf.size.width = kf.origin.x;
		if( kf.origin.y > 0 ) kf.size.height = kf.origin.y;
		kf.origin = CGPointZero;
	}
    else
    {
		kf.origin.x = fabsf(kf.size.width - wf.size.width);
		kf.origin.y = fabsf(kf.size.height - wf.size.height);
    
		if ( kf.origin.x > 0 )
        {
			CGFloat temp = kf.origin.x;
			kf.origin.x = kf.size.width;
			kf.size.width = temp;
		}
        
        if ( kf.origin.y > 0 )
        {
			CGFloat temp = kf.origin.y;
			kf.origin.y = kf.size.height;
			kf.size.height = temp;
		}
	}
    return kf ;
	//return CGRectIntersection(wf, kf);
}



- (void)adjustOrientationTo7:(UIInterfaceOrientation)o alpha:(CGFloat)alpha factor:(CGFloat)factor
{
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance] ;
    CGRect kf = [keyb frame] ;
    //CGRect wf = [UIApplication sharedApplication].keyWindow.bounds;
    CGRect wf = [_window bounds];
    
    wf = subtractRect(wf,kf); ;

    CGFloat edge = 65 + ([keyb isVisible] ? 0 : 60) ;
    CGPoint center = CGPointMake(roundf(wf.origin.x+wf.size.width/2),roundf(wf.origin.y+wf.size.height/2)) ;
    CGFloat degrees ;
    
    if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90, center.x=wf.size.width-wf.origin.x-edge;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90, center.x=wf.origin.x+edge;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180, center.y=wf.origin.y+edge ;
    else degrees = 0, center.y = wf.size.height-wf.origin.y-edge ;
    
    self.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    self.transform = CGAffineTransformScale(self.transform, factor, factor);
    
    self.center = center ;
    self.alpha = alpha ;
}


- (void)adjust8ToAlpha:(CGFloat)alpha factor:(CGFloat)factor
{
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance] ;
    CGFloat kh = [keyb offset] ;
    CGRect wf = [_window bounds];

    CGFloat edge = 65 + ([keyb isVisible] ? 0 : 60) ;
    CGPoint center = CGPointMake( roundf(wf.size.width/2), roundf((wf.size.height-kh)/2) ) ;
    center.y = wf.size.height-edge ;
    
    self.transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformScale(self.transform, factor, factor);
    
    self.center = center ;
    self.alpha = alpha ;
}


- (void)adjustOrientationTo:(UIInterfaceOrientation)o alpha:(CGFloat)alpha factor:(CGFloat)factor
{
    if ( IS_IOS8 )
        [self adjust8ToAlpha:alpha factor:factor];
    else
        [self adjustOrientationTo7:o alpha:alpha factor:factor];
}


- (void)show
{
//    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [_window addSubview:self] ;
}

- (void)hide
{
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    [UIView animateWithDuration:0.15 
    animations:^
    {
        [self adjustOrientationTo:o alpha:0 factor:0.5];
    } 
    completion:^(BOOL finished) 
    {
        [self removeFromSuperview] ;
    }] ;
}



- (void)replaceToolbarItemAtIndex:(int)indx withItem:(UIBarButtonItem *)item
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[toolbar items]] ;
    [items replaceObjectAtIndex:indx withObject:item] ;
    [toolbar setItems:items] ;
    //ARC[items release] ;
}


- (void)setPlaying:(BOOL)state
{
    UIBarButtonSystemItem type = state ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay ;
    UIBarButtonItem *play = [[UIBarButtonItem alloc] 
        initWithBarButtonSystemItem:type target:delegate action:@selector(doPlay:)] ;
    [play setStyle:UIBarButtonItemStylePlain] ;
    [self replaceToolbarItemAtIndex:2 withItem:play] ;
    //ARC[play release] ;
}

- (void)setLabelText:(NSString *)text
{
    [label setText:text] ;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if ( newSuperview == nil )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
        [nc removeObserver:self] ;
    }
    else if ( newSuperview != [self superview] )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
        [nc addObserver:self selector:@selector(keyboardWillAppear:) name:SWKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardWillDisappear:) name:SWKeyboardWillHideNotification object:nil];
        [nc addObserver:self selector:@selector(orientationWillChange:) 
                name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

        UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;        
        [self adjustOrientationTo:o alpha:0 factor:2] ;
        [UIView animateWithDuration:0.15 animations:
        ^{
            [self adjustOrientationTo:o alpha:1 factor:1] ;
        }] ;
    }
}


- (void)keyboardWillAppear:(NSNotification *)notification 
{
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    [UIView animateWithDuration:0.3 animations:
    ^{
         [self adjustOrientationTo:o alpha:1 factor:1] ;
    }] ;
}


- (void)keyboardWillDisappear:(NSNotification *) notification 
{
    UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
    [UIView animateWithDuration:0.3 animations:
    ^{
        [self adjustOrientationTo:o alpha:1 factor:1] ;
    }] ;
    
}
    

- (void)orientationWillChange:(NSNotification *) notification 
{
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *v = [userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
	UIInterfaceOrientation o = [v intValue];
    CGFloat duration = 0.3 ;
	
	[UIView animateWithDuration:duration animations:
    ^{
        [self adjustOrientationTo:o alpha:1 factor:1] ;
    }] ;
}



@end



@interface SWPlayerCenter()
{
	BOOL _active;
	SWPlayerView *playerView;
    AVPlayer *userPlayer ;
    NSString *playerText ;
}

@end


NSString *SWPlayerCenterErrorNotification = @"SWPlayerCenterErrorNotification";
NSString *SWPlayerCenterErrorKey = @"error";

#pragma mark -
@implementation SWPlayerCenter

#pragma mark Init & Friends
+ (SWPlayerCenter*) defaultCenter 
{
	static SWPlayerCenter *defaultCenter = nil;
	if (!defaultCenter) 
    {
		defaultCenter = [[SWPlayerCenter alloc] init];
	}
	return defaultCenter;
}


- (id)init
{
	if( (self=[super init]) )
    {

    }
	return self;
}


- (void)displayErrorText:(NSString*)errStr
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:SWPlayerCenterErrorNotification object:self userInfo:@{SWPlayerCenterErrorKey:errStr}];
}


- (void)maybeShowPlayerView
{
    if ( playerView == nil ) 
    {
        playerView = [[SWPlayerView alloc] initWithDelegate:self];
        [playerView show] ;
        [playerView setPlaying:(userPlayer && [userPlayer rate] != 0)] ;
    }
    [playerView setLabelText:playerText] ;
}

- (void)maybeHidePlayerView
{
    if ( playerView == nil ) return ;
    [playerView hide] ;
    //ARC[playerView release] ;
    playerView = nil ;
}

- (void)setPlayerText:(NSString*)text
{
    /*//ARC
    if ( text != playerText )
    {
        [playerText release] ;
        playerText = [text retain] ;
    }*/
    playerText = text ;
}

static const NSString *ItemStatusContext;

- (void)maybeInitPlayerWithItem:(AVPlayerItem*)playerItem
{
    if ( userPlayer ) return ; 
    userPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [userPlayer setActionAtItemEnd:AVPlayerActionAtItemEndNone] ; // default es aparentment AVPlayerActionAtItemEndPause lo que fa fallar el didplaytoend
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc addObserver:self selector:@selector(didPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [nc addObserver:self selector:@selector(failedToPlay:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [userPlayer addObserver:self forKeyPath:@"status" options:0 /*NSKeyValueObservingOptionNew*/ context:&ItemStatusContext] ;
    [userPlayer addObserver:self forKeyPath:@"rate" options:0 /*NSKeyValueObservingOptionNew*/ context:&ItemStatusContext] ;
    [userPlayer addObserver:self forKeyPath:@"currentItem" options:0 /*NSKeyValueObservingOptionNew*/ context:&ItemStatusContext] ;
}

- (void)maybeDeletePlayer
{
    if ( userPlayer == nil ) return ;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
    [nc removeObserver:self] ;
    [userPlayer removeObserver:self forKeyPath:@"status"] ;
    [userPlayer removeObserver:self forKeyPath:@"rate"] ;
    [userPlayer removeObserver:self forKeyPath:@"currentItem"] ;
    [userPlayer pause] ;
    //ARC[userPlayer release] ;
    userPlayer = nil ;
}

- (void)doPlayPlayerItem:(AVPlayerItem*)playerItem
{
    if ( userPlayer == nil && playerItem )  // start
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance] ;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil] ;
        //[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil] ;
        
        /* Pick any one of them */
        // 1. Overriding the output audio route
        //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        //AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
     
        // 2. Changing the default output audio route
        //UInt32 doChangeDefaultRoute = 1;
        //AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
        
        //NSLog( @"---Starting playing userPlayer" ) ;
        [self maybeInitPlayerWithItem:playerItem] ;
        [userPlayer setRate:1] ;
    }
    else if ( userPlayer && playerItem == nil )  // stop
    {
        //NSLog( @"---Stopping playing userPlayer" ) ;
        [self maybeHidePlayerView] ;
        [self maybeDeletePlayer] ;
    }
    else if ( userPlayer && playerItem )  // stop + start
    {
        //NSLog( @"---Replacing playing userPlayer" ) ;
        
        // el canvi de playerItem no avisa de null si no es playable AVPlayer Bug?
        // [userPlayer replaceCurrentItemWithPlayerItem:playerItem] ;  
        // workaround: eliminant i tornant a crear el player sembla que funciona
        [self maybeDeletePlayer] ;
        [self maybeInitPlayerWithItem:playerItem] ;
        [userPlayer setRate:1] ;
    }
}

- (void)playSoundTextUrl:(NSString*)textUrl labelText:(NSString*)text
{
    __block NSURL *soundURL = nil ;
    [self setPlayerText:text] ;
    
    //soundURL = [[NSBundle mainBundle] URLForResource:@"Alarm" withExtension:@"caf"];    // treu treu
    //textUrl = nil ;                                                                     // treu treu
    
    if ( textUrl.length )
    {
        NSString *audioName = [textUrl lastPathComponent] ;
        if ( [playerText length] == 0 ) [self setPlayerText:audioName] ;
        
        //NSLog( @"want to play: %@", audioName ) ;
        
        NSStringCompareOptions options = NSCaseInsensitiveSearch | NSAnchoredSearch ;
        NSRange range1 = [textUrl rangeOfString:@"ipod-library://" options:options] ;
        NSRange range2 = [textUrl rangeOfString:@"http://" options:options] ;
        NSRange range3 = [textUrl rangeOfString:@"https://" options:options] ;
        if ( range1.length )
        {
    
            NSString *playList = @PlayListName ;
            //playList = @"sss" ;
            
            MPMediaPropertyPredicate *playListPredicate = [MPMediaPropertyPredicate
                predicateWithValue:playList forProperty:MPMediaPlaylistPropertyName] ;
            
            MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate 
                 predicateWithValue:audioName forProperty:MPMediaItemPropertyTitle] ;
                 
            //MPMediaPropertyPredicate *titlePredicate = [MPMediaPropertyPredicate 
            //     predicateWithValue:@"30_Sec_Various-twist_my_hips_INST_01" forProperty:MPMediaItemPropertyTitle] ;
            
            NSSet *propertyPredicatesSet = [NSSet setWithObjects:titlePredicate, playListPredicate ,nil] ;
    
            MPMediaQuery *playListQuery = [[MPMediaQuery alloc] init];
            [playListQuery setGroupingType:MPMediaGroupingPlaylist] ;
            [playListQuery setFilterPredicates:propertyPredicatesSet] ;
    
 
            // Obtain the media item collections from the query
            NSArray *collections = [playListQuery collections];
            NSArray *mediaItems = [playListQuery items] ;
            //ARC[playListQuery release] ;
    
    
            NSSet *properties = [NSSet setWithObjects:
                //MPMediaItemPropertyPersistentID, 
                //MPMediaItemPropertyAlbumTitle, 
                //MPMediaItemPropertyTitle, 
                MPMediaItemPropertyAssetURL,
                nil] ;
        
  
            if ( [collections count] == 0 ) 
            {
                NSString *format = NSLocalizedString(@"PlayListNotFound%@", nil) ;
                NSString *errStr = [NSString stringWithFormat:format, playList] ;
                //[model() alarmListAddSystemAlarmWithGroup:@"AUDIO" text:errStr] ;
                [self displayErrorText:errStr] ;
                return ;
            }
            
            /*
            for ( MPMediaItemCollection *collection in collections )
            {
                NSLog( @"Collection: %@", collection ) ;
                NSArray *mediaItems = [collection items] ;
                
                if ( [mediaItems count] == 0 ) 
                {
                    NSString *errStr = [NSString stringWithFormat:@"Item %@ not found on the %@ playlist of the iPod-Library", audioName, playList] ;
                    [model() alarmListAddSystemAlarmWithGroup:@"AUDIO" text:errStr] ;
                    return ;
                }
                
                for ( MPMediaItem *mediaItem in mediaItems )
                {
                    NSLog( @"  MediaITem: %@", mediaItem ) ;
                    [mediaItem enumerateValuesForProperties:properties usingBlock:
                    ^(NSString *property, id value, BOOL *stop) 
                    {
                        NSLog( @"    Property %@ %@", property, value ) ;
                        if ( property == MPMediaItemPropertyAssetURL )
                        {
                            soundURL = [value retain] ;
                            *stop = YES ;
                        }
                    }] ;
                    [soundURL autorelease] ;
                }
            
                if ( soundURL == nil )
                {
                    NSString *errStr = [NSString stringWithFormat:@"%@ from the iPod-Library is FairPlay protected or not playabe by this app", audioName] ;
                    [model() alarmListAddSystemAlarmWithGroup:@"AUDIO" text:errStr] ;
                    return ;
                }
            }
            */
            
            
            if ( [mediaItems count] == 0 ) 
            {
                
                NSString *format = NSLocalizedString(@"Audio%@NotFoundInPlaylist%@", nil) ;
                NSString *errStr = [NSString stringWithFormat:format, audioName, playList] ;
                [self displayErrorText:errStr] ;
                return ;
            }
            
            for ( MPMediaItem *mediaItem in mediaItems )
            {
                //NSLog( @"  MediaITem: %@", mediaItem ) ;
                [mediaItem enumerateValuesForProperties:properties usingBlock:
                ^(NSString *property, id value, BOOL *stop) 
                {
                    //NSLog( @"    Property %@ %@", property, value ) ;
                    if ( property == MPMediaItemPropertyAssetURL )
                    {
                        //ARCsoundURL = [value retain] ;
                        soundURL = value ;
                        *stop = YES ;
                    }
                }] ;
                //ARC[soundURL autorelease] ;
            }
            
            if ( soundURL == nil )
            {
            
                NSString *format = NSLocalizedString(@"Audio%@NotPlayable", nil) ;
                NSString *errStr = [NSString stringWithFormat:format, audioName] ;
                [self displayErrorText:errStr] ;
                return ;
            }
        }
    
        
        if ( range2.length || range3.length ) 
        {
            NSString *fullPath = [textUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
            soundURL = [NSURL URLWithString:fullPath] ;
        }
    
        else
        {
            //soundURL = [NSURL URLWithString:textUrl] ;
            NSFileManager *fm = [NSFileManager defaultManager] ;
            if ( [fm fileExistsAtPath:textUrl] ) 
            {
                soundURL = [NSURL fileURLWithPath:textUrl] ;
            }
            
            if ( soundURL == nil )
            {
            
                NSString *format = NSLocalizedString(@"AudioFile%@NotFound", nil) ;
                NSString *errStr = [NSString stringWithFormat:format, audioName] ;
                [self displayErrorText:errStr] ;
                return ;
            }
        }
    }

    AVPlayerItem *playerItem = nil ;
    if ( soundURL ) playerItem = [[AVPlayerItem alloc] initWithURL:soundURL] ;

    [self doPlayPlayerItem:playerItem] ; // si es null el cancela
    //ARC[playerItem release] ;
}


- (void)setVisible:(BOOL)state
{
    if ( state && userPlayer ) [self maybeShowPlayerView] ;
    else if ( !state && playerView ) [self maybeHidePlayerView] ;
}

- (void)setRepeat:(BOOL)state
{
    repeat = state ;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
    //ARC[playerView release] ;
    //ARC[userPlayer release] ;
    //ARC[playerText release] ;
    //ARC[super dealloc] ;
}



#pragma mark notificacions del playerItem


- (void)didPlayToEnd:(NSNotification*)note
{
    dispatch_async(dispatch_get_main_queue(), 
    ^{
        if ( repeat )
        {
            CMTime startTime = CMTimeMake(0, 1);
            [userPlayer seekToTime:startTime] ;
            [userPlayer setRate:1] ;
        }
        else
        {
            [self maybeHidePlayerView] ;
            [self maybeDeletePlayer] ;
        }
    }) ;
}

- (void)failedToPlay:(NSNotification*)note
{
    //NSLog( @"failed to play" ) ;
    dispatch_async(dispatch_get_main_queue(), 
    ^{
        [self maybeHidePlayerView] ;
        [self maybeDeletePlayer] ;
    }) ;
}

#pragma mark delegats del playerView

- (void)doRewind:(id)sender
{
    //NSLog( @"doRewind" ) ;
    CMTime startTime = CMTimeMake(0, 1);
    [userPlayer seekToTime:startTime] ;
}

- (void)doPlay:(id)sender
{
    //NSLog( @"doPlay" ) ;
    float newRate = [userPlayer rate] == 0 ? 1 : 0 ;
    [userPlayer setRate:newRate] ;
}

- (void)doClose:(id)sender
{
    //NSLog( @"doClose" ) ;
    [self maybeHidePlayerView] ;
    [self maybeDeletePlayer] ;
}


#pragma mark observacio de la propietat state

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context 
{
    //NSLog( @"ItemStatusContext %x, %x", (unsigned)&ItemStatusContext, (unsigned)ItemStatusContext ) ;
    if (context == &ItemStatusContext ) 
    {
        void (^block)(void) = ^
        {
            AVPlayer *thePlayer = (AVPlayer *)object;
            if ( [keyPath isEqualToString:@"status"] )
            {
                //NSLog( @"theStatus:%d", [thePlayer status] ) ;
                AVPlayerStatus status = [thePlayer status] ;
                if ( status == AVPlayerStatusReadyToPlay ) 
                {
                    [self maybeShowPlayerView] ;
                }
            
                else if ( status == AVPlayerStatusFailed ) 
                {
                    [self maybeHidePlayerView] ;
                    [self maybeDeletePlayer] ;
                    NSString *format = NSLocalizedString(@"Audio%@NotFound", nil) ;
                    NSString *errStr = [NSString stringWithFormat:format, playerText] ;
                    [self displayErrorText:errStr] ;
                    // Respond to error: for example, display an alert sheet.
                }
                // Deal with other status change if appropriate.
            }
            else if ( [keyPath isEqualToString:@"rate"] ) 
            {
                //NSLog( @"theRate:%f", [thePlayer rate] ) ;
                BOOL playing = [thePlayer rate] != 0 ;
                [playerView setPlaying:playing] ;
            }
            
            else if ( [keyPath isEqualToString:@"currentItem"] ) 
            {
                //NSLog( @"currentItem:%@", [thePlayer currentItem] ) ;
                if ( [thePlayer currentItem] == nil )
                {
                    [self maybeHidePlayerView] ;
                    [self maybeDeletePlayer] ;
                    NSString *format = NSLocalizedString(@"Audio%@NotFound", nil) ;
                    NSString *errStr = [NSString stringWithFormat:format, playerText] ;
                    [self displayErrorText:errStr] ;
                }
            }
        } ;
    
        dispatch_queue_t dQueue = dispatch_get_main_queue() ;
//        if ( dispatch_get_current_queue() == dQueue ) block() ;
//        else
        dispatch_async( dQueue, block ) ;  // no esta clar que aixo sigui necesari
    }
    
    // Deal with other change notifications if appropriate.
    //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


@end