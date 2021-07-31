%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "symboltable.h"
#include "asmUtils.h"
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
//%token<symbolvalue> program unit type_specifier declaration_list parameter_list func_definition func_declaration compound_statement statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor arguments argument_list var_declaration


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

						code_asmcode = getASMfromStack(program);

						if(!(error_count+syntax_error)) {
							initialASMcode();
							//optimizedCode<<code_asmcode;
						}
						//write your code in this block in all the similar blocks below
					}
	;

program : program unit
					{
						string output = getfromStack(program)+ getfromStack(unit);
						saveinStack(program, output);

						printTologFile("program : program unit");
						printTextToLogfile(output);

						$$ = new SymbolInfo();
						$$ = $1;
						$$->code = getASMfromStack(program)+getASMfromStack(unit);
						saveASMinStack(program, $$->code);

						//delete $1;
						//delete $2;
					}
	| unit
				 {
					 string output = getfromStack(unit);
					 saveinStack(program,output);

					 printTologFile("program : unit");
					 printTextToLogfile( output);

					 $$ = new SymbolInfo();
					 $$->code = getASMfromStack(unit);
					 saveASMinStack(program, $$->code);

					 //delete $1;
				 }
	;

unit : var_declaration
				{
					string output = getfromStack(var_declaration);
					saveinStack(unit,output);

					printTologFile("unit : var_declaration");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$->code = getASMfromStack(var_declaration);
					saveASMinStack(unit, $$->code);
					//delete $1;
				}
     | func_declaration
		 		{
					string output = getfromStack(func_declaration);
					saveinStack(unit,output);

					printTologFile("unit : func_declaration");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$->code = getASMfromStack(func_declaration);
					saveASMinStack(unit, $$->code);
					//delete $1;
				}
     | func_definition
		 		{
					string output = getfromStack(func_definition);
					saveinStack(unit, output);

					printTologFile("unit : func_definition");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$->code = getASMfromStack(func_definition);
					saveASMinStack(unit, $$->code);
					//delete $1;
				}
     ;

func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "(" + getfromStack(parameter_list) + ");\n";
					saveinStack(func_declaration,output);

					printTologFile("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
					printTextToLogfile( output);

					$$ = new SymbolInfo();

					handle_func_declaration($1->getVariableDataType(), $2->getName());
					paramTypeList.clear();
					parameters.clear();

					//delete $1;
					//delete $2;
					//delete $4;
				}
		| type_specifier ID LPAREN RPAREN SEMICOLON
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "();\n";
					saveinStack(func_declaration,output);

					printTologFile("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON");
					printTextToLogfile( output);

					$$ = new SymbolInfo();

					handle_func_declaration($1->getVariableDataType(), $2->getName());

					//delete $1;
					//delete $2;
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

					$$ = new SymbolInfo();
					$$->code = getASMfromStack(compound_statement);
					saveASMinStack(func_definition, $$->code);

					//delete $1;
					//delete $2;
					//delete $4;
					//delete $7;
				}
		| type_specifier ID LPAREN RPAREN
																		{handle_func_defination($1->getVariableDataType(),$2->getName());} compound_statement
				{
					string output = getfromStack(type_specifier) + " " + $2->getName() + "()" + getfromStack(compound_statement);
					saveinStack(func_definition, output);

					printTologFile("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$->code = getASMfromStack(compound_statement);
					saveASMinStack(func_definition, $$->code);

					//delete $1;
					//delete $2;
					//delete $6;
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

					$$ = new SymbolInfo();

					handle_func_parameter($3->getName(), $4->getName()); //adding type and id to parameters list as a SymbolInfo
					paramTypeList.push_back($3->getVariableDataType());

					if(tempSet){$$->setTempSymbol(tempVar); tempSet=false;}

					getASMfromStack(parameter_list);
					getASMfromStack(type_specifier);
					saveASMinStack(parameter_list, $$->code);

					//delete $1;
					//delete $3;
					//delete $4;
				}
		| parameter_list COMMA type_specifier
				{
					string output = getfromStack(parameter_list) + "," + getfromStack(type_specifier);
					saveinStack(parameter_list, output);

					printTologFile("parameter_list : parameter_list COMMA type_specifier");
					printTextToLogfile( output);

					$$ = new SymbolInfo();

					paramTypeList.push_back($3->getVariableDataType());

					getASMfromStack(parameter_list);
					getASMfromStack(type_specifier);
					saveASMinStack(parameter_list, $$->code);

					//delete $1;
					//delete $3;
				}
 		| type_specifier ID
				{
					string output = getfromStack(type_specifier) + " " + $2->getName();
					saveinStack(parameter_list, output);

					printTologFile("parameter_list : type_specifier ID");
					printTextToLogfile( output);

					$$ = new SymbolInfo();

					handle_func_parameter($1->getName(), $2->getName()); //adding type and id to parameters list as a SymbolInfo
					paramTypeList.push_back($1->getVariableDataType());

					if(tempSet){$$->setTempSymbol(tempVar); tempSet=false;}

					getASMfromStack(type_specifier);
					saveASMinStack(parameter_list, $$->code);

					//delete $1;
					//delete $2;
				}
		| type_specifier
				{
					string output = getfromStack(type_specifier);
					saveinStack(parameter_list, output);

					printTologFile("parameter_list : type_specifier");
					printTextToLogfile( output);

					$$ = new SymbolInfo();

					paramTypeList.push_back($1->getVariableDataType());

					getASMfromStack(type_specifier);
					saveASMinStack(parameter_list, $$->code);

					//delete $1;
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
													for(int i=0;i<parameters.size();i++) {symboltable->Insert(parameters[i]);current_function->ids.push_back(parameters[i]->getName()); current_function->tempids.push_back(parameters[i]->getTempSymbol());}
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

					$$ = new SymbolInfo();

					$$->code = getASMfromStack(statements);
					//cout<<line_count<<" "<<current_function->getName()<<endl
					if(current_function!=NULL && current_function->getName()!="main"){
						$$->code = handle_asm_function_code($$->code, current_function);
					}
					current_function=NULL;
					hasReturnStatement=false;
					
					saveASMinStack(compound_statement, $$->code);
					//delete $3;
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

					$$= new SymbolInfo();
					$$->code = "";

					//cout<<line_count<<" "<<current_function->getName()<<endl;
					current_function=NULL;

					saveASMinStack(compound_statement, $$->code);
				}
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON
				{
					string output = getfromStack(type_specifier) + " "+ getfromStack(declaration_list) + ";\n";
					saveinStack(var_declaration, output);

					printTologFile("var_declaration : type_specifier declaration_list SEMICOLON");
					printTextToLogfile( output);

					$$= new SymbolInfo();
					$$->code = getASMfromStack(type_specifier) + getASMfromStack(declaration_list);
					saveASMinStack(var_declaration, $$->code);

					//delete $1;
					//delete $2;
				}
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
					$$ = new SymbolInfo();
					SymbolInfo *s = new SymbolInfo();
					s->setName("int");
					s->setVariableDataType(datatype);
					$$ = s;

					saveinStack(type_specifier,s->getName());

					printTologFile("type_specifier : INT");
					printTextToLogfile( "int");

					$$->code = "";

					saveASMinStack(type_specifier, $$->code);
				}
 		| FLOAT
				{
					datatype = "FLOAT";
					$$ = new SymbolInfo();
					SymbolInfo *s = new SymbolInfo();
					s->setName("float");
					s->setVariableDataType(datatype);
					$$ = s;

					saveinStack(type_specifier,s->getName());

					printTologFile("type_specifier : FLOAT");
					printTextToLogfile( "float");

					$$->code = "";
					saveASMinStack(type_specifier, $$->code);
				}
 		| VOID
				{
					datatype = "VOID";
					$$ = new SymbolInfo();
					SymbolInfo *s = new SymbolInfo();
					s->setName("void");
					s->setVariableDataType(datatype);
					$$ = s;

					saveinStack(type_specifier,s->getName());

					printTologFile("type_specifier : VOID");
					printTextToLogfile( "void");

					$$->code = "";
					saveASMinStack(type_specifier, $$->code);
				}
 		;

declaration_list : declaration_list COMMA ID
				{
					string output = getfromStack(declaration_list)+","+$3->getName();
					saveinStack(declaration_list,output);

					printTologFile("declaration_list : declaration_list COMMA ID");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					handle_data($3->getName()); //adding var in data segment

					//$$ = $1;

					handle_variable($3->getName());

					getASMfromStack(declaration_list);
					saveASMinStack(declaration_list, $$->code);
					//delete $1;
					////delete $3;
				}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
				{
					string output = getfromStack(declaration_list)+","+$3->getName()+"["+$5->getName()+"]";
					saveinStack(declaration_list,output);

					printTologFile("declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					handle_data($3->getName(), true, "ARRAY", $5->getName()); //adding array var in data segment

					handle_array($3->getName(), $5->getName());

					//$$->code = $1->code;
					getASMfromStack(declaration_list);
					saveASMinStack(declaration_list, $$->code);

					//delete $1;
					////delete $3;
					//delete $5;
				}
 		  | ID
				{
					$$ = new SymbolInfo();
					$$ = $1;
					saveinStack(declaration_list,$1->getName());

					printTologFile("declaration_list : ID");
					printTextToLogfile( $1->getName());

					handle_data($1->getName()); //adding var in data segment
					//$$->code = $1->code;

					handle_variable($1->getName());
					saveASMinStack(declaration_list, $$->code);

					////delete $1;
				}
 		  | ID LTHIRD CONST_INT RTHIRD
				{
					string output = $1->getName()+ "[" + $3->getName()+"]";
					saveinStack(declaration_list,output);

					printTologFile("declaration_list : ID LTHIRD CONST_INT RTHIRD");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					handle_data($1->getName(),true, "ARRAY", $3->getName()); //adding array var in data segment
					//$$->code = $1->code;

					handle_array($1->getName(), $3->getName());
					saveASMinStack(declaration_list, $$->code);

					////delete $1;
					////delete $3;
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

					$$ = new SymbolInfo();
					$$=$1;
					//cout<<output<<"yo \n"<<$$->code;
					$$->code = getASMfromStack(statement);
					saveASMinStack(statements, $$->code);

					////delete $1;
				}
	   | statements statement
		 		{
					//cout<<"statements statements statement"<<endl;
					string output = getfromStack(statements) +getfromStack(statement);
					saveinStack(statements,output);

					printTologFile("statements : statements statement");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$=$1;
					$$->code=getASMfromStack(statements)+getASMfromStack(statement);
					//cout<<output<<"\n statements 1:\n"<<$1->code;
					//cout<<"\n statements 2:\n"<<$2->code;
					//cout<<"\n\n final \n"<<$$->code;

					saveASMinStack(statements, $$->code);

					////delete $1;
					////delete $2;
				}
	   ;

statement : var_declaration
				{
					string output = getfromStack(var_declaration);
					saveinStack(statement, output);

					printTologFile("statement : var_declaration");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$=$1;

					//$$->code="\n;"+output; //adding comment
					$$->code = getASMfromStack(var_declaration);
					//$$->code+=$1->code;
					//codefile<<"\n;"+output;//////delete it later
					saveASMinStack(statement, $$->code);

					////delete $1;
				}
	  | expression_statement
				{
					string output = getfromStack(expression_statement);
					saveinStack(statement, output);

					printTologFile("statement : expression_statement");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$=$1;
					replace(output.begin(), output.end(), '\n', ' ');
					$$->code="\n;"+output+"\n";
					$$->code+=getASMfromStack(expression_statement);

					//cout<<"here (statement: expression_statement):\n"<<$$->code;
					//codefile<<"\n;"+output;
					saveASMinStack(statement, $$->code);

					////delete $1;
				}
	  | compound_statement
				{
					string output = getfromStack(compound_statement);
					saveinStack(statement, output);

					printTologFile("statement : compound_statement");
					printTextToLogfile( output);
					//cout<<"hi "<<line_count<<endl;

					$$ = new SymbolInfo();
					$$=$1;
					replace( output.begin(), output.end(), '\n', ' ');
					$$->code="\n;"+output+"\n";
					$$->code += getASMfromStack(compound_statement);

					//codefile<<"\n;"+output;
					saveASMinStack(statement, $$->code);
					////delete $1;
				}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
				{
					string expst1 = getfromStack(expression_statement);
					string expst2 = getfromStack(expression_statement);
					string exp = getfromStack(expression);
					string st = getfromStack(statement);
					string output = "for ("+expst2+expst1+exp+")"+st;
					saveinStack(statement, output);

					printTologFile("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
					printTextToLogfile( output);

					replace( expst1.begin(), expst1.end(), '\n', ' ');
					replace( expst2.begin(), expst2.end(), '\n', ' ');
					replace( exp.begin(), exp.end(), '\n', ' ');
					replace( st.begin(), st.end(), '\n', ' ');

					output = "for ("+expst2+expst1+exp+")"+st;

					$$ = new SymbolInfo();
					$$=$3;
					$$->code="\n;"+output+"\n";
					string exp2code =getASMfromStack(expression_statement);//$4 cmp te use hocche. ei karone stack theke ber kore dilam
					$$->code += getASMfromStack(expression_statement);

					string label1 = newLabel();
					string label2 = newLabel();

					$$->code += label1+":\n"+ exp2code+"mov cx, "+$4->getTempSymbol()+"\n";
					$$->code += "cmp cx, 0\n je "+label2+"\n";
					$$->code += getASMfromStack(statement);
					$$->code += getASMfromStack(expression);
					$$->code += "jmp "+label1+"\n";
					$$->code += label2+": \n";

					//codefile<<"\n;"+output;
					saveASMinStack(statement, $$->code);

					////delete $3;
					////delete $4;
					////delete $5;
					////delete $7;
				}
	  | IF LPAREN expression RPAREN statement  %prec LOWER_THAN_ELSE
				{
					//cout<<"hi there "<<line_count<<endl;
					string exp = getfromStack(expression);
					string st = getfromStack(statement);
					string output = "if ("+exp+")"+st;
					saveinStack(statement, output);

					printTologFile("statement : IF LPAREN expression RPAREN statement");
					printTextToLogfile(output);

					replace( exp.begin(), exp.end(), '\n', ' ');
					replace( st.begin(), st.end(), '\n', ' ');
					output = "if ("+exp+")"+st;

					$$ = new SymbolInfo();
					$$=$3;

					$$->code="\n;"+output+"\n";

					$$->code+=getASMfromStack(expression);

					string label = newLabel();
					//cout<<"\n\nlabel in if "<<label<<"\n\n";
					$$->code += "mov ax, "+$3->getTempSymbol()+"\n";
					$$->code += "cmp ax, 0\n";
					$$->code += "je "+label+"\n";
					$$->code += getASMfromStack(statement);
					$$->code += label+":\n";

					//codefile<<"\n;"+output;
					saveASMinStack(statement, $$->code);

					////delete $3;
					////delete $5;
				}
	  | IF LPAREN expression RPAREN statement ELSE statement
				{
					//cout<<"hi there else"<<line_count<<endl;
					string exp = getfromStack(expression);
					string st = getfromStack(statement);
					string st2 = getfromStack(statement);

					string output = "if ("+exp+") "+st2+"else "+st;
					saveinStack(statement, output);

					printTologFile("statement : IF LPAREN expression RPAREN statement ELSE statement");
					printTextToLogfile( output);

					replace( exp.begin(), exp.end(), '\n', ' ');
					replace( st.begin(), st.end(), '\n', ' ');
					replace( st2.begin(), st2.end(), '\n', ' ');
					output = "if ("+exp+") "+st2+"else "+st;
					$$ = new SymbolInfo();
					$$=$3;

					$$->code="\n;"+output+"\n";

					$$->code+=getASMfromStack(expression);

					string label = newLabel();
					string label2 = newLabel();
					//cout<<"\n\nlabel in if else  "<<label<<"\n\n";
					//cout<<"\nfirst statement:\n"<<$5->code<<"\n\n";
					//cout<<"\nsecond statement:\n"<<$7->code<<"\n\n";

					string elseStatement = getASMfromStack(statement);
					string ifStatement = getASMfromStack(statement);

					$$->code += "mov ax, "+$3->getTempSymbol()+"\n";
					$$->code += "cmp ax, 0\n";
					$$->code += "je "+label+"\n";
					$$->code += ifStatement;
					$$->code += "\njmp "+label2+"\n";
					$$->code += label+":\n\t"+elseStatement+"\n";
					$$->code += label2+":\n";
					//codefile<<"\n;"+output;
					saveASMinStack(statement, $$->code);

					////delete $3;
					////delete $5;
					////delete $7;
				}
	  | WHILE LPAREN expression RPAREN statement
				{
					string exp = getfromStack(expression);
					string st = getfromStack(statement);

					string output = "while ("+exp+")"+st;
					saveinStack(statement, output);

					printTologFile("statement : WHILE LPAREN expression RPAREN statement");
					printTextToLogfile( output);

					replace( exp.begin(), exp.end(), '\n', ' ');
					replace( st.begin(), st.end(), '\n', ' ');
					output = "while ("+exp+")"+st;
					$$ = new SymbolInfo();
					$$=$3;
					$$->code="\n;"+output+"\n";
					//$$->code = "";//comment add korle eita ////delete
					string label1 = newLabel();
					string label2 = newLabel();

					$$->code +="\n"+label1+": \n";
					$$->code += getASMfromStack(expression);
					$$->code += "mov cx, "+$3->getTempSymbol()+"\n";
					$$->code += "cmp cx, 0\n je "+label2+"\n";
					$$->code += getASMfromStack(statement);
					$$->code += "jmp "+label1+"\n";
					$$->code += label2+":\n";

					//codefile<<"\n;"+output;
					saveASMinStack(statement, $$->code);

					////delete $3;
					////delete $5;
				}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
				{
					string output ="println("+$3->getName()+");\n";
					saveinStack(statement, output);

					printTologFile("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
					printTextToLogfile( output);

					$$= new SymbolInfo();
					$$->code="\n;"+output+"\n";
					$$->code += "mov ax, "+$3->getTempSymbol()+"\n";
					$$->code += "CALL OUTPUT_NUMBER\n";
					$$->code += asm_newline;

					//cout<<"println :\n"<<$$->code;
					//codefile<<"\n;"+output;

					if($3!=NULL){
						SymbolInfo *t = symboltable->Look_up($3->getName());
						if(t==NULL){
							logfile<<"Error at line "<<line_count<<" : Undeclared variable "<<$3->getName()<<endl<<endl;
				    	errorfile<<"Error at line "<<line_count<<" : Undeclared variable "<<$3->getName()<<endl<<endl;
				    	syntax_error++;
						}
					}
					saveASMinStack(statement, $$->code);
				}
	  | RETURN expression SEMICOLON
				{
					string exp = getfromStack(expression);
					string output = "return "+exp+";\n";
					saveinStack(statement, output);

					printTologFile("statement : RETURN expression SEMICOLON");
					printTextToLogfile( output);

					replace( exp.begin(), exp.end(), '\n', ' ');
					output = "return "+exp+";\n";

					hasReturnStatement = true;

					$$ = new SymbolInfo();
					if($2!=NULL) {
						//cout<<"here i am : "<<current_function->getName()<<endl;
						handle_func_return_type($2);
						$$=$2;
					}
					$$->code="\n;"+output+"\n";
					if(current_function->getName()!="main")
						{
							$$->code += getASMfromStack(expression);
							//$$->code += "\nPOP DX\nPOP CX\nPOP BX\nPOP AX\n";
							$$->code += "mov CX, "+$2->getTempSymbol()+"\n\n";
							/* for(int i=current_function->tempids.size()-1;i>=0;i--){
						    //cout<<"name : "<<func->ids[i]<<"  temp : "<<func->tempids[i]<<endl;
						    $$->code += "POP "+ current_function->tempids[i]+"\n";
						  } */
							$$->code += "\nPOP BP\n";
						  $$->code += "RET "+to_string(current_function->tempids.size()*2)+"\n";
						}
					//$$->code += "RET\n";
					//$$->code += current_function->getName()+" ENDP\n";

				//	codefile<<"\n;"+output;
				//cout<<"\n"<<line_count<<"\n"<<$$->code<<endl;
				saveASMinStack(statement, $$->code);
				//cout<<"yoyoyoyoy\n";
				//delete $2;
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

					$$= new SymbolInfo();
					$$->code="";
					saveASMinStack(expression_statement, $$->code);
				}
			| expression SEMICOLON
				{
					string output = getfromStack(expression) + ";\n";
					saveinStack(expression_statement, output);

					printTologFile("expression_statement : expression SEMICOLON");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$=$1;
					$$->code = getASMfromStack(expression);
					//cout<<"here (expression_statement) : \n"<<$$->code;

					saveASMinStack(expression_statement, $$->code);

					////delete $1;
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

					//$$ = new SymbolInfo();
					$$ = handle_var_ID($1);

					//$$->code=$1->code;

					$$->code="";

					saveASMinStack(variable, $$->code);
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

					$$ = new SymbolInfo();
					$$->setName($1->getName()); $$->setType($1->getType()); $$->setTempSymbol($1->getTempSymbol()); $$->setVariableDataType($1->getVariableDataType());
					$$->setArraySize($1->getArraySize()); $$->setArrayIndex($1->getArrayIndex()); $$->setIDType($1->getIDType());
					$$->intArr = $1->intArr;
					$$->floatArr = $1->floatArr;
					//$$ = $1;

					//cout<<"\nprinting in variable dollar dollar: "<<$$->getTempSymbol();
					//$$->code=$1->code+$3->code+"mov bx, " +$3->getTempSymbol() +"\nadd bx, bx\n";

					$$->code=getASMfromStack(expression)+"mov bx, " +$3->getTempSymbol() +"\nadd bx, bx\n";
					//cout<<"\n"<<line_count<<" printing in variable dollar 1: "<<$1->getTempSymbol()<<endl;
					saveASMinStack(variable, $$->code);

					////delete $3;
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

					$$ = new SymbolInfo();
					$$ = $1;
					$$->code = getASMfromStack(logic_expression);
					saveASMinStack(expression, $$->code);

					////delete $1;
				}
	   | variable ASSIGNOP logic_expression
		 		{
					string output = getfromStack(variable) + "="+ getfromStack(logic_expression);
					saveinStack(expression,output);

					printTologFile("expression : variable ASSIGNOP logic_expression");
					printTextToLogfile(output);
					//cout<<line_count<<" t1 : "<<$1->getName()<<" t3 : "<<$3->getName()<<endl;
					$$ = new SymbolInfo();
					$$ = handle_assignop($1,$3);

					$$->code = "\n; "+output+"\n";
					$$->code += getASMfromStack(logic_expression)+getASMfromStack(variable);
					//cout<<line_count<<" t1 : "<<$1->getTempSymbol()<<" t3 : "<<$3->getTempSymbol()<<endl;
					$$->code+="mov ax, "+$3->getTempSymbol()+"\n";
					if($1->getIDType()!="ARRAY"){
						//cout<<"here in ASSIGNOP var\t"<<line_count<<endl;
						$$->code+= "mov "+$1->getTempSymbol()+", ax\n";
					}

					else{
						//cout<<"here in ASSIGNOP array\t"<<line_count<<endl;

						$$->code+= "mov  "+$1->getTempSymbol()+"[bx], ax\n";
						//cout<<$$->code;
					}

					//cout<<"here (expression): "<<$$->code<<endl;
					saveASMinStack(expression, $$->code);

					////delete $1;
					////delete $3;
				}
	   ;

logic_expression : rel_expression
				{
					string output = getfromStack(rel_expression);
					saveinStack(logic_expression, output);

					printTologFile("logic_expression : rel_expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					if($1!=NULL){
						$1->intArr.push_back(0);
						$1->floatArr.push_back(0);
					}

					$$=$1;

					$$->code = getASMfromStack(rel_expression);
					saveASMinStack(logic_expression, $$->code);

					////delete $1;
				}
		 | rel_expression LOGICOP rel_expression
		 		{
					string output = getfromStack(rel_expression)+ $2->getName() + getfromStack(rel_expression);
					saveinStack(logic_expression, output);

					printTologFile("logic_expression : rel_expression LOGICOP rel_expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$ = handle_relexp_logicop_relexp($1,$2,$3);

					if($$==NULL) $$= new SymbolInfo();
					string secondRelExp = getASMfromStack(rel_expression);
					string firstRelExp = getASMfromStack(rel_expression);
					$$->code = "\n; "+output+"\n";
					$$->code += firstRelExp;
					$$->code += secondRelExp;
					$$->code += handle_logicop_code($1, $2, $3);
					if(tempSet) {$$->setTempSymbol(tempVar); tempSet=false;}
					saveASMinStack(logic_expression, $$->code);

					////delete $1;
					////delete $3;
				}
		 ;

rel_expression	: simple_expression
				{
					string output = getfromStack(simple_expression);
					saveinStack(rel_expression, output);

					printTologFile("rel_expression : simple_expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					if($1!=NULL){
						$1->intArr.push_back(0);
						$1->floatArr.push_back(0);
					}
					$$=$1;
					if($$==NULL) $$= new SymbolInfo();

					$$->code = getASMfromStack(simple_expression);
					saveASMinStack(rel_expression, $$->code);

					////delete $1;
				}
		| simple_expression RELOP simple_expression
				{
					string output = getfromStack(simple_expression) + $2->getName() + getfromStack(simple_expression);
					saveinStack(rel_expression, output);

					printTologFile("rel_expression : simple_expression RELOP simple_expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$ = handle_simexp_relop_simexp($1,$2,$3);


					string secondSimpleExp = getASMfromStack(simple_expression);
					string firstSimpleExp = getASMfromStack(simple_expression);
					$$->code = "\n; "+output+"\n";
					$$->code += firstSimpleExp;
					$$->code += secondSimpleExp;

					$$->code += handle_relop_code($1,$2,$3);
					if(tempSet) {$$->setTempSymbol(tempVar); tempSet=false;}

					saveASMinStack(rel_expression, $$->code);

					////delete $1;
					////delete $3;
				}
		;

simple_expression : term
				{
					string output = getfromStack(term);
					saveinStack(simple_expression, output);

					printTologFile("simple_expression : term");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					if($1!=NULL){
						$1->intArr.push_back(0);
						$1->floatArr.push_back(0);
					}
					$$ = $1;
					if($$==NULL) $$= new SymbolInfo();
					$$->code = getASMfromStack(term);
					saveASMinStack(simple_expression, $$->code);

					////delete $1;
				}
		  | simple_expression ADDOP term
				{
					string output = getfromStack(simple_expression) + $2->getName() + getfromStack(term);
					saveinStack(simple_expression, output);

					printTologFile("simple_expression : simple_expression ADDOP term");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					if($1!=NULL && $2!=NULL && $3!=NULL)
						$$ = handle_simexp_addop_term($1,$2,$3);

					$$->code = "\n; "+output+"\n";
					$$->code += getASMfromStack(simple_expression);
					$$->code += getASMfromStack(term);

					$$->code += handle_addop_code($1,$2,$3);
					if(tempSet) {$$->setTempSymbol(tempVar); tempSet=false;}

					saveASMinStack(simple_expression, $$->code);

					////delete $1;
					////delete $3;
				}
		  ;

term :	unary_expression
				{
					string output = getfromStack(unary_expression);
					saveinStack(term, output);

					printTologFile("term : unary_expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					if($1!=NULL){
						$1->intArr.push_back(0);
						$1->floatArr.push_back(0);
					}

					$$ = $1;
					if($$==NULL) $$= new SymbolInfo();
					$$->code = getASMfromStack(unary_expression);
					saveASMinStack(term, $$->code);
					//cout<<"term\n"<<$$->code<<endl;

					////delete $1;
				}
     |  term MULOP unary_expression
		 		{
					string output = getfromStack(term) + $2->getName() + getfromStack(unary_expression);
					saveinStack(term, output);

					printTologFile("term : term MULOP unary_expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$ = handle_term_mulop_unary_exp($1,$2,$3);

					$$->code = "\n; "+output+"\n";
					$$->code += getASMfromStack(term);
					$$->code += getASMfromStack(unary_expression);

					$$->code += handle_mulop_code($1,$2,$3);
					if(tempSet) {$$->setTempSymbol(tempVar); tempSet=false;}

					saveASMinStack(term, $$->code);

					////delete $1;
					////delete $3;
				}
     ;

unary_expression : ADDOP unary_expression
				{
					string output = $1->getName() + getfromStack(unary_expression);
					saveinStack(unary_expression, output);

					printTologFile("unary_expression : ADDOP unary_expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					if($2!=NULL) $$ = handle_addop_unary_exp($1,$2);

					if($$==NULL) $$= new SymbolInfo();
					if($1->getName()=="-"){
						$$->code = "\n; "+output+"\n";
						$$->code += handle_minus_exp_code($2);
						if(tempSet) {$$->setTempSymbol(tempVar); tempSet=false;}
					}
					getASMfromStack(unary_expression);
					saveASMinStack(unary_expression, $$->code);

					////delete $2;
				}
		 | NOT unary_expression
		 		{
					string output = "!" + getfromStack(unary_expression);
					saveinStack(unary_expression, output);

					printTologFile("unary_expression : NOT unary expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					if($2!=NULL) {
						$$ = handle_not_unary_exp($2);

						if($$==NULL) $$= new SymbolInfo();
						$$->code = "\n; "+output+"\n";
						$$->code += getASMfromStack(unary_expression);
						string temp=newTemp();
						$$->code+="mov ax, " + $2->getTempSymbol() + "\n";
						$$->code+="not ax\n";
						$$->code+="mov "+temp+", ax\n";
						$$->setTempSymbol(temp);
					}
					saveASMinStack(unary_expression, $$->code);

					////delete $2;
				}
		 | factor
		 		{
					string output = getfromStack(factor);
					saveinStack(unary_expression, output);

					printTologFile("unary_expression : factor");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$ = $1;
					if($$==NULL) $$= new SymbolInfo();
					$$->code = getASMfromStack(factor);
					saveASMinStack(unary_expression, $$->code);
					//cout<<"unary \n"<<$$->code<<endl;

					////delete $1;
				}
		 ;

factor	: variable
				{
					string output = getfromStack(variable);
					saveinStack(factor, output);

					printTologFile("factor : variable");
					printTextToLogfile( output);

					//$$ = new SymbolInfo();

					$$=$1;
					//cout<<"address : "<< &$$<<endl;
					//cout<<"address : "<< &$1<<endl;

					string t1 = $1->getTempSymbol();

					//cout<<line_count<<" factor :" << $1->getTempSymbol()<<"  "<<t1<<" "<<$$->getTempSymbol()<<endl;

					if($1->getIDType()=="VARIABLE"){//cout<<line_count<<" var : " <<$$->code<<endl;
																					}
					else if($1->getIDType()=="ARRAY"){

						string temp= newTemp();
						$$->code=getASMfromStack(variable)+"mov ax, " + $1->getTempSymbol()+"[bx]\n";
						$$->code+= "mov " + temp + ", ax\n";
						$$->setTempSymbol(temp);
						//cout<<line_count<<" factor :" << $1->getTempSymbol()<<"  "<<t1<<" "<<$$->getTempSymbol()<<endl;
						//codefile<<$$->code;
						//cout<<line_count<<" array : " <<$$->code<<endl;
					}

					//$1->setTempSymbol(t1);
					//cout<<line_count<<" factor :" << $1->getTempSymbol()<<"  "<<t1<<" "<<$$->getTempSymbol()<<endl;
					saveASMinStack(factor, $$->code);

					////delete $1;
				}
	| ID LPAREN argument_list RPAREN
				{
					string output = $1->getName() + "(" + getfromStack(argument_list) + ")";
					saveinStack(factor, output);

					printTologFile("factor : ID LPAREN argument_list RPAREN");
					printTextToLogfile(output);

					$$ = new SymbolInfo();
					$1 = check_function($1);
					if($3!=NULL && $1!=NULL) check_func_arguements($1);

					parameters.clear();
					paramTypeList.clear();

					$$=copySymbolInfo($$,$1);
					if($$==NULL) $$= new SymbolInfo();
					$$->code = "\n; "+output+"\n";
					//cout<<current_function->getName()<<" "<<$1->getName()<<endl;
					if(current_function!=NULL && current_function->getName() == $1->getName()){
						/* for(int i=0;i<current_function->tempids.size();i++){
					    $$->code  += "PUSH "+ current_function->tempids[i]+"\n";
					  } */

						$$->code += getASMfromStack(argument_list);
						$$->code += "CALL "+$1->getName()+"_procedure\n";

						for(int i=current_function->tempids.size()-1, j=0;i>=0;i--,j++){
					    //cout<<"name : "<<func->ids[i]<<"  temp : "<<func->tempids[i]<<endl;
					    $$->code += "mov ax, [BP+"+to_string(j*2+4)+"]\n";
					    $$->code += "mov "+current_function->tempids[i]+", ax\n";
					  }

						/* for(int i=current_function->tempids.size()-1;i>=0;i--){
							$$->code += "POP "+ current_function->tempids[i]+"\n";
						} */
					}
					else {
						$$->code += getASMfromStack(argument_list);
						$$->code += "CALL "+$1->getName()+"_procedure\n";
						}


					if($1!=NULL && $1->getFuncRetType()!="VOID") {
						string temp = newTemp();
						//$$->code += "POP "+ temp+"\n";
						$$->code += "mov "+temp+", cx\n";
						$$->setTempSymbol(temp);
					}
					//cout<<"\n\n function handle baki ase\n\n";
					//cout<<"here "<<line_count<<" "<<$1->getIDType()<<" "<<$1->getName()<<" "<<$1->getFuncRetType()<<endl;
					saveASMinStack(factor, $$->code);

					////delete $3;
				}
	| LPAREN expression RPAREN
				{
					string output = "(" + getfromStack(expression) + ")";
					saveinStack(factor, output);

					printTologFile("factor : LPAREN expression RPAREN");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$ = $2;
					if($$==NULL) $$= new SymbolInfo();
					$$->code = getASMfromStack(expression);
					saveASMinStack(factor, $$->code);

					////delete $2;
				}
	| CONST_INT
				{
					string output = $1->getName();
					saveinStack(factor, output);

					printTologFile("factor : CONST_INT");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$ = $1;
					$1->setIDType("VARIABLE");
					$1->setVariableDataType("INT");
					$1->intArr.push_back(stoi($1->getName()));

					string temp = newTemp();
					$$->code += "mov ax, "+$1->getName()+"\n";
					$$->code += "mov "+ temp + ", ax\n";
					$$->setTempSymbol(temp);

					saveASMinStack(factor, $$->code);
				}
	| CONST_FLOAT
				{
					string output = $1->getName();
					saveinStack(factor, output);

					printTologFile("factor : CONST_FLOAT");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					$$ = $1;
					$1->setIDType("VARIABLE");
					$1->setVariableDataType("FLOAT");
					$1->floatArr.push_back(stof($1->getName()));

					if($$==NULL) $$= new SymbolInfo();
					string temp = newTemp();
					$$->code += "mov ax, "+$1->getName()+"\n";
					$$->code += "mov "+ temp + ", ax\n";
					$$->setTempSymbol(temp);

					saveASMinStack(factor, $$->code);
				}
	| variable INCOP
				{
					string output = getfromStack(variable) + $2->getName();
					saveinStack(factor, output);

					printTologFile("factor : variable INCOP");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
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

						$$ = copySymbolInfo($$, $1);
					}


					//cout<<"\nhere in variable incop\n"<<endl;
					if($$==NULL) $$= new SymbolInfo();
					string temp = newTemp();
					$$->setTempSymbol(temp);

					$$->code = "\n; "+output+"\n";
					$$->code += getASMfromStack(variable);
					if($1->getIDType()!="ARRAY"){ //variable
						$$->code += "mov ax, "+$1->getTempSymbol()+"\n";
						$$->code += "mov "+$$->getTempSymbol()+", ax\n";
						if($2->getName()=="++") {$$->code +="inc ax\n";}
						else {$$->code += "dec ax\n";}
						$$->code += "mov "+$1->getTempSymbol()+", ax\n";
					}
					else{ //array
						//cout<<"\nhere in variable incop array\n"<<endl;
						$$->code+= "mov  ax, "+$1->getTempSymbol()+"[bx]\n";
						$$->code += "mov "+$$->getTempSymbol()+", ax\n";
						if($2->getName()=="++") {$$->code +="inc ax\n";}
						else {$$->code += "dec ax\n";}

						$$->code += "mov "+$1->getTempSymbol()+"[bx], ax\n";
						//cout<<$$->code;
					}

					saveASMinStack(factor, $$->code);

					////delete $1;
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

					$$ = new SymbolInfo();
					$$ = $1;
					$$->code = getASMfromStack(arguments);
					saveASMinStack(argument_list, $$->code);

					////delete $1;
				}
			  |
				{
					string output = "";
					saveinStack(argument_list, output);

					printTologFile("argument_list : ");
					printTextToLogfile(output);

					$$ = new SymbolInfo();
					saveASMinStack(argument_list, $$->code);
				}
			  ;

arguments : arguments COMMA logic_expression
				{
					string output = getfromStack(arguments) + "," + getfromStack(logic_expression);
					saveinStack(arguments, output);

					printTologFile("arguments : arguments COMMA logic_expression");
					printTextToLogfile( output);
					parameters.push_back($3);

					$$ = new SymbolInfo();
					if($$==NULL) $$= new SymbolInfo();
					$$->code = getASMfromStack(arguments)+getASMfromStack(logic_expression);
					$$->code += "PUSH " + $3->getTempSymbol()+"\n";

					saveASMinStack(arguments,$$->code);

					////delete $1;
					////delete $3;
				}
	     | logic_expression
				{
					string output = getfromStack(logic_expression);
					saveinStack(arguments, output);

					printTologFile("arguments : logic_expression");
					printTextToLogfile( output);

					$$ = new SymbolInfo();
					parameters.push_back($1);
					$$ = $1;

					$$->code = getASMfromStack(logic_expression);
					$$->code += "PUSH " + $1->getTempSymbol()+"\n";
					saveASMinStack(arguments,$$->code);

					////delete $1;
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

	codefile.open("code.asm");
	optimizedCode.open("optimized_code.asm");

	yyin=fp;
	yyparse();

	fclose(yyin);
	logfile.close();
	errorfile.close();
	return 0;
}
