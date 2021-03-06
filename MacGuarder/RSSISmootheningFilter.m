
#import "RSSISmootheningFilter.h"

static NSUInteger const kDefaultNumberOfSamples = 3;

@interface RSSISmootheningFilter ()

@property (nonatomic, strong) NSMutableArray *samples;
@property (nonatomic, assign) NSInteger currentSampleIndex;

@end

@implementation RSSISmootheningFilter

+ (RSSISmootheningFilter *)sharedInstance
{
    static RSSISmootheningFilter *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RSSISmootheningFilter alloc] init];
        sharedInstance.numberOfSamples = kDefaultNumberOfSamples;
        sharedInstance.currentSampleIndex = 0;
    });
    return sharedInstance;
}

- (void)addSample:(NSInteger)value
{
    if (self.currentSampleIndex == 0) {
        self.samples = [NSMutableArray array];
    }
    
    if (self.currentSampleIndex > self.numberOfSamples-1) {
        [self.samples removeLastObject];
    } else {
        self.currentSampleIndex++;
    }
    
    [self.samples insertObject:[NSNumber numberWithInteger:value] atIndex:0];
}

- (void)reset
{
    self.currentSampleIndex = 0;
}

- (BOOL)isFilterFull
{
    return (self.currentSampleIndex == self.numberOfSamples);
}

- (NSInteger)getMedianValue
{
    NSInteger accumulator = 0;
    if (self.samples.count == 0) {
        return 127; // just like the behaviour of IOBluetoothDevice.rawRSSI
    }

    for (NSNumber *n in self.samples) {
        accumulator += [n integerValue];
    }
    return accumulator / (NSInteger)self.samples.count;
}

- (NSInteger)getMaximumVariation
{
    NSInteger min = [[self.samples firstObject] integerValue];
    NSInteger max = [[self.samples firstObject] integerValue];
    
    for (NSNumber *n in self.samples) {
        NSInteger nn = [n integerValue];
        if (nn > max) max = nn;
        if (nn < min) min = nn;
    }
    
    return max - min;
}

#pragma mark - setters

- (void)setNumberOfSamples:(NSInteger)numberOfSamples
{
    _numberOfSamples = numberOfSamples;
    self.currentSampleIndex = 0;
}

@end
