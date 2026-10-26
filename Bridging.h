// API private di AppKit usate da MTMR/Pock per mostrare una Touch Bar globale.
#import <AppKit/AppKit.h>

@interface NSTouchBar (SmartPrivate)
+ (void)presentSystemModalTouchBar:(NSTouchBar *)touchBar placement:(long long)placement systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (void)minimizeSystemModalTouchBar:(NSTouchBar *)touchBar;
+ (void)dismissSystemModalTouchBar:(NSTouchBar *)touchBar;
@end

@interface NSTouchBarItem (SmartPrivate)
+ (void)addSystemTrayItem:(NSTouchBarItem *)item;
+ (void)removeSystemTrayItem:(NSTouchBarItem *)item;
@end
