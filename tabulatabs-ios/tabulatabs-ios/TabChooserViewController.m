//
//  TabChooserViewController.m
//  tabulatabs-ios
//
//  Created by Max Winde on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabChooserViewController.h"
#import "TabulatabsBrowserWindow.h"
#import "TabulatabsBrowserTab.h"
#import "BrowserViewController.h"
#import "TabChooserCell.h"
#import "Helpers.h"

@implementation TabChooserViewController

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
        self.searchResults = [self.browser allTabs];
    } else {
        self.searchResults = [self.browser tabsContainingString:searchString];
    }
    
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"updatedTabList" object:nil];

    self.title = self.browser.label;
    UITableView *tableView = self.tableView;
    
    tableView.rowHeight = 72;
    
    [browser.windows enumerateObjectsUsingBlock:^(TabulatabsBrowserWindow *window, NSUInteger idx, BOOL *stop) {
        [window.tabs enumerateObjectsUsingBlock:^(TabulatabsBrowserTab *tab, NSUInteger idx, BOOL *stop) {
            if (tab.favIconUrl) {
                [[TabulatabsApp sharedImagePool] fetchImageToPool:[NSURLRequest requestWithURL:tab.favIconUrl] imageLoadedBlock:^(UIImage *image) {
                    tab.favIconImage = image;
                    [tableView reloadData];
                }];
            }

            if (tab.pageThumbnailUrl) {
                [[TabulatabsApp sharedImagePool] fetchImageToPool:[NSURLRequest requestWithURL:tab.pageThumbnailUrl] imageLoadedBlock:^(UIImage *imageData) {
                    tab.pageThumbnail = scaleImageToMinSize(imageData, CGSizeMake(256.0, 144.0));
                    [tableView reloadData];
                }];
            }
        }];
    }];
        
/*    CGRect scrollRect = tableView.bounds;
    scrollRect.origin.x = 0;
    scrollRect.origin.y = self.tabSearchBar.bounds.size.height;
    [tableView scrollRectToVisible:scrollRect animated:NO];*/
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.searchResults count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *tabs = [self.searchResults objectAtIndex:section];
    
    return [tabs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TabCell";
    
    TabChooserCell *cell = (TabChooserCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TabChooserCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    NSArray *tabs = [self.searchResults objectAtIndex:indexPath.section];
    TabulatabsBrowserTab *tab = [tabs objectAtIndex:indexPath.row];
    
    [cell setTitle:tab.pageTitle withSiteName:tab.siteTitle withShortDomainName:tab.shortDomain];
    [cell setFavIcon:tab.favIconImage];
    [cell setPageThumbnail:tab.pageThumbnail];
    
    cell.browserTab = tab;
    
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
    TabulatabsBrowserWindow *window = [self.browser.windows objectAtIndex:indexPath.section];
    TabulatabsBrowserTab *tab = [window.tabs objectAtIndex:indexPath.row];
    
    BrowserViewController *browserView = [[BrowserViewController alloc] initWithNibName:@"BrowserViewController" bundle:nil];
    browserView.browserTab = tab;
    
    [self.navigationController pushViewController:browserView animated:YES]; 
}

#pragma mark SearchBarDelegate

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
    searchBar.text = @"";
    [self performSearchFor:@""];
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
        [self.tableView.visibleCells enumerateObjectsUsingBlock:^(TabChooserCell *cell, NSUInteger idx, BOOL *stop) {
            [cell setActionViewVisibile:NO animated:YES];
        }];
    }
}

@end
