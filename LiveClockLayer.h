#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

__attribute__((visibility("hidden")))
@interface LiveClockLayer : CALayer {
@private
	NSTimer *_timer;
	NSMutableArray *_layers;
	NSTimeInterval _updateInterval;
}

- (id)initWithSettings:(NSDictionary *)settings;

@property (nonatomic, assign) BOOL updatesEnabled;

@end