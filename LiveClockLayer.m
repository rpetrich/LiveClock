#import "LiveClockLayer.h"
#import <QuartzCore/QuartzCore.h>

#define RGBA(r, g, b, a) \
	(CGFloat)(r)/255.0f, (CGFloat)(g)/255.0f, (CGFloat)(b)/255.0f, (CGFloat)(a)/255.0f

#define PI 3.14159265f

@interface UIScreen (OS40)
@property (nonatomic, readonly) CGFloat scale;
@end

#define Lookup(dictionary, key, defaultValue) \
	([dictionary objectForKey:key]?:defaultValue)
	
#define CancelInit(reasons...) \
	do { \
		NSLog(reasons); \
		[self release]; \
		return nil; \
	} while(0)

__attribute__((visibility("hidden")))
@interface LiveClockLayerItem : NSObject {
}
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)drawInContext:(CGContextRef)context withComponents:(NSDateComponents *)components;
@end

@implementation LiveClockLayerItem
- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	return self;
}
- (void)drawInContext:(CGContextRef)context withComponents:(NSDateComponents *)components
{
}
@end

typedef enum {
	HandLayerSourceNone,
	HandLayerSourceHour,
	HandLayerSourceMinute,
	HandLayerSourceSecond,
} HandLayerSource;

__attribute__((visibility("hidden")))
@interface LiveClockHandLayerItem : LiveClockLayerItem {
@private
	HandLayerSource source;
	CGFloat redColor;
	CGFloat greenColor;
	CGFloat blueColor;
	CGFloat alphaColor;
	CGPoint origin;
	CGPoint *points;
	NSUInteger pointCount;
}
@end

@implementation LiveClockHandLayerItem

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if ((self = [super initWithDictionary:dictionary])) {
		// Find hand source
		NSString *sourceText = Lookup(dictionary, @"source", nil);
		if ([sourceText isEqualToString:@"hour"])
			source = HandLayerSourceHour;
		else if ([sourceText isEqualToString:@"minute"])
			source = HandLayerSourceMinute;
		else if ([sourceText isEqualToString:@"second"])
			source = HandLayerSourceSecond;
		else
			source = HandLayerSourceNone;
		// Find color array
		NSArray *colorArray = Lookup(dictionary, @"color", nil);
		alphaColor = 1.0f;
		switch ([colorArray count]) {
			case 4:	alphaColor	= [[colorArray objectAtIndex:3] floatValue];
			case 3:	blueColor	= [[colorArray objectAtIndex:2] floatValue];
					greenColor	= [[colorArray objectAtIndex:1] floatValue];
					redColor	= [[colorArray objectAtIndex:0] floatValue];
					break;
			default:
				CancelInit(@"LiveClock: Invalid number of elements in color array: %i", [colorArray count]);
		}
		// Find origin
		NSArray *originArray = Lookup(dictionary, @"origin", nil);
		switch ([originArray count]) {
			case 1:	origin.x = [[originArray objectAtIndex:0] floatValue];
					origin.y = origin.x;
					break;
			case 2:	origin.x = [[originArray objectAtIndex:0] floatValue];
					origin.y = [[originArray objectAtIndex:1] floatValue];
					break;
			default:
					CancelInit(@"LiveClock: Invalid number of elements in origin array: %i", [originArray count]);
		}
		// Find points
		NSArray *pointsArray = Lookup(dictionary, @"points", nil);
		pointCount = [pointsArray count];
		if (pointCount % 2)
			CancelInit(@"LiveClock: Invalid number of elements in point array: %i", pointCount);
		pointCount = pointCount / 2;
		points = malloc(sizeof(CGPoint) * pointCount);
		for (NSUInteger i = 0; i < pointCount; i++) {
			points[i].x = [[pointsArray objectAtIndex:i * 2] floatValue];
			points[i].y = [[pointsArray objectAtIndex:i * 2 + 1] floatValue];
		}
	}
	return self;
}

- (void)drawInContext:(CGContextRef)context withComponents:(NSDateComponents *)components
{
	// Get Context
	CGContextSaveGState(context);
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextTranslateCTM(context, origin.x, origin.y);
	CGFloat amount;
	switch (source) {
		case HandLayerSourceHour:
			amount = (CGFloat)([components hour] * 60 + [components minute]) / (12 * 60);
			break;
		case HandLayerSourceMinute:
			amount = (CGFloat)([components minute] * 60 + [components second]) / (60 * 60);
			break;
		case HandLayerSourceSecond:
			amount = (CGFloat)[components second] / 60;
			break;
		default:
			amount = 0;
			break;
	}
	CGContextRotateCTM(context, PI * 2 * amount);
	CGContextSetRGBFillColor(context, redColor, greenColor, blueColor, alphaColor);
	CGContextBeginPath(context);
	CGContextAddLines(context, points, pointCount);
	CGContextClosePath(context);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
}

- (void)dealloc
{
	free(points);
	points = NULL;
	[super dealloc];
}

@end

__attribute__((visibility("hidden")))
@interface LiveClockEllipseLayerItem : LiveClockLayerItem {
@private
	CGFloat redColor;
	CGFloat greenColor;
	CGFloat blueColor;
	CGFloat alphaColor;
	CGRect rect;
}
@end

@implementation LiveClockEllipseLayerItem

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if ((self = [super initWithDictionary:dictionary])) {
		// Find color array
		NSArray *colorArray = Lookup(dictionary, @"color", nil);
		alphaColor = 1.0f;
		switch ([colorArray count]) {
			case 4:	alphaColor	= [[colorArray objectAtIndex:3] floatValue];
			case 3:	blueColor	= [[colorArray objectAtIndex:2] floatValue];
					greenColor	= [[colorArray objectAtIndex:1] floatValue];
					redColor	= [[colorArray objectAtIndex:0] floatValue];
					break;
			default:
				CancelInit(@"LiveClock: Invalid number of elements in color array: %i", [colorArray count]);
		}
		// Find rect
		NSArray *rectArray = Lookup(dictionary, @"rect", nil);
		switch ([rectArray count]) {
			case 2: rect.origin.x = [[rectArray objectAtIndex:0] floatValue];
					rect.origin.y = rect.origin.x;
					rect.size.width = [[rectArray objectAtIndex:1] floatValue];
					rect.size.height = rect.size.width;
					break;
			case 3: rect.origin.x = [[rectArray objectAtIndex:0] floatValue];
					rect.origin.y = [[rectArray objectAtIndex:1] floatValue];
					rect.size.width = [[rectArray objectAtIndex:2] floatValue];
					rect.size.height = rect.size.width;
					break;
			case 4: rect.origin.x = [[rectArray objectAtIndex:0] floatValue];
					rect.origin.y = [[rectArray objectAtIndex:1] floatValue];
					rect.size.width = [[rectArray objectAtIndex:2] floatValue];
					rect.size.height = [[rectArray objectAtIndex:2] floatValue];
					break;
			default:
					CancelInit(@"LiveClock: Invalid number of elements in rect array: %i", [rectArray count]);
		}
	}
	return self;
}

- (void)drawInContext:(CGContextRef)context withComponents:(NSDateComponents *)components
{
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextSetRGBFillColor(context, redColor, greenColor, blueColor, alphaColor);
	CGContextFillEllipseInRect(context, rect);
}

@end

__attribute__((visibility("hidden")))
@interface LiveClockImageLayerItem : LiveClockLayerItem {
@private
	CGPoint origin;
	UIImage *image;
	HandLayerSource source;
}
@end

@implementation LiveClockImageLayerItem

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if ((self = [super initWithDictionary:dictionary])) {
		// Find origin
		NSArray *originArray = Lookup(dictionary, @"origin", nil);
		switch ([originArray count]) {
			case 1:	origin.x = [[originArray objectAtIndex:0] floatValue];
					origin.y = origin.x;
					break;
			case 2:	origin.x = [[originArray objectAtIndex:0] floatValue];
					origin.y = [[originArray objectAtIndex:1] floatValue];
					break;
			default:
					CancelInit(@"LiveClock: Invalid number of elements in origin array: %i", [originArray count]);
		}
		// Find hand source
		NSString *sourceText = Lookup(dictionary, @"source", nil);
		if ([sourceText isEqualToString:@"hour"])
			source = HandLayerSourceHour;
		else if ([sourceText isEqualToString:@"minute"])
			source = HandLayerSourceMinute;
		else if ([sourceText isEqualToString:@"second"])
			source = HandLayerSourceSecond;
		else
			source = HandLayerSourceNone;
		// Find Image Path
		NSString *imagePath = Lookup(dictionary, @"path", nil);
		if ([imagePath length]) {
			NSBundle *springBundle = [NSBundle bundleWithIdentifier:@"com.apple.springboard"];
			if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
				CGFloat scale = [[UIScreen mainScreen] scale];
				if (scale != 1.0f) {
					NSString *basePath = [imagePath stringByDeletingPathExtension];
					NSString *scaledName = [NSString stringWithFormat:@"%@@%.0fx", basePath, scale];
					image = [[UIImage alloc] initWithContentsOfFile:[springBundle pathForResource:scaledName ofType:[imagePath pathExtension]]];
					if (image)
						return self;
				}
			}
			NSString *settingsPath = [springBundle pathForResource:imagePath ofType:nil];
			image = [[UIImage alloc] initWithContentsOfFile:settingsPath];
			if (!image)
				CancelInit(@"LiveClock: Unable to load image at path: %@", imagePath);
		} else {
			CancelInit(@"LiveClock: No image path given");
		}
	}
	return self;
}

- (void)drawInContext:(CGContextRef)context withComponents:(NSDateComponents *)components
{
	CGPoint point = origin;
	CGRect clipRect = { origin, [image size] };
	NSInteger divisions;
	NSInteger index;
	switch (source) {
		case HandLayerSourceNone:
			// Optimized when there's no clipping to be done
			[image drawAtPoint:point];
			return;
		case HandLayerSourceHour:
			divisions = 24;
			index = [components hour] - 1;
			break;
		case HandLayerSourceMinute:
			divisions = 60;
			index = [components minute] - 1;
			break;
		case HandLayerSourceSecond:
			divisions = 60;
			index = [components second];
			break;
		default:
			return;
	}
	if (index < 0)
		index += divisions;
	NSInteger height = ((NSInteger)clipRect.size.height) / divisions;
	clipRect.size.height = (CGFloat)height;
	point.y -= (CGFloat)(height * index);
	CGContextSaveGState(context);
	CGContextClipToRect(context, clipRect);
	[image drawAtPoint:point];
	CGContextRestoreGState(context);
}

- (void)dealloc
{
	[image release];
	image = nil;
	[super dealloc];
}

@end

@implementation LiveClockLayer

- (id)initWithSettings:(NSDictionary *)settings
{
	if ((self = [super init])) {
		CGRect frame;
		frame.size.width = [Lookup(settings, @"width", [NSNumber numberWithFloat:57.0f]) floatValue];
		frame.size.height = [Lookup(settings, @"height", [NSNumber numberWithFloat:57.0f]) floatValue];
		frame.origin.x = 30 - (NSInteger)frame.size.width / 2;
		frame.origin.y = 28 - (NSInteger)frame.size.height / 2;
		self.frame = frame;
		_updateInterval = [Lookup(settings, @"update-interval", [NSNumber numberWithFloat:3.0f]) floatValue];
		NSArray *layoutArray = Lookup(settings, @"layout", [NSArray array]);
		_layers = [[NSMutableArray alloc] init];
		for (NSDictionary *layerDict in layoutArray) {
			NSString *layerType = Lookup(layerDict, @"type", nil);
			LiveClockLayerItem *layer;
			if ([layerType isEqualToString:@"hand"])
				layer = [LiveClockHandLayerItem alloc];
			else if ([layerType isEqualToString:@"ellipse"])
				layer = [LiveClockEllipseLayerItem alloc];
			else if ([layerType isEqualToString:@"image"])
				layer = [LiveClockImageLayerItem alloc];
			else {
				NSLog(@"LiveClock: Unknown layer type: %@", layerType);
				continue;
			}
			layer = [layer initWithDictionary:layerDict];
			if (layer) {
				[_layers addObject:layer];
				[layer release];
			}
		}
	}
	return self;
}

- (void)dealloc
{
	[_timer invalidate];
	[_timer release];
	[_layers release];
	[super dealloc];
}

- (BOOL)updatesEnabled
{
	return _timer != nil;
}

- (void)setUpdatesEnabled:(BOOL)updatesEnabled
{
	if (updatesEnabled) {
		if (!_timer) {
			_timer = [[NSTimer scheduledTimerWithTimeInterval:_updateInterval target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES] retain];
			[self setNeedsDisplay];
		}
	} else {
		[_timer invalidate];
		[_timer release];
		_timer = nil;
	}
}

- (void)drawInContext:(CGContextRef)context
{
	// Get Time
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *timeComponents = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
	// Draw each layer
	for (LiveClockLayerItem *layer in _layers)
		[layer drawInContext:context withComponents:timeComponents];
}

@end
