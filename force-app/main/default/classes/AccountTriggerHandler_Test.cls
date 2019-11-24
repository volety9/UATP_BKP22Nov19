/*
@Author        : Santhoshan
@Name          : AccountTrigger_Test
@Created Date  : 31st Jan 2018
@Description   : This is a Test Class for AccountTrigger
@version       : 1.0
*/

@isTest
public class AccountTriggerHandler_Test { 
    /**
* @description       Test method to check Account Update if the associated Contact is updated.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static TestMethod void changeContactAccount_Test(){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> newoppList = new List<Opportunity>();
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        
        User testUser = new user(ID = UserInfo.getUserID());
        
        Group__c groups = TestData.createGroup();
        insert groups;
        
        /*Group__c groups2 = TestData.createGroup();
        insert groups2;*/
        
        Division__c division = TestData.createDivision();
        division.Div_Group__c = groups.Id;
        insert division;
        
        /*Division__c division2 = TestData.createDivision();
        division2.Div_Group__c = groups2.Id;
        insert division2;*/
        
        Region__c region = TestData.createRegion();
        region.Region_Division__c = division.id;
        insert region;
        
        /*Region__c region2 = TestData.createRegion();
        region2.Region_Division__c = division2.id;
        insert region2;*/
        
        Centre__c centre = TestData.createCentre();
        centre.Centre_Region__c = region.Id;
        insert centre;
        
        /*Centre__c centre2 = TestData.createCentre();
        centre2.Centre_Region__c = region2.Id;
        insert centre2;*/
        
        Team__c team = TestData.createTeam();
        team.Name = 'Test Team';
        team.Team_Centre__c = centre.Id;
        insert team;
        
        /*Team__c team2 = TestData.createTeam();
        team2.Name = 'Test Team';
        team2.Team_Centre__c = centre2.Id;
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
        system.debug('PPOOOOO'+oppList);
        
        acc.RM_Name__c=con.Id;
        update acc;
        Test.stopTest();
        
        AggregateResult[] opptyQueryListFirstBanker = [SELECT SUM(Amount)Amount FROM Opportunity
                                                         WHERE Account.RM_Name__c=:con.ID];
        AggregateResult[] opptyQueryListBanker = [SELECT SUM(Amount)Amount FROM Opportunity
                                                         WHERE Account.RM_Name__c=:con.ID];
        AggregateResult[] journalQueryListFirstBanker = [SELECT SUM(Journal_Amount__c)Amount FROM JournalLineItem__c
                                                         WHERE Journal_Banker__c=:con.Id];
        AggregateResult[] journalQueryListBankerChange = [SELECT SUM(Journal_Amount__c)Amount FROM JournalLineItem__c
                                                          WHERE Journal_Banker__c=:con.Id];
        
        /* Boolean check;
            Decimal amt= (Decimal)journalQueryListFirstBanker[0].get('Amount');
            if(amt == 0)
            {
                check = true;
            }
            System.assertEquals(true, check);*/
        //System.assertEquals(15000, journalQueryListFirstBanker[0].get('Amount'));
       // System.assertEquals(0, journalQueryListBankerChange[0].get('Amount'));
        
    }
    /**
* @description       Test method to check Account Update if the associated Contact is updated with
*                           RunAs CYB User.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    public static testMethod void changeContactAccount_TestRunAs() {
        // Setup test data
        // Create a unique UserName
        //String uniqueUserName = 'Standarduser' + DateTime.now().getTime() + '@cybg.com';
        // This code runs as the system user
        //Profile profileTest = [SELECT Id FROM Profile WHERE Name='CYB'];
        
        User userTest = TestData.createUser('CYB');
        
        User testUser = new user(ID = UserInfo.getUserID());
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> newoppList = new List<Opportunity>();
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser = TestData.createUser('System Administrator');
        tsmUser.lastname = 'Tsm User';
        tsmUser.ManagerId = tsmUserManager.id;
        tsmUser.Location__c = 'England';
        tsmUser.Username  = 'tsmuserjournal@testorg.com';
        system.debug('---tsmUser.Location__c'+tsmUser.Location__c);
        insert tsmUser;
        System.runAs(tsmUser){
            List<Team__c> teamList = new List<Team__c>();
            
            Group__c groups = TestData.createGroup();
        insert groups;
        
        /*Group__c groups2 = TestData.createGroup();
        insert groups2;*/
        
        /*Group__c groups3 = TestData.createGroup();
        insert groups3;*/
        
        Division__c division = TestData.createDivision();
        division.Div_Group__c = groups.Id;
        insert division;
        
        /*Division__c division2 = TestData.createDivision();
        division2.Div_Group__c = groups2.Id;
        insert division2;*/
        
        /*Division__c division3 = TestData.createDivision();
        division3.Div_Group__c = groups3.Id;
        insert division3;*/
        
        Region__c region = TestData.createRegion();
        region.Region_Division__c = division.id;
        insert region;
        
        /*Region__c region2 = TestData.createRegion();
        region2.Region_Division__c = division2.id;
        insert region2;*/
        
        /*Region__c region3 = TestData.createRegion();
        region2.Region_Division__c = division3.id;
        insert region3;*/
        
        Centre__c centre = TestData.createCentre();
        centre.Centre_Region__c = region.Id;
        insert centre;
        
        /*Centre__c centre2 = TestData.createCentre();
        centre2.Centre_Region__c = region2.Id;
        insert centre2;*/
        
        /*Centre__c centre3 = TestData.createCentre();
        centre3.Centre_Region__c = region3.Id;
        insert centre3;*/
        
        Team__c team = TestData.createTeam();
        team.Name = 'Test Team';
        team.Team_Centre__c = centre.Id;
        insert team;
        
        /*Team__c team2 = TestData.createTeam();
        team2.Name = 'Test Team';
        team2.Team_Centre__c = centre2.Id;
        insert team2;*/
        
        /*Team__c team3 = TestData.createTeam();
            team3.Name = 'Test Team';
            team3.Team_Centre__c = centre3.Id;
            insert team3; */
           
            
           
            Date todayDate1 = system.today();
            Integer monthval = todayDate1.month();
            Integer yearval = todayDate1.Year();
            Integer nextMonth = monthval+1;
            Date myDate = Date.newInstance(yearval, nextMonth, 1);
            TSMTarget__c testTarget = TestData.createTSMTarget();
            
            testTarget.TSMTar_Team__c = team.id;
            testTarget.TSMTar_TSM__c = tsmUser.Id;
            testTarget.TSMTar_StartDate__c = system.today();
            //testTarget.TSMTar_StartDate__c = myDate;
            testTarget.TSMTar_EndDate__c = System.Today().AddDays(1);
            
            insert testTarget;
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
            accint.RecordType__c = 'Internal';
            insert accint;
            
            Contact con = TestData.createContact('1234999', RecordTypeIdContactBanker, accint.Id);
            con.Con_Team__c = team.id;
            insert con;
            system.debug('First Banker'+con.id);
            /*Contact consec = TestData.createContact('234599912', RecordTypeIdContactBanker, accint.Id);
            consec.Con_Team__c = team2.id;
            insert consec;
            system.debug('Second Banker'+consec.id); */
             
            Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
            
            insert conint;
            

            PMTarget__c testPMTarget = TestData.createPMMTarget();
            testPMTarget.PMTar_StartDate__c = system.today();
            
            testPMTarget.PMTar_PMUser__c = tsmUser.Id;
            testPMTarget.PMTar_PMContact__c = conint.Id;
            testPMTarget.PMTar_EndDate__c = System.Today().AddDays(1);
            Insert testPMTarget;
            
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.id;
            acc.Commodity_Manager__c=con.id;
            acc.IRRM_Manager__c=con.id;
            acc.RecordType__c = 'Customer';
            acc.RM_Name__c = con.id;
            insert acc;
            system.debug('RM Name for Test Acc'+acc.RM_Name__c);
            
            //Account accIRRM = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            //accIRRM.Commodity_Manager__c=con.id;
            //insert accIRRM;
            
            Checklist__c chkList = TestData.createChecklist(acc.id);
            chkList.File_Checker__c = testUser.Id;
            chkList.Product__c = 'FX';
            insert chkList;
            
            Checklist__c chkListCommodity = TestData.createChecklist(acc.id);
            chkListCommodity.File_Checker__c = testUser.Id;
            chkListCommodity.Product__c = 'Commodity';
            insert chkListCommodity;
            
            Checklist__c chkListIRRM = TestData.createChecklist(acc.id);
            chkListIRRM.File_Checker__c = testUser.Id;
            chkListIRRM.Product__c = 'IRRM';
            insert chkListIRRM;
            
            for(integer i=0;i<10;i++)
            {
                Opportunity opp = new Opportunity();
                if(i >= 0 && i<3)
                {
                    opp = TestData.createOpportunityTradeID(acc.id, con, chkList.Id, RecordTypeIdOpportunityCommodity, 1500, 1500, String.valueOf(i*11));
                }
                else if(i>=3 && i<6)
                {
                    opp = TestData.createOpportunityTradeID(acc.id, con, chkListCommodity.Id, RecordTypeIdOpportunityCRM, 1500, 1500, String.valueOf(i*11));
                }
                else
                {
                    opp = TestData.createOpportunityTradeID(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 1500, 1500, String.valueOf(i*11));
                }
                opp.StageName = 'Closed Won';
                 opp.Opp_TradeId__c='1234'+i;
                opp.Deal_Executed_By__c = con.id;
                oppList.add(opp);
            }
            
            Test.startTest();
            insert oppList;
            system.debug('PPOOOOO'+oppList);
            system.debug('RM Name for Test Acc before Update'+acc.RM_Name__c);
            acc.RM_Name__c=con.Id;
            system.debug('RM Name Before Update statement '+acc.RM_Name__c);
            update acc;
            system.debug('RM Name for Test Acc After Update'+acc.RM_Name__c);
            Test.stopTest();
            
            
            AggregateResult[] journalQueryListFirstBanker = [SELECT SUM(Journal_Amount__c)Amount FROM JournalLineItem__c
                                                             WHERE Journal_Banker__c=:con.Id];
            AggregateResult[] journalQueryListBankerChange = [SELECT SUM(Journal_Amount__c)Amount FROM JournalLineItem__c
                                                              WHERE Journal_Banker__c=:con.Id];
            
            Boolean check;
            Decimal amt= (Decimal)journalQueryListFirstBanker[0].get('Amount');
            if(amt > 100)
            {
                check = true;
            }
            System.assertEquals(true, check);
            //System.assertEquals(10500, journalQueryListBankerChange[0].get('Amount'));
            
            
        }
    }
}