#include<bits/stdc++.h>
using namespace std;


//saving code of non nonterminals in stack
stack<string> codepart[arguments+1];

void yyerror(char *s)
{
	//fprintf(stderr,"%s\n",s);
	err_line = line_count;
	cout<<"Error at line no "<<line_count<<" : "<<s<<" lexeme: "<<yytext<<endl;
	logfile<<"Error at line "<<line_count<<": "<<s<<endl<<endl;
	errorfile<<"Error at line "<<line_count<<": "<<s<<endl<<endl;
  syntax_error++;
	return;
}

void saveinStack(nonterminals nt, string str){
  //cout<<nt<<": "<<str<<endl;
  codepart[nt].push(str);
}



string getfromStack(nonterminals nt){
  string str =  codepart[nt].top();
  codepart[nt].pop();
  return str;
}


void printTologFile(string rule){
  logfile<<"Line "<<line_count<<": "<<rule <<endl<<endl;
}

void printTextToLogfile(string text){
  logfile<<text<<endl<<endl;
}

void print_error_recovery_mode(string msg){
  logfile<<"Error at line "<<line_count<<": "<<msg<<endl<<endl;
	errorfile<<"Error at line "<<line_count<<": "<<msg<<endl<<endl;
  syntax_error++;
}

SymbolInfo* copySymbolInfo(SymbolInfo *des, SymbolInfo *src){
	des->setName(src->getName());
	des->setType(src->getType());
	des->setTempSymbol(src->getTempSymbol());
	des->setFuncRetType(src->getFuncRetType());
	des->setFuncDefined(src->getFuncDefined());
	des->setVariableDataType(src->getVariableDataType());
	des->setIDType(src->getIDType());
	des->setArraySize(src->getArraySize());
	des->setArrayIndex(src->getArrayIndex());
	des->ids = src->ids;
	des->tempids = src->tempids;
	des->paramTypeList = src->paramTypeList;
	des->intArr = src->intArr;
	des->floatArr = src->floatArr;
	des->code = src->code;

	return des;
}


void insert_variable_to_table(string datatype, string name){
  SymbolInfo *s = new SymbolInfo(name,"ID");
  s->setVariableDataType(datatype);
  s->setIDType("VARIABLE");
  //cout<<"handle_variable func 91"<<endl;
	if(tempSet){s->setTempSymbol(tempVar); tempSet=false;}
  symboltable->Insert(s);
}


void handle_variable(string name){
  if(datatype=="VOID"){
		logfile<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl<<endl;
    errorfile<<"Error at line "<<line_count<<": Variable type cannot be void"<<endl<<endl;
    syntax_error++;
  }
  else{
    SymbolInfo *temp = symboltable->Look_up_cur_scope(name);
    if(temp==NULL){
			//cout<<"calling insert 105\n";
      insert_variable_to_table(datatype, name);
    }
    else{
      if(temp->getIDType()=="VARIABLE" || temp->getIDType()=="FUNCTION"){
        errorfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp->getName()<<endl<<endl;
				logfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp->getName()<<endl<<endl;
        syntax_error++;
      }
      else{
				//cout<<"calling insert 115\n";
        insert_variable_to_table(datatype, name);
      }
      //cout<<"\nalready variable defined check kora lagbe variable ar function e kina. array hoile error na \n";
    }
  }
}






void handle_array(string name, string arrsize){
  if(datatype=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(array data type can't be void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(array data type can't be void)"<<endl<<endl;
    syntax_error++;
    return;
  }
  else{
    SymbolInfo *temp = symboltable->Look_up(name, "ARRAY");
    if(temp==NULL){
      SymbolInfo *s = new SymbolInfo(name, "ID");
      s->setIDType("ARRAY");
      s->setVariableDataType(datatype);
      s->setArraySize(stoi(arrsize));
      s->setArrayIndex(0);
      if(datatype=="INT"){
        for(int i=0;i<stoi(arrsize);i++) s->intArr.push_back(0);
      }
      else if(datatype=="FLOAT"){
        for(int i=0;i<stoi(arrsize);i++) s->floatArr.push_back(0);
      }
			//cout<<"calling insert 149\n";
			if(tempSet){s->setTempSymbol(tempVar); tempSet=false;}
      symboltable->Insert(s);
    }
    else{
      errorfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp->getName()<<endl<<endl;
      syntax_error++;
    }
  }
}


bool search_in_parameter_list(string name){
	for(SymbolInfo *s:parameters){
		if(s->getName()==name){
			return true;
		}
	}
	return false;
}



void handle_func_parameter(string type, string name){
  //cout<<"datatype: "<<datatype<<"    type: "<<type<<" name: "<<name<<endl;
  if(datatype=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(parameter data type can't be void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(parameter data type can't be void)"<<endl<<endl;
    syntax_error++;
    return;
  }
	if(search_in_parameter_list(name)){
		errorfile<<"Error at line "<<line_count<<": Multiple declaration of "<<name<<" in parameter"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Multiple declaration of "<<name<<" in parameter"<<endl<<endl;
    syntax_error++;
    return;
	}

  SymbolInfo *s = new SymbolInfo(name,"ID");
  s->setVariableDataType(datatype);
  s->setIDType("VARIABLE");

	handle_data(name);
	if(tempSet){s->setTempSymbol(tempVar);}

	parameters.push_back(s);
}


void handle_func_declaration(string retType, string name){
  SymbolInfo *temp1 = symboltable->Look_up(name, "FUNCTION");
  SymbolInfo *temp2 = symboltable->Look_up(name, "VARIABLE");

  if(temp1==NULL && temp2==NULL){
    SymbolInfo *s = new SymbolInfo(name, "ID");
    s->setIDType("FUNCTION");
    s->setFuncRetType(retType);
    s->paramTypeList = paramTypeList;
		//cout<<"calling insert 203\n";
    symboltable->Insert(s);
    //symboltable->Print_All_ScopeTable();
  }
  else{
    if(temp1!=NULL) {
			errorfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp1->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp1->getName()<<endl<<endl;
		}
    else {
			errorfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp2->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp2->getName()<<endl<<endl;
		}
    syntax_error++;
  }
}






void handle_func_defination(string datatype, string name){
  SymbolInfo *temp1 = symboltable->Look_up(name, "FUNCTION");
  SymbolInfo *temp2 = symboltable->Look_up(name, "VARIABLE");

  if(temp1==NULL && temp2==NULL){
    SymbolInfo *s = new SymbolInfo(name, "ID");
    s->setIDType("FUNCTION");
    s->setFuncRetType(datatype);
    for(int i=0;i<parameters.size();i++){
			SymbolInfo *t = parameters[i];
      //s->parameterList.push_back(t);
      s->paramTypeList.push_back(parameters[i]->getVariableDataType());
    }
    s->setFuncDefined(true);
		//cout<<"calling insert 239\n";
    symboltable->Insert(s);
    current_function=s;
		//paramTypeList.clear();
		//parameters.clear();
    return;
  }
  else if(temp1!=NULL && !temp1->getFuncDefined()){
    if(datatype!=temp1->getFuncRetType()){
      errorfile<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<temp1->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Return type mismatch with function declaration in function "<<temp1->getName()<<endl<<endl;
      syntax_error++;
      return;
    }
    if(temp1->paramTypeList.size()!=parameters.size()){
      errorfile<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<temp1->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Total number of arguments mismatch with declaration in function "<<temp1->getName()<<endl<<endl;
      syntax_error++;
      return;
    }
    bool typemismatch=false;
		int i;
    for(i=0;i<parameters.size();i++){
      if(parameters[i]->getVariableDataType()!=temp1->paramTypeList[i]){
        typemismatch=true;
        break;
      }
    }
    if(typemismatch){
      errorfile<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<temp1->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<temp1->getName()<<endl<<endl;
      syntax_error++;
      return;
    }
    //temp1->parameterList = parameters;
    temp1->setFuncDefined(true);
    current_function=temp1;
  }
  else{
    if(temp1!=NULL){
			errorfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp1->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp1->getName()<<endl<<endl;
		}
    else {
			errorfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp2->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Multiple Declaration of "<<temp2->getName()<<endl<<endl;
		}
    syntax_error++;
  }
}





void handle_func_return_type(SymbolInfo *exp){
  if(current_function!=NULL && current_function->getIDType()=="FUNCTION" && exp->getVariableDataType()!=current_function->getFuncRetType()){
		if(current_function->getFuncRetType()=="FLOAT" && exp->getVariableDataType()=="INT"){
			current_function->floatArr.push_back(exp->intArr[0]);
		}
		else if(current_function->getFuncRetType()=="INT" && exp->getVariableDataType()=="FLOAT"){
			current_function->intArr.push_back(int(exp->floatArr[0]));
			errorfile<<"Error at line "<<line_count<<": Return type Mismatch of "<<current_function->getName()<<" (float is returning to int type)"<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Return type Mismatch of "<<current_function->getName()<<" (float is returning to int type)"<<endl<<endl;
	    syntax_error++;
	    return;
		}
		else{
			errorfile<<"Error at line "<<line_count<<": Return type Mismatch of "<<current_function->getName()<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Return type Mismatch of "<<current_function->getName()<<endl<<endl;
    	syntax_error++;
    	return;
		}
  }
  if(current_function!=NULL && current_function->getIDType()=="FUNCTION"){
    if(current_function->getFuncRetType()=="INT") current_function->intArr.push_back(exp->intArr[0]);
    else if(current_function->getFuncRetType()=="FLOAT") current_function->floatArr.push_back(exp->floatArr[0]);
  }
}

SymbolInfo* check_function(SymbolInfo *f){
	SymbolInfo *called_func = symboltable->Look_up(f->getName(),"FUNCTION");
  if(called_func==NULL){
    errorfile<<"Error at line "<<line_count<<": Undeclared function "<<f->getName()<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Undeclared function "<<f->getName()<<endl<<endl;
    syntax_error++;
    return NULL;
  }
	return called_func;
}


void check_func_arguements(SymbolInfo *f){
  //cout<<f->getName()<<endl;
  if(f==NULL){
    errorfile<<"Error at line "<<line_count<<": function Not defined "<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": function Not defined "<<endl<<endl;
    syntax_error++;
    return;
  }
  SymbolInfo *called_func = symboltable->Look_up(f->getName(),"FUNCTION");
  if(parameters.size()!=called_func->paramTypeList.size()){
    errorfile<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<f->getName()<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Total number of arguments mismatch in function "<<f->getName()<<endl<<endl;
    syntax_error++;
    return;
  }
  //cout<<"here i am 211   size "<<parameters.size()<<endl;
  bool typemismatch=false;
	int i;
  for(i=0;i<parameters.size();i++){
    //cout<<"line : "<<line_count<<" "<<f->getName()<<" caller type: "<<parameters[i]->getVariableDataType()<<" callee type: "<<called_func->paramTypeList[i]<<endl;
		string t1="";
		if(parameters[i]!=NULL) t1 = parameters[i]->getVariableDataType();
		string t2 = called_func->paramTypeList[i];
    if(parameters[i]!=NULL && t1!=t2){
			if(t1=="INT" && t2=="FLOAT"){
				continue;
			}
      typemismatch=true;
      break;
    }
  }
  //cout<<"here i am 2\n";
  if(typemismatch){
		errorfile<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<f->getName()<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": "<<i+1<<"th argument mismatch in function "<<f->getName()<<endl<<endl;
    syntax_error++;
    return;
  }
  //cout<<"here i am 5\n";
}








SymbolInfo* handle_var_ID(SymbolInfo *id){
  SymbolInfo *temp = symboltable->Look_up(id->getName());
  if(temp!=NULL && temp->getIDType()=="ARRAY"){
    errorfile<<"Error at line "<<line_count<<": Type mismatch, "<<temp->getName()<<" is an array"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type mismatch, "<<temp->getName()<<" is an array"<<endl<<endl;
    syntax_error++;
    return NULL;
  }

	if(temp!=NULL && temp->getIDType()=="FUNCTION"){
    errorfile<<"Error at line "<<line_count<<": Type mismatch, "<<temp->getName()<<" is a function"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type mismatch, "<<temp->getName()<<" is a function"<<endl<<endl;
    syntax_error++;
    return NULL;
  }

  if(temp==NULL){
    errorfile<<"Error at line "<<line_count<<": Undeclared Variable "<<id->getName()<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Undeclared Variable "<<id->getName()<<endl<<endl;
    syntax_error++;
    return NULL;
  }
  return temp;
}







SymbolInfo* handle_assignop(SymbolInfo *var, SymbolInfo *exp){

  if(var==NULL || exp==NULL) return NULL;

  string type1 = var->getVariableDataType();
  string type2 = exp->getVariableDataType();
  var->intArr.push_back(0);
  var->floatArr.push_back(0);

  //cout<<var->intArr[0]<<endl;
  //cout<<"id type: "<<var->getIDType()<<" "<<exp->getIDType()<<" var int 0: "<<exp->intArr[0]<<" "<<var->intArr[0]<<endl;

  if(type1=="VOID" || type2=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(assign operator can't take void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(assign operator can't take void)"<<endl<<endl;
    syntax_error++;
    return var;
  }


  if(exp->getIDType()=="FUNCTION"){
    string rettype = exp->getFuncRetType();
    if(rettype=="VOID"){
      errorfile<<"Error at line "<<line_count<<": Type Mismatch(assign operator can't take void. function return type is void)"<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Type Mismatch(assign operator can't take void. function return type is void)"<<endl<<endl;
      syntax_error++;
      return var;
    }
    if(rettype==type1){
      if(type1=="INT") var->intArr[0] = exp->intArr[0];
      else if(type1=="FLOAT") var->floatArr[0] = exp->floatArr[0];
    }
    else if(rettype=="INT" && type1=="FLOAT"){
      var->floatArr[0] = exp->intArr[0]*1.0;
    }
    else if(rettype=="FLOAT" && type1=="INT"){
      errorfile<<"Error at line "<<line_count<<": Type Mismatch(return type float is assigned to int type variable)"<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Type Mismatch(return type float is assigned to int type variable)"<<endl<<endl;
      syntax_error++;
      var->intArr[0] = exp->floatArr[0];
    }
  }

  else if(exp->getIDType()=="VARIABLE"){
    if(type1==type2){
      if(type1=="INT") var->intArr[0] = exp->intArr[0];
      else if(type1=="FLOAT") var->floatArr[0] = exp->floatArr[0];
    }
    else if(type1=="INT" && type2=="FLOAT"){
      errorfile<<"Error at line "<<line_count<<": Type Mismatch(float is assigned to int type variable)"<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Type Mismatch(float is assigned to int type variable)"<<endl<<endl;
      syntax_error++;
      var->intArr[0] = exp->floatArr[0];
    }
    else if(type1=="FLOAT" && type2=="INT"){
      var->floatArr[0] = exp->intArr[0]*1.0;
    }
  }

  else if(exp->getIDType()=="ARRAY"){
    if(type1==type2){
      if(type1=="INT") var->intArr[0] = exp->intArr[exp->getArrayIndex()];
      else if(type1=="FLOAT") var->floatArr[0] = exp->floatArr[exp->getArrayIndex()];
    }
    else if(type1=="INT" && type2=="FLOAT"){
      errorfile<<"Error at line "<<line_count<<": Type Mismatch(float is assigned to int type variable)"<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Type Mismatch(float is assigned to int type variable)"<<endl<<endl;
      syntax_error++;
      var->intArr[0] = exp->floatArr[exp->getArrayIndex()];
    }
    else if(type1=="FLOAT" && type2=="INT"){
      var->floatArr[0] = exp->intArr[exp->getArrayIndex()]*1.0;
    }
  }

  return var;
}








SymbolInfo* handle_addop_unary_exp(SymbolInfo *op, SymbolInfo *exp){
  if(exp->getVariableDataType()=="VOID" || exp->getFuncRetType()=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(void)"<<endl<<endl;
    syntax_error++;
    return NULL;
  }

  SymbolInfo *t = exp;
  if(op->getName()=="-"){
    if(exp->getIDType()=="VARIABLE"){
      if(exp->getVariableDataType()=="INT") t->intArr[0] = -exp->intArr[0];
      else if(exp->getVariableDataType()=="FLOAT") t->floatArr[0] = -exp->floatArr[0];
    }
    else if(exp->getIDType()=="ARRAY"){
      if(exp->getVariableDataType()=="INT") t->intArr[0] = -exp->intArr[exp->getArrayIndex()];
      else if(exp->getVariableDataType()=="FLOAT") t->floatArr[0] = -exp->floatArr[exp->getArrayIndex()];
    }
    else if(exp->getIDType()=="FUNCTION"){
      if(exp->getVariableDataType()=="INT") t->intArr[0] = -exp->intArr[0];
      else if(exp->getVariableDataType()=="FLOAT") t->floatArr[0] = -exp->floatArr[0];
    }
  }
  return t;
}



SymbolInfo* handle_not_unary_exp(SymbolInfo *exp){
  if(exp->getVariableDataType()=="VOID" || exp->getFuncRetType()=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(void)"<<endl<<endl;
    syntax_error++;
    return NULL;
  }

  SymbolInfo *t = new SymbolInfo();
  t->setIDType("VARIABLE");
  t->intArr.push_back(0);
  t->setVariableDataType("INT");

  if(exp->getIDType()=="VARIABLE"){
    if(exp->getVariableDataType()=="INT" && exp->intArr[0]==0) t->intArr[0] = 1;
    else if(exp->getVariableDataType()=="FLOAT" && exp->floatArr[0]==0) t->intArr[0] = 1;
  }
  else if(exp->getIDType()=="ARRAY"){
    if(exp->getVariableDataType()=="INT" && exp->intArr[exp->getArrayIndex()]==0) t->intArr[0] = 1;
    else if(exp->getVariableDataType()=="FLOAT" && exp->floatArr[exp->getArrayIndex()]==0) t->intArr[0] = 1;
  }
  else if(exp->getIDType()=="FUNCTION"){
    if(exp->getVariableDataType()=="INT" && exp->intArr[0]==0) t->intArr[0] = 1;
    else if(exp->getVariableDataType()=="FLOAT" && exp->floatArr[0]==0) t->intArr[0] = 1;
  }

  return t;
}





SymbolInfo *handle_ex_op_ex_function(SymbolInfo *e1, SymbolInfo *op, SymbolInfo *e2){
	SymbolInfo *t = new SymbolInfo();
  t->setIDType("VARIABLE");
  t->intArr.push_back(0);
  t->floatArr.push_back(0);

	if(e1->getVariableDataType()=="VOID" || e2->getVariableDataType()=="VOID" || e1->getFuncRetType()=="VOID" || e2->getFuncRetType()=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(simple expression or term type can't be void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(simple expression or term type can't be void)"<<endl<<endl;
    syntax_error++;
    return t;
  }

	if(e1->getIDType()=="VARIABLE"){
    if(e2->getIDType()=="FUNCTION"){
      if(e1->getVariableDataType()=="INT"){
        if(e2->getFuncRetType()=="INT"){
          t->setVariableDataType("INT");
          if(op->getName()=="+") t->intArr[0] = e1->intArr[0] + e2->intArr[0]; //var_int+var_int
          else if(op->getName()=="-") t->intArr[0] = e1->intArr[0] - e2->intArr[0]; //var_int-var_int
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[0] && e2->intArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[0] || e2->intArr[0];
        }
        else if(e2->getFuncRetType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(op->getName()=="+") t->floatArr[0] = e1->intArr[0] + e2->floatArr[0]; //var_int+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->intArr[0] - e2->floatArr[0]; //var_int-var_float
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[0] && e2->floatArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[0] || e2->floatArr[0];
        }
      }
      else if(e1->getVariableDataType()=="FLOAT"){
        if(e2->getFuncRetType()=="INT"){
          t->setVariableDataType("FLOAT");
          if(op->getName()=="+") t->floatArr[0] = e1->floatArr[0] + e2->intArr[0]; //var_float+var_int
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[0] - e2->intArr[0]; //var_float-var_int
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[0] && e2->intArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[0] || e2->intArr[0];
        }
        else if(e2->getFuncRetType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(op->getName()=="+") t->floatArr[0] = e1->floatArr[0] + e2->floatArr[0]; //var_float+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[0] - e2->floatArr[0]; //var_float-var_float
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[0] && e2->floatArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[0] || e2->floatArr[0];
        }
      }
    }
	}

	if(e1->getIDType()=="ARRAY"){
    if(e2->getIDType()=="FUNCTION"){
      if(e1->getVariableDataType()=="INT"){
        if(e2->getFuncRetType()=="INT"){
          t->setVariableDataType("INT");
          if(op->getName()=="+") t->intArr[0] = e1->intArr[e1->getArrayIndex()] + e2->intArr[0]; //var_int+var_int
          else if(op->getName()=="-") t->intArr[0] = e1->intArr[e1->getArrayIndex()] - e2->intArr[0]; //var_int-var_int
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[e1->getArrayIndex()] && e2->intArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[e1->getArrayIndex()] || e2->intArr[0];
        }
        else if(e2->getFuncRetType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(op->getName()=="+") t->floatArr[0] = e1->intArr[e1->getArrayIndex()] + e2->floatArr[0]; //var_int+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->intArr[e1->getArrayIndex()] - e2->floatArr[0]; //var_int-var_float
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[e1->getArrayIndex()] && e2->floatArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[e1->getArrayIndex()] || e2->floatArr[0];
        }
      }
      else if(e1->getVariableDataType()=="FLOAT"){
        if(e2->getFuncRetType()=="INT"){
          t->setVariableDataType("FLOAT");
          if(op->getName()=="+") t->floatArr[0] = e1->floatArr[e1->getArrayIndex()] + e2->intArr[0]; //var_float+var_int
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[e1->getArrayIndex()] - e2->intArr[0]; //var_float-var_int
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[e1->getArrayIndex()] && e2->intArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[e1->getArrayIndex()] || e2->intArr[0];
        }
        else if(e2->getFuncRetType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(op->getName()=="+") t->floatArr[0] = e1->floatArr[e1->getArrayIndex()] + e2->floatArr[0]; //var_float+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[e1->getArrayIndex()] - e2->floatArr[0]; //var_float-var_float
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[e1->getArrayIndex()] && e2->floatArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[e1->getArrayIndex()] || e2->floatArr[0];
        }
      }
    }
	}

	if(e1->getIDType()=="FUNCTION"){
		if(e2->getIDType()=="VARIABLE"){
			if(e1->getFuncRetType()=="INT"){
				if(e2->getVariableDataType()=="INT"){
					t->setVariableDataType("INT");
					if(op->getName()=="+") t->intArr[0] = e1->intArr[0] + e2->intArr[0]; //var_int+var_int
          else if(op->getName()=="-") t->intArr[0] = e1->intArr[0] - e2->intArr[0];
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[0] && e2->intArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[0] || e2->intArr[0];
				}
				else if(e2->getVariableDataType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->intArr[0] + e2->floatArr[0]; //var_int+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->intArr[0] - e2->floatArr[0];
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[0] && e2->floatArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[0] || e2->floatArr[0];
				}
			}
			else if(e1->getFuncRetType()=="FLOAT"){
				if(e2->getVariableDataType()=="INT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->floatArr[0] + e2->intArr[0]; //var_float+var_int
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[0] - e2->intArr[0];
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[0] && e2->intArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[0] || e2->intArr[0];
				}
				else if(e2->getVariableDataType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->floatArr[0] + e2->floatArr[0]; //var_float+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[0] - e2->floatArr[0];
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[0] && e2->floatArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[0] || e2->floatArr[0];
				}
			}
		}
		else if(e2->getIDType()=="ARRAY"){
			if(e1->getFuncRetType()=="INT"){
				if(e2->getVariableDataType()=="INT"){
					t->setVariableDataType("INT");
					if(op->getName()=="+") t->intArr[0] = e1->intArr[0] + e2->intArr[e2->getArrayIndex()]; //var_int+var_int
          else if(op->getName()=="-") t->intArr[0] = e1->intArr[0] - e2->intArr[e2->getArrayIndex()];
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[0] && e2->intArr[e2->getArrayIndex()];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[0] || e2->intArr[e2->getArrayIndex()];
				}
				else if(e2->getVariableDataType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->intArr[0] + e2->floatArr[e2->getArrayIndex()]; //var_int+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->intArr[0] - e2->floatArr[e2->getArrayIndex()];
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[0] && e2->floatArr[e2->getArrayIndex()];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[0] || e2->floatArr[e2->getArrayIndex()];
				}
			}
			else if(e1->getFuncRetType()=="FLOAT"){
				if(e2->getVariableDataType()=="INT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->floatArr[0] + e2->intArr[e2->getArrayIndex()]; //var_float+var_int
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[0] - e2->intArr[e2->getArrayIndex()];
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[0] && e2->intArr[e2->getArrayIndex()];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[0] || e2->intArr[e2->getArrayIndex()];
				}
				else if(e2->getVariableDataType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->floatArr[0] + e2->floatArr[e2->getArrayIndex()]; //var_float+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[0] - e2->floatArr[e2->getArrayIndex()];
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[0] && e2->floatArr[e2->getArrayIndex()];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[0] || e2->floatArr[e2->getArrayIndex()];
				}
			}
		}
		else if(e2->getIDType()=="FUNCTION"){
			if(e1->getFuncRetType()=="INT"){
				if(e2->getFuncRetType()=="INT"){
					t->setVariableDataType("INT");
					if(op->getName()=="+") t->intArr[0] = e1->intArr[0] + e2->intArr[0]; //var_int+var_int
          else if(op->getName()=="-") t->intArr[0] = e1->intArr[0] - e2->intArr[0];
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[0] && e2->intArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[0] || e2->intArr[0];
				}
				else if(e2->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->intArr[0] + e2->floatArr[0]; //var_int+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->intArr[0] - e2->floatArr[0];
					else if(op->getName()=="&&") t->intArr[0] = e1->intArr[0] && e2->floatArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->intArr[0] || e2->floatArr[0];
				}
			}
			else if(e1->getFuncRetType()=="FLOAT"){
				if(e2->getFuncRetType()=="INT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->floatArr[0] + e2->intArr[0]; //var_float+var_int
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[0] - e2->intArr[0];
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[0] && e2->intArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[0] || e2->intArr[0];
				}
				else if(e2->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					if(op->getName()=="+") t->floatArr[0] = e1->floatArr[0] + e2->floatArr[0]; //var_float+var_float
          else if(op->getName()=="-") t->floatArr[0] = e1->floatArr[0] - e2->floatArr[0];
					else if(op->getName()=="&&") t->intArr[0] = e1->floatArr[0] && e2->floatArr[0];
					else if(op->getName()=="||") t->intArr[0] = e1->floatArr[0] || e2->floatArr[0];
				}
			}
		}
	}
	if(op->getName()=="&&" || op->getName()=="||") t->setVariableDataType("INT");
	 return t;

 }




SymbolInfo* handle_simexp_relop_simexp(SymbolInfo *exp1, SymbolInfo *relop, SymbolInfo *exp2){
  SymbolInfo *t = new SymbolInfo();
  t->setIDType("VARIABLE");
  t->intArr.push_back(0);
  t->setVariableDataType("INT");

  //cout<<"exp 1 id type: "<<exp1->getIDType()<<"   exp2 id type: "<<exp2->getIDType()<<endl;
  string type1 = exp1->getVariableDataType();
  string type2 = exp2->getVariableDataType();

  if(type1=="VOID" || type2=="VOID"||exp1->getFuncRetType()=="VOID" || exp2->getFuncRetType()=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(can't compare void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(can't compare void)"<<endl<<endl;
    syntax_error++;
    return t;
  }

  if(relop->getName()=="<" || relop->getName()=="<="){
    if(exp1->getIDType()=="VARIABLE"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]<exp2->intArr[0]) t->intArr[0]=1;
            else if(exp1->intArr[0]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]<exp2->floatArr[0]) t->intArr[0]=1;
            else if(exp1->intArr[0]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]<exp2->intArr[0]) t->intArr[0]=1;
            else if(exp1->floatArr[0]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]<exp2->floatArr[0]) t->intArr[0]=1;
            else if(exp1->floatArr[0]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]<exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->intArr[0]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]<exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->intArr[0]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]<exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->floatArr[0]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]<exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->floatArr[0]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
    else if(exp1->getIDType()=="ARRAY"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]<exp2->intArr[0]) t->intArr[0]=1;
            else if(exp1->intArr[exp1->getArrayIndex()]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]<exp2->floatArr[0]) t->intArr[0]=1;
            else if(exp1->intArr[exp1->getArrayIndex()]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]<exp2->intArr[0]) t->intArr[0]=1;
            else if(exp1->floatArr[exp1->getArrayIndex()]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]<exp2->floatArr[0]) t->intArr[0]=1;
            else if(exp1->floatArr[exp1->getArrayIndex()]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]<exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->intArr[exp1->getArrayIndex()]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]<exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->intArr[exp1->getArrayIndex()]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]<exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->floatArr[exp1->getArrayIndex()]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]<exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->floatArr[exp1->getArrayIndex()]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
  }
  else if(relop->getName()==">" || relop->getName()==">="){
    if(exp1->getIDType()=="VARIABLE"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]>exp2->intArr[0]) t->intArr[0]=1;
            else if(exp1->intArr[0]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]>exp2->floatArr[0]) t->intArr[0]=1;
            else if(exp1->intArr[0]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]>exp2->intArr[0]) t->intArr[0]=1;
            else if(exp1->floatArr[0]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]>exp2->floatArr[0]) t->intArr[0]=1;
            else if(exp1->floatArr[0]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]>exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->intArr[0]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]>exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->intArr[0]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]>exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->floatArr[0]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]>exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->floatArr[0]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
    else if(exp1->getIDType()=="ARRAY"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]>exp2->intArr[0]) t->intArr[0]=1;
            else if(exp1->intArr[exp1->getArrayIndex()]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]>exp2->floatArr[0]) t->intArr[0]=1;
            else if(exp1->intArr[exp1->getArrayIndex()]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]>exp2->intArr[0]) t->intArr[0]=1;
            else if(exp1->floatArr[exp1->getArrayIndex()]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]>exp2->floatArr[0]) t->intArr[0]=1;
            else if(exp1->floatArr[exp1->getArrayIndex()]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]>exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->intArr[exp1->getArrayIndex()]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]>exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->intArr[exp1->getArrayIndex()]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]>exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->floatArr[exp1->getArrayIndex()]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]>exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
            else if(exp1->floatArr[exp1->getArrayIndex()]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
  }
  else if(relop->getName()=="=="){
    if(exp1->getIDType()=="VARIABLE"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
    else if(exp1->getIDType()=="ARRAY"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]==exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]==exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]==exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]==exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
  }
  else if(relop->getName()=="!="){
    if(exp1->getIDType()=="VARIABLE"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]!=exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]!=exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]!=exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]!=exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]!=exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]!=exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]!=exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]!=exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
    else if(exp1->getIDType()=="ARRAY"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]!=exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]!=exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]!=exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]!=exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]!=exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]!=exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]!=exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]!=exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
  }

  return t;
}














SymbolInfo* handle_relexp_logicop_relexp(SymbolInfo *exp1,SymbolInfo *logiop, SymbolInfo *exp2){
  string type1 = exp1->getVariableDataType();
  string type2 = exp2->getVariableDataType();
	//cout<<line_count<<" "<<exp2->getName()<<" "<<exp2->getIDType()<<endl;
  SymbolInfo *t = new SymbolInfo();
  t->setIDType("VARIABLE");
  t->setVariableDataType("INT");
  t->intArr.push_back(0);

  if(type1=="VOID" || type2=="VOID" || exp1->getFuncRetType()=="VOID" || exp2->getFuncRetType()=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(logic expression type can't be void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(logic expression type can't be void)"<<endl<<endl;
    syntax_error++;
    return t;
  }

	if(exp1->getIDType()=="FUNCTION" || exp2->getIDType()=="FUNCTION"){
		return handle_ex_op_ex_function(exp1,logiop,exp2);
	}

  if(logiop->getName()=="&&"){
    if(exp1->getIDType()=="VARIABLE"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0] && exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]&&exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]&&exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]&&exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0]&&exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0]&&exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0]&&exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0]&&exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
    else if(exp1->getIDType()=="ARRAY"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]&&exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]&&exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]&&exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]&&exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()]&&exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()]&&exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()]&&exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()]&&exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
  }

  else if(logiop->getName()=="||"){
    if(exp1->getIDType()=="VARIABLE"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0] || exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0] || exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0] || exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0] || exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[0] || exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[0] || exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[0] || exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[0] || exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
    else if(exp1->getIDType()=="ARRAY"){
      if(exp2->getIDType()=="VARIABLE"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()] || exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()] || exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()] || exp2->intArr[0]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()] || exp2->floatArr[0]) t->intArr[0]=1;
          }
        }
      }
      else if(exp2->getIDType()=="ARRAY"){
        if(type1=="INT"){
          if(type2=="INT"){
            if(exp1->intArr[exp1->getArrayIndex()] || exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->intArr[exp1->getArrayIndex()] || exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
        else if(type1=="FLOAT"){
          if(type2=="INT"){
            if(exp1->floatArr[exp1->getArrayIndex()] || exp2->intArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
          else if(type2=="FLOAT"){
            if(exp1->floatArr[exp1->getArrayIndex()] || exp2->floatArr[exp2->getArrayIndex()]) t->intArr[0]=1;
          }
        }
      }
    }
  }
  return t;
}





SymbolInfo* handle_simexp_addop_term(SymbolInfo *exp, SymbolInfo *addop, SymbolInfo *ter){
  SymbolInfo *t = new SymbolInfo();
  t->setIDType("VARIABLE");
  t->intArr.push_back(0);
  t->floatArr.push_back(0);

	//cout<<line_count<<" "<< exp->getIDType()<<" "<<ter->getIDType()<<endl;

  if(exp->getVariableDataType()=="VOID" || ter->getVariableDataType()=="VOID" || exp->getFuncRetType()=="VOID" || ter->getFuncRetType()=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type Mismatch(simple expression or term type can't be void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type Mismatch(simple expression or term type can't be void)"<<endl<<endl;
    syntax_error++;
    return t;
  }

	if(exp==NULL || addop==NULL || ter == NULL) return t;

	if(exp->getIDType()=="FUNCTION" || ter->getIDType()=="FUNCTION"){
		return handle_ex_op_ex_function(exp,addop,ter);
	}

  if(ter->getIDType()=="VARIABLE"){
    if(exp->getIDType()=="VARIABLE"){
      if(ter->getVariableDataType()=="INT"){
        if(exp->getVariableDataType()=="INT"){
          t->setVariableDataType("INT");
          if(addop->getName()=="+") t->intArr[0] = ter->intArr[0] + exp->intArr[0]; //var_int+var_int
          else t->intArr[0] = ter->intArr[0] - exp->intArr[0]; //var_int-var_int
        }
        else if(exp->getVariableDataType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->intArr[0] + exp->floatArr[0]; //var_int+var_float
          else t->floatArr[0] = ter->intArr[0] - exp->floatArr[0]; //var_int-var_float
        }
      }
      else if(ter->getVariableDataType()=="FLOAT"){
        if(exp->getVariableDataType()=="INT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->floatArr[0] + exp->intArr[0]; //var_float+var_int
          else t->floatArr[0] = ter->floatArr[0] - exp->intArr[0]; //var_float-var_int
        }
        else if(exp->getVariableDataType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->floatArr[0] + exp->floatArr[0]; //var_float+var_float
          else t->floatArr[0] = ter->floatArr[0] - exp->floatArr[0]; //var_float-var_float
        }
      }
    }
    else if(exp->getIDType()=="ARRAY"){
      if(ter->getVariableDataType()=="INT"){
        if(exp->getVariableDataType()=="INT"){
          t->setVariableDataType("INT");
          if(addop->getName()=="+") t->intArr[0] = ter->intArr[0] + exp->intArr[exp->getArrayIndex()]; //var_int+arr_int
          else t->intArr[0] = ter->intArr[0] - exp->intArr[exp->getArrayIndex()]; //var_int-arr_int
        }
        else if(exp->getVariableDataType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->intArr[0] + exp->floatArr[exp->getArrayIndex()]; //var_int+arr_float
          else t->floatArr[0] = ter->intArr[0] - exp->floatArr[exp->getArrayIndex()]; //var_int-arr_float
        }
      }
      else if(ter->getVariableDataType()=="FLOAT"){
        if(exp->getVariableDataType()=="INT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->floatArr[0] + exp->intArr[exp->getArrayIndex()]; //var_float+arr_int
          else t->floatArr[0] = ter->floatArr[0] - exp->intArr[exp->getArrayIndex()]; //var_float-arr_int
        }
        else if(exp->getVariableDataType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->floatArr[0] + exp->floatArr[exp->getArrayIndex()]; //var_float+arr_float
          else t->floatArr[0] = ter->floatArr[0] - exp->floatArr[exp->getArrayIndex()]; //var_float-arr_float
        }
      }

    }
  }
  else if(ter->getIDType()=="ARRAY"){
    if(exp->getIDType()=="VARIABLE"){
      if(ter->getVariableDataType()=="INT"){
        if(exp->getVariableDataType()=="INT"){
          t->setVariableDataType("INT");
          if(addop->getName()=="+") t->intArr[0] = ter->intArr[ter->getArrayIndex()] + exp->intArr[0]; //arr_int+var_int
          else t->intArr[0] = ter->intArr[ter->getArrayIndex()] - exp->intArr[0]; //arr_int-var_int
        }
        else if(exp->getVariableDataType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->intArr[ter->getArrayIndex()] + exp->floatArr[0]; //arr_int+var_float
          else t->floatArr[0] = ter->intArr[ter->getArrayIndex()] - exp->floatArr[0]; //arr_int-var_float
        }
      }
      else if(ter->getVariableDataType()=="FLOAT"){
        if(exp->getVariableDataType()=="INT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] + exp->intArr[0]; //arr_float+var_int
          else t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] - exp->intArr[0]; //arr_float-var_int
        }
        else if(exp->getVariableDataType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] + exp->floatArr[0]; //arr_float+var_float
          else t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] - exp->floatArr[0]; //arr_float-var_float
        }
      }

    }
    else if(exp->getIDType()=="ARRAY"){
      if(ter->getVariableDataType()=="INT"){
        if(exp->getVariableDataType()=="INT"){
          t->setVariableDataType("INT");
          if(addop->getName()=="+") t->intArr[0] = ter->intArr[ter->getArrayIndex()] + exp->intArr[exp->getArrayIndex()]; //arr_int+arr_int
          else t->intArr[0] = ter->intArr[ter->getArrayIndex()] - exp->intArr[exp->getArrayIndex()]; //arr_int-arr_int
        }
        else if(exp->getVariableDataType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->intArr[ter->getArrayIndex()] + exp->floatArr[exp->getArrayIndex()]; //arr_int+arr_float
          else t->floatArr[0] = ter->intArr[ter->getArrayIndex()] - exp->floatArr[exp->getArrayIndex()]; //arr_int-arr_float
        }
      }
      else if(ter->getVariableDataType()=="FLOAT"){
        if(exp->getVariableDataType()=="INT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] + exp->intArr[exp->getArrayIndex()]; //arr_float+arr_int
          else t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] - exp->intArr[exp->getArrayIndex()]; //arr_float-arr_int
        }
        else if(exp->getVariableDataType()=="FLOAT"){
          t->setVariableDataType("FLOAT");
          if(addop->getName()=="+") t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] + exp->floatArr[exp->getArrayIndex()]; //arr_float+arr_float
          else t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] - exp->floatArr[exp->getArrayIndex()]; //arr_float-arr_float
        }
      }

    }
  }

  return t;
}





void print_divide_by_zero(){
		errorfile<<"Error at line "<<line_count<<": Divide by Zero"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Divide by Zero"<<endl<<endl;
		syntax_error++;
}








SymbolInfo* handle_term_mulop_unary_exp(SymbolInfo *ter, SymbolInfo *mulop, SymbolInfo *exp){
  SymbolInfo *t = new SymbolInfo();
  t->setIDType("VARIABLE");
  t->intArr.push_back(0);
  t->floatArr.push_back(0);

  if(exp->getVariableDataType()=="VOID" || ter->getVariableDataType()=="VOID" || exp->getFuncRetType()=="VOID" || ter->getFuncRetType()=="VOID"){
    errorfile<<"Error at line "<<line_count<<": Type mismatch(unary expression or term type can't be void)"<<endl<<endl;
		logfile<<"Error at line "<<line_count<<": Type mismatch(unary expression or term type can't be void)"<<endl<<endl;
    syntax_error++;
    return t;
  }

  //cout<<"\n ter: "<<ter->getName()<<endl;
	ter->intArr.push_back(0);
	ter->floatArr.push_back(0);
	exp->intArr.push_back(0);
	exp->floatArr.push_back(0);

  if(mulop->getName()=="*"){
    if(ter->getIDType()=="VARIABLE"){
      if(exp->getIDType()=="VARIABLE"){
        if(ter->getVariableDataType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            t->intArr[0] = ter->intArr[0] * exp->intArr[0]; //var_int*var_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->intArr[0] * exp->floatArr[0]; //var_int*var_float
          }
        }
        else if(ter->getVariableDataType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[0] * exp->intArr[0]; //var_float*var_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[0] * exp->floatArr[0]; //var_float*var_float
          }
        }
      }
      else if(exp->getIDType()=="ARRAY"){
        if(ter->getVariableDataType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            t->intArr[0] = ter->intArr[0] * exp->intArr[exp->getArrayIndex()]; //var_int*arr_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->intArr[0] * exp->floatArr[exp->getArrayIndex()]; //var_int*arr_float
          }
        }
        else if(ter->getVariableDataType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[0] * exp->intArr[exp->getArrayIndex()]; //var_float*arr_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[0] * exp->floatArr[exp->getArrayIndex()]; //var_float*arr_float
          }
        }

      }
		else if(exp->getIDType()=="FUNCTION"){
			if(ter->getVariableDataType()=="INT"){
				if(exp->getFuncRetType()=="INT"){
					t->setVariableDataType("INT");
					t->intArr[0] = ter->intArr[0] * exp->intArr[0]; //var_int*var_int
				}
				else if(exp->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->intArr[0] * exp->floatArr[0]; //var_int*var_float
				}
			}
			else if(ter->getVariableDataType()=="FLOAT"){
				if(exp->getFuncRetType()=="INT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->floatArr[0] * exp->intArr[0]; //var_float*var_int
				}
				else if(exp->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->floatArr[0] * exp->floatArr[0]; //var_float*var_float
				}
			}
		}
    }
    else if(ter->getIDType()=="ARRAY"){
      if(exp->getIDType()=="VARIABLE"){
        if(ter->getVariableDataType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            t->intArr[0] = ter->intArr[ter->getArrayIndex()] * exp->intArr[0]; //arr_int*var_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->intArr[ter->getArrayIndex()] * exp->floatArr[0]; //arr_int*var_float
          }
        }
        else if(ter->getVariableDataType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] * exp->intArr[0]; //arr_float*var_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] * exp->floatArr[0]; //arr_float*var_float
          }
        }

      }
      else if(exp->getIDType()=="ARRAY"){
        if(ter->getVariableDataType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            t->intArr[0] = ter->intArr[ter->getArrayIndex()] * exp->intArr[exp->getArrayIndex()]; //arr_int*arr_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->intArr[ter->getArrayIndex()] * exp->floatArr[exp->getArrayIndex()]; //arr_int*arr_float
          }
        }
        else if(ter->getVariableDataType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] * exp->intArr[exp->getArrayIndex()]; //arr_float*arr_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] * exp->floatArr[exp->getArrayIndex()]; //arr_float*arr_float
          }
        }

      }

		else if(exp->getIDType()=="FUNCTION"){
			if(ter->getVariableDataType()=="INT"){
				if(exp->getFuncRetType()=="INT"){
					t->setVariableDataType("INT");
					t->intArr[0] = ter->intArr[ter->getArrayIndex()] * exp->intArr[0]; //arr_int*var_int
				}
				else if(exp->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->intArr[ter->getArrayIndex()] * exp->floatArr[0]; //arr_int*var_float
				}
			}
			else if(ter->getVariableDataType()=="FLOAT"){
				if(exp->getFuncRetType()=="INT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] * exp->intArr[0]; //arr_float*var_int
				}
				else if(exp->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] * exp->floatArr[0]; //arr_float*var_float
				}
			}
		}


    }

		else if(ter->getIDType()=="FUNCTION"){
			if(exp->getIDType()=="VARIABLE"){
        if(ter->getFuncRetType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            t->intArr[0] = ter->intArr[0] * exp->intArr[0]; //var_int*var_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->intArr[0] * exp->floatArr[0]; //var_int*var_float
          }
        }
        else if(ter->getFuncRetType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[0] * exp->intArr[0]; //var_float*var_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[0] * exp->floatArr[0]; //var_float*var_float
          }
        }
      }
      else if(exp->getIDType()=="ARRAY"){
        if(ter->getFuncRetType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            t->intArr[0] = ter->intArr[0] * exp->intArr[exp->getArrayIndex()]; //var_int*arr_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->intArr[0] * exp->floatArr[exp->getArrayIndex()]; //var_int*arr_float
          }
        }
        else if(ter->getFuncRetType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[0] * exp->intArr[exp->getArrayIndex()]; //var_float*arr_int
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            t->floatArr[0] = ter->floatArr[0] * exp->floatArr[exp->getArrayIndex()]; //var_float*arr_float
          }
        }

      }
		else if(exp->getIDType()=="FUNCTION"){
			if(ter->getFuncRetType()=="INT"){
				if(exp->getFuncRetType()=="INT"){
					t->setVariableDataType("INT");
					t->intArr[0] = ter->intArr[0] * exp->intArr[0]; //var_int*var_int
				}
				else if(exp->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->intArr[0] * exp->floatArr[0]; //var_int*var_float
				}
			}
			else if(ter->getFuncRetType()=="FLOAT"){
				if(exp->getFuncRetType()=="INT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->floatArr[0] * exp->intArr[0]; //var_float*var_int
				}
				else if(exp->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					t->floatArr[0] = ter->floatArr[0] * exp->floatArr[0]; //var_float*var_float
				}
			}
		}
		}


  }

  else if(mulop->getName()=="/"){
    if(ter->getIDType()=="VARIABLE"){
      if(exp->getIDType()=="VARIABLE"){
        if(ter->getVariableDataType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            if(exp->intArr[0]!=0) t->intArr[0] = ter->intArr[0] / exp->intArr[0]; //var_int/var_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[0]!=0) t->floatArr[0] = ter->intArr[0] / exp->floatArr[0]; //var_int/var_float
						else print_divide_by_zero();
          }
        }
        else if(ter->getVariableDataType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            if(exp->intArr[0]!=0) t->floatArr[0] = ter->floatArr[0] / exp->intArr[0]; //var_float/var_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[0]!=0) t->floatArr[0] = ter->floatArr[0] / exp->floatArr[0]; //var_float/var_float
						else print_divide_by_zero();
          }
        }
      }
      else if(exp->getIDType()=="ARRAY"){
        if(ter->getVariableDataType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            if(exp->intArr[exp->getArrayIndex()]!=0) t->intArr[0] = ter->intArr[0] / exp->intArr[exp->getArrayIndex()]; //var_int/arr_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->intArr[0] / exp->floatArr[exp->getArrayIndex()]; //var_int/arr_float
						else print_divide_by_zero();
          }
        }
        else if(ter->getVariableDataType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            if(exp->intArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->floatArr[0] / exp->intArr[exp->getArrayIndex()]; //var_float/arr_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->floatArr[0] / exp->floatArr[exp->getArrayIndex()]; //var_float/arr_float
						else print_divide_by_zero();
					}
        }

      }

			else if(exp->getIDType()=="FUNCTION"){
				if(ter->getVariableDataType()=="INT"){
					if(exp->getFuncRetType()=="INT"){
						t->setVariableDataType("INT");
						if(exp->intArr[0]!=0) t->intArr[0] = ter->intArr[0] / exp->intArr[0]; //var_int * var_int
						else print_divide_by_zero();
					}
					else if(exp->getFuncRetType()=="FLOAT"){
						t->setVariableDataType("FLOAT");
						if(exp->intArr[0]!=0) t->floatArr[0] = ter->intArr[0] / exp->floatArr[0]; //var_int/var_float
						else print_divide_by_zero();
					}
				}
				else if(ter->getVariableDataType()=="FLOAT"){
					if(exp->getFuncRetType()=="INT"){
						t->setVariableDataType("FLOAT");
						if(exp->intArr[0]!=0) t->floatArr[0] = ter->floatArr[0] / exp->intArr[0]; //var_float/var_int
						else print_divide_by_zero();
					}
					else if(exp->getFuncRetType()=="FLOAT"){
						t->setVariableDataType("FLOAT");
						if(exp->floatArr[0]!=0) t->floatArr[0] = ter->floatArr[0] / exp->floatArr[0]; //var_float/var_float
						else print_divide_by_zero();
					}
				}
			}

    }
    else if(ter->getIDType()=="ARRAY"){
      if(exp->getIDType()=="VARIABLE"){
        if(ter->getVariableDataType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            if(exp->intArr[0]) t->intArr[0] = ter->intArr[ter->getArrayIndex()] / exp->intArr[0]; //arr_int/var_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[0]) t->floatArr[0] = ter->intArr[ter->getArrayIndex()] / exp->floatArr[0]; //arr_int/var_float
						else print_divide_by_zero();
          }
        }
        else if(ter->getVariableDataType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            if(exp->intArr[0]) t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] / exp->intArr[0]; //arr_float/var_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[0]) t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] / exp->floatArr[0]; //arr_float/var_float
						else print_divide_by_zero();
          }
        }

      }
      else if(exp->getIDType()=="ARRAY"){
        if(ter->getVariableDataType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            if(exp->intArr[exp->getArrayIndex()]!=0) t->intArr[0] = ter->intArr[ter->getArrayIndex()] / exp->intArr[exp->getArrayIndex()]; //arr_int/arr_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->intArr[ter->getArrayIndex()] / exp->floatArr[exp->getArrayIndex()]; //arr_int/arr_float
						else print_divide_by_zero();
          }
        }
        else if(ter->getVariableDataType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            if(exp->intArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] / exp->intArr[exp->getArrayIndex()]; //arr_float/arr_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] / exp->floatArr[exp->getArrayIndex()]; //arr_float/arr_float
						else print_divide_by_zero();
          }
        }

      }


			else if(exp->getIDType()=="FUNCTION"){
				if(ter->getVariableDataType()=="INT"){
					if(exp->getFuncRetType()=="INT"){
						t->setVariableDataType("INT");
						if(exp->intArr[0]!=0) t->intArr[0] = ter->intArr[ter->getArrayIndex()] / exp->intArr[0]; //var_int * var_int
						else print_divide_by_zero();
					}
					else if(exp->getFuncRetType()=="FLOAT"){
						t->setVariableDataType("FLOAT");
						if(exp->intArr[0]!=0) t->floatArr[0] = ter->intArr[ter->getArrayIndex()] / exp->floatArr[0]; //var_int/var_float
						else print_divide_by_zero();
					}
				}
				else if(ter->getVariableDataType()=="FLOAT"){
					if(exp->getFuncRetType()=="INT"){
						t->setVariableDataType("FLOAT");
						if(exp->intArr[0]!=0) t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] / exp->intArr[0]; //var_float/var_int
						else print_divide_by_zero();
					}
					else if(exp->getFuncRetType()=="FLOAT"){
						t->setVariableDataType("FLOAT");
						if(exp->floatArr[0]!=0) t->floatArr[0] = ter->floatArr[ter->getArrayIndex()] / exp->floatArr[0]; //var_float/var_float
						else print_divide_by_zero();
					}
				}
			}



    }

		else if(ter->getIDType()=="FUNCTION"){
			if(exp->getIDType()=="VARIABLE"){
        if(ter->getFuncRetType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            if(exp->intArr[0]!=0) t->intArr[0] = ter->intArr[0] / exp->intArr[0]; //var_int/var_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[0]!=0) t->floatArr[0] = ter->intArr[0] / exp->floatArr[0]; //var_int/var_float
						else print_divide_by_zero();
          }
        }
        else if(ter->getFuncRetType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            if(exp->intArr[0]!=0) t->floatArr[0] = ter->floatArr[0] / exp->intArr[0]; //var_float/var_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[0]!=0) t->floatArr[0] = ter->floatArr[0] / exp->floatArr[0]; //var_float/var_float
						else print_divide_by_zero();
          }
        }
      }
      else if(exp->getIDType()=="ARRAY"){
        if(ter->getFuncRetType()=="INT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("INT");
            if(exp->intArr[exp->getArrayIndex()]!=0)t->intArr[0] = ter->intArr[0] / exp->intArr[exp->getArrayIndex()]; //var_int/arr_int
						else print_divide_by_zero();
          }
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->intArr[0] / exp->floatArr[exp->getArrayIndex()]; //var_int/arr_float
						else print_divide_by_zero();
          }
        }
        else if(ter->getFuncRetType()=="FLOAT"){
          if(exp->getVariableDataType()=="INT"){
            t->setVariableDataType("FLOAT");
            if(exp->intArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->floatArr[0] / exp->intArr[exp->getArrayIndex()]; //var_float/arr_int
						else print_divide_by_zero();
					}
          else if(exp->getVariableDataType()=="FLOAT"){
            t->setVariableDataType("FLOAT");
            if(exp->floatArr[exp->getArrayIndex()]!=0) t->floatArr[0] = ter->floatArr[0] / exp->floatArr[exp->getArrayIndex()]; //var_float/arr_float
						else print_divide_by_zero();
          }
        }

      }
		else if(exp->getIDType()=="FUNCTION"){
			if(ter->getFuncRetType()=="INT"){
				if(exp->getFuncRetType()=="INT"){
					t->setVariableDataType("INT");
					if(exp->intArr[0]!=0) t->intArr[0] = ter->intArr[0] / exp->intArr[0]; //var_int/var_int
					else print_divide_by_zero();
				}
				else if(exp->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					if(exp->floatArr[0]!=0) t->floatArr[0] = ter->intArr[0] / exp->floatArr[0]; //var_int/var_float
					else print_divide_by_zero();
				}
			}
			else if(ter->getFuncRetType()=="FLOAT"){
				if(exp->getFuncRetType()=="INT"){
					t->setVariableDataType("FLOAT");
					if(exp->intArr[0]!=0) t->floatArr[0] = ter->floatArr[0] / exp->intArr[0]; //var_float/var_int
					else print_divide_by_zero();
				}
				else if(exp->getFuncRetType()=="FLOAT"){
					t->setVariableDataType("FLOAT");
					if(exp->floatArr[0]!=0) t->floatArr[0] = ter->floatArr[0] / exp->floatArr[0]; //var_float/var_float
					else print_divide_by_zero();
				}
			}
		}
		}


  }

  else if(mulop->getName()=="%"){

    if((ter->getVariableDataType()=="INT" || ter->getFuncRetType()=="INT") && (exp->getVariableDataType()=="INT" || exp->getFuncRetType()=="INT")){

      t->setVariableDataType("INT");

      if(ter->getIDType()=="ARRAY"){
        if(exp->getIDType()=="ARRAY"){
					if(exp->intArr[exp->getArrayIndex()]!=0){
          	t->intArr[0] = ter->intArr[ter->getArrayIndex()] % exp->intArr[exp->getArrayIndex()];
					}
					else{
						errorfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
						logfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
						syntax_error++;
					}
        }
        else if(exp->getIDType()=="VARIABLE"){
					if(exp->intArr[0]!=0)
          	t->intArr[0] = ter->intArr[ter->getArrayIndex()] % exp->intArr[0];
					else{
							errorfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
							logfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
							syntax_error++;
						}
        }
				else if(exp->getIDType()=="FUNCTION"){
					if(exp->intArr[0]!=0)
          	t->intArr[0] = ter->intArr[ter->getArrayIndex()] % exp->intArr[0];
					else{
							errorfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
							logfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
							syntax_error++;
						}
        }
      }
      else if(ter->getIDType()=="VARIABLE"){
        if(exp->getIDType()=="ARRAY"){
					if(exp->intArr[exp->getArrayIndex()]!=0)
          	t->intArr[0] = ter->intArr[0] % exp->intArr[exp->getArrayIndex()];
					else{
								errorfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
								logfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
								syntax_error++;
							}
        }
        else if(exp->getIDType()=="VARIABLE"){
					if(exp->intArr[0]!=0)
          	t->intArr[0] = ter->intArr[0] % exp->intArr[0];
					else{
							errorfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
							logfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
							syntax_error++;
						}
        }

				else if(exp->getIDType()=="FUNCTION"){
					if(exp->intArr[0]!=0)
						t->intArr[0] = ter->intArr[0] % exp->intArr[0];
					else{
							errorfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
							logfile<<"Error at line "<<line_count<<": Modulus by Zero"<<endl<<endl;
							syntax_error++;
						}
				}
      }
    }
    else{
      errorfile<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator"<<endl<<endl;
			logfile<<"Error at line "<<line_count<<": Non-Integer operand on modulus operator"<<endl<<endl;
      syntax_error++;
    }
  }

  return t;
}
