public class leadTriggerHelper {
    public static PageReference leadCoversionMethod(Lead ld){      

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.Id);
        lc.setDoNotCreateOpportunity(True);
        lc.setConvertedStatus('Closed - Converted');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Id AccId = lcr.getAccountId();
        Id conId = lcr.getContactId();
        //String sServerName = ApexPages.currentPage().getHeaders().get('Host');
        //sServerName = 'https://' + sServerName + '/';
        //PageReference pageRef = new PageReference('https://chasecorrespondent--pbrinker.my.salesforce.com/'+ConId);
        PageReference pageRef = new PageReference('/'+ conId );
        system.debug('pageRef........'+pageRef);
        aura.redirect(pageRef);
        //pageRef.setRedirect(true);
        return pageRef;
    }
}