@isTest
public class QuarterEndForecasting_Test {

    static testMethod void testclass(){
       Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();

        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeIdOpportunityFXCash = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        
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
            Account accint = TestData.createCalypsoAccountInternal('Demo Customer', RecordTypeIdAccountCustomer);
            accint.RecordType__c = 'Customer';
            accint.RM_Name__c = con.id;
                
           // insert accint;
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
                List<PMTarget__c>pmList = New List<PMTarget__c>();
            PMTarget__c testPMTarget1 = TestData.createPMMTarget();
            testPMTarget1.PMTar_StartDate__c = system.today();
            testPMTarget1.PMTar_PMUser__c = tsmUser1.Id;
            testPMTarget1.PMTar_PMContact__c = con3.Id;
            testPMTarget1.PMTar_EndDate__c = myDate;
            pmList.add(testPMTarget1);
            PMTarget__c testPMTarget2 = TestData.createPMMTarget();
            testPMTarget2.PMTar_StartDate__c = system.today();
            testPMTarget2.PMTar_PMUser__c = tsmUser2.Id;
            testPMTarget2.PMTar_PMContact__c = con4.Id;
            testPMTarget2.PMTar_EndDate__c = myDate;
            pmList.add(testPMTarget2);    
            //Insert pmList;
        
        system.runAs(tsmUser1){
            List<Opportunity>oppList = new List<Opportunity>();
            Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFXCash, 100, 100);
            opp1.opp_TradeID__c='1235';
            opp1.Deal_Executed_By__c = con.id;
            opp1.Opp_BranchNumber__c = System.Label.CBDirectDealingClient;
            opp1.Amount=100;
            opp1.CloseDate = System.today();
            opp1.Product__c = 'FXFlexiForward';
            opp1.StageName = 'Closed Won';
            oppList.add(opp1);
            Opportunity opp2 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFXCash, 100, 100);
            opp2.opp_TradeID__c='1462';
            opp2.Deal_Executed_By__c = con.id;
            opp2.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
            opp2.Amount=100;
            opp2.Product__c = 'FXFlexiForward';
            opp2.CloseDate = System.today().AddMonths(1);
            opp2.StageName = 'Closed Won';
            oppList.add(opp2);
            Insert oppList;
            
    }
        

        system.runAs(tsmUser2){
            
            List<Opportunity>oppList = new List<Opportunity>();
        Opportunity opp6 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFXCash, 100, 100);
            opp6.opp_TradeID__c='1469';
            opp6.Deal_Executed_By__c = con.id;
            opp6.Opp_BranchNumber__c = null;
            opp6.Product__c = 'FXFlexiForward';
            opp6.CloseDate = System.today();
            opp6.Amount=100;
            opp6.StageName = 'Closed Won';
            oppList.add(opp6);
            Opportunity opp7 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFXCash, 100, 100);
            opp7.opp_TradeID__c='146911';
            opp7.Deal_Executed_By__c = con.id;
            opp7.Opp_BranchNumber__c = null;
            opp7.Product__c = 'FXFlexiForward';
            opp7.CloseDate = System.today().addMonths(1);
            opp7.Amount=100;
            opp7.StageName = 'Closed Won';
            oppList.add(opp7);
            Opportunity opp3 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 1500, 1500);
            opp3.opp_TradeID__c='175634';
            opp3.Deal_Executed_By__c = con.id;
            opp3.StageName = 'Closed Won';
            oppList.add(opp3);
            Opportunity opp4 = TestData.createOpportunity(acc.id, con, chkListCommodity.Id, RecordTypeIdOpportunityCommodity, 110,110);
            opp4.opp_TradeID__c='12754';
            opp4.Deal_Executed_By__c = con.id;
            opp4.Amount=0;
            opp4.StageName = 'Closed Won';
            oppList.add(opp4);
            
            Insert oppList;
        }
        List<Repository__c> repList = new List<Repository__c>();
        Repository__c rep1 = new Repository__c();
        rep1.Rep_BusinessCentre__c = '1234';
        rep1.Rep_BusinessCentreId__c = '1234';
        rep1.Rep_CombineId__c = '12341234';
        rep1.Rep_RMName__c = '2344';
        rep1.Rep_RMId__c = '2344';
        rep1.Rep_Month__c = 6;
        rep1.Rep_MonthText__c = '6';
        rep1.Rep_FXDirectActual__c = 1200;
        rep1.Rep_FXIndirectActual__c = 1200; 
        rep1.Rep_CommodityActual__c = 1200;
        rep1.Rep_IRRMActual__c = 1200;
        insert rep1;
        
        
		Test.startTest();
        QuarterEndForecasting rmObj = new QuarterEndForecasting();
        rmObj.downloadReport();
        Test.stopTest();
        
  
    }
    
    
      
     

}