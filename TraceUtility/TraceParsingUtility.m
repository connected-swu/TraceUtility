//
//  TraceParsingUtility.m
//  TraceUtility
//

#import "TraceParsingUtility.h"
#import "PluginHeaders.h"
#import "XRTrace+TUPrivate.h"
#import "NSArray+TUFunctional.h"


@implementation TraceParsingUtility

+ (void)initializePlugins {
    DVTInitializeSharedFrameworks();
    [DVTDeveloperPaths initializeApplicationDirectoryName:@"Instruments"];
    [XRInternalizedSettingsStore configureWithAdditionalURLs:nil];
    PFTLoadPlugins();
}

+ (NSArray <XRTrace *> *)tracesInDirectoryPath:(NSString *)directoryPath {
    return [[self traceFilePathsInDirectoryPath:directoryPath] tu_map:^id(NSString *filePath) {
        return [self traceFromPath:filePath];
    }];
}

+ (NSArray <NSString *> *)traceFilePathsInDirectoryPath:(NSString *)directoryPath {
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath
                                                                         error:&error];
    return [[files tu_filter:^BOOL(NSString *fileName) {
        return [[[fileName pathExtension] lowercaseString] isEqualToString:@"trace"];
    }] tu_map:^id(NSString *fileName) {
        return [directoryPath stringByAppendingPathComponent:fileName];
    }];
}

+ (XRTrace *)traceFromPath:(NSString *)traceFilePath {
    XRTrace *trace = [[XRTrace alloc] initForCommandLine:NO];
    NSError *error;
    [trace loadDocument:[NSURL fileURLWithPath:traceFilePath] error:&error];
    [trace awakeFromTemplate];
    return trace;
}

+ (void)forEachTraceFileInDirectoryPath:(NSString *)directoryPath
                                perform:(void(^)(NSString *traceFileNameWithoutExtension, XRTrace *trace))action {
    [[self traceFilePathsInDirectoryPath:directoryPath] enumerateObjectsUsingBlock:^(NSString * _Nonnull filePath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
        XRTrace *trace = [self traceFromPath:filePath];
        action(fileName, trace);
    }];
}

+ (void)saveData:(NSString *)data toCsv:(NSString *)csvFilePath {
    NSError *error;
    [data writeToFile:csvFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

@end
