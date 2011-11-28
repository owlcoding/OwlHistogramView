//
//  OwlHistogramView.m
//
//  Created by Pawel Maczewski on 27/11/11.
//  Copyright (c) 2011 OwlCoding.com. All rights reserved.
//

#import "OwlHistogramView.h"

@implementation OwlHistogramView

@synthesize dataSource = _dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        valuesSorted = nil;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (CGFloat) nextTopRangeForBottom:(CGFloat) bott max:(CGFloat) max andMin:(CGFloat) min {
    if ([self.dataSource respondsToSelector:@selector(histogram:topValueOfTheRangeForBottomValue:)]) {
        return [self.dataSource histogram:self topValueOfTheRangeForBottomValue:bott];
    } else {
        return bott + (max-min)/10;
    }
}

// reloads data and generates histogram from 
// data source
- (void)reloadData {
    valuesSorted = (NSMutableArray *)[[self.dataSource histogramValues:self] sortedArrayUsingComparator:(NSComparator)^(id i1, id i2) {
        return [i1 floatValue]>[i2 floatValue];
    }];
    NSLog(@"sorted: %@", valuesSorted);
    
    float min = [[valuesSorted objectAtIndex:0] floatValue];
    float max = [[valuesSorted objectAtIndex:[valuesSorted count]-1] floatValue];
    
    if ([self.dataSource respondsToSelector:@selector(histogramMinimumPresentedValue:)]) {
        min = [self.dataSource histogramMinimumPresentedValue:self];
    }
    if ([self.dataSource respondsToSelector:@selector(histogramMaximumPresentedValue:)]) {
        max = [self.dataSource histogramMaximumPresentedValue:self];
    }
    
    float bott = min;
    float top = min;
    histogram_x = [NSMutableArray arrayWithCapacity:0];
    histogram_y = [NSMutableArray arrayWithCapacity:0];
    
    int cnt_idx = 0;
    max_hist_value = 0;
    while (bott <= max) {
        top = [self nextTopRangeForBottom:bott max:max andMin:min];
        if (top > max) {
            break;
        }
        // do the counting
        int cnt = 0;
        while (cnt_idx < [valuesSorted count] && [[valuesSorted objectAtIndex:cnt_idx] floatValue] <= top) {
            cnt ++;
            cnt_idx ++;
        }
        if (cnt > max_hist_value) {
            max_hist_value = cnt;
        }
        [histogram_y addObject:[NSNumber numberWithInt:cnt]];
        [histogram_x addObject:[NSString stringWithFormat:@"%.1f-%.1f", bott, top]];
        bott = top;
    }
    NSLog(@"hist: %@ %@", histogram_x, histogram_y);
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef c = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(c, self.backgroundColor.CGColor);
	CGContextFillRect(c, rect);

    
    if (valuesSorted == nil) {
        return;
    }
    
    float h = rect.size.height;
    float w = rect.size.width;
    
    // scale of the histogram
    float one_point_scale = 1.0 * (h - 30.0 - 30.0) / max_hist_value;
    int number_of_bars = [histogram_x count];
    float bar_width = ((w - 30 - 30) - 5 * (number_of_bars - 1)) / number_of_bars ;
    
    // draw the damn bars
    for (int i = 0; i < number_of_bars; i++) {
        float bar_height = one_point_scale * [[histogram_y objectAtIndex:i] intValue];
        CGRect bar_rect = CGRectMake(30 + 5 * i + bar_width * i,
                                     (h-30)-bar_height,
                                     bar_width,
                                     bar_height);
        CGRect text_rect = CGRectMake(30+5 *i + bar_width * i,
                                      h-30,
                                      bar_width,
                                      30);
        CGContextAddRect(c, bar_rect);
        CGContextSetStrokeColorWithColor(c, [UIColor redColor].CGColor);
        CGContextSetFillColorWithColor(c, [UIColor grayColor].CGColor);
        CGContextStrokePath(c);
        CGContextFillPath(c);
        [[UIColor blueColor] set];
        [[NSString stringWithFormat:@"%@", [histogram_x objectAtIndex:i]] drawInRect:text_rect
                                         withFont:[UIFont systemFontOfSize:8.0]
                                    lineBreakMode:UILineBreakModeCharacterWrap
                                        alignment:UITextAlignmentCenter];
        NSLog(@"%@: %@", [histogram_x objectAtIndex:i], [histogram_y objectAtIndex:i]);
    }
}

@end
