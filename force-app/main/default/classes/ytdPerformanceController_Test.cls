/*
@Author        : Santhoshan
@Name          : OpportunityTrigger_Test
@Created Date  : 24th Jan 2018
@Description   : This is a Test Class for OpportunityTriggerHandler
@version       : 1.0
*/

@isTest
public class ytdPerformanceController_Test{  
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
        Id RecordTypeIdOpportunityFX = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        Id RecordTypeIdOpportunityComm = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeRepositoryTSM = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndTSM').getRecordTypeId();
        
        User testUser = new user(ID = UserInfo.getUserID());
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser = TestData.createUser('System Administrator');
        tsmUser.lastname = 'Tsm User';
        tsmUser.ManagerId = tsmUserManager.id;
        tsmUser.Location__c = 'England';
        tsmUser.Username  = 'tsmuserjournal@testorg.com';
        system.debug('---tsmUser.Location__c'+tsmUser.Location__c);
        insert tsmUser;
        
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
        
        TSMTarget__c testTarget =  new TSMTarget__c();
                testTarget = TestData.createTSMTarget();
                testTarget.TSMTar_Team__c = team.id;
                testTarget.TSMTar_TSM__c = tsmUser.Id;
                testTarget.TSMTar_StartDate__c = System.Today();
                testTarget.TSMTar_EndDate__c = System.Today().AddDays(1);
                insert testTarget;
            
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        
        insert accint;
        
        Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
        con.Con_Team__c = team.id;
        con.Officer_Code__c = '1234';
        insert con;
        
        Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
        acc.FX_Manager__c=con.id;
        acc.RM_Name__c = con.id;
        acc.Commodity_Manager__c=con.id;
        acc.IRRM_Manager__c=con.id;
        acc.RecordType__c = 'Customer';
        insert acc;
        
        
        Checklist__c chkList = TestData.createChecklist(acc.id);
        chkList.File_Checker__c = testUser.Id;
            chkList.Product__c = 'FX';
        insert chkList;
        
        
        List<Repository__c> repList = new List<Repository__c>();
        Repository__c rep1 = new Repository__c();
        rep1.Rep_BusinessCentre__c = team.Name;
        rep1.Rep_BusinessCentreId__c = team.Id;
        rep1.Rep_CombineId__c = team.Id+','+con.Id+','+6;
        rep1.Rep_RMName__c = con.Name;
        rep1.Rep_RMId__c = con.id;
        rep1.Rep_Month__c = 6;
        rep1.Rep_MonthText__c = '6';
        rep1.Rep_FXDirectActual__c = 1200;
        rep1.Rep_FXIndirectActual__c = 1200; 
        rep1.Rep_CommodityActual__c = 1200;
        rep1.Rep_IRRMActual__c = 1200;
        rep1.RecordTypeId = RecordTypeRepositoryTSM;
        insert rep1;
        Repository__c each = [SELECT Rep_CombineId__c, Rep_FXDirectActual__c, Rep_FXIndirectActual__c, Rep_CommodityActual__c, Rep_IRRMActual__c FROM Repository__c];
        
           // wholeMap.put(each.Rep_CombineId__c,each);
        Map<String, Repository__c> wholeMap1= new Map<String, Repository__c>();
        wholeMap1.put(team.Id+','+con.Id+','+6, each);
        RepositoryBatch.wholeMap = wholeMap1;
        
        Opportunity opp = new Opportunity();
        for(Integer i=0; i<100; i++)
        {
            
            opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 1500, 1500);
            opp.StageName = 'Closed Won';
            opp.opp_TradeID__c='1234'+i;
            opp.CreatedDate = Date.newInstance(2018,06,06);
            opp.Deal_Executed_By__c = con.id;
            if(i==1)
                opp.Opp_BranchNumber__c = System.Label.CBDirectDealingClient;
            else if(i==2)
                opp.Opp_BranchNumber__c = System.Label.YBDirectDealingClient;
            else if(i==3)
                opp.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
            else if(i==4)
                opp.Opp_BranchNumber__c = System.Label.YBCardedRateSheet;
            else if(i==5)
                opp.Opp_BranchNumber__c = System.Label.CBIndirect;
            else if(i==6)
                opp.Opp_BranchNumber__c = System.Label.YBIndirect;
            else if(i==7)
                opp.Opp_BranchNumber__c = System.Label.CBSortingCode;
            else if(i==8)
                opp.Opp_BranchNumber__c = System.Label.YBSortingCode;
            else if(i==9)
                opp.Opp_BranchNumber__c = System.Label.CBGeneric;
            else if(i==10)
                opp.Opp_BranchNumber__c = System.Label.YBGeneric;
            else if(i==11)
                opp.Opp_BranchNumber__c = null;
            
            
            if(i >= 0 && i<= 20)
                opp.RecordTypeId = RecordTypeIdOpportunityFX;
            else if(i > 20 && i<= 30)
                opp.RecordTypeId = RecordTypeIdOpportunityComm;
            else if(i > 30 && i<= 40)
                opp.RecordTypeId = RecordTypeIdOpportunityIRRM;
            else
                opp.RecordTypeId = RecordTypeIdOpportunityFX;
            if(i >= 60 && i<= 70)
            	opp.StageName = 'New Opportunity';
            else
                opp.StageName = 'Closed Won';
            opp.Amount = 1000;
            oppList.add(opp);
        }
        insert oppList;
        
        
        
        
        CYBGUtilClass.firstRun = true;
        opp.StageName='Closed Won';
        oppListUpdate.add(opp);
        update oppListUpdate;
        Test.startTest();
        
        ytdPerformanceController rmObj = new ytdPerformanceController();
        rmObj.downloadReport();
        rmObj.submitBusCen();
        rmObj.submitRegions();
        rmObj.submitDivisions();
        rmObj.submitGroups();
        rmObj.submitBanks();
        
        Test.stopTest();
        
        
        
    }
    
   
}