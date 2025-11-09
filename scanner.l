%{
#include <stdio.h>
#include <stdlib.h>

FILE *tokFile;
FILE *errFile;

void printToken(const char* type, const char* lexeme);
void printError(const char* lexeme);
%}

%option noyywrap
%option yylineno
%s COMMENT

LETTER      [A-Za-z_]
DIGIT       [0-9]

ID          {LETTER}({LETTER}|{DIGIT})*

INT         {DIGIT}+
FLOAT       ({DIGIT}+"."{DIGIT}*|"."{DIGIT}+)
EXP         ({DIGIT}+"."{DIGIT}*|"."{DIGIT}+|{DIGIT}+)[eE][+-]?{DIGIT}+

STRING      \"([^"\\]|\\.)*\"
CHAR        \'([^\'\\]|\\.)\'

WS          [ \t\r]+
NEWLINE     \n

LINECOMMENT \/\/.*

%%

{WS}                { /* ignore spaces and tabs */ }
{NEWLINE}           { /* newline; yylineno auto-updated */ }
{LINECOMMENT}       { /* ignore // comments */ }

 
"/*"                { BEGIN(COMMENT); }
<COMMENT>"*/"       { BEGIN(INITIAL); }
<COMMENT>.|\n        { /* consume comment contents, update lineno via %option yylineno */ }

 
 
"start"                 { printToken("KW_START", yytext); }
"player"                { printToken("KW_VARDECL", yytext); }
"score"                 { printToken("KW_STRING", yytext); }
"bowl"                  { printToken("KW_PRINT", yytext); }
"ball"                  { printToken("KW_INPUT", yytext); }
"catch"                 { printToken("KW_IF", yytext); }
"noball"                { printToken("KW_ELSE", yytext); }
"wide ball"             { printToken("KW_ELSEIF", yytext); }
"over"                  { printToken("KW_LOOP", yytext); }
"field"                 { printToken("KW_ARRAY", yytext); }
"team"                  { printToken("KW_CLASS", yytext); }
"toss"                  { printToken("KW_BOOL", yytext); }
"wicket"                { printToken("KW_BREAK", yytext); }
"return to pavilion"    { printToken("KW_RETURN", yytext); }
"umpire"                { printToken("KW_DEFAULT", yytext); }

 
"<-"                { printToken("OP_ASSIGN_ARROW", yytext); }
"&&&"               { printToken("OP_AND3", yytext); }
"##"                { printToken("OP_CAT", yytext); }

"=="                { printToken("OP_EQ", yytext); }
"!="                { printToken("OP_NEQ", yytext); }
"<="                { printToken("OP_LE", yytext); }
">="                { printToken("OP_GE", yytext); }
"&&"                { printToken("OP_AND", yytext); }
"||"                { printToken("OP_OR", yytext); }
"++"                { printToken("OP_INC", yytext); }
"--"                { printToken("OP_DEC", yytext); }
"="                 { printToken("OP_ASSIGN", yytext); }
"<"                 { printToken("OP_LT", yytext); }
">"                 { printToken("OP_GT", yytext); }
"+"                 { printToken("OP_PLUS", yytext); }
"-"                 { printToken("OP_MINUS", yytext); }
"*"                 { printToken("OP_MUL", yytext); }
"/"                 { printToken("OP_DIV", yytext); }
"%"                 { printToken("OP_MOD", yytext); }

 
"::"                { printToken("PUNC_DBLCOLON", yytext); }
"{"                 { printToken("PUNC_LCURLY", yytext); }
"}"                 { printToken("PUNC_RCURLY", yytext); }
"("                 { printToken("PUNC_LPAREN", yytext); }
")"                 { printToken("PUNC_RPAREN", yytext); }
";"                 { printToken("PUNC_SEMI", yytext); }
","                 { printToken("PUNC_COMMA", yytext); }

 
{STRING}            { printToken("STRING_LITERAL", yytext); }
{CHAR}              { printToken("CHAR_LITERAL", yytext); }
{EXP}               { printToken("NUMBER_EXP", yytext); }
{FLOAT}             { printToken("NUMBER_FLOAT", yytext); }
{INT}               { printToken("NUMBER_INT", yytext); }

 
{ID}                { printToken("IDENTIFIER", yytext); }

 
"@"({LETTER}|{DIGIT})*  { printError(yytext); }
.   { printError(yytext); }

%%

void printToken(const char* type, const char* lexeme) {
    fprintf(tokFile, "Line %d: %s → %s\n", yylineno, type, lexeme);
}

void printError(const char* lexeme) {
    fprintf(errFile, "Line %d: ERROR → %s (invalid token)\n", yylineno, lexeme);
}

int main(int argc, char** argv) {
    tokFile = fopen("tokens.txt", "w");
    if (!tokFile) {
        perror("tokens.txt");
        return 1;
    }

    errFile = fopen("errors.txt", "w");
    if (!errFile) {
        perror("errors.txt");
        return 1;
    }

    if (argc > 1) {
        FILE *in = fopen(argv[1], "r");
        if (!in) {
            perror("source file");
            return 1;
        }
        yyin = in;
        yylex();
        fclose(in);
    } else {
        yylex();
    }

    fclose(tokFile);
    fclose(errFile);
    return 0;
}