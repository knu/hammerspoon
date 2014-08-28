#import <Cocoa/Cocoa.h>
#import "MJMainWindowController.h"
#import "MJExtensionManager.h"
#import "MJConfigUtils.h"
#import "MJUpdateChecker.h"
#import "MJDockIcon.h"
#import "MJMenuIcon.h"
#import "MJLua.h"
#import "variables.h"

@interface MJAppDelegate : NSObject <NSApplicationDelegate>
@property IBOutlet NSMenu* menuBarMenu;
@property IBOutlet NSMenu* dockIconMenu;
@end

@implementation MJAppDelegate

- (BOOL) applicationOpenUntitledFile:(NSApplication *)sender {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[MJMainWindowController sharedMainWindowController] showWindow: nil];
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self registerDefaultDefaults];
    MJMenuIconSetup(self.menuBarMenu);
    MJDockIconSetup();
    MJUpdateCheckerSetup();
    MJConfigEnsureDirExists();
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:MJConfigPath()];
    [[MJExtensionManager sharedManager] setup];
    [[MJMainWindowController sharedMainWindowController] maybeShowWindow];
    MJLuaSetup();
    [[MJExtensionManager sharedManager] loadInstalledModules];
    MJLuaReloadConfig();
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
    return self.dockIconMenu;
}

- (void) registerDefaultDefaults {
    [[NSUserDefaults standardUserDefaults]
     registerDefaults: @{MJCheckForUpdatesKey: @YES,
                         MJShowDockIconKey: @YES,
                         MJShowWindowAtLaunchKey: @YES,
                         MJShowMenuIconKey: @NO}];
}

- (IBAction) reloadConfig:(id)sender {
    MJLuaReloadConfig();
}

- (IBAction) showMainWindow:(id)sender {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[MJMainWindowController sharedMainWindowController] showWindow: nil];
}

- (IBAction) showAboutPanel:(id)sender {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel: nil];
}

- (IBAction) checkForUpdates:(id)sender {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    MJUpdateCheckerCheckVerbosely();
}

@end

int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}
