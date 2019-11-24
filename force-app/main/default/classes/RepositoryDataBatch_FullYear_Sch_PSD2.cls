global class RepositoryDataBatch_FullYear_Sch_PSD2 implements Schedulable{
	
     global void execute(SchedulableContext ctx) {        
        RepositoryDataDeleteBatch_FullYear_PSD2 rbdbc = new RepositoryDataDeleteBatch_FullYear_PSD2();
        DataBase.executeBatch(rbdbc,100); 
    }

}