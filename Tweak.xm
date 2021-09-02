// Interfaces
@interface CSTimerView : UIView
@end

@interface SBFLockScreenDateSubtitleDateView : UIView
@end

static NSTimer *viewSwitchTimer;
static SBFLockScreenDateSubtitleDateView *dateView;

/* Preferences */
static BOOL kEnabled;
static float kTimeBeforeSwitch;

static void loadPrefs() {
	// Initialise NSMutableDictionary from the preferences plist file
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.icraze.whatsthedateprefs.plist"];
	kEnabled = [prefs objectForKey:@"kEnabled"] ? [[prefs objectForKey:@"kEnabled"] boolValue] : YES;
	kTimeBeforeSwitch = [prefs objectForKey:@"kTimeBeforeSwitch"] ? [[prefs objectForKey:@"kTimeBeforeSwitch"] floatValue] : 3.5f;
}

/* Main tweak code */
%hook CSTimerView
// when timer label appears
-(void)movedToWindow:(id)arg1 {
	%orig;
	if (!kEnabled) return;

	// the slider for kTimeBeforeSwitch doesn't fire a notif so we will reload manually just in case
	loadPrefs();

	// set up timer to switch to date view after kTimeBeforeSwitch
	viewSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeBeforeSwitch target:self selector:@selector(viewSwitchTimer_fire) userInfo:nil repeats:NO];
}

// add a new method to the class (NSNotification callback)
%new
-(void)viewSwitchTimer_fire {
	if (!kEnabled) return;

	// fade out timer label
	[UIView animateWithDuration:0.5f animations:^{
		self.alpha = 0.0f;
	} completion:^(BOOL finished) {
		// fade in date view
		[dateView whatsthedate_fadeIn];
	}];
}
%end

%hook SBFLockScreenDateSubtitleDateView
-(void)didMoveToWindow {
	%orig;
	dateView = self;
}

// add a new method to the class
%new
-(void)whatsthedate_fadeIn {
	[UIView animateWithDuration:0.5f animations:^{
		self.alpha = 1.0f;
	}];
}
%end

%hook SBBacklightController
// this method is called whenever the screen turns on or off
-(void)setBacklightFactorPending:(float)arg1 {
	%orig;

	// if screen turning off, reset the timer
	if (arg1 == 0) {
		[viewSwitchTimer invalidate];
		viewSwitchTimer = nil;
	}
}
%end

%ctor {
	// register prefs
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.icraze.whatsthedateprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	// load hooks
	if (kEnabled) %init;
}
