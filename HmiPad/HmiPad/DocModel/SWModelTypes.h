//
//  SWModelTypes.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/14/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString *SWFileTypeBinary;
//extern NSString *SWFileTypeSymbolic;
//extern NSString *SWFileExtensionBinary;
//extern NSString *SWFileExtensionSymbolic;
//
//extern NSString *SWFileTypeWrappBinary;
//extern NSString *SWFileTypeWrappSaveSymbolic;
//extern NSString *SWFileTypeWrappSaveThumbnail;
//extern NSString *SWFileExtensionWrapp;
//
//extern NSString *SWFileTypeWrappValuesBinary;
//extern NSString *SWFileTypeWrappValuesSymbolic;
//
//extern NSString *SWFileKeyWrappBinary;
//extern NSString *SWFileKeyWrappSymbolic;
//extern NSString *SWFileKeyWrappEncryptedSymbolic;
//
//extern NSString *SWFileKeyWrappValuesBinary;
//extern NSString *SWFileKeyWrappValuesSymbolic;
//extern NSString *SWFileKeyWrappThumbnail;
//
//extern NSString *SWFileExtensionActivationCode;

//extern NSString *SWFileAssetsDir;

//static NSString *SWFileChangesControlKeyBinary           = @"binaryArchiveKey";
//static NSString *SWFileChangesControlKeySymbolic         = @"symbolicArchiveKey";

typedef NSString * SWItemControllerType;

extern const SWItemControllerType SWItemControllerTypeNone;
extern const SWItemControllerType SWItemControllerTypeGroup;
extern const SWItemControllerType SWItemControllerTypeTextField;
extern const SWItemControllerType SWItemControllerTypeAbstractTextField;
extern const SWItemControllerType SWItemControllerTypeNumberTextField;
extern const SWItemControllerType SWItemControllerTypeStringTextField;
extern const SWItemControllerType SWItemControllerTypeStringTextView;
extern const SWItemControllerType SWItemControllerTypeArrayPicker;
extern const SWItemControllerType SWItemControllerTypeSegmentedControl;
extern const SWItemControllerType SWItemControllerTypeDictionaryPicker;
extern const SWItemControllerType SWItemControllerTypeLabel;
extern const SWItemControllerType SWItemControllerTypeStyledSwitch;
extern const SWItemControllerType SWItemControllerTypeCustomSwitch;
extern const SWItemControllerType SWItemControllerTypeButton;
extern const SWItemControllerType SWItemControllerTypeGestureRecognizer;
extern const SWItemControllerType SWItemControllerTypeTapRecognizer;
extern const SWItemControllerType SWItemControllerTypeLamp;
extern const SWItemControllerType SWItemControllerTypeShape;
extern const SWItemControllerType SWItemControllerTypeBarLevel;
extern const SWItemControllerType SWItemControllerTypeHPIndicator;
extern const SWItemControllerType SWItemControllerTypeSlider;
extern const SWItemControllerType SWItemControllerTypeWeb;
extern const SWItemControllerType SWItemControllerTypeImage;
extern const SWItemControllerType SWItemControllerTypeHorizontalPipe;
extern const SWItemControllerType SWItemControllerTypeVerticalPipe;
extern const SWItemControllerType SWItemControllerTypeTrend;
extern const SWItemControllerType SWItemControllerTypeChart;
extern const SWItemControllerType SWItemControllerTypeScale;
extern const SWItemControllerType SWItemControllerTypeGauge;
extern const SWItemControllerType SWItemControllerTypeKnob;

#pragma mark - SWType

typedef enum {
    SWEnumerationTypeNo = 0,
    SWEnumerationTypeYes = 0x100,
    SWEnumerationTypeMask = 0x100
} SWEnumerationType;

typedef enum {
    SWTypeAny                   = 0,
    SWTypeInteger               = 1,
    SWTypeBool                  = 2,
    SWTypeDouble                = 3,
    SWTypeAbsoluteTime          = 4,
    SWTypeColor                 = 5,
    SWTypePoint                 = 6,
    SWTypeSize                  = 7,
    SWTypeRect                  = 8,
    SWTypeRange                 = 9,
    SWTypeString                = 10,
    SWTypeUrl                   = 11,
    SWTypePath                  = 12,
    SWTypeImagePath             = 13,
    SWTypeRecipeSheetPath       = 14,
    SWTypeFont                  = 15,
    SWTypeFormatString          = 16,
    SWTypeDictionary            = 17,
    SWTypeArray                 = 18,
    //SWTypeEnumInputType         = 100  | SWEnumerationTypeYes,
    SWTypeEnumTextFieldStyle    = 100  | SWEnumerationTypeYes,
    SWTypeEnumAspectRatio       = 101  | SWEnumerationTypeYes,
    SWTypeEnumSwitchStyle       = 102  | SWEnumerationTypeYes,
    SWTypeEnumButtonStyle       = 103  | SWEnumerationTypeYes,
    SWTypeEnumOrientation       = 104  | SWEnumerationTypeYes,
    SWTypeEnumOrientation2      = 105  | SWEnumerationTypeYes,
    SWTypeEnumDirection         = 106  | SWEnumerationTypeYes,
    SWTypeEnumTextSelectionStyle    = 107  | SWEnumerationTypeYes,
    SWTypeEnumTextAlignment     = 108  | SWEnumerationTypeYes,
    SWTypeEnumVerticalTextAlignment     = 109  | SWEnumerationTypeYes,
    SWTypeEnumKnobThumbStyle    = 110  | SWEnumerationTypeYes,
    SWTypeEnumKnobStyle         = 111  | SWEnumerationTypeYes,
    SWTypeEnumGaugeStyle        = 112  | SWEnumerationTypeYes,
    SWTypeEnumChartType        = 113  | SWEnumerationTypeYes,
    SWTypeEnumTrendStyle        = 114  | SWEnumerationTypeYes,
    SWTypeEnumTrendUpdatingStyle = 115  | SWEnumerationTypeYes,
    SWTypeEnumFillStyle         = 116  | SWEnumerationTypeYes,
    SWTypeEnumStrokeStyle       = 117  | SWEnumerationTypeYes,
    SWTypeEnumShadowStyle       = 118  | SWEnumerationTypeYes,
    SWTypeEnumBooleanChoice     = 119  | SWEnumerationTypeYes,
    SWTypeEnumModalStyle        = 120  | SWEnumerationTypeYes,
    SWTypeEnumPageTransitionStyle = 121 | SWEnumerationTypeYes,
    SWTypeEnumPageInterfaceIdiom  = 122 | SWEnumerationTypeYes,
    SWTypeEnumDeviceInterfaceIdiom  = 123 | SWEnumerationTypeYes,
    SWTypeEnumAlarmPlayDefaultSound    = 124 | SWEnumerationTypeYes,
    SWTypeEnumAlarmShowAlert    = 125 | SWEnumerationTypeYes,
    SWTypeEnumProjectAllowedOrientation = 126 | SWEnumerationTypeYes,
    SWTypeEnumDatabaseTimeRange = 127 | SWEnumerationTypeYes,
//    SWTypeCount
} SWType;


extern NSString* NSStringFromSWType(SWType type);
extern NSString* NSLocalizedStringFromSWType(SWType type);
extern SWType SWTypeFromString(NSString *string);
extern NSIndexSet* compatibleTypesForType(SWType type);

typedef enum {
    SWItemResizeMaskNone = 0,
    SWItemResizeMaskFlexibleWidth = 1<<0,
    SWItemResizeMaskFlexibleHeight = 1<<1
} SWItemResizeMask;



