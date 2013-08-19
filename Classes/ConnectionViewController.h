
#import <UIKit/UIKit.h>
#import "TiVoTelnetAccess.h"

@interface ConnectionViewController : UIViewController <TivoBeaconListener, UIWebViewDelegate> {    
    IBOutlet UITableView *ourTableView;
    UIButton *rb;
    
    IBOutlet UIButton* manuallyEnterButton;
    id owner;
}

-(IBAction) buttonWasPressed:(id)sender;
-(IBAction) enterIPAddress:(id)sender;

-(void) userEnteredValidIP:(NSString*)ip;

@end
