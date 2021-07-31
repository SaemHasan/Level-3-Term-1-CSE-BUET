#include<bits/stdc++.h>
using namespace std;

class SymbolInfo{
    string Name;
    string Type;

public:

    SymbolInfo *next;

    SymbolInfo(){
        next=NULL;
    }

    SymbolInfo(string name, string type){
        Name=name;
        Type=type;
        next=NULL;
    }

    string getName(){
        return Name;
    }

    string getType(){
        return Type;
    }

    ~SymbolInfo(){
        next = NULL;
    }

};



class ScopeTable{
        SymbolInfo **nodes;
        int total_buckets;//total_buckets

        int hashFunc(string key){
            int sum_ascii=0;
            for(int i=0;i<key.length();i++){
                sum_ascii+=int(key[i]);
            }
            int hashValue= sum_ascii% total_buckets;
            return hashValue;
        }

    public:
        ScopeTable *parentScope;
        string id;
        int CreatedScopeTable;//count of created scope table under this scope

        ScopeTable(int length,string tableID){
            id=tableID;
            CreatedScopeTable=0;
            parentScope=NULL;
            total_buckets=length;
            nodes = new SymbolInfo*[total_buckets];
            for(int i=0;i<total_buckets;i++){
                nodes[i]=NULL;
            }
        }

        bool Insert(string name, string type){

            if(Look_up(name)!=NULL) return false;

            else{
                int cnt=0;
                SymbolInfo *NewNode = new SymbolInfo(name,type);
                int idx=hashFunc(name);

                SymbolInfo *temp=NULL;
                temp=nodes[idx];

                if(temp==NULL){
                    nodes[idx]=NewNode;
                }

                else{
                    SymbolInfo *prev=NULL;
                    while(temp!=NULL){
                        cnt++;
                        prev=temp;
                        temp=prev->next;
                    }
                    prev->next=NewNode;
                }
                // cout<<"Inserted in ScopeTable# " <<id<<" at position "<< idx<<", "<< cnt<<endl<<endl;
                return true;
            }

        }

        SymbolInfo* Look_up(string key){

            int idx=hashFunc(key);

            if(nodes[idx]==NULL) return NULL;

            int cnt=0;
            SymbolInfo *temp=nodes[idx];
            SymbolInfo *result=NULL;

            while(temp!=NULL){
                    if(temp->getName()==key){
                        result = temp;
                        break;
                    }
                    cnt++;
                    temp=temp->next;
            }
            // if(result!=NULL) cout<<"Found in ScopeTable# "<<id<<" at position "<<idx<<", "<<cnt<<endl<<endl;
            return result;
        }

        bool Delete(string key){

            int idx=hashFunc(key);

            if(Look_up(key)==NULL) {
                    cout<<"Not found"<<endl<<endl;
                    return false;
            }

            bool deleted = false;
            int cnt=0;
            SymbolInfo *temp=nodes[idx];
            SymbolInfo *prev=NULL;

            while(temp!=NULL){
                    if(temp->getName()==key){
                        if(prev!=NULL) prev->next=temp->next;
                        else nodes[idx]=temp->next;
                        deleted = true;
                        delete temp;
                        break;
                    }
                    cnt++;
                    prev=temp;
                    temp=temp->next;
            }

            // if(deleted) cout<<"Deleted Entry "<<idx<<", " <<cnt<<" from current ScopeTable"<<endl<<endl;

            return deleted;

        }

        void Print(){
            cout<<"ScopeTable # "<<id<<endl;
            for(int i=0;i<total_buckets;i++){
              if(nodes[i]!=NULL){
                cout<<i<<" -->  ";
                SymbolInfo *temp=nodes[i];
                while(temp!=NULL){
                    cout<<"< "<<temp->getName()<<" : "<<temp->getType()<<">  ";
                    temp=temp->next;
                }
                cout<<endl;
              }
            }
        }

        void Print(ofstream &out){
            out<<"ScopeTable # "<<id<<endl;
            for(int i=0;i<total_buckets;i++){
              if(nodes[i]!=NULL){
                out<<" "<<i<<" --> ";
                SymbolInfo *temp=nodes[i];
                while(temp!=NULL){
                    out<<"< "<<temp->getName()<<" : "<<temp->getType()<<"> ";
                    temp=temp->next;
                }
                out<<endl;
              }
            }
        }

        ~ScopeTable(){
                for(int i=0;i<total_buckets;i++){
                    delete nodes[i];
                }
        }
};


class SymbolTable{
    int total_buckets;
    int globalscope_count;
    public:
        ScopeTable *current_scopetable;

        SymbolTable(int length){
            total_buckets=length;
            globalscope_count=1;
            current_scopetable=new ScopeTable(length,"1");
        }


        void Enter_Scope(){
            ostringstream str;
            string newtableID;
            ScopeTable *temp;
            temp = current_scopetable;
            if(temp!=NULL){
                str<<++current_scopetable->CreatedScopeTable;
                newtableID = current_scopetable->id+"."+str.str();
                current_scopetable= new ScopeTable(total_buckets,newtableID);
                current_scopetable->parentScope=temp;
            }
            else{
                str<<++globalscope_count;
                newtableID=str.str();
                current_scopetable= new ScopeTable(total_buckets,newtableID);
            }
            // cout<<"New ScopeTable with id "<<newtableID<< " created"<<endl<<endl;
        }

        void Exit_Scope(){
            if(current_scopetable!=NULL){
                ScopeTable *temp=current_scopetable;
                //cout<<"ScopeTable with id "<<current_scopetable->id<<" removed"<<endl<<endl;
                current_scopetable=current_scopetable->parentScope;
                delete temp;
            }
            else{
                // cout<<"Create A scope table first"<<endl;
            }
        }

        bool Insert(string name, string type){
            if(current_scopetable!=NULL){
                bool inserted=current_scopetable->Insert(name,type);
                //if(!inserted) cout<<"<"<<name<<","<<type<<">  already exists in current ScopeTable"<<endl<<endl;
                return inserted;
            }
            else{
                // cout<<"Create A scope table first"<<endl;
                return false;
            }
        }

        bool Remove(string key){
            if(current_scopetable!=NULL){
                bool deleted= current_scopetable->Delete(key);
                //if(!deleted) cout<<key<<" not found"<<endl<<endl;
                return deleted;
            }
            else{
                // cout<<"Create A scope table first"<<endl;
                return false;
            }
        }

        SymbolInfo* Look_up(string key){
            if(current_scopetable!=NULL){
                ScopeTable *temp=current_scopetable;
                SymbolInfo *result=NULL;
                bool found=false;

                while(temp!=NULL){
                    result=temp->Look_up(key);
                    if(result!=NULL){
                         found=true;
                        break;
                    }
                    temp=temp->parentScope;
                }
                // if(!found) cout<<"Not found"<<endl<<endl;
                return result;
            }
            else{
                // cout<<"Create A scope table first"<<endl;
                return NULL;
            }
        }

        void Print_Current_ScopeTable(){
            if(current_scopetable!=NULL){
                current_scopetable->Print();
                cout<<endl;
            }
            else{
                // cout<<"Create A scope table first"<<endl;
            }
        }

        void Print_All_ScopeTable(){
            if(current_scopetable!=NULL){
                ScopeTable *temp= current_scopetable;
                while(temp!=NULL){
                    temp->Print();
                    cout<<endl;
                    temp=temp->parentScope;
                }
            }
            else{
                // cout<<"Create A scope table first"<<endl;
            }
        }

        void Print_All_ScopeTable(ofstream &out){
            if(current_scopetable!=NULL){
                ScopeTable *temp= current_scopetable;
                while(temp!=NULL){
                    temp->Print(out);
                    out<<endl;
                    temp=temp->parentScope;
                }
            }
            else{
                // cout<<"Create A scope table first"<<endl;
            }
        }

        ~SymbolTable(){
            ScopeTable *temp;
                while(current_scopetable!=NULL){
                    temp= current_scopetable;
                    current_scopetable=current_scopetable->parentScope;
                    delete temp;
                }
        }

};





// int main(){
//     fstream in("input.txt");
//     freopen("output.txt", "w+", stdout);

//     int total_buckets;
//     char ch,ch1;
//     string name,type;

//     in>>total_buckets;

//     SymbolTable *symboltable=new SymbolTable(total_buckets);

//     while(!in.eof()){
//         in>>ch;
//         if(in.eof()) break;

//         if(ch=='I'){
//                 in>>name;
//                 in>>type;
//                 cout<<ch<<" "<<name<<" "<<type<<"\n\n";
//                 symboltable->Insert(name,type);
//         }
//         else if(ch=='L'){
//             in>>name;
//             cout<<ch<<" "<<name<<"\n\n";
//             symboltable->Look_up(name);
//         }
//         else if(ch=='D'){
//             in>>name;
//             cout<<ch<<" "<<name<<"\n\n";
//             symboltable->Remove(name);
//         }
//         else if(ch=='P'){
//             in>>ch1;
//             if(ch1=='A'){
//                 cout<<ch<<" "<<ch1<<"\n\n\n";
//                 symboltable->Print_All_ScopeTable();
//             }
//             else if(ch1=='C'){
//                 cout<<ch<<" "<<ch1<<"\n\n\n";
//                 symboltable->Print_Current_ScopeTable();
//             }
//         }
//         else if(ch=='S'){
//             cout<<ch<<"\n\n";
//             symboltable->Enter_Scope();
//         }
//         else if(ch=='E'){
//             cout<<ch<<"\n\n";
//             symboltable->Exit_Scope();
//         }

//     }
//     return 0;
// }
