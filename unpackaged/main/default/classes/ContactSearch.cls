public class ContactSearch {
    
    public static List<Contact> searchForContacts(String lName, String pCode){
        List<Contact> conList = [SELECT Id, Name FROM Contact where LastName=:lName AND MailingPostalCode=:pCode];
            return conList;
    }
}