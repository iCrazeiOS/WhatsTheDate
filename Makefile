ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WhatsTheDate

WhatsTheDate_FILES = Tweak.xm
WhatsTheDate_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += whatsthedateprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
