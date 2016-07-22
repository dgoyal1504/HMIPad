//
//  SWModelTypes.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import "SWModelTypes.h"
#import "Pair.h"

const SWItemControllerType SWItemControllerTypeNone = @"";
const SWItemControllerType SWItemControllerTypeGroup = @"SWGroupItemController";
const SWItemControllerType SWItemControllerTypeTextField = @"SWTextFieldItemController";
const SWItemControllerType SWItemControllerTypeAbstractTextField = @"SWAbstractTextFieldItemController";
const SWItemControllerType SWItemControllerTypeNumberTextField = @"SWNumberTextFieldItemController";
const SWItemControllerType SWItemControllerTypeStringTextField = @"SWStringTextFieldItemController";
const SWItemControllerType SWItemControllerTypeStringTextView = @"SWStringTextViewItemController";
const SWItemControllerType SWItemControllerTypeArrayPicker = @"SWArrayPickerItemController";
const SWItemControllerType SWItemControllerTypeSegmentedControl = @"SWSegmentedControlItemController";
const SWItemControllerType SWItemControllerTypeDictionaryPicker = @"SWDictionaryPickerItemController";
const SWItemControllerType SWItemControllerTypeLabel = @"SWLabelItemController";
const SWItemControllerType SWItemControllerTypeStyledSwitch = @"SWStyledSwitchItemController";
const SWItemControllerType SWItemControllerTypeCustomSwitch = @"SWCustomSwitchItemController";
const SWItemControllerType SWItemControllerTypeButton = @"SWButtonItemController";
const SWItemControllerType SWItemControllerTypeGestureRecognizer = @"SWGestureRecognizerItemController";
const SWItemControllerType SWItemControllerTypeTapRecognizer = @"SWTapRecognizerItemController";
const SWItemControllerType SWItemControllerTypeLamp = @"SWLampItemController";
const SWItemControllerType SWItemControllerTypeShape = @"SWShapeItemController";
const SWItemControllerType SWItemControllerTypeBarLevel = @"SWBarLevelItemController";
const SWItemControllerType SWItemControllerTypeHPIndicator = @"SWHPIndicatorItemController";
const SWItemControllerType SWItemControllerTypeSlider = @"SWSliderItemController";
const SWItemControllerType SWItemControllerTypeHorizontalPipe = @"SWHorizontalPipeItemController";
const SWItemControllerType SWItemControllerTypeVerticalPipe = @"SWVerticalPipeItemController";
const SWItemControllerType SWItemControllerTypeTrend = @"SWTrendItemController";
const SWItemControllerType SWItemControllerTypeChart = @"SWChartItemController";
const SWItemControllerType SWItemControllerTypeScale = @"SWScaleItemController";
const SWItemControllerType SWItemControllerTypeGauge = @"SWGaugeItemController";
const SWItemControllerType SWItemControllerTypeKnob = @"SWKnobItemController";
const SWItemControllerType SWItemControllerTypeWeb = @"SWWebItemController";
const SWItemControllerType SWItemControllerTypeImage = @"SWImageItemController";


//NSString *SWFileTypeBinary                  = @"com.sweetwilliam.hmipad.smb";
//NSString *SWFileTypeSymbolic                = @"com.sweetwilliam.hmipad.smst";
//NSString *SWFileExtensionBinary             = @"smb";
//NSString *SWFileExtensionSymbolic           = @"smst";
//
//NSString *SWFileTypeWrappBinary             = @"com.sweetwilliam.hmipad.bin.hmipad";
//NSString *SWFileTypeWrappSaveSymbolic       = @"com.sweetwilliam.hmipad.sym.hmipad";
//NSString *SWFileTypeWrappSaveThumbnail      = @"com.sweetwilliam.hmipad.thu.hmipad";
//NSString *SWFileExtensionWrapp              = @"hmipad";
//
//NSString *SWFileTypeWrappValuesBinary       = @"com.sweetwilliam.hmipad.valuesbin.hmipad";
//NSString *SWFileTypeWrappValuesSymbolic     = @"com.sweetwilliam.hmipad.valuessym.hmipad";
//
//NSString *SWFileKeyWrappBinary              = @"binary";
//NSString *SWFileKeyWrappSymbolic            = @"symbolic";
//NSString *SWFileKeyWrappEncryptedSymbolic   = @"rsymbolic";
//NSString *SWFileKeyWrappThumbnail           = @"thumbnail.png";
//
//NSString *SWFileKeyWrappValuesBinary        = @"valuesbinary";
//NSString *SWFileKeyWrappValuesSymbolic      = @"valuessymbolic";
//
//NSString *SWFileExtensionActivationCode     = @"hmipadcode";
//
////NSString *SWFileAssetsDir                   = @"assets";
//

#pragma mark - SWType

const static Pair swTypePairs[] =
{
    { @"Any", SWTypeAny },
    { @"Integer", SWTypeInteger },
    { @"Bool", SWTypeBool },
    { @"Color", SWTypeColor },
    { @"Double", SWTypeDouble },
    { @"AbsoluteTime", SWTypeAbsoluteTime },
    { @"Point", SWTypePoint },
    { @"Size", SWTypeSize },
    { @"Rect", SWTypeRect },
    { @"Range", SWTypeRange },
    { @"String", SWTypeString },
    { @"Url", SWTypeUrl },
    { @"Path", SWTypePath },
    { @"ImagePath", SWTypeImagePath },
    { @"RecipeSheetPath", SWTypeRecipeSheetPath },
    { @"FontName", SWTypeFont },
    { @"FormatString", SWTypeFormatString },
    { @"Dictionary", SWTypeDictionary },
    { @"Array", SWTypeArray },
    
    //{ @"InputType", SWTypeEnumInputType },
    
    { @"TextFieldStyle", SWTypeEnumTextFieldStyle },
    { @"AspectRatio", SWTypeEnumAspectRatio },
    { @"SwitchStyle", SWTypeEnumSwitchStyle },
    { @"ButtonStyle", SWTypeEnumButtonStyle },
    { @"Orientation", SWTypeEnumOrientation },
    { @"Orientation", SWTypeEnumOrientation2 },
    { @"Direction", SWTypeEnumDirection },
    { @"TextSelectionStyle", SWTypeEnumTextSelectionStyle },
    { @"TextAlignment", SWTypeEnumTextAlignment },
    { @"VerticalAlignment", SWTypeEnumVerticalTextAlignment },
    { @"ThumbStyle", SWTypeEnumKnobThumbStyle },
    { @"KnobStyle", SWTypeEnumKnobStyle },
    { @"GaugeStyle", SWTypeEnumGaugeStyle },
    
    { @"TrendStyle", SWTypeEnumTrendStyle },
    { @"FillStyle", SWTypeEnumFillStyle },
    { @"StrokeStyle", SWTypeEnumStrokeStyle },
    { @"ShadowStyle", SWTypeEnumShadowStyle },
    { @"BooleanChoice", SWTypeEnumBooleanChoice },
    { @"ModalStyle", SWTypeEnumModalStyle },
    { @"PageTransitionStyle", SWTypeEnumPageTransitionStyle },
    { @"InterfaceIdiom", SWTypeEnumPageInterfaceIdiom },
    { @"AlarmPlayDefaultSound", SWTypeEnumAlarmPlayDefaultSound },
    { @"AlarmShowAlert", SWTypeEnumAlarmShowAlert },
    
    { @"ProjectAllowedOrientation", SWTypeEnumProjectAllowedOrientation },
    { @"DatabaseTimeRange", SWTypeEnumDatabaseTimeRange },
    
};

const static int swTypePairsCount = sizeof(swTypePairs)/sizeof(Pair);

NSString* NSStringFromSWType(SWType type) 
{
    return PairStringForNumber(swTypePairs, swTypePairsCount, type);
}

NSString* NSLocalizedStringFromSWType(SWType type)
{
    return NSLocalizedString(NSStringFromSWType(type), nil);
}

SWType SWTypeFromString(NSString *string)
{
    return PairNumberForString(swTypePairs, swTypePairsCount, string);
}

NSIndexSet* compatibleTypesForType(SWType type)
{
    // com a minim es compatible amb ell mateix i amb SWTypeAny
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:type];
    [indexSet addIndex:SWTypeAny];
    
    // pot ser compatible amb altres
    switch (type)
    {
        case SWTypeString:
            [indexSet addIndex:SWTypeUrl];
            [indexSet addIndex:SWTypeFont];
            [indexSet addIndex:SWTypeFormatString];
            [indexSet addIndex:SWTypeColor];
            [indexSet addIndex:SWTypePath];
            [indexSet addIndex:SWTypeImagePath];
            [indexSet addIndex:SWTypeRecipeSheetPath];
            break;
            
        case SWTypeUrl:
        case SWTypeFont:
        case SWTypeFormatString:
        case SWTypeColor:
        case SWTypePath:
        case SWTypeImagePath:
        case SWTypeRecipeSheetPath:
            [indexSet addIndex:SWTypeString];
            break;
        
        case SWTypeBool:
        case SWTypeDouble:
        case SWTypeInteger:
            [indexSet addIndex:SWTypeBool];
            [indexSet addIndex:SWTypeInteger];
            [indexSet addIndex:SWTypeDouble];
            break;
        
        case SWTypeAny:
//            [indexSet addIndex:SWTypeInteger];
//            [indexSet addIndex:SWTypeBool];
//            [indexSet addIndex:SWTypeDouble];
//            [indexSet addIndex:SWTypeAbsoluteTime];
//            [indexSet addIndex:SWTypeColor];
//            [indexSet addIndex:SWTypePoint];
//            [indexSet addIndex:SWTypeSize];
//            [indexSet addIndex:SWTypeRect];
//            [indexSet addIndex:SWTypeRange];
//            [indexSet addIndex:SWTypeString];
//            [indexSet addIndex:SWTypeUrl];
//            [indexSet addIndex:SWTypePath];
//            [indexSet addIndex:SWTypeImagePath];
//            [indexSet addIndex:SWTypeRecipeSheetPath];
//            [indexSet addIndex:SWTypeFont];
//            [indexSet addIndex:SWTypeFormatString];
//            [indexSet addIndex:SWTypeDictionary];
//            [indexSet addIndex:SWTypeArray];
            
            [indexSet addIndexesInRange:NSMakeRange(0, 200)];
        default:
            break;
    }
    
    return [indexSet copy];
}

