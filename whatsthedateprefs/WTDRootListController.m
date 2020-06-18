#include "WTDRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>

@implementation WTDRootListController

-(id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

-(void)twitter:(id)sender {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"https://www.twitter.com/iCrazeiOS"] options:@{} completionHandler:nil];
}

-(void)paypal:(id)sender {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"https://paypal.me/iCrazeiOS"] options:@{} completionHandler:nil];
}

-(void)github:(id)sender {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"https://www.github.com/iCrazeiOS/WhatsTheDate"] options:@{} completionHandler:nil];
}

@end
