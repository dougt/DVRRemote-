#import "KeyboardEntryViewController.h"
#import "TiVoTelnetAccess.h"


@implementation KeyboardEntryViewController

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

-(id) init {
    self = [super init];
    current_x = 0;
    current_y = 0;
    return self;
}


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

-(IBAction) clearWasPressed:(id)sender
{
    [ourTextField resignFirstResponder];
    
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];

    if ([service hasConnected] == NO) {
        [service tivoNotRespondingDialog];
        return;
    }
        
    while(current_x-- > 0)
        if ([service sendButton: TTA_Left_Button] != 0)
        {
            [service tivoNotRespondingDialog];
            return;
        }

    while(current_y-- > 0)
        if ([service sendButton: TTA_Up_Button] != 0)
        {
            [service tivoNotRespondingDialog];
            return;
        }
    
    if ([service sendButton: TTA_Clear_Button] != 0)
    {
        [service tivoNotRespondingDialog];
        return;
    }
    
    current_y = current_x = 0;
    ourTextField.text = @"";
}

-(IBAction) sendWasPressed: (id)sender
{
    [ourTextField resignFirstResponder];
    
    TiVoTelnetAccess* service = [TiVoTelnetAccess TiVoTelnetAccessService];
    
    // check to see if there is an active connection (maybe move this functionality to the service so that I do not have to check the beacon itself.
    TivoBeacon* activeBeacon = [service getActiveTivo];
    
    if ([activeBeacon hasConnected] == NO) {
        [service tivoNotRespondingDialog];
        return;
    }
    
    int target_x = 0;
    int target_y = 0;
    
    int width;
    if ([ourSegmentedControl selectedSegmentIndex] == 0)
        width = 4;
    else if ([ourSegmentedControl selectedSegmentIndex] == 1)
        width = 5;
    else
        width = 9;
    
    const char* message = [[ourTextField.text uppercaseString] UTF8String]; // hmm this HAS to be ASCII
    while (message && *message)
    {
        char ch = *message;
            if ( 'A' <= ch && ch <= 'Z' )
            {
                char pos = ch - 'A';
                
                target_y = pos / width;
                target_x = pos % width;
                
                if (target_y > current_y)
                {
                    for (int i = 0; i < (target_y - current_y); i++)
                        if ([service sendButton: TTA_Down_Button] != 0)
                        {
                            [service tivoNotRespondingDialog];
                            return;
                        }
                }
                else
                {
                    for (int i = 0; i < (current_y - target_y); i++)
                        if ([service sendButton: TTA_Up_Button] != 0)
                        {
                            [service tivoNotRespondingDialog];
                            return;
                        }

                }
                
                if (target_x > current_x)
                {
                    for (int i = 0; i < (target_x - current_x); i++)
                        if ([service sendButton: TTA_Right_Button] != 0)
                        {
                            [service tivoNotRespondingDialog];
                            return;
                        }
                }
                else
                {
                    for (int i = 0; i < (current_x - target_x); i++)
                        if ([service sendButton: TTA_Left_Button] != 0)
                        {
                            [service tivoNotRespondingDialog];
                            return;
                        }
                }
                [service sendButton: TTA_Select_Button];
                current_y = target_y;
                current_x = target_x;
                
            }
            else if ( '0' <= ch && ch <= '9')
            {
                int value = atoi(&ch);
                if ([service sendNumber: value] != 0)
                {
                    [service tivoNotRespondingDialog];
                    return;
                }

            }
            else if (ch == ' ')
            {
                if ([service sendButton: TTA_Forward_Button] != 0)
                {
                    [service tivoNotRespondingDialog];
                    return;
                }
            }
        
        message++;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // hide our text field
    [ourTextField resignFirstResponder];
}

@end
