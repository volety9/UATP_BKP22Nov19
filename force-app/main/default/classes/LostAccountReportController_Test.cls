/*
  @Author        : Suhas
  @Name          : LostAccountReportController_Test
  @Created Date  : 17th May 2018
  @Description   : Test Class for LostAccountReportController
  @version       : 1.0
*/
@isTest
public class LostAccountReportController_Test {
    
    
    /**
* @description       Test method to check Account Update if the associated Contact is updated.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static TestMethod void LostAccountReportController_Test(){
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> newoppList = new List<Opportunity>();
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        
        User testUser = new user(ID = UserInfo.getUserID());
        
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
        
        /*Team__c team2 = TestData.createTeam();
        team2.Name = 'Test Team';
        team2.Team_Centre__c = centre.Id;
        insert team2;*/
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        insert accint;
        
        Contact con = TestData.createContact('1234999', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        /*Contact consec = TestData.createContact('2345999', RecordTypeIdContactBanker, accint.Id);
        consec.Con_Team__c = team2.id;
        insert consec;*/
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c=con.id;
        acc.RecordType__c = 'Customer';
        acc.Customer_Status__c='Lost';
        acc.Lost_Reason__c='Test Lost Account';
        insert acc;
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        for(integer i=0;i<10;i++)
        {
            Opportunity opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 1500, 1500);
            opp.Opp_TradeId__c='1234'+i;
            opp.Deal_Executed_By__c = con.id;
            opp.StageName = 'Closed Won';
            oppList.add(opp);
        }
        
        
        Test.startTest();
        insert oppList;

        
        LostAccountReportController lstAccController = new LostAccountReportController();
        LostAccountReportController.WrapperClass innerClass = new LostAccountReportController.WrapperClass('Test Lost Acc',100.00,100.00,5,100.00,100.00,
                            2,10,10);
         lstAccController.downloadReport();
        
      
        Test.stopTest();
    }
}