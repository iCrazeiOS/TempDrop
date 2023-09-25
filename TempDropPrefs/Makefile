ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TempDropPrefs

TempDropPrefs_FILES = TMPDRPRootListController.m
TempDropPrefs_INSTALL_PATH = /Library/PreferenceBundles
TempDropPrefs_FRAMEWORKS = UIKit
TempDropPrefs_PRIVATE_FRAMEWORKS = Preferences
TempDropPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TempDropPrefs.plist$(ECHO_END)
