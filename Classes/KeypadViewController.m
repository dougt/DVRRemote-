
#import "KeypadViewController.h"
#import "TiVoTelnetAccess.h"


@implementation KeypadViewController

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
    UIButton* button = sender;
    
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    if ([service hasConnected] == NO) {
        [service tivoNotRespondingDialog];
        return;
    }
    

    
    if (button.tag >= 0 && button.tag <= 9)
    {
        if ([service sendNumber:button.tag] != 0)
            [service tivoNotRespondingDialog];
        return;
    }
    
    int value;

    if (button.tag == 100)
        value = TTA_ChannelUp_Button;
    else if (button.tag == 200)
        value = TTA_ChannelDown_Button;
    else if (button.tag == 300)
        value = TTA_Enter_Button;
    else if (button.tag == 400)
        value = TTA_LiveTV_Button;
    else if (button.tag == 500)
        value = TTA_Display_Button;
    else
        return;
    
    if ([service sendButton:value] != 0)
        [service tivoNotRespondingDialog];
}

@end
