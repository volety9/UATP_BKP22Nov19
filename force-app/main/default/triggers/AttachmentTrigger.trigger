/*
  @Author        : Sushant
  @Name          : AttachmentTrigger 
  @Created Date  : 10th July 2017
  @Description   : Trigger on Attachment 
  @version       : 1.0
*/ 

trigger AttachmentTrigger on Attachment (before delete) {
    if(trigger.isBefore){   
        if(trigger.isDelete){
            //To check if the logged in user is Super user or not, If not super user then throw an error 
            AttachmentTriggerHandler.onBeforeDelete(trigger.old);
        }
    }
}