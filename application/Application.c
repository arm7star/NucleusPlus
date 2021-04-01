/* --------------------------------------------------
 * include
 * -------------------------------------------------- */
#include  "nucleus.h"

/* Application Structures */
NU_TASK         Task_0;
NU_TASK         Task_1;
NU_TASK         Task_2;
NU_TASK         Task_3_and_4;
NU_TASK         Task_5;

NU_MEMORY_POOL  System_Memory;
NU_MAILBOX		Mailbox;
NU_SEMAPHORE 	Semaphore_0;
NU_EVENT_GROUP 	Event_Group_0;


/* Function Prototypes */
VOID    task_0(UNSIGNED argc, VOID *argv);
VOID    task_1(UNSIGNED argc, VOID *argv);
VOID 	task_2(UNSIGNED argc,VOID *argv);
VOID 	task3_and_4(UNSIGNED argc,VOID *argv);
VOID 	task_5(UNSIGNED argc,VOID *argv);


/* --------------------------------------------------
 * void Application_Initialize(...)
 * -------------------------------------------------- */
void Application_Initialize(void *first_available_memory)
{
	VOID	*pointer;
	STATUS	status;
	
    /* Create a system memory pool that will be used to allocate task stacks,
       queue areas, etc.  */
    status = NU_Create_Memory_Pool(&System_Memory, "SYSMEM",
                        first_available_memory, 4000, 50, NU_FIFO);
    if(status != NU_SUCCESS) {
        ERC_System_Error(status);
    } else {
        printf("System_Memory have been cteated!\r\n");
    }

    /* Create each task in the system. */
	/* Create task_0 */
    NU_Allocate_Memory(&System_Memory, &pointer, 512, NU_NO_SUSPEND);
    status=NU_Create_Task(&Task_0, "TASK 0", task_0, 0, NU_NULL, pointer,
                                      512, 3, 20, NU_PREEMPT, NU_START);
    if(status != NU_SUCCESS) {
    	ERC_System_Error(status);
    } else {
        printf("task_0 have been created\r\n");
    }

    /* Create task_1 */
    NU_Allocate_Memory(&System_Memory, &pointer, 512, NU_NO_SUSPEND);
    status=NU_Create_Task(&Task_1, "TASK 1", task_1, 0, NU_NULL, pointer,
                                      512, 3, 20, NU_PREEMPT, NU_START);
    if(status != NU_SUCCESS) {
    	ERC_System_Error(status);
    } else {
        printf("task_1 have been created\r\n");
    }
	
    /* Create task_2*/
    NU_Allocate_Memory(&System_Memory, &pointer, 512, NU_NO_SUSPEND);
    status=NU_Create_Task(&Task_2, "TASK 2", task_2, 0, NU_NULL, pointer,
                                      512, 3, 15, NU_PREEMPT, NU_START);
    if (status != NU_SUCCESS) {    	
    	ERC_System_Error(status);
    } else {
        printf("task_2 have been created\r\n");
    }

    /* Create task_3_and_4 */
    NU_Allocate_Memory(&System_Memory, &pointer, 512, NU_NO_SUSPEND);
    status=NU_Create_Task(&Task_3_and_4, "TASK 3 and 4", task3_and_4, 0, NU_NULL, pointer,
                                      512, 3, 15, NU_PREEMPT, NU_START);
    if (status != NU_SUCCESS) { 	
    	ERC_System_Error(status);
    }
    else {
        printf("task_3_and_4 have been created\r\n");
    }
	
    /* Create task_5 */
    NU_Allocate_Memory(&System_Memory, &pointer, 512, NU_NO_SUSPEND);
    status=NU_Create_Task(&Task_5, "TASK 5", task_5, 0, NU_NULL, pointer,
                                      512, 3, 15, NU_PREEMPT, NU_START);
    if (status != NU_SUCCESS) {	
    	ERC_System_Error(status);
    } else {
        printf("task_5 have been created\r\n");
    }

   	/* Create a Mailbox */
    status=NU_Create_Mailbox(&Mailbox,"MAILBOX",NU_FIFO);
    if (status != NU_SUCCESS) {  	
    	ERC_System_Error(status);
    }
	
	/* Create a Semaphore */
	status=NU_Create_Semaphore(&Semaphore_0,"SEM_0",1,NU_FIFO);
    if (status != NU_SUCCESS) {  	
    	ERC_System_Error(status);
    }

	/* Create a Event Group */
	status=NU_Create_Event_Group(&Event_Group_0,"EVGROUP0");
    if (status != NU_SUCCESS) {  	
    	ERC_System_Error(status);
    }
}


/* Define the system timer task.  More complicated systems might use a
   routine like this to perform periodic message sending and other time
   oriented functions.  */


/* --------------------------------------------------
 * VOID task_0(UNSIGNED argc, VOID *argv)
 * -------------------------------------------------- */
VOID task_0(UNSIGNED argc, VOID *argv)
{
	STATUS  status;
	UNSIGNED	Smessage[4]={11110000,11112222,33334444,55556666,};
	status =  (STATUS) argc + (STATUS) argv;
	printf("------- task_0 start--------------\r\n");
	while(1)
	{
		status=NU_Send_To_Mailbox(&Mailbox,&Smessage[0],25);
		if(status==NU_SUCCESS)
			printf("SMail\r\n");
		else
			printf("send mailbox error!\r\n");

		NU_Sleep(40);
	}
}	


/* --------------------------------------------------
 * VOID task_1(UNSIGNED argc, VOID *argv)
 * -------------------------------------------------- */
VOID task_1(UNSIGNED argc, VOID *argv)
{
	STATUS  status;
	int     j;
	UNSIGNED Dmessage[4];
    status =  (STATUS) argc + (STATUS) argv;
	printf("------- task_1 start--------------\r\n");
	while(1)
	{		
		status=NU_Receive_From_Mailbox(&Mailbox,&Dmessage[0],20);
		if(status==NU_SUCCESS)
		{
			for(j=0;j<4;j++)
			printf("DMail is %d\r\n",Dmessage[j]);
		} 
		else
			printf("receive mailbox error!\r\n");

        NU_Sleep(20);
	}
}	


/* --------------------------------------------------
 * VOID task_2(UNSIGNED argc, VOID *argv)
 * -------------------------------------------------- */
VOID task_2(UNSIGNED argc, VOID *argv)
{
	STATUS  status;
	status =  (STATUS) argc + (STATUS) argv;
	printf("------- task_2 start--------------\r\n");
	while(1)
	{
		NU_Sleep(80);
		printf("NU_Set_Events\r\n");
		NU_Set_Events(&Event_Group_0,1,NU_OR);
	}
}


/* --------------------------------------------------
 * VOID task3_and_4(UNSIGNED argc, VOID *argv)
 * -------------------------------------------------- */
VOID task3_and_4(UNSIGNED argc, VOID *argv)
{
	STATUS  status;
	status =  (STATUS) argc + (STATUS) argv;
	printf("------- task3_and_4 start --------------\r\n");
	while(1)
	{
		status = NU_Obtain_Semaphore(&Semaphore_0, NU_SUSPEND);
		if(status == NU_SUCCESS)
		{
			NU_Sleep(10);
			printf("NU_Obtain_Semaphore NU_SUCCESS\r\n");
			NU_Release_Semaphore(&Semaphore_0);
		}
	}
}


/* --------------------------------------------------
 * VOID task_5(UNSIGNED argc, VOID *argv)
 * -------------------------------------------------- */
VOID task_5(UNSIGNED argc, VOID *argv)
{
	STATUS  status;
	UNSIGNED event_group;
	status =  (STATUS) argc + (STATUS) argv;
	printf("------- task_5 start --------------\r\n");
	while(1)
	{
		NU_Sleep(50);
		status = NU_Retrieve_Events(&Event_Group_0,1,NU_OR_CONSUME,&event_group,NU_SUSPEND);
		if(status == NU_SUCCESS)
		{
			printf("NU_Retrieve_Events NU_SUCCESS\r\n");
		}
	}
}

