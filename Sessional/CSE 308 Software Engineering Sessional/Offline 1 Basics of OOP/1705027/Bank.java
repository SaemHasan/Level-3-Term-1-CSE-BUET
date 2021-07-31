import java.util.HashSet;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Set;

public class Bank {
    private static int year_count=0;
    private static int account_count =0;

    private double internal_fund;

    private Set<String> primaryKeys= new HashSet<String>();
    private Accounts accounts[]=new Accounts[500];
    private Employees employees[] = new Employees[8];
    private Queue<Accounts> requested_Account = new LinkedList<Accounts>();

    public Bank() {
        internal_fund=1000000;
        employees[0]= new Managing_Director(accounts,"MD", "MANAGING DIRECTOR");
        employees[1]= new Officer(accounts,"S1","OFFICER");
        employees[2]= new Officer(accounts,"S2","OFFICER");
        for(int i=3;i<8;i++){
            employees[i] = new Cashier(accounts,"C"+String.valueOf(i-2),"CASHIER");
        }
        System.out.println("Bank Created; MD, S1, S2, C1, C2, C3, C4, C5 created");
    }


    boolean create_account(String name, String type, double initial_deposit){
        boolean opened=false;
        if(primaryKeys.contains(name.toUpperCase())){
            System.out.println("Name already exist!");
            return false;
        }
        if(type.toUpperCase().equalsIgnoreCase("FIXED")){
            if(initial_deposit<100000){
                System.out.println("In fixed deposit, the first deposit should be at least 100000");
                return false;
            }

            accounts[account_count++]= new FixedDeposit(type, name, initial_deposit);
            primaryKeys.add(name.toUpperCase());
            opened=true;
        }
        if(type.toUpperCase().equalsIgnoreCase("STUDENT")){
            primaryKeys.add(name.toUpperCase());
            accounts[account_count++] = new Student(type, name, initial_deposit);
            opened=true;
        }
        if(type.toUpperCase().equalsIgnoreCase("SAVINGS")){
            primaryKeys.add(name.toUpperCase());
            accounts[account_count++] = new Savings(type,name, initial_deposit);
            opened=true;
        }
        if(opened)
            System.out.println(type+" account for "+name+" created; Initial balance "+initial_deposit+"$");
        else
            System.out.println("Can not Create the account!Enter 'Create Name AccountType initialDeposit' in this format");
        return opened;
    }

    boolean Open(String key){
        int idx = SearchEmployee(key);
        if(idx!=-1){
            if(employees[idx] instanceof Cashier){
                System.out.println(key+" Active.");
            }
            if(employees[idx] instanceof Managing_Director || employees[idx] instanceof Officer){
                if(requested_Account.isEmpty())
                    System.out.println(key+" Active.");
                else
                    System.out.println(key+" Active, there are loan approvals pending");
            }

            return true;
        }
        else{
            if(primaryKeys.contains(key.toUpperCase())){
                System.out.println("Welcome Back, "+key);
                return true;
            }
            return false;
        }
    }

    void deposit(String name, double amount){
        for(int i=0;i<account_count;i++){
            if(accounts[i].name.equalsIgnoreCase(name)){
                accounts[i].deposit(amount);
                break;
            }
        }
    }

    void withdraw(String name, double amount){
        for(int i=0;i<account_count;i++){
            if(accounts[i].name.equalsIgnoreCase(name)){
                accounts[i].withdraw(amount);
                break;
            }
        }
    }

    void query(String name){
        for(int i=0;i<account_count;i++){
            if(accounts[i].name.equalsIgnoreCase(name)){
                accounts[i].query();
                break;
            }
        }
    }

    void request(String name, double amount){
        for(int i=0;i<account_count;i++){
            if(accounts[i].name.equalsIgnoreCase(name)){
                if(accounts[i].request_loan(amount)){
                    requested_Account.add(accounts[i]);
                }
                break;
            }
        }
    }

    void INC_operation(){
        year_count++;
        for(int i=0;i<account_count;i++){
            accounts[i].inc_operation();
        }
        System.out.println("1 year passed");
    }

    int SearchEmployee(String key){
        int found = -1;
        for(int i=0;i<8;i++){
            if(employees[i].name.equalsIgnoreCase(key)){
                found=i;
                break;
            }
        }
        return found;
    }

    void Lookup(String key, String Accountname){
        int idx = SearchEmployee(key);
        if(idx!=-1){
            employees[idx].Lookup(Accountname);
        }
        else{
            System.out.println(key+" is not a employee");
        }
    }

    void change(String key, String type, double new_Interest_Rate){
        int idx = SearchEmployee(key);
        if(idx!=-1 && employees[idx] instanceof Managing_Director){
            employees[idx].Change_Interest_Rate(type, new_Interest_Rate);
        }
        else{
            System.out.println("You don't have permission for this operation");
        }
    }

    void See(String key){
        int idx  = SearchEmployee(key);
        if(idx!=-1 && employees[idx] instanceof Managing_Director){
            System.out.println("The internal funds "+internal_fund+"$");
        }
        else{
            System.out.println("You don't have permission for this operation");
        }
    }

    void approve_Loan(String key){
        double Loan_Sum=0;
        int idx = SearchEmployee(key);
        if(idx!=-1) {
            if(employees[idx] instanceof Cashier){
                System.out.println("You don't have permission for this operation");
            }
            else {
                while (requested_Account.peek() != null && internal_fund-Loan_Sum>=0) {
                    Accounts account = requested_Account.poll();
                    double approvedLoan = employees[idx].Approve_loan(account);
                    Loan_Sum += approvedLoan;
                }
                internal_fund -= Loan_Sum;
            }
        }

        else{
            System.out.println(key+" is not a employee");
        }
    }

}
