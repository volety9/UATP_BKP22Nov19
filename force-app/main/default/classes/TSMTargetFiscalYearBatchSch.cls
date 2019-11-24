/*
@Author        : Santhoshan
@Name          : TSMTargetFiscalYearBatchSch 
@Created Date  : 28th Feb 2018
@Description   : This is a Schedule class for TSMTargetFiscalYearBatch
@version       : 1.0
*/
global class TSMTargetFiscalYearBatchSch implements Schedulable {
/**
* @description       Method to Schedule a TSMTargetFiscalYearBatch Batch class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/ 
    global void execute(SchedulableContext ctx) {
        TSMTargetFiscalYearBatch tsmSch = new TSMTargetFiscalYearBatch();
        DataBase.executeBatch(tsmSch); 
    }
    
}