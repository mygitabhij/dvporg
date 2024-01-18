trigger RangeSetting_Trigger on RangeSetting__c (before insert,before update) {
    if(trigger.isBefore){
        if( Trigger.isInsert){
            RangeSettingTrigger_Utility.beforeInsert(Trigger.New);
        }
        if(Trigger.isUpdate ){
            RangeSettingTrigger_Utility.beforeUpdate(Trigger.New,Trigger.oldMap);
        }
    }
}