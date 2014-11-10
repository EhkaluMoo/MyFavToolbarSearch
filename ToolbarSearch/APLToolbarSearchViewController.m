

#import "APLToolbarSearchViewController.h"
#import "APLRecentSearchesController.h"

@interface APLToolbarSearchViewController ()

@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UILabel *progressLabel;

@property (nonatomic) APLRecentSearchesController *recentSearchesController;
@property (nonatomic) UIPopoverController *recentSearchesPopoverController;

@end


#pragma mark -

@implementation APLToolbarSearchViewController


#pragma mark - RecentSearchesDelegate

- (void)recentSearchesController:(APLRecentSearchesController *)controller didSelectString:(NSString *)searchString {
    
    // The user selected a row in the recent searches list (UITableView).
    // Set the text in the search bar to the search string, and conduct the search.
    self.searchBar.text = searchString;
    [self finishSearchWithString:searchString];
}


#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    
    // Create the popover if it is not already open.
    if (self.recentSearchesPopoverController == nil) {

        // Use the storyboard to instantiate a navigation controller that contains a recent searches controller.
        UINavigationController *navigationController = [[self storyboard] instantiateViewControllerWithIdentifier:@"PopoverNavigationController"];

        self.recentSearchesController = (APLRecentSearchesController *)[navigationController topViewController];
        self.recentSearchesController.delegate = self;
        
        // Create the popover controller to contain the navigation controller.
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        popover.delegate = self;
        
        // Ensure the popover is not dismissed if the user taps in the search bar by adding
        // the search bar to the popover's list of pass-through views.
        popover.passthroughViews = @[self.searchBar];
        
        self.recentSearchesPopoverController = popover;
    }
    
    // Display the popover.
    [self.recentSearchesPopoverController presentPopoverFromRect:[self.searchBar bounds] inView:self.searchBar permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    
    // If the user finishes editing text in the search bar by, for example: tapping away
    // rather than selecting from the recents list, then just dismiss the popover,
    // but only if its confirm UIActionSheet is not open (UIActionSheets can take away
    // first responder from the search bar when first opened).
    //
    if (self.recentSearchesPopoverController != nil) {
        
        if (self.recentSearchesController.confirmSheet == nil) {
            [self.recentSearchesPopoverController dismissPopoverAnimated:YES];
            self.recentSearchesPopoverController = nil;
        }
    }    
    [aSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // When the search string changes, filter the recents list accordingly.
    [self.recentSearchesController filterResultsUsingString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    
    // When the search button is tapped, add the search term to recents and conduct the search.
    NSString *searchString = [self.searchBar text];
    [self.recentSearchesController addToRecentSearches:searchString];
    [self finishSearchWithString:searchString];
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    // Remove focus from the search bar without committing the search.
    self.progressLabel.text = NSLocalizedString(@"Canceled a search.", @"canceled search string for the progress label");
    self.recentSearchesPopoverController = nil;
    [self.searchBar resignFirstResponder];
}


#pragma mark - Finish the search

- (void)finishSearchWithString:(NSString *)searchString {
    
    // Conduct the search. In this case, simply report the search term used.
    [self.recentSearchesPopoverController dismissPopoverAnimated:YES];
    self.recentSearchesPopoverController = nil;
    NSString *formatString = NSLocalizedString(@"Performed a search using \"%@\".", @"format string for reporting search performed");
    self.progressLabel.text = [NSString stringWithFormat:formatString, searchString];
    [self.searchBar resignFirstResponder];
}

@end
