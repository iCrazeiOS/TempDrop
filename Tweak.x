#import <Foundation/Foundation.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

@interface SFAirDropDiscoveryController : NSObject
-(void)setDiscoverableMode:(long long)arg1;
@end

static NSMutableDictionary *prefs;
BOOL tweakEnabled = YES;
int tweakMode = 0;
int switchDelay = 1200; // 20 minutes

NSTimer *timer;

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	// notifs are sent from Listener.xm
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(tempdrop_update:) name:@"com.icraze.tempdrop-update" object:nil];
}

%new
-(void)tempdrop_update:(NSNotification *)notification {
	if (!tweakEnabled) return;
	
	NSDictionary *userInfo = [notification userInfo];
	long long mode = [[userInfo objectForKey:@"mode"] intValue];
	if (mode == 2) { // if 'everyone'
		if (timer) {
			[timer invalidate];
			timer = nil;
		}
		
		timer = [NSTimer scheduledTimerWithTimeInterval:switchDelay repeats:NO block:^(NSTimer *timer) {
			[[%c(SFAirDropDiscoveryController) new] setDiscoverableMode:tweakMode];
		}];
	}
}
%end


static void loadPrefs() {
	// thanks xina for making us do this :)
	NSString *path = @"/var/mobile/Library/Preferences/com.icraze.tempdropprefs.plist";
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb/var/mobile/Library/Preferences/"]) {
		path = [@"/var/jb" stringByAppendingString:path];
	}
	prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

	tweakEnabled = prefs[@"enabled"] ? [prefs[@"enabled"] boolValue] : YES;
	tweakMode = prefs[@"mode"] ? [prefs[@"mode"] intValue] : 0;
	switchDelay = (prefs[@"delay"] ? [prefs[@"delay"] intValue] : 20) * 60; // * 60 to convert to minutes
}

%ctor {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) return;
	loadPrefs();
	if (!tweakEnabled) return;

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.icraze.tempdropprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	%init;
}
