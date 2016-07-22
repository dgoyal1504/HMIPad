//
//  SWPageNavigatorController.m
//  HmiPad
//
//  Created by Joan Martin on 1/16/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWPageNavigatorController.h"

#import "SWPageNavigatorCell.h"
#import "SWDocumentController.h"

#import "SWDocumentModel.h"
#import "SWPage.h"
#import "SWValue.h"

#import "SWImageManager.h"
#import "SWPasteboardTypes.h"


NSString * const SWPageNavigatorControllerHasVisiblePagesNotification = @"SWPageNavigatorControllerHasVisiblePagesNotification";

@interface SWPageNavigatorController () <DocumentModelObserver /*,SWPageNavigatorCellDelegate*/ >
{
    CALayer *_lineLayer;
    NSArray *_visiblePages;
    BOOL _editingMode;
    BOOL _waitChangePageVisibility;
}
@end

@implementation SWPageNavigatorController

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self initWithDocumentModel:nil];
}

- (id)initWithDocumentModel:(SWDocumentModel*)documentModel
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _documentModel = documentModel;
        _visiblePages = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *tableView = self.tableView;
    
    NSString *nibName = IS_IPHONE?SWPageNavigatorCellNibName_Phone:SWPageNavigatorCellNibName;
    [tableView setShowsVerticalScrollIndicator:!IS_IPHONE];
    
    UINib *cellNib = [UINib nibWithNibName:nibName bundle:nil];
    [tableView registerNib:cellNib forCellReuseIdentifier:SWPageNavigatorCellIdentifier];
    
    tableView.rowHeight = [SWPageNavigatorCell preferredHeight];

    
    tableView.allowsSelection = YES;
    tableView.delaysContentTouches = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //    tableView.backgroundView = [[UIView alloc] init];
//    tableView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
    
    tableView.backgroundColor = [UIColor clearColor];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:tableView.bounds];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toolbar.barTintColor = nil;
    toolbar.translucent = YES;
    //toolbar.barTintColor = [UIColor colorWithRed:1 green:0.25 blue:0.25 alpha:0.0];
   // [toolbar setBarStyle:UIBarStyleBlack];
    
    tableView.backgroundView = toolbar;
    
    _lineLayer = [[CALayer alloc] init];
    [_lineLayer setBackgroundColor:[UIColor darkGrayColor].CGColor];
    //[self.view.layer addSublayer:_lineLayer];
    [tableView.backgroundView.layer addSublayer:_lineLayer];
    [tableView setClipsToBounds:NO];
}


- (void)viewDidLayoutSubviews
{
//    UIView *selfView = self.view;
//    CGRect bounds = selfView.bounds;
//    _lineLayer.frame = CGRectMake(bounds.size.width-1, 0, 1, bounds.size.height);
    
    UITableView *table = self.tableView;
    UIView *view = [table backgroundView];
    CGRect bounds = view.bounds;
    //_lineLayer.frame = CGRectMake(bounds.size.width, 0, 0.5, bounds.size.height);
    
    CGFloat contentScale = [[UIScreen mainScreen] scale];
    CGFloat pixelWidth = 1/contentScale;
    
    _lineLayer.frame = CGRectMake(bounds.size.width, 0, pixelWidth, bounds.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_documentModel addObserver:self];
    [self _reloadVisiblePages];
    
    UITableView *table = self.tableView;
    [table reloadData];
    
    NSInteger selectedPageIndex = _documentModel.selectedPageIndex;
    
    NSIndexPath *indexPath = [self _convertIndexPathToControllerFromModelIndexPath:
        [NSIndexPath indexPathForRow:selectedPageIndex inSection:0]];
    
    if ( indexPath )
    {
        [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
//    [self _notifyHasVisiblePages];
    
//    if ( selectedPageIndex != NSNotFound )
//    {
//        [table selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedPageIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
//    }


}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_documentModel removeObserver:self];
    _visiblePages = nil;  // <<-- no volem retenir les pagines
    //[_visiblePages removeAllObjects];  // <<-- no volem retenir les pagines
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [_documentModel removeObserver:self];
}


//- (void)pageDidGetThumbnailNotification:(NSNotification*)note
//{
//    SWPage *page = note.object;
//    
//    NSArray *visibleCells = [self.tableView visibleCells];
//    for ( SWPageNavigatorCell *cell in visibleCells )
//    {
//        if ( cell.page == page )
//        {
//            UIImage *image = note.userInfo[@1];
//            [cell.previewImageView setImage:image];
//            break;
//        }
//    }
//}


#pragma mark private

- (void)_reloadVisiblePages
{
    //[_visiblePages removeAllObjects];
    
    BOOL editMode = _documentModel.editMode;
    _editingMode = editMode;
    
    if ( editMode )
        return;
    
//    for ( SWPage *page in _documentModel.pages )
//    {
//        BOOL isHidden = [page.hidden valueAsBool];
//        if ( !isHidden )
//        {
//            [_visiblePages addObject:page];
//        }
//    }
    
    _visiblePages = [_documentModel visiblePages];
    
}

//- (void)_notifyHasVisiblePages
//{
//    NSArray *dataSource = [self _currentDataSource];
//    BOOL hasPages = (dataSource.count > 0 );
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc postNotificationName:SWPageNavigatorControllerHasVisiblePagesNotification object:nil userInfo:@{@"info":@(hasPages)}];
//}


- (NSArray*)_currentDataSource
{
    if ( _editingMode )
        return _documentModel.pages;
    
    return _visiblePages;
}


- (void)_updateTableViewRowsAnimated:(BOOL)animated
{
    NSMutableIndexSet *addSections = [NSMutableIndexSet indexSet] ;
    NSMutableIndexSet *remSections = [NSMutableIndexSet indexSet] ;
    NSMutableArray *addRowPaths = [NSMutableArray array];
    NSMutableArray *remRowPaths = [NSMutableArray array];
    
    BOOL newEditMode = _documentModel.editMode;
    
    NSArray *modelSections = @[_documentModel.pages];       // <-- una unica seccio amb les pagines
    NSArray *dataSections = @[[self _currentDataSource]];   // <-- una unica seccio amb les pagines
    
    NSInteger si = 0;
    NSInteger sj = 0;
    NSInteger sa = 0;
    
    NSInteger sicount = modelSections.count ;    // model sections count
    NSInteger sjcount = dataSections.count ;    // datasource sections count
    
    if ( sicount == 0 )
    {
        for ( sj=0 ; sj<sjcount ; sj++ )
        {
            [remSections addIndex:sj];
        }
    }
    
    for ( si=0 ; si<sicount ; si++ )
    {
        NSArray *mSection = [modelSections objectAtIndex:si] ;
        NSArray *dSection = (sj<sjcount) ? [dataSections objectAtIndex:sj] : nil ;
        BOOL sectionHidden = /*[mSection isHidden]*/ NO;
        
        // la mateixa seccio existeix
        if ( /*mSection == [dSection parent]*/ YES )   // el parent conte en aquest cas la seccio del model (veure dataSourceSections)
        {
            // pot ser que s'hagi d'eliminar
            if ( sectionHidden ) 
            {
                [remSections addIndex:sj] ;
            }

            // o actualitzar les files
            else
            {
                NSArray *mRows = mSection;
                NSArray *dRows = dSection;
            
                NSInteger ii, ij, ia;
                ii = 0, ij = 0, ia = 0 ;
                NSInteger iicount = [mRows count] ;
                NSInteger ijcount = [dRows count] ;
                for ( ii=0 ; ii<iicount ; ii++ )
                {
                    SWPage *mItem = [mRows objectAtIndex:ii] ;
                    SWPage *dItem = ij<ijcount ? [dRows objectAtIndex:ij] : nil ;
                    //BOOL itemHidden = [mItem.hidden valueAsBool] && !newEditMode;
                    BOOL itemHidden = ![_documentModel pageIsVisible:mItem] && !newEditMode;
                    if ( mItem == dItem )
                    {
                        if ( itemHidden ) [remRowPaths addObject:[NSIndexPath indexPathForRow:ij inSection:sj]] ;
                        else ia++ ;
                        ij++ ;
                    }
                    else
                    {
                        if ( !itemHidden ) [addRowPaths addObject:[NSIndexPath indexPathForRow:ia++ inSection:sa]] ;
                    }
                }
                
                sa++;
            }
            sj++;
        }
        
        // la mateixa seccio no existeix
        else
        {
            // pot ser que s'hagi de afegir
            if ( sectionHidden == NO ) 
            {
                [addSections addIndex:sa++] ;
                // [self sectionUpdateMRows:mRows dRows:dRows add:addRowPaths rem:remRowPaths] ;
            }
        }
    }

    [self _reloadVisiblePages];

    if ( [remRowPaths count] || [remSections count] || [addSections count] || [addRowPaths count] )
    {
        UITableView *tv = [self tableView] ;
        if ( animated )
        {
            [tv beginUpdates] ;
            [tv deleteRowsAtIndexPaths:remRowPaths withRowAnimation:UITableViewRowAnimationFade] ;
            [tv deleteSections:remSections withRowAnimation:UITableViewRowAnimationFade] ;
            [tv insertSections:addSections withRowAnimation:UITableViewRowAnimationFade] ;
            [tv insertRowsAtIndexPaths:addRowPaths withRowAnimation:UITableViewRowAnimationFade] ;
            [tv endUpdates] ;
        }
        else
        {
            [tv reloadData] ;
        }
    }
    
    //[self _notifyHasVisiblePages];
}


- (NSIndexPath*)_convertIndexPathToControllerFromModelIndexPath:(NSIndexPath*)mIndexPath
{
//    if ( _editingMode )
//        return mIndexPath;

    NSInteger mSection = mIndexPath.section;
    NSInteger mRow = mIndexPath.row;
    
    NSInteger dSection = NSNotFound;
    NSInteger dRow = NSNotFound;
    
    if ( mSection == 0 && mRow != NSNotFound )
    {
        dSection = mSection ;
        
        if ( _editingMode )
        {
            dRow = mRow ;
        }
        else
        {
            NSArray *mRows = _documentModel.pages;
            NSArray *dRows = [self _currentDataSource];

            SWPage *mItem = [mRows objectAtIndex:mRow];
            dRow = [dRows indexOfObjectIdenticalTo:mItem];
        }
    }
    
    NSIndexPath *dIndexPath = nil;
    
    if ( dSection != NSNotFound && dRow != NSNotFound )
        dIndexPath = [NSIndexPath indexPathForRow:dRow inSection:dSection];
    
    return dIndexPath;
}


- (NSIndexPath*)_convertIndexPathToModelFromControllerIndexPath:(NSIndexPath*)dIndexPath
{
    if ( _editingMode )
        return dIndexPath;

    NSInteger dSection = dIndexPath.section;
    NSInteger dRow = dIndexPath.row;
    NSInteger mSection = NSNotFound;
    NSInteger mRow = NSNotFound;

    if ( dSection == 0 )
    {
        mSection = dSection ;
    
        NSArray *mRows = _documentModel.pages;
        NSArray *dRows = [self _currentDataSource];

        SWPage *dItem = [dRows objectAtIndex:dRow];
        mRow = [mRows indexOfObjectIdenticalTo:dItem];
    }
    
    NSIndexPath *mIndexPath = nil;
    
    if ( mSection != NSNotFound && mRow != NSNotFound )
        mIndexPath = [NSIndexPath indexPathForRow:mRow inSection:mSection];
    
    return mIndexPath;
}



#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self _currentDataSource].count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    //SWPageNavigatorCell *cell = [tableView dequeueReusableCellWithIdentifier:SWPageNavigatorCellIdentifier];
    SWPageNavigatorCell *cell = [tableView dequeueReusableCellWithIdentifier:SWPageNavigatorCellIdentifier forIndexPath:indexPath];
    
    //SWPage *page = [_documentModel.pages objectAtIndex:index];
    SWPage *page = [[self _currentDataSource] objectAtIndex:index];
    
    cell.page = page;
    //cell.delegate = self;
    
    return cell;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hello"];
//    if ( cell == nil )
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hello"];
//    }
//    
//    cell.textLabel.text = @"I'm a Cell";
//    
//    return cell;
//}

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}
*/




#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[_documentModel selectPageAtIndex:indexPath.row];
    //NSLog( @"Selected" );
    
    NSIndexPath *modelIndexPath = [self _convertIndexPathToModelFromControllerIndexPath:indexPath];
    
    [_documentModel selectPageAtIndex:modelIndexPath.row];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15f];
    cell.backgroundColor = [UIColor clearColor];
    
    if ( [cell respondsToSelector:@selector(beginObservingModel)] )
        [(SWPageNavigatorCell*)cell beginObservingModel];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ( [cell respondsToSelector:@selector(endObservingModel)] )
        [(SWPageNavigatorCell*)cell endObservingModel];
}


#pragma mark DocumentModelObserver

//- (void)documentModel:(SWDocumentModel *)docModel selectedPageDidChange:(NSInteger)index direction:(NSInteger)direction
//{
//    UITableView *tableView = self.tableView;
//    
//    NSInteger currentIndex = tableView.indexPathForSelectedRow.row;
//    
//    if (index != currentIndex)
//    {
//        UITableViewScrollPosition position = UITableViewScrollPositionNone;
//        
//        if (index < currentIndex)
//            position = UITableViewScrollPositionTop;
//        else
//            position = UITableViewScrollPositionBottom;
//        
//        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:position];
//    }
//}

- (void)documentModel:(SWDocumentModel *)docModel didInsertPagesAtIndexes:(NSIndexSet *)indexes
{
    NSAssert( _editingMode, @"Only in edit Mode" );

    UITableView *tableView = self.tableView;
    
    NSMutableArray *indexPaths = [NSMutableArray array];

    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
//    
//    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_documentModel.selectedPageIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)documentModel:(SWDocumentModel *)docModel didRemovePagesAtIndexes:(NSIndexSet *)indexes
{
    NSAssert( _editingMode, @"Only in edit Mode" );
    
    UITableView *tableView = self.tableView;
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    
//    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_documentModel.selectedPageIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)documentModel:(SWDocumentModel *)docModel didMovePageAtIndex:(NSInteger)index toIndex:(NSInteger)finalIndex
{
    NSAssert( _editingMode, @"Only in edit Mode" );
    
    UITableView *tableView = self.tableView;
    NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:finalIndex inSection:0];
    
    [tableView beginUpdates];
    [tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    [tableView endUpdates];
}


- (void)documentModel:(SWDocumentModel *)docModel selectedPageDidChangeToIndex:(NSInteger)index oldIndex:(NSInteger)oldIndex
{
    NSIndexPath *indexPath = [self _convertIndexPathToControllerFromModelIndexPath:
        [NSIndexPath indexPathForRow:index inSection:0]];
    
    if ( indexPath )
    {
        UITableView *tableView = self.tableView;
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }


//    UITableView *tableView = self.tableView;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}


- (void)documentModel:(SWDocumentModel *)docModel selectedPageDidChange:(NSInteger)index direction:(NSInteger)direction
{
}

- (void)documentModel:(SWDocumentModel *)docModel editingModeDidChangeAnimated:(BOOL)animated
{
    [self _updateTableViewRowsAnimated:YES];
}

- (void)documentModelPagesVisibilityDidChange:(SWDocumentModel *)docModel
{
    if ( _editingMode )
        return;
    
    
    [self _updateTableViewRowsAnimated:YES];
    
//    if ( _waitChangePageVisibility == NO )
//    {
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            _waitChangePageVisibility = NO;
//            [self _updateTableViewRowsAnimated:YES];
//        });
//    }
//    _waitChangePageVisibility = YES;
}



//#pragma mark SWPageNavigatorCellDelegate
//
//- (void)pageNavigatorCellButtonTouched:(SWPageNavigatorCell *)cell
//{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    [_documentModel selectPageAtIndex:indexPath.row];
//}




@end
