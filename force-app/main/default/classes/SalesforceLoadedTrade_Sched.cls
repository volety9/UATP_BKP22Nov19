/*
@Author        : Krishnakanth Volety
@Name          : SalesforceLoadedTrade_Sched
@Created Date  : 14 Oct 2019
@Description   : This is a Schedule class for SalesforceLoadedTrade_Sched
@version       : 1.0
*/
global class SalesforceLoadedTrade_Sched implements Schedulable {
/**
* @description       Method to Schedule a SalesforceLoadedTrade_Sched class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/
    global void execute(SchedulableContext ctx) {
    List<Calypsodata__c> calList = [select cd_tradeid__c,cd_conversionstatus__c,CD_ETREUTERSPNL__c,createddate from calypsodata__c where createddate=today and createdby.name='DLAPI User'];
string header = 'Trade Id,Trade Status,ET Reuters PNL,CreatedDate\n';
string finalstr = header ;
for(Calypsodata__c a: calList)
{
       string recordString = '"'+a.cd_tradeid__c+'","'+a.cd_conversionstatus__c+'","'+a.CD_ETREUTERSPNL__c+'","'+a.createddate +'"\n';
       finalstr = finalstr +recordString;
}

String TradeCount;
String tdy = System.today().format();
string convertedCount;
string failedCount;
AggregateResult[] agrtradecount = [Select count(id) cnt from Calypsodata__c where createddate=today and createdby.name='DLAPI User'];
for( AggregateResult each : agrtradecount)
                             {
                             
                             TradeCount =   string.valueOf((Integer)each.get('cnt'));
                             }
AggregateResult[] agrconverted = [SELECT Count(ID) cnt FROM CalypsoData__c where CD_ConversionStatus__c  = 'Converted' AND CreatedDate = today AND CreatedBy.Name = 'DLAPI User'];
AggregateResult[] agrfailed = [SELECT Count(ID) cnt FROM CalypsoData__c where CD_ConversionStatus__c!='Converted' AND CreatedDate = today AND CreatedBy.Name = 'DLAPI User' ];
                             for( AggregateResult each : agrconverted)
                             {
                             
                             convertedCount = string.valueOf((Integer)each.get('cnt'));
                             }
                             for(AggregateResult each : agrfailed )
                             {
                             failedCount = string.valueOf((Integer)each.get('cnt'));
                             }
Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
blob csvBlob = Blob.valueOf(finalstr);
string csvname= 'SalesforceUploadedTrades.csv';
csvAttc.setFileName(csvname);
csvAttc.setBody(csvBlob);
Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
String[] toAddresses = new list<string> {'krishnakanth.volety@cybg.com','elizabeth.innes@cybg.com','zoe.graham@cybg.com'};
String subject ='Salesforce Uploaded Trades :Today';
email.setSubject(subject);
email.setToAddresses(toAddresses);
email.setPlainTextBody('Hi FRS,\n\n Total no of trades uploaded to Salesforce as on '+tdy+' are : '+TradeCount+'\n\n Success Trades :'+convertedCount+'\n Failure Trades : '+failedCount+'\n\n Please find attached file for your reference' + '\n\n Thanks and Regards,\nAccenture CRM Support');
email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
}
    
}