#import "TMPDRPRootListController.h"

@implementation TMPDRPRootListController
-(void)loadView {
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
}

-(void)respring {
	pid_t pid;
	const char* args[] = {"sbreload", NULL, NULL};
	posix_spawn(&pid, ROOT_PATH("/usr/bin/sbreload"), NULL, NULL, (char* const*)args, NULL);
}

-(NSString *)plistPathForFilename:(NSString *)filename {
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", filename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb/var/mobile/Library/Preferences/"]) {
		path = [@"/var/jb" stringByAppendingString:path];
	}
	return path;
}

-(id)readPreferenceValue:(PSSpecifier *)specifier {
	NSString *path = [self plistPathForFilename:specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSString *path = [self plistPathForFilename:specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
}

-(NSArray *)specifiers {
	if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	return _specifiers;
}

-(void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/iCrazeiOS/TempDrop"] options:@{} completionHandler:nil];
}

-(void)twitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/iCrazeiOS"] options:@{} completionHandler:nil];
}

-(void)nexus {
	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:[NSURL URLWithString:@"sileo://"]]) {
		[app openURL:[NSURL URLWithString:@"sileo://package/com.icraze.nexus"] options:@{} completionHandler:nil];
	} else if ([app canOpenURL:[NSURL URLWithString:@"zbra://"]]) {
		[app openURL:[NSURL URLWithString:@"zbra://packages/com.icraze.nexus?source=https://havoc.app"] options:@{} completionHandler:nil];
	} else {
		[app openURL:[NSURL URLWithString:@"https://havoc.app/package/nexus"] options:@{} completionHandler:nil];
	}
}

-(void)paypal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/iCrazeiOS/2.50"] options:@{} completionHandler:nil];
}
@end
