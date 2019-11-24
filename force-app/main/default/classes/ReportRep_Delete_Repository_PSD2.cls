/*
@Author        : Sandeep
@Name          : ReportRep_Delete_Repository_PSD2
@Created Date  : 16th Aug 2019
@Description   : This is a Batch class for Deleting the Repository Records of RecordType "CustomerAndPM"
@version       : 1.0
@UpdatedBy     :Krishna
@UpdatedDate   :22 oct 2019
*/
global class ReportRep_Delete_Repository_PSD2 implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){       
        
        return Database.getQueryLocator([SELECT Id FROM Repository__c WHERE RecordType.Name = 'CustomerAndPM']); 
    } 
    global void execute(Database.BatchableContext BC, List<Repository__c> scope){
        List<Repository__c> repCustomerAndPmList = new List<Repository__c>();
        for(Repository__c repo:scope){
            repCustomerAndPmList.add(repo);
        }
        if(!repCustomerAndPmList.isEmpty()){
            delete repCustomerAndPmList;
        }
        
    }
    global void finish(Database.BatchableContext BC){ 
       //ReportRep_Batch_PSD2 reportRepBatch = new ReportRep_Batch_PSD2();   
        //Database.executeBatch(reportRepBatch,200);
        ReportRepOppty_Batch obj = new ReportRepOppty_Batch();     
        Database.executeBatch(obj,100);
        //ReportRep_Batch obj = new ReportRep_Batch();
        //Database.executeBatch(obj,100);
        //ReportRepCM_Current_FY_Batch_PSD2 reportRepBatch = new ReportRepCM_Current_FY_Batch_PSD2();        
        //Database.executeBatch(reportRepBatch,100);
        
    }    
}