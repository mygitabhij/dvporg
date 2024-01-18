public class contactPaginationController{
    
    //variable used in page.
    Public String size{get;set;}
    Public Integer noOfRecords{get; set;}
    Public List<System.SelectOption> pageSizeList{get;set;}
    public List<SelectOption> paginationSizeOptions{get;set;}
    public static final Integer QUERY_LIMIT = 10000;
    public static final Integer PAGE_SIZE = 5;
    
    public List <WrapperClass> wrapperRecordList{get;set;}
    Map<Id, WrapperClass> mapHoldingSelectedRecords{get;set;}
    
    //constructor calling init method.
    public contactPaginationController(){
        mapHoldingSelectedRecords = new Map<Id, WrapperClass>();
        init();
        pageSizeList = new List<System.SelectOption>();
        pageSizeList.add(new System.SelectOption('5','5'));
        pageSizeList.add(new System.SelectOption('10','10'));
        pageSizeList.add(new System.SelectOption('20','20'));
        pageSizeList.add(new System.SelectOption('50','50'));
        
    }
    
    //Init method which queries the records from standard set controller.
    public void init() {
        wrapperRecordList = new List<WrapperClass>();
        //setCon.setPageNumber(size);
        for (Contact cont : (List<Contact>)setCon.getRecords()) {
            if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(cont.id)){
                wrapperRecordList.add(mapHoldingSelectedRecords.get(cont.id));
                
            }
            else{
                wrapperRecordList.add(new WrapperClass(cont, false));
            }
        }
    }
    
    /** Instantiate the StandardSetController from a query locater*/
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Name, Email, Phone FROM Contact LIMIT : QUERY_LIMIT ]));
                
                // sets the number of records to show in each page view
                setCon.setPageSize(PAGE_SIZE);
            }
            return setCon;
        }
        set;
    }
    
    /** indicates whether there are more records after the current page set.*/
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    /** indicates whether there are more records before the current page set.*/
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    /** returns the page number of the current page set*/
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    /** return total number of pages for page set*/
    Public Integer getTotalPages(){
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize/pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    /** returns the first page of the page set*/
    public void first() {
        updateSearchItemsMap();
        setCon.first();
        init();
    }
    
    /** returns the last page of the page set*/
    public void last() {
        updateSearchItemsMap();
        setCon.last();
        init();
    }
    
    /** returns the previous page of the page set*/
    public void previous() {
        updateSearchItemsMap();
        setCon.previous();
        init();
    }
    
    /** returns the next page of the page set*/
    public void next() {
        updateSearchItemsMap();
        setCon.next();
        init();
    }
    
    /** page size selection**/
    public void getchangePageSize() {
        Integer pagesize;
        if(size == '5'){
            pagesize=5;
        }else if(size == '10'){
            pagesize=10;
        }else if(size == '20'){
            pagesize=20;
        }else If(size == '50'){
            pagesize=50;
        }else{
            pagesize=PAGE_SIZE;
        }
        setCon.setPageSize(pagesize);
        init();
    }
    //This is the method which manages to remove the deselected records, and keep the records which are selected in map.
    private void updateSearchItemsMap() {
        for(WrapperClass wrp : wrapperRecordList){
            if(wrp.isSelected){
                mapHoldingSelectedRecords.put(wrp.contactRecord.id, wrp);
            }
            if(wrp.isSelected == false && mapHoldingSelectedRecords.containsKey(wrp.contactRecord.id)){
                mapHoldingSelectedRecords.remove(wrp.contactRecord.id);
            }
        }
    }
    
    //wrapper class being used for checkbox showing.
    public class WrapperClass {
        public Boolean isSelected {get;set;}
        public Contact contactRecord {get;set;}
        public WrapperClass(Contact contactRecord, Boolean isSelected) {
            this.contactRecord = contactRecord;
            this.isSelected = isSelected;
        }
    }
    
}