//
//  SWEnumTypes.h
//  HmiPad
//
//  Created by Lluch Joan on 07/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWModelTypes.h"

// TextFieldStyle
typedef enum {
    SWTextFieldStylePlain,
    SWTextFieldStyleBezel
} SWTextFieldStyle;

// Aspect ratio
typedef enum {
    SWImageAspectRatioNone,
    SWImageAspectRatioFill,
    SWImageAspectRatioFit,
    SWImageAspectRatioScaleToFill,
    SWImageAspectRatioCount
} SWImageAspectRatio;

// Orientation/Position
typedef enum {
    SWOrientationLeft,
    SWOrientationTop,
    SWOrientationRight,
    SWOrientationBottom,
} SWOrientation;

// Orientation2
typedef enum {
    SWOrientationHorizontal,
    SWOrientationVertical,
} SWOrientation2;

// Direction
typedef enum {
    SWDirectionLeft,
    SWDirectionUp,
    SWDirectionRight,
    SWDirectionDown,
} SWDirection;

// TextSelectionStyle
typedef enum {
    SWTextSelectionStyleNone,
    SWTextSelectionStyleAll,
} SWTextSelectionStyle;

// TextAlignment
typedef enum {
    SWTextAlignmentLeft,
    SWTextAlignmentCenter,
    SWTextAlignmentRight,
} SWTextAlignment;


// VerticalTextAlignment
typedef enum {
    SWVerticalTextAlignmentTop,
    SWVerticalTextAlignmentCenter,
    SWVerticalTextAlignmentBottom,
} SWVerticalTextAlignment;

// SwitchStyle
typedef enum {
    SWSwitchStyleApple,
    SWSwitchStyleButton,
} SWSwitchStyle;

// ButtonStyle
typedef enum {
    SWButtonStyleNormal,
    SWButtonStyleToggle,
    SWButtonStyleTouchUp,
} SWButtonStyle;

// InputType
//typedef enum {
//    SWTextFieldInputTypeNumeric,
//    SWTextFieldInputTypeString
//} SWEnumInputType;

// KnobThumbStyle
typedef enum {
    SWKnobThumbStyleSegment,
    SWKnobThumbStyleThumb
} SWKnobThumbStyle;

// KnobStyle
typedef enum {
    SWKnobStyleCustom,
    SWKnobStyle1,
    SWKnobStyle2
} SWKnobStyle;

// GaugeStyle
typedef enum {
    SWGaugeStyleCustom,
    SWGaugeStyle1,
    SWGaugeStyle2
} SWGaugeStyle;

// ChartType
typedef enum {
    SWChartTypeLine,
    SWChartTypeBar,
    SWChartTypeMixed,
} SWChartType;

// TrendStyle
typedef enum {
    SWTrendStyleCustom,
    SWTrendStyle1,
    SWTrendStyle2
} SWTrendStyle;

// TrendUpdatingStyle
typedef enum {
    SWTrendUpdatingStyleContinuous,
    SWTrendUpdatingStyleDiscrete
} SWTrendUpdatingStyle;

// Fill Style
typedef enum {
    SWFillStyleFlat,
    SWFillStyleSolid,
    SWFillStyleGradient,
    SWFillStyleImage,
} SWFillStyle;

// Stroke Style
typedef enum {
    SWStrokeStyleLine,
    SWStrokeStyleDash,
} SWStrokeStyle;

// Shadow Style
typedef enum {
    SWShadowStyleNone,
    SWShadowStyleAlphaChannel,
    SWShadowStyleInnerFill,
    SWShadowStyleOuterFill,
} SWShadowStyle;

// BooleanChoice
typedef enum {
    SWBooleanChoiceNo,
    SWBooleanChoiceYes,
} SWBooleanChoice;

// ModalStyle
typedef enum {
    SWModalStyleNormal,
    SWModalStyleModal,
} SWModalStyle;

// PageTransitionStyle
typedef enum {
    SWPageTransitionStyleNone,
    SWPageTransitionStyleFade,
    SWPageTransitionStyleCurl,
    SWPageTransitionStyleHorizontalShift,
    SWPageTransitionStyleVerticalShift,
    SWPageTransitionStyleHorizontalFlip,
} SWPageTransitionStyle;

// PageInterfaceIdiom
typedef enum {
    SWPageInterfaceIdiomPadAndPhone,
    SWPageInterfaceIdiomPad,
    SWPageInterfaceIdiomPhone,
} SWPageInterfaceIdiom;

// DeviceInterfaceIdiom
typedef enum {
    SWDeviceInterfaceIdiomPad,
    SWDeviceInterfaceIdiomPhone,
} SWDeviceInterfaceIdiom;

// AlarmPlaySound
typedef enum {
    SWAlarmPlayDefaultSoundNo,
    SWAlarmPlayDefaultSoundYes
} SWAlarmPlayDefaultSound;

// AlarmShowAlert
typedef enum {
    SWAlarmShowAlertNo,
    SWAlarmShowAlertYes
} SWAlarmShowAlert;

// ProjectAllowedOrientations
typedef enum {
    SWProjectAllowedOrientationAny,
    SWProjectAllowedOrientationLandscape,
    SWProjectAllowedOrientationPortrait,
} SWProjectAllowedOrientation;

// DatabaseTimeRanges
// ATENCIO: aquest enum ha d'estar ordenat de menor a mes gran degut a la seva utilizacio.
typedef enum {
    SWDatabaseTimeRangeHourly,
    SWDatabaseTimeRangeDaily,
    SWDatabaseTimeRangeWeekly,
    SWDatabaseTimeRangeMonthly,
    SWDatabaseTimeRangeYearly,
}   SWDatabaseTimeRange;


extern UIViewContentMode UIViewContentModeFromSWImageAspectRatio(SWImageAspectRatio ratio);

extern NSInteger numberOfOptionsForType(SWType type);
extern NSString *localizedNameForOption_type(int option, SWType type);
extern NSArray *localizedNamesArrayForType(SWType type);




