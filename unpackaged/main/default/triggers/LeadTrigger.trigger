trigger LeadTrigger on Lead (after update) {
    for(Lead ld : (List<Lead>)trigger.new){
        if(ld.Status == 'Closed - Not Converted' && ld.Convert_The_Lead__c){
            leadTriggerHelper.leadCoversionMethod(ld);
        }
    }
}