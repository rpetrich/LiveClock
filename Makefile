TWEAK_NAME = LiveClock
LiveClock_OBJC_FILES = LiveClock.m LiveClockLayer.m
LiveClock_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics QuartzCore

ADDITIONAL_CFLAGS = -std=c99

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
