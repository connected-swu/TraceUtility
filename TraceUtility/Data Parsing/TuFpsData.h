//
//  TuFpsData.h
//  TraceUtility
//

#import <Foundation/Foundation.h>


@interface TuFpsData : NSObject
@property (nonatomic, strong, readonly) NSNumber *timeStamp;
@property (nonatomic, strong, readonly) NSNumber *frames;
+ (instancetype)withTimeStamp:(NSNumber *)timeStamp
                       frames:(NSNumber *)frames;
@end
