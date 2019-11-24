@isTest
public class EventsAndTask_Controller_Test {
    static testMethod void testclass(){
        User tsmUserManager = TestData.createUser('CYB');
        Insert tsmUserManager;
        User tsmUser = TestData.createUser('System Administrator');
        tsmUser.lastname = 'Tsm User';
        tsmUser.ManagerId = tsmUserManager.id;
        tsmUser.Location__c = 'England';
        tsmUser.Username  = 'tsmuserjournaltransfer1@testorg.com';
        system.debug('---tsmUser.Location__c'+tsmUser.Location__c);
        insert tsmUser;
        Id RecordTypeIdQuickCalls = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Quick Call').getRecordTypeId();
        Id RecordTypeIdDefaultEvents = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Default Event').getRecordTypeId();
        Id RecordTypeIdContactBanker = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Banker').getRecordTypeId();
        Id RecordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
        Id RecordTypeIdAccountCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id RecordTypeIdOpportunityCRM = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CRM').getRecordTypeId();
        Id RecordTypeIdOpportunityFX = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FX Cash').getRecordTypeId();
        Id RecordTypeIdEventAndTask = Schema.SObjectType.Repository__c.getRecordTypeInfosByName().get('Event and Task').getRecordTypeId();
    
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
        chkList.File_Checker__c = tsmUser.Id;
            chkList.Product__c = 'FX';
        insert chkList;
        
        Opportunity opp = new Opportunity();
        
            
            opp = TestData.createOpportunity(acc.id, con, chkList.Id, RecordTypeIdOpportunityCRM, 1500, 1500);
            opp.StageName = 'Closed Won';
            opp.opp_TradeID__c='12345';
            opp.CreatedDate = System.today();
            opp.Deal_Executed_By__c = con.id;
                opp.Opp_BranchNumber__c = System.Label.CBDirectDealingClient;
                opp.RecordTypeId = RecordTypeIdOpportunityFX;
                opp.StageName = 'Closed Won';
        opp.CloseDate = System.today().addDays(2);
            opp.Amount = 1000;
            
        insert opp;
        
        
        Task t = new Task();
        t.OwnerId = tsmUser.id;
        t.WhatId = opp.id;
        t.Subject = 'New Test Task';
        t.RecordTypeId = RecordTypeIdQuickCalls;
        t.Status = 'Open';
        t.Priority = 'Normal';
        t.Product__c = 'FX';
        t.Type = 'Inbound';
        t.ActivityDate = System.today().AddDays(1);
        insert t;
        
        Event e = new Event();
        e.OwnerId = tsmUser.id;
        e.Subject = 'New Test Event';
        e.RecordTypeId = RecordTypeIdDefaultEvents;
        e.DurationInMinutes = 30;
        e.ActivityDateTime = System.Now();
        insert e;
        
        Repository__c reposObject = new Repository__c();
        reposObject.Rep_CombineId__c = tsmUser.Name + 'ETQC';
        reposObject.Rep_TSMName__c = tsmUser.Name;
        reposObject.RecordTypeId = RecordTypeIdEventAndTask;
        reposObject.Rep_QuickCalls__c = 1;
        reposObject.Rep_DefaultEvent__c = 1;
        insert reposObject;
        
        Test.startTest();
        	EventsAndTask_Controller obj = new EventsAndTask_Controller();
        	obj.downloadReport();
        List<Task> taskList = [SELECT id,Subject From Task];
        System.debug('Task '+taskList);
        Test.stopTest();
    }
}