/*
@Author        : Sushant
@Name          : TSMTargetWorkingDays 
@Created Date  : 28th Feb 2018
@Description   : This is a Batch Class to get the # working days for TSM Target
@version       : 1.0
*/

Public class WorkingDaysCalUtil{
/**
* @description       Method to Calculate working days for TSM Target
* @name              CalWorkingDaysForTSMTarget
* @param             List<TSMTarget__c>
* @return            void
* @throws            NA
*/   
     Public Static List<TSMTarget__c> CalWorkingDaysForTSMTarget(List<TSMTarget__c> tsmtarList){
        id scotlandBHoursId;
        id englandBhoursId;
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        List<BusinessHours> bhList = [SELECT Id,Name FROM BusinessHours limit 5];
        for(BusinessHours bh : bhList){
            if(bh.Name.equalsIgnoreCase(System.Label.ScotlandBusinessHours))
                scotlandBHoursId = bh.id;
            if(bh.Name.equalsIgnoreCase(System.Label.EnglandBusinessHours))
                englandBhoursId = bh.id;
        }        
        for(TSMTarget__c eachRecTSM : tsmtarList){                 
            DateTime startDate = (DateTime) eachRecTSM.TSMTar_StartDate__c;
            DateTime endDate;            
            DateTime fyEndDate = (datetime) eachRecTSM.TSMTar_EndDate__c; 
            if(eachRecTSM.TSMTar_Status__c == System.Label.Terminated && eachRecTSM.TSMTar_TerminationDate__c <= System.today())
                endDate = (DateTime) eachRecTSM.TSMTar_TerminationDate__c;
           // else if(eachRecTSM.TSMTar_EndDate__c <= Date.newInstance(2019, 09, 30)){
                else if(eachRecTSM.TSMTar_EndDate__c <= System.today()){
                endDate = (DateTime) eachRecTSM.TSMTar_EndDate__c; 
            }
            else{
                endDate = System.Now();
                //endDate = date.newInstance(2019, 09, 30);
            }
            
       
           
            if(String.isNotBlank(eachRecTSM.TSMTar_TSMLocation__c)){
                if(eachRecTSM.TSMTar_TSMLocation__c.equalsIgnoreCase(System.Label.England)){
                    eachRecTSM.TSMTar_WorkingDays__c = (BusinessHours.diff(englandBhoursId , startDate, endDate)/(1000*60*60*24))+1;
                    eachRecTSM.TSMTar_TotalWorkingDays__c = (BusinessHours.diff(englandBhoursId , startDate, fyEndDate)/(1000*60*60*24))+1;
                }
                else if(eachRecTSM.TSMTar_TSMLocation__c.equalsIgnoreCase(System.Label.Scotland)){
                    eachRecTSM.TSMTar_WorkingDays__c = (BusinessHours.diff(scotlandBHoursId , startDate, endDate)/(1000*60*60*24))+1;
                    eachRecTSM.TSMTar_TotalWorkingDays__c = (BusinessHours.diff(scotlandBHoursId , startDate, fyEndDate)/(1000*60*60*24))+1; 
               }                
            }  
            else
            {
                eachRecTSM.TSMTar_WorkingDays__c = (BusinessHours.diff(englandBhoursId , startDate, endDate)/(1000*60*60*24))+1;
                    eachRecTSM.TSMTar_TotalWorkingDays__c = (BusinessHours.diff(englandBhoursId , startDate, fyEndDate)/(1000*60*60*24))+1;
            }
            
          
            If(!eachRecTSM.TSMTar_Terminated__c){
                eachRecTSM.TSMTar_FXDirectTargetTillDate__c = (eachRecTSM.TSMTar_FXDirectTarget__c * eachRecTSM.TSMTar_WorkingDays__c) / eachRecTSM.TSMTar_TotalWorkingDays__c;
                eachRecTSM.TSMTar_FXIndirectTargetTillDate__c = (eachRecTSM.TSMTar_FXIndirectTarget__c * eachRecTSM.TSMTar_WorkingDays__c) / eachRecTSM.TSMTar_TotalWorkingDays__c;
                eachRecTSM.TSMTar_CRMTargetTillDate__c = (eachRecTSM.TSMTar_CRMTarget__c * eachRecTSM.TSMTar_WorkingDays__c) / eachRecTSM.TSMTar_TotalWorkingDays__c;
                eachRecTSM.TSMTar_CommTargetTillDate__c = (eachRecTSM.TSMTar_CommTarget__c * eachRecTSM.TSMTar_WorkingDays__c) / eachRecTSM.TSMTar_TotalWorkingDays__c;
                eachRecTSM.TSMTar_IRRMTargetTillDate__c = (eachRecTSM.TSMTar_IRRMTarget__c * eachRecTSM.TSMTar_WorkingDays__c) / eachRecTSM.TSMTar_TotalWorkingDays__c;
                eachRecTSM.TSMTar_FXIndirectTargetTillDate__c = (eachRecTSM.TSMTar_FXIndirectTarget__c * eachRecTSM.TSMTar_WorkingDays__c) / eachRecTSM.TSMTar_TotalWorkingDays__c;
                //Krishna : Added line #68 on 30/04/2019 to calculate tilldate targets figures for Retail
                eachRecTSM.TSMTar_FXRetailTillDate__c = (eachRecTSM.TSMTar_FXRetail__c * eachRecTSM.TSMTar_WorkingDays__c) / eachRecTSM.TSMTar_TotalWorkingDays__c;
                
                if((eachRecTSM.TSMTar_Status__c == System.Label.Terminated && eachRecTSM.TSMTar_TerminationDate__c <= System.Today())
                   || (eachRecTSM.TSMTar_EndDate__c <= System.today())){
                    eachRecTSM.TSMTar_FXDirectTarRemainAtClosure__c = eachRecTSM.TSMTar_FXDirectTarget__c - eachRecTSM.TSMTar_FXDirectTargetTillDate__c;
                    eachRecTSM.TSMTar_FXIndirectTarRemainAtClosure__c = eachRecTSM.TSMTar_FXIndirectTarget__c - eachRecTSM.TSMTar_FXIndirectTargetTillDate__c;
                    eachRecTSM.TSMTar_CRMTarRemainAtClosure__c = eachRecTSM.TSMTar_CRMTarget__c - eachRecTSM.TSMTar_CRMTargetTillDate__c;
                    eachRecTSM.TSMTar_CommTarRemainAtClosure__c = eachRecTSM.TSMTar_CommTarget__c - eachRecTSM.TSMTar_CommTargetTillDate__c;
                    eachRecTSM.TSMTar_IRRMTarRemainAtClosure__c = eachRecTSM.TSMTar_IRRMTarget__c - eachRecTSM.TSMTar_IRRMTargetTillDate__c;
                    eachRecTSM.TSMTar_FXRetailRemainingAtClosure__c = eachRecTSM.TSMTar_FXRetail__c - eachRecTSM.TSMTar_FXRetailTillDate__c;
                       
                    eachRecTSM.TSMTar_FXDirectTarget__c = eachRecTSM.TSMTar_FXDirectTargetTillDate__c;
                    eachRecTSM.TSMTar_FXIndirectTarget__c = eachRecTSM.TSMTar_FXIndirectTargetTillDate__c;
                    eachRecTSM.TSMTar_CRMTarget__c = eachRecTSM.TSMTar_CRMTargetTillDate__c;
                    eachRecTSM.TSMTar_CommTarget__c = eachRecTSM.TSMTar_CommTargetTillDate__c;
                    eachRecTSM.TSMTar_IRRMTarget__c = eachRecTSM.TSMTar_IRRMTargetTillDate__c;
                       eachRecTSM.TSMTar_FXRetail__c = eachRecTSM.TSMTar_FXRetailTillDate__c;
                       
                    eachRecTSM.TSMTar_FXDirectTargetTillDate__c = 0;
                    eachRecTSM.TSMTar_FXIndirectTargetTillDate__c = 0;
                    eachRecTSM.TSMTar_CRMTargetTillDate__c = 0;
                    eachRecTSM.TSMTar_CommTargetTillDate__c = 0;
                    eachRecTSM.TSMTar_IRRMTargetTillDate__c = 0;
                    eachRecTSM.TSMTar_FXRetailTillDate__c   = 0;
                    eachRecTSM.TSMTar_Terminated__c = true;
                    if(eachRecTSM.TSMTar_EndDate__c <= System.today()){
                         eachRecTSM.TSMTar_Status__c = System.Label.Ended;
                    }
                }
            }
        }     
        return tsmtarList ;


    }
    
/**
* @description       Method to Calculate working days for PM Target
* @name              CalWorkingDaysForPMTarget
* @param             List<PMTarget__c>
* @return            List<PMTarget__c>
* @throws            NA
*/   
    Public Static List<PMTarget__c> CalWorkingDaysForPMTarget(List<PMTarget__c> pmtarList){
        id scotlandBHoursId;
        id englandBhoursId;
        Integer fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        List<BusinessHours> bhList = [SELECT Id,Name FROM BusinessHours limit 5];
        for(BusinessHours bh : bhList){
            if(bh.Name.equalsIgnoreCase(System.Label.ScotlandBusinessHours))
                scotlandBHoursId = bh.id;
            if(bh.Name.equalsIgnoreCase(System.Label.EnglandBusinessHours))
                englandBhoursId = bh.id;
        }        
        for(PMTarget__c eachRecPM : pmtarList){                 
            DateTime startDate = (DateTime) eachRecPM.PMTar_StartDate__c;
            DateTime endDate;            
            DateTime fyEndDate = (datetime) eachRecPM.PMTar_EndDate__c;
            if(eachRecPM.PMTar_Status__c == System.Label.Terminated && eachRecPM.PMTar_TerminationDate__c <= System.today())
                endDate = (DateTime) eachRecPM.PMTar_TerminationDate__c;
           // else if(eachRecPM.PMTar_EndDate__c <= Date.newInstance(2019, 09, 30)){
           else if(eachRecPM.PMTar_EndDate__c <= System.today()){
                endDate = (DateTime) eachRecPM.PMTar_EndDate__c; 
            }
            else{
                endDate = System.Now();
                //endDate = date.newInstance(2019, 09, 30);
            }
            System.debug('Name '+eachRecPM.PMTar_PMUser__c);
            // @Santhoshan 28/01/2019: This block is used to calculate total working days and working days till date based on user's location
            if(String.isNotBlank(eachRecPM.PMTar_Location__c)){
                if(eachRecPM.PMTar_Location__c.equalsIgnoreCase(System.Label.England)){
                    eachRecPM.PMTar_WorkingDays__c = (BusinessHours.diff(englandBhoursId , startDate, endDate)/(1000*60*60*24))+1;
                    eachRecPM.PMTar_TotalWorkingDays__c = (BusinessHours.diff(englandBhoursId , startDate, fyEndDate)/(1000*60*60*24))+1;               
                }
                if(eachRecPM.PMTar_Location__c.equalsIgnoreCase(System.Label.Scotland)){
                    eachRecPM.PMTar_WorkingDays__c = (BusinessHours.diff(scotlandBHoursId , startDate, endDate)/(1000*60*60*24))+1;
                    eachRecPM.PMTar_TotalWorkingDays__c = (BusinessHours.diff(scotlandBHoursId , startDate, fyEndDate)/(1000*60*60*24))+1;               
                }                
            }
            else
            {
                eachRecPM.PMTar_WorkingDays__c = (BusinessHours.diff(englandBhoursId , startDate, endDate)/(1000*60*60*24))+1;
                    eachRecPM.PMTar_TotalWorkingDays__c = (BusinessHours.diff(englandBhoursId , startDate, fyEndDate)/(1000*60*60*24))+1;     
            }
           // until here : working days and total working days calculation
            
            //@santhoshan 28/01/2019: this block will be calculating targets till date
            If(!eachRecPM.PMTar_Terminated__c ){
                eachRecPM.PMTar_FXDirectTargetTillDate__c = (eachRecPM.PMTar_FXDirectTarget__c * eachRecPM.PMTar_WorkingDays__c) / eachRecPM.PMTar_TotalWorkingDays__c;
                eachRecPM.PMTar_CRMTargetTillDate__c = (eachRecPM.PMTar_CRMTarget__c * eachRecPM.PMTar_WorkingDays__c) / eachRecPM.PMTar_TotalWorkingDays__c;
                eachRecPM.PMTar_CommTargetTillDate__c = (eachRecPM.PMTar_CommTarget__c * eachRecPM.PMTar_WorkingDays__c) / eachRecPM.PMTar_TotalWorkingDays__c;
                eachRecPM.PMTar_IRRMTargetTillDate__c = (eachRecPM.PMTar_IRRMTarget__c * eachRecPM.PMTar_WorkingDays__c) / eachRecPM.PMTar_TotalWorkingDays__c;
                eachRecPM.PMTar_FXIndirerctTargetTillDate__c = (eachRecPM.PMTar_FXIndirectTarget__c * eachRecPM.PMTar_WorkingDays__c) / eachRecPM.PMTar_TotalWorkingDays__c;
                eachRecPM.PMTar_FXRetailTillDate__c = (eachRecPM.PMTar_FXRetail__c * eachRecPM.PMTar_WorkingDays__c) / eachRecPM.PMTar_TotalWorkingDays__c;
// until here : targets till date calculation

                if((eachRecPM.PMTar_Status__c == System.Label.Terminated && eachRecPM.PMTar_TerminationDate__c <= System.Today())
                   || (eachRecPM.PMTar_EndDate__c <= System.Today())){
                    eachRecPM.PMTar_FXDirectTarRemainAtClosure__c = eachRecPM.PMTar_FXDirectTarget__c - eachRecPM.PMTar_FXDirectTargetTillDate__c;
                    eachRecPM.PMTar_CRMTarRemainAtClosure__c = eachRecPM.PMTar_CRMTarget__c - eachRecPM.PMTar_CRMTargetTillDate__c;
                    eachRecPM.PMTar_CommTarRemainAtClosure__c = eachRecPM.PMTar_CommTarget__c - eachRecPM.PMTar_CommTargetTillDate__c;
                    eachRecPM.PMTar_IRRMTarRemainAtClosure__c = eachRecPM.PMTar_IRRMTarget__c - eachRecPM.PMTar_IRRMTargetTillDate__c;
                    eachRecPM.PMTar_FXIndirectTarRemainAtClosure__c = eachRecPM.PMTar_FXIndirectTarget__c - eachRecPM.PMTar_FXIndirerctTargetTillDate__c;
                    eachRecPM.PMTar_FXRetailRemainingAtClosure__c = eachRecPM.PMTar_FXRetail__c - eachRecPM.PMTar_FXRetailTillDate__c;
                       
                    eachRecPM.PMTar_FXDirectTarget__c = eachRecPM.PMTar_FXDirectTargetTillDate__c;
                       eachRecPM.PMTar_CRMTarget__c = eachRecPM.PMTar_CRMTargetTillDate__c;
                       eachRecPM.PMTar_CommTarget__c = eachRecPM.PMTar_CommTargetTillDate__c;
                       eachRecPM.PMTar_IRRMTarget__c = eachRecPM.PMTar_IRRMTargetTillDate__c;
                       eachRecPM.PMTar_FXIndirectTarget__c = eachRecPM.PMTar_FXIndirerctTargetTillDate__c;
                       eachRecPM.PMTar_FXRetail__c = eachRecPM.PMTar_FXRetailTillDate__c;
                       
                       eachRecPM.PMTar_FXDirectTargetTillDate__c = 0;
                       eachRecPM.PMTar_CRMTargetTillDate__c = 0;
                       eachRecPM.PMTar_CommTargetTillDate__c = 0;
                    eachRecPM.PMTar_IRRMTargetTillDate__c = 0;
                    eachRecPM.PMTar_FXIndirerctTargetTillDate__c = 0; 
                    eachRecPM.PMTar_FXRetailTillDate__c = 0;
                    eachRecPM.PMTar_Terminated__c = true;
                    if(eachRecPM.PMTar_EndDate__c <= System.Today()){
                        eachRecPM.PMTar_Status__c = System.Label.Ended;
                    }
                }
            } 
        }   
        return pmtarList ;
    }
    
}