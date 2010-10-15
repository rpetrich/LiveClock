#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TimeView : CALayer {
@private
	NSTimer *_timer;
	NSMutableArray *_layers;
	NSTimeInterval _updateInterval;
}

- (id)initWithSettings:(NSDictionary *)settings;

@property (nonatomic, assign) BOOL updatesEnabled;

@end