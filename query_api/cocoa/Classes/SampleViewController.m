//
//  SampleViewController.m
//  kooabaQuerySample
//
//  Created by Joachim Fornallaz on 18.09.09.
//  Copyright kooaba AG 2009. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. 
//

#import "SampleViewController.h"

#import "KooabaQuery.h"

@implementation SampleViewController

- (IBAction)takePicture
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	[self presentModalViewController:imagePickerController animated:YES];
}

- (void)imagePickerController: (UIImagePickerController *)picker
		didFinishPickingImage: (UIImage *)image
				  editingInfo: (NSDictionary *)editingInfo {
	
	[self dismissModalViewControllerAnimated:YES];

	NSData *jpegData = UIImageJPEGRepresentation(image, 0.75);
	KooabaQuery *query = [[KooabaQuery alloc] initWithImageData:jpegData type:@"jpeg"];
	query.accessKey = @"df8d23140eb443505c0661c5b58294ef472baf64";
	query.secretKey = @"054a431c8cd9c3cf819f3bc7aba592cc84c09ff7";
	query.groupIds = [NSArray arrayWithObject:[NSNumber numberWithInt:32]];
	NSString *result = [query create];
	textView.text = result;
	
	NSLog(@"The return string  %@", result);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	textView.font = [UIFont fontWithName:@"Courier" size:12.0];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
}


- (void)dealloc {
    [super dealloc];
}

@end
