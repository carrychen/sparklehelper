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

@property (retain) IBOutlet NSTextField *desc;

@property (assign) IBOutlet NSTextField *itemTitle;
@property (assign) IBOutlet NSTextField *version;
@property (assign) IBOutlet NSTextField *sourceAppPath;
@property (assign) IBOutlet NSTextField *destPath;
@property (assign) IBOutlet NSTextField *lang;
@property (assign) IBOutlet NSProgressIndicator *indicator;
@property (strong) NSDictionary* plistInfo;
@property (strong) NSString* pubDate;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    _pubDate = @"Wed, 09 Jan 2015 19:20:12 +0000";
    NSString* srcPath = [self getPref:MA_sourceAppPath];
    [self loadPlist:srcPath];
    
    [self loadFromPref];
    [_indicator setHidden:YES];
}
-(void)loadPlist:(NSString*)srcPath
{
    if(srcPath==nil) return;
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *plistPath = [NSString stringWithFormat:@"%@/Contents/Info.plist",srcPath];
    _plistInfo = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
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
    _desc.stringValue = [self getPref:MA_desc];
    _itemTitle.stringValue = [self getPref:MA_itemtitle];
     _version.stringValue = [self getPref:MA_version];
    _sourceAppPath.stringValue = [self getPref:MA_sourceAppPath];
    _destPath.stringValue = [self getPref:MA_destPath];
    _lang.stringValue = [self getPref:MA_lang];
    

    
    NSString* src = _sourceAppPath.stringValue;
    if(src&&src.length>0)
    {
        NSString* version = [self getVersion];
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
     [self setPref:MA_desc value:_desc.stringValue];
    [self setPref:MA_itemtitle value:_itemTitle.stringValue];
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
    
        [self loadPlist:path];
        _version.stringValue = [self getVersion];
        
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

-(NSString*) getVersion
{
    NSString* version = [_plistInfo objectForKey:@"CFBundleVersion"];
    if(version==nil) version = @"";
    return version;
}

 //http://127.0.0.1/appcast.xml
-(NSString*)getFeedUrl
{
    NSString* url = [_plistInfo objectForKey:@"SUFeedURL"];
    /*if(url==nil) return @"";
    NSArray* coms = [url componentsSeparatedByString:@"//"];
    if(coms.count<2) return @"";
    url = coms[1];
    coms = [url componentsSeparatedByString:@"/"];
    if(coms.count<1) return @"";
    url = coms[0];*/
    return url;
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
        
        NSString* version = [self getVersion];
        NSString* link = [self getFeedUrl];
        
        NSString* nodeLink = [NSString stringWithFormat:@"%@/%@.html", [link stringByDeletingLastPathComponent],version];
        NSString* itemUrl = [NSString stringWithFormat:@"%@/%@.zip", [link stringByDeletingLastPathComponent],title];

        //gen note
        NSString* localNotePath = [NSString stringWithFormat:@"%@/%@.html",dest,version];
        NSString* noteContent = [NSString stringWithFormat:@"<html><body>%@ Beta %@</body></html>",title,version];
        [noteContent writeToFile:localNotePath atomically:YES];
        
        NSString* temp = [NSString stringWithContentsOfFile:appcastTmplPath];
        NSString  *appcast = [NSString  stringWithFormat:temp,
                              _title.stringValue,
                              link,
                              _desc.stringValue,
                              _lang.stringValue,
                              _itemTitle.stringValue,
                              nodeLink,
                              _pubDate,
                              itemUrl,
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
