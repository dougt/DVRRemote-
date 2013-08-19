
#import "TiVoTelnetAccess.h"

#include <netdb.h>
#include <sys/socket.h>
#include <sys/poll.h>
#include <sys/fcntl.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>



@implementation TivoBeacon

+ (id) beaconWithMachine: (NSString*)machineName ip:(NSString*)ipName
{
    TivoBeacon* tb = [[TivoBeacon alloc] init];
    
    [machineName retain];
    tb->machine = machineName;
    
    [ipName retain];
    tb->ip = ipName;
    
    tb->writeTimestamp = nil;
    
    return tb;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
   [encoder encodeObject:machine forKey:@"machine"];
   [encoder encodeObject:ip      forKey:@"ip"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
   [super init];
   
   machine =  [[decoder decodeObjectForKey:@"machine"] retain];
   ip      =  [[decoder decodeObjectForKey:@"ip"] retain];
   writeTimestamp = nil;
    
   return self;
}


- (void)dealloc {
    [machine release];
    [ip release];
    [connectionListener release];
    [writeTimestamp release];
    [super dealloc];
}


- (NSString *) machineName
{
    return machine;
}

- (NSString *) ip
{
    return ip;
}


- (void) postStatusUpdate: (NSString*) message
{
    SEL callback = @selector(beaconConnectionUpdate:withMessage:);
    
    NSMethodSignature* signature = [connectionListener methodSignatureForSelector:callback];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:connectionListener];
    [invocation setSelector:callback];
    [invocation setArgument:&self atIndex:2];
    [invocation setArgument:&message atIndex:3];
    
    // Since the callback might touch the UI, we need to make sure that the callback happens
    // on the UI thread.    
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
}

- (void) connectInternal
{    
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
        
    sd = socket(AF_INET, SOCK_STREAM, 0);
    
    if (sd == -1) {
        hasFailed = YES;
        [self postStatusUpdate: @"Could not connect to Tivo"];
        return;
    }
    
    [self postStatusUpdate: @"Looking up Tivo..."];
    
    struct sockaddr_in sin;
    struct hostent *host = gethostbyname([ip UTF8String]);
    
    if (host == NULL) {
        hasFailed = YES;
        [self postStatusUpdate: @"Could not connect to Tivo"];
        return;
    }
    
    memcpy(&sin.sin_addr.s_addr, host->h_addr, host->h_length);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(31339);
    
    [self postStatusUpdate: @"Connecting..."];
  
    // Set this socket for non-blocking.
    int flags;
    if (-1 == (flags = fcntl(sd, F_GETFL, 0)))
        flags = 0;
    
    fcntl(sd, F_SETFL, flags | O_NONBLOCK);
    
    connect(sd, (struct sockaddr *)&sin, sizeof(sin));
    
    // Poll to allow time to connect.
    struct pollfd pollfds[2];
    pollfds[ 0 ].fd = sd;
    pollfds[ 0 ].events = POLLOUT;
    pollfds[ 0 ].revents = 0;
    int rc = poll( pollfds, 1, 5000 );
    
    if( rc == 0 || (! (pollfds[ 0 ].revents & POLLOUT)))
    {
        hasFailed = YES;
        [self postStatusUpdate: @"Could not connect to this Tivo."];
        sd = -1;
        return;
    }
    
    NSString * str = @"Connected to ";
    str = [str stringByAppendingString: self.machineName];
    
    [self postStatusUpdate: str];
    
    [writeTimestamp release];
    writeTimestamp = [[NSDate date] retain];
    hasConnected = YES;

    [autoreleasepool release];
    
    return;
}

- (void) connect: (id <TivoBeaconListener>) listener
{
    hasConnected = NO;
    hasFailed = NO;
    
    [listener retain];
    [connectionListener release];
    connectionListener = listener;
    
    [self postStatusUpdate: @"Attempting to connect..."];
    
    if (sd != -1)
    {
        close(sd);
        sd = -1;
    }
    // The rest of this needs to happen off of the main thread.
    [NSThread detachNewThreadSelector:@selector(connectInternal) toTarget: self withObject:nil];   
}

- (BOOL) hasConnected
{
    return hasConnected;
}

- (BOOL) hasFailed
{
    return hasFailed;
}

- (void) throttleIfRequired
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:writeTimestamp];
    if( interval < .25 )
        sleep(.25);
    [writeTimestamp release];
    writeTimestamp = [[NSDate date] retain];
}

- (int) sendButton: (int) button
{
    
    if (hasConnected == NO)
        return -1;
    
    char* tivoCode;
    
    switch (button)
    {
        case TTA_Up_Button: 
            tivoCode = "IRCODE UP\r";
            break;
            
        case TTA_Down_Button:
            tivoCode = "IRCODE DOWN\r";
            break;
            
        case TTA_Left_Button:
            tivoCode = "IRCODE LEFT\r";
            break;
            
        case TTA_Right_Button:
            tivoCode = "IRCODE RIGHT\r";
            break;
            
        case TTA_Select_Button:
            tivoCode = "IRCODE SELECT\r";
            break;
            
        case TTA_Forward_Button:
            tivoCode = "IRCODE FORWARD\r";
            break;
            
        case TTA_Clear_Button:
            tivoCode = "IRCODE CLEAR\r";
            break;
            
        case TTA_LiveTV_Button:
            tivoCode = "IRCODE LIVETV\r";
            break;
            
        case TTA_ThumbsUp_Button:
            tivoCode = "IRCODE THUMBSUP\r";
            break;
            
        case TTA_ThumbsDown_Button:
            tivoCode = "IRCODE THUMBSDOWN\r";
            break;
            
        case TTA_ChannelUp_Button:
            tivoCode = "IRCODE CHANNELUP\r";
            break;
            
        case TTA_ChannelDown_Button:
            tivoCode = "IRCODE CHANNELDOWN\r";
            break;
            
        case TTA_Record_Button:
            tivoCode = "IRCODE RECORD\r";
            break;
            
        case TTA_Display_Button:
            tivoCode = "IRCODE DISPLAY\r";
            break;
            
        case TTA_Enter_Button:
            tivoCode = "IRCODE ENTER\r";
            break;
            
        case TTA_Play_Button:
            tivoCode = "IRCODE PLAY\r";
            break;
            
        case TTA_Pause_Button:
            tivoCode = "IRCODE PAUSE\r";
            break;
            
        case TTA_Slow_Button:
            tivoCode = "IRCODE SLOW\r";
            break;
            
        case TTA_Reverse_Button:
            tivoCode = "IRCODE REVERSE\r";
            break;
            
        case TTA_StandBy_Button:
            tivoCode = "IRCODE STANDBY\r";
            break;
            
        case TTA_NowShowing_Button:
            tivoCode = "IRCODE NOWSHOWING\r";
            break;
            
        case TTA_Replay_Button:
            tivoCode = "IRCODE REPLAY\r";
            break;
            
        case TTA_Advance_Button:
            tivoCode = "IRCODE ADVANCE\r";
            break;
            
        case TTA_Delimiter_Button:
            tivoCode = "IRCODE DELIMITER\r";
            break;
            
        case TTA_Guide_Button:
            tivoCode = "IRCODE GUIDE\r";
            break;
            
        case TTA_Aspect_Button:
            tivoCode = "IRCODE WINDOW\r";
            break;
        
        case TTA_Info_Button:
            tivoCode = "IRCODE INFO\r";
            break;
            
        case TTA_PageUp_Button:
            tivoCode = "IRCODE CHANNELUP\r";
            break;
            
        case TTA_PageDown_Button:
            tivoCode = "IRCODE CHANNELDOWN\r";
            break;
            
        default:
            tivoCode = "IRCODE TIVO\r";
    }
    
    int len = strlen(tivoCode);

    [self throttleIfRequired];

    int result = write(sd, tivoCode, len);
    if (result < len)
    {
        [self postStatusUpdate: @"Disconnected"];
        return -1;
    }
    
    return 0;
}

- (int)  sendNumber: (int) value
{
    if (hasConnected == NO)
        return -1;
    
    char buffer[32];
    sprintf(buffer, "IRCODE NUM%d\r", value);
    int len = strlen(buffer);
    
    [self throttleIfRequired];

    int result = write(sd, buffer, len);
    
    if (result < len)
    {
        [self postStatusUpdate: @"Disconnected"];
        return -1;
    }
    
    return 0;
}

@end


@implementation TiVoTelnetAccess

+ (TiVoTelnetAccess *)TiVoTelnetAccessService
{
    static TiVoTelnetAccess *TiVoTelnetAccessService;
    
    @synchronized(self)
    {
        if (!TiVoTelnetAccessService)
            TiVoTelnetAccessService = [[TiVoTelnetAccess alloc] init];
        
        return TiVoTelnetAccessService;
    }
    return NULL;
}

+(BOOL) doesTivoRespond:(NSString*) ip
{
    int sd = socket(AF_INET, SOCK_STREAM, 0);
    
    if (sd == -1)
        return NO;
    
    struct sockaddr_in sin;
    struct hostent *host = gethostbyname([ip UTF8String]);
    if (host == NULL)
        return NO;
    
    memcpy(&sin.sin_addr.s_addr, host->h_addr, host->h_length);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(31339);
    
    // Set this socket for non-blocking.
    int flags;
    if (-1 == (flags = fcntl(sd, F_GETFL, 0)))
        flags = 0;
    
    fcntl(sd, F_SETFL, flags | O_NONBLOCK);
    
    connect(sd, (struct sockaddr *)&sin, sizeof(sin));
    
    // Poll to allow time to connect.
    struct pollfd pollfds[2];
    pollfds[ 0 ].fd = sd;
    pollfds[ 0 ].events = POLLOUT;
    pollfds[ 0 ].revents = 0;
    int rc = poll( pollfds, 1, 5000 );

    if( rc == 0 || (! (pollfds[ 0 ].revents & POLLOUT)))
    {
        return NO;
    }
    
    close(sd);
    
    return YES;
}


-(id) init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];

    seenTivoBeacons = [[NSMutableArray alloc] init];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *list = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey: @"SeenTivoBeacons"]];
    if (list)
        [seenTivoBeacons addObjectsFromArray:list];
    
    sigset_t sigchld_mask;
    sigemptyset(&sigchld_mask);
    sigaddset(&sigchld_mask, SIGPIPE);
    sigprocmask(SIG_BLOCK, &sigchld_mask, NULL);

    bonjour = [[CFBonjour alloc] init];
    [bonjour CFBonjourStartBrowsingForServices:@"_tivo-videos._tcp." inDomain:@""];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bonjourClientAdded:) name:@"bonjourClientAdded" object:nil];
    
    lastConnectedTivo = nil;
    NSString *lastConnectedIP = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastConnectedTivo"];
    if (lastConnectedIP)
    {
        id element;
        for(element in seenTivoBeacons)
        {
            if ([lastConnectedIP  compare: [element ip]] == NSOrderedSame) {
                lastConnectedTivo = element;
            }
        }
    }
    else
    {
        activeBeacon = nil; 
    }
    
    return self;
}

- (TivoBeacon*) getLastConnectedTivo
{
    return lastConnectedTivo;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    NSMutableArray* connectedBeacons = [[NSMutableArray alloc] init];

    id element;
    
    for(element in seenTivoBeacons)
        if ([element hasFailed] == NO)
            [connectedBeacons addObject: element];
            
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:connectedBeacons] forKey:@"SeenTivoBeacons"];
    
   [defaults setObject:[activeBeacon ip] forKey:@"LastConnectedTivo"];

   [defaults synchronize];
   
   [connectedBeacons release];
    
    // TODO:  we need to free TiVoTelnetAccessService when the app quits. xxx

}

- (void)dealloc {
    
    [seenTivoBeacons release];
    [activeBeacon release];
    [listener release];
    
    [super dealloc];
}

- (void) setListener: (id <TivoBeaconListener>) aListener
{
    listener = aListener;
}

- (NSArray*) availableTivos
{
    NSArray *result = [ NSArray array ];  // memory allocation here?
    result = [ result arrayByAddingObjectsFromArray: seenTivoBeacons ];
    return result;
}

-(void) bonjourClientAdded:(NSNotification *) notification
{
    // contains: serviceName resolvedIP port
    NSString* serviceName = [[notification userInfo] objectForKey:@"serviceName"];
    NSString* ipAddr = [[notification userInfo] objectForKey:@"resolvedIP"];
    NSString* port = [[notification userInfo] objectForKey:@"port"];

    printf("%s, %s, %s\n", [serviceName UTF8String], [ipAddr UTF8String], [port UTF8String]);
    id element;
    for(element in seenTivoBeacons)
    {
        if ([serviceName  compare: [element machineName]] == NSOrderedSame)
            return;  // we already have seen this.
    }
    
    TivoBeacon *arg = [TivoBeacon beaconWithMachine: serviceName 
                                                 ip: ipAddr];
    
    // if it doesn't exist, add it to our array
    [seenTivoBeacons addObject: arg];
    
    // notify any listeners of the change
    SEL callback = @selector(newBeaconFound:);
    NSMethodSignature* signature = [listener methodSignatureForSelector: callback];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:listener];
    [invocation setSelector:callback];
    [invocation setArgument:&arg atIndex:2];
    
    // Since the callback might touch the UI, we need to make sure that the callback happens
    // on the UI thread.    
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
    
}

- (void) setActiveTivo: (TivoBeacon*) beacon
{
    [beacon retain];
    [activeBeacon release];
    activeBeacon = beacon;
    
    [activeBeacon connect: listener];
}

- (TivoBeacon*) getActiveTivo
{
    return activeBeacon;
}

- (BOOL) hasConnected
{
    if (activeBeacon == nil)
        return NO;
    
    return activeBeacon.hasConnected;
}

/* although I thought that this class should be free of UI stuff, it is pretty nice to have this code in one place.
   I probably should move it to a common ui class or something
 */

-(void) tivoNotRespondingDialog
{
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    TivoBeacon* beacon = [service getActiveTivo];
    NSString* value;
    
    if (beacon)
        value = [[NSString alloc] initWithFormat:@"The Tivo \"%@\" is not responding.", [beacon machineName]];
    else
        value = @"Not connected to any Tivo.";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                              message:value
                                              delegate:NULL
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    [value autorelease];
    
}

- (int) sendNumber: (int) value
{
    if ([activeBeacon hasConnected] == NO)
        return -1;
    
    if ([activeBeacon sendNumber: value] != 0)
        return -1;
    
    return 0;
}

- (int) sendButton: (int) button
{
    if ([activeBeacon hasConnected] == NO)
        return -1;
        
    if ([activeBeacon sendButton: button] != 0)
        return -1;
    
    return 0;
}

@end
