

#import <UIKit/UIKit.h>

extern NSString *RecentSearchesKey;

@class APLRecentSearchesController;

@protocol RecentSearchesDelegate
// sent when the user selects a row in the recent searches list
- (void)recentSearchesController:(APLRecentSearchesController *)controller didSelectString:(NSString *)searchString;
@end

#pragma mark -

@interface APLRecentSearchesController : UITableViewController <UIActionSheetDelegate>

@property (nonatomic, weak) id <RecentSearchesDelegate> delegate;

@property (nonatomic, readonly) UIActionSheet *confirmSheet;

- (void)filterResultsUsingString:(NSString *)filterString;
- (void)addToRecentSearches:(NSString *)searchString;

@end
