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
#include "y.tab.h"

using namespace std;


extern ofstream logfile, errorfile;
extern YYSTYPE yylval;
extern SymbolTable *symboltable;
void yyerror(char *);



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

/* void printChar(){
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
} */



%}

ws [ \t\v\r\f]
newline (\r)?(\n)
except_newline[^{newline}]
anything .


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

([+]{2})|([-]{2}) 		{
												SymbolInfo *s= new  SymbolInfo(yytext, "INCOP");
												yylval.symbolvalue = s;
												return INCOP;
											}
[+-] 									{
												SymbolInfo *s= new  SymbolInfo(yytext, "ADDOP");
												yylval.symbolvalue = s;
												return ADDOP;
											}
[*/%] 								{
												SymbolInfo *s= new  SymbolInfo(yytext, "MULOP");
												yylval.symbolvalue = s;
												return MULOP;
											}
(<=)|(>=)|(==)|(!=) 	{
												SymbolInfo *s= new  SymbolInfo(yytext, "RELOP");
												yylval.symbolvalue = s;
												return RELOP;
											}
[<>] 									{
												SymbolInfo *s= new  SymbolInfo(yytext, "RELOP");
												yylval.symbolvalue = s;
												return RELOP;
											}
= 										{return ASSIGNOP;}
(&&)|([|]{2}) 				{
												SymbolInfo *s= new  SymbolInfo(yytext, "LOGICOP");
												yylval.symbolvalue = s;
												return LOGICOP;
											}
[!] 									{return NOT;}
[(] 									{return LPAREN;}
[)] 									{return RPAREN;}
[{] 									{return LCURL;}
[}] 									{return RCURL;}
\[ 										{return LTHIRD;}
\] 										{return RTHIRD;}
, 										{return COMMA;}
; 										{return SEMICOLON;}


[\/]{2} 									{ BEGIN COMMENT_STATE; commentOutput+=yytext; initial_line=line_count;}
<COMMENT_STATE>{newline}  {BEGIN INITIAL; line_count++;commentOutput="";}
<COMMENT_STATE>(\\)$ 			{line_count++; commentOutput+=yytext; yyinput(); commentOutput+='\n';}
<COMMENT_STATE>. 					{commentOutput+=yytext;}

(\/\*) 										{BEGIN COMMENT_STATE2; commentOutput+=yytext; initial_line=line_count;}
<COMMENT_STATE2>{newline} {line_count++;commentOutput+=yytext;}
<COMMENT_STATE2>(\*\/) 		{commentOutput+=yytext; commentOutput="";BEGIN INITIAL;}
<COMMENT_STATE2>. 				{commentOutput+=yytext;}
<COMMENT_STATE2><<EOF>>   {++error_count;
	 												errorfile<<"\nError at line no "<<initial_line<<": Unterminated Comment "<<commentOutput<<endl<<endl;
													logfile<<"\nError at line no "<<initial_line<<": Unterminated Comment "<<commentOutput<<endl<<endl; BEGIN INITIAL;}

\" 												{BEGIN STRING_STATE; clearVar(); stringOutput+=yytext; stringLexeme+=yytext; initial_line=line_count;}
<STRING_STATE>\" 					{BEGIN INITIAL;stringOutput+=yytext; stringLexeme+=yytext; //printString()
														clearVar();
														SymbolInfo *s = new SymbolInfo(stringOutput,"STRING");
														yylval.symbolvalue = s;
														return STRING;
													}
<STRING_STATE>{newline} 	{BEGIN INITIAL; line_count++; ++error_count;
	 												errorfile<<"\nError at line no "<<initial_line<<": Unterminated String "<<stringLexeme<<endl<<endl;
													logfile<<"\nError at line no "<<initial_line<<": Unterminated String "<<stringLexeme<<endl<<endl; clearVar();}

<STRING_STATE>(\\)$ 			{line_count++; stringLexeme+=yytext; yyinput(); stringLexeme+='\n';}
<STRING_STATE>(\\{anything}) {	char ch=mapSpecialChar(yytext);
																if(ch!='w') stringOutput+=ch;
																else stringOutput+=yytext;
																stringLexeme+=yytext;}
<STRING_STATE>{character} {stringOutput+=yytext; stringLexeme+=yytext;}
<STRING_STATE>. 					{stringOutput+=yytext; stringLexeme+=yytext;}

"if" 			 {return IF;}
"for" 		 {return FOR;}
"do" 			 {return DO;}
"int" 		 {return INT;}
"float" 	 {return FLOAT;}
"void"  	 {return VOID;}
"switch" 	 {return SWITCH;}
"default"  {return DEFAULT;}
"else" 		 {return ELSE;}
"while" 	 {return WHILE;}
"break" 	 {return BREAK;}
"char" 		 {return CHAR;}
"double" 	 {return DOUBLE;}
"return" 	 {return RETURN;}
"case" 		 {return CASE;}
"continue" {return CONTINUE;}
"printf" {return PRINTLN;}


{id} 					{
								SymbolInfo *s= symboltable->Look_up(yytext);
								if(s==NULL)
								{
									s= new SymbolInfo(yytext, "ID");
								}
								yylval.symbolvalue = s;
								return ID;
							}

{char_literal} {
								SymbolInfo *s= symboltable->Look_up(yytext);
								if(s==NULL)
								{
									s = new SymbolInfo(yytext, "CONST_CHAR");
								}
								yylval.symbolvalue = s;
								return CONST_CHAR;}

{int_number} 	 {
								SymbolInfo *s= symboltable->Look_up(yytext);
								if(s==NULL)
								{
									s= new SymbolInfo(yytext, "CONST_INT");
								}
								yylval.symbolvalue = s;
								return CONST_INT;
							}

{float_number} {
								SymbolInfo *s= symboltable->Look_up(yytext);
								if(s==NULL)
								{
									s= new SymbolInfo(yytext, "CONST_FLOAT");
								}
								yylval.symbolvalue = s;
								return CONST_FLOAT;
							}

{error_too_many_decimal_point} 	{++error_count;
																errorfile<<"\nError at line no "<<line_count<<": Too many decimal points "<<yytext<<endl<<endl;
																logfile<<"\nError at line no "<<line_count<<": Too many decimal points "<<yytext<<endl<<endl;}
{error_ill_formed_number} 			{++error_count;
																errorfile<<"\nError at line no "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;
																logfile<<"\nError at line no "<<line_count<<": Ill formed number "<<yytext<<endl<<endl;}
{error_invalid_id} 							{++error_count;
																errorfile<<"\nError at line no "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl<<endl;
																logfile<<"\nError at line no "<<line_count<<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<endl<<endl;}
{error_empty_char} 							{++error_count;
																errorfile<<"\nError at line no "<<line_count<<": Empty character constant error "<<yytext<<endl<<endl;
																logfile<<"\nError at line no "<<line_count<<": Empty character constant error "<<yytext<<endl<<endl;}
{error_unfinished_char} 				{++error_count;
																errorfile<<"\nError at line no "<<line_count<<": Unterminated Character "<<yytext<<endl<<endl;
																logfile<<"\nError at line no "<<line_count<<": Unterminated Character "<<yytext<<endl<<endl;}
{error_multi_char} 							{++error_count;
																errorfile<<"\nError at line no "<<line_count<<": Multi character constant error "<<yytext<<endl<<endl;
																logfile<<"\nError at line no "<<line_count<<": Multi character constant error "<<yytext<<endl<<endl;}

<<EOF>> 											 {return 0;}

. 														 {++error_count;
	 															errorfile<<"\nError at line no "<<line_count<<": Unrecognized character "<<yytext<<endl<<endl;
																logfile<<"\nError at line no "<<line_count<<": Unrecognized character "<<yytext<<endl<<endl;}
%%

/*int main(int argc,char *argv[]){

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
*/
