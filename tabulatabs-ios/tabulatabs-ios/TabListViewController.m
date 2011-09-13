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

- (void)performSearchFor:(NSString *)searchString
{
    if ([searchString isEqualToString:@""]) {
        self.searchResults = [self.browser tabs];
    } else {
        self.searchResults = [self.browser tabsContainingString:searchString];
    }
    
    [self.tableView reloadData];
}

- (void)openPage:(TTTab *)tab;
{
    WebViewViewController *browserView = [[WebViewViewController alloc] initWithNibName:@"BrowserViewController" bundle:nil];
    browserView.browserTab = tab;
    
    [self.navigationController pushViewController:browserView animated:YES]; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"updatedTabList" object:nil];

    self.title = self.browser.label;
    UITableView *tableView = self.tableView;
    
    tableView.rowHeight = 72;
}

- (void)viewDidUnload
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabSearchBar.text = @"";
    [self performSearchFor:@""];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [browser performSelector:@selector(loadImages) withObject:nil afterDelay:3.0];
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
    return YES;
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
    
    cell.markedAsRead = indexPath.row == 4;
    
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
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = nil;
    [self performSearchFor:nil];
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self performSearchFor:searchString];
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

@end
