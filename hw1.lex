%{
    /* Declarations section */
    
    #include "string.h"
    void showToken(char *);
    void parseString(char*,int);
    void unknownToken();
    void handleUnclosedString();
    void handleNestedComment();
    void handleUndefinedU();
    void handleUnterminatedComment();
    void addToBuffer();
    void addSingleBuffer(char c);
    void handleU();
    void undefinedEscapeSequence();
    void endString();
    void startComment();
    void endComment();
    char buffer[1025];
    int buffer_pos=0;
    int lineCount=0;
%}
%option yylineno
%option noyywrap
digit ([0-9])
letter ([a-zA-Z])
alnum ([a-zA-Z0-9])
xdigit ({digit}|[A-Fa-f])
whitespace ([\t\n ])
printable ([\x20-\x7e\x9\xa\xd])
lineprintable ([\x20-\x7e\x9\xa\xd]{-}[\r\n])
stringprintable ([\x20-\x7e\x9\xa\xd]{-}[\\\"\r\n])
commentprintable ([\x20-\x7e\x9\xa\xd]{-}[\/\*\r\n])
%x STRING
%x MULTICOMMENT
%%
Int|UInt|Double|Float|Bool|String|Character showToken("TYPE");
var showToken("VAR");
let showToken("LET");
func showToken("FUNC");
import showToken("IMPORT");
nil showToken("NIL");
while showToken("WHILE");
if showToken("IF");
else showToken("ELSE");
return showToken("RETURN");
\; showToken("SC");
\, showToken("COMMA");
\( showToken("LPAREN");
\) showToken("RPAREN");
\{ showToken("LBRACE");
\} showToken("RBRACE");
\[ showToken("LBRACKET");
\] showToken("RBRACKET");
= showToken("ASSIGN");
==|!=|<|>|<=|>= showToken("RELOP");
\|\||&& showToken("LOGOP");
\+|\-|\*|\/|\% showToken("BINOP");
true showToken("TRUE");
false showToken("FALSE");
\-> showToken("ARROW");
\: showToken("COLON");
_{alnum}+ showToken("ID");
{letter}{alnum}* showToken("ID");
0b[01]+ showToken("BIN_INT");
0o[0-7]+ showToken("OCT_INT");
{digit}+ showToken("DEC_INT");
0x{xdigit}+ showToken("HEX_INT");
{digit}+\.{digit}* showToken("DEC_REAL");
{digit}*\.{digit}+ showToken("DEC_REAL");
{digit}+\.{digit}*[eE][\+-]{digit}+ showToken("DEC_REAL");
{digit}*\.{digit}+[eE][\+-]{digit}+ showToken("DEC_REAL");
0x{xdigit}+[pP][\+-]{digit}+ showToken("HEX_FP");
\" BEGIN(STRING);
<STRING>{stringprintable}* addToBuffer();
<STRING>\\n addSingleBuffer('\n');
<STRING>\\r addSingleBuffer('\r');
<STRING>\\t addSingleBuffer('\t');
<STRING>\\\\ addSingleBuffer('\\');
<STRING>\\\" addSingleBuffer('\"');
<STRING>\\u\{[a-fA-F0-9]{1,6}\} handleU();
<STRING>\\{printable} undefinedEscapeSequence();
<STRING>\\[^{printable}] undefinedEscapeSequence();
<STRING>\\ handleUnclosedString();
<STRING>[\r|\n] handleUnclosedString();
<STRING><<EOF>> handleUnclosedString();
<STRING>\" endString();BEGIN(INITIAL);

\/\/{lineprintable}* startComment(); endComment();

\/\* BEGIN(MULTICOMMENT);startComment();
<MULTICOMMENT>{commentprintable}* ;
<MULTICOMMENT>\/ ;
<MULTICOMMENT>\* ;
<MULTICOMMENT>\r\n ++lineCount;
<MULTICOMMENT>\r ++lineCount;
<MULTICOMMENT>\n ++lineCount;
<MULTICOMMENT>\/\* handleNestedComment();
<MULTICOMMENT>\*\/ endComment();BEGIN(INITIAL);
<MULTICOMMENT><<EOF>> handleUnterminatedComment();
{whitespace} ;
<*>. unknownToken(); 
%%


int printable(int c){
    return (c<=0x7e && c>= 0x20) || c== 0x9 || c == 0xa || c== 0xd;
}
void unknownToken(){
    printf ("Error %c\n", *yytext);
    exit (0);
}
void addToBuffer(){
    strcpy(buffer+buffer_pos,yytext);
    buffer_pos+=yyleng;
}
void addSingleBuffer(char c){
    buffer[buffer_pos++]=c;
}
void handleUndefinedU(){
    printf ("Error undefined escape sequence u\n");
    exit (0);
}
int isHexDecimal(char c,long long* sum){
    if(c>='0' && c <= '9'){
        *sum=*sum*16+c-'0';
        return 1;
    }
    if(c>='A' && c <= 'F'){
        *sum=*sum*16+c-'A' + 10;
        return 1;
    }
    if(c>='a' && c <= 'f'){
        *sum=*sum*16+c-'a' + 10;
        return 1;
    }
    return 0;
}
void handleU(){
    char*str=yytext+3;
    long long sum=0;
    while(isHexDecimal(*str,&sum) && sum<= 0x7e ){
        ++str;
    }
    if(!printable(*str)){
            printf ("Error %c\n", *str);
            exit (0);
    }
    if((*str!='}') || !printable(sum)){
        handleUndefinedU();        
    }
    addSingleBuffer(sum);
}
void undefinedEscapeSequence(){
    if(printable( *(yytext+1))){
        printf("Error undefined escape sequence %c\n", *(yytext+1));
    } else {
        printf ("Error %c\n", *(yytext+1));
    }
    exit(0);
    
}
void endString(){
    buffer[buffer_pos]=0;
    printf("%d %s %s\n", yylineno, "STRING", buffer); 
    buffer_pos=0;
}
void handleUnclosedString(){
    printf("Error unclosed string\n");
    exit(0);
}
void startComment(){
    lineCount=1;
}
void endComment(){
    printf("%d %s %d\n", yylineno, "COMMENT", lineCount); 
}
void handleNestedComment(){
    printf ("Warning nested comment\n");
    exit(0);
}

void handleUnterminatedComment(){
    printf ("Error unclosed comment\n");
    exit(0);
}
void showToken(char * name){
    if(!strcmp(name,"BIN_INT")){
        printf("%d %s %ld\n", yylineno, name, strtol(yytext+2,NULL,2)); 
        return;
    }
    if(!strcmp(name,"OCT_INT")){
        printf("%d %s %ld\n", yylineno, name, strtol(yytext+2,NULL,8)); 
        return;
    }
    if(!strcmp(name,"DEC_INT")){
        printf("%d %s %ld\n", yylineno, name, strtol(yytext,NULL,10)); 
        return;
    }
    if(!strcmp(name,"HEX_INT")){
        printf("%d %s %ld\n", yylineno, name, strtol(yytext+2,NULL,16)); 
        return;
    }
    printf("%d %s %s\n", yylineno, name, yytext); 
}