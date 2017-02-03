//
//  TuFpsData.m
//  TraceUtility
//

#import "TuFpsData.h"

@interface TuFpsData()
@property (nonatomic, strong, readwrite) NSNumber *timeStamp;
@property (nonatomic, strong, readwrite) NSNumber *frames;
@end

@implementation TuFpsData

- (instancetype)initWithTimeStamp:(NSNumber *)timeStamp
                           frames:(NSNumber *)frames {
    self = [super init];
    if (self) {
        _timeStamp = timeStamp;
        _frames = frames;
    }
    return self;
}

+ (instancetype)withTimeStamp:(NSNumber *)timeStamp
                       frames:(NSNumber *)frames {
    if (!frames) {
        return nil;
    }
    return [[TuFpsData alloc] initWithTimeStamp:timeStamp
                                         frames:frames];
}

@end
