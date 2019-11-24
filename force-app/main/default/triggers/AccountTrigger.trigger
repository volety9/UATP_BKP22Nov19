/*
  @Author        : Ramkumar and Santhoshan
  @Name          : AccountTrigger 
  @Created Date  : 22th December 2017
  @Description   : Trigger on Account 
  @version       : 1.0
*/ 

trigger AccountTrigger on Account (before Update,before Insert, after update) 
{
    System.debug('Entering the Account Trigger static variable'+CYBGUtilClass.accountFirstRun);
    
            
    if(trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
        AccountTriggerHandler  handlerObjectVar = new AccountTriggerHandler ();
        handlerObjectVar.onBeforeInsert(Trigger.new);
        }
        
        if(Trigger.isUpdate)
        {
        AccountTriggerHandler  handlerObjectVar = new AccountTriggerHandler ();
        handlerObjectVar.onBeforeUpdate(Trigger.new);
        }
        
        
    }
    
    if(trigger.isAfter)
    {
        
    if(Trigger.isInsert)
    {
        
        //Do Nothing
        
                
    }
   /*If(CYBGUtilClass.accountFirstRun)
    {*/
        system.debug('Entered the Update loop');
    if(Trigger.isUpdate)
    {
        AccountTriggerHandler  handlerObject = new AccountTriggerHandler ();
        handlerObject.onAfterUpdate(Trigger.new);
        
        //helperObj.createUpdateJournal();
        
                
    } 
  /* CYBGUtilClass.accountFirstRun = false;
  System.debug('Ennd of the Account Trigger static variable'+CYBGUtilClass.accountFirstRun);    
}
*/    
    }
    
}