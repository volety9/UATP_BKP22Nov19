/*
  @Author        : Sushant
  @Name          : TestData_Test
  @Created Date  : 25th July 2017
  @Description   : Test class for TestData
  @version       : 1.0
*/ 
@isTest
private class TestData_Test{
    static testMethod Void TestDataTest(){
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdContactContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        TestData.createUser('CYB');
        Account acc = TestData.createAccount('Target Account');
        TestData.createComp('RM Referral');
        TestData.createAttach('Attachment');
        TestData.createMGRUser('CYB');
        TestData.createCustomerAccount('Test',RecordTypeIdAccountCustomer);
        TestData.createCalypsoAccount('Test', '1234', '1234', RecordTypeIdContactContact, RecordTypeIdAccountCustomer);
        TestData.createCalypsoAccountInternal('Test', RecordTypeIdAccountInternal);
        TestData.createCalypsoData();
        Contact con = TestData.createContact('1234', RecordTypeIdContactContact, acc.id);
        TestData.createContactContact('Test', RecordTypeIdContactContact, acc.id);
        Checklist__c checkList = TestData.createChecklist(acc.id);
        Opportunity opp = TestData.createOpportunity(acc.id, con, checkList.id, RecordTypeIdOpportunityCRM, 1500, 1500);
        TestData.createOpportunityTradeID(acc.id, con, checkList.id, RecordTypeIdOpportunityCRM, 1500, 1500, '1234');
        TestData.createGroup();
        TestData.createDivision();
        TestData.createRegion();
        TestData.createCentre();
        TestData.createTeam();
        TestData.createTSMTarget();
        TestData.createPMMTarget();
        TestData.createJournal(opp.id,1500.00);
    }
}