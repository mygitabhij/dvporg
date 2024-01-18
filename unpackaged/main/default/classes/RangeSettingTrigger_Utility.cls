public class RangeSettingTrigger_Utility {
    public static void beforeInsert(List<RangeSetting__c> rangeSettingRecords){
        RangeSetting__c mainRangeSetting = [Select Id,StartingNumber__c,EndingNumber__c,ResetNumber__c from RangeSetting__c where Main__c=true Order By Name Desc Limit 1];
        for(RangeSetting__c dealIdRangeSetting : rangeSettingRecords){
            System.debug('Name'+dealIdRangeSetting.Name);
            System.debug('StartingNumber__c'+dealIdRangeSetting.StartingNumber__c);
            System.debug('EndingNumber__c'+dealIdRangeSetting.EndingNumber__c);
            System.debug('ResetNumber__c'+dealIdRangeSetting.ResetNumber__c);
            if(dealIdRangeSetting.Main__c){
                if(mainRangeSetting != null){
                    dealIdRangeSetting.addError('Main Record already Exists');
                }
                dealIdRangeSetting.ResetNumber__c = getNewResetNumber()+1;
            }else{
                dealIdRangeSetting.StartingNumber__c = mainRangeSetting.StartingNumber__c;
                dealIdRangeSetting.EndingNumber__c = mainRangeSetting.EndingNumber__c;
                dealIdRangeSetting.ResetNumber__c = mainRangeSetting.ResetNumber__c;
            }
        }
    }
    public static void beforeUpdate(List<RangeSetting__c> rangeSettingRecords,Map<Id,RangeSetting__c> mapOldRangeSettings){
        for(RangeSetting__c dealIdRangeSetting : rangeSettingRecords){
            if(dealIdRangeSetting.Main__c && (dealIdRangeSetting.StartingNumber__c != mapOldRangeSettings.get(dealIdRangeSetting.Id).StartingNumber__c)){
                dealIdRangeSetting.ResetNumber__c = getNewResetNumber();
            }
        }
    }
    
    Public Static Integer getNewResetNumber(){
        RangeSetting__c dummyDealIdRangeSetting = new RangeSetting__c();
        dummyDealIdRangeSetting.Main__c = false;
        insert dummyDealIdRangeSetting;
        dummyDealIdRangeSetting = [Select Id,Name,Main__c from RangeSetting__c where Id=:dummyDealIdRangeSetting.Id];
        //String newRestNumber = dummyDealIdRangeSetting.Name;
        return Integer.valueof(((String)dummyDealIdRangeSetting.Name).trim())+1;
    }
}