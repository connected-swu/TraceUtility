//
//  NSString+TUFilePathing.h
//  TraceUtility
//

#import <Foundation/Foundation.h>


@class XRInstrument;
@class XRRun;
@interface NSString (TUFilePathing)
- (NSString *)tu_slash:(NSString *)prefix
                 title:(NSString *)title
                   uid:(NSString *)uid
                   ext:(NSString *)extension;
+ (NSString *)tu_uidFor:(XRInstrument *)instrument
                    run:(XRRun *)run;
@end
