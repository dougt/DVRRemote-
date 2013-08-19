
#import "AboutViewController.h"


@implementation AboutViewController

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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

- (void)viewDidLoad {
    NSURLRequest *aRequest=[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"About" ofType:@"html"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [ourWebView loadRequest:aRequest];
    ourWebView.delegate = self;
    ourWebView.scalesPageToFit = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        if ([request.URL.scheme compare: @"http"] == NSOrderedSame)
        {
            [[UIApplication sharedApplication] openURL: request.URL];
            return NO;
        }
    }
    return YES;
}

- (IBAction)okClicked:(id)sender {
    [owner dismissModalViewControllerAnimated: YES];
}

- (void) setOwner: (id) aOwner
{
    owner = aOwner;
}

@end
