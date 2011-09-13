//
//  BrowserChooserViewController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 23.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BrowserListViewController.h"
#import "TTBrowser.h"
#import "TabulatabsApp.h"
#import "AddBrowserStepsViewController.h"
#import "TabListViewController.h"
#import "TabActionController.h"

const int BrowserChooserViewControllerBrowserSelectionSection = 0;
const int BrowserChooserViewControllerAddBrowserSection = 1;

@implementation BrowserListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.title = NSLocalizedString(@"TabulaTabs", @"TabulaTabs");
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"updatedBrowserList" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == BrowserChooserViewControllerBrowserSelectionSection) {
        return [TabulatabsApp.sharedInstance.browserRepresenations count];
    } else if (section == BrowserChooserViewControllerAddBrowserSection) {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == BrowserChooserViewControllerBrowserSelectionSection)
    {
        TTBrowser *browser = [[TabulatabsApp sharedInstance].browserRepresenations objectAtIndex:[indexPath row]];
        cell.textLabel.text = browser.label;
        
        if (!browser.browserInfoLoaded) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [activityView startAnimating];
            
            cell.accessoryView = activityView;
        } else {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == BrowserChooserViewControllerAddBrowserSection)
    {
        cell.textLabel.text = NSLocalizedString(@"Add your Browser", @"Add a new Browser Table cell label");
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == BrowserChooserViewControllerAddBrowserSection) {
        AddBrowserStepsViewController *browserSteps = [[AddBrowserStepsViewController alloc] initWithNibName:@"AddBrowserStepsViewController" bundle:nil];
        
        browserSteps.openerViewController = self;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:browserSteps];
        [self presentModalViewController:navigationController animated:YES];
    }
    else if (indexPath.section == BrowserChooserViewControllerBrowserSelectionSection) {
        TabListViewController *tabChooser = [[TabListViewController alloc] initWithNibName:@"TabChooserViewController" bundle:nil];
        tabChooser.browser = [[TabulatabsApp sharedInstance].browserRepresenations objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:tabChooser animated:YES];
    }
    
}

@end
