//
//  ViewController.m
//  vodiEx
//
//  Created by Son Dang on 10/27/17.
//  Copyright © 2017 Son Dang. All rights reserved.
//

#define KEY 1
#define EN 2
#define VN 3
#define ES 4
#define PT 5
#define IN 6
#define MS 7
#define HI 8
#define ZH 9

#define localizeFileCount 8
#define contentKey @"contentKey"
#define contentString @"contentString"

#define rootPath @"/Users/sondang/My Projects/vodiEx/language/"
#define version @"1.0"

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableDictionary *inputLanguage;
@property (nonatomic, strong) NSMutableDictionary *inputLocalize;
@property (nonatomic, weak) IBOutlet NSTextField *textfield;
@property (nonatomic, weak) IBOutlet NSButton *button;
@property (nonatomic, weak) IBOutlet NSTextField *label;
@property (nonatomic, weak) IBOutlet NSPopUpButton *popupButton;
@property (nonatomic, copy) NSString *inputVersion;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputLanguage = [NSMutableDictionary new];
    self.inputLocalize = [NSMutableDictionary new];
    [self setupPopupButton];
    [self.label setStringValue:@"Stay"];
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)mergeFiles {
    //3 for
    for (NSInteger index = 2; index <= localizeFileCount+1; index++) {
        [self mergeFileWithType:index];
        [self writeLocalize:index];
    }
}

- (void)mergeFileWithType:(NSInteger)type {
    NSMutableArray *listLocalize = self.inputLocalize[@(type)];
    NSMutableArray *listLanguage = self.inputLanguage[@(type)];
    
    NSMutableArray *newContents = [NSMutableArray new];
    
    for (NSDictionary *dict in listLanguage) {
        BOOL shouldAddNewKey = YES;
        for (NSInteger i = 0; i < listLocalize.count; i++) {
            NSString *fContent = listLocalize[i];
            // merge key
            if ([fContent containsString:[self keyLanguageOfDictionary:dict]]) {
                shouldAddNewKey = NO;
                listLocalize[i] = [self printContentDictionary:dict];
                break;
            }
        }
        
        if (shouldAddNewKey) {
            [newContents addObject:[self printContentDictionary:dict]];
        }
    }
    if (newContents.count) {
        [listLocalize addObjectsFromArray:newContents];
    }
}

- (NSString *)localizeFileNamePath:(NSInteger)type {
    NSString *localizable = @"%@.lproj/Localizable.strings";
    return [NSString stringWithFormat:localizable, [self localizeName:type]];
}

- (NSString *)localizeName:(NSInteger)type {
    switch (type) {
        case EN:
            return @"en";
            break;
        case VN:
            return @"vi";
            break;
        case ES:
            return @"es";
            break;
        case PT:
            return @"pt-PT";
            break;
        case IN:
            return @"id";
            break;
        case MS:
            return @"ms";
            break;
        case HI:
            return @"hi";
            break;
        case ZH:
            return @"zh-Hans";
            break;
        default:
            break;
    }
    return @"";
}

- (void)parseRow:(NSString *)rowCode {
    NSArray* columns = [rowCode componentsSeparatedByString:@","];
    for (NSInteger index = 0; index < columns.count; index++) {
        [self addToLanguage:index fullCodeRay:columns];
    }
    
    NSLog(@"ok");
}

- (void)addToLanguage:(NSInteger)language fullCodeRay:(nonnull NSArray *)fullContent {
    NSString *key = fullContent[KEY];
    NSString *content = fullContent[language];
    [self addToLanguage:language key:key content:content extendContent:fullContent[EN]];
}

- (void)addToLanguage:(NSInteger)language key:(nonnull NSString *)key content:(NSString *)content extendContent:(nonnull NSString *)exContent {
    if (language == 0 || language == 1)
        return;
    
    NSMutableArray *listContent = self.inputLanguage[@(language)];
    if (!listContent) {
        listContent = [NSMutableArray new];
        [self.inputLanguage setObject:listContent forKey:@(language)];
    }
    
    NSString *finalContent = exContent;
    if (content.length) {
        finalContent = content;
    }
    [listContent addObject:[self createContentDictionary:key content:finalContent]];
}

- (NSString *)outputContentFromKey:(NSString *)key andString:(NSString *)string {
    return [NSString stringWithFormat:@"%@ = %@;", key, string];
}

- (NSDictionary *)createContentDictionary:(nonnull NSString *)key content:(nonnull NSString *)content {
    return @{contentKey:key, contentString:content};
}

- (NSString *)keyLanguageOfDictionary:(NSDictionary *)dictionary {
    return dictionary[contentKey];
}

- (NSString *)contentLanguageOfDictionary:(NSDictionary *)dictionary {
    return dictionary[contentString];
}

- (NSString *)printContentDictionary:(NSDictionary *)dictionary {
    return [NSString stringWithFormat:@"\"%@\" = \"%@\";", dictionary[contentKey], dictionary[contentString]];
}

- (IBAction)handleProcess:(id)sender {
    [self.label setStringValue:@"Waiting.."];
    self.inputVersion = self.popupButton.selectedItem.title;
    if (!self.inputVersion.length) {
        [self.label setStringValue:@"Fail, select your version"];
        return;
    }
    [self readCSVFile];
    [self readLanguageFile];
    [self mergeFiles];
    [self.label setStringValue:@"Done"];
}

#pragma mark - path support

- (NSString *)rootPathVersion:(NSString *)versionId {
    if (versionId.length) {
        return [NSString stringWithFormat:@"%@%@/", rootPath, versionId];
    }
    
    return rootPath;
}

- (NSString *)csvFilePath {
    return [NSString stringWithFormat:@"%@%@", [self rootPathVersion:self.inputVersion], @"demo.csv"];
}

- (NSString *)localizePath {
    return [NSString stringWithFormat:@"%@%@", [self rootPathVersion:self.inputVersion], @"Languages/"];
}

- (NSString *)outputPath {
    return [self rootPathVersion:self.inputVersion];
}

#pragma mark - read function

- (void)readCSVFile {
    NSString *fileString = [NSString stringWithContentsOfFile:[self csvFilePath] encoding:NSUTF8StringEncoding error:nil];
    NSArray* rows = [fileString componentsSeparatedByString:@"\n"];
    for (int i = 1; i < rows.count-1; i++){
        NSString* row = [rows objectAtIndex:i];
        [self parseRow:row];
    }
}

- (void)readLanguageFile {
    for (NSInteger index = 2; index <= localizeFileCount+1; index++) {
        [self readLanguageFileWithType:index];
    }
}

- (void)readLanguageFileWithType:(NSInteger)type {
    NSString *path = [NSString stringWithFormat:@"%@%@", [self localizePath], [self localizeFileNamePath:type]];
    NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *rows = [NSMutableArray arrayWithArray:[fileString componentsSeparatedByString:@"\n"]];
    [self correctReadContent:rows];
    [self.inputLocalize setObject:rows forKey:@(type)];
}

- (void)correctReadContent:(NSMutableArray *)contents {
    NSMutableArray *removed = [NSMutableArray new];
    
    for (NSInteger index = 0; index < contents.count; index++) {
        NSString *string = contents[index];
        if (!string.length) {
            [removed addObject:string];
        }
        if ([string containsString:@"%s"]) {
            contents[index] = [string stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
        }
        if ([string containsString:@"%S"]) {
            contents[index] = [string stringByReplacingOccurrencesOfString:@"%S" withString:@"%@"];
        }
    }
    
    [contents removeObjectsInArray:removed];
}

#pragma mark - write functions

- (void)writeLocalize:(NSInteger)type {
    NSMutableArray *listLocalize = self.inputLocalize[@(type)];
    NSString *printContent = @"";
    for (NSInteger index = 0; index < listLocalize.count; index++) {
        printContent = [[printContent stringByAppendingString:listLocalize[index]] stringByAppendingString:@"\n"];
    }
    [self writeString:printContent toPath:[NSString stringWithFormat:@"%@%@.strings",[self outputPath], [self localizeName:type]]];
}

- (void)writeString:(NSString *)content toPath:(NSString *)path {
    [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - UI function 

- (void)setupPopupButton {
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:NULL];
    for (NSString *folderTitle in dirs) {
        [self.popupButton addItemWithTitle:folderTitle];
    }
}

@end
