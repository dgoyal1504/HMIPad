//
//  SWImagePickerController.m
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWImagePickerController.h"
#import "SWImagePickerView.h"
#import "UIImage+Resize.h"

@interface SWImagePickerController () <SWImagePickerViewDelegate, SWImagePickerViewDataSource>

@end

@implementation SWImagePickerController
{
    SWImagePickerView *_imagePickerView;
    
    NSMutableArray *_imagePaths;
    NSString *_selectedImagePath;
}

@synthesize path = _path;
@synthesize allowsDeletion = _allowsDeletion;
@synthesize delegate = _delegate;

#pragma mark Overriden Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithContentsAtPath:nil];
}

- (id)initWithContentsAtPath:(NSString*)path
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _path = path;
        _imagePaths = [NSMutableArray array];
        _allowsDeletion = YES;
        
        [self _loadImages];
    }
    return self;
}

- (void)dealloc
{
    //NSLog( @"SWImagePickerController Dealloc" );
}

- (void)loadView
{
//    [super loadView];
//    _imagePickerView = [[SWImagePickerView alloc] initWithFrame:self.view.bounds];
    _imagePickerView = [[SWImagePickerView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    _imagePickerView.delegate = self;
    _imagePickerView.dataSource = self;
    _imagePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imagePickerView.borderedImages = YES;
    
    self.view = _imagePickerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_imagePickerView reloadData];
    
//    NSInteger index = [_imagePaths indexOfObject:_selectedImagePath];
//    [_imagePickerView selectImagesAtIndexes:[NSIndexSet indexSetWithIndex:index]];
//    [_imagePickerView highlightImageAtIndex:index];
    
    [self _setupToolbarAnimated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( _selectedImagePath )
    {
        NSInteger index = [_imagePaths indexOfObject:_selectedImagePath];
        [_imagePickerView highlightImageAtIndex:index];
    }
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return YES;
//}

#pragma mark Properties

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    _imagePickerView.editing = editing;
    
    [self.navigationController setToolbarHidden:!editing animated:YES];
}

- (void)setAllowsDeletion:(BOOL)allowsDeletion
{
    if (_allowsDeletion == allowsDeletion) 
        return;
    
    _allowsDeletion = allowsDeletion;
    
    [self _setupToolbarAnimated:YES];
}

- (void)setSelectedFileName:(NSString*)fileName;
{
    _selectedImagePath = [_path stringByAppendingPathComponent:fileName];
    if ( _imagePickerView )
    {
        NSInteger index = [_imagePaths indexOfObject:_selectedImagePath];
        //[_imagePickerView selectImagesAtIndexes:[NSIndexSet indexSetWithIndex:index]];
        [_imagePickerView highlightImageAtIndex:index];
    }
}

#pragma mark Private Methods


- (void)_loadImages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *array = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:_path] 
                                includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                                     error:&error];
    
    if (error)
    {
        //NSLog(@"ERROR: %@",error.description);
        return;
    }
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    NSMutableArray *redundantPaths = [NSMutableArray array];
    
    for (NSURL *urlPath_ in array)
    {
        NSURL *urlPath = [urlPath_ URLByStandardizingPath];    // <- Atenció això es necesari
        NSString *path = [urlPath path];
        
//        // ATENCIO: no podem utilitzar simplement NSString *path = urlPath.path; perque per algun extrany motiu
//        // en el dispositiu obtenim paths de l'estil /private/var/Aplications/82F2...documentFiles/bg_calm.jpg
//        // en canvi _path es simplement /private/var/Aplications/82F2...documentFiles/
//        // Aquesta diferencia fa fallar la comparacio de _selectedImagePath amb els _imagePaths
//        // La solucio es generar els _imagePaths directament a partir del _path
//        
//        NSString *path = [_path stringByAppendingPathComponent:[urlPath lastPathComponent]];
        
        NSNumber *isDirectory = nil;
        if ( ![urlPath getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil] )
            continue;
        
        if ( [isDirectory boolValue] )
            continue;
        
        NSString *extension = [path pathExtension];
        
        if (![[UIImage supportedFileFormats] containsObject:extension])
            continue;
        
        NSString *cleanPath = [path stringByReplacingOccurrencesOfString:@"@2x" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
        
        if ( ![path isEqualToString:cleanPath] )
        {
            if ( scale == 2.0f )
            {
                // prioritzem les que tenen @2x
                [redundantPaths addObject:cleanPath];
            }
            else
            {
                // saltem les que tenen @2x
                continue ;
            }
        }
        
        [_imagePaths addObject:path];
    }
    
    [_imagePaths removeObjectsInArray:redundantPaths];
}




//- (void)_loadImagesNN
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error = nil;
//    NSArray *array = [fileManager contentsOfDirectoryAtPath:_path error:&error];
//    
//    if (error)
//    {
//        NSLog(@"ERROR: %@",error.description);
//        return;
//    }
//    
//    CGFloat scale = [[UIScreen mainScreen] scale];
//    NSMutableArray *redundantPaths = [NSMutableArray array];
//    
//    for (NSString *fileName in array)
//    {
//        // ATENCIO, en una implementacio anterior utilitzavem contentsOfDirectoryAtURL i determinavem el
//        // path amb fileURL.path
//    
//        NSString *path = [_path stringByAppendingPathComponent:fileName];
//        
//        BOOL isDirectory = NO;
//        [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
//        
//        if (isDirectory)
//            continue;
//        
//        NSString *extension = [path pathExtension];
//        
//        if (![[UIImage supportedFileFormats] containsObject:extension])
//            continue;
//        
//        NSString *cleanPath = [path stringByReplacingOccurrencesOfString:@"@2x" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
//        
//        if ( ![path isEqualToString:cleanPath] )
//        {
//            if ( scale == 2.0f )
//            {
//                // prioritzem les que tenen @2x
//                [redundantPaths addObject:cleanPath];
//            }
//            else
//            {
//                // saltem les que tenen @2x
//                continue ;
//            }
//        }
//        
//        [_imagePaths addObject:path];
//    }
//    
//    [_imagePaths removeObjectsInArray:redundantPaths];
//}



- (void)_setupToolbarAnimated:(BOOL)animated
{
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(_trash:)];
    UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(_action:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:delete,flex,action, nil];
    
    if (!_allowsDeletion)
    {
        [items removeObject:delete];
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:self.editButtonItem animated:animated];
    }
    
    [self setToolbarItems:[items copy] animated:animated];
}

- (void)_trash:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSIndexSet *set = _imagePickerView.selectedImageIndexes;
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        NSString *path = [_imagePaths objectAtIndex:idx];
        
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        
        if (error)
            NSLog(@"ERROR DELETING IMAGE: %@ AT PATH: %@",error.description,path);
    }];
    
    [_imagePaths removeObjectsAtIndexes:set];
    [_imagePickerView deleteImagesAtIndexes:set];
}

- (void)_action:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What do you want to do?",nil) 
                                                             delegate:self 
                                                    cancelButtonTitle:@"Dismiss" 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    UIBarButtonItem *item = sender;
    [actionSheet showFromBarButtonItem:item animated:YES];
}

#pragma mark Protocol ImagePickerViewDataSource

- (NSInteger)numberOfImagesForImagePickerView:(SWImagePickerView *)imagePickerView
{
    return _imagePaths.count;
}

//- (UIImage*)imagePickerView:(SWImagePickerView *)imagePickerView imageAtIndex:(NSInteger)index
//{
//    return [[UIImage alloc] initWithContentsOfFile:[_imagePaths objectAtIndex:index]];
//}

- (NSString*)imagePickerView:(SWImagePickerView *)imagePickerView imagePathAtIndex:(NSInteger)index
{
    return [_imagePaths objectAtIndex:index];
}

#pragma mark Protocol ImagePickerDelegate

- (void)imagePickerView:(SWImagePickerView *)imagePickerView didSelectImageAtIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(imagePickerController:didSelectImageAtPath:)])
    {
    
        _selectedImagePath = [_imagePaths objectAtIndex:index];
        NSString *cleanPath = [_selectedImagePath stringByReplacingOccurrencesOfString:@"@2x"
            withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, _selectedImagePath.length)];
    
        [_delegate imagePickerController:self didSelectImageAtPath:cleanPath];
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) 
    {
        // Nothing to do
    } 
    else if (buttonIndex == actionSheet.destructiveButtonIndex) 
    {
        // Nothing to do
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex) 
    {
        // Todo
    }
//    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) 
//    {
//        // Todo
//    }

}

@end
