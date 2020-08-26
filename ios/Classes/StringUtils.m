//
//  StringUtils.m
//
//  Created by wuye on 2020/8/4.
//

#import "StringUtils.h"

NSMutableData* hexString2Data(NSString *str) {

    str = [str lowercaseString];
    NSMutableData *data= [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i = 0;
    int length = (int) str.length;
    while (i < length-1) {
        char c = [str characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f')
            continue;
        byte_chars[0] = c;
        byte_chars[1] = [str characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

NSData* reverseData(NSData *data) {
    const char *bytes = [data bytes];
    int idx = [data length] - 1;
    char *reversedBytes = calloc(sizeof(char),[data length]);
    for (int i = 0; i < [data length]; i++) {
        reversedBytes[idx--] = bytes[i];
    }
    NSData *reversedData = [NSData dataWithBytes:reversedBytes length:[data length]];
    free(reversedBytes);
    return reversedData;
}