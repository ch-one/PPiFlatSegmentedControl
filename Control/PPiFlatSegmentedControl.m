//
//  PPiFlatSwitch.m
//  PPiFlatSwitch
//
//  Created by Pedro Piñera Buendía on 12/08/13.
//  Copyright (c) 2013 PPinera. All rights reserved.
//

#import "PPiFlatSegmentedControl.h"
#import "UIAwesomeButton.h"
#define segment_corner 3.0

@interface PPiFlatSegmentedControl()
@property (nonatomic,strong) NSMutableArray *segments;
@property (nonatomic) NSUInteger currentSelected;
@property (nonatomic,strong) NSMutableArray *separators;
@property (nonatomic,strong) NSMutableArray *underlines;
@end

@implementation PPiFlatSegmentedControl

- (id)initWithFrame:(CGRect)frame
              items:(NSArray*)items
       iconPosition:(IconPosition)position
  andSelectionBlock:(SelectionBlock)block
     iconSeparation:(CGFloat)separation
{
    self = [super initWithFrame:frame];
    if (self) {
        //Selection block
        _selectionBlock=block;
        
        //Icon separation
        self.iconSeparation = separation;
        
        //Icon position
        self.iconPosition = position;
        
        //Adding items
        [self addItems:items withFrame:frame];
        
        //Background Color
        self.backgroundColor=[UIColor clearColor];
        
        //Applying corners
        self.layer.masksToBounds=YES;
        self.layer.cornerRadius=segment_corner;
        
        //Default selected 0
        _currentSelected=0;
    }
    return self;
}

- (void)addItems:(NSArray*)items withFrame:(CGRect)frame
{
    // Removing segments and separators
    for (UIView *separator in self.separators) {
        [separator removeFromSuperview];
    }
    [self.separators removeAllObjects];
    for (UIView *segment in self.segments) {
        [segment removeFromSuperview];
    }
    [self.segments removeAllObjects];
    for (UIView *underline in self.underlines) {
        [underline removeFromSuperview];
    }
    [self.underlines removeAllObjects];
    
    //Generating segments
    float buttonWith=ceil(frame.size.width / items.count);
    CGFloat underlineY = frame.size.height - self.underlineWidth;
    int i=0;
    for(PPiFlatSegmentItem *item in items){
        NSString *text=item.title;
        NSObject *icon=item.icon;
        
        UIAwesomeButton  *button;
        if([icon isKindOfClass:[UIImage class]]) {
            button = [[UIAwesomeButton alloc] initWithFrame:CGRectMake(buttonWith*i, 0, buttonWith, frame.size.height) text:text iconImage:(UIImage *)icon attributes:@{} andIconPosition:self.iconPosition];
        }
        else {
            button = [[UIAwesomeButton alloc] initWithFrame:CGRectMake(buttonWith*i, 0, buttonWith, frame.size.height) text:text icon:(NSString *)icon attributes:@{} andIconPosition:self.iconPosition];
        }
        
        UIAwesomeButton __weak *wbutton = button;
        [button setActionBlock:^(UIAwesomeButton *button) {
            [self segmentSelected:wbutton];
        }];
        
        //Adding to self view
        [self.segments addObject:button];
        [self addSubview:button];
        
        // Adding underline
        UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(buttonWith*i, underlineY, buttonWith, self.underlineWidth)];
        underline.backgroundColor = item.underlineColor ?: nil;
        [self addSubview:underline];
        [self.underlines addObject:underline];
        
        //Adding separator
        if(i!=0){
            UIView *separatorView=[[UIView alloc] initWithFrame:CGRectMake(i*buttonWith, 0, self.borderWidth, frame.size.height)];
            [self addSubview:separatorView];
            [self.separators addObject:separatorView];
        }
        
        
        i++;
    }
    
    // Bringins separators to the front
    for (UIView* underline in self.underlines) {
        [self bringSubviewToFront:underline];
    }
    
    // Bringins separators to the front
    for (UIView* separator in self.separators) {
        [self bringSubviewToFront:separator];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    CGFloat buttonWidth = ceil(frame.size.width/self.segments.count);
    CGFloat underlineY = frame.size.height - self.underlineWidth;
    
    int i = 0;
    for(UIView *segment in self.segments){
        segment.frame = CGRectMake(i*buttonWidth, 0, buttonWidth, frame.size.height);
        i++;
    }
    i = 0;
    for (UIView *seperator in self.separators) {
        seperator.frame = CGRectMake(i*buttonWidth, 0, self.borderWidth, frame.size.height);
        i++;
    }
    i = 0;
    for (UIView *underline in self.underlines) {
        underline.frame = CGRectMake(i*buttonWidth, underlineY, buttonWidth, self.underlineWidth);
        i++;
    }
}


#pragma mark - Lazy instantiations

-(NSMutableArray*)segments
{
    if(!_segments)_segments=[[NSMutableArray alloc] init];
    return _segments;
}
-(NSMutableArray*)separators
{
    if(!_separators)_separators=[[NSMutableArray alloc] init];
    return _separators;
}
-(NSMutableArray*)underlines
{
    if(!_underlines)_underlines=[[NSMutableArray alloc] init];
    return _underlines;
}


#pragma mark - Actions

-(void)segmentSelected:(id)sender
{
    if(sender) {
        NSUInteger selectedIndex=[self.segments indexOfObject:sender];
        [self setSelected:YES segmentAtIndex:selectedIndex];
    }
}


#pragma mark - Getters

-(BOOL)isSelectedSegmentAtIndex:(NSUInteger)index
{
    return (index==self.currentSelected);
}

- (NSUInteger)numberOfSegments
{
    return self.segments.count;
}


#pragma mark - Setters

- (void)setSegmentAtIndex:(NSUInteger)index enabled:(BOOL)enabled
{
    if (index >= self.segments.count) return;
    UIButton *button = self.segments[index];
    [button setEnabled:enabled];
    [button setUserInteractionEnabled:enabled];
}

-(void)updateSegmentsFormat
{
    //Setting border color
    if (self.borderColor) {
        self.layer.borderWidth=self.borderWidth;
        self.layer.borderColor=self.borderColor.CGColor;
    }
    else {
        self.layer.borderWidth=0;
    }
    
    //Updating segments color
    for (UIView *separator in self.separators) {
        separator.backgroundColor=self.borderColor;
        separator.frame=CGRectMake(separator.frame.origin.x, separator.frame.origin.y,self.borderWidth , separator.frame.size.height);
    }
    
    //Modifying buttons with current State
    for (UIAwesomeButton *segment in self.segments)
    {
        //Setting icon Position
        if (self.iconPosition)
            [segment setIconPosition:self.iconPosition];
        
        //Set text aligment
        [segment setTextAlignment:NSTextAlignmentCenter];
        
        //Setting icon separation
        if(([segment getIcon] || [segment getIconImage]) && [segment getButtonText]){
            [segment setSeparation:self.iconSeparation];
        } else {
            [segment setSeparation:0];
        }
        
        //Setting format depending on if it's selected or not
        if([self.segments indexOfObject:segment]==self.currentSelected){
            //Selected-one
            if(self.selectedColor)[segment setBackgroundColor:self.selectedColor forUIControlState:UIControlStateNormal];
            if(self.selectedTextAttributes)
                [segment setAttributes:self.selectedTextAttributes forUIControlState:UIControlStateNormal];
        }
        else{
            //Non selected
            if(self.color)[segment setBackgroundColor:self.color forUIControlState:UIControlStateNormal];
            if(self.textAttributes)
                [segment setAttributes:self.textAttributes forUIControlState:UIControlStateNormal];
        }
    }
}

- (void)setItems:(NSArray*)items
{
    [self addItems:items withFrame:self.frame];
    [self updateSegmentsFormat];
}

-(void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor=selectedColor;
    [self updateSegmentsFormat];
}

-(void)setColor:(UIColor *)color
{
    _color=color;
    [self updateSegmentsFormat];
}

-(void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth=borderWidth;
    [self updateSegmentsFormat];
}

-(void)setIconPosition:(IconPosition)iconPosition
{
    _iconPosition=iconPosition;
    [self updateSegmentsFormat];
}

- (void)setIconSeparation:(CGFloat)iconSeparation
{
    _iconSeparation = iconSeparation;
    [self updateSegmentsFormat];
}

-(void)setTitle:(id)title forSegmentAtIndex:(NSUInteger)index
{
    //Getting the Segment
    if(index<self.segments.count) {
        UIAwesomeButton *segment=self.segments[index];
        if([title isKindOfClass:[NSString class]]){
            [segment setButtonText:title];
        }
    }
}
-(void)setBorderColor:(UIColor *)borderColor{
    //Setting boerder color to all view
    _borderColor=borderColor;
    [self updateSegmentsFormat];
}

-(void)setSelected:(BOOL)selected segmentAtIndex:(NSUInteger)segment{
    if (selected) {
        self.currentSelected=segment;
        [self updateSegmentsFormat];
        
        if(self.selectionBlock) {
            self.selectionBlock(segment);
        }
    }
}

-(void)setTextAttributes:(NSDictionary *)textAttributes
{
    _textAttributes=textAttributes;
    [self updateSegmentsFormat];
}

-(void)setSelectedTextAttributes:(NSDictionary *)selectedTextAttributes
{
    _selectedTextAttributes=selectedTextAttributes;
    [self updateSegmentsFormat];
}

@end

