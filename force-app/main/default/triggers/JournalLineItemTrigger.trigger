/*
  @Author        : Ramkumar M B
  @Name          : JournalLineItemTrigger
  @Created Date  : 15th Feb 2018
  @Description   : Trigger on JournalLineItem__c
  @version       : 1.0
*/

trigger JournalLineItemTrigger on JournalLineItem__c (after insert)
{
    if(Trigger.isAfter){
        if(Trigger.isInsert){

            JournalLineItemTriggerHandler.onAfterInsert(Trigger.new);   
            JournalLineItemTriggerHandler.insertOrUpdateEOMJournal(Trigger.new); 
        } 
    }
}