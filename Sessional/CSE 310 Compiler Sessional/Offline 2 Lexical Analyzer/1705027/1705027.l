%option noyywrap

%x COMMENT_STATE
%x COMMENT_STATE2
%x STRING_STATE

%{
#include<stdio.h>
#include<stdlib.h>
#include<iostream>
#include<fstream>
#include<string>
#include "symboltable.h"
using namespace std;

int total_buckets=7;
SymbolTable *symboltable=new SymbolTable(total_buckets);

ofstream flog;
ofstream ftoken;
string stringLexeme;
string stringOutput;
string commentOutput;

int line_count=1;
int error_count=0;
int initial_line;

void clearVar(){
	stringLexeme="";
	stringOutput="";
}


void printop(string token){
		ftoken<<"<"<<token<<", " <<yytext<<"> ";
		flog<<"Line no "<<line_count<<": Token <"<<token<<"> Lexeme "<<yytext<<" found\n"<<endl;
}

void printKeyword(){
		string token = yytext;
		transform(token.begin(), token.end(), token.begin(), ::toupper);
		ftoken<<"<"<<token<<"> ";
		flog<<"Line no "<<line_count<<": Token <"<<token<<"> Lexeme "<<yytext<<" found\n"<<endl;
}

char mapSpecialChar(string s){
	char ch;
	if(s=="\\n") ch='\n';
	else if(s=="\\t") ch='\t';
	else if(s=="\\\\") ch='\\';
	else if(s=="\\a") ch='\a';
	else if(s=="\\f") ch='\f';
	else if(s=="\\r") ch='\r';
	else if(s=="\\b") ch='\b';
	else if(s=="\\v") ch='\v';
	else if(s=="\\0") ch='\n';
	else if(s=="\\\'") ch='\'';
	else if(s=="\\\"") ch='\"';
	else return 'w';
	return ch;
}

void printChar(){
		char ch1;
		char ch = yytext[1];
		string s(1, ch);
		if(yytext[1]=='\\'){
			ch1=yytext[2]; s+=ch1;
			ch=mapSpecialChar(s);
		}
		if(ch!='w') ftoken<<"<CONST_CHAR, "<<ch<<"> ";
		else ftoken<<"<CONST_CHAR, "<<s<<"> ";
		bool inserted=symboltable->Insert(yytext,"CONST_CHAR");
		if(ch!='w') flog<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CONST_CHAR, "<<ch<<"> \n"<<endl;
		else flog<<"Line no "<<line_count<<": Token <CONST_CHAR> Lexeme "<<yytext<<" found --> <CONST_CHAR, "<<s<<"> \n"<<endl;
		if(inserted) symboltable->Print_All_ScopeTable(flog);
		else flog<<yytext<<" already exists in current ScopeTable\n";
}

void printString(){
		ftoken<<"<STRING, "<<stringOutput<<"> ";
		flog<<"Line no "<<initial_line<<": Token <STRING> Lexeme "<<stringLexeme<<" found --> <STRING, "<<stringOutput<<"> \n"<<endl;
}

void printID(){
				ftoken<<"<ID, "<<yytext<<"> ";
				bool inserted=symboltable->Insert(yytext,"ID");
				flog<<"Line no "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found\n"<<endl;
				if(inserted) symboltable->Print_All_ScopeTable(flog);
				else flog<<yytext<<" already exists in current ScopeTable\n";
}

void printNumber(string type){
					ftoken<<"<"<<type<<", "<<yytext<<"> ";
					bool inserted=symboltable->Insert(yytext,type);
					flog<<"Line no "<<line_count<<": Token <"<<type<<"> Lexeme "<<yytext<<" found\n"<<endl;
					if(inserted) symboltable->Print_All_ScopeTable(flog);
					else flog<<yytext<<" already exists in current ScopeTable\n";
}

void printComment(){
		flog<<"Line no "<<initial_line<<": Token <COMMENT> Lexeme "<<commentOutput<<" found\n"<<endl;
}



%}

ws [ \t\v\r\f]
newline (\r)?(\n)
except_newline[^{newline}]
anything .
/* specialchar [\n\t\\\'\a\f\r\b\v\0] */

digit [0-9]
Letter [a-zA-Z]
character ((\\{anything})|([^\\'(\n)]))
char_literal ([\'])({character})([\'])

id (_|{Letter})({Letter}|{digit}|_)*

int_number {digit}+
float_number {digit}+(\.{digit}+)?((E|e)[+-]?{digit}+)?

error_too_many_decimal_point {digit}*(\.{digit}*){2,}
error_ill_formed_number {digit}*((\.{digit}*)*)((E|e)[+-]?{digit}*)?(\.{digit}*)*
error_invalid_id ({digit})({Letter}|{digit}|_)*
error_multi_char \'({character}){2,}\'
error_unfinished_char (\'{character}+)|(\'\\\')|(\'\\)
error_empty_char \'\'


%%

{ws}+ {}
{newline} {line_count++;}

([+]{2})|([-]{2}) {printop("INCOP");}
[+-] {printop("ADDOP");}
[*/%] {printop("MULOP");}
(<=)|(>=)|(==)|(!=) {printop("RELOP");}
[<>] {printop("RELOP");}
= {printop("ASSIGNOP");}
(&&)|([|]{2}) {printop("LOGICOP");}
[!] {printop("NOT");}
[(] {printop("LPAREN");}
[)] {printop("RPAREN");}
[{] {printop("LCURL"); symboltable->Enter_Scope();}
[}] {printop("RCURL"); symboltable->Exit_Scope();}
\[ {printop("LTHIRD");}
\] {printop("RTHIRD");}
, {printop("COMMA");}
; {printop("SEMICOLON");}


[\/]{2} { BEGIN COMMENT_STATE; commentOutput+=yytext; initial_line=line_count;}
<COMMENT_STATE>{newline} {BEGIN INITIAL; printComment(); line_count++;commentOutput="";}
<COMMENT_STATE>(\\)$ {line_count++; commentOutput+=yytext; yyinput(); commentOutput+='\n';}
<COMMENT_STATE>. {commentOutput+=yytext;}

(\/\*) {BEGIN COMMENT_STATE2; commentOutput+=yytext; initial_line=line_count;}
<COMMENT_STATE2>{newline} {line_count++;commentOutput+=yytext;}
<COMMENT_STATE2>(\*\/) {commentOutput+=yytext;printComment(); commentOutput="";BEGIN INITIAL;}
<COMMENT_STATE2>. {commentOutput+=yytext;}
<COMMENT_STATE2><<EOF>> {++error_count; flog<<"\nError at line no "<<initial_line<<": Unterminated Comment "<<commentOutput<<endl; BEGIN INITIAL;}

\" {BEGIN STRING_STATE; clearVar(); stringOutput+=yytext; stringLexeme+=yytext; initial_line=line_count;}
<STRING_STATE>\" {BEGIN INITIAL;stringOutput+=yytext; stringLexeme+=yytext; printString(); clearVar();}
<STRING_STATE>{newline} {BEGIN INITIAL; line_count++; ++error_count; flog<<"\nError at line no "<<initial_line<<": Unterminated String "<<stringLexeme<<endl; clearVar();}
<STRING_STATE>(\\)$ {line_count++; stringLexeme+=yytext;yyinput(); stringLexeme+='\n';}
<STRING_STATE>(\\{anything}) {char ch=mapSpecialChar(yytext);
														if(ch!='w') stringOutput+=ch;
														else stringOutput+=yytext;
														stringLexeme+=yytext;}
<STRING_STATE>{character} {stringOutput+=yytext; stringLexeme+=yytext;}
<STRING_STATE>. {stringOutput+=yytext; stringLexeme+=yytext;}

"if" |
"for" |
"do" |
"int" |
"float" |
"void" |
"switch" |
"default" |
"else" |
"while" |
"break" |
"char" |
"double" |
"return" |
"case" |
"continue" {printKeyword();}


{id} {printID();}

{char_literal} {printChar();}

{int_number} {printNumber("CONST_INT");}

{float_number} {printNumber("CONST_FLOAT");}

{error_too_many_decimal_point} {++error_count;flog<<"\nError at line no "<<line_count<<": Too many decimal points "<<yytext<<endl;}
{error_ill_formed_number} {++error_count; flog<<"\nError at line no "<<line_count<<": Ill formed number "<<yytext<<endl;}
{error_invalid_id} {++error_count; flog<<"\nError at line no "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl;}
{error_empty_char} {++error_count; flog<<"\nError at line no "<<line_count<<": Empty character constant error "<<yytext<<endl;}
{error_unfinished_char} {++error_count; flog<<"\nError at line no "<<line_count<<": Unterminated Character "<<yytext<<endl;}
{error_multi_char} {++error_count; flog<<"\nError at line no "<<line_count<<": Multi character constant error "<<yytext<<endl;}

<<EOF>> {symboltable->Print_All_ScopeTable(flog); flog<<"Total lines: "<<line_count<<endl; flog<<"Total errors: "<<error_count<<endl; return 0;}

. {++error_count; flog<<"\nError at line no "<<line_count<<": Unrecognized character "<<yytext<<endl;}
%%

int main(int argc,char *argv[]){

	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	flog.open("1705027_log.txt");
	ftoken.open("1705027_token.txt");
	yyin= fin;
	yylex();
	fclose(yyin);
	return 0;
}
