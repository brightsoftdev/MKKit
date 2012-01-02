//
//  MKTableCell.m
//  MKKit
//
//  Created by Matthew King on 3/19/10.
//  Copyright 2010-2011 Matt King. All rights reserved.
//

#import "MKTableCell.h"

#import "MKTableElements/MKTableCellBadgeView.h"
#import "MKTableElements/MKElementAccentView.h"
#import "MKTableElements/MKTableCellAccentView.h"

@interface MKTableCell ()

- (void)accessoryButton:(id)sender;
- (void)onSwipe:(UISwipeGestureRecognizer *)sender;
- (void)onLongPress:(UILongPressGestureRecognizer *)sender;
- (void)resetLongPressRecognizer;

@end

#pragma mark - Functions

MKTableCellBadge iBadge;
MKTableCellAccent iAccent;

MKTableCellBadge MKTableCellBadgeMake(CGColorRef color, CFStringRef text) {
    iBadge.color = color;
    iBadge.text = text;
    
    return iBadge;
}

MKTableCellAccent MKTableCellAccentMake(MKTableCellAccentType type, MKTableCellPosition position, CGColorRef tint) {
    iAccent.type = type;
    iAccent.position = position;
    iAccent.tint = tint;
    
    return iAccent;
}

@implementation MKTableCell

@synthesize delegate, type, theLabel=mTheLabel, smallLabel=mSmallLabel, key=mKey, accessoryViewType, 
            validationType=mValidationType, validating=mValidating, validator, icon,
            iconMask, validatorTestStringLength=mValidatorTestStringLength, accessoryIcon, 
            recognizeLeftToRightSwipe, recognizeRightToLeftSwipe, recognizeLongPress, indexPath,
            primaryViewTrim, badge, accent, cellView=mCellView, stroryboardPrototype, image, accessoryImage;

#pragma mark - Creating

- (id)initWithType:(MKTableCellType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.type = cellType;
        [self.textLabel removeFromSuperview];
        
        if (type != MKTableCellTypeNone) {
            mCellView = [[MKView alloc] initWithCell:self];
            mCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            [self.contentView addSubview:mCellView];
            [mCellView release];
        }
        
        if (type == MKTableCellTypeLabel) {
            mTheLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			mTheLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:16.0];
            mTheLabel.backgroundColor = CLEAR;
			mTheLabel.textAlignment = UITextAlignmentLeft;
			mTheLabel.adjustsFontSizeToFitWidth = NO;
            mTheLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
            
            [mCellView addPrimaryElement:mTheLabel];
            [mTheLabel release];
		}
		
		if (type == MKTableCellTypeDescription) {
            mTheLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			mTheLabel.textAlignment = UITextAlignmentLeft;
            mTheLabel.backgroundColor = CLEAR;
			
            [mCellView addPrimaryElement:mTheLabel];
            [mTheLabel release];
            
			mSmallLabel = [[UILabel alloc] initWithFrame:CGRectZero];
			mSmallLabel.textAlignment = UITextAlignmentLeft;
			mSmallLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			mSmallLabel.adjustsFontSizeToFitWidth = YES;
            mSmallLabel.font = SYSTEM(12.0);
			mSmallLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            mSmallLabel.backgroundColor = CLEAR;
			
			[mCellView addDetailElement:mSmallLabel];
			[mSmallLabel release];
		}
               
		[self.contentView setAutoresizesSubviews:YES];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
	return self;
}

#pragma mark - Memory Management

- (void)dealloc {
    self.accessoryImage = nil;
    self.indexPath = nil;
    self.cellView = nil;
    //self.theLabel = nil;
    self.smallLabel = nil;
    self.image = nil;
    
    [super dealloc];
}
	
#pragma mark - Accessor Methods
#pragma mark Accessories

- (void)setAccessoryViewType:(MKTableCellAccessoryViewType)aType {
	if (aType == MKTableCellAccessoryNone) {
		self.accessoryView = nil;
	}
	if (aType == MKTableCellAccessoryInfoButton) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
		[button addTarget:self action:@selector(accessoryButton:) forControlEvents:UIControlEventTouchUpInside];
		self.accessoryView = button;
	}
	if (aType == MKTableCellAccessoryWarningIcon) {
        MKControl *iconImage = [[MKControl alloc] initWithType:MKTableCellAccessoryWarningIcon];
        self.accessoryView = iconImage;
		[iconImage release];
	}
    if (aType == MKTableCellAccessoryActivity) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 20.0)];
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [activityIndicator startAnimating];
        
        self.accessoryView = activityIndicator;
        [activityIndicator release];
    }
    if (aType == MKTableCellAccessoryAdd) {
        MKControl *iconImage = [[MKControl alloc] initWithType:MKTableCellAccessoryAdd];
        [iconImage addTarget:self selector:@selector(accessoryButton:) action:MKActionTouchUp];
        self.accessoryView = iconImage;
        [iconImage release];
    }
    if (aType == MKTableCellAccessorySubtract) {
        MKControl *iconImage = [[MKControl alloc] initWithType:MKTableCellAccessorySubtract];
        [iconImage addTarget:self selector:@selector(accessoryButton:) action:MKActionTouchUp];
        self.accessoryView = iconImage;
        [iconImage release];
    }
}

- (void)setAccessoryImage:(MKImage *)img {
    MKControl *iconView = [[MKControl alloc] initWithImage:(UIImage *)img];
    [iconView addTarget:self selector:@selector(accessoryButton:) action:MKActionTouchDown];
    self.accessoryView = iconView;
    [iconView release];
}

#pragma mark Validation

- (void)setValidationType:(MKValidationType)valType {
	mValidationType = valType;
	
	if (valType == MKValidationNone) {
		mValidating = NO;
		validator = nil;
	}
	else {
		mValidating = YES;
		validator = [MKValidator sharedValidator];
	}
}

- (void)setValidatorTestStringLength:(NSInteger)length {
    mValidatorTestStringLength = length;
    
    if (mValidating) {
        ((MKValidator *)validator).stringLength = length;
    }
}

#pragma mark Icons

- (void)setImage:(MKImage *)img {
    if (!stroryboardPrototype) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.image = (UIImage *)img;
        
        [mCellView addIconElement:imageView];
        [imageView release];
    }
}

#pragma mark Accents

- (void)setAccent:(MKTableCellAccent)anAccent {
    UIView *view = [mCellView viewWithTag:kAccentViewTag];
    
    if (view) {
        [view removeFromSuperview];
    }
    
    if (anAccent.type == MKTableCellAccentTypeFull) {
        MKTableCellAccentView *view = [[MKTableCellAccentView alloc] initWithFrame:mCellView.frame position:anAccent.position];
        view.tint = [UIColor colorWithCGColor:anAccent.tint];
        view.tag = kAccentViewTag;
        
        [mCellView addSubview:view];
        [mCellView sendSubviewToBack:view];
        
        [view release];
    }
    
    if (anAccent.type == MKTableCellAccentTypePrimaryView) {
        [self accentPrimaryViewForCellAtPosition:anAccent.position];
    }
}

- (void)setPrimaryViewTrim:(CGFloat)trim {
    MKElementAccentView *view = (MKElementAccentView *)[self.contentView viewWithTag:kAccentViewTag];
    view.frame = CGRectMake(view.x, view.y, trim, view.height);
    
    UIView *textView = [mCellView viewWithTag:kPrimaryViewTag];
    textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, (trim - CGRectGetMinX(textView.frame)), textView.frame.size.height);
    textView.autoresizingMask = UIViewAutoresizingNone;
}

- (void)setBadge:(MKTableCellBadge)aBadge {
    UIView *view = (UIView *)[mCellView viewWithTag:kBadgeViewTag];
    
    if (view) {
        [view removeFromSuperview];
    }
    
    CGSize width = [(NSString *)aBadge.text sizeWithFont:SYSTEM_BOLD(kBadgeTextFontSize)];
    CGRect rect = CGRectMake((kBadgeX - width.width - kBadgeXWidthAdjustment), kBadgeY, (width.width + kBadgeTextPadding), kBadgeHeight);
    
    MKTableCellBadgeView *badgeView = [[MKTableCellBadgeView alloc] initWithFrame:rect];
    badgeView.badgeText = (NSString *)aBadge.text;
    badgeView.badgeColor = [UIColor colorWithCGColor:aBadge.color];
    badgeView.tag = kBadgeViewTag;
    
    [mCellView addSubview:badgeView];
    [badgeView release];
}

#pragma mark Gestures

- (void)setRecognizeRightToLeftSwipe:(BOOL)recognize {
    if (recognize) {
        mRightToLeftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
        mRightToLeftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        
        [self addGestureRecognizer:mRightToLeftSwipe];
        [mRightToLeftSwipe release];
    }
    else {
        if (mRightToLeftSwipe) {
            [self removeGestureRecognizer:mRightToLeftSwipe];
            mRightToLeftSwipe = nil;
        }
    }
}

- (void)setRecognizeLeftToRightSwipe:(BOOL)recognize {
    if (recognize) {
        mLeftToRightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
        mLeftToRightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self addGestureRecognizer:mLeftToRightSwipe];
        [mLeftToRightSwipe release];
    }
    else {
        if (mLeftToRightSwipe) {
            [self removeGestureRecognizer:mLeftToRightSwipe];
            mLeftToRightSwipe = nil;
        }
    }
}

- (void)setRecognizeLongPress:(BOOL)recognize {
    if (recognize) {
        mLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        
        [self addGestureRecognizer:mLongPress];
        [mLongPress release];
    }
    else {
        if (mLongPress) {
            [self removeGestureRecognizer:mLongPress];
            mLongPress = nil;
        }
    }
}

- (void)storyboardPrototypeWithType:(MKTableCellType)celltype {
    self.type = celltype;
    self = [self initWithType:celltype reuseIdentifier:self.reuseIdentifier];
}

#pragma mark - Elements

- (void)addBadgeWithText:(NSString *)text color:(UIColor *)color rect:(CGRect)rect {
    UIView *view = (UIView *)[mCellView viewWithTag:kBadgeViewTag];
    
    if (view) {
        [view removeFromSuperview];
    }
    
    MKTableCellBadgeView *abadge = [[MKTableCellBadgeView alloc] initWithFrame:rect];
    abadge.badgeText = text;
    abadge.badgeColor = color;
    abadge.tag = kBadgeViewTag;
    
    [mCellView addSubview:abadge];
    [abadge release];
}

#pragma mark - Appearance

- (void)accentPrimaryViewForCellAtPosition:(MKTableCellPosition)position {
    UIView *view = (UIView *)[mCellView viewWithTag:kPrimaryViewTag];
    UIView *aView = (UIView *)[self.contentView viewWithTag:kAccentViewTag];
    
    if (aView) {
        [aView removeFromSuperview];
    }
    
    MKElementAccentView *accentView = [[MKElementAccentView alloc] initWithFrame:CGRectMake(0.0, 0.0, (CGRectGetMaxX(view.frame) + 5.0), self.frame.size.height) position:position];
    [self.contentView addSubview:accentView];
    [self.contentView sendSubviewToBack:accentView];
    accentView.tag = kAccentViewTag;
    [accentView release];
    
    if (mTheLabel) {
        mTheLabel.font = VERDANA_BOLD(14.0);
        mTheLabel.adjustsFontSizeToFitWidth = YES;
        mTheLabel.textColor = DARK_GRAY;
        mTheLabel.shadowColor = WHITE;
        mTheLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        mTheLabel.textAlignment = UITextAlignmentCenter;
    }
}

- (void)accentPrimaryViewForCellAtPosition:(MKTableCellPosition)position trim:(CGFloat)trim {
    [self accentPrimaryViewForCellAtPosition:position];
    if (self.primaryViewTrim == 0.0) {
        self.primaryViewTrim = trim;
    }
}

#pragma mark - Validation Methods

- (BOOL)validatedWithType:(MKValidationType)aType {
	return YES;
}

#pragma mark - Actions

- (void)accessoryButton:(id)sender {
	if ([self.delegate respondsToSelector:@selector(didTapAccessoryForKey:indexPath:)]) {
        if (self.indexPath == nil) {
            NSException *exception = [NSException exceptionWithName:@"No Index Path" reason:@"The indexPath property of MKTableCell must be set to call the didTapAccessoryForKey:indexPath delegate method." userInfo:nil];
            [exception raise];
        }
		[self.delegate didTapAccessoryForKey:self.key indexPath:self.indexPath];
	}
}

#pragma mark - Gesture Actions

- (void)onSwipe:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if ([delegate respondsToSelector:@selector(didSwipeRightToLeftForKey:indexPath:)]) {
            [delegate didSwipeRightToLeftForKey:self.key indexPath:self.indexPath];
        }
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        if ([delegate respondsToSelector:@selector(didSwipeLeftToRightForKey:indexPath:)]) {
            [delegate didSwipeLeftToRightForKey:self.key indexPath:self.indexPath];
        }
    }
}

- (void)onLongPress:(UILongPressGestureRecognizer *)sender {
    self.recognizeLongPress = NO;
    
    if ([delegate respondsToSelector:@selector(didLongPressForKey:indexPath:)]) {
        [delegate didLongPressForKey:self.key indexPath:self.indexPath];
    }
    
    [self performSelector:@selector(resetLongPressRecognizer) withObject:nil afterDelay:1.5];
}

- (void)resetLongPressRecognizer {
    self.recognizeLongPress = YES;
}

#pragma mark - Deprecated

- (void)validateWithType:(MKValidationType)aType {
    //Deprecated Method//
}

- (void)setIconMask:(UIImage *)lIconMask {
    //Deprecated Method//
}

- (void)setIcon:(UIImage *)anImage {
    //Deprecated Method//
}

- (void)setAccessoryIcon:(UIImage *)lIcon {
    //Deprecated Method//
}

@end

#pragma mark -

@implementation MKView (MKTableCell)

@dynamic pinnedSecondaryElement, pinnedPrimaryElement;

static const char *PinnedPrimary = "PinnedPrimary";
static const char *PinnedSecondary = "PinnedSecondary";

#pragma mark - Initalizer

- (id)initWithCell:(MKTableCell *)cell {
    self = [super initWithFrame:cell.contentView.frame];
    if (self) {
        self.backgroundColor = CLEAR;
        self.opaque = NO;
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        self.pinnedSecondaryElement = NO;
        self.pinnedPrimaryElement = NO;
        
        mShouldRemoveView = NO;
    }
    return self;
}

#pragma mark - Layout

- (void)layoutCell {
    UIView *primaryElement = [self viewWithTag:kPrimaryViewTag];
    UIView *secondaryElement = [self viewWithTag:kSecondaryViewTag];
    UIView *iconElement = [self viewWithTag:kIconViewTag];
    UIView *detailElement = [self viewWithTag:kDetailViewTag];
    
    if (primaryElement) {
        if (!self.pinnedPrimaryElement) {
            primaryElement.frame = CGRectMake(kCellPrimaryElementX, kCellPrimaryElementY, kCellPrimaryElementyWidth, kCellSecondaryElementHeight);
        }
    }
    
    if (secondaryElement) {
        if (!self.pinnedSecondaryElement) {
            secondaryElement.frame = CGRectMake(kCellSecondaryElementX, kCellSecondaryElementY, kCellSecondaryElementWidth, kCellSecondaryElementHeight);
        }
        
        if (primaryElement && !self.pinnedPrimaryElement) {
            primaryElement.frame = CGRectMake(primaryElement.frame.origin.x, primaryElement.frame.origin.y, (CGRectGetMinX(secondaryElement.frame) - CGRectGetMinX(primaryElement.frame) - 5.0), primaryElement.frame.size.height);
        }
    }
    
    if (detailElement) {
        detailElement.frame = CGRectMake(kCellDetailElementX, kCellDetailElementY, kCellDetailElementWidth, kCellDetailElementHeight);
        
        if (primaryElement) {
            primaryElement.frame = CGRectMake(primaryElement.frame.origin.x, (primaryElement.frame.origin.y - 5.0), primaryElement.frame.size.width, (primaryElement.frame.size.height - 5.0));
        }
        if (secondaryElement) {
            secondaryElement.frame = CGRectMake(secondaryElement.frame.origin.x, (secondaryElement.frame.origin.y - 5.0), secondaryElement.frame.size.width, (secondaryElement.frame.size.height - 5.0));
        }
    }
    
    if (iconElement) {
        iconElement.frame = CGRectMake(kCellIconRectX, kCellIconRectY, kCellIconRectWidth, kCellIconRectHeight);
        
        if (primaryElement && !self.pinnedPrimaryElement) {
            primaryElement.frame = CGRectMake((primaryElement.frame.origin.x + 44.0), primaryElement.frame.origin.y, (primaryElement.frame.size.width - 44.0), primaryElement.frame.size.height);
        }
        if (detailElement) {
            detailElement.frame = CGRectMake((detailElement.frame.origin.x + 44.0), detailElement.frame.origin.y, (detailElement.frame.size.width - 44.0), detailElement.frame.size.height);
        }
    }
}

#pragma mark - Accessory Methods
#pragma mark Setters

- (void)setPinnedSecondaryElement:(BOOL)pinned {
    NSNumber *pinnedObj = [NSNumber numberWithBool:pinned];
    objc_setAssociatedObject(self, PinnedSecondary, pinnedObj, OBJC_ASSOCIATION_RETAIN);
}

- (void)setPinnedPrimaryElement:(BOOL)pinned {
    NSNumber *pinnedObj = [NSNumber numberWithBool:pinned];
    objc_setAssociatedObject(self, PinnedPrimary, pinnedObj, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark Getters

- (BOOL)pinnedSecondaryElement {
    return [objc_getAssociatedObject(self, PinnedSecondary) boolValue];
}

- (BOOL)pinnedPrimaryElement {
    return [objc_getAssociatedObject(self, PinnedPrimary) boolValue];
}

#pragma mark - Adding Elements

- (void)addPrimaryElement:(UIView *)element {
    element.tag = kPrimaryViewTag;
    element.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:element];
    [self layoutCell];
}

- (void)addPrimaryElement:(UIView *)element inRect:(CGRect)rect {
    self.pinnedPrimaryElement = YES;
    
    element.tag = kPrimaryViewTag;
    element.autoresizingMask = UIViewAutoresizingNone;
    
    [self addSubview:element];
    [self layoutCell];
}

- (void)addSecondaryElement:(UIView *)element {
    element.tag = kSecondaryViewTag;
    element.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:element];
    [self layoutCell];
}

- (void)addSecondaryElement:(UIView *)element inRect:(CGRect)rect {
    self.pinnedSecondaryElement = YES;
    
    element.tag = kSecondaryViewTag;
    element.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:element];
    [self layoutCell];
}

- (void)addIconElement:(UIView *)element {
    element.tag = kIconViewTag;
    element.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:element];
    [self layoutCell];
}

- (void)addDetailElement:(UIView *)element {
    element.tag = kDetailViewTag;
    element.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:element];
    [self layoutCell];
}

- (void)didRelease {
    objc_removeAssociatedObjects(self);
}

@end

#pragma mark - 

static const char *TypeTagKey = "TypeTag";

@implementation MKControl (MKTableCell)

void drawWarningIcon(CGContextRef context, CGRect rect);
void drawAddIcon(CGContextRef context, CGRect rect);
void drawSubtractIcon(CGContextRef context, CGRect rect);

@dynamic viewType;

#pragma mark - Initalizer

- (id)initWithType:(MKTableCellAccessoryViewType)type {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        self.backgroundColor = CLEAR;
        self.opaque = NO;
        self.viewType = [NSNumber numberWithInt:type];
        
        if (((int)type) == MKTableCellAccessoryWarningIcon) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 25.0)];
            label.textAlignment = UITextAlignmentCenter;
            label.backgroundColor = CLEAR;
            label.textColor = WHITE;
            label.shadowColor = RED;
            label.shadowOffset = CGSizeMake(0.0, -1.0);
            label.font = SYSTEM_BOLD(24.0);
            label.text = @"!";
            
            [self addSubview:label];
            [label release];
        }
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        self.backgroundColor = CLEAR;
        self.opaque = NO;
        self.viewType = [NSNumber numberWithInt:MKTableCellAccessoryNone];
        
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.frame = self.frame;
        [self addSubview:view];
        [view release];
    }
    return self;
}

#pragma mark - Accessors

- (void)setViewType:(id)type {
    objc_setAssociatedObject(self, TypeTagKey, type, OBJC_ASSOCIATION_ASSIGN);
}

- (id)viewType {
    return objc_getAssociatedObject(self, TypeTagKey);
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    if ([(NSNumber *)self.viewType intValue] == MKTableCellAccessoryWarningIcon) {
        drawWarningIcon(context, rect);
    }
    if ([(NSNumber *)self.viewType intValue] == MKTableCellAccessoryAdd) {
        drawAddIcon(context, rect);
    }
    if ([(NSNumber *)self.viewType intValue] == MKTableCellAccessorySubtract) {
        drawSubtractIcon(context, rect);
    }
}

#pragma mark Warning Icon

void drawWarningIcon(CGContextRef context, CGRect rect) {
    CGColorRef redColor = RED.CGColor;
    
    CGPoint p1 = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint p2 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint p3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, p1.x, p1.y);
    CGPathAddLineToPoint(path, NULL, p2.x, p2.y);
    CGPathAddLineToPoint(path, NULL, p3.x, p3.y);
    CGPathAddLineToPoint(path, NULL, p1.x, p1.y);
    
    CGPathCloseSubpath(path);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, redColor);
    CGContextAddPath(context, path);
    CGContextClip(context);
    drawGlossAndLinearGradient(context, rect, redColor, redColor);
    CGContextSaveGState(context);
    
    CFRelease(path);
}

#pragma mark Add Icon

void drawAddIcon(CGContextRef context, CGRect rect) {
    CGColorRef fillColor = MK_COLOR_HSB(117.0, 96.0, 91.0, 1.0).CGColor;
    CGColorRef plusShadowColor = MK_COLOR_HSB(117.0, 96.0, 57.0, 1.0).CGColor;
    
    CGRect drawRect = CGRectInset(rect, 4.0, 4.0);
    CGRect plusRect = CGRectInset(drawRect, 5.0, 5.0);
    
    CGMutablePathRef path = createCircularPathForRect(drawRect);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextFillRect(context, drawRect);
    drawCurvedGloss(context, rect, rect.size.width);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, WHITE.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 3.0, MK_SHADOW_COLOR);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 3.0);
    CGContextSetStrokeColorWithColor(context, WHITE.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, -1.0), 1.0, plusShadowColor);
    CGContextMoveToPoint(context, CGRectGetMidX(plusRect), CGRectGetMinY(plusRect));
    CGContextAddLineToPoint(context, CGRectGetMidX(plusRect), CGRectGetMaxY(plusRect));
    CGContextMoveToPoint(context, CGRectGetMinX(plusRect), CGRectGetMidY(plusRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(plusRect), CGRectGetMidY(plusRect));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CFRelease(path);
}

#pragma mark Subtract Icon

void drawSubtractIcon(CGContextRef context, CGRect rect) {
    CGColorRef fillColor = RED.CGColor;
    CGColorRef plusShadowColor = RED.CGColor;
    
    CGRect drawRect = CGRectInset(rect, 4.0, 4.0);
    CGRect plusRect = CGRectInset(drawRect, 5.0, 5.0);
    
    CGMutablePathRef path = createCircularPathForRect(drawRect);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextFillRect(context, drawRect);
    drawCurvedGloss(context, rect, rect.size.width);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, WHITE.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 3.0, MK_SHADOW_COLOR);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 3.0);
    CGContextSetStrokeColorWithColor(context, WHITE.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, -1.0), 1.0, plusShadowColor);
    CGContextMoveToPoint(context, CGRectGetMinX(plusRect), CGRectGetMidY(plusRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(plusRect), CGRectGetMidY(plusRect));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CFRelease(path);
}

#pragma mark - Memory Mangament

- (void)didRelease {
    if (self.viewType) {
        objc_removeAssociatedObjects(self.viewType);
    }
}

@end
