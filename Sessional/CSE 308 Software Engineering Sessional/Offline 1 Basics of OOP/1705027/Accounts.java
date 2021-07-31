class Accounts{
    protected String accountType;
    protected String name;
    protected double deposit_amount;
    protected double loan_amount;
    protected double req_loan;


    public Accounts() {
    }

    public Accounts(String accountType, String name, double deposit_amount) {
        this.accountType = accountType;
        this.name = name;
        this.deposit_amount = deposit_amount;
        this.loan_amount = 0;
        this.req_loan=0;
    }


    void deposit(double amount){
        deposit_amount+= amount;
        System.out.println(amount+"$ deposited; current balance "+deposit_amount+"$");
    };

    void withdraw(double amount){};
    boolean request_loan(double amount){return false;};

    void query(){
        if(loan_amount==0){
            System.out.println("Current balance "+deposit_amount);
        }
        else
            System.out.println("Current balance "+deposit_amount+"$, loan "+loan_amount+"$");
    };

    void inc_operation(){};

}

class Savings extends Accounts{
    private static double deposit_interest_rate=10;
    private static double service_charge=500;
    private static double max_loan =10000;
    private static double loan_interest_rate=10;
    private int year;


    public Savings(String accountType, String name, double deposit_amount) {
        super(accountType, name, deposit_amount);
        year=0;
    }

    public static void setDeposit_interest_rate(double deposit_interest_rate) {
        Savings.deposit_interest_rate = deposit_interest_rate;
    }

    void withdraw(double amount){
        if(deposit_amount-amount<1000){
            System.out.println("Invalid transaction: current balance "+deposit_amount+"$");
            return;
        }
        deposit_amount-=amount;
        System.out.println(amount+"$ withdrawn; current balance "+deposit_amount+"$");
    }

    boolean request_loan(double amount){
        if(req_loan+amount>max_loan){
            System.out.println("for savings account the maximum allowable loan is "+max_loan+"$");
            return false;
        }
        req_loan+=amount;
        System.out.println("Loan request successful, sent for approval");
        return true;
    }

    void inc_operation(){
        year++;
        deposit_amount+= (deposit_amount*(deposit_interest_rate/100.0));
        deposit_amount-= service_charge;
        deposit_amount-= (loan_amount*(loan_interest_rate/100.0));
    };


}

class Student extends Accounts{
    private static double deposit_interest_rate=5;
    private static double service_charge=0;
    private static double max_loan=1000;
    private static double loan_interest_rate=10;
    private int year;

    public Student(String accountType, String name, double deposit_amount) {
        super(accountType, name, deposit_amount);
        year=0;
    }

    public static void setDeposit_interest_rate(double deposit_interest_rate) {
        Student.deposit_interest_rate = deposit_interest_rate;
    }

    void withdraw(double amount){
        if(amount>10000 || amount>deposit_amount){
            System.out.println("Invalid transaction: current balance "+deposit_amount+"$");
            return;
        }
        deposit_amount-=amount;
        System.out.println(amount+"$ withdrawn; current balance "+deposit_amount+"$");
    }

    boolean request_loan(double amount){
        if(req_loan+amount>max_loan){
            System.out.println("for student account the maximum allowable loan is "+max_loan+"$");
            return false;
        }
        req_loan+=amount;
        System.out.println("Loan request successful, sent for approval");
        return true;
    }

    void inc_operation(){
        year++;
        deposit_amount+= (deposit_amount*(deposit_interest_rate/100.0));
        deposit_amount-=service_charge;
        deposit_amount-= (loan_amount*(loan_interest_rate/100.0));
    };

}

class FixedDeposit extends Accounts{
    private static double deposit_interest_rate=15;
    private static double service_charge=500;
    private static double min_deposit = 50000;
    private static double max_loan = 100000;
    private static double loan_interest_rate=10;
    private int year;

    public FixedDeposit(String accountType, String name, double deposit_amount) {
        super(accountType, name, deposit_amount);
        year=0;
    }

    public static void setDeposit_interest_rate(double deposit_interest_rate) {
        FixedDeposit.deposit_interest_rate = deposit_interest_rate;
    }

    void deposit(double amount){
        if(amount<50000){
            System.out.println("in fixed deposit, the deposit amount should not be less than 50000");
            return;
        }
        deposit_amount+=amount;
//        System.out.println("in fixed deposit, deposit function");
        System.out.println(amount+"$ deposited; current balance "+deposit_amount+"$");
    }

    void withdraw(double amount){
//        System.out.println("here in fixed. year : "+year);
        if(year==0){
            System.out.println("A fixed deposit account cannot withdraw if it has not reached a maturity period of one year");
            return;
        }
        if(amount>deposit_amount){
            System.out.println("Invalid transaction: current balance "+deposit_amount+"$");
            return;
        }
        deposit_amount-=amount;
        System.out.println(amount+"$ withdrawn; current balance "+deposit_amount+"$");
    }

    boolean request_loan(double amount){
        if(req_loan+amount>max_loan){
            System.out.println("for fixed deposit account the maximum allowable loan is "+max_loan+"$");
            return false;
        }
        req_loan+=amount;
        System.out.println("Loan request successful, sent for approval");
        return true;
    }


    void inc_operation(){
        year++;
        deposit_amount+= (deposit_amount*(deposit_interest_rate/100.0));
        deposit_amount-=service_charge;
        deposit_amount-= (loan_amount*(loan_interest_rate/100.0));
    };



}