//
//  XRTrace+TUDataExporting.h
//  TraceUtility
//

#import "XRTrace+TUPrivate.h"


typedef NS_ENUM(NSInteger, TuFpsDataOption) {
    TuFpsDataOptionDefault,
    TuFpsDataOptionTreat0as60,
    TuFpsDataOptionIgnore0s
};

@interface XRTrace (TUDataExporting)
- (void)tu_exportActivityInstrumentCpuUsageDataForProcess:(NSString *)processName
                                            withDirectory:(NSString *)directory
                                                   prefix:(NSString *)prefix;
- (void)tu_exportCoreAnimationInstrumentFpsDataWithDirectory:(NSString *)directory
                                                      prefix:(NSString *)prefix
                                                      option:(TuFpsDataOption)option;
@end
