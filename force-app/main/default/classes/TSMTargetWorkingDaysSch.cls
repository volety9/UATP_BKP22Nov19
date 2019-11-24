/*
@Author        : Santhoshan
@Name          : TSMTargetWorkingDaysSch 
@Created Date  : 28th Feb 2018
@Description   : This is a Schedule class for TSMTargetWorkingDays
@version       : 1.0
*/
global class TSMTargetWorkingDaysSch implements Schedulable {
/**
* @description       Method to Schedule a TSMTargetWorkingDays Batch class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/ 
    global void execute(SchedulableContext ctx) {
        TSMTargetWorkingDays tsmSch = new TSMTargetWorkingDays();
        DataBase.executeBatch(tsmSch); 
    }
    
}