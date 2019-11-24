/*
  @Author        : Sushant Shekhar
  @Name          : CalypsoDataTrigger
  @Created Date  : 22nd Dec 2017
  @Description   : Trigger on Calypso Data
  @version       : 1.0
*/ 

trigger CalypsoDataTrigger on CalypsoData__c (before insert, before update, after insert,  after update) {
                                   
    if(Trigger.isBefore){
        
        system.debug('This is before ');
        if(CYBGUtilClass.runBeforeTrigger)
        {
            system.debug('value of run '+CYBGUtilClass.runBeforeTrigger);
            if(Trigger.isInsert)
            {
                system.debug('It is before Insert');
                CalypsoDataTriggerHandler.onBeforeInsert(Trigger.new);
                CYBGUtilClass.runBeforeTrigger = false;
            }
        }
        if(CYBGUtilClass.runBeforeTrigger)
        {
            system.debug('value of run '+CYBGUtilClass.runBeforeTrigger);
            if(Trigger.isUpdate)
            {
                system.debug('It is before Update');
                CalypsoDataTriggerHandler.onBeforeUpdate(Trigger.new);
                CYBGUtilClass.runBeforeTrigger = false;
            }
        }
    }      
   
    if(Trigger.isAfter)
    {          
        if(CYBGUtilClass.runAfterTrigger){
            CYBGUtilClass.runAfterTrigger = false;
            CalypsoDataTriggerHandler cdTriggerHandler = new CalypsoDataTriggerHandler();    
            cdTriggerHandler.onAfterInsert(Trigger.new); 
        }   
    } 
  
}