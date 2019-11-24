/*
@Author        : Suhas
@Name          : BrokenDownByProductYOYController_Test
@Created Date  : 29th May 2018
@Description   : Test Class for BrokenDownByProductYOYController
@version       : 1.0
*/
@isTest
public class BrokenDownByProductYOYController_Test {
    static testMethod void testclass(){
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdContactInternal = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> executeList = new List<Opportunity>();
        User testUser = new user(ID = UserInfo.getUserID());
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
         
        Date todayDate1 = system.today();
               Integer monthval = todayDate1.month();
               Integer yearval = todayDate1.Year();
               Integer nextMonth = monthval+1;
               Date myDate = Date.newInstance(yearval, nextMonth, 1);
        system.runAs(tsmUser1)
        {
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
            accint.RecordType__c='Internal';
            insert accint;
            
            Contact con = TestData.createContact('1234', RecordTypeIdContactBanker, accint.Id);
            con.Con_Team__c = team.id;
            insert con;
            Contact con3 = TestData.createContact('1345', RecordTypeIdContactInternal, accint.Id);
            con3.Con_Team__c = team.id;
            insert con3;
            Account acc = TestData.createCalypsoAccount('Test Acc', '1245', '1234', con.Id, RecordTypeIdAccountCustomer);
            acc.FX_Manager__c=con3.Id;
            acc.RecordType__c='Customer';
            insert acc;
            
            Account acc2 = TestData.createCalypsoAccount('Test Acc2', '2345', '2345', con.Id, RecordTypeIdAccountCustomer);
            acc2.FX_Manager__c=con3.Id;
            acc2.RecordType__c='Customer';
            insert acc2;
            
            Account acc3 = TestData.createCalypsoAccount('Test Acc3', '3456', '3456', con.Id, RecordTypeIdAccountCustomer);
            acc3.FX_Manager__c=con3.Id;
            acc3.RecordType__c='Customer';
            insert acc3;
            
            Checklist__c chkLst = TestData.createChecklist(acc.Id);
            chkLst.File_Checker__c = testUser.Id;
            chkLst.Product__c = 'FX';
            insert chkLst;
            
            List<TSMTarget__c> tsmTargetList = new List<TSMTarget__c>();
                TSMTarget__c testTarget1 =  new TSMTarget__c();
                testTarget1 = TestData.createTSMTarget();
                testTarget1.TSMTar_Team__c = team.id;
                testTarget1.TSMTar_TSM__c = tsmUser1.Id;
                testTarget1.TSMTar_StartDate__c = System.Today();
                testTarget1.TSMTar_EndDate__c = System.Today().AddDays(1);
                tsmTargetList.add(testTarget1);
                TSMTarget__c testTarget2 =  new TSMTarget__c();
                testTarget2 = TestData.createTSMTarget();
                testTarget2.TSMTar_Team__c = team.id;
                testTarget2.TSMTar_TSM__c = tsmUser2.Id;
                testTarget2.TSMTar_StartDate__c = System.Today();
                testTarget2.TSMTar_EndDate__c = System.Today().AddDays(1);
                tsmTargetList.add(testTarget2);
                Database.SaveResult[] insertResultForTSMTarget = Database.Insert(tsmTargetList, False);
                List<PMTarget__c>pmList = New List<PMTarget__c>();
            PMTarget__c testPMTarget1 = TestData.createPMMTarget();
            testPMTarget1.PMTar_StartDate__c = system.today();
            testPMTarget1.PMTar_PMUser__c = tsmUser1.Id;
            testPMTarget1.PMTar_PMContact__c = con3.Id;
            testPMTarget1.PMTar_EndDate__c = System.Today().AddDays(1);
            pmList.add(testPMTarget1);
            PMTarget__c testPMTarget2 = TestData.createPMMTarget();
            testPMTarget2.PMTar_StartDate__c = system.today();
            testPMTarget2.PMTar_PMUser__c = tsmUser2.Id;
            testPMTarget2.PMTar_PMContact__c = con3.Id;
            testPMTarget2.PMTar_EndDate__c = System.Today().AddDays(1);
            pmList.add(testPMTarget2);    
            Insert pmList;
            
            for(integer i=0;i<10;i++)
            {
                Opportunity opp = TestData.createOpportunity(acc.id, con, chkLst.Id, RecordTypeIdOpportunityCRM,1500,1500);
                opp.StageName = 'Closed Won';
                opp.Opp_TradeID__c='1234'+i;
                if(i==2)
                    opp.CloseDate=System.today().AddYears(-1);
                if(i==3)
                {
                    opp.AccountId = acc2.id;
                    opp.Opp_BaseEquivalent__c = 500;
                }
                if(i==4)
                {
                    opp.AccountId = acc3.id;
                    opp.CloseDate=System.today().AddYears(-1);
                    opp.Opp_BaseEquivalent__c = 500;
                }
                oppList.add(opp);
            }
            insert oppList;
        }
        
        Test.startTest();
        BrokenDownByProductYOYController BrokenDownByProductYOY = new BrokenDownByProductYOYController();
        BrokenDownByProductYOY.downloadReport();
        Test.stopTest();
        
        AggregateResult[] arOpp = [SELECT Count(ID)total, SUM(Opp_BaseEquivalent__c)sum FROM Opportunity];
        System.assertEquals(10, arOpp[0].get('total'));
        System.assertEquals(1000, arOpp[0].get('sum'));     
        
        
    }
}