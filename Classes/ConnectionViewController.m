
#import "ConnectionViewController.h"
#import "TiVoTelnetAccess.h"
#import "AboutViewController.h"
#import "TiVoRemoteAppDelegate.h"
#import "EnterIPViewController.h"

@implementation ConnectionViewController

- (void) newBeaconFound: (TivoBeacon*) beacon
{
    // notify the list to update
    [ourTableView reloadData];
}

- (void) beaconConnectionUpdate:(TivoBeacon*) beacon withMessage: (NSString*) message
{
    // notify the list to update
    
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];    
	
    TivoBeacon *currentlySelectBeacon = [[service availableTivos] objectAtIndex:[ourTableView indexPathForSelectedRow].row];
   
    // is there a better way to compare objects in obj-c?
    if ([[currentlySelectBeacon ip]  compare: [beacon ip]] != NSOrderedSame)
        return;
    
    UILabel *label = (UILabel *) [[ourTableView cellForRowAtIndexPath: [ourTableView indexPathForSelectedRow]].contentView viewWithTag:2];
    label.text = message;
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];    
	return [[service availableTivos] count] + 1; /* one extra for the waiting one */
}



//This method will be called n number of times.
//Where n = total number of items in the array.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    UITableViewCell *cell;

    if (indexPath.row ==  [[service availableTivos] count])
    {        
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
            
        UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithFrame:cell.bounds];
            
        [ai setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [ai sizeToFit];
            
        ai.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                               UIViewAutoresizingFlexibleRightMargin |
                               UIViewAutoresizingFlexibleTopMargin |
                               UIViewAutoresizingFlexibleBottomMargin);
            
        [ai startAnimating];
        [ai setCenter:[cell.contentView center]];
            
        [cell.contentView addSubview:ai];
            
        [ai release];
        return cell;
    }
 
	cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
        
    UILabel* label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.text = [[[service availableTivos] objectAtIndex:indexPath.row] machineName];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];

    [label setCenter:[cell.contentView center]];
    
    label.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                           UIViewAutoresizingFlexibleRightMargin |
                           UIViewAutoresizingFlexibleTopMargin |
                           UIViewAutoresizingFlexibleBottomMargin);
    
    [cell.contentView addSubview:label];

    [label release];
        
	// return the table cell.
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic

    // how do we get the previous cell so that we can revert the multi view stuff?
    [ourTableView reloadData];

    // check to see if this is the one with the progress ui in it.
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    if (indexPath.row == [[service availableTivos] count])
    {
        return;
    }
    
	int index = [indexPath indexAtPosition: [indexPath length] - 1];
    [service setActiveTivo: [[service availableTivos] objectAtIndex:index]];
    
    // lets move the user to the controls
    
    TivoRemoteAppDelegate *appDelegate = (TivoRemoteAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarController.selectedIndex = 1;

}

- (void) checkForLastConnection {
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    TivoBeacon *last = [service getLastConnectedTivo];
    if (last)
    {
        [service setActiveTivo: last];
        TivoRemoteAppDelegate *appDelegate = (TivoRemoteAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.tabBarController.selectedIndex = 1;
        return;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // be notified when the tivos on the network are updated.
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    [service setListener: self];
    
    NSTimer *timer1 = [NSTimer timerWithTimeInterval:0.0 target:self selector:@selector(checkForLastConnection) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
    
    // Set up an alert to reminder the user that we can continue searching, but haven't found anything
    NSTimer *timer2 = [NSTimer timerWithTimeInterval:0.0 target:self selector:@selector(checkForTivos) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
    
    ourTableView.backgroundColor = [UIColor clearColor];
    [manuallyEnterButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];

}

- (void) addBackTable {
    [rb removeFromSuperview];
    [rb addTarget:self action:@selector(actionRemove) forControlEvents:UIControlEventTouchUpInside];
    [rb release];

    ourTableView.hidden = NO;
    
    // Set up an alert to reminder the user that we can continue searching, but haven't found anything  (45 seconds)
    NSTimer *timer = [NSTimer timerWithTimeInterval:45.0 target:self selector:@selector(anyTivosFound) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void) replaceTableWithSearchButton
{
    // Hide the table, and replace it with a button that allows a rescan.
    
    ourTableView.hidden = YES;
    
    rb = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    rb.frame = CGRectMake(0, 0, 250, 60);
    rb.backgroundColor = [UIColor clearColor];
    [rb setTitle:@"Search for TiVo® DVRs" forState:UIControlStateNormal];
    rb.center = self.view.center;
    
    [rb addTarget:self action:@selector(addBackTable) forControlEvents:UIControlEventTouchUpInside];    
    
    [self.view addSubview:rb];
}


- (void) anyTivosFound
{
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    if ([[service availableTivos] count] > 0)
    {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"No Tivos have been found on this network."
                                                   delegate:NULL
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    
    [self replaceTableWithSearchButton];

}

- (void) checkForTivos {
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    if ([[service availableTivos] count] == 0)
    {
        [self replaceTableWithSearchButton];
        return;
    }
    else
        ourTableView.hidden = NO;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

-(IBAction) buttonWasPressed:(id)sender
{
    AboutViewController *about = [[AboutViewController alloc] initWithNibName:@"About" bundle:[NSBundle mainBundle]];
    [about setOwner: self];
    
    [self presentModalViewController: about animated: YES];
    [about release];
}

-(IBAction) enterIPAddress:(id)sender
{
    EnterIPViewController *evc = [[EnterIPViewController alloc] initWithNibName:@"EnterTivoIP" bundle:[NSBundle mainBundle]];
    [evc setOwner: self];
    [self presentModalViewController: evc animated: YES];
    [evc release];
}

-(void) userEnteredValidIP:(NSString*)ip
{
    TivoBeacon *tivo = [TivoBeacon beaconWithMachine: ip 
                                                 ip: ip];
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    [service setActiveTivo: tivo];
    
    // lets move the user to the controls
    TivoRemoteAppDelegate *appDelegate = (TivoRemoteAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabBarController.selectedIndex = 1;
}
@end
