//
//  TabChooserViewController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabListViewController.h"
#import "TTTab.h"
#import "WebViewViewController.h"
#import "TabViewCell.h"
#import "Helpers.h"

@interface TabListViewController () {
    NSString *searchString;
}

- (void)tabsLoaded:(NSNotification *)notification;

@end


@implementation TabListViewController

@synthesize browser;
@synthesize searchResults;
@synthesize tabSearchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)performSearchFor:(NSString *)aSearchString
{
    searchString = aSearchString;
    
    if (searchString == @"") {
        searchString = nil;
    }
    
    if (!searchString) {
        self.searchResults = [self.browser tabs];
    } else {
        self.searchResults = [self.browser tabsContainingString:searchString];
    }
}

- (void)openPage:(TTTab *)tab;
{
    WebViewViewController *browserView = [[WebViewViewController alloc] initWithNibName:@"WebViewViewController" bundle:nil];
    browserView.browserTab = tab;
    
    [self.navigationController pushViewController:browserView animated:YES]; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabsLoaded:) name:@"updatedTabList" object:nil];

    searchString = nil;
    
    self.title = self.browser.label;
    self.tableView.rowHeight = 72;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabSearchBar.text = @"";
    [self performSearchFor:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [browser performSelector:@selector(loadImages) withObject:nil afterDelay:3.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark PullToRefreshTableViewController

- (void)reloadTableViewDataSource;
{
    [self.browser loadTabs];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TabCell";
    
    TabViewCell *cell = (TabViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TabViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    TTTab *tab = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.tab = tab;
    
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

#pragma mark - SearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSearchFor:searchText];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [self performSearchFor:nil];
    [self.tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    searchBar.showsCancelButton = YES;
    [UIView commitAnimations];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}


#pragma mark SearchViewDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)aSearchString
{
    [self performSearchFor:aSearchString];
    [self.tableView reloadData];
    return YES;
}


#pragma mark ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [self.tableView.visibleCells enumerateObjectsUsingBlock:^(TabViewCell *cell, NSUInteger idx, BOOL *stop) {
            [cell setBackgroundViewVisible:NO animated:YES];
        }];
    }
}


#pragma mark Private Methods

- (void)tabsLoaded:(NSNotification *)notification;
{
    [refreshHeaderView setCurrentDate];
    [self dataSourceDidFinishLoadingNewData];
    
    NSArray *oldTabs = self.searchResults;
    [self performSearchFor:searchString];
    NSArray *newTabs = self.searchResults;
    
    [self.tableView beginUpdates];
    
    // removing old tabs
    [oldTabs enumerateObjectsUsingBlock:^(TTTab *oldTab, NSUInteger idx, BOOL *stop) {
        NSIndexSet *indexSet = [newTabs indexesOfObjectsPassingTest:^BOOL(TTTab *newTab, NSUInteger idx, BOOL *stop) {
            return oldTab.tabId == newTab.tabId; 
        }];
        if (indexSet.count == 0) {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    // adding new tabs
    [newTabs enumerateObjectsUsingBlock:^(TTTab *newTab, NSUInteger idx, BOOL *stop) {
        NSIndexSet *indexSet = [oldTabs indexesOfObjectsPassingTest:^BOOL(TTTab *oldTab, NSUInteger idx, BOOL *stop) {
            return oldTab.tabId == newTab.tabId; 
        }];
        if (indexSet.count == 0) {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];

    [self.tableView endUpdates];
}

@end
