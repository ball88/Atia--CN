ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Atria
$(TWEAK_NAME)_FILES = $(wildcard Hooks/*.xm src/Editor/*.m src/Manager/*.m src/UI/*.m)
$(TWEAK_NAME)_FRAMEWORKS = UIKit CoreGraphics CoreText QuartzCore
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -w

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
