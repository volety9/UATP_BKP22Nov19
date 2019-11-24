@isTest
public class RespsitoryData_PSD2_Test {
    
    @testSetup static void setup() 
    {
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Id RecordTypeIdOpportunityFXCash = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityBusinessLoan = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Business Loan').getRecordTypeId();
        
        Id BusinessRMRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndRM').getRecordTypeId();
        Id BusinessTSMRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndTSM').getRecordTypeId();
        Id RegionBusinessRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('RegionAndBusiness').getRecordTypeId();
        Id DivisionRegionRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('DivisionAndRegion').getRecordTypeId();
        Id GroupDivisionRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('GroupAndDivision').getRecordTypeId();
        Id BankGroupRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BankAndGroup').getRecordTypeId();  
        List<Repository__c> repositoryList = new List<Repository__c>();
        Id RecordTypeIdRepositroyBusinessAndCustomer= Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndCustomer').getRecordTypeId();
        
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
        acc.RM_Name__c = con.id;
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
        
        system.runAs(tsmUser1){
            List<Opportunity>oppList = new List<Opportunity>();
            Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFXCash, 100, 100);
            opp1.opp_TradeID__c='1235';
            opp1.Deal_Executed_By__c = con.id;
            opp1.Opp_BranchNumber__c = System.Label.CBDirectDealingClient;
            opp1.Amount=100;
            opp1.StageName = 'Closed Won';
            oppList.add(opp1);
            Opportunity opp2 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityFXCash, 100, 100);
            opp2.opp_TradeID__c='1462';
            opp2.Deal_Executed_By__c = con.id;
            opp2.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
            opp2.Amount=100;
            opp2.StageName = 'Closed Won';
            oppList.add(opp2);
            Opportunity opp3 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityIRRM, 100, 100);
            opp3.opp_TradeID__c='14621';
            opp3.Deal_Executed_By__c = con.id;            
            opp3.Amount=100;
            opp3.StageName = 'Closed Won';
            oppList.add(opp3);
            Opportunity opp4 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCommodity, 100, 100);
            opp4.opp_TradeID__c='146213';
            opp4.Deal_Executed_By__c = con.id;
            opp4.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
            opp4.Amount=100;
            opp4.StageName = 'Closed Won';
            oppList.add(opp4);   
            Opportunity opp5 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 100, 100);
            opp5.opp_TradeID__c='1235789';
            opp5.Deal_Executed_By__c = con.id;
            opp5.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
            opp5.Amount=100;
            opp5.StageName = 'Closed Won';
            oppList.add(opp5);
            Opportunity opp6 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityBusinessLoan, 100, 100);
            opp6.opp_TradeID__c='1235456';
            opp6.Deal_Executed_By__c = con.id;
            opp6.Opp_BranchNumber__c = System.Label.CBCardedRateSheet;
            opp6.Amount=100;
            opp6.StageName = 'Closed Won';
            oppList.add(opp6);
            Insert oppList;
            
            for(Integer i=0;i<=10;i++){
            Repository__c rep1 = new Repository__c();
            rep1.Rep_BusinessCentre__c = '1234'+i;
            rep1.RecordTypeId = GroupDivisionRecordType;
            rep1.Rep_BusinessCentreId__c = '1234'+i;
            rep1.Rep_CombineId__c = '12341234'+i;
            rep1.Rep_RMName__c = '2344'+i;
            rep1.Rep_RMId__c = '2344'+i;
            rep1.Rep_Month__c = 6;
            rep1.Rep_MonthText__c = '6';
            rep1.Rep_FXDirectActual__c = 0;
            rep1.Rep_FXIndirectActual__c = 1200; 
            rep1.Rep_CommodityActual__c = 1200;
            rep1.Rep_IRRMActual__c = 1200;
            repositoryList.add(rep1);                  
        }
        for(Integer i=0;i<=10;i++){
            Repository__c rep1 = new Repository__c();
            rep1.Rep_BusinessCentre__c = '2345'+i;
            rep1.RecordTypeId = RecordTypeIdRepositroyBusinessAndCustomer;
            rep1.Rep_BusinessCentreId__c = '2346'+i;
            rep1.Rep_CombineId__c = '2341235'+i;
            rep1.Rep_RMName__c = '25678'+i;
            rep1.Rep_RMId__c = '4567'+i;
            rep1.Rep_Month__c = 6;
            rep1.Rep_MonthText__c = '6';
            rep1.Rep_FXDirectActual__c = 0;
            rep1.Rep_FXIndirectActual__c = 1200; 
            rep1.Rep_CommodityActual__c = 1200;
            rep1.Rep_IRRMActual__c = 1200;
            repositoryList.add(rep1);                  
        }
            for(Integer i=0;i<=10;i++){
            Repository__c rep1 = new Repository__c();
            rep1.Rep_BusinessCentre__c = '2345'+i;
            rep1.RecordTypeId = BankGroupRecordType;
            rep1.Rep_BusinessCentreId__c = '2346'+i;
            rep1.Rep_CombineId__c = '2341235'+i;
            rep1.Rep_RMName__c = '25678'+i;
            rep1.Rep_RMId__c = '4567'+i;
            rep1.Rep_Month__c = 6;
            rep1.Rep_MonthText__c = '6';
            rep1.Rep_FXDirectActual__c = 0;
            rep1.Rep_FXIndirectActual__c = 1200; 
            rep1.Rep_CommodityActual__c = 1200;
            rep1.Rep_IRRMActual__c = 1200;
            repositoryList.add(rep1);                  
        }
        insert repositoryList;
        }
        
    }
    static testMethod void testclass()
    {
        Map<String, Repository__c> wholeMap= new Map<String, Repository__c>();
        Map<String, Repository__c> wholeMap1= new Map<String, Repository__c>();
        Map<String, Repository__c> wholeMap2= new Map<String, Repository__c>();
        Map<String, Repository__c> wholeMap3= new Map<String, Repository__c>(); 
        Map<String, Repository__c> wholeMap4= new Map<String, Repository__c>();
        Map<String, Repository__c> wholeMap5= new Map<String, Repository__c>();
        Map<String, Repository__c> repList = new Map<String, Repository__c>();
        Id BusinessRMRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndRM').getRecordTypeId();
        Id BusinessTSMRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndTSM').getRecordTypeId();
        Id RegionBusinessRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('RegionAndBusiness').getRecordTypeId();
        Id DivisionRegionRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('DivisionAndRegion').getRecordTypeId();
        Id GroupDivisionRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('GroupAndDivision').getRecordTypeId();
        Id BankGroupRecordType = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BankAndGroup').getRecordTypeId();  
        
        Test.startTest();
        List<Opportunity> eachOpp = [Select Id,CreatedDate,RecordType.Name,Account.RM_Name__c, Account.RM_Name__r.Name, Account.Name
                                     ,isQ6Available__c,Opp_BranchNumber__c, Opp_CorpCode__c, StageName,
                                     OwnerId, Owner.Name, Banker__c,Account.RM_Name__r.Con_Team__c, CloseDate, Account.RM_Name__r.Officer_Code__c,
                                     Account.RM_Name__r.Con_Team__r.Name,Account.RM_Name__r.Con_Centre__c,
                                     Account.RM_Name__r.Con_Region__c,Account.RM_Name__r.Con_Division__c,
                                     Account.RM_Name__r.Con_Group__c,Amount,Account.FX_Manager__r.Name       
                                     From Opportunity]; 
        
        Opportunity fxOpp;
        Opportunity commOpp;
        Opportunity irrmOpp;
        List<Repository__c> repListvalues = [SELECT Rep_CombineId__c, Rep_FXDirectActual__c, Rep_FXIndirectActual__c, Rep_BusinessActual__c,Rep_CommodityActual__c, Rep_IRRMActual__c, Rep_RetailActual__c,Rep_FX_Manager__c,Rep_Total__c FROM Repository__c];
        for(Repository__c rep:repListvalues){
            repList.put(rep.Rep_CombineId__c,rep);            
        }
        For(Opportunity each :eachOpp)
        {
            system.debug('Q6 code'+each.isQ6Available__c);
            if(each.RecordType.Name =='FX Cash')
            {
                fxOpp = each;
            }else if(each.RecordType.Name =='IRRM')
            {
                irrmOpp = each;
            }else 
            {
                commOpp = each;
            }
        }
        
        String CombineId = (String)fxOpp.Account.RM_Name__r.Con_Team__c +','+ (String)fxOpp.Account.RM_Name__c +','+ fxOpp.CreatedDate.month();
        String CombineId2 = 'tgrew';
        String CombineId3 = 'tgrew2'; 
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,fxOpp,CombineId,BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,fxOpp,CombineId,BusinessRMRecordType);
        fxopp.Opp_BranchNumber__c = Null; 
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,fxOpp,CombineId2,BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,fxOpp,CombineId2,BusinessRMRecordType);
        fxopp.Opp_BranchNumber__c = 'CB Direct Dealing Client'; 
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,fxOpp,'Test',BusinessRMRecordType);  
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,irrmOpp,'IRRM',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,commOpp,'Commodity',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,fxOpp,'Test',BusinessRMRecordType);  
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,irrmOpp,'IRRM',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,commOpp,'Commodity',BusinessRMRecordType);
        
        Repository__c rep = new Repository__c();
        rep.Rep_CombineId__c =  CombineId;
        Insert  rep;
        wholeMap.put(CombineId,rep); 
        fxopp.Opp_BranchNumber__c = 'CB Carded Ratesheet';  
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,fxOpp,CombineId,BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,fxOpp,CombineId,BusinessRMRecordType);
        wholeMap.put(CombineId2,rep);
        wholeMap.put('IRRM',rep);
        wholeMap.put('Commodity',rep);
        fxOpp.Opp_BranchNumber__c = Null;
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,fxOpp,CombineId2,BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,fxOpp,CombineId2,BusinessRMRecordType);
        fxOpp.Opp_BranchNumber__c = 'CB Direct Dealing Client';
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,fxOpp,CombineId2,BusinessRMRecordType); 
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,irrmOpp,'IRRM',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(wholeMap,wholeMap1,commOpp,'Commodity',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,fxOpp,CombineId2,BusinessRMRecordType); 
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,irrmOpp,'IRRM',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap1,commOpp,'Commodity',BusinessRMRecordType);
        
        wholeMap4.put(CombineId,rep); 
        RespsitoryData_PSD2.dataInsert(wholeMap3,wholeMap4,fxOpp,CombineId,BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap4,fxOpp,CombineId,BusinessRMRecordType);
        wholeMap4.put(CombineId2,rep);
        wholeMap4.put('IRRM',rep);
        wholeMap4.put('Commodity',rep);
        fxOpp.Opp_BranchNumber__c = 'CB Carded Ratesheet';
        RespsitoryData_PSD2.dataInsert(wholeMap3,wholeMap4,fxOpp,CombineId2,BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap4,fxOpp,CombineId2,BusinessRMRecordType);
        fxOpp.Opp_BranchNumber__c = Null;
        RespsitoryData_PSD2.dataInsert(wholeMap3,wholeMap4,fxOpp,CombineId2,BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap4,fxOpp,CombineId2,BusinessRMRecordType);
        
        RespsitoryData_PSD2.dataInsert(wholeMap3,wholeMap4,irrmOpp,'IRRM',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(wholeMap3,wholeMap4,commOpp,'Commodity',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap4,irrmOpp,'IRRM',BusinessRMRecordType);
        RespsitoryData_PSD2.dataInsert(repList,wholeMap4,commOpp,'Commodity',BusinessRMRecordType);
        
        
        
        RespsitoryData.dataInsert(wholeMap,wholeMap1,irrmOpp,CombineId,BusinessRMRecordType);
        RespsitoryData.dataInsert(wholeMap,wholeMap1,commOpp,CombineId,BusinessRMRecordType);
        RespsitoryData.dataInsert(repList,wholeMap1,irrmOpp,CombineId,BusinessRMRecordType);
        RespsitoryData.dataInsert(repList,wholeMap1,commOpp,CombineId,BusinessRMRecordType);
        
        Repository__c rep1 = new Repository__c();
        rep1.Rep_CombineId__c =  CombineId;
        Insert  rep1;
        wholeMap.put(CombineId,rep1);
        RespsitoryData.dataInsert(wholeMap,wholeMap1,fxOpp,CombineId,BusinessRMRecordType); 
        RespsitoryData.dataInsert(repList,wholeMap1,fxOpp,CombineId,BusinessRMRecordType);
        fxopp.Opp_BranchNumber__c = 'CBIndirect'; 
        RespsitoryData.dataInsert(wholeMap,wholeMap1,fxOpp,CombineId,BusinessRMRecordType);
        RespsitoryData.dataInsert(repList,wholeMap1,fxOpp,CombineId,BusinessRMRecordType);
        fxopp.Opp_BranchNumber__c = Null;
        RespsitoryData.dataInsert(wholeMap,wholeMap1,fxOpp,CombineId,BusinessRMRecordType); 
        RespsitoryData.dataInsert(wholeMap,wholeMap1,irrmOpp,CombineId,BusinessRMRecordType);
        RespsitoryData.dataInsert(wholeMap,wholeMap1,commOpp,CombineId,BusinessRMRecordType);
        RespsitoryData.dataInsert(repList,wholeMap1,fxOpp,CombineId,BusinessRMRecordType); 
        RespsitoryData.dataInsert(repList,wholeMap1,irrmOpp,CombineId,BusinessRMRecordType);
        RespsitoryData.dataInsert(repList,wholeMap1,commOpp,CombineId,BusinessRMRecordType);
        fxopp.Opp_BranchNumber__c = 'CBDirectDealingClient'; 
        
        String combineId1 = 'ABCD8';
         
        wholeMap1.put(CombineId,rep); 
        RespsitoryData.dataInsert(wholeMap,wholeMap1,fxOpp,combineId1,BusinessRMRecordType);
        RespsitoryData.dataInsert(repList,wholeMap1,fxOpp,combineId1,BusinessRMRecordType);
         
        fxopp.Opp_BranchNumber__c = 'CBCardedRateSheet';  
        RespsitoryData.dataInsert(wholeMap,wholeMap1,fxOpp,combineId1,BusinessRMRecordType);
        RespsitoryData.dataInsert(repList,wholeMap1,fxOpp,combineId1,BusinessRMRecordType); 
        Test.stopTest();
    }
}