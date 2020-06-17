ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WhatsTheDatePrefs

WhatsTheDatePrefs_FILES = WTDRootListController.m
WhatsTheDatePrefs_INSTALL_PATH = /Library/PreferenceBundles
WhatsTheDatePrefs_FRAMEWORKS = UIKit
WhatsTheDatePrefs_PRIVATE_FRAMEWORKS = Preferences
WhatsTheDatePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/WhatsTheDatePrefs.plist$(ECHO_END)
