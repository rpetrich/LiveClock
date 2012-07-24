TWEAK_NAME = LiveClock
LiveClock_OBJC_FILES = LiveClock.m LiveClockLayer.m
LiveClock_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics QuartzCore

ADDITIONAL_CFLAGS = -std=c99

TARGET_IPHONEOS_DEPLOYMENT_VERSION := 3.0

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
