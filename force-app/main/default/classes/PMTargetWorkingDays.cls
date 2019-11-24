/*
@Author        : Sushant
@Name          : PMTargetWorkingDays 
@Created Date  : 28th Feb 2018
@Description   : This is a Batch Class to get the # working days for PM Target
@version       : 1.0
*/
global class PMTargetWorkingDays implements Database.Batchable<sObject>{
/**
* @description       Method to get all Active and Closed PM target records where End date is greater than Today
* @name              start
* @param             Database.BatchableContext
* @return            Database.QueryLocator
* @throws            NA
*/     
    global Database.QueryLocator start(Database.BatchableContext BC){
		String query =  'SELECT ID, PMTar_PMUser__c, PMTar_Location__c, PMTar_StartDate__c, '+
                        'PMTar_TotalWorkingDays__c, PMTar_WorkingDays__c, PMTar_Terminated__c, '+
                        'PMTar_Status__c, PMTar_EndDate__c , PMTar_FXDirectTarget__c, '+
            			'PMTar_FXDirectTargetTillDate__c, PMTar_TerminationDate__c, '+
            			'PMTar_CRMTarget__c, PMTar_CRMTargetTillDate__c, PMTar_CommTarget__c, '+
            			'PMTar_CommTargetTillDate__c, PMTar_IRRMTarget__c, PMTar_IRRMTargetTillDate__c, '+
             			'PMTar_FXIndirectTarget__c, PMTar_FXIndirerctTargetTillDate__c,' +
            			'PMTar_FXRetail__c, PMTar_FXRetailTillDate__c,'+
            			'PMTar_FXDirectTarRemainAtClosure__c, PMTar_IRRMTarRemainAtClosure__c, '+
            			'PMTar_CRMTarRemainAtClosure__c, PMTar_CommTarRemainAtClosure__c, '+
            			'PMTar_FXIndirectTarRemainAtClosure__c, PMTar_FXRetailRemainingAtClosure__c '+
                        'FROM PMTarget__c WHERE PMTar_Status__c != \'Inactive\' AND PMTar_Terminated__c = false';        
               
        return Database.getQueryLocator(query);
    }
/**
* @description       Method to calculate No of working days till and Total No of working days .
* @name              execute
* @param             Database.BatchableContext,List<PMTarget__c>
* @return            Void
* @throws            NA
*/     
    global void execute(Database.BatchableContext BC, List<PMTarget__c> scope){
        List<PMTarget__c> updatePMTarList = WorkingDaysCalUtil.CalWorkingDaysForPMTarget(scope);
        Database.SaveResult[] urList = Database.update(updatePMTarList);                
        /*for (Database.SaveResult ur : urList) {
            if (ur.isSuccess()) {
                System.debug('Successfully Updated PM Target. PM Target ID: ' + ur.getId());
            }
            else {
                for(Database.Error err : ur.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('PM Target fields that affected this error: ' + err.getFields());
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