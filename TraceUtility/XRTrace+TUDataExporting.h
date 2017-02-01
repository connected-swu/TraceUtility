//
//  XRTrace+TUDataExporting.h
//  TraceUtility
//

#import "XRTrace+TUPrivate.h"


@interface XRTrace (TUDataExporting)
- (void)tu_exportActivityInstrumentCpuUsageDataWithDirectory:(NSString *)directory
                                                      prefix:(NSString *)prefix;
- (void)tu_exportCoreAnimationInstrumentFpsDataWithDirectory:(NSString *)directory
                                                      prefix:(NSString *)prefix;
@end
