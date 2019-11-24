public class FRSDealStatistics {
    Public List<WrapperClass> wrappyList{get; set;}
    
    Integer fyStartMonth;
    Public Date fyStartDate;
    Public Date fyEndDate; 
    
    Public List<String> monthListTot = new List<String>{'0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00'};
        Public List<Integer> cntListTot = new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0};
            
    Public List<String> monthList = new List<String>{'0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00'};
        Public List<Integer> cntList = new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0};
            
    Public Map<String, List<String>> productMap = new Map<String, List<String>>();
    Public Map<String, List<Integer>> cntMap = new Map<String, List<Integer>>();
    
    Public Map<String, List<String>> productMapfx = new Map<String, List<String>>();
    Public Map<String, List<Integer>> cntMapfx = new Map<String, List<Integer>>();
                               
    public FRSDealStatistics(){
        wrappyList = new List<WrapperClass>();
        
        fyStartMonth = CYBGUtilClass.fiscalYearStartMonth();
        fyStartDate = CYBGUtilClass.findStartDateOfFY(System.Today(), fyStartMonth); 
        fyEndDate = CYBGUtilClass.findEndDateOfFY(System.Today(), fyStartMonth);
        
        exec();
    }
    public void exec()
    {
        String grouper = '';
        Boolean groupIt = false;
        List<String> lists = new List<String>();
        
        AggregateResult[] agr = [SELECT SUM(Amount) amt, CALENDAR_MONTH(CloseDate) csd, Count(Id) cnt, Product__c prd FROM Opportunity WHERE 
                                 CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND StageName = 'Closed Won' AND Amount != 0
                                 AND RecordType.Name != 'FX Cash'
                                 GROUP BY  Product__c, CALENDAR_MONTH(CloseDate) 
                                 ORDER BY  Product__c, CALENDAR_MONTH(CloseDate)];
        
        AggregateResult[] agrfxd = [SELECT SUM(Amount) amt, CALENDAR_MONTH(CloseDate) csd, Count(Id) cnt, Product__c prd FROM Opportunity WHERE 
                                    CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND StageName = 'Closed Won' AND Amount != 0
                                    AND RecordType.Name = 'FX Cash' AND Opp_BranchNumber__c IN ('CB Direct Dealing Client', 'YBDirectDealingClient Group') 
                                    AND Account.RM_Name__c != null
                                    GROUP BY  Product__c, CALENDAR_MONTH(CloseDate) 
                                    ORDER BY  Product__c, CALENDAR_MONTH(CloseDate)];
        
        AggregateResult[] agrfxind = [SELECT SUM(Amount) amt, CALENDAR_MONTH(CloseDate) csd, Count(Id) cnt, Product__c prd FROM Opportunity WHERE 
                                      CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND StageName = 'Closed Won' AND Amount != 0
                                      AND RecordType.Name = 'FX Cash' AND Opp_BranchNumber__c NOT IN ('CB Direct Dealing Client', 'YBDirectDealingClient Group') 
                                      AND Account.RM_Name__c != null
                                      GROUP BY  Product__c, CALENDAR_MONTH(CloseDate) 
                                      ORDER BY  Product__c, CALENDAR_MONTH(CloseDate)];
        
        AggregateResult[] agrfxret = [SELECT SUM(Amount) amt, CALENDAR_MONTH(CloseDate) csd, Count(Id) cnt, Product__c prd FROM Opportunity WHERE 
                                      CloseDate >= :fyStartDate AND CloseDate <= :fyEndDate AND StageName = 'Closed Won' AND Amount != 0
                                      AND RecordType.Name = 'FX Cash' AND Opp_BranchNumber__c NOT IN ('CB Direct Dealing Client', 'YBDirectDealingClient Group') 
                                      AND Account.RM_Name__c = null
                                      GROUP BY  Product__c, CALENDAR_MONTH(CloseDate) 
                                      ORDER BY  Product__c, CALENDAR_MONTH(CloseDate)];
        
        for(AggregateResult eachagr : agr)
        {

            System.debug('PRD '+(String)eachagr.get('prd'));
            System.debug('CSD '+(Integer)eachagr.get('csd'));
            if(productMap.containsKey((String)eachagr.get('prd')))
            {
                monthlist[(Integer)eachagr.get('csd')] = String.valueOf(eachagr.get('amt'));
                cntlist[(Integer)eachagr.get('csd')] =(Integer)eachagr.get('cnt');
                
                monthlistTot[(Integer)eachagr.get('csd')] = String.valueOf((Decimal)eachagr.get('amt') + Decimal.valueOf(monthlistTot[(Integer)eachagr.get('csd')]));
                cntlistTot[(Integer)eachagr.get('csd')] =(Integer)eachagr.get('cnt') + cntlistTot[(Integer)eachagr.get('csd')];
                
                productMap.put((String)eachagr.get('prd'), monthList);
                cntMap.put((String)eachagr.get('prd'), cntList);
            }
            else
            {
                monthList = new List<String>{'0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00'};
                    cntList = new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                        
                monthlist[(Integer)eachagr.get('csd')] = String.valueOf(eachagr.get('amt'));
                cntlist[(Integer)eachagr.get('csd')] = (Integer)eachagr.get('cnt');
                
                monthlistTot[(Integer)eachagr.get('csd')] = String.valueOf((Decimal)eachagr.get('amt') + Decimal.valueOf(monthlistTot[(Integer)eachagr.get('csd')]));
                cntlistTot[(Integer)eachagr.get('csd')] =(Integer)eachagr.get('cnt') + cntlistTot[(Integer)eachagr.get('csd')];
                
                productMap.put((String)eachagr.get('prd'), monthList);
                cntMap.put((String)eachagr.get('prd'), cntList);
            }
        }
        for(AggregateResult each : agrfxd)
        {
            if(productMapfx.containsKey((String)each.get('prd') + '_FX Direct'))
            {
                monthlist[(Integer)each.get('csd')] = String.valueOf(each.get('amt')) ;
                cntlist[(Integer)each.get('csd')] =(Integer)each.get('cnt');
                
                monthlistTot[(Integer)each.get('csd')] = String.valueOf((Decimal)each.get('amt') + Decimal.valueOf(monthlistTot[(Integer)each.get('csd')]));
                cntlistTot[(Integer)each.get('csd')] =(Integer)each.get('cnt') + cntlistTot[(Integer)each.get('csd')];
                
                productMapfx.put((String)each.get('prd') + '_FX Direct', monthList);
                cntMapfx.put((String)each.get('prd') + '_FX Direct', cntList);
            }
            else
            {
                monthList = new List<String>{'0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00'};
                    cntList = new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                        
                monthlist[(Integer)each.get('csd')] = String.valueOf(each.get('amt'));
                cntlist[(Integer)each.get('csd')] = (Integer)each.get('cnt');
                
                monthlistTot[(Integer)each.get('csd')] = String.valueOf((Decimal)each.get('amt') + Decimal.valueOf(monthlistTot[(Integer)each.get('csd')]));
                cntlistTot[(Integer)each.get('csd')] =(Integer)each.get('cnt') + cntlistTot[(Integer)each.get('csd')];
                
                productMapfx.put((String)each.get('prd') + '_FX Direct', monthList);
                cntMapfx.put((String)each.get('prd') + '_FX Direct', cntList);
            }
        }
        for(AggregateResult each : agrfxind)
        {
            if(productMapfx.containsKey((String)each.get('prd') + '_FX Indirect'))
            {
                monthlist[(Integer)each.get('csd')] = String.valueOf(each.get('amt'));
                cntlist[(Integer)each.get('csd')] =(Integer)each.get('cnt');
                
                monthlistTot[(Integer)each.get('csd')] = String.valueOf((Decimal)each.get('amt') + Decimal.valueOf(monthlistTot[(Integer)each.get('csd')]));
                cntlistTot[(Integer)each.get('csd')] =(Integer)each.get('cnt') + cntlistTot[(Integer)each.get('csd')];
                
                productMapfx.put((String)each.get('prd') + '_FX Indirect', monthList);
                cntMapfx.put((String)each.get('prd') + '_FX Indirect', cntList);
            }
            else
            {
                monthList = new List<String>{'0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00'};
                    cntList = new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                        
                monthlist[(Integer)each.get('csd')] = String.valueOf(each.get('amt'));
                cntlist[(Integer)each.get('csd')] = (Integer)each.get('cnt');
                
                monthlistTot[(Integer)each.get('csd')] = String.valueOf((Decimal)each.get('amt') + Decimal.valueOf(monthlistTot[(Integer)each.get('csd')]));
                cntlistTot[(Integer)each.get('csd')] =(Integer)each.get('cnt') + cntlistTot[(Integer)each.get('csd')];
                
                productMapfx.put((String)each.get('prd') + '_FX Indirect', monthList);
                cntMapfx.put((String)each.get('prd') + '_FX Indirect', cntList);
            }
        }
        for(AggregateResult each : agrfxret)
        {
            if(productMapfx.containsKey((String)each.get('prd') + '_FX Retail'))
            {
                monthlist[(Integer)each.get('csd')] = String.valueOf(each.get('amt'));
                cntlist[(Integer)each.get('csd')] =(Integer)each.get('cnt');
                
                monthlistTot[(Integer)each.get('csd')] = String.valueOf((Decimal)each.get('amt') + Decimal.valueOf(monthlistTot[(Integer)each.get('csd')]));
                cntlistTot[(Integer)each.get('csd')] =(Integer)each.get('cnt') + cntlistTot[(Integer)each.get('csd')];
                
                productMapfx.put((String)each.get('prd') + '_FX Retail', monthList);
                cntMapfx.put((String)each.get('prd') + '_FX Retail', cntList);
            }
            else
            {
                monthList = new List<String>{'0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00'};
                    cntList = new List<Integer>{0,0,0,0,0,0,0,0,0,0,0,0,0};
                        
                monthlist[(Integer)each.get('csd')] = String.valueOf(each.get('amt'));
                cntlist[(Integer)each.get('csd')] = (Integer)each.get('cnt');
                
                monthlistTot[(Integer)each.get('csd')] = String.valueOf((Decimal)each.get('amt') + Decimal.valueOf(monthlistTot[(Integer)each.get('csd')]));
                cntlistTot[(Integer)each.get('csd')] =(Integer)each.get('cnt') + cntlistTot[(Integer)each.get('csd')];
                
                productMapfx.put((String)each.get('prd') + '_FX Retail', monthList);
                cntMapfx.put((String)each.get('prd') + '_FX Retail', cntList);
            }
        }
        
        lists.addAll(productMapfx.keySet());	
        lists.sort();
        wrappyList.add(new WrapperClass('Non FX Trades', true, true)
                                           );
        for(String each : productMap.keySet())
        {
            wrappyList.add(new WrapperClass((String)each, (List<Integer>)cntMap.get((String)each), (List<String>)productMap.get((String)each)
                                           ));
        }
        wrappyList.add(new WrapperClass('FX Trades', true, true)
                                           );
        for(String each : lists)
        {
            if(grouper != (String)each.split('_')[0])
            {
                groupIt = true;
            	wrappyList.add(new WrapperClass((String)each.split('_')[0], groupIt, false)
                                           );
                grouper = (String)each.split('_')[0];
            }
            
            wrappyList.add(new WrapperClass((String)each.split('_')[1], (List<Integer>)cntMapfx.get((String)each), (List<String>)productMapfx.get((String)each)
                                           ));
        }
        wrappyList.add(new WrapperClass('Total', (List<Integer>)cntlistTot, (List<String>)monthlistTot, (Boolean) groupIt)
                                           );
    }
    
    public PageReference downloadReport(){
        PageReference nextPage = new PageReference('/apex/FRSDealStatistics_Dld');
        return nextPage;
    }
    public Class WrapperClass{
        Public String product{get; set;}
        Public List<String> mnthList{get; set;}
        Public List<Integer> cntList{get; set;}
        Public Boolean groupIt{get; set;}
        Public Boolean Center{get; set;}

        public WrapperClass(String prd, List<Integer> cntList, List<String> mnthList)
        {
            product = prd;
            this.mnthList = mnthList;
            this.cntList = cntList;
        }
        public WrapperClass(String prd, Boolean groupIt, Boolean Center)
        {
            product = prd;
            this.groupIt = groupIt;
            this.Center = Center;
        }
        public WrapperClass(String prd, List<Integer> cntList, List<String> mnthList, Boolean groupIt)
        {
            product = prd;
            this.mnthList = mnthList;
            this.cntList = cntList;
			this.groupIt = groupIt;
        }
    }
}