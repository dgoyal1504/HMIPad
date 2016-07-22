//
//  SWEventCell.m
//  HmiPad
//
//  Created by Joan on 08/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWEventCell.h"
#import "SWEvent.h"

#import "SWColor.h"
#import "Drawing.h"

@implementation SWEventCell
{
    UInt32 _rgbGradColor;
}


- (void)_doInitSWEventCell
{
    if ( IS_IOS7 )
    {
//        _eventLabelLabel.textColor = [UIColor darkGrayColor];
//        _eventTimeLabel.textColor = [UIColor darkGrayColor];
//        _eventCommentLabel.textColor = [UIColor blackColor];
    }
    else
    {
        _eventLabelLabel.textColor = [UIColor lightGrayColor];
        _eventTimeLabel.textColor = [UIColor lightGrayColor];
        _eventCommentLabel.textColor = [UIColor whiteColor];
        self.darkContext = YES;
    }
    
    UIImage *alarmImg = [[UIImage imageNamed:@"719-alarm-clock-toolbar.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_alarmImageView setImage:alarmImg];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
       [self _doInitSWEventCell];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
       [self _doInitSWEventCell];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self _doInitSWEventCell];
}



- (CGFloat)heightForComment:(NSString*)comment
{
    
    UIFont *font = _eventCommentLabel.font;
    CGRect commentFrame = _eventCommentLabel.frame;
    
    //CGRect rect = self.bounds;
    //CGFloat width = rect.size.width;
    //CGFloat commentHeight = [comment sizeWithFont:font constrainedToSize:CGSizeMake(width,200)].height;
    
    //CGSize commentSize = [comment sizeWithFont:font constrainedToSize:CGSizeMake(commentFrame.size.width,200)];
    
    CGSize commentSize = [comment boundingRectWithSize:CGSizeMake(commentFrame.size.width,200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    CGFloat commentHeight = ceil(commentSize.height);

    const int Gap = 15;
    CGFloat height = commentFrame.origin.y + commentHeight + Gap;
    return height;
}


//- (void)setEventV:(SWEvent *)event
//{
//    _event = event;
//    _eventLabelLabel.text = event.labelText;
//    _eventTimeLabel.text = event.getTimeStampString;
//    _eventCommentLabel.text = event.commentText;
//    
//    UIColor *color = nil;
//    //UIColor *backColor = nil;
//    UIImage *image = nil;
//    if ( event.active )
//    {
//        if ( event.acknowledged )
//        {
//            color = UIColorWithRgb( Theme_RGB(0, 175, 0, 0));
//            image = [UIImage imageNamed:@"alarm20DarkRed.png"];
//        }
//        else
//        {
//            color = UIColorWithRgb(0xff0000);
//            image = [UIImage imageNamed:@"alarm20Red.png"];
//        }
//    }
//    else
//    {
//        color = IS_IOS7 ? [UIColor darkGrayColor] : [UIColor whiteColor];
//        image = [UIImage imageNamed:@"clock20.png"];
//    }
//    
//    _alarmImageView.image = image;
//    _eventCommentLabel.textColor = color;
//}



- (void)setEvent:(SWEvent *)event
{
    _event = event;
    _eventLabelLabel.text = event.labelText;
    _eventTimeLabel.text = event.getTimeStampString;
    _eventCommentLabel.text = event.commentText;
    
    UIColor *color = nil;
    if ( event.active )
    {
        if ( event.acknowledged )
        {
            //color = UIColorWithRgb( Theme_RGB(0, 175, 0, 0));
            color = [UIColor colorWithRed:0.6 green:0 blue:0 alpha:1.0];
        }
        else
        {
            color = [UIColor redColor];
        }
    }
    else
    {
        if ( _isHisto ) color = UIColorWithRgb(TheNiceGreenColor);
        else color = [UIColor darkGrayColor];
    }
    
    _alarmImageView.tintColor = color;
    _eventCommentLabel.textColor = color;
    _eventTimeLabel.textColor = color;
}









//- (void)prepareForDisplay
//{
//    
//    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.15f];
//}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
