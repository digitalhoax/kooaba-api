//
//  KooabaQueryAppViewController.h
//  KooabaQueryApp
//
//  Created by Joachim Fornallaz on 12.01.11.
//  Copyright 2011 kooaba AG. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. 
//

#import <UIKit/UIKit.h>

@interface KooabaQueryAppViewController : UIViewController <UIImagePickerControllerDelegate> {
	IBOutlet UIImagePickerController *imagePickerController;
	IBOutlet UITextView *textView;
}

- (IBAction)takePicture;

@end

