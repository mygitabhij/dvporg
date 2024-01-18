public with sharing class DLWC_DynamicSearchController {
    /**************************************************************************************************************************************\
    @ Description   Controller for DLWC_DynamicSearchComponent Component. This class is used to 
    retrieve Object date from Salesforce, handles search logic
    @ Author: Karthi Gurusamy           
    @ Date :  08-Jan-2019       
    @ Test Class: DLWC_DynamicSearchControllerTest
    /************************************************************************************************************************************
    * ModificationLog     Developer            CodeReview          Date                   Description  
    1.0            		Karthi Gurusamy       Sumit Mishra      108-Jan-2019       Created apex class for DLWC_DynamicSearchComponent
	*************************************************************************************************************************************/

    @AuraEnabled(cacheable=true)
    public static SearchPagerWrapper fetchrecords(Decimal pageNumber ,Integer recordToDisply,String searchtext,String searchname) {
        /**********************************************************************************************************************************
        * @description : This method is returns available object records with pagination,
        * 				 invoked from lightning component (DLWC_DynamicSearchComponent)
        * @param       : Pagenumber - Current page Number
        * @param       : recordToDisply - records per page selected
        * @param       : searchtext - search text(NUll on init)
        * @param       : searchname - Custom metadata record name for configuration
        * @return type : SearchPagerWrapper
        **********************************************************************************************************************************/
        try{
            Integer offset = ((Integer)pageNumber - 1) * recordToDisply; //calculate offset
            String query='';
            String searchQuery='';
            // create a instance of wrapper class.
            SearchPagerWrapper obj =  new SearchPagerWrapper();
            // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
            obj.pageSize = recordToDisply;
            obj.page = (Integer) pageNumber;
            List<String> displayColumns= new List<String>();
            List<String> searchColumns= new List<String>();
            String objName='';
            List<String> pageSizeList=new List<String>();
            String filterCriteria='';
            
            if(searchname==null||searchname==''){
                AuraHandledException ex = new AuraHandledException(Label.DLWC_Attribute_Error);
                ex.setMessage(Label.DLWC_Attribute_Error);
                throw ex;
            }

            //get all custom metadata value
            for(DLWC_Dynamic_Search_Configuration__mdt mdt:[Select DeveloperName,Display_Fields__c,Filter_Criteria__c,Object_Name__c,Page_Size_Options__c,Search_Fields__c from DLWC_Dynamic_Search_Configuration__mdt where DeveloperName=:searchname]){
                if(mdt.Display_Fields__c==null || mdt.Search_Fields__c==null || mdt.Object_Name__c==null){
                    AuraHandledException ex = new AuraHandledException(Label.DLWC_Metadata_Error);
                    ex.setMessage(Label.DLWC_Metadata_Error);
                    throw ex;
                }
                displayColumns=mdt.Display_Fields__c.split(','); //get fields to be displayed as csv
                searchColumns=mdt.Search_Fields__c.split(','); //get fields to be searched as csv
                objName=mdt.Object_Name__c; //get object name
                pageSizeList=mdt.Page_Size_Options__c.split(','); //get page size options as csv
                if(mdt.Filter_Criteria__c!=null){
                    filterCriteria=mdt.Filter_Criteria__c;
                }
            }
            
            //get field schema of the object
            Map<String, Schema.SObjectField> fieldMap1=Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            List<ColumnWrapper> columnList= new List<ColumnWrapper>();
            Map<String,String> relationMap= new Map<String,String>();
            List<String> columnFieldList =new List<String>();
            Schema.DescribeFieldResult nameField;
            //find the name field of the searched obejct
            for(String s:fieldMap1.keyset()){                
                if(fieldMap1.get(s).getDescribe().isNameField())
                    nameField=fieldMap1.get(s).getDescribe();
            }
            //count query to get number of available records
            String countQuery='Select count() from '+objName;
            
            // analyze and segregate the fields like relationship,Name,Id fields
            for(String s:displayColumns){
                Schema.DescribeFieldResult fieldDetails;
                // get field details of the relationship fields
                if(s.contains('.') && relationMap!=null && !relationMap.values().contains(s)&& !s.equalsIgnoreCase('recordtype.name')){                    
                    if(Schema.getGlobalDescribe().get(s.split('\\.')[0])!=null){
                        Map<String, Schema.SObjectField> fieldMap=Schema.getGlobalDescribe().get(s.split('\\.')[0]).getDescribe().fields.getMap();
                    	fieldDetails=fieldMap.get(s.split('\\.')[1]).getDescribe();
                    }
                    // throw exception on invalid fields
                    else{
                        AuraHandledException ex = new AuraHandledException(Label.DLWC_Field_Error+s);
                        ex.setMessage(Label.DLWC_Field_Error+s);
                        throw ex;
                    }
                }
                //handle record type field
                else if(s.equalsIgnoreCase('recordtypeId')|| s.equalsIgnoreCase('recordtype.name')){
                    if(!s.equalsIgnoreCase('recordtype.name')){
                    	columnFieldList.add(s); 
                    }
                    relationMap.put('RecordTypeId','RecordType.Name');
                    columnList.add(new ColumnWrapper('Record Type','RecordTypeIdName','text',null));
                                       
                    continue;
                }
                // get field details
                else if(relationMap!=null && !relationMap.values().contains(s)){
                    if(fieldMap1.get(s)!=null){
                        fieldDetails=fieldMap1.get(s).getDescribe();
                    }
                    // throw exception on invalid fields
                    else{
                        AuraHandledException ex = new AuraHandledException(Label.DLWC_Field_Error+s);
                        ex.setMessage(Label.DLWC_Field_Error+s);
                        throw ex;
                    }
                    
                }
                else{
                    continue;
                }
                
                if(!columnFieldList.contains(s)){
                    columnFieldList.add(s);
                }
                
                // set the column details of the lightning:datatable 
                string type=String.valueof(fieldDetails.getType()).tolowercase();
                String label=s.contains('.')?s.split('\\.')[0]+' '+fieldDetails.getLabel():fieldDetails.getLabel();
                //Id field as link with Name as label
                if(s.equalsIgnoreCase('Id')){
                    relationMap.put(fieldDetails.getName(),nameField.getName());
                    columnList.add(new ColumnWrapper(nameField.getLabel(),'Id','url',new TypeAttributes(nameField.getName())));
                }
                // Name field as link
                else if(fielddetails.isNameField()){
                    relationMap.put(fieldDetails.getName(),'Id');
                    columnList.add(new ColumnWrapper(label,'Id','url',new TypeAttributes(s)));
                }
                //relationship fields as links
                else if(type=='reference'){
                    relationMap.put(fieldDetails.getName(),fieldDetails.getRelationshipName()+'.Name');
                    columnList.add(new ColumnWrapper(label.replace(' ID', ' Name'),fieldDetails.getName()+'Id','url',new TypeAttributes(fieldDetails.getName()+'Name')));
                }
                // undefined fields as text fields
                else if(type!='boolean' && type!='percent' && type!='date' && type!='datetime' && type!='phone' && type!='email' && type!='number'){
                    type='text';
                    columnList.add(new ColumnWrapper(label,fieldDetails.getName(),type,null));
                }
                else{
                    columnList.add(new ColumnWrapper(fieldDetails.getLabel(),fieldDetails.getName(),type,null));
                }
            }
            //form query with all fields and relationship object fields
            if(relationMap.size()>0){
                query='Select '+String.join(columnFieldList,',')+','+String.join(relationMap.values(),',')+' from '+objName;
            }
            else{
                query='Select '+String.join(columnFieldList,',')+' from '+objName;
            }
            //add search conditions to the query
            if(searchtext!=null && searchtext!=''){
                searchQuery=filterCriteria==''?' where':' where (';
                for(String s:searchColumns){
                    if(!s.containsIgnoreCase('Id')){
                        searchQuery=searchQuery+' '+s+' like \'%'+searchtext+'%\' OR';
                    }
                    else{
                        searchQuery=searchQuery+' '+relationMap.get(s)+' like \'%'+searchtext+'%\' OR';
                    }
                }
                searchQuery=searchQuery.removeEnd('OR');
                // add filter criteria from custom metadata
                if(filterCriteria!=''){
                    searchQuery=searchQuery+') AND '+filterCriteria;
                }
            }
            else if(filterCriteria!=''){
                searchQuery=' where '+filterCriteria;
            }
            query=searchQuery!=''?query+searchQuery:query;
            countQuery=searchQuery!=''?countQuery+searchQuery:countQuery;
            query=query+' LIMIT '+recordToDisply+' OFFSET '+offset; // add limit and offset for pagination
            system.debug(query);
            system.debug(columnList);

            //assign to the wrapper to return
            obj.total = Database.countQuery(countQuery);
            obj.objectsList = Database.query(query);
            obj.columnList=columnList;
            obj.relFieldsMap=relationMap;
            obj.relFieldsSet=relationMap.keyset();
            obj.pageSizeList=pageSizeList;
            // return the wrapper class instance .
            return obj;
        } 
        // handle thrown exceptions
        catch(AuraHandledException e){            
            throw new AuraHandledException(e.getMessage());
        }
        catch(Exception e){
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
            system.debug(e.getStackTraceString());
            //throw new AuraHandledException(e.getMessage());
            return null;
        }
    }
    
    
    // create a wrapper class with @AuraEnabled Properties  to return to component
    public class SearchPagerWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<sObject> objectsList {get;set;}
        @AuraEnabled public List<ColumnWrapper> columnList {get;set;}
        @AuraEnabled public Map<String,String> relFieldsMap {get;set;}
        @AuraEnabled public Set<String> relFieldsSet {get;set;}
        @AuraEnabled public List<String> pageSizeList {get;set;}
    }

    //wrapper to match lightning:datatable columns parameter
    public class ColumnWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public TypeAttributes typeAttributes {get;set;}
        
        public ColumnWrapper(String label,String fieldName,String type,TypeAttributes typeAttributes){
            this.label=label;
            this.fieldName=fieldName;
            this.type=type;
            if(typeAttributes!=null){
                this.typeAttributes=typeAttributes;
            }
        }
    }
    // TypeAttribute for URL field type
    public class TypeAttributes{
        @AuraEnabled public AttributeLabel label {get;set;}
        @AuraEnabled public String target {get;set;}
        public TypeAttributes(String label){
            this.label=new AttributeLabel(label);
            this.target='_blank';
        }
    }
    public class AttributeLabel{
        @AuraEnabled public String fieldName {get;set;}
        public AttributeLabel(String label){
            this.fieldName=label;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactList() {
        return [SELECT Id, FirstName, LastName, Title, Phone, Email FROM Contact LIMIT 10];
    }
}