/*
@Author        : SUHAS BARGI
@Name          : ContactTriggerHandlerTest
@Created Date  : 4th APRIL 2018
@Description   : This is a test Class for ContactTriggerHandler 
@version       : 1.0
*/ 

@isTest
public class ContactTriggerHandlerTest
{
    /**
* @description       test method for contact Insert and Update
* @name              createContactTestData
* @param             null
* @return            void
* @throws            NA
*/ 
    static TestMethod void createContactTestData()
    {
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        
        Group__c groups = TestData.createGroup();
        insert groups;
        
        Division__c division = TestData.createDivision();
        division.Div_Group__c = groups.Id;
        insert division;
        
        Region__c region = TestData.createRegion();
        region.Region_Division__c = division.id;
        insert region;
        
        Centre__c centre = TestData.createCentre();
        centre.Centre_Region__c = region.Id;
        insert centre;
        
        Team__c team = TestData.createTeam();
        team.Name = 'Test Team';
        team.Team_Centre__c = centre.Id;
        insert team;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        con.TDM_Name__c='Test1 Con Inn';
        con.TDM_BankingCenter__c='Birmingham';

        insert con;
        
        Contact con1 = TestData.createContact('12345', RecordTypeIdContactBanker, accint.Id);
        con1.Con_Team__c = team.id;
        con1.TDM_Name__c='Test1COMM';
        con1.TDM_BankingCenter__c='Birmingham';

        insert con1;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c=con.id;
        acc.RecordType__c = 'Customer';
        insert acc;
        
        
        

        con.TDM_Name__c='Test2 Con Inn';
        update con;

        

        con.TDM_Name__c='Test2';
        update con;

           
        
        
    }
}