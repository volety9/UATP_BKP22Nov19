/*
@Author        : Santhoshan
@Name          : PMTargetWorkingDaysSch 
@Created Date  : 28th Feb 2018
@Description   : This is a Schedule class for PMTargetWorkingDays
@version       : 1.0
*/
global class PMTargetWorkingDaysSch implements Schedulable {
/**
* @description       Method to Schedule a PMTargetWorkingDays Batch class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/ 
    global void execute(SchedulableContext ctx) {
        PMTargetWorkingDays pmSch = new PMTargetWorkingDays();
        DataBase.executeBatch(pmSch); 
    }
    
}