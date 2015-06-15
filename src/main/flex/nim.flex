package im.huy.nim.lexer;

import com.intellij.lexer.FlexLexer;
import com.intellij.openapi.util.text.StringUtil;
import com.intellij.psi.tree.IElementType;
import im.huy.nim.psi.NimTypes;

%%
%class NimLexer
%implements FlexLexer
%unicode
%function advance
%type IElementType
%eof{  return;
%eof}

DIGIT = [0-9]
NONZERODIGIT = [1-9]
OCTDIGIT = [0-7]
HEXDIGIT = [0-9A-Fa-f]
BINDIGIT = [01]

HEXINTEGER = 0[Xx]({HEXDIGIT})+
OCTINTEGER = 0[Oo]?({OCTDIGIT})+
BININTEGER = 0[Bb]({BINDIGIT})+
DECIMALINTEGER = (({NONZERODIGIT}({DIGIT})*)|0)
INTEGER = {DECIMALINTEGER}|{OCTINTEGER}|{HEXINTEGER}|{BININTEGER}
LONGINTEGER = {INTEGER}[Ll]

END_OF_LINE_COMMENT="#"[^\r\n]*

IDENT_START = [a-zA-Z_]|[:unicode_uppercase_letter:]|[:unicode_lowercase_letter:]|[:unicode_titlecase_letter:]|[:unicode_modifier_letter:]|[:unicode_other_letter:]|[:unicode_letter_number:]
IDENT_CONTINUE = [a-zA-Z0-9_]|[:unicode_uppercase_letter:]|[:unicode_lowercase_letter:]|[:unicode_titlecase_letter:]|[:unicode_modifier_letter:]|[:unicode_other_letter:]|[:unicode_letter_number:]|[:unicode_non_spacing_mark:]|[:unicode_combining_spacing_mark:]|[:unicode_decimal_digit_number:]|[:unicode_connector_punctuation:]
IDENTIFIER = {IDENT_START}{IDENT_CONTINUE}**

FLOATNUMBER=({POINTFLOAT})|({EXPONENTFLOAT})
POINTFLOAT=(({INTPART})?{FRACTION})|({INTPART}\.)
EXPONENTFLOAT=(({INTPART})|({POINTFLOAT})){EXPONENT}
INTPART = ({DIGIT})+
FRACTION = \.({DIGIT})+
EXPONENT = [eE][+\-]?({DIGIT})+

IMAGNUMBER=(({FLOATNUMBER})|({INTPART}))[Jj]

//STRING_LITERAL=[UuBb]?({RAW_STRING}|{QUOTED_STRING})
//RAW_STRING=[Rr]{QUOTED_STRING}
//QUOTED_STRING=({TRIPLE_APOS_LITERAL})|({QUOTED_LITERAL})|({DOUBLE_QUOTED_LITERAL})|({TRIPLE_QUOTED_LITERAL})

SINGLE_QUOTED_STRING=[UuBbCcRr]{0,2}({QUOTED_LITERAL} | {DOUBLE_QUOTED_LITERAL})
TRIPLE_QUOTED_STRING=[UuBbCcRr]{0,2}[UuBbCcRr]?({TRIPLE_QUOTED_LITERAL}|{TRIPLE_APOS_LITERAL})

DOCSTRING_LITERAL=({SINGLE_QUOTED_STRING}|{TRIPLE_QUOTED_STRING})

QUOTED_LITERAL="'" ([^\\\'\r\n] | {ESCAPE_SEQUENCE} | (\\[\r\n]))* ("'"|\\)?
DOUBLE_QUOTED_LITERAL=\"([^\\\"\r\n]|{ESCAPE_SEQUENCE}|(\\[\r\n]))*?(\"|\\)?
ESCAPE_SEQUENCE=\\[^\r\n]

ANY_ESCAPE_SEQUENCE = \\[^]

THREE_QUO = (\"\"\")
ONE_TWO_QUO = (\"[^\"]) | (\"\\[^]) | (\"\"[^\"]) | (\"\"\\[^])
QUO_STRING_CHAR = [^\\\"] | {ANY_ESCAPE_SEQUENCE} | {ONE_TWO_QUO}
TRIPLE_QUOTED_LITERAL = {THREE_QUO} {QUO_STRING_CHAR}* {THREE_QUO}?

THREE_APOS = (\'\'\')
ONE_TWO_APOS = ('[^']) | ('\\[^]) | (''[^']) | (''\\[^])
APOS_STRING_CHAR = [^\\'] | {ANY_ESCAPE_SEQUENCE} | {ONE_TWO_APOS}
TRIPLE_APOS_LITERAL = {THREE_APOS} {APOS_STRING_CHAR}* {THREE_APOS}?

%state PENDING_DOCSTRING
%state IN_DOCSTRING_OWNER
%{
private int getSpaceLength(CharSequence string) {
String string1 = string.toString();
string1 = StringUtil.trimEnd(string1, "\\");
string1 = StringUtil.trimEnd(string1, ";");
final String s = StringUtil.trimTrailing(string1);
return yylength()-s.length();

}
%}

%%

[\ ]                        { return NimTypes.SPACE; }
[\t]                        { return NimTypes.TAB; }
[\f]                        { return NimTypes.FORMFEED; }
"\\"                        { return NimTypes.BACKSLASH; }

<YYINITIAL> {
[\n]                        { if (zzCurrentPos == 0) yybegin(PENDING_DOCSTRING); return NimTypes.LINE_BREAK; }
{END_OF_LINE_COMMENT}       { if (zzCurrentPos == 0) yybegin(PENDING_DOCSTRING); return NimTypes.END_OF_LINE_COMMENT; }

{SINGLE_QUOTED_STRING}          { if (zzInput == YYEOF && zzStartRead == 0) return NimTypes.DOCSTRING;
                                 else return NimTypes.SINGLE_QUOTED_STRING; }
{TRIPLE_QUOTED_STRING}          { if (zzInput == YYEOF && zzStartRead == 0) return NimTypes.DOCSTRING;
                                 else return NimTypes.TRIPLE_QUOTED_STRING; }

{SINGLE_QUOTED_STRING}[\ \t]*[\n;]   { yypushback(getSpaceLength(yytext())); if (zzCurrentPos != 0) return NimTypes.SINGLE_QUOTED_STRING;
return NimTypes.DOCSTRING; }

{TRIPLE_QUOTED_STRING}[\ \t]*[\n;]   { yypushback(getSpaceLength(yytext())); if (zzCurrentPos != 0) return NimTypes.TRIPLE_QUOTED_STRING;
return NimTypes.DOCSTRING; }

{SINGLE_QUOTED_STRING}[\ \t]*"\\"  {
 yypushback(getSpaceLength(yytext())); if (zzCurrentPos != 0) return NimTypes.SINGLE_QUOTED_STRING;
 yybegin(PENDING_DOCSTRING); return NimTypes.DOCSTRING; }

{TRIPLE_QUOTED_STRING}[\ \t]*"\\"  {
 yypushback(getSpaceLength(yytext())); if (zzCurrentPos != 0) return NimTypes.TRIPLE_QUOTED_STRING;
 yybegin(PENDING_DOCSTRING); return NimTypes.DOCSTRING; }

}

[\n]                        { return NimTypes.LINE_BREAK; }
{END_OF_LINE_COMMENT}       { return NimTypes.END_OF_LINE_COMMENT; }

<YYINITIAL, IN_DOCSTRING_OWNER> {
{LONGINTEGER}         { return NimTypes.INTEGER_LITERAL; }
{INTEGER}             { return NimTypes.INTEGER_LITERAL; }
{FLOATNUMBER}         { return NimTypes.FLOAT_LITERAL; }
{IMAGNUMBER}          { return NimTypes.IMAGINARY_LITERAL; }

{SINGLE_QUOTED_STRING} { return NimTypes.SINGLE_QUOTED_STRING; }
{TRIPLE_QUOTED_STRING} { return NimTypes.TRIPLE_QUOTED_STRING; }

"and"                 { return NimTypes.AND_KEYWORD; }
"assert"              { return NimTypes.ASSERT_KEYWORD; }
"break"               { return NimTypes.BREAK_KEYWORD; }
"class"               { yybegin(IN_DOCSTRING_OWNER); return NimTypes.CLASS_KEYWORD; }
"continue"            { return NimTypes.CONTINUE_KEYWORD; }
"def"                 { yybegin(IN_DOCSTRING_OWNER); return NimTypes.DEF_KEYWORD; }
"del"                 { return NimTypes.DEL_KEYWORD; }
"elif"                { return NimTypes.ELIF_KEYWORD; }
"else"                { return NimTypes.ELSE_KEYWORD; }
"except"              { return NimTypes.EXCEPT_KEYWORD; }
"finally"             { return NimTypes.FINALLY_KEYWORD; }
"for"                 { return NimTypes.FOR_KEYWORD; }
"from"                { return NimTypes.FROM_KEYWORD; }
"global"              { return NimTypes.GLOBAL_KEYWORD; }
"if"                  { return NimTypes.IF_KEYWORD; }
"import"              { return NimTypes.IMPORT_KEYWORD; }
"in"                  { return NimTypes.IN_KEYWORD; }
"is"                  { return NimTypes.IS_KEYWORD; }
"lambda"              { return NimTypes.LAMBDA_KEYWORD; }
"not"                 { return NimTypes.NOT_KEYWORD; }
"or"                  { return NimTypes.OR_KEYWORD; }
"pass"                { return NimTypes.PASS_KEYWORD; }
"raise"               { return NimTypes.RAISE_KEYWORD; }
"return"              { return NimTypes.RETURN_KEYWORD; }
"try"                 { return NimTypes.TRY_KEYWORD; }
"while"               { return NimTypes.WHILE_KEYWORD; }
"yield"               { return NimTypes.YIELD_KEYWORD; }

{IDENTIFIER}          { return NimTypes.IDENTIFIER; }

"+="                  { return NimTypes.PLUSEQ; }
"-="                  { return NimTypes.MINUSEQ; }
"**="                 { return NimTypes.EXPEQ; }
"*="                  { return NimTypes.MULTEQ; }
"@="                  { return NimTypes.ATEQ; }
"//="                 { return NimTypes.FLOORDIVEQ; }
"/="                  { return NimTypes.DIVEQ; }
"%="                  { return NimTypes.PERCEQ; }
"&="                  { return NimTypes.ANDEQ; }
"|="                  { return NimTypes.OREQ; }
"^="                  { return NimTypes.XOREQ; }
">>="                 { return NimTypes.GTGTEQ; }
"<<="                 { return NimTypes.LTLTEQ; }
"<<"                  { return NimTypes.LTLT; }
">>"                  { return NimTypes.GTGT; }
"**"                  { return NimTypes.EXP; }
"//"                  { return NimTypes.FLOORDIV; }
"<="                  { return NimTypes.LE; }
">="                  { return NimTypes.GE; }
"=="                  { return NimTypes.EQEQ; }
"!="                  { return NimTypes.NE; }
"<>"                  { return NimTypes.NE_OLD; }
"->"                  { return NimTypes.RARROW; }
"+"                   { return NimTypes.PLUS; }
"-"                   { return NimTypes.MINUS; }
"*"                   { return NimTypes.MULT; }
"/"                   { return NimTypes.DIV; }
"%"                   { return NimTypes.PERC; }
"&"                   { return NimTypes.AND; }
"|"                   { return NimTypes.OR; }
"^"                   { return NimTypes.XOR; }
"~"                   { return NimTypes.TILDE; }
"<"                   { return NimTypes.LT; }
">"                   { return NimTypes.GT; }
"("                   { return NimTypes.LPAR; }
")"                   { return NimTypes.RPAR; }
"["                   { return NimTypes.LBRACKET; }
"]"                   { return NimTypes.RBRACKET; }
"{"                   { return NimTypes.LBRACE; }
"}"                   { return NimTypes.RBRACE; }
"@"                   { return NimTypes.AT; }
","                   { return NimTypes.COMMA; }
":"                   { return NimTypes.COLON; }

"."                   { return NimTypes.DOT; }
"`"                   { return NimTypes.TICK; }
"="                   { return NimTypes.EQ; }
";"                   { return NimTypes.SEMICOLON; }

.                     { return NimTypes.BAD_CHARACTER; }
}

<IN_DOCSTRING_OWNER> {
":"(\ )*{END_OF_LINE_COMMENT}?"\n"          { yypushback(yylength()-1); yybegin(PENDING_DOCSTRING); return NimTypes.COLON; }
}

<PENDING_DOCSTRING> {
{SINGLE_QUOTED_STRING}          { if (zzInput == YYEOF) return NimTypes.DOCSTRING;
                                 else yybegin(YYINITIAL); return NimTypes.SINGLE_QUOTED_STRING; }
{TRIPLE_QUOTED_STRING}          { if (zzInput == YYEOF) return NimTypes.DOCSTRING;
                                 else yybegin(YYINITIAL); return NimTypes.TRIPLE_QUOTED_STRING; }
{DOCSTRING_LITERAL}[\ \t]*[\n;]   { yypushback(getSpaceLength(yytext())); yybegin(YYINITIAL); return NimTypes.DOCSTRING; }
{DOCSTRING_LITERAL}[\ \t]*"\\"  {
 yypushback(getSpaceLength(yytext())); return NimTypes.DOCSTRING; }

.                               { yypushback(1); yybegin(YYINITIAL); }
}