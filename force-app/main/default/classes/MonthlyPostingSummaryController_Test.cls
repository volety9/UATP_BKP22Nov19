/*
@Author        : Santhoshan
@Name          : MonthlyPostingSummaryController_Test 
@Created Date  : 26th March 2018
@Description   : This is a Test Class for MonthlyPostingSummaryController
@version       : 1.0
*/
@isTest 
public class MonthlyPostingSummaryController_Test {
    static TestMethod void MonthlyPostingSummaryController_TestMethod()
    {
        Map<Integer,String> monthMap = new Map<Integer,String>{1 => 'January',2 => 'February',3 => 'March',4 => 'April',5 => 'May',
            6 => 'June',7 => 'July',8 => 'August',9 => 'Sept',10 => 'October',11 => 'November',12 => 'December'};
                integer startMonth = CYBGUtilClass.fiscalYearStartMonth();
        List<MonthlyPostingSummary__c> mpsList = new List<MonthlyPostingSummary__c>();
        String firstName = String.valueOf(System.today());
        
        for(integer i=0;i<12;i++){
            MonthlyPostingSummary__c mps = new MonthlyPostingSummary__c();
            if(startMonth<CYBGUtilClass.fiscalYearStartMonth()){
                Integer year = Integer.valueOf(System.Today().Year())+1; 
                mps.Name= monthMap.get(startMonth)+' '+String.valueOf(year);  
            }else{
                mps.Name= monthMap.get(startMonth)+' '+System.Today().Year();
            }
            mps.MPS_Month__c=startMonth;
            if(startMonth==12){
                startMonth=1;    
            }else{
                startMonth++;
            } 
            if(i==5){
                mps.MPS_Current_Posting_Month__c=true;   
            }else{
                mps.MPS_Current_Posting_Month__c=false;
            }
            mps.MPS_Fiscal_Year__c= CYBGUtilClass.findCurrentFY(System.Today(), 10);
            mps.MPS_Status__c='Not Published';            
            mpsList.add(mps);
        }
        
        insert mpsList;
        
        PostingLineItem__c testPLI = new PostingLineItem__c();
        testPLI.MonthlyPostingSummary__c = mpsList.get(5).Id;
        testPLI.PLI_Amount__c=200.00;
        testPLI.PLI_Corporate_Code__c=label.EOM_YB_Corp_Code;
        testPLI.PLI_GL_Account__c='101010101';
        testPLI.PLI_Cost_Centre__c='10101';
        testPLI.PLI_Cr_Dr__c='Debit';
        testPLI.PLI_Description__c='Test';
        /* insertOrUpdateEOMJournal Test Coverage end*/
        insert testPLI;
        
        PostingLineItem__c testPLICB = new PostingLineItem__c();
        testPLICB.MonthlyPostingSummary__c = mpsList.get(5).Id;
        testPLICB.PLI_Amount__c=200.00;
        testPLICB.PLI_Corporate_Code__c=label.EOM_CB_Corp_Code;
        testPLICB.PLI_GL_Account__c='101010101';
        testPLICB.PLI_Cost_Centre__c='10101';
        testPLICB.PLI_Cr_Dr__c='Debit';
        testPLICB.PLI_Description__c='Test';
        /* insertOrUpdateEOMJournal Test Coverage end*/
        insert testPLICB;
        
        List<MonthlyPostingSummary__c> MPS = [SELECT ID, (SELECT Id, Name FROM Attachments) FROM MonthlyPostingSummary__c 
                                              WHERE MPS_Current_Posting_Month__c=true LIMIT 1 ];
        ApexPages.StandardController controllerObj = new ApexPages.StandardController(MPS[0]);
        
        test.startTest();
        
        MonthlyPostingSummaryController mpsObj = new MonthlyPostingSummaryController(controllerObj);
        mpsObj.FileExport();
        mpsObj.cancelPublish();
        
        test.stopTest();
        List<MonthlyPostingSummary__c> MPSAssert = [SELECT ID, MPS_Status__c, MPS_Current_Posting_Month__c, (SELECT Id, Name FROM Attachments) FROM MonthlyPostingSummary__c 
                                                    WHERE MPS_Current_Posting_Month__c=true LIMIT 1 ];
        
        System.assertEquals(true, MPSAssert[0].MPS_Current_Posting_Month__c);
        System.assertEquals('Not Published', MPSAssert[0].MPS_Status__c);
    }
}