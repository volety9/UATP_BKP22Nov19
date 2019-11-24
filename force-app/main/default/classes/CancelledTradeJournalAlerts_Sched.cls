/*
@Author        : Krishnakanth Volety
@Name          : CancelledTradeJournalAlerts_Sched
@Created Date  : 19 June 2019
@Description   : This is a Schedule class for CancelledTradeJournalAlerts_Sched
@version       : 1.0
*/
global class CancelledTradeJournalAlerts_Sched implements Schedulable {
/**
* @description       Method to Schedule a CancelledTradeJournalAlerts_Sched class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/
    global void execute(SchedulableContext ctx) {
    
                List<Opportunity> oppList = [Select id,name,opp_tradeid__c,opp_tradedate__C,opp_tradestatus__c,recordtype.name,amount,sum_of_journalLINES__c from opportunity where closedate=THIS_FISCAL_YEAR and stagename='Closed Won' and amount=0 and sum_of_journalLINES__c!=0];
string header = 'Record Id,Opportunity_Name,TradeId,TradeDate,TradeStatus,ProductType,Opp_VA,Sum_Of_Journals \n';
string finalstr = header ;
for(Opportunity a: oppList)
{
       string recordString = '"'+a.id+'","'+a.Name+'","'+a.opp_tradeid__c+'","'+a.opp_tradedate__C+'","'+a.opp_tradestatus__c+'","'+a.recordtype.name +'","'+a.amount+'","'+a.sum_of_journalLINES__c +'"\n';
       finalstr = finalstr +recordString;
}

String TradeCount;
String tdy = System.today().format();

AggregateResult[] agrtradecount = [Select count(id) cnt from opportunity where closedate=THIS_FISCAL_YEAR and stagename='Closed Won' and amount=0 and sum_of_journalLINES__c!=0];
for( AggregateResult each : agrtradecount)
                             {
                             
                             TradeCount =   string.valueOf((Integer)each.get('cnt'));
                             }
Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
blob csvBlob = Blob.valueOf(finalstr);
string csvname= 'FY20_Cancelled_Trades.csv';
csvAttc.setFileName(csvname);
csvAttc.setBody(csvBlob);
Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
String[] toAddresses = new list<string> {'krishnakanth.volety@cybg.com','zoe.graham@cybg.com','elizabeth.innes@cybg.com'};
String subject ='FY20 Cancelled Trades with No Contra Journals...';
email.setSubject(subject);
email.setToAddresses(toAddresses);
email.setPlainTextBody('Hi FRS,\n\n Please find attached file where we have extracted all FY20 cancelled trades for which no contra entry created and hence discrepancy between opportunity and sum of journals...\n\nThe number of cancelled trades in the system with no contra journals as on today : '+tdy+' are:'+ TradeCount +'\n\nPlease verfiy and take appropriate action' + '\n\n Thanks and Regards,\nAccenture CRM Support');
email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
}
    
}