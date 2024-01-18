@isTest
private class DLWC_DynamicSearchControllerTest {
    @isTest static void testMethodOne() {
        List<Account> accList = new List<Account>();
        acclist.add(new Account(Name='Test1'));
        acclist.add(new Account(Name='Test2'));
        acclist.add(new Account(Name='Test3'));
        insert acclist;
        DLWC_DynamicSearchController.fetchrecords(1,10,null,'testclass1');
    }

    @isTest static void testMethodtwo() {
        List<Account> accList = new List<Account>();
        acclist.add(new Account(Name='Test1'));
        acclist.add(new Account(Name='Test2'));
        acclist.add(new Account(Name='Test3'));
        insert acclist;

        List<Contact> conList = new List<Contact>();
        conList.add(new Contact(FirstName='Test1',LastName='Test1',email='test@1.com',AccountId=acclist[0].Id));
        conList.add(new Contact(FirstName='Test2',LastName='Test1',email='test@1.com',AccountId=acclist[0].Id));
        conList.add(new Contact(FirstName='Test3',LastName='Test1',email='test@1.com',AccountId=acclist[0].Id));
        insert conList;
        DLWC_DynamicSearchController.fetchrecords(1,10,'t','testclass2');
    }
    @isTest static void testMethodthree() {
        try{
            DLWC_DynamicSearchController.fetchrecords(1,10,null,null);
        }
        catch(Exception e){

        }
    }
    @isTest static void testMethodfour() {
       try{
            DLWC_DynamicSearchController.fetchrecords(1,10,null,'testclass4');
        }
        catch(Exception e){

        }
    }
    
    @isTest static void testMethodfive() {
       try{
            DLWC_DynamicSearchController.fetchrecords(1,10,null,'testclass3');
        }
        catch(Exception e){

        }
    }
}