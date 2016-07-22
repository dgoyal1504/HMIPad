//
//  SWFontPickerViewController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWAssetFilePickerViewController.h"
#import "SWTableSectionHeaderView.h"

#import "UIImage+Resize.h"
#import "SWColor.h"
@interface SWAssetFilePickerViewController ()

@end

@implementation SWAssetFilePickerViewController

@synthesize selectedFileName = _selectedFileName;
@synthesize delegate = _delegate;


- (id)initWithContentsAtPath:(NSString*)path
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _path = path;
        _filePaths = [NSMutableArray array];
        
        [self _loadFiles];
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    //[self setSelectedFileName:_selectedFileName];
    
    self.tableView.rowHeight = 40;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UITableView *table = self.tableView;
    
    [table scrollToRowAtIndexPath:[table indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}


//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}



- (void)setSelectedFileName:(NSString*)fileName;
{
    _selectedFilePath = [_path stringByAppendingPathComponent:fileName];

    NSInteger index = [_filePaths indexOfObject:_selectedFilePath];
    if ( index < _filePaths.count )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}


#pragma mark Private Methods


- (NSInteger)_indexForFileName:(NSString*)fileName
{
    NSInteger index = [_filePaths indexOfObject:fileName];
    return index;
}

- (void)_loadFiles
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
        if ([[UIImage supportedFileFormats] containsObject:extension])  // saltem les imatges (just el contrari del que fem a SWImagePickerController)
            continue;
        
        [_filePaths addObject:path];
    }
}



#pragma mark Protocol TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filePaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        if ( IS_IOS7 )
        {
        
        }
        else
        {
            cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            UIColor *color = UIColorWithRgb(getRgbValueForString(@"lightblue"));
            view.backgroundColor = color;
            [cell setSelectedBackgroundView:view];
        }
        
    }
    
    NSString *filePath = [_filePaths objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"\"%@\"", filePath.lastPathComponent];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    SWTableSectionHeaderView *header = [[SWTableSectionHeaderView alloc] initWithHeight:30];
//    header.title = [_fontFamilyNames objectAtIndex:section];
//    return header;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 50;
//}


//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    NSMutableArray *titles = [NSMutableArray array];
//    NSMutableArray *mapping = [NSMutableArray array];
//    
//    NSInteger index = 0;
//    
//    for(NSString *section in _fontFamilyNames) 
//    {
//        NSString *firstLetter = [[section substringToIndex:1] uppercaseString];
//        NSString *lastTitle = [titles lastObject];
//        
//        if (![firstLetter isEqualToString:lastTitle]) 
//        {
//            [titles addObject:firstLetter];
//            [mapping addObject:[NSNumber numberWithInteger:index]];
//        }
//             
//        ++index;
//    }
//    
//    _indexTitles = [mapping copy];
//    return [titles copy];
//}
//
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    NSMutableArray *titles = [NSMutableArray array];
//    NSMutableArray *mapping = [NSMutableArray array];
//    
//    NSInteger index = 0;
//    
//    for(NSString *section in _fontFamilyNames) 
//    {
//        NSString *firstLetter = [[section substringToIndex:1] uppercaseString];
//        NSString *lastTitle = [titles lastObject];
//        
//        if (![firstLetter isEqualToString:lastTitle]) 
//        {
//            [titles addObject:firstLetter];
//            [mapping addObject:[NSNumber numberWithInteger:index]];
//        }
//             
//        ++index;
//    }
//    
//    _indexTitles = [mapping copy];
//    return [titles copy];
//}
//
//
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return [[_indexTitles objectAtIndex:index] integerValue];
//}

#pragma mark Protocol TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedFilePath = [_filePaths objectAtIndex:indexPath.row];
    
    [_delegate assetFilePicker:self didSelectAssetAtPath:_selectedFilePath];
}

@end



