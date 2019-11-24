/*
  @Author        : Ramkumar M B 
  @Name          : RegionTrigger 
  @Created Date  : 12 February 2018
  @Description   : Trigger on Region 
  @version       : 1.0
*/ 
trigger RegionTrigger on Region__c (after insert, after update,before update) 
{ 
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            RegionTriggerHandler.onAfterInsert(Trigger.new);
            
        } 
   
        if(Trigger.isUpdate)
        {
            RegionTriggerHandler.onAfterUpdate(Trigger.new);
            
        } 
    }
}