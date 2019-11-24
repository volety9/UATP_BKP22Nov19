/*
@Author        : Krishnakanth Volety
@Name          : CancelledTradeJournalAlerts_SchedTest
@Created Date  : 19 June 2019
@Description   : This is a Schedule class for CancelledTradeJournalAlerts_SchedTest
@version       : 1.0
*/
@isTest
public class CancelledTradeJournalAlerts_SchedTest{
   public static testMethod void testschedule() {
        Test.StartTest();
       List<Opportunity> oppList = [Select id,name,opp_tradeid__c,recordtype.name,amount,sum_of_journals__c from opportunity where closedate=THIS_FISCAL_YEAR and stagename='Closed Won' and amount=0 and sum_of_journals__c!=0];
       string header = 'Record Id,Opportunity_Name,TradeId,ProductType,Opp_VA,Sum_Of_Journals \n';
       string finalstr = header ;
    //   for(Opportunity a: oppList)
//{
       string recordString = '0061w00001908st,820406,82406,FX Cash,0,1000';
       finalstr = finalstr +recordString;
//}

       
        CancelledTradeJournalAlerts_Sched sh1 = new CancelledTradeJournalAlerts_Sched();
        
        String sch = '0 0 0 1 10 ? *'; 
       
        system.schedule('Test Batch Run1', sch, sh1); 
        Test.stopTest();
    }


}