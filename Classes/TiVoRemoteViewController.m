#include <AudioToolbox/AudioToolbox.h>

#import "TiVoRemoteViewController.h"
#import "TiVoTelnetAccess.h"

#import "ConnectionViewController.h"

@implementation TiVoRemoteViewController

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


// Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
	[super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


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
    
    
/*    
    UIView * adView = [[UIView alloc] initWithFrame: CGRectMake(0,0,320,48)];
    adView.backgroundColor = [UIColor blackColor];
    [self.view.superview addSubview:adView];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    self.view.frame = CGRectMake(0, 48, 320, 382);
*/
    
    int value;
    
    switch (button.tag) {
        case 1:
            value = TTA_LiveTV_Button;
            break;
        case 2:
            value = TTA_Tivo_Button;
            break;
        case 3:
            value = TTA_Aspect_Button;
            break;
        case 4:
            value = TTA_Guide_Button;
            break;
        case 5:
            value = TTA_Info_Button;
            break;
        case 6:
            value = TTA_Up_Button;
            break;
        case 7:
            value = TTA_Left_Button;
            break;
        case 8:
            value = TTA_Down_Button;
            break;
        case 9:
            value = TTA_Right_Button;
            break;       
        case 10:
            value = TTA_Select_Button;
            break;
        case 11:
            value = TTA_PageUp_Button;
            break;
        case 12:
            value = TTA_PageDown_Button;
            break;
        case 13:
            value = TTA_ThumbsUp_Button;
            break;
        case 14:
            value = TTA_ThumbsDown_Button;
            break;
            
        case 15:
            value = TTA_Play_Button;
            break;
        case 16:
            value = TTA_Slow_Button;
            break;
        case 17:
            value = TTA_Replay_Button;
            break;
        case 18:
            value = TTA_Reverse_Button;
            break;
        case 19:
            value = TTA_Pause_Button;
            break;
        case 20:
            value = TTA_Forward_Button;
            break;
        case 21:
            value = TTA_Advance_Button;
            break;
        case 22:
            value = TTA_Clear_Button;
            break;
        case 23:
            value = TTA_Record_Button;
            break;
        case 24:
            value = TTA_Enter_Button;
            break;
            
        default:
            return;
            break;
    }

    if ([service sendButton:value] != 0) {
        [service tivoNotRespondingDialog];
        return;
    }
}

@end
