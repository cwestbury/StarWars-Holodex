//
//  DetailViewController.h
//  Holodex
//
//  Created by Cameron Westbury on 10/15/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface DetailViewController : UIViewController <SFSafariViewControllerDelegate>


@property (nonatomic, strong) NSDictionary *selectedResult;

@end
