/*
@Author        : Santhoshan
@Name          : PMTargetFiscalYearBatch
@Created Date  : 28th Feb 2018
@Description   : This is a Batch Class to convert the PM Targets to the Current Fiscal Year
@version       : 1.0
*/
global class PMTargetFiscalYearBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT PMTar_PMContact__c, Owner.Id,'+ 
            'PMTar_StartDate__c,PMTar_PMUser__c, PMTar_IsCurrentFY__c,'+
            'PMTar_EndDate__c, PMTar_FXDirectTarget__c,'+
            'PMTar_CRMTarget__c, PMTar_CommTarget__c, PMTar_IRRMTarget__c,'+
            'PMTar_FXIndirectTarget__c, PMTar_FXRetail__c,'+
            'PMTar_FXIndirectActual__c, PMTar_FXRetailActual__c,'+
            'PMTar_FXDirectActual__c, PMTar_CRMActual__c,'+
            'PMTar_CommActual__c, PMTar_IRRMActual__c,'+
            'PMTar_Status__c FROM PMTarget__c '+
            'WHERE PMTar_Status__c != \'Inactive\'';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<PMTarget__c> scope){
        List<PMTarget__c> PMTarList = new List<PMTarget__c>();
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        Date startDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        Date endDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        
        for(PMTarget__c eachRecPM : scope){
            if(eachRecPM.PMTar_Status__c.equals(System.Label.Active) || eachRecPM.PMTar_Status__c.equals(System.Label.Ended))
            {
                PMTarget__c newPMTar = new PMTarget__c();
                newPMTar.PMTar_PMContact__c = eachRecPM.PMTar_PMContact__c;
                newPMTar.OwnerId = eachRecPM.Owner.Id;
                newPMTar.PMTar_PMUser__c = eachRecPM.PMTar_PMUser__c;
                newPMTar.PMTar_StartDate__c = startDate;
                newPMTar.PMTar_EndDate__c = endDate;
                newPMTar.PMTar_IsCurrentFY__c = true;
                newPMTar.PMTar_FXDirectTarget__c = eachRecPM.PMTar_FXDirectTarget__c;
                newPMTar.PMTar_CRMTarget__c = eachRecPM.PMTar_CRMTarget__c;
                newPMTar.PMTar_CommTarget__c = eachRecPM.PMTar_CommTarget__c;
                newPMTar.PMTar_IRRMTarget__c = eachRecPM.PMTar_IRRMTarget__c;   
                newPMTar.PMTar_FXIndirectTarget__c = eachRecPM.PMTar_FXIndirectTarget__c; 
                newPMTar.PMTar_FXRetail__c = eachRecPM.PMTar_FXRetail__c; 
                newPMTar.PMTar_Status__c = System.Label.Active;
                PMTarList.add(newPMTar);
                eachRecPM.PMTar_IsCurrentFY__c = false;
                eachRecPM.PMTar_Status__c = System.Label.Inactive;
            }
            //else if(eachRecPM.PMTar_Status__c.equals(System.Label.Terminated))
            else{
                eachRecPM.PMTar_IsCurrentFY__c = false;
                eachRecPM.PMTar_Status__c = System.Label.Inactive;
            }
            
        }                                   
        if(!scope.isEmpty()){     
        	Database.SaveResult[] urList = Database.update(scope,false);
          	/*for (Database.SaveResult sr : urList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully Inserted New PM Target. PM Target ID: ' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('PM Target fields that affected this error: ' + err.getFields());
                    }
                }
            }*/
        }
        if(!PMTarList.isEmpty()){
        	Database.SaveResult[] srList = Database.insert(PMTarList,false);
        	/*for (Database.SaveResult ur : srList) {
                if (ur.isSuccess()) {
                    System.debug('Successfully Updated Old PM Target. PM Target ID: ' + ur.getId());
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
    }
    
    global void finish(Database.BatchableContext BC){
    }
}