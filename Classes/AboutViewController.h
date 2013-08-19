
#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController<UIWebViewDelegate> {
    IBOutlet UIWebView *ourWebView;
    id owner;

}

- (IBAction)okClicked:(id)sender;
- (void) setOwner: (id) owner;

@end
