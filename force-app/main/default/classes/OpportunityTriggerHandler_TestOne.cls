/*
@Author        : Sandeep
@Name          : OpportunityTrigger_Test
@Created Date  : 24th June 2019
@Description   : This is a Test Class for OpportunityTriggerHandler
@version       : 1.0
*/
@isTest
public class OpportunityTriggerHandler_TestOne {
    
    /**
* @description       Test method to check if the Journals are getting created or not.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static TestMethod void createOpportunity_Test(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityFxCash = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        team.Team_Status__c = 'Active';
        insert team;
        
        Contact co = new Contact();
        co.Con_Team__c = team.id;
        insert co;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        accint.OwnerId = tsmUser1.Id;
        accint.FX_Manager__c = co.Id;       
        insert accint;
        
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Contact con1 = TestData.createContact('12345', RecordTypeIdContactBanker, accint.Id);
        con1.Con_Team__c = team.id;
        insert con1;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c = conint.Id;
        acc.IRRM_Manager__c = conint.Id;
        acc.Commodity_Manager__c = conint.Id;
        acc.RecordType__c = 'Customer';
        acc.OwnerId = tsmUser1.Id;        
        insert acc;
       
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFxCash, 1500, 1500);
        opp.StageName = 'New Opportunity';
        opp.opp_TradeID__c='1234';
        opp.Deal_Executed_By__c = con.id;
        oppList.add(opp);
        
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityIRRM, 1600, 1400);
        opp1.StageName = 'New Opportunity';
        opp1.opp_TradeID__c='12345';
        opp1.Deal_Executed_By__c = con.id;
        oppList.add(opp1);        
        
        insert oppList;       
        
        CYBGUtilClass.firstRun = true;
        Opportunity oppo = new Opportunity();
        oppo.Id = opp1.Id;
        oppo.StageName='Closed Won';
        oppo.Appropriateness_Assessment_Undertaken__c = true;
        oppo.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        oppo.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        oppo.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(oppo);
        
        Test.startTest();
       
        update oppListUpdate;
       
        Test.stopTest();
        
        AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
        System.assertEquals(1, arJnl[0].get('total'));        
        
    }
    
    /**
* @description       Test method to check if the Journals and the Reversals are getting created
* 							or not if the Opportunity Amount is updated.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static TestMethod void updateAmount_Test(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Database.SaveResult[] srList;
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeIdOpportunityFxCash = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        con.Con_Team__c = team.Id;
        insert con;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.Commodity_Manager__c = con.id;
        acc.IRRM_Manager__c = con.id;
        acc.FX_Manager__c=con.id;
        acc.RecordType__c = 'Customer';
        insert acc;
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Checklist__c chkListIRRM = TestData.createChecklist(acc.id);
        chkListIRRM.File_Checker__c = testUser.Id;
        chkListIRRM.Product__c = 'IRRM';
        insert chkListIRRM;
        
        Checklist__c chkListCommodity = TestData.createChecklist(acc.id);
        chkListCommodity.File_Checker__c = testUser.Id;
        chkListCommodity.Product__c = 'Commodity';
        insert chkListCommodity;
        
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 1500, 1500);
        opp.opp_TradeID__c='1234';
        opp.Deal_Executed_By__c = con.id;
        opp.StageName = 'New Opportunity';
        
        oppList.add(opp);
        Opportunity opp2 = TestData.createOpportunity(acc.id, con, chkListCommodity.Id, RecordTypeIdOpportunityCommodity, 0, 0);
        opp2.opp_TradeID__c='1235';
        opp2.Deal_Executed_By__c = con.id;
        opp2.Amount=0;
        opp2.StageName = 'Closed Won';
        opp2.Appropriateness_Assessment_Undertaken__c = true;
        opp2.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp2.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp2.TRID_Reference__c = 'Customer TR';
        oppList.add(opp2);
        Opportunity opp3 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityFxCash, 100, 100);
        opp3.opp_TradeID__c='1236';
        opp3.Deal_Executed_By__c = con.id;
        opp3.StageName = 'Closed Won';
        opp3.Appropriateness_Assessment_Undertaken__c = true;
        opp3.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp3.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp3.TRID_Reference__c = 'Customer TR';
        oppList.add(opp3);
        Opportunity opp4 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 0, 0);
        opp4.opp_TradeID__c='1237';
        opp4.Deal_Executed_By__c = con.id;
        opp4.Amount=100;
        opp4.Face_Value_Amount__c=100;
        opp4.StageName = 'Closed Won';
        opp4.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp4.Appropriateness_Assessment_Undertaken__c = true;
        opp4.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp4.TRID_Reference__c = 'Customer TR';
        oppList.add(opp4);
        Opportunity opp5 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityFxCash, 0, 0);
        opp5.opp_TradeID__c='1238';
        opp5.Deal_Executed_By__c = con.id;
        opp5.StageName = 'Closed Won';
        opp5.Appropriateness_Assessment_Undertaken__c = true;
        opp5.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp5.Face_Value_Amount__c=100;
        opp5.Amount=100;
        opp5.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp5.TRID_Reference__c = 'Customer TR';
        oppList.add(opp5);
        Opportunity opp6 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCommodity, 100, 100);
        opp6.opp_TradeID__c='12399';
        opp6.Deal_Executed_By__c = con.id;
        opp6.StageName = 'Closed Won';
        opp6.Appropriateness_Assessment_Undertaken__c = true;
        opp6.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp6.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp6.TRID_Reference__c = 'Customer TR';
        opp6.Face_Value_Amount__c=100;
        opp6.Amount=100;
        oppList.add(opp6);
        
        Test.startTest();
        
        insert oppList;        
        
        CYBGUtilClass.firstRun = true;
        opp.StageName = 'Closed Won';
        opp.Face_Value_Amount__c=2500;
        opp.Appropriateness_Assessment_Undertaken__c = true;
        opp.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp.Amount=2500;
        
        oppListUpdate.add(opp);
        
        opp2.Face_Value_Amount__c=2500;
        opp2.Amount=2500;
		opp2.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp2);
        
        opp3.Face_Value_Amount__c=0;
        opp3.Amount=0;
        oppListUpdate.add(opp3);
        
        opp4.StageName = 'Closed Won';
        opp4.Face_Value_Amount__c=2500;
        opp4.Amount=2500;
        opp4.Appropriateness_Assessment_Undertaken__c = true;
        opp4.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp4.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp4.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp4);
        
        opp5.StageName = 'Closed Won';
        opp5.Appropriateness_Assessment_Undertaken__c = true;
        opp5.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp5.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp5.TRID_Reference__c = 'Customer TR';
        opp5.Face_Value_Amount__c=0;
        opp5.Amount=0;
        oppListUpdate.add(opp5);
        
        opp6.Face_Value_Amount__c=2500;
        opp6.Amount=2500;
        oppListUpdate.add(opp6);
        try{
            srList = Database.update(oppListUpdate, false);
        }
        catch(Exception e)
        {
            System.debug('The Exception is '+e);
        }
        
        oppListUpdate[4].Amount=1200;
        update oppListUpdate[4];
        Test.stopTest();
        List<JournalLineItem__c> journalLineItemsList = [SELECT Name, Journal_Amount__c, Journal_TransactionType__c 
                                                         FROM JournalLineItem__c];
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted Opportunity. Opportunity ID: ' + sr);
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity fields that affected this error: ' + err.getFields());
                }
            }
        }
        
        System.assertEquals(12, journalLineItemsList.size());
        
    }
    
    /**
* @description       Test method to check if the Journals are created when there are no Journals
* 							and Opportunity is updated.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    
    static TestMethod void createOpportunityEmptyJournal_Test(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        accint.OwnerId = tsmUser1.Id;
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c=con.id;
        acc.RecordType__c='Customer';
        acc.OwnerId = tsmUser1.Id;
        acc.IRRM_Manager__c = con.id;
        insert acc;
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityIRRM, 1500, 1500);
        opp.StageName = 'New Opportunity';
        opp.opp_TradeID__c='1239';
        opp.Deal_Executed_By__c = con.id;
        oppList.add(opp);
        
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityIRRM, 0, 0);
        opp1.StageName = 'Closed Won';
        opp1.opp_TradeID__c='1230';
        opp1.Deal_Executed_By__c = con.id;
        opp1.Appropriateness_Assessment_Undertaken__c = true;
        opp1.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp1.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp1.TRID_Reference__c = 'Customer TR';
        oppList.add(opp1);
        
        insert oppList;      
        
        List<JournalLineItem__c> jList = [SELECT Name, Journal_Amount__c, Journal_TransactionType__c FROM JournalLineItem__c];
        delete jList;
        Opportunity opp2 = [Select Id,Amount From Opportunity where amount = 0];
        
        CYBGUtilClass.firstRun = true;
        
        opp.Face_Value_Amount__c=2500;
        opp.StageName = 'Closed Won';
        opp.Amount=2500;
        opp.Appropriateness_Assessment_Undertaken__c = true;
        opp.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp.TRID_Reference__c = 'Customer TR';
        opp1.Amount = 100;
        oppListUpdate.add(opp);
        //oppListUpdate.add(opp2);
        
        Test.startTest();
        try{
            update oppListUpdate;
        }
        catch(Exception e)
        {
            System.debug('The Exception is '+e);
        }
        Test.stopTest();
        
        AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
        System.assertEquals(1, arJnl[0].get('total'));
        
    }
    
    /**
* @description       Test method to check if the TSMTarget & PMTarget created or not.
* @name              createTSMTarget_Test
* @param             NA 
* @return            Void
* @throws            NA
*/ 
    static TestMethod void createTSMTarget_Test(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        team.Team_Status__c = 'Active';
        insert team;
        
        Team__c team1 = TestData.createTeam();
        team1.Name = 'CB';
        team1.Team_Centre__c = centre.Id;
        team1.Team_Status__c = 'Active';
        insert team1;
        
        Team__c team2 = TestData.createTeam();
        team2.Name = 'YB';
        team2.Team_Centre__c = centre.Id;
        team2.Team_Status__c = 'Active';
        insert team2;
        
        Contact co = new Contact();
        co.Con_Team__c = team.id;
        insert co;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        accint.OwnerId = testUser.Id;
        accint.FX_Manager__c = co.Id;       
        insert accint;
        
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Contact con1 = TestData.createContact('12345', RecordTypeIdContactBanker, accint.Id);
        con1.Con_Team__c = team.id;
        insert con1;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c = conint.Id;
        acc.IRRM_Manager__c = conint.Id;
        acc.Commodity_Manager__c = conint.Id;
        acc.RecordType__c = 'Customer';
        acc.OwnerId = tsmUser1.Id;
        insert acc;
        
        List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
        
        Integer year = date.today().year();
        Date tsmstartdate = Date.newInstance(year,10, 01);
        Date tsmenddate = Date.newInstance(year+1,09, 30);
        
        TSMTarget__c tsm = new TSMTarget__c();
        tsm.TSMTar_TSM__c = tsmUser1.Id;
        tsm.TSMTar_Status__c = 'Active';
        tsm.TSMTar_Team__c = team.Id;
        tsm.TSMTar_PseudoTarget__c = true;
        tsm.TSMTar_StartDate__c = tsmstartdate;
        tsm.TSMTar_EndDate__c = tsmenddate;
        tsm.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm); 
        
        TSMTarget__c tsm1 = new TSMTarget__c();
        tsm1.TSMTar_TSM__c = tsmUser1.Id;
        tsm1.TSMTar_Status__c = 'Active';
        tsm1.TSMTar_Team__c = team1.Id;
        tsm1.TSMTar_PseudoTarget__c = true;
        tsm1.TSMTar_StartDate__c = tsmstartdate;
        tsm1.TSMTar_EndDate__c = tsmenddate;
        tsm1.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm1);   
        
        TSMTarget__c tsm2 = new TSMTarget__c();
        tsm2.TSMTar_TSM__c = tsmUser1.Id;
        tsm2.TSMTar_Status__c = 'Active';
        tsm2.TSMTar_Team__c = team2.Id;
        tsm2.TSMTar_PseudoTarget__c = true;
        tsm2.TSMTar_StartDate__c = tsmstartdate;
        tsm2.TSMTar_EndDate__c = tsmenddate;
        tsm2.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm2);
        
        insert tsmTargetList;
        
        List<PMTarget__c> pmTargetList = new List<PMTarget__c>(); 
        Integer pmyear = date.today().year();
        Date pmstartdate = Date.newInstance(pmyear,10, 01);
        Date pmenddate = Date.newInstance(pmyear+1,09, 30);
        
        PMTarget__c pmt = new PMTarget__c();
        pmt.PMTar_PMContact__c = conint.id;
        pmt.PMTar_PMUser__c = tsmUser1.Id;
        pmt.PMTar_Status__c = 'Active';
        pmt.PMTar_StartDate__c = System.Today();
        pmt.PMTar_EndDate__c = System.Today().AddDays(1);
        pmt.PMTar_FiscalYear__c = 'FY19';
        pmt.PMTar_FYStartDate__c = pmstartdate;
        pmt.PMTar_FYEndDate__c = pmenddate;
        pmTargetList.add(pmt);
        
        PMTarget__c pmt1 = new PMTarget__c();
        pmt1.PMTar_PMContact__c = conint.id;
        pmt1.PMTar_Status__c = 'Active';
        pmt1.PMTar_PMUser__c = tsmUser1.Id;
        pmt1.PMTar_StartDate__c = pmstartdate;
        pmt1.PMTar_EndDate__c = pmenddate;
        pmTargetList.add(pmt1);
        
        PMTarget__c pmt2 = new PMTarget__c();
        pmt2.PMTar_PMContact__c = conint.id;
        pmt2.PMTar_Status__c = 'Active';
        pmt2.PMTar_PMUser__c = tsmUser1.Id;
        pmt2.PMTar_StartDate__c = pmstartdate;
        pmt2.PMTar_EndDate__c = pmenddate;
        pmTargetList.add(pmt2);
        
        insert pmTargetList;
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCommodity, 1500, 1500);
        opp.StageName = 'New Opportunity';
        opp.opp_TradeID__c='1234';
        opp.Deal_Executed_By__c = con.id;
        oppList.add(opp);
        
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityIRRM, 1600, 1400);
        opp1.StageName = 'New Opportunity One';
        opp1.opp_TradeID__c='12345';
        opp1.Deal_Executed_By__c = con.id;
        oppList.add(opp1);
        
        insert oppList;
        
        CYBGUtilClass.firstRun = true;
        opp.StageName='Closed Won';
        opp.Appropriateness_Assessment_Undertaken__c = true;
        opp.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp);
        
        Test.startTest();
        
        update oppListUpdate;
        
        Test.stopTest();
        
        AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
        System.assertEquals(1, arJnl[0].get('total'));       
    } 
    
    /**
* @description       Test method to check if the Opportunity Update.
* @name              createTSMTarget_Test
* @param             NA 
* @return            Void
* @throws            NA
*/     
    static TestMethod void updateOpportunityDetails_Test(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Database.SaveResult[] srList;
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        
        Team__c team1 = TestData.createTeam();
        team1.Name = 'CB';
        team1.Team_Centre__c = centre.Id;
        team1.Team_Status__c = 'Active';
        insert team1;
        
        Team__c team2 = TestData.createTeam();
        team2.Name = 'YB';
        team2.Team_Centre__c = centre.Id;
        team2.Team_Status__c = 'Active';
        insert team2;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        accint.OwnerId = tsmUser1.Id;
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.Id;
        insert con;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.Commodity_Manager__c = con.id;
        acc.IRRM_Manager__c = con.id;
        acc.FX_Manager__c=con.id;
        acc.RecordType__c = 'Customer';
        acc.OwnerId = tsmUser1.Id;
        insert acc;
        
        List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
        
        Integer year = date.today().year();
        Date tsmstartdate = Date.newInstance(year,10, 01);
        Date tsmenddate = Date.newInstance(year+1,09, 30);
        
        TSMTarget__c tsm = new TSMTarget__c();
        tsm.TSMTar_TSM__c = tsmUser1.Id;
        tsm.TSMTar_Status__c = 'Active';
        tsm.TSMTar_Team__c = team.Id;
        tsm.TSMTar_PseudoTarget__c = true;
        tsm.TSMTar_StartDate__c = tsmstartdate;
        tsm.TSMTar_EndDate__c = tsmenddate;
        tsm.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm); 
        
        TSMTarget__c tsm1 = new TSMTarget__c();
        tsm1.TSMTar_TSM__c = tsmUser1.Id;
        tsm1.TSMTar_Status__c = 'Active';
        tsm1.TSMTar_Team__c = team1.Id;
        tsm1.TSMTar_PseudoTarget__c = true;
        tsm1.TSMTar_StartDate__c = tsmstartdate;
        tsm1.TSMTar_EndDate__c = tsmenddate;
        tsm1.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm1);   
        
        TSMTarget__c tsm2 = new TSMTarget__c();
        tsm2.TSMTar_TSM__c = tsmUser1.Id;
        tsm2.TSMTar_Status__c = 'Active';
        tsm2.TSMTar_Team__c = team2.Id;
        tsm2.TSMTar_PseudoTarget__c = true;
        tsm2.TSMTar_StartDate__c = tsmstartdate;
        tsm2.TSMTar_EndDate__c = tsmenddate;
        tsm2.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm2); 
        insert tsmTargetList;
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Checklist__c chkListIRRM = TestData.createChecklist(acc.id);
        chkListIRRM.File_Checker__c = testUser.Id;
        chkListIRRM.Product__c = 'IRRM';
        insert chkListIRRM;
        
        Checklist__c chkListCommodity = TestData.createChecklist(acc.id);
        chkListCommodity.File_Checker__c = testUser.Id;
        chkListCommodity.Product__c = 'Commodity';
        insert chkListCommodity;
        
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 1500, 1500);
        opp1.opp_TradeID__c='12309';
        opp1.Deal_Executed_By__c = con.id;
        opp1.StageName = 'New Opportunity';        
        insert opp1;
        
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 1500, 1500);
        opp.opp_TradeID__c='1234';
        opp.Deal_Executed_By__c = con.id;
        opp.StageName = 'New Opportunity';        
        oppList.add(opp);
        
        Opportunity opp2 = TestData.createOpportunity(acc.id, con, chkListCommodity.Id, RecordTypeIdOpportunityCommodity, 0, 0);
        opp2.opp_TradeID__c='1235';
        opp2.Deal_Executed_By__c = con.id;
        opp2.Amount=0;
        opp2.StageName = 'Work In Progress';
        opp2.NextStep = 'Contacting Banker';
        oppList.add(opp2);
        
        Opportunity opp3 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 100, 100);
        opp3.opp_TradeID__c='1236';
        opp3.Deal_Executed_By__c = con.id;
        opp3.StageName = 'Work In Progress';
        opp3.NextStep = 'Contacting Banker';
        oppList.add(opp3);
        
        Opportunity opp4 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 0, 0);
        opp4.opp_TradeID__c='1237';
        opp4.Deal_Executed_By__c = con.id;
        opp4.Amount=100;
        opp4.Face_Value_Amount__c=100;
        opp4.StageName = 'Closed Won';
        opp4.Appropriateness_Assessment_Undertaken__c = true;
        opp4.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp4.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp4.TRID_Reference__c = 'Customer TR';
        oppList.add(opp4);
        
        Opportunity opp5 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 0, 0);
        opp5.opp_TradeID__c='1238';
        opp5.Deal_Executed_By__c = con.id;
        opp5.StageName = 'Closed Won';
        opp5.Face_Value_Amount__c=100;
        opp5.Appropriateness_Assessment_Undertaken__c = true;
        opp5.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp5.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp5.TRID_Reference__c = 'Customer TR';
        opp5.Amount=100;
        oppList.add(opp5);
        
        Opportunity opp6 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 100, 100);
        opp6.opp_TradeID__c='12399';
        opp6.Deal_Executed_By__c = con.id;
        opp6.StageName = 'Work In Progress';
        opp6.NextStep = 'Contacting Banker';
        opp6.Face_Value_Amount__c=100;
        opp6.Amount=100;        
        oppList.add(opp6);   
        
        Test.startTest();
        
        insert oppList;
        
        CYBGUtilClass.firstRun = true;
        
        Opportunity oppUpdate1 = new Opportunity();
        oppUpdate1.Id = opp.Id;
        oppUpdate1.StageName = 'Closed Won';
        oppUpdate1.Face_Value_Amount__c=2500;
        oppUpdate1.OwnerId = tsmUser1.Id;
        oppUpdate1.Appropriateness_Assessment_Undertaken__c = true;
        oppUpdate1.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        oppUpdate1.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        oppUpdate1.TRID_Reference__c = 'Customer TR';
        oppUpdate1.Amount=2500;
        
        Opportunity oppUpdatenew1 = new Opportunity();
        oppUpdatenew1.Id = opp1.Id;
        oppUpdatenew1.StageName = 'Closed Won';
        oppUpdatenew1.Face_Value_Amount__c=2508;
        oppUpdatenew1.OwnerId = tsmUser1.Id;
        oppUpdatenew1.Amount=2509; 
        oppUpdatenew1.Appropriateness_Assessment_Undertaken__c = true;
        oppUpdatenew1.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        oppUpdatenew1.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        oppUpdatenew1.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(oppUpdatenew1);
        
        Opportunity oppUpdate2 = new Opportunity();
        oppUpdate2.Id = opp2.Id;
        oppUpdate2.Face_Value_Amount__c=2500;
        oppUpdate2.Amount=2500;
        oppUpdate2.OwnerId = tsmUser1.Id;
        oppUpdate2.StageName = 'Closed Won';
        oppUpdate2.Appropriateness_Assessment_Undertaken__c = true;
        oppUpdate2.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        oppUpdate2.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        oppUpdate2.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(oppUpdate2);
        
        Opportunity oppUpdate3 = new Opportunity();
        oppUpdate3.Id = opp3.Id;
        oppUpdate3.Face_Value_Amount__c=0;
        oppUpdate3.Amount=0;
        oppUpdate3.OwnerId = tsmUser1.Id;
        oppListUpdate.add(oppUpdate3);
        
        Opportunity oppUpdate4 = new Opportunity();
        oppUpdate4.Id = opp4.Id;
        oppUpdate4.StageName = 'Closed Won';
        oppUpdate4.Face_Value_Amount__c=2500;
        oppUpdate4.Amount=2500;
        oppUpdate4.OwnerId = tsmUser1.Id;
        oppUpdate4.Appropriateness_Assessment_Undertaken__c = true;
        oppUpdate4.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        oppUpdate4.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        oppUpdate4.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(oppUpdate4);
        
        Opportunity oppUpdate5 = new Opportunity();
        oppUpdate5.Id = opp5.Id;
        oppUpdate5.Face_Value_Amount__c=0;
        oppUpdate5.Amount=0;
        oppUpdate5.OwnerId = tsmUser1.Id;
        oppListUpdate.add(oppUpdate5);
        
        Opportunity oppUpdate6 = new Opportunity();
        oppUpdate6.Id = opp6.Id;
        oppUpdate6.Face_Value_Amount__c=2500;
        oppUpdate6.Amount=2500;
        oppUpdate6.OwnerId = tsmUser1.Id;
        oppListUpdate.add(oppUpdate6);
        
        try{
            srList = Database.update(oppListUpdate, false);
        }
        catch(Exception e)
        {
            System.debug('The Exception is '+e);
        }		        
        oppListUpdate[4].Amount=1200;
        update oppListUpdate[4];
        Test.stopTest();        
        List<JournalLineItem__c> journalLineItemsList = [SELECT Name, Journal_Amount__c, Journal_TransactionType__c 
                                                         FROM JournalLineItem__c];
        
        
        
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('Successfully inserted Opportunity. Opportunity ID: ' + sr);
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity fields that affected this error: ' + err.getFields());
                }
            }
        }        
        System.assertEquals(8, journalLineItemsList.size());       
    } 
    static TestMethod void createOpportunityJournalLineItems_Test(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityvanillaFx   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vanilla FX').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        
        Team__c team1 = TestData.createTeam();
        team1.Name = 'CB';
        team1.Team_Centre__c = centre.Id;
        team1.Team_Status__c = 'Active';
        insert team1;
        
        Team__c team2 = TestData.createTeam();
        team2.Name = 'YB';
        team2.Team_Centre__c = centre.Id;
        team2.Team_Status__c = 'Active';
        insert team2;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        accint.OwnerId = tsmUser1.Id;
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.Name = 'CYB';
        acc.FX_Manager__c=con.id;
        acc.RecordType__c='Customer';
        acc.OwnerId = tsmUser1.Id;
        acc.BillingCity = 'Banglore';
        acc.BillingStreet = 'DF123';
        acc.BillingPostalCode = '560037';
        insert acc;
        
        List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
        
        Integer year = date.today().year();
        Date tsmstartdate = Date.newInstance(year,10, 01);
        Date tsmenddate = Date.newInstance(year+1,09, 30);
        
        TSMTarget__c tsm = new TSMTarget__c();
        tsm.TSMTar_TSM__c = tsmUser1.Id;
        tsm.TSMTar_Status__c = 'Active';
        tsm.TSMTar_Team__c = team.Id;
        tsm.TSMTar_PseudoTarget__c = true;
        tsm.TSMTar_StartDate__c = tsmstartdate;
        tsm.TSMTar_EndDate__c = tsmenddate;
        tsm.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm); 
        
        TSMTarget__c tsm1 = new TSMTarget__c();
        tsm1.TSMTar_TSM__c = tsmUser1.Id;
        tsm1.TSMTar_Status__c = 'Active';
        tsm1.TSMTar_Team__c = team1.Id;
        tsm1.TSMTar_PseudoTarget__c = true;
        tsm1.TSMTar_StartDate__c = tsmstartdate;
        tsm1.TSMTar_EndDate__c = tsmenddate;
        tsm1.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm1);   
        
        TSMTarget__c tsm2 = new TSMTarget__c();
        tsm2.TSMTar_TSM__c = tsmUser1.Id;
        tsm2.TSMTar_Status__c = 'Active';
        tsm2.TSMTar_Team__c = team2.Id;
        tsm2.TSMTar_PseudoTarget__c = true;
        tsm2.TSMTar_StartDate__c = tsmstartdate;
        tsm2.TSMTar_EndDate__c = tsmenddate;
        tsm2.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm2);
        
        insert tsmTargetList;        
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = new Opportunity();
        opp.Name = '346098';
        opp.CloseDate = System.today();
        opp.StageName = 'New Opportunity';
        opp.opp_TradeID__c='1239';
        opp.Deal_Executed_By__c = Null;
        opp.OwnerId = tsmUser1.Id;
        opp.RecordTypeId = RecordTypeIdOpportunityCRM;
        opp.Amount = 6790;
        oppList.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = '346068';
        opp1.CloseDate = System.today().addDays(-3);
        opp1.StageName = 'New Opportunity';
        opp1.opp_TradeID__c='1234';        
        opp1.Amount = 9807;
        opp1.RecordTypeId = RecordTypeIdOpportunityvanillaFx;
        opp1.OwnerId = tsmUser1.Id;
        oppList.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = '346028';
        opp2.CloseDate = System.today().addDays(-1);
        opp2.StageName = 'Work In Progress';
        opp2.NextStep = 'Contacting Banker';
        opp2.opp_TradeID__c='1260';        
        opp2.Amount = 5670;
        opp.RecordTypeId = RecordTypeIdOpportunityCRM;
        opp2.OwnerId = tsmUser1.Id;
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = '346678';
        opp3.CloseDate = System.today().addDays(-9);
        opp3.StageName = 'Work In Progress';
        opp3.NextStep = 'Contacting Banker';
        opp3.opp_TradeID__c='1280';        
        opp3.Amount = 4569;
        opp3.RecordTypeId = RecordTypeIdOpportunityvanillaFx;
        opp3.OwnerId = tsmUser1.Id;
        oppList.add(opp3);
        
        insert oppList;
        
        JournalLineItem__c jlItem0 = new JournalLineItem__c();
        jlItem0.Journal_Amount__c = 1200;
        jlItem0.Journal_Banker__c = null;
        jlItem0.Journal_TransactionType__c = 'Credit';
        jlItem0.Journal_Opportunity__c = opp.Id;
        insert jlItem0;
        
        JournalLineItem__c jlItem01 = new JournalLineItem__c();
        jlItem01.Journal_Amount__c = 1200;
        jlItem01.Journal_Banker__c = null;
        jlItem01.Journal_TransactionType__c = 'Credit';
        jlItem01.Journal_Opportunity__c = opp.Id;
        insert jlItem01;
        
        List<JournalLineItem__c> journalLineItemList =  new  List<JournalLineItem__c>();
        
        JournalLineItem__c jlItem = new JournalLineItem__c();
        jlItem.Journal_Amount__c = 1200;
        jlItem.Journal_Banker__c = null;
        jlItem.Journal_TransactionType__c = 'Credit';
        jlItem.Journal_Opportunity__c = opp.Id;
        jlItem.Journal_JournalLineItem__c = jlItem0.Id;
        journalLineItemList.add(jlItem);
        
        JournalLineItem__c jlItem1 = new JournalLineItem__c();
        jlItem1.Journal_Amount__c = 1209;
        jlItem1.Journal_Banker__c = Null;
        jlItem1.Journal_TransactionType__c = 'Credit';
        jlItem1.Journal_Opportunity__c = opp.Id;
        jlItem1.Journal_JournalLineItem__c = jlItem01.Id;
        journalLineItemList.add(jlItem1);
        
        JournalLineItem__c jlItem3 = new JournalLineItem__c();
        jlItem3.Journal_Amount__c = 120;
        jlItem3.Journal_Banker__c = Null;
        jlItem3.Journal_TransactionType__c = 'Debit';
        jlItem3.Journal_Opportunity__c = opp.Id;
        jlItem3.Journal_JournalLineItem__c = jlItem0.Id;
        journalLineItemList.add(jlItem3);
        
        CYBGUtilClass.firstRun = true;
        
        Opportunity opp11 = new Opportunity();
        opp11.Id = opp.Id;
        opp11.StageName = 'Work In Progress';
        opp11.NextStep = 'Contacting Banker Info';        
        opp11.opp_TradeID__c='1230';
        
        opp11.Amount = 0;
        oppListUpdate.add(opp11);
        
        Opportunity opp21 = new Opportunity();
        opp21.Id = opp2.Id;
        opp21.StageName = 'Work In Progress';        
        opp21.opp_TradeID__c='1239';
        opp21.NextStep = 'Contacting Banker Info to Proceed Forward';       
        opp21.Amount = 0;
        oppListUpdate.add(opp21);
        
        Opportunity opp31 = new Opportunity();
        opp31.Id = opp3.Id;
        opp31.StageName = 'Work In Progress';        
        opp31.opp_TradeID__c='1235';
        opp31.NextStep = 'Awaiting For Customer Conformation';      
        opp31.Amount = 0;
        oppListUpdate.add(opp31);
        
        Test.startTest();
        
        insert journalLineItemList;
        update oppListUpdate;
        
        Test.stopTest();
        
        AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
        System.assertEquals(5, arJnl[0].get('total'));        
    }
    static TestMethod void createOpportunityJournalLineItems_JournalBanker_NullTest(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityvanillaFx   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vanilla FX').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdOpportunityCommidity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        
        Team__c team1 = TestData.createTeam();
        team1.Name = 'CB';
        team1.Team_Centre__c = centre.Id;
        team1.Team_Status__c = 'Active';
        insert team1;
        
        Team__c team2 = TestData.createTeam();
        team2.Name = 'YB';
        team2.Team_Centre__c = centre.Id;
        team2.Team_Status__c = 'Active';
        insert team2;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        accint.OwnerId = tsmUser1.Id;
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.Name = 'CYB';
        acc.FX_Manager__c=con.id;
        acc.IRRM_Manager__c = con.Id;
        acc.RecordType__c='Customer';
        acc.OwnerId = tsmUser1.Id;
        acc.RM_Name__c = con.Id;
        acc.BillingCity = 'Banglore';
        acc.BillingStreet = 'DF123';
        acc.BillingPostalCode = '560037';
        insert acc;
        
        List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
        Integer year = date.today().year();
        Date tsmstartdate = Date.newInstance(year,10, 01);
        Date tsmenddate = Date.newInstance(year+1,09, 30);
        
        TSMTarget__c tsm = new TSMTarget__c();
        tsm.TSMTar_TSM__c = tsmUser1.Id;
        tsm.TSMTar_Status__c = 'Active';
        tsm.TSMTar_Team__c = team.Id;
        tsm.TSMTar_PseudoTarget__c = true;
        tsm.TSMTar_StartDate__c = tsmstartdate;
        tsm.TSMTar_EndDate__c = tsmenddate;
        tsm.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm); 
        
        TSMTarget__c tsm1 = new TSMTarget__c();
        tsm1.TSMTar_TSM__c = tsmUser1.Id;
        tsm1.TSMTar_Status__c = 'Active';
        tsm1.TSMTar_Team__c = team1.Id;
        tsm1.TSMTar_PseudoTarget__c = true;
        tsm1.TSMTar_StartDate__c = tsmstartdate;
        tsm1.TSMTar_EndDate__c = tsmenddate;
        tsm1.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm1);   
        
        TSMTarget__c tsm2 = new TSMTarget__c();
        tsm2.TSMTar_TSM__c = tsmUser1.Id;
        tsm2.TSMTar_Status__c = 'Active';
        tsm2.TSMTar_Team__c = team2.Id;
        tsm2.TSMTar_PseudoTarget__c = true;
        tsm2.TSMTar_StartDate__c = tsmstartdate;
        tsm2.TSMTar_EndDate__c = tsmenddate;
        tsm2.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm2);
        
        insert tsmTargetList;        
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = new Opportunity();
        opp.Name = '346098';
        opp.CloseDate = System.today();
        opp.AccountId = acc.Id;
        opp.StageName = 'Closed Won';
        opp.opp_TradeID__c='1439';
        opp.Deal_Executed_By__c = Null;
        opp.OwnerId = tsmUser1.Id;
        opp.RecordTypeId = RecordTypeIdOpportunityCommidity;
        opp.Amount = 6790;
        opp.Deal_Executed_By__c = con.Id;
        opp.Face_Value_Amount__c=1020;
        opp.Maturity_Date__c = Date.today();
        opp.Appropriateness_Assessment_Undertaken__c = true;
        opp.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp.TRID_Reference__c = 'Customer TR';
        oppList.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = '346068';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = System.today().addDays(-3);
        opp1.StageName = 'Closed Won';
        opp1.opp_TradeID__c='1434';        
        opp1.Amount = 3456;
        opp1.RecordTypeId = RecordTypeIdOpportunityIRRM;
        opp1.OwnerId = tsmUser1.Id;
        opp1.Deal_Executed_By__c = con.Id;
        opp1.Face_Value_Amount__c=1040;
        opp1.Maturity_Date__c = Date.today();
        opp1.Appropriateness_Assessment_Undertaken__c = true;
        opp1.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp1.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp1.TRID_Reference__c = 'Customer TR';
        oppList.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = '346028';
        opp2.AccountId = acc.Id;
        opp2.CloseDate = System.today().addDays(-1);
        opp2.StageName = 'Closed Won';
        opp2.NextStep = 'Contacting Banker';
        opp2.opp_TradeID__c='1460';        
        opp2.Amount = 3400;
        opp2.RecordTypeId = RecordTypeIdOpportunityCommidity;
        opp2.OwnerId = tsmUser1.Id;
        opp2.Deal_Executed_By__c = con.Id;
        opp2.Face_Value_Amount__c=1009;
        opp2.Maturity_Date__c = Date.today();
        opp2.Appropriateness_Assessment_Undertaken__c = true;
        opp2.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp2.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp2.TRID_Reference__c = 'Customer TR';
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = '346678';
        opp3.AccountId = acc.Id;
        opp3.CloseDate = System.today().addDays(-9);
        opp3.StageName = 'Closed Won';
        opp3.NextStep = 'Contacting Banker';
        opp3.opp_TradeID__c='1480';        
        opp3.Amount = 2030;
        opp3.RecordTypeId = RecordTypeIdOpportunityIRRM;
        opp3.OwnerId = tsmUser1.Id;
        opp3.Deal_Executed_By__c = con.Id;
        opp3.Face_Value_Amount__c=1000;
        opp3.Maturity_Date__c = Date.today();
        opp3.Appropriateness_Assessment_Undertaken__c = true;
        opp3.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp3.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp3.TRID_Reference__c = 'Customer TR';
        oppList.add(opp3);
        
        insert oppList;
        
        JournalLineItem__c jlItem0 = new JournalLineItem__c();
        jlItem0.Journal_Amount__c = 1200;
        jlItem0.Journal_Banker__c = Null;
        jlItem0.Journal_TransactionType__c = 'Credit';
        jlItem0.Journal_Opportunity__c = opp.Id;
        insert jlItem0;
        
        JournalLineItem__c jlItem01 = new JournalLineItem__c();
        jlItem01.Journal_Amount__c = 1200;
        jlItem01.Journal_Banker__c = Null;
        jlItem01.Journal_TransactionType__c = 'Credit';
        jlItem01.Journal_Opportunity__c = opp1.Id;
        insert jlItem01;
        
        List<JournalLineItem__c> journalLineItemList =  new  List<JournalLineItem__c>();
        
        JournalLineItem__c jlItem = new JournalLineItem__c();
        jlItem.Journal_Amount__c = 1200;
        jlItem.Journal_Banker__c = Null;
        jlItem.Journal_TransactionType__c = 'Credit';
        jlItem.Journal_Opportunity__c = opp.Id;
        jlItem.Journal_JournalLineItem__c = jlItem0.Id;
        journalLineItemList.add(jlItem);
        
        JournalLineItem__c jlItem1 = new JournalLineItem__c();
        jlItem1.Journal_Amount__c = 1209;
        jlItem1.Journal_Banker__c = Null;
        jlItem1.Journal_TransactionType__c = 'Credit';
        jlItem1.Journal_Opportunity__c = opp1.Id;
        jlItem1.Journal_JournalLineItem__c = jlItem01.Id;
        journalLineItemList.add(jlItem1);
        
        JournalLineItem__c jlItem3 = new JournalLineItem__c();
        jlItem3.Journal_Amount__c = 120;
        jlItem3.Journal_Banker__c = Null;
        jlItem3.Journal_TransactionType__c = 'Debit';
        jlItem3.Journal_Opportunity__c = opp2.Id;
        jlItem3.Journal_JournalLineItem__c = jlItem0.Id;
        journalLineItemList.add(jlItem3);
        
        CYBGUtilClass.firstRun = true;
        
        Opportunity opp11 = new Opportunity();
        opp11.Id = opp.Id;
        opp11.AccountId = acc.Id;
        opp11.StageName = 'Closed Won';
        opp11.NextStep = 'Contacting Banker Info';        
        opp11.opp_TradeID__c='1630';        
        opp11.Amount = 0;
        opp11.Deal_Executed_By__c = con.Id;
        opp11.Face_Value_Amount__c=100;
        opp11.Maturity_Date__c = Date.today();
        opp11.Appropriateness_Assessment_Undertaken__c = true;
        opp11.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp11.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp11.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp11);
        
        Opportunity opp21 = new Opportunity();
        opp21.Id = opp2.Id;
        opp21.AccountId = acc.Id;
        opp21.StageName = 'Closed Won';        
        opp21.opp_TradeID__c='1639';
        opp21.NextStep = 'Contacting Banker Info to Proceed Forward';       
        opp21.Amount = 0;
        opp21.Deal_Executed_By__c = con.Id;
        opp21.Face_Value_Amount__c=100;
        opp21.Maturity_Date__c = Date.today();
        opp21.Appropriateness_Assessment_Undertaken__c = true;
        opp21.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp21.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp21.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp21);
        
        Opportunity opp31 = new Opportunity();
        opp31.Id = opp3.Id;
        opp31.AccountId = acc.Id;
        opp31.StageName = 'Closed Won';        
        opp31.opp_TradeID__c='1535';
        opp31.NextStep = 'Awaiting For Customer Conformation';      
        opp31.Amount = 0;
        opp31.Deal_Executed_By__c = con.Id;
        opp31.Face_Value_Amount__c=100;
        opp31.Maturity_Date__c = Date.today();
        opp31.Appropriateness_Assessment_Undertaken__c = true;
        opp31.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp31.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp31.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp31);
        
        Test.startTest();
        
        insert journalLineItemList;
        update oppListUpdate;
        
        Test.stopTest();
        
        AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
        System.assertEquals(12, arJnl[0].get('total'));        
    }
    static TestMethod void createOpportunityJournalLineItems_oldOpportunityAmountZeroTest(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityvanillaFx   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vanilla FX').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdOpportunityCommidity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        
        Team__c team1 = TestData.createTeam();
        team1.Name = 'CB';
        team1.Team_Centre__c = centre.Id;
        team1.Team_Status__c = 'Active';
        insert team1;
        
        Team__c team2 = TestData.createTeam();
        team2.Name = 'YB';
        team2.Team_Centre__c = centre.Id;
        team2.Team_Status__c = 'Active';
        insert team2;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        accint.OwnerId = tsmUser1.Id;
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.Name = 'CYB';
        acc.FX_Manager__c=con.id;
        acc.IRRM_Manager__c = con.Id;
        acc.RecordType__c='Customer';
        acc.OwnerId = tsmUser1.Id;
        acc.RM_Name__c = con.Id;
        acc.BillingCity = 'Banglore';
        acc.BillingStreet = 'DF123';
        acc.BillingPostalCode = '560037';
        insert acc;
        
        List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
        
        Integer year = date.today().year();
        Date tsmstartdate = Date.newInstance(year,10, 01);
        Date tsmenddate = Date.newInstance(year+1,09, 30);
        
        
        TSMTarget__c tsm = new TSMTarget__c();
        tsm.TSMTar_TSM__c = tsmUser1.Id;
        tsm.TSMTar_Status__c = 'Active';
        tsm.TSMTar_Team__c = team.Id;
        tsm.TSMTar_PseudoTarget__c = true;
        tsm.TSMTar_StartDate__c = tsmstartdate;
        tsm.TSMTar_EndDate__c = tsmenddate;
        tsm.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm); 
        
        TSMTarget__c tsm1 = new TSMTarget__c();
        tsm1.TSMTar_TSM__c = tsmUser1.Id;
        tsm1.TSMTar_Status__c = 'Active';
        tsm1.TSMTar_Team__c = team1.Id;
        tsm1.TSMTar_PseudoTarget__c = true;
        tsm1.TSMTar_StartDate__c = tsmstartdate;
        tsm1.TSMTar_EndDate__c = tsmenddate;
        tsm1.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm1);   
        
        TSMTarget__c tsm2 = new TSMTarget__c();
        tsm2.TSMTar_TSM__c = tsmUser1.Id;
        tsm2.TSMTar_Status__c = 'Active';
        tsm2.TSMTar_Team__c = team2.Id;
        tsm2.TSMTar_PseudoTarget__c = true;
        tsm2.TSMTar_StartDate__c = tsmstartdate;
        tsm2.TSMTar_EndDate__c = tsmenddate;
        tsm2.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm2);
        
        insert tsmTargetList;        
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = new Opportunity();
        opp.Name = '346098';
        opp.CloseDate = System.today();
        opp.AccountId = acc.Id;
        opp.StageName = 'Closed Won';
        opp.opp_TradeID__c='1439';
        opp.Deal_Executed_By__c = Null;
        opp.OwnerId = tsmUser1.Id;
        opp.RecordTypeId = RecordTypeIdOpportunityCommidity;
        opp.Amount = 0;
        opp.Deal_Executed_By__c = con.Id;
        opp.Face_Value_Amount__c=1020;
        opp.Maturity_Date__c = Date.today();
        opp.Appropriateness_Assessment_Undertaken__c = true;
        opp.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp.TRID_Reference__c = 'Customer TR';
        oppList.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = '346068';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = System.today().addDays(-3);
        opp1.StageName = 'Closed Won';
        opp1.opp_TradeID__c='1434';        
        opp1.Amount = 0;
        opp1.RecordTypeId = RecordTypeIdOpportunityIRRM;
        opp1.OwnerId = tsmUser1.Id;
        opp1.Deal_Executed_By__c = con.Id;
        opp1.Face_Value_Amount__c=1040;
        opp1.Maturity_Date__c = Date.today();
        opp1.Appropriateness_Assessment_Undertaken__c = true;
        opp1.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp1.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp1.TRID_Reference__c = 'Customer TR';
        oppList.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = '346028';
        opp2.AccountId = acc.Id;
        opp2.CloseDate = System.today().addDays(-1);
        opp2.StageName = 'Closed Won';
        opp2.NextStep = 'Contacting Banker';
        opp2.opp_TradeID__c='1460';        
        opp2.Amount = 0;
        opp2.RecordTypeId = RecordTypeIdOpportunityCommidity;
        opp2.OwnerId = tsmUser1.Id;
        opp2.Deal_Executed_By__c = con.Id;
        opp2.Face_Value_Amount__c=1009;
        opp2.Maturity_Date__c = Date.today();
        opp2.Appropriateness_Assessment_Undertaken__c = true;
        opp2.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp2.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp2.TRID_Reference__c = 'Customer TR';
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = '346678';
        opp3.AccountId = acc.Id;
        opp3.CloseDate = System.today().addDays(-9);
        opp3.StageName = 'Closed Won';
        opp3.NextStep = 'Contacting Banker';
        opp3.opp_TradeID__c='1480';        
        opp3.Amount = 0;
        opp3.RecordTypeId = RecordTypeIdOpportunityIRRM;
        opp3.OwnerId = tsmUser1.Id;
        opp3.Deal_Executed_By__c = con.Id;
        opp3.Face_Value_Amount__c=1000;
        opp3.Maturity_Date__c = Date.today();
        opp3.Appropriateness_Assessment_Undertaken__c = true;
        opp3.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp3.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp3.TRID_Reference__c = 'Customer TR';
        oppList.add(opp3);
        
        insert oppList;
        
        JournalLineItem__c jlItem0 = new JournalLineItem__c();
        jlItem0.Journal_Amount__c = 1200;
        jlItem0.Journal_Banker__c = Null;
        jlItem0.Journal_TransactionType__c = 'Credit';
        jlItem0.Journal_Opportunity__c = opp.Id;
        insert jlItem0;
        
        JournalLineItem__c jlItem01 = new JournalLineItem__c();
        jlItem01.Journal_Amount__c = 1200;
        jlItem01.Journal_Banker__c = Null;
        jlItem01.Journal_TransactionType__c = 'Credit';
        jlItem01.Journal_Opportunity__c = opp1.Id;
        insert jlItem01;
        
        List<JournalLineItem__c> journalLineItemList =  new  List<JournalLineItem__c>();
        
        JournalLineItem__c jlItem = new JournalLineItem__c();
        jlItem.Journal_Amount__c = 1200;
        jlItem.Journal_Banker__c = Null;
        jlItem.Journal_TransactionType__c = 'Credit';
        jlItem.Journal_Opportunity__c = opp.Id;
        jlItem.Journal_JournalLineItem__c = jlItem0.Id;
        journalLineItemList.add(jlItem);
        
        JournalLineItem__c jlItem1 = new JournalLineItem__c();
        jlItem1.Journal_Amount__c = 1209;
        jlItem1.Journal_Banker__c = Null;
        jlItem1.Journal_TransactionType__c = 'Credit';
        jlItem1.Journal_Opportunity__c = opp1.Id;
        jlItem1.Journal_JournalLineItem__c = jlItem01.Id;
        journalLineItemList.add(jlItem1);
        
        JournalLineItem__c jlItem3 = new JournalLineItem__c();
        jlItem3.Journal_Amount__c = 120;
        jlItem3.Journal_Banker__c = Null;
        jlItem3.Journal_TransactionType__c = 'Debit';
        jlItem3.Journal_Opportunity__c = opp2.Id;
        jlItem3.Journal_JournalLineItem__c = jlItem0.Id;
        journalLineItemList.add(jlItem3);
        
        CYBGUtilClass.firstRun = true;
        
        Opportunity opp11 = new Opportunity();
        opp11.Id = opp.Id;
        opp11.AccountId = acc.Id;
        opp11.StageName = 'Closed Won';
        opp11.NextStep = 'Contacting Banker Info';        
        opp11.opp_TradeID__c='1630';        
        opp11.Amount = 1234;
        opp11.Deal_Executed_By__c = con.Id;
        opp11.Face_Value_Amount__c=100;
        opp11.Maturity_Date__c = Date.today();
        opp11.Appropriateness_Assessment_Undertaken__c = true;
        opp11.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp11.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp11.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp11);
        
        Opportunity opp21 = new Opportunity();
        opp21.Id = opp2.Id;
        opp21.AccountId = acc.Id;
        opp21.StageName = 'Closed Won';        
        opp21.opp_TradeID__c='1639';
        opp21.NextStep = 'Contacting Banker Info to Proceed Forward';       
        opp21.Amount = 8970;
        opp21.Deal_Executed_By__c = con.Id;
        opp21.Face_Value_Amount__c=100;
        opp21.Maturity_Date__c = Date.today();
        opp21.Appropriateness_Assessment_Undertaken__c = true;
        opp21.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp21.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp21.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp21);
        
        Opportunity opp31 = new Opportunity();
        opp31.Id = opp3.Id;
        opp31.AccountId = acc.Id;
        opp31.StageName = 'Closed Won';        
        opp31.opp_TradeID__c='1535';
        opp31.NextStep = 'Awaiting For Customer Conformation';      
        opp31.Amount = 3450;
        opp31.Deal_Executed_By__c = con.Id;
        opp31.Face_Value_Amount__c=100;
        opp31.Maturity_Date__c = Date.today();
        opp31.Appropriateness_Assessment_Undertaken__c = true;
        opp31.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp31.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp31.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp31);
        
        Test.startTest();
        
        insert journalLineItemList;
        update oppListUpdate;
        
        Test.stopTest();
        
        AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
        System.assertEquals(8, arJnl[0].get('total'));        
    } 
    static TestMethod void createOpportunityJournalLineItems_oldOpportunityAmountNotZeroJournalBankerequalsNullTest(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityvanillaFx   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Vanilla FX').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdOpportunityCommidity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        insert tsmUser1;
        
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
        
        Team__c team1 = TestData.createTeam();
        team1.Name = 'CB';
        team1.Team_Centre__c = centre.Id;
        team1.Team_Status__c = 'Active';
        insert team1;
        
        Team__c team2 = TestData.createTeam();
        team2.Name = 'YB';
        team2.Team_Centre__c = centre.Id;
        team2.Team_Status__c = 'Active';
        insert team2;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        accint.OwnerId = tsmUser1.Id;
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.Name = 'CYB';
        acc.FX_Manager__c=con.id;
        acc.IRRM_Manager__c = con.Id;
        acc.RecordType__c='Customer';
        acc.OwnerId = tsmUser1.Id;
        acc.RM_Name__c = con.Id;
        acc.BillingCity = 'Banglore';
        acc.BillingStreet = 'DF123';
        acc.BillingPostalCode = '560037';
        insert acc;
        
        List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
        
        Integer year = date.today().year();
        Date tsmstartdate = Date.newInstance(year,10, 01);
        Date tsmenddate = Date.newInstance(year+1,09, 30);
        
        TSMTarget__c tsm = new TSMTarget__c();
        tsm.TSMTar_TSM__c = tsmUser1.Id;
        tsm.TSMTar_Status__c = 'Active';
        tsm.TSMTar_Team__c = team.Id;
        tsm.TSMTar_PseudoTarget__c = true;
        tsm.TSMTar_StartDate__c = tsmstartdate;
        tsm.TSMTar_EndDate__c = tsmenddate;
        tsm.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm); 
        
        TSMTarget__c tsm1 = new TSMTarget__c();
        tsm1.TSMTar_TSM__c = tsmUser1.Id;
        tsm1.TSMTar_Status__c = 'Active';
        tsm1.TSMTar_Team__c = team1.Id;
        tsm1.TSMTar_PseudoTarget__c = true;
        tsm1.TSMTar_StartDate__c = tsmstartdate;
        tsm1.TSMTar_EndDate__c = tsmenddate;
        tsm1.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm1);   
        
        TSMTarget__c tsm2 = new TSMTarget__c();
        tsm2.TSMTar_TSM__c = tsmUser1.Id;
        tsm2.TSMTar_Status__c = 'Active';
        tsm2.TSMTar_Team__c = team2.Id;
        tsm2.TSMTar_PseudoTarget__c = true;
        tsm2.TSMTar_StartDate__c = tsmstartdate;
        tsm2.TSMTar_EndDate__c = tsmenddate;
        tsm2.TSMTar_TSMManager__c = userInfo.getUserId();       		
        tsmTargetList.add(tsm2);
        
        insert tsmTargetList;        
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = new Opportunity();
        opp.Name = '346098';
        opp.CloseDate = System.today();
        opp.AccountId = acc.Id;
        opp.StageName = 'Closed Won';
        opp.opp_TradeID__c='1439';
        opp.Deal_Executed_By__c = Null;
        opp.OwnerId = tsmUser1.Id;
        opp.RecordTypeId = RecordTypeIdOpportunityCommidity;
        opp.Amount = 230;
        opp.Deal_Executed_By__c = con.Id;
        opp.Face_Value_Amount__c=1020;
        opp.Maturity_Date__c = Date.today();
        opp.Appropriateness_Assessment_Undertaken__c = true;
        opp.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp.TRID_Reference__c = 'Customer TR';
        oppList.add(opp);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = '346068';
        opp1.AccountId = acc.Id;
        opp1.CloseDate = System.today().addDays(-3);
        opp1.StageName = 'Closed Won';
        opp1.opp_TradeID__c='1434';        
        opp1.Amount = 2345;
        opp1.RecordTypeId = RecordTypeIdOpportunityIRRM;
        opp1.OwnerId = tsmUser1.Id;
        opp1.Deal_Executed_By__c = con.Id;
        opp1.Face_Value_Amount__c=1040;
        opp1.Maturity_Date__c = Date.today();
        opp1.Appropriateness_Assessment_Undertaken__c = true;
        opp1.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp1.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp1.TRID_Reference__c = 'Customer TR';
        oppList.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = '346028';
        opp2.AccountId = acc.Id;
        opp2.CloseDate = System.today().addDays(-1);
        opp2.StageName = 'Closed Won';
        opp2.NextStep = 'Contacting Banker';
        opp2.opp_TradeID__c='1460';        
        opp2.Amount = 6780;
        opp2.RecordTypeId = RecordTypeIdOpportunityCommidity;
        opp2.OwnerId = tsmUser1.Id;
        opp2.Deal_Executed_By__c = con.Id;
        opp2.Face_Value_Amount__c=1009;
        opp2.Maturity_Date__c = Date.today();
        opp2.Appropriateness_Assessment_Undertaken__c = true;
        opp2.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp2.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp2.TRID_Reference__c = 'Customer TR';
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.Name = '346678';
        opp3.AccountId = acc.Id;
        opp3.CloseDate = System.today().addDays(-9);
        opp3.StageName = 'Closed Won';
        opp3.NextStep = 'Contacting Banker';
        opp3.opp_TradeID__c='1480';        
        opp3.Amount = 460;
        opp3.RecordTypeId = RecordTypeIdOpportunityIRRM;
        opp3.OwnerId = tsmUser1.Id;
        opp3.Deal_Executed_By__c = con.Id;
        opp3.Face_Value_Amount__c=1000;
        opp3.Maturity_Date__c = Date.today();
        opp3.Appropriateness_Assessment_Undertaken__c = true;
        opp3.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp3.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp3.TRID_Reference__c = 'Customer TR';
        oppList.add(opp3);
        
        insert oppList;
        
        JournalLineItem__c jlItem0 = new JournalLineItem__c();
        jlItem0.Journal_Amount__c = 1200;
        jlItem0.Journal_Banker__c = Null;
        jlItem0.Journal_TransactionType__c = 'Credit';
        jlItem0.Journal_Opportunity__c = opp.Id;
        insert jlItem0;
        
        JournalLineItem__c jlItem01 = new JournalLineItem__c();
        jlItem01.Journal_Amount__c = 1200;
        jlItem01.Journal_Banker__c = Null;
        jlItem01.Journal_TransactionType__c = 'Credit';
        jlItem01.Journal_Opportunity__c = opp1.Id;
        insert jlItem01;
        
        List<JournalLineItem__c> journalLineItemList =  new  List<JournalLineItem__c>();
        
        JournalLineItem__c jlItem = new JournalLineItem__c();
        jlItem.Journal_Amount__c = 1200;
        jlItem.Journal_Banker__c = Null;
        jlItem.Journal_TransactionType__c = 'Credit';
        jlItem.Journal_Opportunity__c = opp.Id;
        jlItem.Journal_JournalLineItem__c = jlItem0.Id;
        journalLineItemList.add(jlItem);
        
        JournalLineItem__c jlItem1 = new JournalLineItem__c();
        jlItem1.Journal_Amount__c = 1209;
        jlItem1.Journal_Banker__c = Null;
        jlItem1.Journal_TransactionType__c = 'Credit';
        jlItem1.Journal_Opportunity__c = opp1.Id;
        jlItem1.Journal_JournalLineItem__c = jlItem01.Id;
        journalLineItemList.add(jlItem1);
        
        JournalLineItem__c jlItem3 = new JournalLineItem__c();
        jlItem3.Journal_Amount__c = 120;
        jlItem3.Journal_Banker__c = Null;
        jlItem3.Journal_TransactionType__c = 'Debit';
        jlItem3.Journal_Opportunity__c = opp2.Id;
        jlItem3.Journal_JournalLineItem__c = jlItem0.Id;
        journalLineItemList.add(jlItem3);
        
        CYBGUtilClass.firstRun = true;
        
        Opportunity opp11 = new Opportunity();
        opp11.Id = opp.Id;
        opp11.AccountId = acc.Id;
        opp11.StageName = 'Closed Won';
        opp11.NextStep = 'Contacting Banker Info';        
        opp11.opp_TradeID__c='1630';        
        opp11.Amount = 1234;
        opp11.Deal_Executed_By__c = con.Id;
        opp11.Face_Value_Amount__c=100;
        opp11.Maturity_Date__c = Date.today();
        opp11.Appropriateness_Assessment_Undertaken__c = true;
        opp11.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp11.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp11.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp11);
        
        Opportunity opp21 = new Opportunity();
        opp21.Id = opp2.Id;
        opp21.AccountId = acc.Id;
        opp21.StageName = 'Closed Won';        
        opp21.opp_TradeID__c='1639';
        opp21.NextStep = 'Contacting Banker Info to Proceed Forward';       
        opp21.Amount = 8970;
        opp21.Deal_Executed_By__c = con.Id;
        opp21.Face_Value_Amount__c=100;
        opp21.Maturity_Date__c = Date.today();
        opp21.Appropriateness_Assessment_Undertaken__c = true;
        opp21.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp21.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp21.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp21);
        
        Opportunity opp31 = new Opportunity();
        opp31.Id = opp3.Id;
        opp31.AccountId = acc.Id;
        opp31.StageName = 'Closed Won';        
        opp31.opp_TradeID__c='1535';
        opp31.NextStep = 'Awaiting For Customer Conformation';      
        opp31.Amount = 3450;
        opp31.Deal_Executed_By__c = con.Id;
        opp31.Face_Value_Amount__c=100;
        opp31.Maturity_Date__c = Date.today();
        opp31.Appropriateness_Assessment_Undertaken__c = true;
        opp31.Deal_Executed_Tel_Number__c = '984802123 2:03PM';
        opp31.Reason_For_Final_Product_Selected__c = 'Customer Intersted in that Product';
        opp31.TRID_Reference__c = 'Customer TR';
        oppListUpdate.add(opp31);
        
        Test.startTest();
        
        insert journalLineItemList;
        update oppListUpdate;
        
        Test.stopTest();
        
        AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
        System.assertEquals(15, arJnl[0].get('total'));        
    }
}