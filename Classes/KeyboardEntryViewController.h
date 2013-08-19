
#import <UIKit/UIKit.h>


@interface KeyboardEntryViewController : UIViewController {
    IBOutlet UITextField* ourTextField;
    IBOutlet UISegmentedControl* ourSegmentedControl;
    
    int current_x;
    int current_y;
}

-(IBAction) sendWasPressed:(id)sender;
-(IBAction) clearWasPressed:(id)sender;

@end
