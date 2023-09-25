#import <Foundation/Foundation.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

%hook SFAirDropDiscoveryController
-(void)setDiscoverableMode:(long long)arg1 {
	%orig;
	// send to Tweak.x
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.icraze.tempdrop-update" object:nil userInfo:@{@"mode": @(arg1)}];
}
%end
