/*
  @Author        : Sushant Shekhar 
  @Name          : PMTargetTrigger
  @Created Date  : 21st Feb 2018
  @Description   : Trigger on PMTarget__c
  @version       : 1.0
*/trigger PMTargetTrigger on PMTarget__c (before insert, before update)
{
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            PMTargetTriggerHandler.onBeforeInsert(Trigger.new);            
        }
        if(!system.isBatch()){
            if(Trigger.isUpdate){
                PMTargetTriggerHandler.onBeforeUpdate(Trigger.new);            
            }
        }
    }    
}