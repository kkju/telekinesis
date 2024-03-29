#import "QSKeyCodeTranslator.h"

Ascii2KeyCodeTable keytable;
@implementation QSKeyCodeTranslator
+(void) initialize{
    [self InitAscii2KeyCodeTable];
}

+(OSStatus)InitAscii2KeyCodeTable{
    unsigned char *theCurrentKCHR, *ithKeyTable;
    short count, i, j, resID;
    Handle theKCHRRsrc;
    ResType rType;
    /* set up our table to all minus ones */
    for (i=0;i<256; i++) keytable.transtable[i] = -1;
    /* find the current kchr resource ID */
    keytable.kchrID = (short) GetScriptVariable(smCurrentScript,
                                                smScriptKeys);
    /* get the current KCHR resource */
    theKCHRRsrc = GetResource('KCHR', keytable.kchrID);
    if (theKCHRRsrc == NULL) return resNotFound;
    GetResInfo(theKCHRRsrc,&resID,&rType,keytable.KCHRname);
    /* dereference the resource */
    theCurrentKCHR = (unsigned char *) (*theKCHRRsrc);
    /* get the count from the resource */
    count = * (short *) (theCurrentKCHR + kTableCountOffset);
    /* build inverse table by merging all key tables */
    for (i=0; i<count; i++) {
        ithKeyTable = theCurrentKCHR + kFirstTableOffset + (i * kTableSize);
        for (j=0; j<kTableSize; j++) {
            if ( keytable.transtable[ ithKeyTable[j] ] == -1)
                keytable.transtable[ ithKeyTable[j] ] = j;
        }
    }
    /* all done */
    return noErr;
}

+(short)keyCodeForCharacter:(NSString *)character{
	char ascii=*[character UTF8String];	
	return [self AsciiToKeyCode:ascii];
}

+(short)AsciiToKeyCode:(short)asciiCode{
	if (asciiCode >= 0 && asciiCode <= 255) return
        keytable.transtable[asciiCode];
    else return -1;
}

@end


