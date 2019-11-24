/*
  @Author        : SUHAS BARGI
  @Name          : ContactTrigger
  @Created Date  : 30th MARCH 2018
  @Description   : Trigger on Contact
  @version       : 1.0
*/ 

trigger ContactTrigger on Contact (before insert, before update) {
                                   
    if(Trigger.isBefore){

            if(Trigger.isInsert){
                ContactTriggerHandler.onBeforeInsert(Trigger.new);
            }


            if(Trigger.isUpdate){
                ContactTriggerHandler.onBeforeUpdate(Trigger.new);
            }

    }      
             
}