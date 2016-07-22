//
//  SWThumbnail.m
//  HmiPad
//
//  Created by Joan on 01/04/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWThumbnail.h"


#import "SWImageManager.h"
#import "CALayer+ScreenShot.h"
//#import "UIImage+Resize.h"
#import "Drawing.h"
#import "SWColor.h"


#import "ColoredButton.h"
#import "RoundedTextView.h"
#import "SWKnobControl.h"
#import "SWBarLevelView.h"
#import "SWHPIndicatorView.h"
#import "SWTrendView.h"
#import "SWScaleView.h"
#import "SWGaugeView.h"
#import "SWLampView.h"



NSString *SWThumbnailSwitch = @"SWThumbnailSwitch";
NSString *SWThumbnailSegmented = @"SWThumbnailSegmented";
NSString *SWThumbnailColoredButton = @"SWThumbnailColoredButton";
NSString *SWThumbnailArrayPicker = @"SWThumbnailArrayPicker";
NSString *SWThumbnailDictionaryPicker = @"SWThumbnailDictionaryPicker";
NSString *SWThumbnailSlider = @"SWThumbnailSlider";
NSString *SWThumbnailKnob = @"SWThumbnailKnob";
NSString *SWThumbnailTapGesture = @"SWThumbnailTapGesture";

NSString *SWThumbnailTextField = @"SWThumbnailTextField";
NSString *SWThumbnailTextView = @"SWThumbnailTextView";
NSString *SWThumbnailNumberField = @"SWThumbnailNumberField";

NSString *SWThumbnailLabel = @"SWThumbnailLabel";
NSString *SWThumbnailBar = @"SWThumbnailBar";
NSString *SWThumbnailHPIndicator = @"SWThumbnailHPIndicator";
NSString *SWThumbnailTrend = @"SWThumbnailTrend";
NSString *SWThumbnailChart = @"SWThumbnailChart";
NSString *SWThumbnailScale = @"SWThumbnailScale";
NSString *SWThumbnailGauge = @"SWThumbnailGauge";
NSString *SWThumbnailLamp = @"SWThumbnailLamp";
NSString *SWThumbnailHPipe = @"SWThumbnailHPipe";
NSString *SWThumbnailVPipe = @"SWThumbnailVPipe";


@interface SWThumbnail()<SWTrendViewDataSource>
{
    CGSize _size;
    UInt32 _rgb;
    UIImage *_placeholderImage;
}
@end


@implementation SWThumbnail

- (id)initWithDefaultSize:(CGSize)size defaultRgb:(UInt32)rgb;
{
    self = [super init];
    if ( self )
    {
        _size = size;
        _rgb = rgb;
    }
    return self;
}



- (UIImage *)placeholderImage
{
    if ( _placeholderImage == nil )
    {
        CGFloat radius = 5;
        radius = 0;
        UIColor *color = [UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1];
        UIImage *image = glossyImageWithSizeAndColor( _size, [color CGColor], NO, NO, radius, 1 );
        //image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, radius+1, 0, radius+1)];
        _placeholderImage = image;
    }
    return _placeholderImage;
}


static NSString const *ThumbNailChart = @"ThumbNailChart";
static NSString const *ThumbNailTrend = @"ThumbNailTrend";

- (void)imageWithKey:(NSString*)imageKey completion:(void (^)(UIImage* image))block
{
    UIView *view = nil;
    //UIViewContentMode contentMode = UIViewContentModeScaleAspectFit;
    
    if ( [imageKey isEqualToString:SWThumbnailSwitch] )
    {
        CGRect viewFrame = CGRectMake(0,0,70,40);
        UIView *sView = [[UIView alloc] initWithFrame:viewFrame];
        UISwitch *switchv = [[UISwitch alloc] init];
        CGRect frame = switchv.bounds;
        frame.origin.x = round((viewFrame.size.width-frame.size.width)/2);
        frame.origin.y = round((viewFrame.size.height-frame.size.height)/2);
        switchv.frame = frame;
        [switchv setOn:YES];
        [switchv setOnTintColor:UIColorWithRgb(_rgb)];
        [sView addSubview:switchv];
        view = sView;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailSegmented] )
    {
        UISegmentedControl *segmented = [[UISegmentedControl alloc] initWithItems:@[@"ONE", @"TWO"] ];
        [segmented setFrame:CGRectMake(0, 0, 120, 40)];
        //[segmented setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segmented setTintColor:UIColorWithRgb(_rgb)];
        [segmented setSelectedSegmentIndex:0];
        view = segmented;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailColoredButton] )
    {        
        ColoredButton *button = [[ColoredButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        [button setTitle:NSLocalizedString(@"Button", nil) forState:UIControlStateNormal];
        [button setRgbTintColor:_rgb overWhite:NO];
        view = button;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailArrayPicker] )
    {        
        ColoredButton *button = [[ColoredButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        [button setTitle:NSLocalizedString(@"Element", nil) forState:UIControlStateNormal];
        [button setRgbTintColor:_rgb overWhite:NO];
        view = button;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailDictionaryPicker] )
    {        
        ColoredButton *button = [[ColoredButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        [button setTitle:NSLocalizedString(@"Key", nil) forState:UIControlStateNormal];
        [button setRgbTintColor:_rgb overWhite:NO];
        view = button;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailTapGesture] )
    {
        UIView *tView = [[UIView alloc] initWithFrame:CGRectMake(0,0,40,40)];
        tView.backgroundColor = UIColorWithRgb(_rgb);
        view = tView;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailSlider] )
    {
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        [slider setValue:0.66];
        [slider setMinimumTrackTintColor:UIColorWithRgb(_rgb)];
        view = slider;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailKnob] )
    {
        SWKnobControl *knob = [[SWKnobControl alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        [knob setRange:SWRangeMake(0, 10) animated:NO];
        [knob setValue:3 animated:NO];
        [knob setMajorTickInterval:1];
        [knob setFormat:@"%g"];
        [knob setThumbStyle:SWKnobThumbStyleSegment];
        [knob setBorderColor:[UIColor blackColor]];
        [knob setBackgroundColor:UIColorWithRgb(SystemClearWhiteColor)];
        view = knob;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailTextField] )
    {
        RoundedTextView  *textField = [[RoundedTextView alloc] initWithFrame:CGRectMake(0, 0, 90, 36)];
        UITextView* textView = textField.textView;
        [textField setText:NSLocalizedString(@"abc", nil)];
        [textView setFont:[UIFont boldSystemFontOfSize:18]];
        [textView setTextColor:UIColorWithRgb(_rgb)];
        [textView setTextAlignment:NSTextAlignmentCenter];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        view = textField;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailTextView] )
    {
        RoundedTextView  *textField = [[RoundedTextView alloc] initWithFrame:CGRectMake(0, 0, 90, 36)];
        UITextView* textView = textField.textView;
        [textField setText:NSLocalizedString(@"abc abc", nil)];
        [textView setFont:[UIFont boldSystemFontOfSize:18]];
        [textView setTextColor:UIColorWithRgb(_rgb)];
        [textView setTextAlignment:NSTextAlignmentCenter];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        view = textField;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailNumberField] )
    {
        RoundedTextView *textField = [[RoundedTextView alloc] initWithFrame:CGRectMake(0, 0, 90, 36)];
        UITextView* textView = textField.textView;
        [textField setText:NSLocalizedString(@"123", nil)];
        [textView setFont:[UIFont boldSystemFontOfSize:18]];
        [textView setTextColor:UIColorWithRgb(_rgb)];
        [textView setTextAlignment:NSTextAlignmentCenter];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        view = textField;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailLabel] )
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 36)];
        [label setText:NSLocalizedString(@"Label", nil)];
        [label setFont:[UIFont boldSystemFontOfSize:18]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:UIColorWithRgb(_rgb)];
        view = label;
    }
        
    else if ( [imageKey isEqualToString:SWThumbnailBar] )
    {
        SWBarLevelView *barLevel = [[SWBarLevelView alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
        [barLevel setBarColor:UIColorWithRgb(BarDefaultColor)];
        [barLevel setTintsColor:[UIColor lightGrayColor]];
        [barLevel setBorderColor:[UIColor darkGrayColor]];
        [barLevel setDirection:SWDirectionRight];
        [barLevel setBackgroundColor:UIColorWithRgb(SystemClearWhiteColor)];
        [barLevel setRange:SWRangeMake(0, 1) animated:NO];
        [barLevel setValue:0.66 animated:NO];
        view = barLevel;
    }
    
        else if ( [imageKey isEqualToString:SWThumbnailHPIndicator] )
    {
        SWHPIndicatorView *hpIndicator = [[SWHPIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
        [hpIndicator setNeedleColor:UIColorWithRgb(BarDefaultColor)];
        [hpIndicator setTintsColor:[UIColor lightGrayColor]];
        [hpIndicator setBorderColor:[UIColor darkGrayColor]];
        [hpIndicator setDirection:SWDirectionRight];
        [hpIndicator setBackgroundColor:UIColorWithRgb(SystemClearWhiteColor)];
        [hpIndicator setRange:SWRangeMake(0, 1) animated:NO];
        
        const int count = 2;
        NSMutableData *rangesData = [NSMutableData dataWithCapacity:count*sizeof(SWValueRange)];
        [rangesData setLength:count*sizeof(SWValueRange)];
        SWValueRange *cRanges = [rangesData mutableBytes];
        cRanges[0] = SWValueRangeMake(0.0, 0.15);
        cRanges[1] = SWValueRangeMake(0.85, 1.0);
        [hpIndicator setRanges:rangesData];
        
        [hpIndicator setValue:0.66 animated:NO];
        view = hpIndicator;
    }
        
    else if ( [imageKey isEqualToString:SWThumbnailTrend] )
    {
        //SWTrendView *trend = [[SWTrendView alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
        SWTrendView *trend = [[SWTrendView alloc] initWithFrame:CGRectMake(0, 0, 80, 70)];
        [trend setDataSource:self];
        [trend setYAxisRange:SWBoundsMake(0, 100) animated:NO];
        //double time = CFAbsoluteTimeGetCurrent();
        //[trend setXAxisRange:SWPlotRangeMake(time, time+30) animated:NO];
        [trend setXRangeOffset:0.01];
        [trend setXPlotInterval:8];
        [trend setXMajorTickInterval:5];
        [trend setYMajorTickInterval:25];
        [trend setYMinorTicksPerInterval:0];
        [trend setXMinorTicksPerInterval:0];
        [trend setTintsColor:[UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f]];
        [trend setBorderColor:[UIColor blackColor]];
        [trend setBackgroundColor:UIColorWithRgb(SystemClearWhiteColor)];
        
        id ident = ThumbNailTrend;
        [trend addPlotWithIdentifier:ident];
        [trend setYRange:SWBoundsMake(0, 100) forPlotWithIdentifier:ident animated:NO];
        //[trend setXRangeForPlotWithIdentifier:ident animated:NO];
        [trend reloadPlotsAnimated:NO];
        [trend setColor:[UIColor redColor] forPlotWithIdentifier:ident];
        view = trend;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailChart] )
    {
        //SWTrendView *trend = [[SWTrendView alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
        SWTrendView *trend = [[SWTrendView alloc] initWithFrame:CGRectMake(0, 0, 80, 70)];
        [trend setDataSource:self];
        [trend setYAxisRange:SWBoundsMake(0, 100) animated:NO];
        //double time = CFAbsoluteTimeGetCurrent();
        //[trend setXAxisRange:SWPlotRangeMake(time, time+30) animated:NO];
        double xStart = 0;
        [trend setXAxisRange:SWPlotRangeMake(xStart, xStart+4) animated:NO];
        [trend setXMajorTickInterval:1];
        [trend setYMajorTickInterval:25];
        [trend setYMinorTicksPerInterval:0];
        [trend setXMinorTicksPerInterval:0];
        [trend setTintsColor:[UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f]];
        [trend setBorderColor:[UIColor blackColor]];
        [trend setBackgroundColor:UIColorWithRgb(SystemClearWhiteColor)];
        
        id ident = ThumbNailChart;
        [trend addPlotWithIdentifier:ident];
        [trend setYRange:SWBoundsMake(0, 100) forPlotWithIdentifier:ident animated:NO];
        //[trend setXRangeForPlotWithIdentifier:ident animated:NO];
        [trend reloadPlotsAnimated:NO];
        [trend setColor:[UIColor blueColor] forPlotWithIdentifier:ident];
        [trend setSymbol:YES forPlotWithIdentifier:ident];
        view = trend;
    }
    
    else if ( [imageKey isEqualToString:SWThumbnailScale] )
    {
        SWScaleView *scale = [[SWScaleView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [scale setOrientation:SWOrientationRight];
        [scale setRange:SWRangeMake(0, 4) animated:NO];
        [scale setFormat:@"%0.1f"];
        [scale setMajorTickInterval:1];
        [scale setMinorTicksPerInterval:2];
        [scale setBackgroundColor:UIColorWithRgb(SystemClearWhiteColor)];
        view = scale;
    }
        
    else if ( [imageKey isEqualToString:SWThumbnailGauge] )
    {
        SWGaugeView *gauge = [[SWGaugeView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        [gauge setRange:SWRangeMake(0, 10) animated:NO];
        [gauge setValue:3 animated:NO];
        [gauge setMajorTickInterval:1];
        [gauge setFormat:@"%g"];
        [gauge setBorderColor:[UIColor blackColor]];
        [gauge setBackgroundColor:UIColorWithRgb(SystemClearWhiteColor)];
        view = gauge;
    }
        
    else if ( [imageKey isEqualToString:SWThumbnailLamp] )
    {
        SWLampView *lamp = [[SWLampView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [lamp setColor:UIColorWithRgb(TheNiceGreenColor)];
        [lamp setValue:YES animated:NO];
        [lamp setBackgroundColor:UIColorWithRgb(SystemClearWhiteColor)];
        view = lamp;
    }    
    
    else if ( [imageKey isEqualToString:SWThumbnailHPipe] )
    {
        UIView *hPipe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 4)];
        [hPipe setBackgroundColor:[UIColor grayColor]];
        view = hPipe;
    }    
    
    else if ( [imageKey isEqualToString:SWThumbnailVPipe] )
    {
        UIView *vPipe = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 40)];
        [vPipe setBackgroundColor:[UIColor grayColor]];
        view = vPipe;
    }

    if ( view )
    {
        SWImageManager *imageManager = [SWImageManager defaultManager];
        [imageManager makeThumbnailImageFromView:view uuid:imageKey size:_size radius:0
            contentMode:UIViewContentModeScaleAspectFit options:SWImageManagerProcessingOptionsOffLineRendering
            cancelBlock:nil completionBlock:block];
    }
    else
    {
        UIImage *image = [UIImage imageNamed:imageKey];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        if ( block ) block(image);
    }
}


- (NSData*)pointsForPlotWithIdentifier:(id)ident inRange:(SWPlotRange)range
{
    CFAbsoluteTime time = range.min;
    SWPlotPoint points[] =
    {
        {time+0, 25},
        {time+2, 75},
        {time+4, 20},
        {time+6, 50},
        {time+8, 50},
    };
    return [NSData dataWithBytes:points length:sizeof(points)];
}

- (NSArray *)pointsForPlotsWithIdentifiers:(NSArray *)idents inRange:(SWPlotRange)range
{
    NSMutableArray *array = [NSMutableArray array];
    for ( NSString* ident in idents )
    {
        NSData *data = [self pointsForPlotWithIdentifier:ident inRange:range];
        [array addObject:data];
    }
    return array;
}

@end


