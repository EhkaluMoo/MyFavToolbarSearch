

#import "APLRecentSearchesController.h"

NSString *RecentSearchesKey = @"RecentSearchesKey";

@interface APLRecentSearchesController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *clearButtonItem;

@property (nonatomic) NSArray *recentSearches;
@property (nonatomic) NSArray *displayedRecentSearches;
@property (nonatomic, readwrite) UIActionSheet *confirmSheet;

@end

#pragma mark -

@implementation APLRecentSearchesController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // Set up the recent searches list, from user defaults or using an empty array.
    NSArray *recents = [[NSUserDefaults standardUserDefaults] objectForKey:RecentSearchesKey];
    if (recents) {
        self.recentSearches = recents;
        self.displayedRecentSearches = recents;
    }
    else {
        self.recentSearches = [NSArray array];
        self.displayedRecentSearches = [NSArray array];
    }

    // Disable the Clear button if there are no recents items.
    if ([self.recentSearches count] == 0) {
        self.clearButtonItem.enabled = NO;
    }    
}


- (void)viewWillAppear:(BOOL)animated {
 
    // Ensure the complete list of recents is shown on first display.
    [super viewWillAppear:animated];
    self.displayedRecentSearches = self.recentSearches;
}


#pragma mark - Managing the recents list

- (void)addToRecentSearches:(NSString *)searchString {
    
    // Filter out any strings that shouldn't be in the recents list.
    if ([searchString isEqualToString:@""]) {
        return;
    }
    
    // Create a mutable copy of recent searches and remove the search string if it's already there (it's added to the top of the list later).

    NSMutableArray *mutableRecents = [self.recentSearches mutableCopy];
    [mutableRecents removeObject:searchString];
    
    // Add the new string at the top of the list.
    [mutableRecents insertObject:searchString atIndex:0];
    
    // Update user defaults.
    [[NSUserDefaults standardUserDefaults] setObject:mutableRecents forKey:RecentSearchesKey];

    // Set self's recent searches to the new recents array, and reload the table view.
    self.recentSearches = mutableRecents;
    self.displayedRecentSearches = mutableRecents;
    [self.tableView reloadData];
    
    // Ensure the clear button is enabled.
    self.clearButtonItem.enabled = YES;
}


- (void)filterResultsUsingString:(NSString *)filterString {

    // If the search string is zero-length, then restore the recent searches, otherwise
    // create a predicate to filter the recent searches using the search string.
    //
    if ([filterString length] == 0) {
        self.displayedRecentSearches = self.recentSearches;
    }
    else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self BEGINSWITH[cd] %@", filterString];
        NSArray *filteredRecentSearches = [self.recentSearches filteredArrayUsingPredicate:filterPredicate];
        self.displayedRecentSearches = filteredRecentSearches;
    }

    [self.tableView reloadData];
}

- (IBAction)showClearRecentsAlert:(id)sender {
    
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"Cancel button title");
    NSString *clearAllRecentsButtonTitle = NSLocalizedString(@"Clear All Recents", @"Clear All Recents button title");
    
    // If the user taps the Clear Recents button, present an action sheet to confirm.
    self.confirmSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:clearAllRecentsButtonTitle otherButtonTitles:nil];
    [self.confirmSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        /*
         If the user chose to clear recents, remove the recents entry from user defaults, set the list to an empty array, and redisplay the table view.
         */
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:RecentSearchesKey];
        self.recentSearches = [NSArray array];
        self.displayedRecentSearches = [NSArray array];
        [self.tableView reloadData];
        self.clearButtonItem.enabled = NO;
    }
    self.confirmSheet = nil;
}


#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.displayedRecentSearches count];
}

// Display the strings in displayedRecentSearches.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [self.displayedRecentSearches objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Notify the delegate if a row is selected.
    [self.delegate recentSearchesController:self didSelectString:[self.displayedRecentSearches objectAtIndex:indexPath.row]];
}

@end

