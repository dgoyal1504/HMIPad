//
//  SWEnumTypes.m
//  HmiPad
//
//  Created by Lluch Joan on 07/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWEnumTypes.h"
#import "Pair.h"


#pragma mark Pairs

// TextFieldStyle
const static Pair swTypeEnumTextFieldStylePairs[] =
{
    { @"Plain", SWTextFieldStylePlain },
    { @"Bezel", SWTextFieldStyleBezel },
};
const static int swTypeEnumTextFieldStylePairsCount = sizeof(swTypeEnumTextFieldStylePairs)/sizeof(Pair);


// Aspect ratio
const static Pair swTypeEnumImageAspectRatioPairs[] =
{
    { @"None", SWImageAspectRatioNone },
    { @"Aspect Fill", SWImageAspectRatioFill },
    { @"Aspect Fit", SWImageAspectRatioFit },
    { @"Scale to Fill", SWImageAspectRatioScaleToFill },
};
const static int swTypeEnumImageAspectRatioPairsCount = sizeof(swTypeEnumImageAspectRatioPairs)/sizeof(Pair);

// Orientation
const static Pair swTypeEnumOrientationPairs[] =
{
    { @"Left", SWOrientationLeft },
    { @"Top", SWOrientationTop },
    { @"Right", SWOrientationRight },
    { @"Bottom", SWOrientationBottom },
};
const static int swTypeEnumOrientationPairsCount = sizeof(swTypeEnumOrientationPairs)/sizeof(Pair);

// Orientation
const static Pair swTypeEnumOrientation2Pairs[] =
{
    { @"Horizontal", SWOrientationHorizontal },
    { @"Vertical", SWOrientationVertical },
};
const static int swTypeEnumOrientation2PairsCount = sizeof(swTypeEnumOrientation2Pairs)/sizeof(Pair);

// Direction
const static Pair swTypeEnumDirectionPairs[] =
{
    { @"Left", SWDirectionLeft },
    { @"Up", SWDirectionUp },
    { @"Right", SWDirectionRight },
    { @"Down", SWDirectionDown },
};
const static int swTypeEnumDirectionPairsCount = sizeof(swTypeEnumDirectionPairs)/sizeof(Pair);


// TextSelectionStyle
const static Pair swTypeEnumTextSelectionStylePairs[] =
{
    { @"No Selection", SWTextSelectionStyleNone },
    { @"Select All", SWTextSelectionStyleAll },
};
const static int swTypeEnumTextSelectionStylePairsCount = sizeof(swTypeEnumTextSelectionStylePairs)/sizeof(Pair);


// TextAlignment
const static Pair swTypeEnumTextAlignmentPairs[] =
{
    { @"Left", SWTextAlignmentLeft },
    { @"Center", SWTextAlignmentCenter },
    { @"Right", SWTextAlignmentRight },
};
const static int swTypeEnumTextAlignmentPairsCount = sizeof(swTypeEnumTextAlignmentPairs)/sizeof(Pair);

// VerticalTextAlignment
const static Pair swTypeEnumVerticalTextAlignmentPairs[] =
{
    { @"Top", SWVerticalTextAlignmentTop },
    { @"Center", SWVerticalTextAlignmentCenter },
    { @"Bottom", SWVerticalTextAlignmentBottom },
};
const static int swTypeEnumVerticalTextAlignmentPairsCount = sizeof(swTypeEnumVerticalTextAlignmentPairs)/sizeof(Pair);


// SwitchSytle
const static Pair swTypeEnumSwitchStylePairs[] =
{
    { @"Apple Style", SWSwitchStyleApple },
    { @"Button Style", SWSwitchStyleButton },
};
const static int swTypeEnumSwitchStylePairsCount = sizeof(swTypeEnumSwitchStylePairs)/sizeof(Pair);

// ButtonSytle
const static Pair swTypeEnumButtonStylePairs[] =
{
    { @"Normal Button", SWButtonStyleNormal },
    { @"Toggle Button", SWButtonStyleToggle },
    { @"Touch Up Button", SWButtonStyleTouchUp },
};
const static int swTypeEnumButtonStylePairsCount = sizeof(swTypeEnumButtonStylePairs)/sizeof(Pair);

//// InputType
//const static Pair swTypeEnumInputTypePairs[] =
//{
//    { @"Text", SWTextFieldInputTypeString },
//    { @"Numeric", SWTextFieldInputTypeNumeric },
//};
//const static int swTypeEnumInputTypePairsCount = sizeof(swTypeEnumInputTypePairs)/sizeof(Pair);

// KnobStyle
const static Pair swTypeEnumKnobStylePairs[] =
{
    { @"Custom", SWKnobStyleCustom },
    { @"Style 1", SWKnobStyle1 },
    { @"Style 2", SWKnobStyle2 },
};
const static int swTypeEnumKnobStylePairsCount = sizeof(swTypeEnumKnobStylePairs)/sizeof(Pair);

// KnobThumbStyle
const static Pair swTypeEnumKnobThumbStylePairs[] =
{
    { @"Segment", SWKnobThumbStyleSegment },
    { @"Thumb", SWKnobThumbStyleThumb },
};
const static int swTypeEnumKnobThumbStylePairsCount = sizeof(swTypeEnumKnobThumbStylePairs)/sizeof(Pair);

// GaugeStyle
const static Pair swTypeEnumGaugeStylePairs[] =
{
    { @"Custom", SWGaugeStyleCustom },
    { @"Style 1", SWGaugeStyle1 },
    { @"Style 2", SWGaugeStyle2 },
};
const static int swTypeEnumGaugeStylePairsCount = sizeof(swTypeEnumGaugeStylePairs)/sizeof(Pair);

// ChartType
const static Pair swTypeEnumChartTypePairs[] =
{
    { @"Line", SWChartTypeLine },
    { @"Bar", SWChartTypeBar },
    { @"Mixed", SWChartTypeMixed },
};
const static int swTypeEnumChartTypePairsCount = sizeof(swTypeEnumChartTypePairs)/sizeof(Pair);


// TrendStyle
const static Pair swTypeEnumTrendStylePairs[] =
{
    { @"Custom", SWTrendStyleCustom },
    { @"Style 1", SWTrendStyle1 },
    { @"Style 2", SWTrendStyle2 },
};
const static int swTypeEnumTrendStylePairsCount = sizeof(swTypeEnumTrendStylePairs)/sizeof(Pair);

// TrendUpdatingStyle
const static Pair swTypeEnumTrendUpdatingStylePairs[] =
{
    { @"Continuous", SWTrendUpdatingStyleContinuous },
    { @"Discrete", SWTrendUpdatingStyleDiscrete },
};
const static int swTypeEnumTrendUpdatingStylePairsCount = sizeof(swTypeEnumTrendUpdatingStylePairs)/sizeof(Pair);

// SWTypeEnumFillStyle
const static Pair swTypeEnumFillStylePairs[] =
{
    { @"Flat Color", SWFillStyleFlat },
    { @"Solid Color", SWFillStyleSolid },
    { @"Gradient", SWFillStyleGradient },
    { @"Image", SWFillStyleImage },
};
const static int swTypeEnumFillStylePairsCount = sizeof(swTypeEnumFillStylePairs)/sizeof(Pair);

// SWTypeEnumStrokeStyle
const static Pair swTypeEnumStrokeStylePairs[] =
{
    { @"Line", SWStrokeStyleLine },
    { @"Dash", SWStrokeStyleDash },
};
const static int swTypeEnumStrokeStylePairsCount = sizeof(swTypeEnumStrokeStylePairs)/sizeof(Pair);

// SWTypeEnumShadowStyle
const static Pair swTypeEnumShadowStylePairs[] =
{
    { @"None", SWShadowStyleNone },
    { @"Alpha Channel", SWShadowStyleAlphaChannel },
    { @"Inner Fill", SWShadowStyleInnerFill },
    { @"Outer Fill", SWShadowStyleOuterFill },
};
const static int swTypeEnumShadowStylePairsCount = sizeof(swTypeEnumShadowStylePairs)/sizeof(Pair);


// SWTypeEnumBooleanChoice
const static Pair swTypeEnumBooleanChoicePairs[] =
{
    { @"No", SWBooleanChoiceNo },
    { @"Yes", SWBooleanChoiceYes },
};
const static int swTypeEnumBooleanChoicePairsCount = sizeof(swTypeEnumBooleanChoicePairs)/sizeof(Pair);

// SWTypeEnumModalStyle
const static Pair swTypeEnumModalStylePairs[] =
{
    { @"Normal", SWModalStyleNormal },
    { @"Modal", SWModalStyleModal },
};
const static int swTypeEnumModalStylePairsCount = sizeof(swTypeEnumModalStylePairs)/sizeof(Pair);

// SWTypeEnumPageTransitionStyle
const static Pair swTypeEnumPageTransitionStylePairs[] =
{
    { @"None", SWPageTransitionStyleNone },
    { @"Fade", SWPageTransitionStyleFade },
    { @"Curl", SWPageTransitionStyleCurl },
    { @"Shift Horizontal", SWPageTransitionStyleHorizontalShift },
    { @"Shift Vertical", SWPageTransitionStyleVerticalShift },
    { @"Flip", SWPageTransitionStyleHorizontalFlip },
};
const static int swTypeEnumPageTransitionStylePairsCount = sizeof(swTypeEnumPageTransitionStylePairs)/sizeof(Pair);

// SWTypeEnumPageInterfaceIdiom
const static Pair swTypeEnumPageInterfaceIdiomPairs[] =
{
    { @"iPad & iPhone", SWPageInterfaceIdiomPadAndPhone },
    { @"iPad", SWPageInterfaceIdiomPad },
    { @"iPhone", SWPageInterfaceIdiomPhone },
};
const static int swTypeEnumPageInterfaceIdiomPairsCount = sizeof(swTypeEnumPageInterfaceIdiomPairs)/sizeof(Pair);

// SWTypeEnumDeviceInterfaceIdiom
const static Pair swTypeEnumDeviceInterfaceIdiomPairs[] =
{
    { @"iPad", SWDeviceInterfaceIdiomPad },
    { @"iPhone", SWDeviceInterfaceIdiomPhone },
};
const static int swTypeEnumDeviceInterfaceIdiomPairsCount = sizeof(swTypeEnumDeviceInterfaceIdiomPairs)/sizeof(Pair);

// SWAlarmPlayDefaultSound
const static Pair swTypeEnumAlarmPlayDefaultSoundPairs[] =
{
    { @"Custom Sound", SWAlarmPlayDefaultSoundNo },
    { @"Default Sound", SWAlarmPlayDefaultSoundYes },
};
const static int swTypeEnumAlarmPlayDefaultSoundPairsCount = sizeof(swTypeEnumAlarmPlayDefaultSoundPairs)/sizeof(Pair);

// SWAlarmShowAlert
const static Pair swTypeEnumAlarmShowAlertPairs[] =
{
    { @"No Alert", SWAlarmShowAlertNo },
    { @"Show Alert", SWAlarmShowAlertYes },
};
const static int swTypeEnumAlarmShowAlertPairsCount = sizeof(swTypeEnumAlarmShowAlertPairs)/sizeof(Pair);

// SWProjectAllowedOrientation
const static Pair swTypeEnumProjectAllowedOrientationPairs[] =
{
    { @"Landscape", SWProjectAllowedOrientationLandscape },
    { @"Portrait", SWProjectAllowedOrientationPortrait },
    { @"All", SWProjectAllowedOrientationAny },
};
const static int swTypeEnumProjectAllowedOrientationPairsCount = sizeof(swTypeEnumProjectAllowedOrientationPairs)/sizeof(Pair);

// SWDatabaseTimeRanges
const static Pair swTypeEnumDatabaseTimeRangePairs[] =
{
    { @"Hourly", SWDatabaseTimeRangeHourly },
    { @"Daily", SWDatabaseTimeRangeDaily },
    { @"Weekly", SWDatabaseTimeRangeWeekly },
    { @"Monthly", SWDatabaseTimeRangeMonthly },
    { @"Yearly", SWDatabaseTimeRangeYearly },
};
const static int swTypeEnumDatabaseTimeRangePairsCount = sizeof(swTypeEnumDatabaseTimeRangePairs)/sizeof(Pair);


// Value Enumeration types
const static Tuple swTypeEnumTypeTuples[] =
{
    { {&swTypeEnumTextFieldStylePairs, swTypeEnumTextFieldStylePairsCount}, SWTypeEnumTextFieldStyle },
    { {&swTypeEnumImageAspectRatioPairs, swTypeEnumImageAspectRatioPairsCount}, SWTypeEnumAspectRatio },
    { {&swTypeEnumOrientationPairs, swTypeEnumOrientationPairsCount}, SWTypeEnumOrientation },
    { {&swTypeEnumOrientation2Pairs, swTypeEnumOrientation2PairsCount}, SWTypeEnumOrientation2 },
    { {&swTypeEnumDirectionPairs, swTypeEnumDirectionPairsCount}, SWTypeEnumDirection },
    { {&swTypeEnumTextSelectionStylePairs, swTypeEnumTextSelectionStylePairsCount}, SWTypeEnumTextSelectionStyle },
    { {&swTypeEnumTextAlignmentPairs, swTypeEnumTextAlignmentPairsCount}, SWTypeEnumTextAlignment },
    { {&swTypeEnumVerticalTextAlignmentPairs, swTypeEnumVerticalTextAlignmentPairsCount}, SWTypeEnumVerticalTextAlignment },
    { {&swTypeEnumSwitchStylePairs, swTypeEnumSwitchStylePairsCount}, SWTypeEnumSwitchStyle },
    { {&swTypeEnumButtonStylePairs, swTypeEnumButtonStylePairsCount}, SWTypeEnumButtonStyle },
//    { {&swTypeEnumInputTypePairs, swTypeEnumInputTypePairsCount}, SWTypeEnumInputType },
    { {&swTypeEnumKnobStylePairs, swTypeEnumKnobStylePairsCount}, SWTypeEnumKnobStyle },
    { {&swTypeEnumKnobThumbStylePairs, swTypeEnumKnobThumbStylePairsCount}, SWTypeEnumKnobThumbStyle },
    { {&swTypeEnumGaugeStylePairs, swTypeEnumGaugeStylePairsCount}, SWTypeEnumGaugeStyle },
    { {&swTypeEnumChartTypePairs, swTypeEnumChartTypePairsCount}, SWTypeEnumChartType },
    { {&swTypeEnumTrendStylePairs, swTypeEnumTrendStylePairsCount}, SWTypeEnumTrendStyle },
    { {&swTypeEnumTrendUpdatingStylePairs, swTypeEnumTrendUpdatingStylePairsCount}, SWTypeEnumTrendUpdatingStyle },
    { {&swTypeEnumFillStylePairs, swTypeEnumFillStylePairsCount}, SWTypeEnumFillStyle },
    { {&swTypeEnumStrokeStylePairs, swTypeEnumStrokeStylePairsCount}, SWTypeEnumStrokeStyle },
    { {&swTypeEnumShadowStylePairs, swTypeEnumShadowStylePairsCount}, SWTypeEnumShadowStyle },
    { {&swTypeEnumBooleanChoicePairs, swTypeEnumBooleanChoicePairsCount}, SWTypeEnumBooleanChoice },
    { {&swTypeEnumModalStylePairs, swTypeEnumModalStylePairsCount}, SWTypeEnumModalStyle },
    { {&swTypeEnumPageTransitionStylePairs, swTypeEnumPageTransitionStylePairsCount}, SWTypeEnumPageTransitionStyle },
    { {&swTypeEnumPageInterfaceIdiomPairs, swTypeEnumPageInterfaceIdiomPairsCount}, SWTypeEnumPageInterfaceIdiom },
    { {&swTypeEnumDeviceInterfaceIdiomPairs, swTypeEnumDeviceInterfaceIdiomPairsCount}, SWTypeEnumDeviceInterfaceIdiom },
    { {&swTypeEnumAlarmPlayDefaultSoundPairs, swTypeEnumAlarmPlayDefaultSoundPairsCount}, SWTypeEnumAlarmPlayDefaultSound },
    { {&swTypeEnumAlarmShowAlertPairs, swTypeEnumAlarmShowAlertPairsCount}, SWTypeEnumAlarmShowAlert },
    { {&swTypeEnumProjectAllowedOrientationPairs, swTypeEnumProjectAllowedOrientationPairsCount}, SWTypeEnumProjectAllowedOrientation },
    { {&swTypeEnumDatabaseTimeRangePairs, swTypeEnumDatabaseTimeRangePairsCount}, SWTypeEnumDatabaseTimeRange },
};
const static int swTypeEnumTypeTuplesCount = sizeof(swTypeEnumTypeTuples)/sizeof(Tuple);


#pragma mark function implementation

NSInteger numberOfOptionsForType(SWType type)
{
    Pair pair = PairForKey( swTypeEnumTypeTuples, swTypeEnumTypeTuplesCount, type);
    return pair.number;
}


NSString* localizedNameForOption_type(int option, SWType type)
{
    NSString *name = nil ;
    
    Pair pair = PairForKey(swTypeEnumTypeTuples, swTypeEnumTypeTuplesCount, type);
    name = PairStringForNumber(pair.ptr, pair.number, option);
    
    NSString *localizedName = NSLocalizedString(name, nil);
    return localizedName;
}


NSArray *localizedNamesArrayForType(SWType type)
{
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = numberOfOptionsForType(type);
    
    for (NSInteger i=0; i<count; ++i) 
    {
        NSString *title = localizedNameForOption_type(i,type);
        [array addObject:title];
    }
    
    return array;
}


UIViewContentMode UIViewContentModeFromSWImageAspectRatio(SWImageAspectRatio ratio)
{
    UIViewContentMode contentMode;
    
    switch (ratio) {
        case SWImageAspectRatioNone:
            contentMode = UIViewContentModeCenter;
            break;
        case SWImageAspectRatioFill:
            contentMode = UIViewContentModeScaleAspectFill;
            break;
        case SWImageAspectRatioFit:
            contentMode = UIViewContentModeScaleAspectFit;
            break;
        case SWImageAspectRatioScaleToFill:
            contentMode = UIViewContentModeScaleToFill;
            break;
        case SWImageAspectRatioCount:  // se suposa que no pasa mai, pero es per fer callar el compilador
            contentMode = UIViewContentModeCenter;
            break;
    }
    
    return contentMode;
}

