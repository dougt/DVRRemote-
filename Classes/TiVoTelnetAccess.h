
#import <UIKit/UIKit.h>
#import "CFBonjour.h"

@class TivoBeacon;

@protocol TivoBeaconListener <NSObject>
- (void) newBeaconFound:(TivoBeacon*) beacon;
- (void) beaconConnectionUpdate:(TivoBeacon*) beacon withMessage: (NSString*) message;
@end

@interface TivoBeacon : NSObject<NSCoding>
{
    NSString* machine;
    NSString* ip;
    
    int sd;
    BOOL hasConnected;
    BOOL hasFailed;
    NSDate* writeTimestamp;

    id connectionListener; // implements TivoBeaconListener
}

+ (id) beaconWithMachine: (NSString*)datagram ip:(NSString*)ipString;

- (NSString *) machineName;
- (NSString *) ip;
- (BOOL) hasConnected;

- (void) connect: (id <TivoBeaconListener>) listener;
- (int)  sendButton: (int) button;
- (int)  sendNumber: (int) value;

@end


@interface TiVoTelnetAccess : NSObject  <UIActionSheetDelegate> {
    
    id listener; // implements TivoBeaconListener
    
    NSMutableArray* seenTivoBeacons;
    TivoBeacon* activeBeacon;
    TivoBeacon* lastConnectedTivo;
    
    CFBonjour *bonjour;
}

enum 
{ 
    TTA_Tivo_Button = 1, 
    TTA_Up_Button, 
    TTA_Down_Button, 
    TTA_Left_Button, 
    TTA_Right_Button,
    TTA_Select_Button,
    TTA_Forward_Button,
    TTA_Clear_Button,
    TTA_LiveTV_Button,
    TTA_ThumbsUp_Button,
    TTA_ThumbsDown_Button,
    TTA_ChannelUp_Button,
    TTA_ChannelDown_Button,
    TTA_Record_Button,
    TTA_Display_Button,
    TTA_Enter_Button,
    TTA_Play_Button,
    TTA_Pause_Button,
    TTA_Slow_Button,
    TTA_Reverse_Button,
    TTA_StandBy_Button,
    TTA_NowShowing_Button,
    TTA_Replay_Button,
    TTA_Advance_Button,
    TTA_Delimiter_Button,
    TTA_Guide_Button,
    TTA_Aspect_Button,
    TTA_Info_Button,
    TTA_PageUp_Button,
    TTA_PageDown_Button
};


+ (TiVoTelnetAccess *) TiVoTelnetAccessService;
+(BOOL) doesTivoRespond:(NSString*) ip;

- (void) setListener: (id <TivoBeaconListener>) listener;

- (NSArray*) availableTivos;

- (void) setActiveTivo: (TivoBeacon*) beacon;
- (TivoBeacon*) getActiveTivo;

- (TivoBeacon*) getLastConnectedTivo;

- (int) sendButton: (int) button;
- (int) sendNumber: (int) value;

- (BOOL) hasConnected;

/* default dialing */
- (void) tivoNotRespondingDialog;

@end
