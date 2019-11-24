/*
@Author        : Sushant
@Name          : TSMTargetWorkingDays 
@Created Date  : 28th Feb 2018
@Description   : This is a Batch Class to get the # working days for TSM Target
@version       : 1.0
*/
global class TSMTargetWorkingDays implements Database.Batchable<sObject>{
/**
* @description       Method to get all Active and Closed TSM target records where End date is greater than Today
* @name              start
* @param             Database.BatchableContext
* @return            Database.QueryLocator
* @throws            NA
*/ 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query =  'SELECT ID, TSMTar_TSM__c, TSMTar_TSMLocation__c, TSMTar_StartDate__c, '+
                        'TSMTar_TotalWorkingDays__c, TSMTar_WorkingDays__c, TSMTar_TerminationDate__c, '+
                        'TSMTar_Status__c, TSMTar_EndDate__c , TSMTar_FXDirectTarget__c, TSMTar_Terminated__c, '+
            			'TSMTar_FXDirectTargetTillDate__c, TSMTar_FXIndirectTarget__c, TSMTar_FXIndirectTargetTillDate__c, '+
            			'TSMTar_CRMTarget__c, TSMTar_CRMTargetTillDate__c, TSMTar_CommTarget__c, '+
            			'TSMTar_CommTargetTillDate__c, TSMTar_IRRMTarget__c, TSMTar_IRRMTargetTillDate__c, '+
            			'TSMTar_FXRetail__c, TSMTar_FXRetailTillDate__c,'+
            			'TSMTar_FXRetailRemainingAtClosure__c,'+
            			'TSMTar_FXDirectTarRemainAtClosure__c, TSMTar_FXIndirectTarRemainAtClosure__c, '+
            			'TSMTar_CRMTarRemainAtClosure__c, TSMTar_CommTarRemainAtClosure__c, TSMTar_IRRMTarRemainAtClosure__c '+
                        'FROM TSMTarget__c WHERE TSMTar_Status__c != \'Inactive\' AND TSMTar_Terminated__c = false';        
        return Database.getQueryLocator(query);
    }
/**
* @description       Method to calculate No of working days till and Total No of working days .
* @name              execute
* @param             Database.BatchableContext,List<TSMTarget__c>
* @return            Void
* @throws            NA
*/ 
    global void execute(Database.BatchableContext BC, List<TSMTarget__c> scope){
        List<TSMTarget__c> updateTSMTarList = WorkingDaysCalUtil.CalWorkingDaysForTSMTarget(scope);
        Database.SaveResult[] urList = Database.update(updateTSMTarList, False);                
        /*for (Database.SaveResult ur : urList) {
            if (ur.isSuccess()) {
                System.debug('Successfully Updated TSM Target. TSM Target ID: ' + ur.getId());
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
/**
* @description       Finish Method
* @name              finish
* @param             Database.BatchableContext
* @return            Void
* @throws            NA
*/     
    global void finish(Database.BatchableContext BC){
    }
}