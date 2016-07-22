//
//  AppModelCommon.h
//  HmiPad
//
//  Created by Joan on 05/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

enum
{
    kFileCategoryUnknown = 0,
    kFileCategorySourceFile,
    kFileCategoryRecipe,
    kFileCategoryAssetFile,
    kFileCategoryDatabase,
    
    //kFileCategoryRedeemedSourceFile,   // a eliminar
    kFileCategoryEmbeddedAssetFile,
    
    kFileCategoryTemporarySourceFile,
    kFileCategoryTemporaryBundledFile,
    kFileCategoryTemporaryEmbedeedAssetFile,
    
    kExtFileCategoryITunes = 10,
    kExtFileCategoryICloud,
    
    kExtFileCategoryMainBundle = 20,
};
    
    
enum
{
    // arxius i d'altres en el servidor
    kFileCategoryRemoteSourceFile = 30,
    kFileCategoryRemoteAssetFile,
    kFileCategoryRemoteActivationCode,
    kFileCategoryRemoteRedemption,
    
    // projectes i assets que s'estant baixant agrupats del servidor
    kFileCategoryRemoteGroupSourceFile,
    kFileCategoryRemoteGroupAssetFile,
    
    // projectes i assets que s'estant redimint del servidor
    //kFileCategoryRemoteGroupRedeemedSourceFile,
    //kFileCategoryRemoteGroupRedeemedAssetFile,
};

typedef int FileCategory;
//typedef int FileCategory;
