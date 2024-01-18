trigger OrderEventTrigger on Order_Event__e (after insert) {
    //to create the list of tasks
    List<Task> tasks = new List<Task>();
    
    for(Order_Event__e orderEvent : Trigger.New){
        if(orderEvent.Has_Shipped__c){
            Task newTask = new Task();
            newTask.Priority = 'Medium';
            newTask.Subject='Follow up on shipped order ' + orderEvent.Order_Number__c;
            newTask.OwnerId = orderEvent.CreatedById;
            tasks.add(newTask);
        }
    }
     Insert tasks;
}