%{
	#include "source.hpp"
	#include "parser.tab.hpp"
%}

%option yylineno
%option noyywrap

%%

void	return tkvoid;
int	return tkint;
byte	return tkbyte;
b    return tkb;
bool    return tkbool;
and	return tkand;
or	return tkor;
nor	return tknot;
true	return tktrue;
false	return tkfalse;
return	return tkreturn;
if    return tkif;
else    return tkelse;
while return tkwhile;
break return tkbreak;
continue return tkcontinue;
\;    return tksc;
\,    return tkcomma;
\(	return tklp;
\)	return tkrp;
\{	return tklbrace;
\}	return tkrbrace;
=	return tkassign;
==|!=|<|>|<=|>=	return tkrelop;
\+|\-|\*|\/	return tkbinop;
[a-zA-Z]([a-zA-Z0-9]*)	{printf("id\n"); return tkid};
0|[1-9][0-9]*	return tknumber;
\"([^\n\r\"\\]|\\[rnt"\\])+\" return tksrting;
{whitespace} ;
\/\/[^\r\n]*(\r|\n|\r\n)?
<*>. unknownToken(); 
%%
