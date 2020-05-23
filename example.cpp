#include <stdio.h>
extern int yylex();

int main()
{
    int token;
    while (token = yylex())
    {
        if (token == NUM)
        {
            showToken("NUM");
        }
        else if (token == WORD)
        {
            showToken("WORD");
        }
        else if (token == EMAIL)
        {
            showToken("EMAIL");
        }
    }
    return 0;
}