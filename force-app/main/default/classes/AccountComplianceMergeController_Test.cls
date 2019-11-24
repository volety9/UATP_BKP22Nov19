/*
  @Author        : Sushant
  @Name          : AccountComplianceMergeController_Test
  @Created Date  : 25th July 2017
  @Description   : Test Class for AccountComplianceMergeController
  @version       : 1.0
*/ 

@isTest
private class AccountComplianceMergeController_Test{
    static testMethod void testMergeSelectedCompWithMaster(){
         User u = TestData.createUser('System Administrator');
         Account targetAccount = TestData.createAccount('Target Account');
        	targetAccount.RecordType__c = 'Target';
         insert targetAccount;
         List<Compliance__c> compList = new List<Compliance__c>();
         Compliance__c complaince1 = TestData.createComp('RM Referral');
         complaince1.Customer__c = targetAccount.id;
         complaince1.Comment__c = 'Parent Comment';  
         complaince1.Compliance_Reason__c = 'Compliance - FX';
         complaince1.Date_Provided__c = System.Today();
         complaince1.How_Provided__c = 'Mail';                                                  
         compList.add(complaince1);
         Compliance__c complaince2 = TestData.createComp('RM Referral');
         complaince2.Customer__c = targetAccount.id;
         complaince2.Comment__c = 'Child Comment';  
         complaince2.Compliance_Reason__c = 'Compliance - IRRM';
         complaince2.Date_Provided__c = System.Today();
         complaince2.How_Provided__c = 'Handover';                                          
         compList.add(complaince2);
         insert compList;
         List<Attachment> insertAttach = new List<Attachment>();
         Attachment attach = TestData.createAttach('Unit Test Attachment');
         attach.parentId = compList[0].id;
         insertAttach.add(attach);
         Attachment attach1 = TestData.createAttach('Unit Test Attachment1');
         attach1.parentId = compList[1].id;
         insertAttach.add(attach1);
         insert insertAttach;
         Test.startTest();
         System.runAs(u){
             PageReference pageRef = Page.accountComplianceMerge;
             Test.setCurrentPage(pageRef);
             pageRef.getParameters().put('Id', String.valueOf(targetAccount.Id));
             ApexPages.StandardController sc = new ApexPages.StandardController(targetAccount);
             AccountComplianceMergeController testAccCompMerge = new AccountComplianceMergeController(sc);
             testAccCompMerge.getComplianceWrapperList();
             testAccCompMerge.next();
             for(ComplianceWrapper cw : testAccCompMerge.complianceWrapperList){
                 if(cw.comp.Name.equals('RM Referral')){
                     cw.checked = true;
                 }
             }  
             testAccCompMerge.next();
             for(SelectedComplianceWrapper cw : testAccCompMerge.selectedCompWrapList){
                 if(cw.label.equals(System.Label.MasterRecord)){
                     cw.parentSelected = true;
                 }
                 if(cw.label.equals(System.Label.DateProvided)){
                     cw.parentSelected = true;
                 }
                 if(cw.label.equals(System.Label.HowProvided)){
                     cw.parentSelected = true;
                 }
                 if(cw.label.equals(System.Label.ComplianceReason)){
                     cw.parentSelected = true;
                 }
                 if(cw.label.equals(System.Label.Comment)){
                     cw.parentSelected = true;
                 }
             }
             testAccCompMerge.mergeComp();
             Compliance__c mergedComp = [select Id, Comment__c from Compliance__c where Name = 'RM Referral' limit 1];
             System.assertEquals('Parent Comment', mergedComp.Comment__c);             
         }
         Test.stopTest();
     }
     static testMethod void testMergeSelectedCompWithChild(){
         User u = TestData.createUser('System Administrator');
         Account targetAccount = TestData.createAccount('Target Account');
         targetAccount.RecordType__c = 'Target';
         insert targetAccount;
         List<Compliance__c> compList = new List<Compliance__c>();
         Compliance__c complaince1 = TestData.createComp('RM Referral');
         complaince1.Customer__c = targetAccount.id;
         complaince1.Comment__c = 'Parent Comment';  
         complaince1.Compliance_Reason__c = 'Compliance - FX';
         complaince1.Date_Provided__c = System.Today();
         complaince1.How_Provided__c = 'Mail';                                                  
         compList.add(complaince1);
         Compliance__c complaince2 = TestData.createComp('RM Referral');
         complaince2.Customer__c = targetAccount.id;
         complaince2.Comment__c = 'Child Comment';  
         complaince2.Compliance_Reason__c = 'Compliance - IRRM';
         complaince2.Date_Provided__c = System.Today();
         complaince2.How_Provided__c = 'Handover';                                          
         compList.add(complaince2);
         insert compList;
         List<Attachment> insertAttach = new List<Attachment>();
         Attachment attach = TestData.createAttach('Unit Test Attachment');
         attach.parentId = compList[0].id;
         insertAttach.add(attach);
         Attachment attach1 = TestData.createAttach('Unit Test Attachment1');
         attach1.parentId = compList[1].id;
         insertAttach.add(attach1);
         insert insertAttach;
         Test.startTest();
         System.runAs(u){
             PageReference pageRef = Page.accountComplianceMerge;
             Test.setCurrentPage(pageRef);
             pageRef.getParameters().put('Id', String.valueOf(targetAccount.Id));
             ApexPages.StandardController sc = new ApexPages.StandardController(targetAccount);
             AccountComplianceMergeController  testAccCompMerge = new AccountComplianceMergeController(sc);
             testAccCompMerge.getComplianceWrapperList();
             for(ComplianceWrapper cw : testAccCompMerge.complianceWrapperList){
                 if(cw.comp.Name.equals('RM Referral')){
                     cw.checked = true;
                 }
             }  
             testAccCompMerge.next();
             for(SelectedComplianceWrapper cw : testAccCompMerge.selectedCompWrapList){
                 if(cw.label.equals(System.Label.MasterRecord)){
                     cw.childSelected = true;
                 }
                 if(cw.label.equals(System.Label.DateProvided)){
                     cw.childSelected = true;
                 }
                 if(cw.label.equals(System.Label.HowProvided)){
                     cw.childSelected = true;
                 }
                 if(cw.label.equals(System.Label.ComplianceReason)){
                     cw.childSelected = true;
                 }
                 if(cw.label.equals(System.Label.Comment)){
                     cw.childSelected = true;
                 }
             }
             testAccCompMerge.mergeComp();
             Compliance__c mergedComp = [select Id, Comment__c from Compliance__c where Name = 'RM Referral' limit 1];
             System.assertEquals('Child Comment', mergedComp.Comment__c);             
         }
         Test.stopTest();
     }
     static testMethod void testMergeAll(){
         User u = TestData.createUser('System Administrator');
         Account targetAccount = TestData.createAccount('Target Account');
         targetAccount.RecordType__c = 'Target';
         insert targetAccount;
         List<Compliance__c> compList = new List<Compliance__c>();
         Compliance__c complaince1 = TestData.createComp('RM Referral');
         complaince1.Customer__c = targetAccount.id;
         complaince1.Comment__c = 'Parent Comment';  
         complaince1.Compliance_Reason__c = 'Compliance - FX';
         complaince1.Date_Provided__c = System.Today();
         complaince1.How_Provided__c = 'Mail';                                                  
         compList.add(complaince1);
         Compliance__c complaince2 = TestData.createComp('RM Referral');
         complaince2.Customer__c = targetAccount.id;
         complaince2.Comment__c = 'Child Comment';  
         complaince2.Compliance_Reason__c = 'Compliance - IRRM';
         complaince2.Date_Provided__c = System.Today();
         complaince2.How_Provided__c = 'Handover';                                          
         compList.add(complaince2);
         insert compList;
         List<Attachment> insertAttach = new List<Attachment>();
         Attachment attach = TestData.createAttach('Unit Test Attachment');
         attach.parentId = compList[0].id;
         insertAttach.add(attach);
         Attachment attach1 = TestData.createAttach('Unit Test Attachment1');
         attach1.parentId = compList[1].id;
         insertAttach.add(attach1);
         insert insertAttach;
         Test.startTest();
         System.runAs(u){
             PageReference pageRef = Page.accountComplianceMerge;
             Test.setCurrentPage(pageRef);
             pageRef.getParameters().put('Id', String.valueOf(targetAccount.Id));
             ApexPages.StandardController sc = new ApexPages.StandardController(targetAccount);
             AccountComplianceMergeController testAccCompMerge = new AccountComplianceMergeController(sc);
             testAccCompMerge.mergeAllComp();  
             List<Compliance__c> compListcheck = new List<Compliance__c>();
             compListcheck = [select Id from Compliance__c where Name = 'RM Referral'];
             System.assertEquals(1,compListcheck.size());        
         }
         Test.stopTest();
     }
     static testMethod void testMergeSelectedCompWithMasterCYB(){
         User u = TestData.createUser('CYB');
         Account targetAccount = TestData.createAccount('Target Account');
         targetAccount.RecordType__c = 'Target';
         insert targetAccount;
         List<Compliance__c> compList = new List<Compliance__c>();
         Compliance__c complaince1 = TestData.createComp('RM Referral');
         complaince1.Customer__c = targetAccount.id;
         complaince1.Comment__c = 'Parent Comment';  
         complaince1.Compliance_Reason__c = 'Compliance - FX';
         complaince1.Date_Provided__c = System.Today();
         complaince1.How_Provided__c = 'Mail';                                                  
         compList.add(complaince1);
         Compliance__c complaince2 = TestData.createComp('RM Referral');
         complaince2.Customer__c = targetAccount.id;
         complaince2.Comment__c = 'Child Comment';  
         complaince2.Compliance_Reason__c = 'Compliance - IRRM';
         complaince2.Date_Provided__c = System.Today();
         complaince2.How_Provided__c = 'Handover';                                          
         compList.add(complaince2);
         insert compList;
         List<Attachment> insertAttach = new List<Attachment>();
         Attachment attach = TestData.createAttach('Unit Test Attachment');
         attach.parentId = compList[0].id;
         insertAttach.add(attach);
         Attachment attach1 = TestData.createAttach('Unit Test Attachment1');
         attach1.parentId = compList[1].id;
         insertAttach.add(attach1);
         insert insertAttach;
         Test.startTest();
         System.runAs(u){
             PageReference pageRef = Page.accountComplianceMerge;
             Test.setCurrentPage(pageRef);
             pageRef.getParameters().put('Id', String.valueOf(targetAccount.Id));
             ApexPages.StandardController sc = new ApexPages.StandardController(targetAccount);
             AccountComplianceMergeController testAccCompMerge = new AccountComplianceMergeController(sc);
             testAccCompMerge.getComplianceWrapperList();
             for(ComplianceWrapper cw : testAccCompMerge.complianceWrapperList){
                 if(cw.comp.Name.equals('RM Referral')){
                     cw.checked = true;
                 }
             }  
             testAccCompMerge.next();
             for(SelectedComplianceWrapper cw : testAccCompMerge.selectedCompWrapList){
                 if(cw.label.equals(System.Label.MasterRecord)){
                     cw.parentSelected = true;
                 }
                 if(cw.label.equals(System.Label.DateProvided)){
                     cw.parentSelected = true;
                 }
                 if(cw.label.equals(System.Label.HowProvided)){
                     cw.parentSelected = true;
                 }
                 if(cw.label.equals(System.Label.ComplianceReason)){
                     cw.parentSelected = true;
                 }
                 if(cw.label.equals(System.Label.Comment)){
                     cw.parentSelected = true;
                 }
             }
             testAccCompMerge.mergeComp();
             Compliance__c mergedComp = [select Id, Comment__c from Compliance__c where Name = 'RM Referral' limit 1];
             System.assertEquals('Parent Comment', mergedComp.Comment__c);             
         }
         Test.stopTest();
     }
     static testMethod void testMergeAllCYB(){
         User u = TestData.createUser('CYB');
         Account targetAccount = TestData.createAccount('Target Account');
         targetAccount.RecordType__c = 'Target';
         insert targetAccount;
         List<Compliance__c> compList = new List<Compliance__c>();
         Compliance__c complaince1 = TestData.createComp('RM Referral');
         complaince1.Customer__c = targetAccount.id;
         complaince1.Comment__c = 'Parent Comment';  
         complaince1.Compliance_Reason__c = 'Compliance - FX';
         complaince1.Date_Provided__c = System.Today();
         complaince1.How_Provided__c = 'Mail';                                                  
         compList.add(complaince1);
         Compliance__c complaince2 = TestData.createComp('RM Referral');
         complaince2.Customer__c = targetAccount.id;
         complaince2.Comment__c = 'Child Comment';  
         complaince2.Compliance_Reason__c = 'Compliance - IRRM';
         complaince2.Date_Provided__c = System.Today();
         complaince2.How_Provided__c = 'Handover';                                          
         compList.add(complaince2);
         insert compList;
         List<Attachment> insertAttach = new List<Attachment>();
         Attachment attach = TestData.createAttach('Unit Test Attachment');
         attach.parentId = compList[0].id;
         insertAttach.add(attach);
         Attachment attach1 = TestData.createAttach('Unit Test Attachment1');
         attach1.parentId = compList[1].id;
         insertAttach.add(attach1);
         insert insertAttach;
         Test.startTest();
         System.runAs(u){
             PageReference pageRef = Page.accountComplianceMerge;
             Test.setCurrentPage(pageRef);
             pageRef.getParameters().put('Id', String.valueOf(targetAccount.Id));
             ApexPages.StandardController sc = new ApexPages.StandardController(targetAccount);
             AccountComplianceMergeController testAccCompMerge = new AccountComplianceMergeController(sc);
             testAccCompMerge.mergeAllComp();  
             List<Compliance__c> compListcheck = new List<Compliance__c>();
             compListcheck = [select Id from Compliance__c where Name = 'RM Referral'];
             System.assertEquals(2,compListcheck.size());        
         }
         Test.stopTest();
     }
}