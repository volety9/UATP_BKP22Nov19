/*
  @Author        : Sushant
  @Name          : AttachmentTriggerHandler_Test
  @Created Date  : 25th July 2017
  @Description   : Test class for AttachmentTriggerHandler
  @version       : 1.0
*/ 

@isTest
private class AttachmentTriggerHandler_Test{
    static testMethod void testAttachDeleteByCYB()
    {
        User u = TestData.createUser('CYB');
        Compliance__c complaince = TestData.createComp('RM Referral');        
        insert complaince;
        
        Attachment attach = TestData.createAttach('Unit Test Attachment'); 
        attach.parentId=complaince.id;
        insert attach;
        Test.startTest();
        System.runAs(u) 
        {
            try{
                delete attach;
            }
            Catch(DMLException exp){
                System.assert(exp.getMessage().contains(System.Label.Prevent_Deletion_Error_Message));
            }
        }
        Test.stopTest();
    }       
}