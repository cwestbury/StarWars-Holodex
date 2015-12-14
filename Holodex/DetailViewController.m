//
//  DetailViewController.m
//  Holodex
//
//  Created by Cameron Westbury on 10/15/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

#import "DetailViewController.h"
#import "ViewController.h"

@interface DetailViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *characterImageViewDetail;
@property (nonatomic, weak) IBOutlet UITextView *characterInfoTextField;
@property (nonatomic, weak) IBOutlet UITextView *characterStats;
@property (nonatomic, weak) IBOutlet UISegmentedControl *textSelector;


@end

@implementation DetailViewController

#pragma Interactivity Methods

-(NSString*)getTmpDirectory {
    NSLog(@"TmpPath:%@",NSTemporaryDirectory());
    return NSTemporaryDirectory();
}

- (BOOL)fileIsLocal:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self getTmpDirectory] stringByAppendingPathComponent:filename];
    return [fileManager fileExistsAtPath:filePath];
}

-(IBAction)segControllerValueChanged:(UISegmentedControl*)segController {
    NSString *nameString = [segController titleForSegmentAtIndex:segController.selectedSegmentIndex];
    NSLog(@"Value Changed %li %@,", segController.selectedSegmentIndex,nameString);
    if ([nameString isEqualToString:@"Biography"]) {
        _characterInfoTextField.text =[_selectedResult objectForKey:@"bio"];
    } else if ([nameString isEqualToString:@"Facts"]) {
        _characterInfoTextField.text = [_selectedResult objectForKey:@"snippet"];
    } else if ([nameString isEqualToString:@"Webview"]) {
        SFSafariViewController *safariVC =
    [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://starwars.wikia.com/wiki/Main_Page"]];
    [self.navigationController presentViewController:safariVC animated:true completion:nil];
    }
}

#pragma Lifcycle Methods

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *characterName = [_selectedResult objectForKey:@"name"];
    NSString *characterSpecies = [_selectedResult objectForKey:@"species"];
    if ([characterSpecies isEqualToString:@"null"]) {
        characterSpecies = @"Unknown";
    }
    NSString *characterHomeworld = [_selectedResult objectForKey:@"homeworld"];
    if ([characterHomeworld isEqualToString:@"null"]) {
        characterHomeworld = @"Unknown";
    }
    NSString *characterHeight = [_selectedResult objectForKey:@"height"];
    if ([characterHeight isEqualToString:@"null"]) {
        characterHeight = @"Unkown";
    }
    NSString *characterWeight = [_selectedResult objectForKey:@"mass"];
    if ([characterWeight isEqualToString:@"null"]) {
        characterWeight = @"Unknown";
    }
    
    NSString *characterGender = [_selectedResult objectForKey:@"gender"];
    if ([characterGender isEqualToString:@"null"]) {
        characterGender = @"Unknown";
    }
    

   
    NSString *imageFileName = [_selectedResult objectForKey:@"img_file"];
    NSString *imageNameWithPath = [[self getTmpDirectory] stringByAppendingPathComponent:imageFileName];
    _characterImageViewDetail.image =[UIImage imageNamed:imageNameWithPath];
    _characterStats.text = [NSString stringWithFormat:@"Name: %@\nSpecies: %@\nHomeworld: %@\nHeight: %@\nWeight: %@\nGender: %@",characterName,characterSpecies,characterHomeworld,characterHeight,characterWeight,characterGender];
    _characterInfoTextField.text =[_selectedResult objectForKey:@"snippet"];
     UIFont *appfont = [UIFont fontWithName:@"Avenir" size:17];
    _characterStats.font = [UIFont fontWithName:@"Avenir" size:16];;
    _characterInfoTextField.font = appfont;
}


@end
