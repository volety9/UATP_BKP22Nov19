/*
@Author        : Santhoshan
@Name          : RepositoryDataBatch
@Created Date  : 28th Feb 2018
@Description   : This is a Schedule class for RepositoryDataBatch
@version       : 1.0
*/
global class RepositoryDataBatchSch implements Schedulable {
/**
* @description       Method to Schedule a RepositoryDataBatch Batch class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/ 
    global void execute(SchedulableContext ctx) {
        RepositoryDataBatch rbSch = new RepositoryDataBatch();
        DataBase.executeBatch(rbSch,100); 
    }
    
}