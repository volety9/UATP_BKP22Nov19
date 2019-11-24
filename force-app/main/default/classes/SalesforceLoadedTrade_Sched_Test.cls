@isTest
public class SalesforceLoadedTrade_Sched_Test {
    
    public static testMethod void calypsodataInsert(){
        List<Calypsodata__c> calypsoList = new List<Calypsodata__c>();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId();
        Id RecordTypeIdOpportunityFXCash = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        Id RecordTypeIdRepositroyGroupAndDivision = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('GroupAndDivision').getRecordTypeId();
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUserManager1 = TestData.createUser('DL Profile');
        tsmUserManager1.Username = 'dlapiusertest@cybg.com.uatp';
        tsmUserManager1.FirstName = 'DLAPI';
        tsmUserManager1.LastName = 'User';
        Insert tsmUserManager1;
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
        
        System.runAs(tsmUserManager1){
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
            acc.RM_Name__c = con.Id;       
            insert acc;        
            
            for(Integer i=0;i<= 30;i++){
                Calypsodata__c calp = new Calypsodata__c();                
                calp.CD_Banker__c = con.id;
                calp.CD_ETRef__c = 'ET_967_0_0';
                calp.CD_TradeStatus__c = 'VERIFIED';
                calp.CD_TradeID__c = '45000000'+i;
                calp.CD_ETREUTERSPNL__c = 2300+i;
                calp.CD_BankName__c = 'CB';
                calp.CD_BranchNumber__c = 'CB Carded Ratesheet';
                calp.CD_CIF__c = '1011857364';
                calp.CD_WID__c = '5025542';
                calp.CD_BaseEquivalent__c = -2619.74;
                calp.CD_CurrencyPair__c = '-2619.74';
                calp.CD_DealExecutedBy__c = con.id;
                calp.CD_ETPNLCCY__c = 'GBP';
                calp.CD_TradeSettleDate__c = system.today();
                
                calypsoList.add(calp);
            }
            insert calypsoList;
        }
        Test.startTest();
        SalesforceLoadedTrade_Sched slts = new SalesforceLoadedTrade_Sched();
        string sch = '0 0 10 * * ?';
        System.schedule('Salesforce Trade Status Schedule',sch,slts);
        Test.stopTest();
    }
}