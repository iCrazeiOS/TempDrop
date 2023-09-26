#import "Tweak.h"

static NSMutableDictionary *prefs;
BOOL tweakEnabled = YES;
int tweakMode = 0;
int switchDelay = 1200; // 20 minutes

NSTimer *timer;
long long previousMode = 0;

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
	long long newMode = [[userInfo objectForKey:@"mode"] longLongValue];
	if (newMode == 2) { // if 'everyone'
		previousMode = [[userInfo objectForKey:@"previousMode"] longLongValue];

		if (timer) {
			[timer invalidate];
			timer = nil;
		}

		timer = [NSTimer scheduledTimerWithTimeInterval:switchDelay repeats:NO block:^(NSTimer *timer) {
			if (tweakMode == 2) {
				[[%c(SFAirDropDiscoveryController) new] setDiscoverableMode:previousMode];
			} else {
				[[%c(SFAirDropDiscoveryController) new] setDiscoverableMode:tweakMode];
			}
		}];
	}
}
%end

%hook CCUILabeledRoundButton
-(void)setSubtitle:(id)subtitle {
	id vc = [self valueForKey:@"_viewControllerForAncestor"];
	if ([vc isMemberOfClass:%c(CCUIConnectivityAirDropViewController)]) {
		id controller = [vc valueForKey:@"_airDropDiscoveryController"];
		if ([[controller valueForKey:@"_discoverableMode"] longLongValue] == 2) {
			%orig([NSString stringWithFormat:@"Everyone for %d minutes", switchDelay / 60]);
			return;
		}
	}
	%orig;
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
