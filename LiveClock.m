#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import <CaptainHook/CaptainHook.h>

#import "TimeView.h"

static NSString *targetBundleId;
static TimeView *activeTimeView;

CHDeclareClass(SBApplicationIcon)
CHDeclareClass(LiveClockApplicationIcon)
CHDeclareClass(SBApplication)

#define SpringBoardBundle [NSBundle mainBundle]
#define SettingsDictionary [NSDictionary dictionaryWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClock" ofType:@"plist"]]

CHOptimizedMethod(1, super, id, LiveClockApplicationIcon, initWithApplication, SBApplication *, application)
{
	if ((self = CHSuper(1, LiveClockApplicationIcon, initWithApplication, application))) {
		if (activeTimeView)
			[activeTimeView removeFromSuperlayer];
		else
			activeTimeView = [[TimeView alloc] initWithSettings:SettingsDictionary];
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

CHOptimizedMethod(0, super, UIImage *, LiveClockApplicationIcon, icon)
{
	UIImage *result = [UIImage imageWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClock" ofType:@"png"]];
	if (result) {
		CHSuper(0, LiveClockApplicationIcon, icon);
		return result;
	}
	return CHSuper(0, LiveClockApplicationIcon, icon);
}

CHOptimizedMethod(1, super, UIImage *, LiveClockApplicationIcon, generateIconImage, int, format)
{
	UIImage *result = [UIImage imageWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClock" ofType:@"png"]];
	if (result) {
		CHSuper(1, LiveClockApplicationIcon, generateIconImage, format);
		return result;
	}
	return CHSuper(1, LiveClockApplicationIcon, generateIconImage, format);
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
	CHHook(0, LiveClockApplicationIcon, icon);
	CHHook(1, LiveClockApplicationIcon, generateIconImage);
	CHHook(1, LiveClockApplicationIcon, setShowsImages);
	CHLoadLateClass(SBApplication);
	CHHook(0, SBApplication, iconClass);
	targetBundleId = [[SettingsDictionary objectForKey:@"target-application"]?:@"com.apple.mobiletimer" retain];
}