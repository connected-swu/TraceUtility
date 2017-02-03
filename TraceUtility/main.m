//
//  main.m
//  TraceUtility
//

#import "TraceParsingUtility.h"
#import "XRTrace+TUDataExporting.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [TraceParsingUtility initializePlugins];
        NSString *traceDirectory = @"/Users/damianmccabe/Desktop/TraceParsingTest/";
        NSString *outputDirectory = traceDirectory;
        
        [TraceParsingUtility forEachTraceFileInDirectoryPath:traceDirectory
                                                     perform:
         ^(NSString *traceFileNameWithoutExtension, XRTrace *trace) {
             [trace tu_exportActivityInstrumentCpuUsageDataForProcess:@"GreenwichNative"
                                                        withDirectory:outputDirectory
                                                               prefix:traceFileNameWithoutExtension];
             [trace tu_exportCoreAnimationInstrumentFpsDataWithDirectory:outputDirectory
                                                                  prefix:traceFileNameWithoutExtension
                                                                  option:TuFpsDataOptionDefault];
             [trace close];
         }];
    }
    return 0;
}
