//
//  NSString+TUFilePathing.m
//  TraceUtility
//

#import "NSString+TUFilePathing.h"
#import "XRInstrument+TUPrivate.h"
#import "XRRun+TUPrivate.h"


@implementation NSString (TUFilePathing)

- (NSString *)tu_slash:(NSString *)prefix
                 title:(NSString *)title
                   uid:(NSString *)uid
                   ext:(NSString *)extension {
    NSString *fullFileName = [NSString stringWithFormat:@"%@__%@__%@.%@",
                              prefix,
                              title,
                              uid,
                              extension];
    return [self stringByAppendingPathComponent:fullFileName];
}

+ (NSString *)tu_uidFor:(XRInstrument *)instrument
                    run:(XRRun *)run {
    return [[[NSString stringWithFormat:@"%@-%@", instrument.type.name, run.displayName] stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString];
}

@end
