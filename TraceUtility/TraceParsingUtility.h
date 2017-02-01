//
//  TraceParsingUtility.h
//  TraceUtility
//

#import <Foundation/Foundation.h>


@class XRTrace;

@interface TraceParsingUtility : NSObject
+ (void)initializePlugins;
+ (NSArray <NSString *> *)traceFilePathsInDirectoryPath:(NSString *)directoryPath;
+ (NSArray <XRTrace *> *)tracesInDirectoryPath:(NSString *)directoryPath;
+ (XRTrace *)traceFromPath:(NSString *)traceFilePath;
+ (void)forEachTraceFileInDirectoryPath:(NSString *)directoryPath
                                perform:(void(^)(NSString *traceFileNameWithoutExtension, XRTrace *trace))action;
+ (void)saveData:(NSString *)data toCsv:(NSString *)csvFilePath;
@end
