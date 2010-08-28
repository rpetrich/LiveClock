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

CHMethod1(id, LiveClockApplicationIcon, initWithApplication, SBApplication *, application)
{
	if ((self = CHSuper1(LiveClockApplicationIcon, initWithApplication, application))) {
		if (activeTimeView)
			[activeTimeView removeFromSuperlayer];
		else
			activeTimeView = [[TimeView alloc] initWithSettings:SettingsDictionary];
		[[self layer] addSublayer:activeTimeView];
	}
	return self;
}

CHMethod0(void, LiveClockApplicationIcon, dealloc)
{
	CHSuper0(LiveClockApplicationIcon, dealloc);
}

CHMethod1(void, LiveClockApplicationIcon, setShowsImages, BOOL, showsImages)
{
	[activeTimeView setUpdatesEnabled:showsImages];
	CHSuper1(LiveClockApplicationIcon, setShowsImages, showsImages);
}

CHMethod0(UIImage *, LiveClockApplicationIcon, icon)
{
	UIImage *result = [UIImage imageWithContentsOfFile:[SpringBoardBundle pathForResource:@"LiveClock" ofType:@"png"]];
	if (result) {
		CHSuper0(LiveClockApplicationIcon, icon);
		return result;
	}
	return CHSuper0(LiveClockApplicationIcon, icon);
}

CHMethod0(Class, SBApplication, iconClass)
{
	if ([[self bundleIdentifier] isEqualToString:targetBundleId]) {
		if ([[SettingsDictionary objectForKey:@"enabled"] boolValue])
			return CHClass(LiveClockApplicationIcon);
	}
	return CHSuper0(SBApplication, iconClass);
}

CHConstructor {
	CHLoadLateClass(SBApplicationIcon);
	CHRegisterClass(LiveClockApplicationIcon, SBApplicationIcon) {
	}
	CHHook1(LiveClockApplicationIcon, initWithApplication);
	CHHook0(LiveClockApplicationIcon, dealloc);
	CHHook0(LiveClockApplicationIcon, icon);
	CHHook1(LiveClockApplicationIcon, setShowsImages);
	CHLoadLateClass(SBApplication);
	CHHook0(SBApplication, iconClass);
	CHAutoreleasePoolForScope();
	targetBundleId = [[SettingsDictionary objectForKey:@"target-application"]?:@"com.apple.mobiletimer" retain];
}