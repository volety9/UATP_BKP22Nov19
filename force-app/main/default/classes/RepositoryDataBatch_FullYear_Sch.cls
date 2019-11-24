/*
@Author        : Santhoshan
@Name          : RepositoryDataBatch_FullYear
@Created Date  : 2nd April 2019
@Description   : This is a Schedule class for RepositoryDataBatch_FullYear
@version       : 1.0
*/
global class RepositoryDataBatch_FullYear_Sch  implements Schedulable {
/**
* @description       Method to Schedule a RepositoryDataBatch_FullYear Batch class 
* @name              execute
* @param             SchedulableContext
* @return            Void
* @throws            NA
*/
    global void execute(SchedulableContext ctx) {
        RepositoryDataBatch_FullYear rbSch = new RepositoryDataBatch_FullYear();
        DataBase.executeBatch(rbSch,100); 
    }
    
}