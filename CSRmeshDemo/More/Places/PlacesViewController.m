//
//  PlacesViewController.m
//  CSRmeshDemo
//
//  Created by AcTEC on 2017/12/22.
//  Copyright © 2017年 Cambridge Silicon Radio Ltd. All rights reserved.
//

#import "PlacesViewController.h"
#import "CSRDatabaseManager.h"
#import "CSRPlaceEntity.h"
#import "CSRConstants.h"
#import "CSRmeshStyleKit.h"
#import "CSRUtilities.h"
#import "CSRAppStateManager.h"
#import "PlaceDetailsViewController.h"

#import "AppDelegate.h"

@interface PlacesViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray *placesArray;
@property (nonatomic,assign) NSInteger selectedRow;

@end

@implementation PlacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Places";
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backSetting)];
        self.navigationItem.leftBarButtonItem = left;
    }
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
    self.navigationItem.rightBarButtonItem = add;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.0f;
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    _importedURL = ((AppDelegate*)[UIApplication sharedApplication].delegate).passingURL;
}

- (void)addAction {
    PlaceDetailsViewController *pdvc = [[PlaceDetailsViewController alloc] init];
    pdvc.navigationItem.title = @"Creat a new place";
    [self.navigationController pushViewController:pdvc animated:YES];
}

- (void)backSetting{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromLeft];
    [self.view.window.layer addAnimation:animation forKey:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshPlaces];
}

- (void)refreshPlaces {
    [self.placesArray removeAllObjects];
    self.placesArray = [[[CSRDatabaseManager sharedInstance] fetchObjectsWithEntityName:@"CSRPlaceEntity" withPredicate:nil] mutableCopy];
    if (self.placesArray != nil || [self.placesArray count] != 0 ) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        [_placesArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_placesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1];
        
    }
    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [accessoryButton setBackgroundImage:[CSRmeshStyleKit imageOfGear] forState:UIControlStateNormal];
    [accessoryButton addTarget:self action:(@selector(jumpDetaileView:)) forControlEvents:UIControlEventTouchUpInside];
    accessoryButton.tag = indexPath.row;
    cell.accessoryView = accessoryButton;
    
    if (self.placesArray && [self.placesArray count] > 0) {
        CSRPlaceEntity *placeEntity = [self.placesArray objectAtIndex:indexPath.row];
        if (placeEntity) {
            cell.textLabel.text = placeEntity.name;
            if ([CSRAppStateManager sharedInstance].selectedPlace && [[placeEntity objectID] isEqual:[[CSRAppStateManager sharedInstance].selectedPlace objectID]]) {
                _selectedRow = indexPath.row;
                cell.imageView.image = [UIImage imageNamed:@"Be_selected"];
            }else {
                cell.imageView.image = [UIImage imageNamed:@"To_select"];
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

-(void)jumpDetaileView:(UIButton *)sender {
    PlaceDetailsViewController *pdvc = [[PlaceDetailsViewController alloc] init];
    pdvc.navigationItem.title = @"Edit place";
    pdvc.placeEntity = [self.placesArray objectAtIndex:sender.tag];
    [self.navigationController pushViewController:pdvc animated:YES];
}

#pragma mark - table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedRow) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (_placesArray && [_placesArray count] > 0) {
        if ([[_placesArray objectAtIndex:indexPath.row] isKindOfClass:[CSRPlaceEntity class]]) {
            CSRPlaceEntity *placeEntuty = [_placesArray objectAtIndex:indexPath.row];
            [self showAlert:placeEntuty];
        }
    }
}

- (void) showAlert:(CSRPlaceEntity *)placeEntuty
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert!"
                                                                             message:[NSString stringWithFormat:@"Are you sure you want to switch place to the %@.",placeEntuty.name]
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Alert!"];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1] range:NSMakeRange(0, [[attributedTitle string] length])];
    [alertController setValue:attributedTitle forKey:@"attributedTitle"];
    NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Are you sure you want to switch place to the %@.",placeEntuty.name]];
    [attributedMessage addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1] range:NSMakeRange(0, [[attributedMessage string] length])];
    [alertController setValue:attributedMessage forKey:@"attributedMessage"];
    [alertController.view setTintColor:DARKORAGE];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [CSRAppStateManager sharedInstance].selectedPlace = placeEntuty;
                                                         
                                                         if (![[CSRUtilities getValueFromDefaultsForKey:@"kCSRLastSelectedPlaceID"] isEqualToString:[[[[CSRAppStateManager sharedInstance].selectedPlace objectID] URIRepresentation] absoluteString]]) {
                                                             
                                                             [CSRUtilities saveObject:[[[[CSRAppStateManager sharedInstance].selectedPlace objectID] URIRepresentation] absoluteString] toDefaultsWithKey:@"kCSRLastSelectedPlaceID"];
                                                             
                                                         }
                                                         
                                                         [[CSRAppStateManager sharedInstance] setupPlace];
                                                         
                                                         [self.tableView reloadData];
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"reGetDataForPlaceChanged" object:nil];
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel 
                                                   handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - lazy

- (NSMutableArray *)placesArray {
    if (!_placesArray) {
        _placesArray = [[NSMutableArray alloc] init];
    }
    return _placesArray;
}



@end
