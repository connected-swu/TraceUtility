//
//  XRInstrument+TUPrivate.h
//  TraceUtility
//

#import <Foundation/Foundation.h>
#import "PFTInstrumentType+TUPrivate.h"


@interface XRInstrument : NSObject
- (PFTInstrumentType *)type;
- (NSArray *)allRuns;
@end
