//
//  OwlHistogramView.h
//
//  Created by Pawel Maczewski on 27/11/11.
//  Copyright (c) 2011 OwlCoding.com. License is granted to use/change but with future distribution with at least this free license.
//

#import <UIKit/UIKit.h>

/* 
 To use this view in your controller do the following:
 
 OwlHistogramView *hist = [[OwlHistogramView alloc] initWithFrame:frame];
 hist.dataSource = self;
 [hist reloadData];
 
 the method you must provide in your dataSource is
 - (NSArray *)histogramValues:(OwlHistogramView *)histogram;
 that should return an array of NSNumbers made from floats (so they can be sorted like floats)
*/

@class OwlHistogramView;

@protocol OwlHistogramDataSource <NSObject>
@required
// Returns the values to be presented on the histogram
- (NSArray *)histogramValues:(OwlHistogramView *)histogram;

@optional
// Returns the minimum value that should be presented on the histogram
- (CGFloat)histogramMinimumPresentedValue:(OwlHistogramView *)histogram;

// Returns the maximum value that should be presented on the histogram
- (CGFloat)histogramMaximumPresentedValue:(OwlHistogramView *)histogram;

// Returns the range top value for the bottom value of the range. Eg. for 10 it returns 20, it means 
// that the range would be 10-20
- (CGFloat)histogram:(OwlHistogramView *)histogram topValueOfTheRangeForBottomValue:(CGFloat) bottomValue;

@end

@interface OwlHistogramView : UIView
{
    NSMutableArray *valuesSorted;
    NSMutableArray *histogram_x;
    NSMutableArray *histogram_y;
    int max_hist_value;
}
@property (weak) id<OwlHistogramDataSource> dataSource;

- (void)reloadData;
@end
