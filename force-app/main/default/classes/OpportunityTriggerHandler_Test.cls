/*
@Author        : Santhoshan
@Name          : OpportunityTrigger_Test
@Created Date  : 24th Jan 2018
@Description   : This is a Test Class for OpportunityTriggerHandler
@version       : 1.0
*/

@isTest
public class OpportunityTriggerHandler_Test{  
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
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();//added by kk
        
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
        team.Name = 'CB';
        team.Team_Centre__c = centre.Id;
        insert team;
        Team__c teamYB = TestData.createTeam();
        teamYB.Name = 'YB';
        teamYB.Team_Centre__c = centre.Id;
        insert teamYB;
        
        Team__c team1 = TestData.createTeam();
        team1.Name = 'AA';
        team1.Team_Centre__c = centre.Id;
        insert team1;
        List<TSMTarget__c> tsmtList = new List<TSMTarget__c>();
        TSMTarget__c tsntar = new TSMTarget__c();
        tsntar.TSMTar_TSM__c = testUser.Id;
        tsntar.TSMTar_Team__c = team.Id;
        tsntar.TSMTar_PseudoTarget__c = true;
        tsntar.TSMTar_Status__c = 'Active'; 
        tsntar.TSMTar_StartDate__c = system.today();
        
        tsntar.TSMTar_TSM__c = userInfo.getUserId();
        tsntar.TSMTar_EndDate__c = system.today()+10;
        tsntar.TSMTar_TSMManager__c  = userInfo.getUserId();
        
        TSMTarget__c tsntar1 = new TSMTarget__c();
        tsntar1.TSMTar_TSM__c = testUser.Id;
        tsntar1.TSMTar_Team__c = teamYB.Id;
        tsntar1.TSMTar_PseudoTarget__c = true;
        tsntar1.TSMTar_Status__c = 'Active'; 
        tsntar1.TSMTar_StartDate__c = system.today();
        
        tsntar1.TSMTar_TSM__c = userInfo.getUserId();
        tsntar1.TSMTar_EndDate__c = system.today()+10;
        tsntar1.TSMTar_TSMManager__c  = userInfo.getUserId();
        //insert tsntar;
        
        TSMTarget__c tsntar2 = new TSMTarget__c();
        tsntar2.TSMTar_TSM__c = testUser.Id;
        tsntar2.TSMTar_Team__c = team1.Id;
        tsntar2.TSMTar_PseudoTarget__c = true;
        tsntar2.TSMTar_Status__c = 'Active'; 
        tsntar2.TSMTar_StartDate__c = system.today();
        
        tsntar2.TSMTar_TSM__c = userInfo.getUserId();
        tsntar2.TSMTar_EndDate__c = system.today()+10;
        tsntar2.TSMTar_TSMManager__c  = userInfo.getUserId();
        
        tsmtList.add(tsntar);
        tsmtList.add(tsntar1);
        tsmtList.add(tsntar2);
        insert tsmtList;
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c=con.id;
        acc.RecordType__c = 'Customer';
        insert acc;
        
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        List<Opportunity> oppList1 = new List<Opportunity>();
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 1500, 1500);
        opp.StageName = 'New Opportunity';
        opp.opp_TradeID__c='1234';
        opp.Deal_Executed_By__c = con.id;
        oppList.add(opp);
        
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCommodity, 1500, 1500);
        opp1.StageName = 'New Opportunity';
        opp1.opp_TradeID__c='123674';
        opp1.Deal_Executed_By__c = con.id;
        oppList.add(opp1);
        //insert oppList;
        oppList1.add(opp);
        oppList1.add(opp1);
        insert oppList;
        
        /*TSMTarget__c tsntar = new TSMTarget__c();
tsntar.TSMTar_TSM__c = testUser.Id;
tsntar.TSMTar_Team__c = team.Id;
tsntar.TSMTar_PseudoTarget__c = true;
tsntar.TSMTar_Status__c = 'Active';        
insert tsntar;*/
        
        CYBGUtilClass.firstRun = true;
        opp.StageName='Closed Won';
        oppListUpdate.add(opp);
        
        Test.startTest();
        
        Update oppListUpdate;
        
        Test.stopTest();
        
        AggregateResult[] arJnl = [SELECT Count(ID)total FROM JournalLineItem__c];
        System.assertEquals(2, arJnl[0].get('total'));
        
        
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
        //acc.RM_Name__c = con.id;
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
        
        Opportunity oppo = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 1500, 1500);
        oppo.opp_TradeID__c='123434';
        oppo.Deal_Executed_By__c = con.id;
        oppo.StageName = 'Closed Won';
        oppo.Amount = 0;
        //oppo.Banker__c = null;
        oppList.add(oppo);
        
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
        oppList.add(opp2);
        Opportunity opp3 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 100, 100);
        opp3.opp_TradeID__c='1236';
        opp3.Deal_Executed_By__c = con.id;
        opp3.StageName = 'Closed Won';
        oppList.add(opp3);
        Opportunity opp4 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 0, 0);
        opp4.opp_TradeID__c='1237';
        opp4.Deal_Executed_By__c = con.id;
        opp4.Amount=100;
        opp4.Face_Value_Amount__c=100;
        opp4.StageName = 'Closed Won';
        oppList.add(opp4);
        Opportunity opp5 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 0, 0);
        opp5.opp_TradeID__c='1238';
        opp5.Deal_Executed_By__c = con.id;
        opp5.StageName = 'Closed Won';
        opp5.Face_Value_Amount__c=100;
        opp5.Amount=100;
        oppList.add(opp5);
        Opportunity opp6 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 100, 100);
        opp6.opp_TradeID__c='12399';
        opp6.Deal_Executed_By__c = con.id;
        opp6.StageName = 'Closed Won';
        opp6.Face_Value_Amount__c=100;
        opp6.Amount=100;
        oppList.add(opp6);       
        
        insert oppList;
        
        
        
        
        Test.startTest();
        
        CYBGUtilClass.firstRun = true;
        opp.StageName = 'Closed Won';
        opp.Face_Value_Amount__c=2500;
        opp.Amount=2500;
        oppListUpdate.add(opp);
        
        opp2.Face_Value_Amount__c=2500;
        opp2.Amount=2500;
        oppListUpdate.add(opp2);
        
        opp3.Face_Value_Amount__c=0;
        opp3.Amount=0;
        oppListUpdate.add(opp3);
        
        opp4.StageName = 'Closed Won';
        opp4.Face_Value_Amount__c=2500;
        opp4.Amount=2500;
        oppListUpdate.add(opp4);
        
        opp5.StageName = 'Closed Won';
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
        
        System.assertEquals(13, journalLineItemsList.size());
        
    }
    
    /**
* @description       Test method to check if the Journals are created when there are no Journals
* 							and Opportunity is updated.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    
    static TestMethod void createOpportunityEmptyJournal_Test1(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
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
        
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        insert con;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c=con.id;
        acc.RecordType__c='Customer';
        insert acc;
        
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 1500, 1500);
        opp.StageName = 'New Opportunity';
        opp.opp_TradeID__c='1239';
        opp.Deal_Executed_By__c = con.id;
        opp.Amount = 12300;
        oppList.add(opp);
        
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 0, 0);
        opp1.StageName = 'Closed Won';
        opp1.opp_TradeID__c='1230';
        opp1.Amount = 12300;
        opp1.Deal_Executed_By__c = con.id;
        
        oppList.add(opp1);
        
        insert oppList;
        
        
        List<Opportunity> oppupdate = new List<Opportunity>();
        
        Opportunity opp31 = new Opportunity();
        opp31.Id = opp.Id;        
        opp31.Amount = 0;        
        oppupdate.add(opp31);        
        
        update oppupdate; 
        
        Opportunity opp41 = new Opportunity();
        opp41.Id = opp31.Id;        
        opp41.Amount = 900;        
        update opp41;    
        
        List<JournalLineItem__c> jList = [SELECT Name, Journal_Amount__c, Journal_TransactionType__c 
                                          FROM JournalLineItem__c];
        //delete jList;
        Opportunity opp2 = [Select Id,Amount From Opportunity where amount = 0];
        
        CYBGUtilClass.firstRun = true;
        
        opp.Face_Value_Amount__c=2500;
        opp.StageName = 'Closed Won';
        opp.Amount=2500;
        opp1.Amount = 100;
        oppListUpdate.add(opp);
        oppListUpdate.add(opp2);
        
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
        System.assertNotEquals(4, arJnl[0].get('total'));
        
    } 
    
    //21   
    
}