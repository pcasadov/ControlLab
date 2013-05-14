//
//  ControlLabkKeyViewController.m
//  ControlLab
//
//  Created by Pablo Casado Varela on 30/04/13.
//  Copyright (c) 2013 Pablo Casado Varela. All rights reserved.
//

#import "ControlLabkKeyViewController.h"

@interface ControlLabkKeyViewController (){
    CAGradientLayer *bgLayer;
    UIColor *color;
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    UILabel *label4;
    UITextField *textFieldUser;
    UITextField *textFieldPass;

}

@end

@implementation ControlLabkKeyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // Initialization code
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSString *user;
        NSString *pass;

        if (standardUserDefaults) {
            user = [standardUserDefaults objectForKey:@"usuario"];
            pass = [standardUserDefaults objectForKey:@"password"];
        }
        [self.view setBounds:CGRectMake(0, 0, 280, 250)];
        // Custom initialization
        NSString *deviceType = [UIDevice currentDevice].model;

        if([deviceType isEqualToString:@"iPhone"]) {
            // For iPhone
            bgLayer = [ControlLabBackgroundLayer greyGradient];
            bgLayer.frame = self.view.bounds;
            [self.view.layer insertSublayer:bgLayer atIndex:0];


            [self.view setBackgroundColor:[UIColor whiteColor]];
            color = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0];


            label1 = [[UILabel alloc ]initWithFrame:CGRectMake(20, 10, 200, 30)];
            [label1 setText:@"User"];
            [label1 setBackgroundColor:color];
            label1.font = [UIFont fontWithName: @"MarkerFelt-Thin" size: 25.0];
            [label1 setTextAlignment: NSTextAlignmentLeft];

            textFieldUser = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, 200, 30)];
            textFieldUser.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            textFieldUser.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            textFieldUser.text = user;
            textFieldUser.userInteractionEnabled = YES;
            textFieldUser.borderStyle = UITextBorderStyleRoundedRect;
            textFieldUser.clearButtonMode = UITextFieldViewModeWhileEditing;
            [textFieldUser setEnabled:YES];
            [textFieldUser addTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];

            [textFieldUser becomeFirstResponder];

            label2 = [[UILabel alloc ]initWithFrame:CGRectMake(20, 110, 200, 30)];
            [label2 setText:@"Password"];
            [label2 setBackgroundColor:color];
            label2.font = [UIFont fontWithName:@"MarkerFelt-Thin" size: 25.0];
            [label2 setTextAlignment: NSTextAlignmentLeft];

            textFieldPass = [[UITextField alloc] initWithFrame:CGRectMake(20, 160, 200, 30)];
            textFieldPass.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            textFieldPass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            textFieldPass.text = pass;
            textFieldPass.userInteractionEnabled = YES;
            textFieldPass.borderStyle = UITextBorderStyleRoundedRect;
            textFieldPass.clearButtonMode = UITextFieldViewModeWhileEditing;
            textFieldPass.secureTextEntry = YES;
            [textFieldPass addTarget:self action:@selector(hideKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
            [textFieldPass setEnabled:YES];


            // ADD ELEMENTS TO VIEW
            [self.view addSubview:label1];
            [self.view addSubview:label2];
            [self.view addSubview:textFieldUser];
            [self.view addSubview:textFieldPass];



        }
        else {
            // For iPad
            bgLayer = [ControlLabBackgroundLayer greyGradient];
            bgLayer.frame = self.view.bounds;
            [self.view.layer insertSublayer:bgLayer atIndex:0];


            [self.view setBackgroundColor:[UIColor whiteColor]];
            color = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0];


            label1 = [[UILabel alloc ]initWithFrame:CGRectMake(20, 10, 200, 30)];
            [label1 setText:@"User"];
            [label1 setBackgroundColor:color];
            label1.font = [UIFont fontWithName: @"MarkerFelt-Thin" size: 25.0];
            [label1 setTextAlignment: NSTextAlignmentLeft];

            textFieldUser = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, 200, 30)];
            textFieldUser.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            textFieldUser.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            textFieldUser.text = user;
            textFieldUser.userInteractionEnabled = YES;
            textFieldUser.borderStyle = UITextBorderStyleRoundedRect;
            textFieldUser.clearButtonMode = UITextFieldViewModeWhileEditing;
            [textFieldUser setEnabled:YES];
            [textFieldUser becomeFirstResponder];

            label2 = [[UILabel alloc ]initWithFrame:CGRectMake(20, 110, 200, 30)];
            [label2 setText:@"Password"];
            [label2 setBackgroundColor:color];
            label2.font = [UIFont fontWithName:@"MarkerFelt-Thin" size: 25.0];
            [label2 setTextAlignment: NSTextAlignmentLeft];

            textFieldPass = [[UITextField alloc] initWithFrame:CGRectMake(20, 160, 200, 30)];
            textFieldPass.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
            textFieldPass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            textFieldPass.text = pass;
            textFieldPass.userInteractionEnabled = YES;
            textFieldPass.borderStyle = UITextBorderStyleRoundedRect;
            textFieldPass.clearButtonMode = UITextFieldViewModeWhileEditing;
            textFieldPass.secureTextEntry = YES;
            [textFieldPass setEnabled:YES];


            // ADD ELEMENTS TO VIEW
            [self.view addSubview:label1];
            [self.view addSubview:label2];
            [self.view addSubview:textFieldUser];
            [self.view addSubview:textFieldPass];
        }

    }
    return self;
}

- (IBAction)hideKeyboard:(id)sender {
    NSString *usuario = textFieldUser.text;
    NSString *password = textFieldPass.text;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"usuario %@", usuario);
    NSLog(@"password %@", password);

    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSString stringWithString:usuario] forKey:@"usuario"];
        [standardUserDefaults setObject:[NSString stringWithString:password] forKey:@"password"];
        [standardUserDefaults synchronize];
    }

    [sender resignFirstResponder];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
