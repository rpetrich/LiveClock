#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <CaptainHook/CaptainHook.h>

#import "TimeView.h"

static NSString *targetBundleId;
static TimeView *activeTimeView;
static UIImage *cachedImage;

CHDeclareClass(SBApplicationIcon)
CHDeclareClass(LiveClockApplicationIcon)
CHDeclareClass(SBApplication)

#define SpringBoardBundle [NSBundle mainBundle]
#define SettingsDictionary [NSDictionary dictionaryWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClock" ofType:@"plist"]]

@interface UIDevice (OS40)
- (BOOL)isWildcat;
@end

@interface UIScreen (OS40)
@property (nonatomic, readonly) CGFloat scale;
@end

@interface CALayer (OS40)
@property (nonatomic, assign) CGFloat contentsScale;
@end

CHOptimizedMethod(1, super, id, LiveClockApplicationIcon, initWithApplication, SBApplication *, application)
{
	if ((self = CHSuper(1, LiveClockApplicationIcon, initWithApplication, application))) {
		if (activeTimeView)
			[activeTimeView removeFromSuperlayer];
		else
			activeTimeView = [[TimeView alloc] initWithSettings:SettingsDictionary];
		if ([activeTimeView respondsToSelector:@selector(setContentsScale:)])
			if ([UIScreen instancesRespondToSelector:@selector(scale)])
				activeTimeView.contentsScale = [UIScreen mainScreen].scale;
		[[self layer] addSublayer:activeTimeView];
	}
	return self;
}

CHOptimizedMethod(0, super, void, LiveClockApplicationIcon, dealloc)
{
	CHSuper(0, LiveClockApplicationIcon, dealloc);
}

CHOptimizedMethod(1, super, void, LiveClockApplicationIcon, setShowsImages, BOOL, showsImages)
{
	[activeTimeView setUpdatesEnabled:showsImages];
	CHSuper(1, LiveClockApplicationIcon, setShowsImages, showsImages);
}

CHOptimizedMethod(1, super, void, LiveClockApplicationIcon, setDisplayedIcon, UIImage *, image)
{
	// 3.x
	if (cachedImage) {
		CHSuper(1, LiveClockApplicationIcon, setDisplayedIcon, cachedImage);
		return;
	}
	if ([UIDevice instancesRespondToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat]) {
		cachedImage = [[UIImage alloc] initWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClockIcon-72" ofType:@"png"]];
		if (cachedImage) {
			CHSuper(1, LiveClockApplicationIcon, setDisplayedIcon, cachedImage);
			return;
		}
	}
	cachedImage = [[UIImage alloc] initWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClock" ofType:@"png"]];
	if (cachedImage) {
		CHSuper(1, LiveClockApplicationIcon, setDisplayedIcon, cachedImage);
		return;
	}
	CHSuper(1, LiveClockApplicationIcon, setDisplayedIcon, image);
}

CHOptimizedMethod(1, super, void, LiveClockApplicationIcon, setDisplayedIconImage, UIImage *, image)
{
	// 4.0
	if (cachedImage) {
		CHSuper(1, LiveClockApplicationIcon, setDisplayedIconImage, cachedImage);
		return;
	}
	if ([UIDevice instancesRespondToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat]) {
		cachedImage = [[UIImage alloc] initWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClockIcon-72" ofType:@"png"]];
		if (cachedImage) {
			CHSuper(1, LiveClockApplicationIcon, setDisplayedIconImage, cachedImage);
			return;
		}
	}
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		CGFloat scale = [[UIScreen mainScreen] scale];
		if (scale != 1.0f) {
			NSString *scaledName = [NSString stringWithFormat:@"LiveClockIcon@%.0fx", scale];
			cachedImage = [[UIImage alloc] initWithContentsOfFile:[SpringBoardBundle pathForResource:scaledName ofType:@"png"]];
			if (cachedImage) {
				CHSuper(1, LiveClockApplicationIcon, setDisplayedIconImage, cachedImage);
				return;
			}
		}
	}
	cachedImage = [[UIImage alloc] initWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClockIcon" ofType:@"png"]];
	if (cachedImage) {
		CHSuper(1, LiveClockApplicationIcon, setDisplayedIconImage, cachedImage);
		return;
	}
	cachedImage = [[UIImage alloc] initWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClock" ofType:@"png"]];
	if (cachedImage) {
		CHSuper(1, LiveClockApplicationIcon, setDisplayedIconImage, cachedImage);
		return;
	}
	CHSuper(1, LiveClockApplicationIcon, setDisplayedIconImage, image);
}

CHOptimizedMethod(0, super, UIImage *, LiveClockApplicationIcon, imageForReflection)
{
	return cachedImage ?: CHSuper(0, LiveClockApplicationIcon, imageForReflection);
}

CHOptimizedMethod(0, self, Class, SBApplication, iconClass)
{
	if ([[self bundleIdentifier] isEqualToString:targetBundleId]) {
		if ([[SettingsDictionary objectForKey:@"enabled"] boolValue]) {
			CHSuper(0, SBApplication, iconClass);
			return CHClass(LiveClockApplicationIcon);
		}
	}
	return CHSuper(0, SBApplication, iconClass);
}

CHConstructor {
	CHAutoreleasePoolForScope();
	CHLoadLateClass(SBApplicationIcon);
	CHRegisterClass(LiveClockApplicationIcon, SBApplicationIcon) {
	}
	CHHook(1, LiveClockApplicationIcon, initWithApplication);
	CHHook(0, LiveClockApplicationIcon, dealloc);
	CHHook(1, LiveClockApplicationIcon, setDisplayedIcon);
	CHHook(1, LiveClockApplicationIcon, setDisplayedIconImage);
	CHHook(1, LiveClockApplicationIcon, setShowsImages);
	CHHook(0, LiveClockApplicationIcon, imageForReflection);
	CHLoadLateClass(SBApplication);
	CHHook(0, SBApplication, iconClass);
	targetBundleId = [[SettingsDictionary objectForKey:@"target-application"]?:@"com.apple.mobiletimer" retain];
}