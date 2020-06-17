// Interfaces
@interface CSTimerView : UIView
@end

@interface SBFLockScreenDateSubtitleDateView : UIView
@end

static NSTimer *whatsthedateTimer;

/* Preferences */
static BOOL kEnabled;

// Create loadPrefs method
// We call it from the constructor (end of file)
static void loadPrefs() {
	// Initialise NSMutableDictionary from the preferences plist file
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.icraze.whatsthedateprefs.plist"];
	// Assign the value of kEnabled to a BOOL, and set the default value to YES
	kEnabled = [prefs objectForKey:@"kEnabled"] ? [[prefs objectForKey:@"kEnabled"] boolValue] : YES;
}

/* Main tweak code */
%hook SBBacklightController
// This method is called whenever the screen turns on or off
-(void)setBacklightFactorPending:(float)arg1 {
	// Run the original code first
	%orig;
	// Turn the argument (arg1) into a string
	NSString *checkForAutoLockString = [NSString stringWithFormat: @"%f", arg1];
	// When the screen turns on, the string contains "1.00000"
	// When the screen turns of, the string contains "0.00000"
	// We want to check if the string doesn't contain "1", so we can detect when the screen turned off
	if (![checkForAutoLockString containsString:@"1"]) {
		// Reset the timer
		[whatsthedateTimer invalidate];
	}
}
%end

%hook CSTimerView
// This method is called when the view is displayed
-(void)movedToWindow:(id)arg1 {
	// Run the original code first
	%orig;
	// Check if the tweak is enabled
	if (kEnabled) {
		// Start timer for 3.5 seconds after CSTimerView is displayed
		whatsthedateTimer = [NSTimer scheduledTimerWithTimeInterval:3.5f target:self selector:@selector(afterTimerViewTimer) userInfo:nil repeats:NO];
	}
}
// Create a new method in the class
%new
// When the timer ends
-(void)afterTimerViewTimer {
	// Check if the tweak is enabled
	if (kEnabled) {
		// Start animating the view to disappear
		// I have chosen to make the animation take 0.5 seconds,
		// as it seems very similar to the timing Apple uses for the Barrtery Percentage,
		// when you unlock the device whilst charging
		[UIView animateWithDuration:0.5f animations:^{
				// Set the alpha of the view to 0
				self.alpha = 0.0f;
			// Once the animation is complete
			} completion:^(BOOL finished){
				// Erase the timer from memory
				whatsthedateTimer = nil;
				// Send NSNotification to SBFLockScreenDateSubtitleDateView
				NSNotification *alrmaShowDateNotification = [NSNotification notificationWithName:@"alrmaShowDateNotification" object:self userInfo:nil];
				[[NSNotificationCenter defaultCenter] postNotification:alrmaShowDateNotification];
			}
		];
	}
}
%end

%hook SBFLockScreenDateSubtitleDateView
// This method is called when the view is displayed
-(void)didMoveToWindow {
	// Run the original code first
	%orig;
	// Add an NSNotification observer
	// This detects the notification from CSTimerView
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whatsthedateShowDateText) name:@"alrmaShowDateNotification" object:nil];
}
// Create a new method in the class
%new
// When the NSNotification is received
-(void)whatsthedateShowDateText {
	// Check if the tweak is enabled
	if (kEnabled) {
		// Start animating the view to disappear
		// I have chosen to make the animation take 0.5 seconds,
		// as it seems very similar to the timing Apple uses for the Barrtery Percentage,
		// when you unlock the device whilst charging
		[UIView animateWithDuration:0.5f animations:^{
				// Set the alpha of the view to 1
				self.alpha = 1.0f;
			} completion:^(BOOL finished){}
		];
	}
}
%end

/* Constructor */
// This code runs when the tweak is injected into a process
// In this case, we are just injecting into SpringBoard
%ctor {
	// Call the loadPrefs method
	loadPrefs();
	// Add a CFNotification obsever
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.icraze.whatsthedateprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);

	// Check if the tweak is not enabled
	if (!kEnabled) {
		// Don't run anymore code past here
		return;
	}

	// Run the tweak
	%init;
}
