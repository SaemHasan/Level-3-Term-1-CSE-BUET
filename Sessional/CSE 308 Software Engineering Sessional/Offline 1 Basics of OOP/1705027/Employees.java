public class Employees{
    protected String name;
    private String employee_type;

    public Employees() {
    }

    public Employees(String name, String employee_type) {
        this.name = name;
        this.employee_type = employee_type;
    }

    void Lookup(String name){}
    double Approve_loan(Accounts account){return 0;}
    void Change_Interest_Rate(String type, double new_interest_rate){}
}


class Managing_Director extends Employees{

    private Accounts []accounts;

    public Managing_Director(Accounts []accounts,String name, String employee_type) {
        super(name, employee_type);
        this.accounts=accounts;
    }

    void Lookup(String name){
        for(Accounts account: accounts){
            if(account==null){
                System.out.println("There is no account of "+name);
                break;
            }
            if(account.name.equalsIgnoreCase(name)){
                System.out.println(name+"'s current balance "+account.deposit_amount+"$");
                break;
            }
        }
    }


    void Change_Interest_Rate(String type, double new_interest_rate){
        if(type.equalsIgnoreCase("Student")){
            Student.setDeposit_interest_rate(new_interest_rate);
            System.out.println(type+"'s new deposit interest rate "+new_interest_rate);
        }
        if(type.equalsIgnoreCase("Fixed")){
            FixedDeposit.setDeposit_interest_rate(new_interest_rate);
            System.out.println(type+"'s new deposit interest rate "+new_interest_rate);
        }
        if(type.equalsIgnoreCase("Savings")){
            Savings.setDeposit_interest_rate(new_interest_rate);
            System.out.println(type+"'s new deposit interest rate "+new_interest_rate);
        }
    }

    double Approve_loan(Accounts account){
        double loan_amount=0;

        account.deposit_amount += account.req_loan;
        account.loan_amount += account.req_loan;
        loan_amount = account.req_loan;
        account.req_loan = 0;
        System.out.println("Loan for "+account.name+" approved");

        return loan_amount;
    }
}


class Officer extends Employees{
    private Accounts []accounts;

    public Officer(Accounts []accounts, String name, String employee_type) {
        super(name, employee_type);
        this.accounts=accounts;
    }

    void Lookup(String name){
        for(Accounts account: accounts){
            if(account==null){
                System.out.println("There is no account of "+name);
                break;
            }
            if(account.name.equalsIgnoreCase(name)){
                System.out.println(name+"'s current balance "+account.deposit_amount+"$");
                break;
            }
        }
    }

    double Approve_loan(Accounts account){
        double loan_amount=0;
        account.deposit_amount += account.req_loan;
        account.loan_amount += account.req_loan;
        loan_amount = account.req_loan;
        account.req_loan = 0;
        System.out.println("Loan for "+account.name+" approved");
        return loan_amount;
    }
}


class Cashier extends Employees{
    private Accounts []accounts;
    public Cashier(Accounts []accounts,String name, String employee_type) {
        super(name, employee_type);
        this.accounts=accounts;
    }

    void Lookup(String name){
        for(Accounts account: accounts){
            if(account==null){
                System.out.println("There is no account of "+name);
                break;
            }
            if(account.name.equalsIgnoreCase(name)){
                System.out.println(name+"'s current balance "+account.deposit_amount+"$");
                break;
            }
        }
    }

    double Approve_loan(Accounts account){
        double loan_amount=0;
        System.out.println("You don't have permission for this operation");
        return loan_amount;
    }
}
