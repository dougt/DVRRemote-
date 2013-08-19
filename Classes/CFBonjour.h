#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#import <CFNetwork/CFNetwork.h>



@interface CFBonjour : NSObject {
    
    CFNetServiceRef netService;
}

-(void)CFBonjourPublishWithService:(NSString*)newServiceType machineID:(NSString*)userName onPort:(int)port;
-(void)CFBonjourStopCurrentService;
-(void)CFBonjourStartBrowsingForServices:(NSString*)serviceType inDomain:(NSString*)domain;
-(NSMutableArray*)CFBonjourClientsArray;
-(void)countClientsArray;

@end
