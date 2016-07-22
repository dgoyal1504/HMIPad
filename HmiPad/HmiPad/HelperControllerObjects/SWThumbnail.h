//
//  SWThumbnail.h
//  HmiPad
//
//  Created by Joan on 01/04/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *SWThumbnailSwitch;
extern NSString *SWThumbnailSegmented;
extern NSString *SWThumbnailColoredButton;
extern NSString *SWThumbnailArrayPicker;
extern NSString *SWThumbnailDictionaryPicker;
extern NSString *SWThumbnailSlider;
extern NSString *SWThumbnailKnob;
extern NSString *SWThumbnailTapGesture;

extern NSString *SWThumbnailTextField;
extern NSString *SWThumbnailTextView;
extern NSString *SWThumbnailNumberField;

extern NSString *SWThumbnailLabel;
extern NSString *SWThumbnailBar;
extern NSString *SWThumbnailHPIndicator;
extern NSString *SWThumbnailTrend;
extern NSString *SWThumbnailChart;
extern NSString *SWThumbnailScale;
extern NSString *SWThumbnailGauge;
extern NSString *SWThumbnailLamp;
extern NSString *SWThumbnailHPipe;
extern NSString *SWThumbnailVPipe;



@interface SWThumbnail : NSObject

- (id)initWithDefaultSize:(CGSize)size defaultRgb:(UInt32)rgb;
- (UIImage *)placeholderImage;
- (void)imageWithKey:(NSString*)imageKey completion:(void (^)(UIImage* image))block;


@end
