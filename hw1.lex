%{
    /* Declarations section */
    
    #include "string.h"
    void showToken(char *);
    void parseString(char*);
    void unknownToken();
    void handleUnclosedString();
    void handleNestedComment();
    void handleUndefinedU();
    void handleUnterminatedComment();
%}
%option yylineno
%option noyywrap
digit ([0-9])
letter ([a-zA-Z])
alnum ([a-zA-Z0-9])
xdigit ({digit}|[A-Fa-f])
whitespace ([\t\n ])
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
\"([^\"\n\r]|(\\\"))* handleUnclosedString();
\"([^\"\n\r]|(\\\"))*\" showToken("STRING");
\/\/[^\n\r]* showToken("COMMENT");
\/\*([^\*]|\*[^\/])* handleUnterminatedComment();
\/\*([^\*]|\*[^\/])*\*\/ showToken("COMMENT");
{whitespace} ;
. unknownToken(); 
%%
void unknownToken(){
    printf ("Error %s\n", yytext);
    exit (0);
}

void handleUnclosedString(){
    printf("Error unclosed string\n");
    exit(0);
}

void handleNestedComment(){
    printf ("Warning nested comment\n");
    exit(0);
}

void handleUndefinedU(){
    printf ("Error undefined escape sequence u\n");
    exit (0);
}

void handleUnterminatedComment(){
    printf ("Error unclosed comment\n");
    exit(0);
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

char handleU(char **str){
    if(**str!='{')
        handleUndefinedU();
    ++(*str);
    long long sum=0;
    while(isHexDecimal(**str,&sum) && sum<= 0x7e){
        ++(*str);
    }
    if(**str!='}')
        handleUndefinedU();
    if((**str!='}') || sum>0x7e || (sum<0x20 && sum!=0x09 && sum != 0x0a && sum != 0x0d)){
        handleUndefinedU();        
    }
    return sum;
}

void parseString(char*str){
    char *current = str;
    ++str;
    while(*(str+1)){
        if(*str!='\\'){
            *current=*str;
            ++current;
            ++str;
            continue;
        }
        ++str; 
        if(*(str)=='n'){
            *current='\n';
        } else if(*str=='r'){
            *current='\r';
        } else if(*str=='t'){
            *current='\t';
        } else if(*str=='\\'){
            *current='\\';
        } else if(*str=='\"'){
            *current='\"';
        } else if(*str=='u'){
            ++str;
            *current = handleU(&str);
        }
        else {
            *current = *str;
            printf("Error undefined escape sequence %c\n", *current);
            exit(0);
        }
        ++current;
        ++str;
    }
    *current =0;
}

int countLines(char* str){
    int counter=1;
    while(*str){
        if(*str=='\n'){
            ++counter;
        } else if(*str=='\r'){
            ++counter;
            if(*(str+1) && *(str+1)=='\n'){
                ++str;
            }
        }
        ++str;
    }
    return counter;
}
void checkNestedComments(char * str){
    ++str;
    ++str;
    while(*(str+1)){
        if(*str!='/'){
            ++str;
            continue;
        }
        ++str; 
        if(*(str)=='*'){
            handleNestedComment();    
        }
    }
    return;
}
void showToken(char * name){
    if(!strcmp(name,"COMMENT")){
        if(*(yytext+1)=='*'){
            checkNestedComments(yytext);
        }
        printf("%d %s %d\n", yylineno, name, countLines(yytext)); 
        return;
    }
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
    if(!strcmp(name,"STRING")){
        parseString(yytext);
    }
    printf("%d %s %s\n", yylineno, name, yytext); 
}
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) && !defined(__CYGWIN__)
int main()
{
    while (yylex())
    return 0;
}
#endif