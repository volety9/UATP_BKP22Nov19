@isTest
public class TSMTargetWorkingDays_Test 
{
    static testMethod void createTargetData() 
    {
        List<TSMTarget__c> TSMTarList = new List<TSMTarget__c>();
        List<Team__c> teamList = new List<Team__c>();
        Integer expectedCount = 0;
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        Date endDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);        
        
        User mgrUser = TestData.createMGRUser('CYB');
        insert mgrUser;
        
        User testUser1 = TestData.createUser('CYB');
        testUser1.Location__c = 'England';
        testUser1.ManagerId  = mgrUser.id;
        testUser1.username = 'testUser1@usernametestorg.com';
        insert testUser1;
        
        User testUser2 = TestData.createUser('CYB');
        testUser2.Location__c = 'Scotland';
        testUser2.ManagerId  = mgrUser.id;
        testUser2.username = 'testUser2@usernametestorg.com';
        insert testUser2;
        
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

        for(Integer i=0;i<30;i++)
        {
        Team__c team = TestData.createTeam();
        team.Name = 'Test Team '+i;
        team.Team_Centre__c = centre.Id;
            teamList.add(team);
        }
        insert teamList;
        
        for(Integer i=0;i<30;i++)
        {
            expectedCount = expectedCount + 1;
            TSMTarget__c newTSMTar = new TSMTarget__c();            
            newTSMTar.TSMTar_Team__c = teamList[i].Id;
            newTSMTar.TSMTar_StartDate__c = startDate;
            newTSMTar.TSMTar_EndDate__c = endDate;
            newTSMTar.TSMTar_IsCurrentFY__c = true;
            newTSMTar.TSMTar_FXDirectTarget__c = 10000;
            newTSMTar.TSMTar_FXIndirectTarget__c = 10000;
            newTSMTar.TSMTar_CRMTarget__c = 10000;
            newTSMTar.TSMTar_CommTarget__c = 10000;
            newTSMTar.TSMTar_IRRMTarget__c = 10000; 
            newTSMTar.TSMTar_TotalWorkingDays__c = 0;
            newTSMTar.TSMTar_WorkingDays__c = 0;
            If(math.mod(i,2)==0)
            {
                newTSMTar.TSMTar_Status__c = 'Active';
                newTSMTar.TSMTar_TSM__c = testUser1.Id;
            }else If(math.mod(i,3)==0)
            {
                newTSMTar.TSMTar_Status__c = 'Terminated';
                newTSMTar.TSMTar_TerminationDate__c =System.today();
                newTSMTar.TSMTar_TSM__c = testUser2.Id;
            }else
            {
                newTSMTar.TSMTar_Status__c = 'Inactive';
                newTSMTar.TSMTar_TSM__c = testUser2.Id;
            }
           
            TSMTarList.add(newTSMTar);
        }   
       
        
        try{
        insert TSMTarList;
        }
        catch(Exception e)
        {
            System.debug('HERE>>>>>>>>'+e);
        }
        
        Test.startTest();
        
        TSMTargetWorkingDays testObj = new TSMTargetWorkingDays();
        DataBase.executeBatch(testObj); 
        
        Test.stopTest();
        List<TSMTarget__c> lists = [SELECT ID, Name from TSMTarget__c ];
        System.debug('-----lists-----'+lists);
        
    }
   
    
}