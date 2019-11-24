/*
  @Author        : Ramkumar M B
  @Name          : TSMTargetTrigger
  @Created Date  : 21st Feb 2018
  @Description   : Trigger on TSMTarget__c
  @version       : 1.0
*/
trigger TSMTargetTrigger on TSMTarget__c (before insert, before update) 
{    
    if(Trigger.isBefore){
        if(Trigger.isInsert){        
            TSMTargetTriggerHandler.onBeforeInsert(Trigger.new); 
        }
        if(!system.isBatch()){
            if(Trigger.isUpdate){        
                TSMTargetTriggerHandler.onBeforeUpdate(Trigger.new); 
            }
        }
    }
}