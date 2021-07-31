%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "symboltable.h"
#include "utils.h"

using namespace std;

%}

%union{
	SymbolInfo* symbolvalue;
}


%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON
%token PRINTLN
%token<symbolvalue> ID CONST_INT CONST_FLOAT CONST_CHAR ADDOP INCOP MULOP RELOP LOGICOP
%token<symbolvalue> STRING

%type<symbolvalue> program unit type_specifier declaration_list parameter_list func_definition func_declaration compound_statement statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor arguments argument_list var_declaration
/* %left
%right*/
%nonassoc LOWER_THAN_RPAREN
%nonassoc RPAREN
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
					{
						printTologFile("start : program");
						symboltable->Print_All_ScopeTable(logfile);
						logfile<<"\nTotal lines: "<<line_count<<endl;
						logfile<<"\nTotal errors: "<<error_count+syntax_error<<endl;
						//write your code in this block in all the similar blocks below
					}
	;

program : program unit
					{
						string output = getfromStack(program)+ getfromStack(unit);
						saveinStack(program, output);

						printTologFile("program : program unit");
						printTextToLogfile(output);
					}
	| unit
				 {
					 string output = getfromStack(unit);
					 saveinStack(program,output);

					 printTologFile("program : unit");
					 printTextToLogfile( output);
				 }
	;

unit : var_declaration
				{
					string output = getfromStack(var_declaration);
					saveinStack(unit,output);

					printTologFile("unit : var_declaration");
					printTextToLogfile( output);
				}
     | func_declaration
		 		{
					string output = getfromStack(func_declaration);
					saveinStack(unit,output);

					printTologFile("unit : func_declaration");
					printTextToLogfile( output);
				}
     | func_definition
		 		{
					string output = getfromStack(func_definition);
					saveinStack(unit, output);

					printTologFile("unit : func_definition");
					printTextToLogfile( output);
				}
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + getfromStack(parameter_list) + ");\n";
					saveinStack(func_declaration,output);

					printTologFile("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
					printTextToLogfile( output);

					handle_func_declaration($1->getVariableDataType(), $2->getName());
					paramTypeList.clear();
					parameters.clear();

				}
		| type_specifier ID LPAREN RPAREN SEMICOLON
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "();\n";
					saveinStack(func_declaration,output);

					printTologFile("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
					printTextToLogfile( output);

					handle_func_declaration($1->getVariableDataType(), $2->getName());
				}
		| error ID LPAREN parameter_list RPAREN SEMICOLON //error recovery
				{
					string output = $2->getName() + "(" + getfromStack(parameter_list) + ");\n";
					saveinStack(func_declaration,output);

					paramTypeList.clear();
					parameters.clear();
					//print_error_recovery_mode("return type error in function declaration");
				}
		| error ID LPAREN RPAREN SEMICOLON //error recovery
				{
					string output = $2->getName() + "(" + ");\n";
					saveinStack(func_declaration,output);

					//print_error_recovery_mode("return type error in function declaration");
				}
		| type_specifier ID LPAREN error SEMICOLON //error recovery
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "( ;\n";
					saveinStack(func_declaration,output);

					//print_error_recovery_mode("RPAREN MISSING in function declaration");
				}
		| type_specifier ID LPAREN parameter_list RPAREN error //error recovery
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + getfromStack(parameter_list) + ")\n";
					saveinStack(func_declaration,output);

					paramTypeList.clear();
					parameters.clear();
					//print_error_recovery_mode("semicolon missing in function declaration");
				}
		| type_specifier ID LPAREN RPAREN error //error recovery
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + ")\n";
					saveinStack(func_declaration,output);

					//print_error_recovery_mode("semicolon missing in function declaration");
				}
		| type_specifier ID LPAREN error RPAREN SEMICOLON //error recovery
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + ");\n";
					saveinStack(func_definition, output);

					//print_error_recovery_mode("parameter list error in function declaration");
				}
		| type_specifier error LPAREN parameter_list RPAREN SEMICOLON //error recovery
				{
					string output = getfromStack(type_specifier) + " " + "(" + getfromStack(parameter_list) + ");\n";
					saveinStack(func_declaration,output);
					paramTypeList.clear();
					parameters.clear();
					//print_error_recovery_mode("function id missing in declaration");
				}
		| type_specifier error LPAREN RPAREN SEMICOLON //error recovery
				{
					string output = getfromStack(type_specifier) + " " + "(" + ");\n";
					saveinStack(func_declaration,output);
					paramTypeList.clear();
					parameters.clear();
					//print_error_recovery_mode("function id missing in declaration");
				}
		;

func_definition : type_specifier ID LPAREN parameter_list RPAREN
																															{handle_func_defination($1->getVariableDataType(),$2->getName());} compound_statement
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + getfromStack(parameter_list) + ")" + getfromStack(compound_statement);
					saveinStack(func_definition, output);

					printTologFile("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
					printTextToLogfile( output);
					paramTypeList.clear();
					parameters.clear();
				}
		| type_specifier ID LPAREN RPAREN
																		{handle_func_defination($1->getVariableDataType(),$2->getName());} compound_statement
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "()" + getfromStack(compound_statement);
					saveinStack(func_definition, output);

					printTologFile("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
					printTextToLogfile( output);
				}
		| error ID LPAREN parameter_list RPAREN compound_statement //error recovery
				{
					string output = $2->getName() + "(" + getfromStack(parameter_list) + ")" + getfromStack(compound_statement);
					saveinStack(func_definition, output);
					parameters.clear();
					paramTypeList.clear();

					//print_error_recovery_mode("return type error in function definition");
				}
		| error ID LPAREN RPAREN compound_statement //error recovery
				{
					string output = $2->getName() + "()" + getfromStack(compound_statement);
					saveinStack(func_definition, output);

					//print_error_recovery_mode("return type error in function definition");
				}
		| type_specifier ID LPAREN error RPAREN compound_statement //error recovery
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + ")" + getfromStack(compound_statement);
					saveinStack(func_definition, output);
					parameters.clear();
					paramTypeList.clear();
					//print_error_recovery_mode("parameter list error in function definition");
				}
		| type_specifier ID LPAREN error compound_statement //error recovery
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + getfromStack(compound_statement);
					saveinStack(func_definition, output);
					parameters.clear();
					paramTypeList.clear();
					//print_error_recovery_mode("RPAREN MISSING in function definition");
				}
		| type_specifier error LPAREN parameter_list RPAREN compound_statement //error recovery
				{
					string output = getfromStack(type_specifier) + "(" + getfromStack(parameter_list) + ")" + getfromStack(compound_statement);
					saveinStack(func_definition, output);
					parameters.clear();
					paramTypeList.clear();
					//print_error_recovery_mode("id missing in function definition");
				}
		| type_specifier error LPAREN RPAREN compound_statement //error recovery
				{
					string output = getfromStack(type_specifier) + "(" + ")" + getfromStack(compound_statement);
					saveinStack(func_definition, output);
					parameters.clear();
					paramTypeList.clear();
					//print_error_recovery_mode("id missing in function definition");
				}
 		;


parameter_list  : parameter_list COMMA type_specifier ID
				{
					string output = getfromStack(parameter_list) + "," + getfromStack(type_specifier)+" "+$4->getName();
					saveinStack(parameter_list, output);

					printTologFile("parameter_list : parameter_list COMMA type_specifier ID");
					printTextToLogfile( output);

					handle_func_parameter($3->getName(), $4->getName()); //adding type and id to parameters list as a SymbolInfo
					paramTypeList.push_back($3->getVariableDataType());

				}
		| parameter_list COMMA type_specifier
				{
					string output = getfromStack(parameter_list) + "," + getfromStack(type_specifier);
					saveinStack(parameter_list, output);

					printTologFile("parameter_list : parameter_list COMMA type_specifier");
					printTextToLogfile( output);

					paramTypeList.push_back($3->getVariableDataType());
				}
 		| type_specifier ID
				{
					string output = getfromStack(type_specifier) + " " + $2->getName();
					saveinStack(parameter_list, output);

					printTologFile("parameter_list : type_specifier ID");
					printTextToLogfile( output);

					handle_func_parameter($1->getName(), $2->getName()); //adding type and id to parameters list as a SymbolInfo
					paramTypeList.push_back($1->getVariableDataType());
				}
		| type_specifier
				{
					string output = getfromStack(type_specifier);
					saveinStack(parameter_list, output);

					printTologFile("parameter_list : type_specifier");
					printTextToLogfile( output);

					paramTypeList.push_back($1->getVariableDataType());

				}
		| parameter_list COMMA error ID //error recovery
				{
					string output = getfromStack(parameter_list) + "," +$4->getName();
					saveinStack(parameter_list, output);

					//print_error_recovery_mode("type missing in parameter list");
				}
		| error ID //error recovery
				{
					string output = $2->getName();
					saveinStack(parameter_list, output);

					//print_error_recovery_mode("type missing in parameter list");
				}
		| type_specifier error //error recovery
			{
				string output = getfromStack(type_specifier);
				saveinStack(parameter_list, output);
				//print_error_recovery_mode("parameter's name not given");
			}
		| parameter_list COMMA type_specifier error //error recovery
			{
				string output = getfromStack(parameter_list) + "," + getfromStack(type_specifier);
				saveinStack(parameter_list, output);
				//print_error_recovery_mode("parameter's name not given");
			}
 		;


compound_statement : LCURL
												{	symboltable->Enter_Scope();
													for(int i=0;i<parameters.size();i++) symboltable->Insert(parameters[i]);
													parameters.clear();
												} statements RCURL
				{
					string output = "{\n" + getfromStack(statements) + "}\n\n";
					saveinStack(compound_statement, output);

					printTologFile("compound_statement : LCURL statements RCURL");
					printTextToLogfile( output);

					parameters.clear();
					paramTypeList.clear();
					symboltable->Print_All_ScopeTable(logfile);
					symboltable->Exit_Scope();
					current_function=NULL;
				}
 		| LCURL
					{symboltable->Enter_Scope();
					 for(int i=0;i<parameters.size();i++) symboltable->Insert(parameters[i]);
					 parameters.clear();
					 } RCURL
				{
					string output = "{}\n\n";
					saveinStack(compound_statement, output);

					printTologFile("compound_statement : LCURL RCURL");
					printTextToLogfile( output);

					parameters.clear();
					paramTypeList.clear();
					symboltable->Print_All_ScopeTable(logfile);
					symboltable->Exit_Scope();
					current_function=NULL;
				}
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON
				{
					string output = getfromStack(type_specifier) + " "+ getfromStack(declaration_list) + ";\n";
					saveinStack(var_declaration, output);

					printTologFile("var_declaration : type_specifier declaration_list SEMICOLON");
					printTextToLogfile( output);
				}
		 /* | type_specifier declaration_list error //error recovery
				{
					string output = getfromStack(type_specifier) + " "+ getfromStack(declaration_list) + "\n";
					saveinStack(var_declaration, output);

					//print_error_recovery_mode("semicolon(;) missing after variable declaration");
				} */
		| error declaration_list SEMICOLON //error recovery
					{
						string output = getfromStack(declaration_list) + ";\n";
						saveinStack(var_declaration, output);

						//print_error_recovery_mode("id data type missing");
					}
 		 ;

type_specifier	: INT
				{
					datatype = "INT";
					SymbolInfo *s = new SymbolInfo();
					s->setName("int");
					s->setVariableDataType(datatype);
					$$ = s;

					saveinStack(type_specifier,s->getName());

					printTologFile("type_specifier : INT");
					printTextToLogfile( "int");
				}
 		| FLOAT
				{
					datatype = "FLOAT";
					SymbolInfo *s = new SymbolInfo();
					s->setName("float");
					s->setVariableDataType(datatype);
					$$ = s;

					saveinStack(type_specifier,s->getName());

					printTologFile("type_specifier : FLOAT");
					printTextToLogfile( "float");
				}
 		| VOID
				{
					datatype = "VOID";
					SymbolInfo *s = new SymbolInfo();
					s->setName("void");
					s->setVariableDataType(datatype);
					$$ = s;

					saveinStack(type_specifier,s->getName());

					printTologFile("type_specifier : VOID");
					printTextToLogfile( "void");
				}
 		;

declaration_list : declaration_list COMMA ID
				{
					string output = getfromStack(declaration_list)+","+$3->getName();
					saveinStack(declaration_list,output);

					printTologFile("declaration_list : declaration_list COMMA ID");
					printTextToLogfile( output);

					handle_variable($3->getName());
				}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
				{
					string output = getfromStack(declaration_list)+","+$3->getName()+"["+$5->getName()+"]";
					saveinStack(declaration_list,output);

					printTologFile("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
					printTextToLogfile( output);

					handle_array($3->getName(), $5->getName());
				}
 		  | ID
				{
					$$ = $1;
					saveinStack(declaration_list,$1->getName());

					printTologFile("declaration_list : ID");
					printTextToLogfile( $1->getName());

					handle_variable($1->getName());
				}
 		  | ID LTHIRD CONST_INT RTHIRD
				{
					string output = $1->getName()+ "[" + $3->getName()+"]";
					saveinStack(declaration_list,output);

					printTologFile("declaration_list : ID LTHIRD CONST_INT RTHIRD");
					printTextToLogfile( output);

					handle_array($1->getName(), $3->getName());

				}
			| declaration_list COMMA ID LTHIRD error RTHIRD //error recovery
				{
					string output = getfromStack(declaration_list)+","+$3->getName()+"["+"]";
					saveinStack(declaration_list,output);

					//print_error_recovery_mode("array index should be integer");
				}
			| ID LTHIRD error RTHIRD //error recovery
				{
					string output = $1->getName()+ "["+"]";
					saveinStack(declaration_list,output);

					//print_error_recovery_mode("array index should be integer");
				}
			| declaration_list COMMA error //error recovery
				{
					string output = getfromStack(declaration_list)+",";
					saveinStack(declaration_list,output);

					//print_error_recovery_mode("id missing after comma in declaration list");
				}
			| declaration_list error COMMA ID//error recovery
				{
					string output = getfromStack(declaration_list)+","+$4->getName();
					saveinStack(declaration_list,output);
					//print_error_recovery_mode("syntax error");
				}
			| declaration_list error COMMA ID LTHIRD CONST_INT RTHIRD //error recovery
				{
					string output = getfromStack(declaration_list)+","+$4->getName()+"["+$6->getName()+"]";
					saveinStack(declaration_list,output);
					//print_error_recovery_mode("syntax error");
				}
			| error COMMA ID //error recovery
				{
					string output = ","+$3->getName();
					saveinStack(declaration_list,output);
					//print_error_recovery_mode("syntax error");
				}
			| error COMMA ID LTHIRD CONST_INT RTHIRD//error recovery
			 	{
					string output = ","+$3->getName()+"["+$5->getName()+"]";
					saveinStack(declaration_list,output);
					//print_error_recovery_mode("syntax error");
				}
 		  ;

statements : statement
				{
					string output = getfromStack(statement);
					saveinStack(statements, output);

					printTologFile("statements : statement");
					printTextToLogfile( output);

				}
	   | statements statement
		 		{
					//cout<<"statements statements statement"<<endl;
					string output = getfromStack(statements) +getfromStack(statement);
					saveinStack(statements,output);

					printTologFile("statements : statements statement");
					printTextToLogfile( output);
				}
	   ;

statement : var_declaration
				{
					string output = getfromStack(var_declaration);
					saveinStack(statement, output);

					printTologFile("statement : var_declaration");
					printTextToLogfile( output);
				}
	  | expression_statement
				{
					string output = getfromStack(expression_statement);
					saveinStack(statement, output);

					printTologFile("statement : expression_statement");
					printTextToLogfile( output);
				}
	  | compound_statement
				{
					string output = getfromStack(compound_statement);
					saveinStack(statement, output);

					printTologFile("statement : compound_statement");
					printTextToLogfile( output);
					//cout<<"hi "<<line_count<<endl;
				}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
				{
					string output = "for ("+getfromStack(expression_statement)+getfromStack(expression_statement)+getfromStack(expression)+")"+getfromStack(statement);
					saveinStack(statement, output);

					printTologFile("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
					printTextToLogfile( output);
				}
	  | IF LPAREN expression RPAREN statement  %prec LOWER_THAN_ELSE
				{
					//cout<<"hi there "<<line_count<<endl;
					string output = "if ("+getfromStack(expression)+")"+getfromStack(statement);
					saveinStack(statement, output);

					printTologFile("statement : IF LPAREN expression RPAREN statement");
					printTextToLogfile( output);
				}
	  | IF LPAREN expression RPAREN statement ELSE statement
				{
					//cout<<"hi there else"<<line_count<<endl;
					string output = "if ("+getfromStack(expression)+")"+getfromStack(statement)+"else "+getfromStack(statement);
					saveinStack(statement, output);

					printTologFile("statement : IF LPAREN expression RPAREN statement ELSE statement");
					printTextToLogfile( output);
				}
	  | WHILE LPAREN expression RPAREN statement
				{
					string output = "while ("+getfromStack(expression)+")"+getfromStack(statement);
					saveinStack(statement, output);

					printTologFile("statement : WHILE LPAREN expression RPAREN statement");
					printTextToLogfile( output);
				}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
				{
					string output ="printf("+$3->getName()+");\n";
					saveinStack(statement, output);

					printTologFile("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
					printTextToLogfile( output);

					if($3!=NULL){
						SymbolInfo *t = symboltable->Look_up($3->getName());
						if(t==NULL){
							logfile<<"Error at line "<<line_count<<" : Undeclared variable "<<$3->getName()<<endl<<endl;
				    	errorfile<<"Error at line "<<line_count<<" : Undeclared variable "<<$3->getName()<<endl<<endl;
				    	syntax_error++;
						}
					}
				}
	  | RETURN expression SEMICOLON
				{
					string output = "return "+getfromStack(expression)+";\n";
					saveinStack(statement, output);

					printTologFile("statement : RETURN expression SEMICOLON");
					printTextToLogfile( output);

					if($2!=NULL) handle_func_return_type($2);
				}
		| RETURN expression error //error recovery
			{
				string output = "return "+getfromStack(expression)+"\n";
				saveinStack(statement, output);
				//print_error_recovery_mode("semicolon missing in return statement");
			}
		| PRINTLN LPAREN ID RPAREN error //error recovery
			{
				string output ="printf("+$3->getName()+")\n";
				saveinStack(statement, output);
				//print_error_recovery_mode("semicolon missing in the statement");
			}
		| IF LPAREN error RPAREN statement //error recovery
			{
				string output = "if()"+getfromStack(statement);
				saveinStack(statement, output);
				//print_error_recovery_mode("expression error in if statement");
			}
		| IF LPAREN expression error statement //error recovery
			{
				string output = "if("+getfromStack(expression)+getfromStack(statement);
				saveinStack(statement, output);
				//print_error_recovery_mode("RPAREN missing in if statement");
			}
		| error ELSE statement //error recovery
			{
				string output = "else "+getfromStack(statement);
				saveinStack(statement, output);
				//print_error_recovery_mode("else statement without if statement");
			}
		| WHILE LPAREN error RPAREN statement //error recovery
			{
				string output = "while()"+getfromStack(statement);
				saveinStack(statement, output);
				//print_error_recovery_mode("expression error in while statement");
			}
		| WHILE LPAREN expression error statement //error recovery
			{
				string output = "while("+getfromStack(expression)+""+getfromStack(statement);
				saveinStack(statement, output);
				//print_error_recovery_mode("RPAREN missing in while statement");
			}
		| FOR LPAREN expression_statement expression_statement error RPAREN statement //error recovery
			{
				string output = "for ("+getfromStack(expression_statement)+getfromStack(expression_statement)+" )"+getfromStack(statement);
				saveinStack(statement, output);
				//print_error_recovery_mode("expression error in for statement");
			}
		| FOR LPAREN expression_statement expression_statement expression error statement //error recovery
			{
				string output = "for ("+getfromStack(expression_statement)+getfromStack(expression_statement)+getfromStack(expression)+getfromStack(statement);
				saveinStack(statement, output);
				//print_error_recovery_mode("RPAREN MISSING in for statement");
			}
		| type_specifier ID LPAREN parameter_list RPAREN compound_statement //func_bonus
			{
				string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + getfromStack(parameter_list) + ")" + getfromStack(compound_statement);
				saveinStack(statement, output);

				print_error_recovery_mode("invalid scoping of the function definition");

				parameters.clear();
				paramTypeList.clear();
				//printTologFile("statement : type_specifier ID LPAREN parameter_list RPAREN compound_statement");
				//printTextToLogfile( output);
			}
		| type_specifier ID LPAREN RPAREN compound_statement //func_bonus
			{
				string output = getfromStack(type_specifier) + " " + $2->getName() + "()" + getfromStack(compound_statement);
				saveinStack(statement, output);

				print_error_recovery_mode("invalid scoping of the function definition");
				//printTologFile("statement : type_specifier ID LPAREN RPAREN compound_statement");
				//printTextToLogfile( output);
			}
		| type_specifier ID LPAREN parameter_list RPAREN SEMICOLON //func_bonus
			{
				string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + getfromStack(parameter_list) + ");\n";
				saveinStack(statement, output);

				print_error_recovery_mode("invalid scoping of the function declaration");

				parameters.clear();
				paramTypeList.clear();
			}
		| type_specifier ID LPAREN RPAREN SEMICOLON //func_bonus
			{
				string output = getfromStack(type_specifier) + " " + $2->getName() + "("  + ");\n";
				saveinStack(statement, output);

				print_error_recovery_mode("invalid scoping of the function declaration");

			}
	  ;

expression_statement 	: SEMICOLON
				{
					string output=";\n";
					saveinStack(expression_statement, output);

					printTologFile("expression_statement : SEMICOLON");
					printTextToLogfile( output);
				}
			| expression SEMICOLON
				{
					string output = getfromStack(expression) + ";\n";
					saveinStack(expression_statement, output);

					printTologFile("expression_statement : expression SEMICOLON");
					printTextToLogfile( output);
				}
			| expression error //error recovery
				{
					string output = getfromStack(expression) + "\n";
					saveinStack(expression_statement, output);
					//print_error_recovery_mode("semicolon missing in expression");
				}
			| error SEMICOLON //error recovery
				{
					string output = " ;\n";
					saveinStack(expression_statement, output);
					//print_error_recovery_mode("expression error");
				}
			;

variable : ID
				{
					string output = $1->getName();
					saveinStack(variable,output);

					printTologFile("variable : ID");
					printTextToLogfile( output);

					$$ = handle_var_ID($1);
				}
	 | ID LTHIRD expression RTHIRD
	 			{
					string output = $1->getName() + "[" + getfromStack(expression) + "]";
					saveinStack(variable,output);

					printTologFile("variable : ID LTHIRD expression RTHIRD");
					printTextToLogfile( output);

					SymbolInfo *temp = symboltable->Look_up($1->getName(), "ARRAY");

					if(temp==NULL){
						errorfile<<"Error at Line "<<line_count<<" : "<<$1->getName()<<" not an array"<<endl<<endl;
						logfile<<"Error at Line "<<line_count<<" : "<<$1->getName()<<" not an array"<<endl<<endl;
						syntax_error++;
					}
					if($3->getVariableDataType()=="FLOAT" || $3->getVariableDataType()=="VOID"){
						errorfile<<"Error at Line "<<line_count<<" : Expression inside third brackets not an integer"<<endl<<endl;
						logfile<<"Error at Line "<<line_count<<" : Expression inside third brackets not an integer"<<endl<<endl;
						syntax_error++;
					}

					$1->setArrayIndex($3->intArr[0]);

					$$ = $1;
				}
		| ID LTHIRD error RTHIRD //error recovery
				{
					string output = $1->getName() + "[" + "]";
					saveinStack(variable,output);
					//print_error_recovery_mode("array index should be integer");
				}
		| error LTHIRD expression RTHIRD //error recovery
				{
					string output =  "[" + getfromStack(expression) + "]";
					saveinStack(variable,output);
					//print_error_recovery_mode("array id missing");
				}
	 ;

expression : logic_expression
 				{
					string output = getfromStack(logic_expression);
					saveinStack(expression,output);

					printTologFile("expression : logic expression");
					printTextToLogfile( output);

					$$ = $1;
				}
	   | variable ASSIGNOP logic_expression
		 		{
					string output = getfromStack(variable) + "="+ getfromStack(logic_expression);
					saveinStack(expression,output);

					printTologFile("expression : variable ASSIGNOP logic_expression");
					printTextToLogfile( output);

					$$ = handle_assignop($1,$3);
				}
	   ;

logic_expression : rel_expression
				{
					string output = getfromStack(rel_expression);
					saveinStack(logic_expression, output);

					printTologFile("logic_expression : rel_expression");
					printTextToLogfile( output);

					if($1!=NULL){
						$1->intArr.push_back(0);
						$1->floatArr.push_back(0);
					}
					$$=$1;
				}
		 | rel_expression LOGICOP rel_expression
		 		{
					string output = getfromStack(rel_expression)+ $2->getName() + getfromStack(rel_expression);
					saveinStack(logic_expression, output);

					printTologFile("logic_expression : rel_expression LOGICOP rel_expression");
					printTextToLogfile( output);

					$$ = handle_relexp_logicop_relexp($1,$2,$3);
				}
		 ;

rel_expression	: simple_expression
				{
					string output = getfromStack(simple_expression);
					saveinStack(rel_expression, output);

					printTologFile("rel_expression : simple_expression");
					printTextToLogfile( output);

					if($1!=NULL){
						$1->intArr.push_back(0);
						$1->floatArr.push_back(0);
					}
					$$=$1;
				}
		| simple_expression RELOP simple_expression
				{
					string output = getfromStack(simple_expression) + $2->getName() + getfromStack(simple_expression);
					saveinStack(rel_expression, output);

					printTologFile("rel_expression : simple_expression RELOP simple_expression");
					printTextToLogfile( output);

					$$ = handle_simexp_relop_simexp($1,$2,$3);

				}
		;

simple_expression : term
				{
					string output = getfromStack(term);
					saveinStack(simple_expression, output);

					printTologFile("simple_expression : term");
					printTextToLogfile( output);

					if($1!=NULL){
						$1->intArr.push_back(0);
						$1->floatArr.push_back(0);
					}
					$$ = $1;
				}
		  | simple_expression ADDOP term
				{
					string output = getfromStack(simple_expression) + $2->getName() + getfromStack(term);
					saveinStack(simple_expression, output);

					printTologFile("simple_expression : simple_expression ADDOP term");
					printTextToLogfile( output);

					if($1!=NULL && $2!=NULL && $3!=NULL)
						$$ = handle_simexp_addop_term($1,$2,$3);
				}
		  ;

term :	unary_expression
				{
					string output = getfromStack(unary_expression);
					saveinStack(term, output);

					printTologFile("term : unary_expression");
					printTextToLogfile( output);
					if($1!=NULL){
						$1->intArr.push_back(0);
						$1->floatArr.push_back(0);
					}
					$$ = $1;
				}
     |  term MULOP unary_expression
		 		{
					string output = getfromStack(term) + $2->getName() + getfromStack(unary_expression);
					saveinStack(term, output);

					printTologFile("term : term MULOP unary_expression");
					printTextToLogfile( output);

					$$ = handle_term_mulop_unary_exp($1,$2,$3);
				}
     ;

unary_expression : ADDOP unary_expression
				{
					string output = $1->getName() + getfromStack(unary_expression);
					saveinStack(unary_expression, output);

					printTologFile("unary_expression : ADDOP unary_expression");
					printTextToLogfile( output);

					if($2!=NULL) $$ = handle_addop_unary_exp($1,$2);
				}
		 | NOT unary_expression
		 		{
					string output = "!" + getfromStack(unary_expression);
					saveinStack(unary_expression, output);

					printTologFile("unary_expression : NOT unary expression");
					printTextToLogfile( output);
					if($2!=NULL) $$ = handle_not_unary_exp($2);
				}
		 | factor
		 		{
					string output = getfromStack(factor);
					saveinStack(unary_expression, output);

					printTologFile("unary_expression : factor");
					printTextToLogfile( output);

					$$ = $1;
				}
		 ;

factor	: variable
				{
					string output = getfromStack(variable);
					saveinStack(factor, output);

					printTologFile("factor : variable");
					printTextToLogfile( output);
					$$ = $1;
				}
	| ID LPAREN argument_list RPAREN
				{
					string output = $1->getName() + "(" + getfromStack(argument_list) + ")";
					saveinStack(factor, output);

					printTologFile("factor : ID LPAREN argument_list RPAREN");
					printTextToLogfile(output);

					$1 = check_function($1);
					if($3!=NULL && $1!=NULL) check_func_arguements($1);

					parameters.clear();
					paramTypeList.clear();

					$$=$1;
					//cout<<"here "<<line_count<<" "<<$1->getIDType()<<" "<<$1->getName()<<endl;
				}
	| LPAREN expression RPAREN
				{
					string output = "(" + getfromStack(expression) + ")";
					saveinStack(factor, output);

					printTologFile("factor : LPAREN expression RPAREN");
					printTextToLogfile( output);

					$$ = $2;
				}
	| CONST_INT
				{
					string output = $1->getName();
					saveinStack(factor, output);

					printTologFile("factor : CONST_INT");
					printTextToLogfile( output);

					$1->setIDType("VARIABLE");
					$1->setVariableDataType("INT");
					$1->intArr.push_back(stoi($1->getName()));
					$$ = $1;


				}
	| CONST_FLOAT
				{
					string output = $1->getName();
					saveinStack(factor, output);

					printTologFile("factor : CONST_FLOAT");
					printTextToLogfile( output);

					$1->setIDType("VARIABLE");
					$1->setVariableDataType("FLOAT");
					$1->floatArr.push_back(stof($1->getName()));
					$$ = $1;

				}
	| variable INCOP
				{
					string output = getfromStack(variable) + $2->getName();
					saveinStack(factor, output);

					printTologFile("factor : variable INCOP");
					printTextToLogfile( output);

					SymbolInfo *temp1 = symboltable->Look_up($1->getName(),"VARIABLE");
					SymbolInfo *temp2 = symboltable->Look_up($1->getName(),"ARRAY");

					if(temp1==NULL && temp2==NULL){
						errorfile<<"Error at Line "<<line_count<<" : Undeclared Variable: "<<$1->getName()<<endl;
						logfile<<"Error at Line "<<line_count<<" : Undeclared Variable: "<<$1->getName()<<endl;
						syntax_error++;
					}
					else if((temp1!=NULL && temp1->getVariableDataType()=="VOID") || (temp2!=NULL && temp2->getVariableDataType()=="VOID")){
						errorfile<<"Error at Line "<<line_count<<" : Type Mismatch (void)"<<$1->getName()<<endl;
						logfile<<"Error at Line "<<line_count<<" : Type Mismatch (void)"<<$1->getName()<<endl;
						syntax_error++;
					}
					else{
						if($1->getIDType()=="VARIABLE"){
					    if($1->getVariableDataType()=="INT"){
					      if($2->getName()=="++"){
					        $1->intArr[0]=$1->intArr[0]+1;
					      }
					      else if($2->getName()=="--"){
					        $1->intArr[0]=$1->intArr[0]-1;
					      }
					    }
					    else if($1->getVariableDataType()=="FLOAT"){
					      if($2->getName()=="++"){
					        $1->floatArr[0]=$1->floatArr[0]+1;
					      }
					      else if($2->getName()=="--"){
					        $1->floatArr[0]=$1->floatArr[0]-1;
					      }
					    }
					  }
					  else if($1->getIDType()=="ARRAY"){
					    if($1->getVariableDataType()=="INT"){
					      if($2->getName()=="++"){
					        $1->intArr[$1->getArrayIndex()]+=1;
					      }
					      else if($2->getName()=="--"){
					        $1->intArr[$1->getArrayIndex()]-=1;
					      }
					    }
					    else if($1->getVariableDataType()=="FLOAT"){
					      if($2->getName()=="++"){
					        $1->floatArr[$1->getArrayIndex()]+=1;
					      }
					      else if($2->getName()=="--"){
					        $1->floatArr[$1->getArrayIndex()]-=1;
					      }
					    }
					  }

						$$ = $1;
					}

				}
	/* | variable DECOP{} */
	| LPAREN error %prec LOWER_THAN_RPAREN//error recovery
			{
				string output = "( ";
				saveinStack(factor, output);
				//print_error_recovery_mode("RPAREN missing");
			}

	| LPAREN error RPAREN //error recovery
				{
					string output = "( )";
					saveinStack(factor, output);
					//print_error_recovery_mode("expression missing");
				}
	| error CONST_INT //error recovery
			{
				string output = $2->getName();
				saveinStack(factor, output);
				//print_error_recovery_mode("syntax error");
			}
	| error CONST_FLOAT //error recovery
			{
				string output = $2->getName();
				saveinStack(factor, output);
				//print_error_recovery_mode("syntax error");
			}
	| error ID LPAREN argument_list RPAREN//error recovery
			{
				string output = $2->getName() + "(" + getfromStack(argument_list) + ")";
				saveinStack(factor, output);
				//print_error_recovery_mode("syntax error");
			}
	| error LPAREN expression RPAREN //error recovery
			{
				string output = "(" + getfromStack(expression) + ")";
				saveinStack(factor, output);
				//print_error_recovery_mode("syntax error");
			}
	;

argument_list : arguments
				{
					string output = getfromStack(arguments);
					saveinStack(argument_list, output);

					printTologFile("argument_list : arguments");
					printTextToLogfile( output);
					$$ = $1;
				}
			  |
				{
					string output = "";
					saveinStack(argument_list, output);

					printTologFile("argument_list : ");
					printTextToLogfile(output);
				}
			  ;

arguments : arguments COMMA logic_expression
				{
					string output = getfromStack(arguments) + "," + getfromStack(logic_expression);
					saveinStack(arguments, output);

					printTologFile("arguments : arguments COMMA logic_expression");
					printTextToLogfile( output);
					parameters.push_back($3);
				}
	     | logic_expression
				{
					string output = getfromStack(logic_expression);
					saveinStack(arguments, output);

					printTologFile("arguments : logic_expression");
					printTextToLogfile( output);

					parameters.push_back($1);
					$$ = $1;
				}
			| arguments COMMA error //error recovery
				{
					string output = getfromStack(arguments) + ", ";
					saveinStack(arguments, output);
					//print_error_recovery_mode("arguments missing after comma in function call");
				}
	      ;


%%
int main(int argc,char *argv[])
{
	FILE *fp;
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}


	logfile.open("log.txt");
	errorfile.open("error.txt");
	yyin=fp;
	yyparse();

	fclose(yyin);
	logfile.close();
	errorfile.close();
	return 0;
}
