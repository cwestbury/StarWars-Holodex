//
//  ViewController.m
//  Holodex
//
//  Created by Cameron Westbury on 10/15/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

@interface ViewController ()


@property (nonatomic, weak) IBOutlet        UITableView             *searchResultsTableView;
@property (nonatomic, weak) IBOutlet        UISearchBar             *searchText;
@property (nonatomic, strong)               NSArray                 *searchResultsArray;
@property (nonatomic, strong)               NSString                *hostName;
@property (nonatomic, strong)               NSString                *searchString;
@property (nonatomic, strong)               NSString                *nameString;
@property (nonatomic, weak)     IBOutlet    NSLayoutConstraint      *seachBarTopConstraint;
@property (nonatomic, weak)     IBOutlet    NSLayoutConstraint      *tableViewTopConstraint;

@end

@implementation ViewController


Reachability *hostReach;
Reachability *internetReach;
Reachability *wifiReach;

bool serverAvailable;
bool internetAvailable;

#pragma mark - Interactivity Methods



-(IBAction)thatsNoMoon:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)searchButtonPressed:(id)sender{
    if (_searchText.hidden) {
        _searchText.hidden = !_searchText.hidden;
        _searchResultsTableView.hidden = !_searchResultsTableView.hidden;
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_seachBarTopConstraint setConstant:0.0];
            [_tableViewTopConstraint setConstant:_searchText.frame.size.height];
            [self.view layoutIfNeeded];
            [_searchText becomeFirstResponder];
        } completion:^(BOOL finished) {
        }];
    }  else {
        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_seachBarTopConstraint setConstant:-1*_searchText.frame.size.height];
            [_tableViewTopConstraint setConstant:0.0];

            [_searchText setHidden:true];
            [_searchResultsTableView setHidden:true];
            [self.view layoutIfNeeded];
            [_searchText resignFirstResponder];
        } completion:^(BOOL finished) {
        }];
    }
    
}
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSLog(@"search button pressed");
    if (serverAvailable) {
        _nameString = _searchText.text;
        NSLog(@"Searched Name1: %@",_nameString);
        _nameString = [_nameString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSLog(@"Searched Name2: %@",_nameString);
        //NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/characters?q=%@",_hostName,_nameString]];
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",_hostName,_searchString,_nameString]];
        NSLog(@"File URL: %@",fileURL);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:5.0];
        NSURLSession *session  = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (([data length] > 0) && (error ==nil) ) {
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                NSLog(@"JSON: %@",json);
                _searchResultsArray = [(NSDictionary*) json objectForKey:@"results"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_searchResultsTableView reloadData];
                });
                
                
            }
        }] resume];
    }
}


#pragma mark - Get Image


- (void)getImageFromServer:(NSString *)localFileName fromURL:(NSString *)fullFileName atIndexPath:(NSIndexPath *)indexPath {
    if (serverAvailable) {
        NSURL *fileURL = [NSURL URLWithString:fullFileName];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:fileURL];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [request setTimeoutInterval:30.0];
        NSURLSession *session = [NSURLSession sharedSession];
        NSLog(@"PreSession");
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Length:%li error:%@",[data length],error);
            if (([data length]> 0) && (error == nil)) {
                NSLog(@"Got Data");
                NSString *savedFilePath = [[self getTmpDirectory] stringByAppendingPathComponent:localFileName];
                UIImage *imageTemp = [UIImage imageWithData:data];
                if (imageTemp != nil) {
                    [data writeToFile:savedFilePath atomically:true];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    });
                }
            } else {
                NSLog(@"No data");
            }
        }] resume];
    } else {
        NSLog(@"ServerXX not available");
    }
}

#pragma mark - Tableview Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResultsArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *basicResultsCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"basicCell"];
    NSDictionary *resultsDic = [_searchResultsArray objectAtIndex:indexPath.row];
    basicResultsCell.textLabel.text = [resultsDic objectForKey:@"name"];
    basicResultsCell.detailTextLabel.text = [resultsDic objectForKey:@"species"];
    NSString *imageFileNameURL = [resultsDic objectForKey:@"image"];
    NSString *imageFileName = [resultsDic objectForKey:@"img_file"];
    
    if ([self fileIsLocal:imageFileName]) {
        NSLog(@"Local %@",imageFileName);
        NSString *imageNameWithPath = [[self getTmpDirectory] stringByAppendingPathComponent:imageFileName];
        basicResultsCell.imageView.image =[UIImage imageNamed:imageNameWithPath];
        
    } else {
        NSLog(@"Not Local %@",imageFileName);
        [self getImageFromServer:imageFileName fromURL:imageFileNameURL atIndexPath:indexPath];
        
    }
    
    return basicResultsCell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"mainToDetailSegue"]) {
        DetailViewController *destController = [segue destinationViewController];
        NSIndexPath *indexPath = [_searchResultsTableView indexPathForSelectedRow];
        NSDictionary *selectedResult= _searchResultsArray[indexPath.row];
        destController.selectedResult = selectedResult;
    }
}



#pragma mark - Reachability

- (void)updateReachabilityStatus:(Reachability *)currReach {
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [currReach currentReachabilityStatus];
    if (currReach == hostReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Server Not Reachable");
                serverAvailable = false;
                break;
            case ReachableViaWiFi:
                NSLog(@"Server Reachable via Wifi");
                serverAvailable = true;
                break;
            case ReachableViaWWAN:
                NSLog(@"Server Reachable via WAN");
                serverAvailable = true;
                break;
            default:
                break;
        }
    }
    if (currReach == internetReach) {
        switch (netStatus) {
            case NotReachable:
                NSLog(@"Internet Not Reachable");
                internetAvailable = false;
                break;
            case ReachableViaWiFi:
                NSLog(@"Internet Reachable via Wifi");
                internetAvailable = true;
                break;
            case ReachableViaWWAN:
                NSLog(@"Internet Reachable via WAN");
                internetAvailable = true;
                break;
            default:
                break;
        }
    }
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *currReach = [note object];
    [self updateReachabilityStatus:currReach];
}
-(NSString*)getTmpDirectory {
    NSLog(@"TmpPath:%@",NSTemporaryDirectory());
    return NSTemporaryDirectory();
}

- (BOOL)fileIsLocal:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self getTmpDirectory] stringByAppendingPathComponent:filename];
    return [fileManager fileExistsAtPath:filePath];
}


#pragma mark - Lifecyle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchText.hidden = true;
    _searchResultsTableView.hidden = true;
    
    
    _hostName = @"https://wookieapi.herokuapp.com";
    _searchString = @"/search?name=";
    //_hostName = @"datapad.herokuapp.com";
    //_searchString =@"/api/characters.json?q=";
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    hostReach = [Reachability reachabilityWithHostName:_hostName];
    [hostReach startNotifier];
    [self updateReachabilityStatus:hostReach];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    [self updateReachabilityStatus:internetReach];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
