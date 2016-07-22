//
//  SWImagePickerController.m
//  ImagePicker
//
//  Created by Joan Martín Hernàndez on 7/3/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWImagePickerController.h"

@implementation SWImagePickerController
{
    SWImagePickerView *_imagePickerView;
    
    NSMutableArray *_imagePaths;
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
    if (self) {
        _path = path;
        _imagePaths = [NSMutableArray array];
        _allowsDeletion = YES;
        
        [self _loadImages];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _imagePickerView = [[SWImagePickerView alloc] initWithFrame:self.view.frame];
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
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

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

#pragma mark Private Methods

- (NSArray*)allowedExtensions
{
    static NSArray *array = nil;
    if (!array) {
        array = [NSArray arrayWithObjects:@"jpg",@"png",@"jpeg",@"gif", nil];
    }
    return array;
}

- (void)_loadImages
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *array = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:_path] 
                                includingPropertiesForKeys:nil 
                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                                     error:&error];
    
    if (error) {
        NSLog(@"ERROR: %@",error.description);
        return;
    }
    
    for (NSURL *urlPath in array) {
        NSString *path = urlPath.path;
        
        BOOL isDirectory = NO;
        [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
        
        if (isDirectory)
            continue;
        
        NSString *extension = [path pathExtension];
        
        if (![[self allowedExtensions] containsObject:extension])
            continue;
        
        [_imagePaths addObject:path];
    }
}

- (void)_setupToolbarAnimated:(BOOL)animated
{
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(_trash:)];
    UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(_action:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:delete,flex,action, nil];
    
    if (!_allowsDeletion)
        [items removeObject:delete];
    
    [self setToolbarItems:[items copy] animated:animated];
}

- (void)_trash:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSIndexSet *set = _imagePickerView.selectedImages;
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
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

- (UIImage*)imagePickerView:(SWImagePickerView *)imagePickerView imageAtIndex:(NSInteger)index
{
    return [[UIImage alloc] initWithContentsOfFile:[_imagePaths objectAtIndex:index]];
}

#pragma mark Protocol ImagePickerDelegate

- (void)imagePickerView:(SWImagePickerView *)imagePickerView didSelectImageAtIndex:(NSInteger)index
{
    if ([_delegate respondsToSelector:@selector(imagePickerController:didSelectImage:)]) {
        [_delegate imagePickerController:self didSelectImage:[[UIImage alloc] initWithContentsOfFile:[_imagePaths objectAtIndex:index]]];
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
