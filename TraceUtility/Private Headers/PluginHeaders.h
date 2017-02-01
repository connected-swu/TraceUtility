//
//  PluginHeaders.h
//  TraceUtility
//

#import <Foundation/Foundation.h>


#ifdef __cplusplus
extern "C" {
#endif
    NSString *PFTDeveloperDirectory(void);
    void DVTInitializeSharedFrameworks(void);
    BOOL PFTLoadPlugins(void);
#ifdef __cplusplus
}
#endif


@interface DVTDeveloperPaths : NSObject
+ (NSString *)applicationDirectoryName;
+ (void)initializeApplicationDirectoryName:(NSString *)name;
@end


@interface XRInternalizedSettingsStore : NSObject
+ (NSDictionary *)internalizedSettings;
+ (void)configureWithAdditionalURLs:(NSArray *)urls;
@end
