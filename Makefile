FW_DEVICE_IP = 192.168.1.144
SDKVERSION = 4.2
TWEAK_NAME = LiveClock
LiveClock_OBJC_FILES = LiveClock.m TimeView.m
LiveClock_FRAMEWORKS = CoreFoundation Foundation UIKit CoreGraphics QuartzCore

ADDITIONAL_CFLAGS = -std=c99

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
