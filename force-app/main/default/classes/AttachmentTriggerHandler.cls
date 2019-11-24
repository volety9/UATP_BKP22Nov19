/*
  @Author        : Ramya
  @Name          : AttachmentTriggerHandler
  @Created Date  : 28 June 2017
  @Description   : This is a handler class for the AttachmentTrigger 
  @version       : 1.0
*/ 
public class AttachmentTriggerHandler{

    
/**
     * @description       Method to check if the logged in user is Super User, if not super user then throw an error    
     * @name              onBeforeDelete
     * @param             List<Attachment> attachmentList
     * @return            void
     * @throws            NA
     */ 
    public static void onBeforeDelete(List<Attachment> attachmentList) {
        PermissionSet ps = [SELECT Id, Name from PermissionSet WHERE Name = 'Super_User' limit 1];
        List<PermissionSetAssignment > assignedSuperUserPS =  [select id, AssigneeId, PermissionSetId from PermissionSetAssignment where AssigneeId =: userinfo.getuserid() AND PermissionSetId =:ps.id];
        for (Attachment record : attachmentList){
            if (String.isNotBlank(record.Id) && assignedSuperUserPS.isEmpty()){
                record.addError(System.Label.Prevent_Deletion_Error_Message);
            }
        }
    }
}