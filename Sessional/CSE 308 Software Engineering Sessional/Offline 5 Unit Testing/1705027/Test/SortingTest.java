import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.*;


public class SortingTest {

    private static HashMap<Integer, Integer> listNumbersMap= new HashMap<>();
    private static Random random = new Random();

    public List<Integer> SortNumbers(List<Integer> list){
        int i,j;
        for(i=0;i<list.size()-1;i++){
            for(j=i+1;j<list.size();j++){
                if(list.get(i) > list.get(j)){
                    int temp;
                    temp = list.get(i);
                    list.add(i, list.get(j));
                    list.remove(i+1);
                    list.add(j, temp);
                    list.remove(j+1);
                }
            }
        }
        //printList(list);
        return list;
    }

    static void printList(List<Integer> list){
        for(int i=0;i<list.size();i++)
            System.out.println(list.get(i));
    }

    public static List<Integer> genTestCase(int size){
        List<Integer> list = new ArrayList<>();
        Random r = new Random();
        listNumbersMap.clear();

        for(int i=0;i<size;i++){
            int x=r.nextInt(size+10);
            list.add(x);
            listNumbersMap.put(x,x);
        }

        return list;
    }

    /*public static List<Character> genCharTestCase(int size){
        List<Character> list = new ArrayList<>();
        Random r = new Random();
        listNumbersMap.clear();

        for(int i=0;i<size;i++){
            char x=  (char) (random.nextInt(26) + 'a');
            list.add(x);
        }

        return list;
    }*/

    public static List<Integer> genTestCaseNeg(int size){
        List<Integer> list = new ArrayList<>();
        Random r = new Random();
        listNumbersMap.clear();

        for(int i=0;i<size;i++){
            int x=r.nextInt(size+10);
            x = -x;
            list.add(x);
            listNumbersMap.put(x,x);
        }

        return list;
    }

    public static List<Integer> genSortedTestCaseASC(int size){
        List<Integer> list = new ArrayList<>();
        Random r = new Random();
        listNumbersMap.clear();

        for(int i=1; i<=size;i++){
            int x = i+ r.nextInt(i);
            list.add(x);
            listNumbersMap.put(x,x);
        }

        return list;
    }

    public static List<Integer> genSortedTestCaseDESC(int size){
        List<Integer> list = new ArrayList<>();
        Random r = new Random();
        listNumbersMap.clear();

        for(int i=size; i>0;i--){
            int x = i+r.nextInt(i);
            list.add(x);
            listNumbersMap.put(x,x);
        }

        return list;
    }

    public static List<Integer> genTestCaseEqual(int size){
        List<Integer> list = new ArrayList<>();
        Random r = new Random();
        listNumbersMap.clear();

        int a = r.nextInt(50);
        for(int i=0; i<size;i++){
            list.add(a);
            listNumbersMap.put(a,a);
        }

        return list;
    }

    @ParameterizedTest
    @MethodSource("generateData")
    public void TestSort(String type, int size) {
        List<Integer> list=null;
        boolean listAltered = false;
        boolean correctlySorted = true;

        try {
            if (type.equalsIgnoreCase("sort") || type.equalsIgnoreCase("random")) {
                list = genTestCase(size);
            } else if (type.equalsIgnoreCase("asc")) {
                list = genSortedTestCaseASC(size);
            } else if (type.equalsIgnoreCase("desc")) {
                list = genSortedTestCaseDESC(size);
            }  else if (type.equalsIgnoreCase("equal")) {
                list = genTestCaseEqual(size);
            } else if (type.equalsIgnoreCase("negative")) {
                list = genTestCaseNeg(size);
            }

            List<Integer> sortedList = new ArrayList<>(list);
            //printList(sortedList);
            sortedList = SortNumbers(sortedList);

            for(int i=0;i<sortedList.size();i++){
                if(listNumbersMap.get(sortedList.get(i))!=sortedList.get(i)){
                    listAltered = true;
                    break;
                }
            }

            assertFalse(listAltered);

            for(int i=0;i<sortedList.size()-1;i++){
                if(sortedList.get(i)>sortedList.get(i+1)){
                    correctlySorted=false;

                    break;
                }
            }

            assertTrue(correctlySorted);

        }
        catch (Exception e){
            fail();
            System.out.println("Exception");
            e.printStackTrace();
        }

    }

    static Stream<Arguments> generateData() {
        return Stream.of(
                Arguments.of("sort", 0), //Sorting a blank list
                Arguments.of("sort", 1), //Sorting just one number
                Arguments.of("sort", 2), //Sorting two numbers
                Arguments.of("sort", random.nextInt(50)), //The size of the list is initialized randomly
                Arguments.of("random", random.nextInt(50)), //The numbers in the list is initialized randomly
                Arguments.of("asc", random.nextInt(50)), //The numbers in the is sorted in ascending order
                Arguments.of("desc", random.nextInt(50)), //The numbers in the is sorted in descending order
                Arguments.of("equal", random.nextInt(50)), //All the numbers in the list are equal

                Arguments.of("random", random.nextInt(100)), //The size of the list and the numbers in the list are initialized randomly
                Arguments.of("null", random.nextInt(100)), //null list
                Arguments.of("negative", random.nextInt(100)) //all negative numbers


        );
    }
}