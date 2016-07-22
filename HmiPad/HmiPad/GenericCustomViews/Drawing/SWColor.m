/*
 *  Color.h
 *  ScadaMobile_100829
 *
 *  Created by Joan on 30/08/10.
 *  Copyright 2010 SweetWilliam, S.L. All rights reserved.
 *
 */


#import "SWColor.h"
#import <xlocale.h>


//---------------------------------------------------------------------
// Categoria de UIColor per determinar un color de contrast respecte un fons
//@implementation UIColor(ColoredButtonExtensions)


//---------------------------------------------------------------------
//static CGFloat brightnessForColor(UIColor *color)
//{
//    CGColorRef cgColor = [color CGColor] ;
//    CGColorSpaceRef colorSpace = CGColorGetColorSpace( cgColor ) ;
//    CGColorSpaceModel colorModel = CGColorSpaceGetModel( colorSpace ) ;
//    if ( colorModel == kCGColorSpaceModelRGB )
//    {
//        const CGFloat *components = CGColorGetComponents(cgColor) ;
//        return ((components[0] * 299.0f) + (components[1] * 587.0f) + (components[2] * 114.0f)) / 1000.0f ;
//    }
//    return 1 ;
//}



UIColor *groupTableViewBackgroundColor(void)
{
    __strong static UIColor* tableViewBackgroundColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(7.0f, 1.0f), NO, 0.0);
        CGContextRef c = UIGraphicsGetCurrentContext();
        [[UIColor colorWithRed:185/255.f green:192/255.f blue:202/255.f alpha:1.f] setFill];
        CGContextFillRect(c, CGRectMake(0, 0, 4, 1));
        [[UIColor colorWithRed:185/255.f green:193/255.f blue:200/255.f alpha:1.f] setFill];
        CGContextFillRect(c, CGRectMake(4, 0, 1, 1));
        [[UIColor colorWithRed:192/255.f green:200/255.f blue:207/255.f alpha:1.f] setFill];
        CGContextFillRect(c, CGRectMake(5, 0, 2, 1));
        UIImage *tableViewBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        tableViewBackgroundColor = [UIColor colorWithPatternImage:tableViewBackgroundImage];
    });
    return tableViewBackgroundColor;
}


UIColor *checkeredBackgroundColor(void)
{
    __strong static UIColor *checkeredBackgroundColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat side = 16;
        CGSize size = CGSizeMake(side, side);
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
        [[UIColor whiteColor] setFill];
        UIRectFill((CGRect){.size = size});
    
        CGRect r = CGRectMake(0, 0, side / 2, side / 2);
        [[UIColor colorWithWhite:0.90f alpha:1] setFill];
        UIRectFill(r);
        r.origin = CGPointMake(side / 2, side / 2);
        UIRectFill(r);
 
        UIImage *checkeredImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        checkeredBackgroundColor = [UIColor colorWithPatternImage:checkeredImage];
    });
    return checkeredBackgroundColor;
}

UInt32 rgbColorForUIcolor(UIColor *color)
{
    CGColorRef cgColor = [color CGColor] ;
    CGColorSpaceRef colorSpace = CGColorGetColorSpace( cgColor ) ;
    CGColorSpaceModel colorModel = CGColorSpaceGetModel( colorSpace ) ;
    if ( colorModel == kCGColorSpaceModelRGB )
    {
        const CGFloat *components = CGColorGetComponents(cgColor) ;
        int r = 255*components[0] ;
        int g = 255*components[1] ;
        int b = 255*components[2] ;
        int a = 127*components[3] ;

        UInt32 rgb = Theme_RGBA(0, r, g, b, 127-a);
        return rgb ;
    }
    return TheSystemDarkBlueTheme ;

/*
    // implementacio alternativa
    CGFloat fr, fg, fb, fa ;
    if ( [color getRed:&fr green:&fg blue:&fb alpha:&fa] )
    {
        int r = 255*fr ;
        int g = 255*fg ;
        int b = 255*fb ;
        int a = 127*fa ;
        UInt32 rgb = Theme_RGBA(0, r, g, b, a);
        return rgb ;
    }
    return TheSystemDarkBlueTheme ;
*/
}



//---------------------------------------------------------------------
UIColor *contrastColorForRgbColor(UInt32 color)
{
    UIColor *contrastColor ;
    CGFloat brightness = BrightnessForRgb(color) ;
    if (brightness < 0.59) 
    { 
        contrastColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1] ;
    }
    else
    {
        contrastColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75] ;
        //contrastColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1] ;
    }
    return contrastColor ;
}

//---------------------------------------------------------------------
UIColor *shadowColorForForRgbColor(UInt32 color)
{
    CGFloat coef ;
    UIColor *shadowColor ;
    CGFloat brightness = BrightnessForRgb(color) ;
    
    if (brightness < 0.59) coef = 0.66f ;
    else coef = 1.33f ;

    shadowColor = [UIColor colorWithRed:coef*ColorR(color) green:coef*ColorG(color) blue:coef*ColorB(color) alpha:1.0f] ;
    return shadowColor ;
}


UIColor *contrastColorForUIColor(UIColor *color)
{
    UInt32 rgb = rgbColorForUIcolor(color);
    return contrastColorForRgbColor(rgb);
}


UIColor *shadowColorForUIColor(UIColor *color)
{
    UInt32 rgb = rgbColorForUIcolor(color);
    return shadowColorForForRgbColor(rgb);
}

/////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Diccionari de noms de colors
/////////////////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------------
//#define ThemesArraySize 4
static CFDictionaryRef theThemesDictionary = NULL ;

struct NameAndLength
{
    int len ;
    const char *cName ;
    UInt32 themeRgb ;
}  ;

typedef struct NameAndLength NameAndLength ;


static const  NameAndLength scalarKeys[] = 
{
    {11, "TextDefault", TextDefaultColor},
    {7, "Default", TextDefaultColor },
    {10, "BarDefault", BarDefaultColor},
    {12, "DefaultGreen", BarDefaultColor},
    {10, "ClearWhite", SystemClearWhiteColor},
    {10, "ClearColor", SystemClearWhiteColor},
    {10, "ClearBlack", SystemClearBlackColor},
    {9, "AliceBlue", 0xF0F8FF},
    {12, "AntiqueWhite", 0xFAEBD7},
    {4, "Aqua", 0x00FFFF},
    {10, "Aquamarine", 0x7FFFD4},
    {5, "Azure", 0xF0FFFF},
    {5, "Beige", 0xF5F5DC},
    {6, "Bisque", 0xFFE4C4},
    {5, "Black", 0x000000},
    {14, "BlanchedAlmond", 0xFFEBCD},
    {4, "Blue", 0x0000FF},
    {10, "BlueViolet", 0x8A2BE2},
    {5, "Brown", 0xA52A2A},
    {9, "BurlyWood", 0xDEB887},
    {9, "CadetBlue", 0x5F9EA0},
    {10, "Chartreuse", 0x7FFF00},
    {9, "Chocolate", 0xD2691E},
    {5, "Coral", 0xFF7F50},
    {14, "CornflowerBlue", 0x6495ED},
    {8, "Cornsilk", 0xFFF8DC},
    {7, "Crimson", 0xDC143C},
    {4, "Cyan", 0x00FFFF},
    {8, "DarkBlue", 0x00008B},
    {8, "DarkCyan", 0x008B8B},
    {13, "DarkGoldenRod", 0xB8860B},
    {8, "DarkGray", 0xA9A9A9},
    {9, "DarkGreen", 0x006400},
    {9, "DarkKhaki", 0xBDB76B},
    {11, "DarkMagenta", 0x8B008B},
    {14, "DarkOliveGreen", 0x556B2F},
    {10, "Darkorange", 0xFF8C00},
    {10, "DarkOrchid", 0x9932CC},
    {7, "DarkRed", 0x8B0000},
    {10, "DarkSalmon", 0xE9967A},
    {12, "DarkSeaGreen", 0x8FBC8F},
    {13, "DarkSlateBlue", 0x483D8B},
    {13, "DarkSlateGray", 0x2F4F4F},
    {13, "DarkTurquoise", 0x00CED1},
    {10, "DarkViolet", 0x9400D3},
    {8, "DeepPink", 0xFF1493},
    {11, "DeepSkyBlue", 0x00BFFF},
    {7, "DimGray", 0x696969},
    {10, "DodgerBlue", 0x1E90FF},
    {9, "FireBrick", 0xB22222},
    {11, "FloralWhite", 0xFFFAF0},
    {11, "ForestGreen", 0x228B22},
    {7, "Fuchsia", 0xFF00FF},
    {9, "Gainsboro", 0xDCDCDC},
    {10, "GhostWhite", 0xF8F8FF},
    {4, "Gold", 0xFFD700},
    {9, "GoldenRod", 0xDAA520},
    {4, "Gray", 0x808080},
    {5, "Green", 0x008000},
    {11, "GreenYellow", 0xADFF2F},
    {8, "HoneyDew", 0xF0FFF0},
    {7, "HotPink", 0xFF69B4},
    {9, "IndianRed", 0xCD5C5C},
    {6, "Indigo", 0x4B0082},
    {5, "Ivory", 0xFFFFF0},
    {5, "Khaki", 0xF0E68C},
    {8, "Lavender", 0xE6E6FA},
    {13, "LavenderBlush", 0xFFF0F5},
    {9, "LawnGreen", 0x7CFC00},
    {12, "LemonChiffon", 0xFFFACD},
    {9, "LightBlue", 0xADD8E6},
    {10, "LightCoral", 0xF08080},
    {9, "LightCyan", 0xE0FFFF},
    {20, "LightGoldenRodYellow", 0xFAFAD2},
    {9, "LightGrey", 0xD3D3D3},
    {10, "LightGreen", 0x90EE90},
    {9, "LightPink", 0xFFB6C1},
    {11, "LightSalmon", 0xFFA07A},
    {13, "LightSeaGreen", 0x20B2AA},
    {12, "LightSkyBlue", 0x87CEFA},
    {14, "LightSlateGray", 0x778899},
    {14, "LightSteelBlue", 0xB0C4DE},
    {11, "LightYellow", 0xFFFFE0},
    {4, "Lime", 0x00FF00},
    {9, "LimeGreen", 0x32CD32},
    {5, "Linen", 0xFAF0E6},
    {7, "Magenta", 0xFF00FF},
    {6, "Maroon", 0x800000},
    {16, "MediumAquaMarine", 0x66CDAA},
    {10, "MediumBlue", 0x0000CD},
    {12, "MediumOrchid", 0xBA55D3},
    {12, "MediumPurple", 0x9370D8},
    {14, "MediumSeaGreen", 0x3CB371},
    {15, "MediumSlateBlue", 0x7B68EE},
    {17, "MediumSpringGreen", 0x00FA9A},
    {15, "MediumTurquoise", 0x48D1CC},
    {15, "MediumVioletRed", 0xC71585},
    {12, "MidnightBlue", 0x191970},
    {9, "MintCream", 0xF5FFFA},
    {9, "MistyRose", 0xFFE4E1},
    {8, "Moccasin", 0xFFE4B5},
    {11, "NavajoWhite", 0xFFDEAD},
    {4, "Navy", 0x000080},
    {7, "OldLace", 0xFDF5E6},
    {5, "Olive", 0x808000},
    {9, "OliveDrab", 0x6B8E23},
    {6, "Orange", 0xFFA500},
    {9, "OrangeRed", 0xFF4500},
    {6, "Orchid", 0xDA70D6},
    {13, "PaleGoldenRod", 0xEEE8AA},
    {9, "PaleGreen", 0x98FB98},
    {13, "PaleTurquoise", 0xAFEEEE},
    {13, "PaleVioletRed", 0xD87093},
    {10, "PapayaWhip", 0xFFEFD5},
    {9, "PeachPuff", 0xFFDAB9},
    {4, "Peru", 0xCD853F},
    {4, "Pink", 0xFFC0CB},
    {4, "Plum", 0xDDA0DD},
    {10, "PowderBlue", 0xB0E0E6},
    {6, "Purple", 0x800080},
    {3, "Red", 0xFF0000},
    {9, "RosyBrown", 0xBC8F8F},
    {9, "RoyalBlue", 0x4169E1},
    {11, "SaddleBrown", 0x8B4513},
    {6, "Salmon", 0xFA8072},
    {10, "SandyBrown", 0xF4A460},
    {8, "SeaGreen", 0x2E8B57},
    {8, "SeaShell", 0xFFF5EE},
    {6, "Sienna", 0xA0522D},
    {6, "Silver", 0xC0C0C0},
    {7, "SkyBlue", 0x87CEEB},
    {9, "SlateBlue", 0x6A5ACD},
    {9, "SlateGray", 0x708090},
    {4, "Snow", 0xFFFAFA},
    {11, "SpringGreen", 0x00FF7F},
    {9, "SteelBlue", 0x4682B4},
    {3, "Tan", 0xD2B48C},
    {4, "Teal", 0x008080},
    {7, "Thistle", 0xD8BFD8},
    {6, "Tomato", 0xFF6347},
    {9, "Turquoise", 0x40E0D0},
    {6, "Violet", 0xEE82EE},
    {5, "Wheat", 0xF5DEB3},
    {5, "White", 0xFFFFFF},
    {10, "WhiteSmoke", 0xF5F5F5},
    {6, "Yellow", 0xFFFF00},
    {11, "YellowGreen", 0x9ACD32}
} ;
        
const int scalarKeysSize = sizeof(scalarKeys)/sizeof(scalarKeys[0]) ;



//------------------------------------------------------------------------------------
static Boolean equalCallBack (const void *value1, const void *value2 )
{
    const NameAndLength *c1 = (const NameAndLength*)value1 ;
    const NameAndLength *c2 = (const NameAndLength*)value2 ;

    if ( c1->len != c2->len ) return false ; 
    return strncasecmp( c1->cName, c2->cName, c1->len ) == 0 ;
}

//------------------------------------------------------------------------------------
static CFHashCode hashCallBack( const void *value )
{
    const NameAndLength *c1 = (const NameAndLength*)value ;
    CFHashCode hash = 0 ;
    if ( c1->len > 0 ) hash = tolower(c1->cName[0]) ;
    if ( c1->len > 1 ) hash = (hash<<8) + tolower(c1->cName[1]) ;
    return hash ;
}

//------------------------------------------------------------------------------------
static CFDictionaryRef themesDictionary()
{
    if ( theThemesDictionary == NULL )
    {
        const NameAndLength *keys[scalarKeysSize] ;
        const void *values[scalarKeysSize] ;
        
        for ( int i=0 ; i<scalarKeysSize; i++ )
        {
            keys[i] = scalarKeys+i ;
            values[i] = (void *)(long)(scalarKeys[i].themeRgb) ;
        }
        
        const CFDictionaryKeyCallBacks keyCallBacks = 
        { 
            0, NULL, NULL, NULL, equalCallBack, hashCallBack 
        } ;
    
        theThemesDictionary = CFDictionaryCreate(NULL, (const void **)keys, (const void **)values, scalarKeysSize, &keyCallBacks, NULL) ;

    }
    return theThemesDictionary ;
}

/*
UInt32 getRgbValueForCName_lenV( UInt8 *cstr, const int len )
{
    UInt32 tagRgbColor = 0 ;
    if ( len > 0 )
    {
        if ( cstr[0] == '#' )
        {
            if ( len > 1 )
            {
                tagRgbColor = strtol_l((char *)cstr+1, NULL, 16, NULL) ;
                SetTheme_toRgbColor(0, tagRgbColor) ;
            }
        }
        else
        {
            const NameAndLength c1 = { len, (char*)cstr } ;
            CFDictionaryRef colorsDict = themesDictionary() ;
            tagRgbColor = (UInt32)CFDictionaryGetValue(colorsDict, &c1) ;
        }
    }
    if ( tagRgbColor == 0 ) tagRgbColor = TheSystemDarkBlueTheme ;
    return tagRgbColor ;
}
*/


UInt32 getRgbValueForCName_len( const UInt8 *cstr, const int len )
{
//    UInt32 tagRgbColor = 0 ;
    if ( len > 0 )
    {
        if ( cstr[0] == '#' )
        {
            if ( len > 1 )
            {
                char *endPtr;
                UInt32 tagRgbColor = strtoul_l((char *)cstr+1, &endPtr, 16, NULL) ;
                
                if ( *endPtr == '/' )
                {
                    UInt32 o = strtoul_l(endPtr+1, NULL, 16, NULL);
                    tagRgbColor = Theme_RGBA(0,ThemeR(tagRgbColor),ThemeG(tagRgbColor),ThemeB(tagRgbColor),(o>>1));
                }
                
                SetTheme_toRgbColor(0, tagRgbColor) ;
                return tagRgbColor ;
            }
        }
        else
        {
            const NameAndLength c1 = { len, (char*)cstr } ;
            const void *dictRgbValue ;
            CFDictionaryRef colorsDict = themesDictionary() ;
            Boolean found = CFDictionaryGetValueIfPresent(colorsDict, &c1, &dictRgbValue ) ;
            if ( found ) return (UInt32)dictRgbValue ;
        }
    }
    
    return TheSystemDarkBlueTheme ;
}

UInt32 getRgbValueForString( NSString *colorStr )
{
    UInt32 rgbColor = TheSystemDarkBlueTheme ;
    const char *cStr = [colorStr cStringUsingEncoding:NSASCIIStringEncoding] ;
    if ( cStr ) rgbColor = getRgbValueForCName_len( (UInt8*)cStr, [colorStr length] ) ;
    return rgbColor ;
}


//NSString* getColorStrForRgbValue_V(UInt32 value)
//{    
//    for (int i=0; i<scalarKeysSize; ++i) 
//    {
//        if (scalarKeys[i].themeRgb == value) 
//        {
//            NSString *str = [NSString stringWithCString:scalarKeys[i].cName encoding:NSUTF8StringEncoding];
//            return str;
//        }
//    }
//    return nil;
//}


NSString* getColorStrForRgbValue(UInt32 rgbColor)
{
    NSString *str = nil;
    for (int i=0; i<scalarKeysSize; ++i) 
    {
        if (scalarKeys[i].themeRgb == rgbColor)
        {
            str = [NSString stringWithCString:scalarKeys[i].cName encoding:NSUTF8StringEncoding];
            break;
        }
    }
    
    if ( str == nil )
    {
        int r = ThemeR(rgbColor);
        int g = ThemeG(rgbColor);
        int b = ThemeB(rgbColor);
        int o = ThemeA(rgbColor);
        if ( o == 0 )   // totalment opac
        {
            str = [NSString stringWithFormat:@"#%02X%02X%02X", r, g, b ];
        }
        else
        {
            str = [NSString stringWithFormat:@"#%02X%02X%02X/%02X", r, g, b, (o<<1) ];
        }
    }
    
    return str;
}


NSArray* getAllColorStr()
{    
    NSMutableArray *colors = [NSMutableArray array];
    
    for (int i=0; i<scalarKeysSize; ++i) 
    {
        NSString *str = [NSString stringWithCString:scalarKeys[i].cName encoding:NSUTF8StringEncoding];
        [colors addObject:str];
    }    
    
    return colors;
}





//// Deprecated, Removed
//
//UIColor* colorFromExpression(SWExpression *exp) 
//{    
//    UInt32 colorValue = Theme_RGB(0, 255, 255, 255) ;   // per defecte blanc  (podria ser negre o gris fosc)
//    ExpressionValueType valueType = [exp valueType] ;
//    
//    // s'em ha acudit que en la expressio podem tornar tant el valor del color retornat per SM.color 
//    // com directament una string amb el nom del color (per cert coses com "#FFAAFF" tambe se suporten)
//    // segons el tipus del resultat de la expressio (numeric, o string) interpretem una cosa o l'altre
//    
//    // utilitzacio de SM.Color  ( retorna un 'colorValue' numeric ) (normalment nomes fariem això)
//    if ( valueType == ExpressionValueTypeNumber ) colorValue = [exp valueAsDouble];
//    
//    // suport per el nom del color directament ( retorna una string, per exemple "blue" )
//    if ( valueType == ExpressionValueTypeString ) colorValue = getRgbValueForString([exp valueAsStringWithFormat:nil]) ;
//    
//    return UIColorWithRgb(colorValue) ;
//}
//
//UInt32 getRgbValueFromExpression(SWExpression *exp)
//{
//    UInt32 colorValue = Theme_RGB(0, 255, 255, 255);
//    ExpressionValueType valueType = [exp valueType];
//    
//    if ( valueType == ExpressionValueTypeNumber ) 
//        colorValue = [exp valueAsDouble];
//    
//    if ( valueType == ExpressionValueTypeString ) 
//        colorValue = getRgbValueForString([exp valueAsStringWithFormat:nil]) ;
//    
//    return colorValue;
//}


