@isTest
public class RepositoryDataBatch_FullYear_PSD2_Test {
    
    public static testMethod void repositoryDataBatchFYTest(){
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
        
        Contact con2 = TestData.createContact('1234567', RecordTypeIdContactBanker, accint.Id);
        con2.Con_Team__c = team.id;        
        insert con2;
        
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
        
        Checklist__c chkListIRRM = TestData.createChecklist(acc.id);
        chkListIRRM.File_Checker__c = testUser.Id;
        chkListIRRM.Product__c = 'IRRM';
        insert chkListIRRM;
        
        Checklist__c chkListCommodity = TestData.createChecklist(acc.id);
        chkListCommodity.File_Checker__c = testUser.Id;
        chkListCommodity.Product__c = 'Commodity';
        insert chkListCommodity;
        
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 1500, 1500);
        opp.StageName = 'New Opportunity';
        opp.opp_TradeID__c='1234456';
        opp.Deal_Executed_By__c = con.id;
        oppList.add(opp);        
        Opportunity opp0 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 1600, 1400);
        opp0.StageName = 'New Opportunity';
        opp0.opp_TradeID__c='12345';
        opp0.Deal_Executed_By__c = con.id;
        oppList.add(opp0);        
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 1500, 1500);
        opp1.opp_TradeID__c='1234890';
        opp1.Deal_Executed_By__c = con.id;
        opp1.StageName = 'Closed Won';
        opp1.CloseDate = system.today();
        oppList.add(opp1);
        Opportunity opp2 = TestData.createOpportunity(acc.id, con, chkListCommodity.Id, RecordTypeIdOpportunityCommodity, 0, 0);
        opp2.opp_TradeID__c='1235578';
        opp2.Deal_Executed_By__c = con.id;
        opp2.Amount=0;
        opp2.StageName = 'Closed Won';
        opp2.CloseDate = system.today();
        oppList.add(opp2);
        Opportunity opp3 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 100, 100);
        opp3.opp_TradeID__c='12365670';
        opp3.Deal_Executed_By__c = con.id;
        opp3.StageName = 'Closed Won';
        opp3.CloseDate = system.today();
        oppList.add(opp3);
        Opportunity opp4 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 0, 0);
        opp4.opp_TradeID__c='12374567';
        opp4.Deal_Executed_By__c = con.id;
        opp4.Amount=100;
        opp4.Face_Value_Amount__c=100;
        opp4.StageName = 'Closed Won';
        opp4.CloseDate = system.today();
        oppList.add(opp4);
        Opportunity opp5 = TestData.createOpportunity(acc.id, con, chkListIRRM.Id, RecordTypeIdOpportunityIRRM, 0, 0);
        opp5.opp_TradeID__c='12384560';
        opp5.Deal_Executed_By__c = con.id;
        opp5.StageName = 'Closed Won';
        opp5.Face_Value_Amount__c=100;
        opp5.Amount=100;
        opp5.CloseDate = system.today();
        oppList.add(opp5);
        Opportunity opp6 = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 100, 100);
        opp6.opp_TradeID__c='123994908';
        opp6.Deal_Executed_By__c = con.id;
        opp6.StageName = 'Closed Won';
        opp6.Face_Value_Amount__c=100;
        opp6.CloseDate = system.today();
        opp6.Amount=100;
        oppList.add(opp6);
        
        Account acco1 = new Account();
        acco1.BillingStreet='123';
        acco1.BillingCity ='London';
        acco1.BillingPostalCode='5602132';
        acco1.Branch__c='Clydesdale Bank';
        acco1.RecordTypeId=RecordTypeIdAccountCustomer;
        acco1.RM_Name__c=con2.Id;
        acco1.Name = 'Sample Account';
        acco1.US_Persons__c='No';
        acco1.FX_Manager__c = con2.id;        
        acco1.Treasury_Solutions_Area__c='North';        
        acco1.WID__c='45896856';
        acco1.CIF__c='457895632';
        acco1.FCTMA_Date_of_Agreement__c=System.today();
        acco1.ISDA_Date_of_Agreement__c=System.today();
        acco1.LEI_Obtained__c=System.today();
        acco1.FX_Annual_Review_Date__c = System.today();
        acco1.IRRM_Annual_Review_Date__c  = System.today();
        acco1.Commodity_Annual_Review_Date__c  = System.today();
        acco1.FX_3_Month_Review_Date__c  = System.today();
        acco1.Commodity_3_Month_Review_Date__c = System.today();
        acco1.IRRM_3_Month_Review_Date__c = System.today();
        insert acco1;
        
        Opportunity opp7 = new Opportunity();
        opp7.Name='Sample Op 4';        
        opp7.RecordTypeId = RecordTypeIdOpportunityCRM;
        opp7.CloseDate=System.today()-2;
        opp7.AccountId = acco1.id;        
        opp7.Deal_Executed_By__c=con.Id;
        opp7.Maturity_Date__c=Date.parse('01/10/2019');
        opp7.Opportunity_Currency__c='GBP';
        opp7.Pre_Deal_Checklist__c=chkList.Id;
        opp7.Face_Value_Amount__c=2000;
        opp7.Amount=1200;
        opp7.StageName = 'Closed Won';        
        oppList.add(opp7);
        
        List<Repository__c> repositoryList = new List<Repository__c>();
        Id RecordTypeIdRepositroyGroupANDDivison = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('GroupAndDivision').getRecordTypeId();
        Id RecordTypeIdRepositroyBusinessAndCustomer= Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('BusinessAndCustomer').getRecordTypeId();
        for(Integer i=0;i<=10;i++){
            Repository__c rep1 = new Repository__c();
            rep1.Rep_BusinessCentre__c = '1234'+i;
            rep1.RecordTypeId = RecordTypeIdRepositroyGroupANDDivison;
            rep1.Rep_BusinessCentreId__c = '1234'+i;
            rep1.Rep_CombineId__c = '12341234'+i;
            rep1.Rep_RMName__c = '2344'+i;
            rep1.Rep_RMId__c = '2344'+i;
            rep1.Rep_Month__c = 6;
            rep1.Rep_MonthText__c = '6';
            rep1.Rep_FXDirectActual__c = 1200;
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
            rep1.Rep_FXDirectActual__c = 1200;
            rep1.Rep_FXIndirectActual__c = 1200; 
            rep1.Rep_CommodityActual__c = 1200;
            rep1.Rep_IRRMActual__c = 1200;
            repositoryList.add(rep1);                  
        }
        insert repositoryList;        
        
        insert oppList;
        Test.startTest();      
        RepositoryDataBatch_FullYear_PSD2 rdbFullYear = new RepositoryDataBatch_FullYear_PSD2();
        Database.executeBatch(rdbFullYear,100);
        Test.stopTest();           
    }
}