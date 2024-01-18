public class StringArrayTest {

    public static List<String> generateStringArray(Integer returStrings) {
        List<String> testArray = new List<String>();
        for (Integer i=0; i < returStrings; i++){
            String testString = 'Test '+i;
            testArray.add(testString);
        }
        return testArray;
    }
}