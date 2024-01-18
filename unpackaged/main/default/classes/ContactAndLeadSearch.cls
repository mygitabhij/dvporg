public class ContactAndLeadSearch {
    public static List<List< SObject>> searchContactsAndLeads(String nameString){
        List<List<sObject>> searchList = [FIND :nameString IN NAME FIELDS 
                   RETURNING Contact(FirstName,LastName,Department),Lead(FirstName,LastName,Company)];
        return searchList;
    }

}