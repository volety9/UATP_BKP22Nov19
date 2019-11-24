@isTest
public class PMReportUpdateFRSMAndPM_Sched_Test {
    
    public static testMethod void pmAndFRSMTest(){
        List<Opportunity> OpportunityList = new List<Opportunity>();
        List<Repository__c> repositoryList = new List<Repository__c>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeIdOpportunityFXCash = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        Id RecordTypeIdRepositoryCustomerAndPm = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('CustomerAndPM').getRecordTypeId();
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser1 = TestData.createUser('System Administrator');
        tsmUser1.lastname = 'Tsm User';
        tsmUser1.ManagerId = tsmUserManager.id;
        tsmUser1.Location__c = 'England';
        tsmUser1.Username  = 'tsmuserjournaltransfer1@testorg.com';
        system.debug('---tsmUser.Location__c'+tsmUser1.Location__c);
        insert tsmUser1;
        
        User tsmUser2 = TestData.createUser('System Administrator');
        tsmUser2.lastname = 'Tsm User 2';
        tsmUser2.ManagerId = tsmUserManager.id;
        tsmUser2.Location__c = 'England';
        tsmUser2.Username  = 'tsmuserjournaltransfer2@testorg.com';
        system.debug('---tsmUser.Location__c'+tsmUser2.Location__c);
        insert tsmUser2;
        
        
        Group__c testGroup = TestData.createGroup();
        insert testGroup;        
        Division__c testDivision = TestData.createDivision();        
        testDivision.Div_Group__c=testGroup.Id;
        insert testDivision;        
        
        Region__c testRegion = TestData.createRegion();        
        testRegion.Region_Division__c=testDivision.id;        
        insert testRegion;        
        Centre__c testCentre = TestData.createCentre();
        testCentre.Centre_Region__c=testRegion.id;        
        insert testCentre;
        Team__c testTeam = TestData.createTeam();
        testTeam.Team_Centre__c = testCentre.id; 
        insert testTeam;
        Account acct = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        acct.RecordType__c = 'Internal';
        insert acct;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, acct.Id);
        con.Con_Team__c = testTeam.id;
        insert con;
        Contact con1 = TestData.createContact('3456', RecordTypeIdContactBanker, acct.Id);
        con1.Con_Team__c = testTeam.id;
        insert con1;
        Contact con3 = TestData.createContact('1345', RecordTypeIdContactInternal, acct.Id);
        con3.Con_Team__c = testTeam.id;
        insert con3;
        Contact con4 = TestData.createContact('1643', RecordTypeIdContactInternal, acct.Id);
        con4.Con_Team__c = testTeam.id;
        insert con4;        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c=con3.Id;
        acc.IRRM_Manager__c=con3.Id;
        acc.Commodity_Manager__c = con3.Id;
        acc.RecordType__c = 'Customer';
        insert acc;       
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = tsmUser1.Id;
        chkList.Product__c = 'FX';
        insert chkList;
        Checklist__c chkListIRRM = TestData.createChecklist(acc.id);
        chkListIRRM.File_Checker__c = tsmUser1.Id;
        chkListIRRM.Product__c = 'IRRM';
        insert chkListIRRM;
        
        Checklist__c chkListCommodity = TestData.createChecklist(acc.id);
        chkListCommodity.File_Checker__c = tsmUser1.Id;
        chkListCommodity.Product__c = 'Commodity';
        insert chkListCommodity;
        
        Date todayDate1 = system.today();
        Integer monthval = todayDate1.month();
        Integer yearval = todayDate1.Year();
        Integer nextMonth = monthval+1;
        Date myDate = Date.newInstance(yearval, nextMonth, 1);
        
        List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
        TSMTarget__c testTarget1 =  new TSMTarget__c();
        testTarget1 = TestData.createTSMTarget();
        testTarget1.TSMTar_Team__c = testTeam.id;
        testTarget1.TSMTar_TSM__c = tsmUser1.Id;
        testTarget1.TSMTar_StartDate__c = System.Today();
        testTarget1.TSMTar_EndDate__c = myDate;
        tsmTargetList.add(testTarget1);
        TSMTarget__c testTarget2 =  new TSMTarget__c();
        testTarget2 = TestData.createTSMTarget();
        testTarget2.TSMTar_Team__c = testTeam.id;
        testTarget2.TSMTar_TSM__c = tsmUser2.Id;
        testTarget2.TSMTar_StartDate__c = System.Today();
        testTarget2.TSMTar_EndDate__c = myDate;
        tsmTargetList.add(testTarget2);
        Database.SaveResult[] insertResultForTSMTarget = Database.Insert(tsmTargetList, False); 
        
        for(Integer i=0;i<=5;i++){
            Repository__c rep = new Repository__c();
            rep.Name = 'a0G1x000000nSuV'+i;
            rep.Rep_CombineId__c = '0011v00001pmRYZAA20030Y00001e2glYQAQCPFXGBPUSD'+i;
            rep.Rep_AccountId__c = acc.id;
            rep.Rep_TSMName__c = '';
            rep.Rep_PMName__c = '';
            rep.Rep_RMName__c = '';
            rep.Rep_BusinessCentre__c = '';
            rep.Opportunity_RecordType__c = 'FX Cash';
            rep.RecordTypeId = RecordTypeIdRepositoryCustomerAndPm;
            rep.Rep_WID__c = '';
            repositoryList.add(rep);
        }
        for(Integer j=11;j<=15;j++){
            Repository__c rep = new Repository__c();
            rep.Name = 'a0G1x000000nSuV'+j;
            rep.Rep_CombineId__c = '0011v00001pmRYZAA20030Y00001e2glYQAQCPFXGBPUSD'+j;
            rep.Rep_AccountId__c = acc.id;
            rep.Rep_TSMName__c = '';
            rep.Rep_PMName__c = '';
            rep.Rep_RMName__c = '';
            rep.Rep_BusinessCentre__c = '';
            rep.Opportunity_RecordType__c = 'IRRM';
            rep.RecordTypeId = RecordTypeIdRepositoryCustomerAndPm;
            rep.Rep_WID__c = '';
            repositoryList.add(rep);
        }
        for(Integer k=16;k<=20;k++){
            Repository__c rep = new Repository__c();
            rep.Name = 'a0G1x000000nSuV'+k;
            rep.Rep_CombineId__c = '0011v00001pmRYZAA20030Y00001e2glYQAQCPFXGBPUSD'+k;
            rep.Rep_AccountId__c = acc.id;
            rep.Rep_TSMName__c = '';
            rep.Rep_PMName__c = '';
            rep.Rep_RMName__c = '';
            rep.Rep_BusinessCentre__c = '';
            rep.Opportunity_RecordType__c = 'Commodity';
            rep.RecordTypeId = RecordTypeIdRepositoryCustomerAndPm;
            rep.Rep_WID__c = '';
            repositoryList.add(rep);
        }
        insert repositoryList;
        
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFXCash, 100, 100);
        opp1.opp_TradeID__c='1235';
        opp1.Deal_Executed_By__c = con.id;
        opp1.Opp_BranchNumber__c = System.Label.CBDirectDealingClient;
        opp1.Amount=100;
        opp1.Opp_PrimaryCurrency__c = 'GBP';
        opp1.Opp_SecondaryCurrency__c = 'GBP';
        opp1.Opp_PrimaryAmount__c = 1200;
        opp1.Opp_SecondaryAmount__c = 600;
        opp1.CloseDate = System.today();
        opp1.Product__c = 'FXFlexiForward';
        opp1.StageName = 'Closed Won';
        OpportunityList.add(opp1);
        
        Opportunity opp11 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFXCash, 100, 100);
        opp11.opp_TradeID__c='1136';
        opp11.Deal_Executed_By__c = con.id;
        opp11.Opp_BranchNumber__c = System.Label.CBDirectDealingClient;
        opp11.Amount=100;
        opp11.Opp_PrimaryCurrency__c = 'GBP';
        opp11.Opp_SecondaryCurrency__c = 'GBP';
        opp11.Opp_PrimaryAmount__c = 1200;
        opp11.Opp_SecondaryAmount__c = 600;
        opp11.CloseDate = System.today().addYears(-1);
        opp11.Product__c = 'FXFlexiForward';
        opp11.StageName = 'Closed Won';
        OpportunityList.add(opp11);
        
        Opportunity opp2 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityIRRM, 100, 100);
        opp2.opp_TradeID__c='1462';
        opp2.Deal_Executed_By__c = con.id;
        opp2.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
        opp2.Amount=100;
        opp2.Opp_PrimaryCurrency__c = 'USD';
        opp2.Opp_SecondaryCurrency__c = 'GBP';
        opp2.Opp_PrimaryAmount__c = 1200;
        opp2.Opp_SecondaryAmount__c = 600;        
        opp2.CloseDate = System.today();
        opp2.StageName = 'Closed Won';
        OpportunityList.add(opp2); 
        
        Opportunity opp22 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityIRRM, 100, 100);
        opp22.opp_TradeID__c='1182';
        opp22.Deal_Executed_By__c = con.id;
        opp22.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
        opp22.Amount=100; 
        opp22.Opp_PrimaryCurrency__c = 'USD';
        opp22.Opp_SecondaryCurrency__c = 'GBP'; 
        opp22.Opp_PrimaryAmount__c = 1200;
        opp22.Opp_SecondaryAmount__c = 600; 
        opp22.CloseDate = System.today().addYears(-1);
        opp22.StageName = 'Closed Won';
        OpportunityList.add(opp22); 
        
        Opportunity opp3 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCommodity, 100, 100);
        opp3.opp_TradeID__c='1562';
        opp3.Deal_Executed_By__c = con.id;
        opp3.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
        opp3.Amount=100;
        opp3.Opp_PrimaryCurrency__c = 'USD';
        opp3.Opp_SecondaryCurrency__c = 'USD';
        opp3.Opp_PrimaryAmount__c = 1200;
        opp3.Opp_SecondaryAmount__c = 600; 
        opp3.CloseDate = System.today();
        opp3.StageName = 'Closed Won';
        OpportunityList.add(opp3); 
        
        Opportunity opp33 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCommodity, 100, 100);
        opp33.opp_TradeID__c='1112';
        opp33.Deal_Executed_By__c = con.id;
        opp33.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
        opp33.Amount=100;
        opp33.Opp_PrimaryCurrency__c = 'USD';
        opp33.Opp_SecondaryCurrency__c = 'USD';
        opp33.Opp_PrimaryAmount__c = 1200;
        opp33.Opp_SecondaryAmount__c = 600;        
        opp33.CloseDate = System.today().addYears(-1);
        opp33.StageName = 'Closed Won';
        OpportunityList.add(opp33);
        
        insert OpportunityList;
        Test.startTest();
        PMReportUpdateFRSMAndPM_Sched pmAndFRSMSch = new PMReportUpdateFRSMAndPM_Sched();
        string sch = '0 0 10 * * ?';
        System.schedule('PM Portfolio',sch,pmAndFRSMSch);
        Test.stopTest();        
    }

}