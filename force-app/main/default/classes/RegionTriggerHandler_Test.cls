/*
@Author        : Santhoshan
@Name          : RegionTriggerHandler_Test
@Created Date  : 12th Feb 2018
@Description   : This is a Test Class for RegionTriggerHandler
@version       : 1.0
*/

@isTest
public class RegionTriggerHandler_Test {
    /**
* @description       Test method to check the Region's Roll up Summary.
* @name              createOpportunity_Test
* @param             NA 
* @return            void
* @throws            NA
*/ 
    static testMethod void regionRollupSummary() {
        User ManagerUserTest = TestData.createMGRUser('System Administrator');
        insert ManagerUserTest;
        User userTest = TestData.createUser('CYB');
        userTest.ManagerId = ManagerUserTest.id;
        insert userTest;
        
        List<Region__c> regionQueryList = new List<Region__c>();
        List<TSMTarget__c> TSMTargetList = new List<TSMTarget__c>();        
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
        TSMTarget__c testTarget = TestData.createTSMTarget();
        testTarget.TSMTar_Team__c = testTeam.id;
        testTarget.TSMTar_TSM__c = userTest.id;
        TSMTargetList.add(testTarget);        
        TSMTarget__c testTarget2 = TestData.createTSMTarget();
        testTarget2.TSMTar_Team__c = testTeam.id;
        testTarget2.TSMTar_TSM__c = userTest.id;
        TSMTargetList.add(testTarget2);      	            
        insert TSMTargetList;       
        System.runAs(userTest) {
            Test.startTest();
            testTarget.TSMTar_FXDirectTarget__c = 500;
            testTarget.TSMTar_FXIndirectTarget__c = 600;
            testTarget.TSMTar_CRMTarget__c = 700;
            testTarget.TSMTar_CommTarget__c = 800;
            testTarget.TSMTar_IRRMTarget__c = 900;
            update testTarget;
            Test.stopTest();
        }               
        regionQueryList = [SELECT Region_FXDirectTarget__c, Region_FXIndirectTarget__c,
                           Region_CRMTarget__c, Region_CommTarget__c, Region_IRRMTarget__c,
                           Region_FXDirectActual__c, Region_FXIndirectActual__c,
                           Region_CRMActual__c, Region_CommActual__c,
                           Region_IRRMActual__c FROM Region__c 
                           WHERE Name='Test Region'];
        
        System.assertEquals(1000, regionQueryList[0].Region_FXDirectTarget__c);
        System.assertEquals(1100, regionQueryList[0].Region_FXIndirectTarget__c);
        System.assertEquals(1200, regionQueryList[0].Region_CRMTarget__c);
        System.assertEquals(1300, regionQueryList[0].Region_CommTarget__c);
        System.assertEquals(1400, regionQueryList[0].Region_IRRMTarget__c);
        
    }    
}