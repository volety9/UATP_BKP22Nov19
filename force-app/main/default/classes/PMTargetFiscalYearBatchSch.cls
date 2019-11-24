/*
@Author        : Sushant
@Name          : PMTargetFiscalYearBatchSch 
@Created Date  : 28th Feb 2018
@Description   : This is a Schedule class for PMTargetFiscalYearBatch
@version       : 1.0
*/
global class PMTargetFiscalYearBatchSch implements Schedulable {
/**
* @description       Method to Schedule a PMTargetFiscalYearBatch Batch class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/    
    global void execute(SchedulableContext ctx) {
        PMTargetFiscalYearBatch pmSch = new PMTargetFiscalYearBatch();
        DataBase.executeBatch(pmSch);
    }
    
}