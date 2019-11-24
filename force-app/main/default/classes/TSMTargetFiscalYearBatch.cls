/*
@Author        : Santhoshan
@Name          : TSMTargetFiscalYearBatch
@Created Date  : 28th Feb 2018
@Description   : This is a Batch Class to convert the TSM Targets to the Current Fiscal Year
@version       : 1.0
*/
global class TSMTargetFiscalYearBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT TSMTar_TSM__c, TSMTar_Team__c,'+ 
            'TSMTar_StartDate__c,TSMTar_EndDate__c, TSMTar_IsCurrentFY__c,'+
            'TSMTar_FXDirectTarget__c, TSMTar_FXIndirectTarget__c,'+
            'TSMTar_CRMTarget__c, TSMTar_CommTarget__c, TSMTar_IRRMTarget__c,'+            
            'TSMTar_Status__c, TSMTar_FXRetail__c FROM TSMTarget__c '+
            'WHERE TSMTar_Status__c != \'Inactive\'';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<TSMTarget__c> scope){
        List<TSMTarget__c> TSMTarList = new List<TSMTarget__c>();
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        Date endDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth); 
        
        for(TSMTarget__c eachRecTSM : scope){
            if(eachRecTSM.TSMTar_Status__c.equals(System.Label.Active) || eachRecTSM.TSMTar_Status__c.equals(System.Label.Ended))
            {
                TSMTarget__c newTSMTar = new TSMTarget__c();
                newTSMTar.TSMTar_TSM__c = eachRecTSM.TSMTar_TSM__c;
                newTSMTar.TSMTar_Team__c = eachRecTSM.TSMTar_Team__c;
                newTSMTar.TSMTar_StartDate__c = startDate;
                newTSMTar.TSMTar_EndDate__c = endDate;
                newTSMTar.TSMTar_IsCurrentFY__c = true;
                newTSMTar.TSMTar_FXDirectTarget__c = eachRecTSM.TSMTar_FXDirectTarget__c;
                newTSMTar.TSMTar_FXIndirectTarget__c = eachRecTSM.TSMTar_FXIndirectTarget__c;
                newTSMTar.TSMTar_CRMTarget__c = eachRecTSM.TSMTar_CRMTarget__c;
                newTSMTar.TSMTar_CommTarget__c = eachRecTSM.TSMTar_CommTarget__c;
                newTSMTar.TSMTar_IRRMTarget__c = eachRecTSM.TSMTar_IRRMTarget__c;  
                newTSMTar.TSMTar_FXRetail__c = eachRecTSM.TSMTar_FXRetail__c;  
                newTSMTar.TSMTar_Status__c = System.Label.Active;
                TSMTarList.add(newTSMTar);
                eachRecTSM.TSMTar_IsCurrentFY__c = false;
                eachRecTSM.TSMTar_Status__c = System.Label.Inactive;
            }
            //else if(eachRecTSM.TSMTar_Status__c.equals(System.Label.Terminated))
            else{
                eachRecTSM.TSMTar_IsCurrentFY__c = false;
                eachRecTSM.TSMTar_Status__c = System.Label.Inactive;
            }
            
        }
        if(!scope.isEmpty()){
        	Database.SaveResult[] urList = Database.update(scope,false);
            /*for (Database.SaveResult ur : urList) {
                if (ur.isSuccess()) {
                    System.debug('Successfully Updated Old TSM Target. TSM Target ID: ' + ur.getId());
                }
                else {
                    for(Database.Error err : ur.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('TSM Target fields that affected this error: ' + err.getFields());
                    }
                } 
            }*/
        }
        if(!TSMTarList.isEmpty()){
        	Database.SaveResult[] srList = Database.insert(TSMTarList,false);
            /*for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully Inserted New TSM Target. TSM Target ID: ' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('TSM Target fields that affected this error: ' + err.getFields());
                    }
                }
            }*/
        }        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}