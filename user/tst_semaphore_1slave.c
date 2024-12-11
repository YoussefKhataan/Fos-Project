// Test the use of semaphores for critical section & dependency
// Slave program: enter critical section, print it's ID, exit and signal the master program
#include <inc/lib.h>

void
_main(void)
{

	int32 parentenvID = sys_getparentenvid();
	cprintf("10\n");
	int id = sys_getenvindex();
	cprintf("12\n");
	struct semaphore cs1 = get_semaphore(parentenvID, "cs1");
	cprintf("14\n");
	struct semaphore depend1 = get_semaphore(parentenvID, "depend1");
	cprintf("16\n");
	cprintf("%d: before the critical section\n", id);
	cprintf("18\n");
	wait_semaphore(cs1);
	{
		cprintf("21\n");
		cprintf("%d: inside the critical section\n", id) ;
		cprintf("my ID is %d\n", id);
		int sem1val = semaphore_count(cs1);
		if (sem1val > 0)
			panic("Error: more than 1 process inside the CS... please review your semaphore code again...");
		env_sleep(1000) ;
	}
	signal_semaphore(cs1);
	cprintf("%d: after the critical section\n", id);

	signal_semaphore(depend1);
	return;
}
