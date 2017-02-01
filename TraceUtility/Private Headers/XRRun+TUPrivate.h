//
//  XRRun+TUPrivate.h
//  TraceUtility
//

#import <Foundation/Foundation.h>
#import "XRDevice+TUPrivate.h"


@interface XRRun : NSObject
- (XRDevice *)device;
- (NSInteger)runNumber;
- (NSString *)displayName;
- (NSTimeInterval)startTime;
- (NSTimeInterval)endTime;
@end
