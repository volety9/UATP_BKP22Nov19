/*
@Author        : Santhoshan
@Name          : CYBGUtilClass_Test
@Created Date  : 23rd Feb 2018
@Description   : This is a Test Class for CYBGUtilClass
@version       : 1.0
*/
@isTest
public class CYBGUtilClass_Test {
    
    @testSetup static void setup() {
        
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser = TestData.createUser('System Administrator');
        tsmUser.lastname = 'Tsm User';
        tsmUser.ManagerId = tsmUserManager.id;
        tsmUser.Location__c = 'England';
        tsmUser.Username  = 'tsmuserjournal@testorg.com';

        insert tsmUser;
        system.runAs(tsmUser){
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
            Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank', RecordTypeIdAccountInternal);
            accint.RecordType__c = 'Internal';
            insert accint;
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            con.Con_Team__c = testTeam.id;
            insert con;
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con.Id;
            acc.IRRM_Manager__c=con.Id;
            acc.Commodity_Manager__c = con.Id;
            acc.RecordType__c = 'Customer';
            insert acc;
        }
    }
    
    static TestMethod void fiscalYearCheck() {
        Integer integerReturnValue = 0;
        Date todayDate = Date.Today();
        Integer year = todayDate.year();
        string s1=string.valueof(year).right(2);
        Integer yearvalue = Integer.valueof(s1);
        String currentFiscalYear = 'FY'+yearValue;
        String StringReturnedValue ;
        String StringReturnedValue1 ;
        Date newDate = Date.newInstance(2018, 11, 20);
        Test.startTest();
        integerReturnValue = CYBGUtilClass.fiscalYearStartMonth();
        StringReturnedValue = CYBGUtilClass.findCurrentFY(todayDate,integerReturnValue);
        StringReturnedValue1 = CYBGUtilClass.findCurrentFY(newDate,integerReturnValue);
        Date returnDate1 = CYBGUtilClass.findStartDateOfFY(todayDate,integerReturnValue);
        Date returnDate2 = CYBGUtilClass.findEndDateOfFY(todayDate,integerReturnValue);
        Date returnDate3 = CYBGUtilClass.findStartDateOfFY(newDate,integerReturnValue);
        Date returnDate4 = CYBGUtilClass.findEndDateOfFY(newDate,integerReturnValue);
        Test.stopTest();
        //system.assertEquals(currentFiscalYear,StringReturnedValue);
    }
    static TestMethod void journalprocessData() {
        User tsmUser = [Select id,Name from user where Username = 'tsmuserjournal@testorg.com' Limit 1];
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdFXCash= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityCommodity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commodity').getRecordTypeId();
        Id RecordTypeIdOpportunityIRRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IRRM').getRecordTypeId(); 
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        
        User testUser = new user(ID = UserInfo.getUserID());
        
        Account acc = [Select Id,Name from Account where RecordTypeId = :RecordTypeIdAccountCustomer];
        Contact con = [Select Id,FirstName from Contact]; 
        Centre__c centre = [Select Id,Name from Centre__c];
        Division__c division = [Select Id,Name from Division__c];
        Group__c Groupval = [Select Id,Name from Group__c];
        Region__c region = [Select Id,Name from Region__c];
        Account accint = TestData.createCalypsoAccountInternal('Clydesdale Bank Internal', RecordTypeIdAccountInternal);
        accint.RecordType__c = 'Internal';
        insert accint;
        Contact conint = TestData.createContactInternal('2345', RecordTypeIdContactInternal, accint.Id);
        insert conint;
        Checklist__c chkLst = TestData.createChecklist(acc.Id);
        chkLst.File_Checker__c = testUser.Id;
        chkLst.Product__c = 'FX';
        insert chkLst;
        Checklist__c chkLstCommodity = TestData.createChecklist(acc.Id);
        chkLstCommodity.File_Checker__c = testUser.Id;
        chkLstCommodity.Product__c = 'Commodity';
        insert chkLstCommodity;
        Checklist__c chkLstIRRM = TestData.createChecklist(acc.Id);
        chkLstIRRM.File_Checker__c = testUser.Id;
        chkLstIRRM.Product__c = 'IRRM';
        insert chkLstIRRM;
        
        Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdFXCash,200,200);
        opp.StageName = 'Closed Won';
        opp.product__c = 'FX';
        opp.OwnerId   = tsmUser.id;
        opp.Opp_TradeID__c='101010101';
        opp.Opp_BranchNumber__c=System.Label.CBDirectDealingClient;
        insert Opp;
        Opportunity opp1 = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,200,200);
        opp1.StageName = 'Closed Won';
        opp1.OwnerId   = tsmUser.id;
        opp1.Opp_BranchNumber__c=System.Label.CBCardedRateSheet;
        opp1.Opp_TradeID__c='101010102';
        insert Opp1;
        Test.startTest(); 
        Opportunity opp2 = TestData.createOpportunity(acc.id, con, chkLstCommodity.Id, RecordTypeIdOpportunityCommodity,200,200);
        opp2.StageName = 'Closed Won';
        opp2.OwnerId   = tsmUser.id;
        opp2.Opp_TradeID__c='101010103';
        insert Opp2;
        Opportunity opp3 = TestData.createOpportunity(acc.id, con, chkLstIRRM.Id, RecordTypeIdOpportunityIRRM,200,200);
        opp3.StageName = 'Closed Won';
        opp3.OwnerId   = tsmUser.id;
        opp3.Opp_TradeID__c='101010104';
        insert Opp3;
        Date todayDate = Date.today();
        Integer yearValue = todayDate.year();
        Integer monthValue = todayDate.month();
        monthValue = monthValue + 1;
        Date newDate = Date.newInstance(yearValue, monthValue, 1);
        Team__c testTeam = [Select Id,Name from Team__c]; 
        TSMTarget__c testTarget = TestData.createTSMTarget();
        testTarget.TSMTar_Team__c = testTeam.id;
        testTarget.TSMTar_TSM__c = tsmUser.Id;
        testTarget.TSMTar_StartDate__c = System.Today();
        testTarget.TSMTar_EndDate__c = System.Today().AddDays(1);
        //testTarget.TSMTar_EndDate__c = newDate;
        insert testTarget;
        PMTarget__c testPMTarget = TestData.createPMMTarget();
        testPMTarget.PMTar_PMUser__c = tsmUser.Id;
        testPMTarget.PMTar_PMContact__c = conint.Id;
        testPMTarget.PMTar_StartDate__c = System.Today();
        testPMTarget.PMTar_EndDate__c = System.Today().AddDays(1);
        //testPMTarget.PMTar_EndDate__c = newDate;
        Insert testPMTarget;
        
        Test.stopTest();
        
        Integer integerReturnValue = CYBGUtilClass.fiscalYearStartMonth();
        String StringReturnedValue = CYBGUtilClass.findCurrentFY(Date.today(),integerReturnValue);
        
        
        JournalLineItem__c jc1 = CYBGUtilClass.createJournalLineItemsRecords(Opp.id,con.id,Opp.Amount,'Debit',Null,StringReturnedValue,Null,
                                                                             con.FirstName,Null,Null,Null,acc.id,Null,Null,'Vanilla Spot','FX Cash',con.id,
                                                                             con.FirstName,testTeam.id,testTeam.Name,tsmuser.id,tsmuser.Name,
                                                                             Null,Null,Null,centre.Name,region.Name,division.Name,groupval.Name,
                                                                             testPMTarget.id,testTarget.id,NULL);
        System.debug('testPMTarget'+testPMTarget);
        System.debug('jc1'+jc1);
        //PMTarget__c pm1 = CYBGUtilClass.updatePMTarget(testPMTarget,jc1);
        //TSMTarget__c tc1 = CYBGUtilClass.updateTSMTarget(testTarget,jc1);
        
        JournalLineItem__c jc2 = CYBGUtilClass.createJournalLineItemsRecords(Opp1.id,con.id,Opp1.Amount,'Debit',Null,StringReturnedValue,Null,
                                                                             con.FirstName,Null,Null,Null,acc.id,Null,Null,'Vanilla Spot','CRM',con.id,
                                                                             con.FirstName,testTeam.id,testTeam.Name,tsmuser.id,tsmuser.Name,
                                                                             Null,Null,Null,centre.Name,region.Name,division.Name,groupval.Name,
                                                                             testPMTarget.id,testTarget.id,NULL);
        JournalLineItem__c jc3 = CYBGUtilClass.createJournalLineItemsRecords(Opp2.id,con.id,Opp2.Amount,'Debit',Null,StringReturnedValue,Null,
                                                                             con.FirstName,Null,Null,Null,acc.id,Null,Null,'Vanilla Spot','Commodity',con.id,
                                                                             con.FirstName,testTeam.id,testTeam.Name,tsmuser.id,tsmuser.Name,
                                                                             Null,Null,Null,centre.Name,region.Name,division.Name,groupval.Name,
                                                                             testPMTarget.id,testTarget.id,NULL);
        
        JournalLineItem__c jc4 = CYBGUtilClass.createJournalLineItemsRecords(Opp3.id,con.id,Opp3.Amount,'Debit',Null,StringReturnedValue,Null,
                                                                             con.FirstName,Null,Null,Null,acc.id,Null,Null,'Vanilla Spot','IRRM',con.id,
                                                                             con.FirstName,testTeam.id,testTeam.Name,tsmuser.id,tsmuser.Name,
                                                                             Null,Null,Null,centre.Name,region.Name,division.Name,groupval.Name,
                                                                             testPMTarget.id,testTarget.id,NULL);
        
        PMTarget__c pm2 = CYBGUtilClass.updatePMTarget(testPMTarget,jc2);
        TSMTarget__c tc2 = CYBGUtilClass.updateTSMTarget(testTarget,jc2);
        PMTarget__c pm3 = CYBGUtilClass.updatePMTarget(testPMTarget,jc3);
        TSMTarget__c tc3 = CYBGUtilClass.updateTSMTarget(testTarget,jc3);
        PMTarget__c pm4 = CYBGUtilClass.updatePMTarget(testPMTarget,jc4);
        TSMTarget__c tc4 = CYBGUtilClass.updateTSMTarget(testTarget,jc4);
        List<JournalLineItem__c>journalList = [Select Id from JournalLineItem__c];
        //system.assertEquals(5, journalList.size());
        
    }
    
    
}