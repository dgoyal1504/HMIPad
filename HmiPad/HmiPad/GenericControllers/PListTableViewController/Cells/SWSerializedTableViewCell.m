//
//  SWSerializedTableViewCell.m
//  HmiPad
//
//  Created by Joan on 31/03/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWSerializedTableViewCell.h"
#import "SWColor.h"


NSString *SWSerializedTableViewCellIdentifier = @"SWSerializedTableViewCellIdentifier";
NSString *SWSerializedTableViewCellNibName = @"SWSerializedTableViewCell";
NSString *SWSerializedTableViewCellNibName6 = @"SWSerializedTableViewCell6";

@implementation SWSerializedTableViewCell
{
    BOOL _shouldApplyImageBorder;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [_labelDetail setLineBreakMode:NSLineBreakByWordWrapping];
    _imageViewThumbnail.contentMode = UIViewContentModeCenter;
}


- (CGFloat)heightForComment:(NSString*)comment
{
//    CGRect rect = self.bounds;
//    CGFloat width = rect.size.width;
    
    UIFont *font = _labelDetail.font;
    CGRect detailFrame = _labelDetail.frame;
    
    
//    CGFloat detailHeight = [comment sizeWithFont:font constrainedToSize:CGSizeMake(detailFrame.size.width,200)
//        lineBreakMode:NSLineBreakByTruncatingTail].height;
    
    CGFloat detailHeight = [comment boundingRectWithSize:CGSizeMake(detailFrame.size.width,300) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:font} context:nil].size.height;
    
    detailHeight = ceil(detailHeight)+4;

    detailFrame.size.height = detailHeight;
    _labelDetail.frame = detailFrame;
    
    const int Gap = 10;
    CGFloat height = detailFrame.origin.y + detailHeight + Gap;
    
    CGFloat minHeight = SWSerializedTableViewIdentifierImageSize.height;
    if ( height < minHeight) height = minHeight;
    
    return height;
}



- (void)setShouldApplyImageBorder:(BOOL)shouldApplyImageBorder
{
    if ( _shouldApplyImageBorder == shouldApplyImageBorder )
        return;
    
    _shouldApplyImageBorder = shouldApplyImageBorder;
    if ( shouldApplyImageBorder )
    {
        // posem borde i color al imageview del boto
        CALayer *layer = _imageViewThumbnail.layer;

        layer.borderColor = [UIColor colorWithWhite:0.33 alpha:1.0].CGColor;
        layer.borderWidth = 1;
        layer.cornerRadius = 5;
        layer.backgroundColor = checkeredBackgroundColor().CGColor;
        layer.masksToBounds = YES;
        _imageViewThumbnail.contentMode = UIViewContentModeScaleAspectFill;
    }
    else
    {
        CALayer *layer = _imageViewThumbnail.layer;
        layer.borderColor = nil;
        layer.borderWidth = 0;
        layer.cornerRadius = 0;
        layer.backgroundColor = nil; //[UIColor colorWithRed:0.9 green:0.9 blue:0.92 alpha:1].CGColor;
        layer.masksToBounds = NO;
        _imageViewThumbnail.contentMode = UIViewContentModeCenter;
    }
}






@end
