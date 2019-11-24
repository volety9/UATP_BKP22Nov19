/*
@Author        : Ramkumar and Santhoshan
@Name          : OpportunityTrigger 
@Created Date  : 20th December 2017
@Description   : Trigger on Opportunity 
@version       : 1.0
*/ 
trigger OpportunityTrigger on Opportunity (before insert,before update,after insert, after update) 
{
    if(trigger.isBefore)
    {
        if(Trigger.isInsert){            
            OpportunityTriggerHandler.onBeforeInsert(Trigger.new);                                         
        } 
    }
    if(trigger.isAfter){            
        if(Trigger.isInsert){    
            OpportunityTriggerHandler  handlerObject = new OpportunityTriggerHandler();
            handlerObject.onAfterInsert(Trigger.new);                                 
        }  
        system.debug('cybg firstrun' +CYBGUtilClass.firstRun);
        if(CYBGUtilClass.firstRun){ // BY KRISHNA ON 25/08/2019
           system.debug('oppty after upate');
            if(Trigger.isUpdate){      
                OpportunityTriggerHandler  handlerObject = new OpportunityTriggerHandler();
                handlerObject.onAfterUpdate(Trigger.new);                    
            }
            CYBGUtilClass.firstRun = false; //BY KRISHNA 25/08/2019
        }  
    }
}