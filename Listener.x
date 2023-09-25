#import "Listener.h"

%hook SFAirDropDiscoveryController
-(void)setDiscoverableMode:(long long)arg1 {
	long long previousMode = self.discoverableMode;
	%orig;
	// send to Tweak.x
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.icraze.tempdrop-update" object:nil userInfo:@{
		@"mode": @(arg1),
		@"previousMode": @(previousMode)
	}];
}
%end
