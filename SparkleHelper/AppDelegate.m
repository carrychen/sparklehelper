//
//  AppDelegate.m
//  SparkleHelper
//
//  Created by dev on 11/22/15.
//  Copyright (c) 2015 deksmatrix. All rights reserved.
//

#import "AppDelegate.h"
#define MA_Title @"MA_Title"
#define MA_link @"MA_link"
#define MA_desc @"MA_desc"
#define MA_itemtitle @"MA_itemtitle"
#define MA_notelink @"MA_notelink"
#define MA_pubdate @"MA_pubdate"
#define MA_itemurl @"MA_itemurl"
#define MA_lang @"MA_lang"
#define MA_version @"MA_version"
#define MA_sourceAppPath @"MA_sourceAppPath"
#define MA_destPath @"MA_destPath"

@interface AppDelegate ()

@property (retain) IBOutlet NSWindow *window;

@property (retain) IBOutlet NSTextField *title;

@property (retain) IBOutlet NSTextField *link;
@property (retain) IBOutlet NSTextField *desc;

@property (assign) IBOutlet NSTextField *itemTitle;
@property (assign) IBOutlet NSTextField *noteLink;
@property (assign) IBOutlet NSTextField *pubDate;
@property (assign) IBOutlet NSTextField *itemUrl;
@property (assign) IBOutlet NSTextField *version;
@property (assign) IBOutlet NSTextField *sourceAppPath;
@property (assign) IBOutlet NSTextField *destPath;
@property (assign) IBOutlet NSTextField *lang;
@property (assign) IBOutlet NSProgressIndicator *indicator;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self loadFromPref];
    [_indicator setHidden:YES];
}

-(NSString*)getPref:(NSString*)key
{
   if(key==nil) return @"";
    NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];

    NSString* ret = [defaults objectForKey:key];
    if(ret==nil) ret = @"";
    return ret;
}
-(void)setPref:(NSString*)key value:(NSString*)val
{
    if(key==nil||val==nil) return;
     NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
    [defaults setObject:val forKey:key];
}
-(void)loadFromPref
{
    _title.stringValue = [self getPref:MA_Title];
    _link.stringValue = [self getPref:MA_link];
    _desc.stringValue = [self getPref:MA_desc];
    _itemTitle.stringValue = [self getPref:MA_itemtitle];
    _noteLink.stringValue = [self getPref:MA_notelink];
    _pubDate.stringValue = [self getPref:MA_pubdate];
    _itemUrl.stringValue = [self getPref:MA_itemurl];
    _version.stringValue = [self getPref:MA_version];
    _sourceAppPath.stringValue = [self getPref:MA_sourceAppPath];
    _destPath.stringValue = [self getPref:MA_destPath];
    _lang.stringValue = [self getPref:MA_lang];
    
    NSString* src = _sourceAppPath.stringValue;
    if(src&&src.length>0)
    {
        NSString* version = [self getVersiontFromAppBundle:src];
        if(version&&version.length>0)
        {
            _version.stringValue = version;
            _itemTitle.stringValue=[NSString stringWithFormat:@"Version %@",version];

        }
    }
    
   }

-(void)storeToPref
{
    [self setPref:MA_Title value:_title.stringValue];
    [self setPref:MA_link value:_link.stringValue];
    [self setPref:MA_desc value:_desc.stringValue];
    [self setPref:MA_itemtitle value:_itemTitle.stringValue];
    [self setPref:MA_notelink value:_noteLink.stringValue];
    [self setPref:MA_pubdate value:_pubDate.stringValue];
    [self setPref:MA_itemurl value:_itemUrl.stringValue];
    [self setPref:MA_lang value:_lang.stringValue];
    [self setPref:MA_version value:_version.stringValue];
    [self setPref:MA_sourceAppPath value:_sourceAppPath.stringValue];
    [self setPref:MA_destPath value:_destPath.stringValue];
}


- (IBAction)onSelectSrcPath:(id)sender {
    NSOpenPanel * p = [NSOpenPanel openPanel];
    [p setCanChooseDirectories:YES];
    [p setCanChooseFiles:YES];
    if([p runModal]==NSFileHandlingPanelOKButton)
    {
        NSString* path = p.filename;
        _sourceAppPath.stringValue = path;
    
        
        _version.stringValue = [self getVersiontFromAppBundle:path];
        
        _itemTitle.stringValue=[NSString stringWithFormat:@"Version %@",_version.stringValue];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [self storeToPref];
}
- (IBAction)onSelectDestPath:(id)sender {
    
    NSOpenPanel * p = [NSOpenPanel openPanel];
    [p setCanChooseDirectories:YES];
    [p setCanChooseFiles:NO];
    if([p runModal]==NSFileHandlingPanelOKButton)
    {
        NSString* path = p.filename;
        _destPath.stringValue = path;
    }
    
}

-(BOOL)zipApp:(NSString*)srcPath destPath:(NSString*)destPath zipFileName:(NSString*)name srcName:(NSString*)srcName
{
    /*NSTask *unzip = [[NSTask alloc] init];
    [unzip setLaunchPath:@"/usr/bin/zip"];
    [unzip setArguments:[NSArray arrayWithObjects:@"-r",
                         destFile, srcPath, nil]];
    
    NSPipe *aPipe = [[NSPipe alloc] init];
    [unzip setStandardOutput:aPipe];
    
    [unzip launch];
    [unzip waitUntilExit];*/

    //copy 到目的路径
    NSString* cmdCopy = [NSString stringWithFormat:@"cp -rf %@ %@",srcPath,destPath];
    system(cmdCopy.UTF8String);
    
    //压缩
    NSString * cmdZip = [NSString stringWithFormat:@"cd %@ && /usr/bin/zip -r %@/%@ %@",destPath, destPath,name, srcName];
    system(cmdZip.UTF8String);

    if([srcPath containsString:destPath]==NO)
    {
        
        //删除源文件
        NSString * cmdDeleteSource = [NSString stringWithFormat:@"cd %@ && rm -rf %@",destPath,name];
        system(cmdDeleteSource.UTF8String);
    }
    
    
    return YES;
}

-(NSString*) getVersiontFromAppBundle:(NSString*)path
{
    NSString *plistPath = [NSString stringWithFormat:@"%@/Contents/Info.plist",path];
    NSDictionary* info = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    if(info)
    {
        NSString* version = [info objectForKey:@"CFBundleVersion"];
        if(version==nil) version = @"";
        return version;
    }
    return nil;
    
}

-(NSString*)sigApp:(NSString*)destDir zipAppName:(NSString*)zipAppName pubKeyPath:(NSString*)pubKeyPath
{
    NSString* sigCmd = [NSString stringWithFormat:@"cd %@ && ./sign_update.sh %@ %@ > dig",destDir,zipAppName,pubKeyPath];
    int ret = system(sigCmd.UTF8String);
    if(ret==0)
    {
        NSString *digPath = [NSString stringWithFormat:@"%@/dig",destDir];
        NSString* content = [NSString stringWithContentsOfFile:digPath];
        if(content==nil) content = @"";
        
        NSString *rmDigCmd = [NSString stringWithFormat:@"rm -rf %@",digPath];
        system(rmDigCmd.UTF8String);
        return content;
    }
    else return @"";
}
-(int)getFileSize:(NSString*)path
{
    FILE* f = fopen(path.UTF8String,"r");
    if(f==0) return 0;
    fseek(f, 0,SEEK_END);
    int l = ftell(f);
    fclose(f);
    return l;
}
- (IBAction)onGen:(id)sender {
    
    [_indicator setHidden:NO];
    [_indicator startAnimation:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSString* src = _sourceAppPath.stringValue;
        NSString* dest = _destPath.stringValue;
        
        NSString *fileName = [src lastPathComponent];
        
        NSArray* com = [[src lastPathComponent] componentsSeparatedByString:@"."];
        NSString* title = com[0];
        
        NSString* destFileName = [NSString stringWithFormat:@"%@.zip",title ];
        NSString* fullDestFilePath = [NSString stringWithFormat:@"%@/%@",dest,destFileName];
       // [self zipApp:src destPath:dest zipFileName:destFileName srcName:fileName];
        NSString* sig = [self sigApp:dest zipAppName:destFileName pubKeyPath:@"dsa_priv.pem"];
        int fileSize = [self getFileSize:fullDestFilePath];
        
        NSString *appcastTmplPath = [NSString stringWithFormat:@"%@/appcast.xml",[[NSBundle mainBundle] resourcePath]];
        NSString* temp = [NSString stringWithContentsOfFile:appcastTmplPath];
        NSString  *appcast = [NSString  stringWithFormat:temp,
                              _title.stringValue,
                              _link.stringValue,
                              _desc.stringValue,
                              _lang.stringValue,
                              _itemTitle.stringValue,
                              _noteLink.stringValue,
                              _pubDate.stringValue,
                              _itemUrl.stringValue,
                              _version.stringValue,
                              [NSString stringWithFormat:@"%d",fileSize],
                              sig
                              ];
        
        NSString*  appcastFile = [NSString stringWithFormat:@"%@/appcast.xml",dest];
        
        [appcast writeToFile:appcastFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [_indicator stopAnimation:self];
            [_indicator setHidden:YES];
            
            NSAlert* alert = [NSAlert alertWithMessageText:@"OK" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Gen OK!"];
            [alert runModal];
        });
    });
    
    
}


@end
