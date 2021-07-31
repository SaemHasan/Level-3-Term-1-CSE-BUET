import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        String primarykey = "";
        boolean loggedin = false;

        Bank bank = new Bank();
        Scanner sc=new Scanner(System.in);

        while(true){

            if(!loggedin)
                System.out.println("Enter Create/Open Command");
            if(loggedin && bank.SearchEmployee(primarykey)==-1)
                System.out.println("Enter Deposit/Withdraw/Query/Request/Close Command");
            else if (loggedin)
                System.out.println("Enter Approve Loan/Change/Lookup/See Command");

            String input = sc.nextLine();
            String []commands =  input.split(" ");


            if(commands[0].toUpperCase().equals("CREATE")){
                if(commands.length!=4) {
                    System.out.println("Enter all the data correctly");
                }
                else if(loggedin) {
                    System.out.println("Please Close the Account to create another!");
                }
                else{
                    if(bank.create_account(commands[1],commands[2],Double.parseDouble(commands[3]))){
                        primarykey = commands[1];
                        loggedin=true;
                    }
                }
            }


            else if(commands[0].toUpperCase().equals("DEPOSIT")){
                if(commands.length!=2){
                    System.out.println("Enter all the data correctly");
                }
                else {
                    if (loggedin) bank.deposit(primarykey, Double.parseDouble(commands[1]));
                    else System.out.println("Open a account first");
                }
            }


            else if(commands[0].toUpperCase().equals("WITHDRAW")){
                if(commands.length!=2) {
                    System.out.println("Enter all the data correctly");
                }
                else {
                    if (loggedin) {
                        bank.withdraw(primarykey, Double.parseDouble(commands[1]));
                    }
                    else System.out.println("Open a account first");
                }
            }


            else if(commands[0].toUpperCase().equals("QUERY")){
                if(commands.length!=1) {
                    System.out.println("Enter all the data correctly");
                }
                else {
                    if (loggedin) {
                        bank.query(primarykey);
                    } else System.out.println("Open a account first");
                }
            }


            else if(commands[0].toUpperCase().equals("REQUEST")){
                if(commands.length!=2) {
                    System.out.println("Enter all the data correctly");
                }
                else {
                    if (loggedin) {
                        bank.request(primarykey, Double.parseDouble(commands[1]));
                    } else System.out.println("Open a account first");
                }
            }

            else if(commands[0].toUpperCase().equals("CLOSE")){
                if(commands.length!=1) {
                    System.out.println("Enter all the data correctly");
                }
                else {
                    loggedin = false;
                    if(bank.SearchEmployee(primarykey)==-1) System.out.println("Transaction Closed for " + primarykey);
                    else System.out.println("Operation for "+primarykey+" closed");
                    primarykey = "";
                }
            }

            else if(commands[0].toUpperCase().equals("OPEN")){
                if(commands.length!=2) {
                    System.out.println("Enter all the data correctly");
                }
                else if(loggedin) {
                    System.out.println("Please Close the Account to Open another!");
                }
                else {
                    if (bank.Open(commands[1])) {
                        loggedin = true;
                        primarykey = commands[1];
                    } else {
                        System.out.println("There is no account named " + commands[1]);
                    }
                }
            }

            else if(commands[0].toUpperCase().equals("APPROVE")){
                if(commands.length!=2) {
                    System.out.println("Enter all the data correctly");
                }
                else {
                    if (loggedin) bank.approve_Loan(primarykey);
                    else System.out.println("Open a account first");
                }
            }

            else if(commands[0].toUpperCase().equals("CHANGE")){
                if(commands.length!=3) {
                    System.out.println("Enter all the data correctly");
                }
                else {
                    if (loggedin) bank.change(primarykey, commands[1], Double.parseDouble(commands[2]));
                    else System.out.println("Open a account first");
                }
            }

            else if(commands[0].toUpperCase().equals("LOOKUP")){
                if(commands.length!=2) {
                    System.out.println("Enter all the data correctly");
                }
                else {
                    if (loggedin) bank.Lookup(primarykey, commands[1]);
                    else System.out.println("Open a account first");
                }
            }

            else if(commands[0].toUpperCase().equals("SEE")){
                if(commands.length!=1) {
                    System.out.println("Enter all the data correctly");
                }
                else {
                    if (loggedin) bank.See(primarykey);
                    else System.out.println("Open a account first");
                }
            }

            else if(commands[0].toUpperCase().equals("INC")){
                if(commands.length!=1) {
                    System.out.println("Enter all the data correctly");
                }
                else
                    bank.INC_operation();
            }

            else if(commands[0].toUpperCase().equals("EXIT")){
                break;
            }

        }


	// write your code here
    }
}
