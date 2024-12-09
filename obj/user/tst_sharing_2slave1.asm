
obj/user/tst_sharing_2slave1:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	mov $0, %eax
  800020:	b8 00 00 00 00       	mov    $0x0,%eax
	cmpl $USTACKTOP, %esp
  800025:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  80002b:	75 04                	jne    800031 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  80002d:	6a 00                	push   $0x0
	pushl $0
  80002f:	6a 00                	push   $0x0

00800031 <args_exist>:

args_exist:
	call libmain
  800031:	e8 7c 02 00 00       	call   8002b2 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
// Slave program1: Read the 2 shared variables, edit the 3rd one, and exit
#include <inc/lib.h>

void
_main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	53                   	push   %ebx
  80003c:	83 ec 34             	sub    $0x34,%esp
	/*=================================================*/
	//Initial test to ensure it works on "PLACEMENT" not "REPLACEMENT"
#if USE_KHEAP
	{
		if (LIST_SIZE(&(myEnv->page_WS_list)) >= myEnv->page_WS_max_size)
  80003f:	a1 20 50 80 00       	mov    0x805020,%eax
  800044:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
  80004a:	a1 20 50 80 00       	mov    0x805020,%eax
  80004f:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
  800055:	39 c2                	cmp    %eax,%edx
  800057:	72 14                	jb     80006d <_main+0x35>
			panic("Please increase the WS size");
  800059:	83 ec 04             	sub    $0x4,%esp
  80005c:	68 20 3d 80 00       	push   $0x803d20
  800061:	6a 0d                	push   $0xd
  800063:	68 3c 3d 80 00       	push   $0x803d3c
  800068:	e8 84 03 00 00       	call   8003f1 <_panic>
#else
	panic("make sure to enable the kernel heap: USE_KHEAP=1");
#endif
	/*=================================================*/

	uint32 pagealloc_start = USER_HEAP_START + DYN_ALLOC_MAX_SIZE + PAGE_SIZE; //UHS + 32MB + 4KB
  80006d:	c7 45 f4 00 10 00 82 	movl   $0x82001000,-0xc(%ebp)

	uint32 *x,*y,*z, *expectedVA;
	int freeFrames, diff, expected;
	int32 parentenvID = sys_getparentenvid();
  800074:	e8 04 1c 00 00       	call   801c7d <sys_getparentenvid>
  800079:	89 45 f0             	mov    %eax,-0x10(%ebp)
	//GET: z then y then x, opposite to creation order (x then y then z)
	//So, addresses here will be different from the OWNER addresses
	//sys_lock_cons();
	sys_lock_cons();
  80007c:	e8 67 19 00 00       	call   8019e8 <sys_lock_cons>
	{
		freeFrames = sys_calculate_free_frames() ;
  800081:	e8 15 1a 00 00       	call   801a9b <sys_calculate_free_frames>
  800086:	89 45 ec             	mov    %eax,-0x14(%ebp)
		z = sget(parentenvID,"z");
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	68 57 3d 80 00       	push   $0x803d57
  800091:	ff 75 f0             	pushl  -0x10(%ebp)
  800094:	e8 88 17 00 00       	call   801821 <sget>
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		expectedVA = (uint32*)(pagealloc_start + 0 * PAGE_SIZE);
  80009f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (z != expectedVA) panic("Get(): Returned address is not correct. Expected = %x, Actual = %x\nMake sure that you align the allocation on 4KB boundary", expectedVA, z);
  8000a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000a8:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8000ab:	74 1a                	je     8000c7 <_main+0x8f>
  8000ad:	83 ec 0c             	sub    $0xc,%esp
  8000b0:	ff 75 e8             	pushl  -0x18(%ebp)
  8000b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000b6:	68 5c 3d 80 00       	push   $0x803d5c
  8000bb:	6a 21                	push   $0x21
  8000bd:	68 3c 3d 80 00       	push   $0x803d3c
  8000c2:	e8 2a 03 00 00       	call   8003f1 <_panic>
		expected = 1 ; /*1table*/
  8000c7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
		diff = (freeFrames - sys_calculate_free_frames());
  8000ce:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8000d1:	e8 c5 19 00 00       	call   801a9b <sys_calculate_free_frames>
  8000d6:	29 c3                	sub    %eax,%ebx
  8000d8:	89 d8                	mov    %ebx,%eax
  8000da:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if (diff != expected) panic("Wrong allocation (current=%d, expected=%d): make sure that you allocate the required space in the user environment and add its frames to frames_storage", freeFrames - sys_calculate_free_frames(), expected);
  8000dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8000e0:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8000e3:	74 24                	je     800109 <_main+0xd1>
  8000e5:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  8000e8:	e8 ae 19 00 00       	call   801a9b <sys_calculate_free_frames>
  8000ed:	29 c3                	sub    %eax,%ebx
  8000ef:	89 d8                	mov    %ebx,%eax
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8000f7:	50                   	push   %eax
  8000f8:	68 d8 3d 80 00       	push   $0x803dd8
  8000fd:	6a 24                	push   $0x24
  8000ff:	68 3c 3d 80 00       	push   $0x803d3c
  800104:	e8 e8 02 00 00       	call   8003f1 <_panic>

	}
	sys_unlock_cons();
  800109:	e8 f4 18 00 00       	call   801a02 <sys_unlock_cons>
	//sys_unlock_cons();

	//sys_lock_cons();
	sys_lock_cons();
  80010e:	e8 d5 18 00 00       	call   8019e8 <sys_lock_cons>
	{
		freeFrames = sys_calculate_free_frames() ;
  800113:	e8 83 19 00 00       	call   801a9b <sys_calculate_free_frames>
  800118:	89 45 ec             	mov    %eax,-0x14(%ebp)
		y = sget(parentenvID,"y");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 70 3e 80 00       	push   $0x803e70
  800123:	ff 75 f0             	pushl  -0x10(%ebp)
  800126:	e8 f6 16 00 00       	call   801821 <sget>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		expectedVA = (uint32*)(pagealloc_start + 1 * PAGE_SIZE);
  800131:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800134:	05 00 10 00 00       	add    $0x1000,%eax
  800139:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (y != expectedVA) panic("Get(): Returned address is not correct. Expected = %x, Actual = %x\nMake sure that you align the allocation on 4KB boundary", expectedVA, y);
  80013c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80013f:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  800142:	74 1a                	je     80015e <_main+0x126>
  800144:	83 ec 0c             	sub    $0xc,%esp
  800147:	ff 75 d8             	pushl  -0x28(%ebp)
  80014a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80014d:	68 5c 3d 80 00       	push   $0x803d5c
  800152:	6a 30                	push   $0x30
  800154:	68 3c 3d 80 00       	push   $0x803d3c
  800159:	e8 93 02 00 00       	call   8003f1 <_panic>
		expected = 0 ;
  80015e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		diff = (freeFrames - sys_calculate_free_frames());
  800165:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800168:	e8 2e 19 00 00       	call   801a9b <sys_calculate_free_frames>
  80016d:	29 c3                	sub    %eax,%ebx
  80016f:	89 d8                	mov    %ebx,%eax
  800171:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if (diff != expected) panic("Wrong allocation (current=%d, expected=%d): make sure that you allocate the required space in the user environment and add its frames to frames_storage", freeFrames - sys_calculate_free_frames(), expected);
  800174:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800177:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80017a:	74 24                	je     8001a0 <_main+0x168>
  80017c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80017f:	e8 17 19 00 00       	call   801a9b <sys_calculate_free_frames>
  800184:	29 c3                	sub    %eax,%ebx
  800186:	89 d8                	mov    %ebx,%eax
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	ff 75 e0             	pushl  -0x20(%ebp)
  80018e:	50                   	push   %eax
  80018f:	68 d8 3d 80 00       	push   $0x803dd8
  800194:	6a 33                	push   $0x33
  800196:	68 3c 3d 80 00       	push   $0x803d3c
  80019b:	e8 51 02 00 00       	call   8003f1 <_panic>
	}
	sys_unlock_cons();
  8001a0:	e8 5d 18 00 00       	call   801a02 <sys_unlock_cons>
	//sys_unlock_cons();
	if (*y != 20) panic("Get(): Shared Variable is not created or got correctly") ;
  8001a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001a8:	8b 00                	mov    (%eax),%eax
  8001aa:	83 f8 14             	cmp    $0x14,%eax
  8001ad:	74 14                	je     8001c3 <_main+0x18b>
  8001af:	83 ec 04             	sub    $0x4,%esp
  8001b2:	68 74 3e 80 00       	push   $0x803e74
  8001b7:	6a 37                	push   $0x37
  8001b9:	68 3c 3d 80 00       	push   $0x803d3c
  8001be:	e8 2e 02 00 00       	call   8003f1 <_panic>
	//sys_lock_cons();
	sys_lock_cons();
  8001c3:	e8 20 18 00 00       	call   8019e8 <sys_lock_cons>
	{
		freeFrames = sys_calculate_free_frames() ;
  8001c8:	e8 ce 18 00 00       	call   801a9b <sys_calculate_free_frames>
  8001cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
		x = sget(parentenvID,"x");
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	68 ab 3e 80 00       	push   $0x803eab
  8001d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8001db:	e8 41 16 00 00       	call   801821 <sget>
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		expectedVA = (uint32*)(pagealloc_start + 2 * PAGE_SIZE);
  8001e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001e9:	05 00 20 00 00       	add    $0x2000,%eax
  8001ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (x != expectedVA) panic("Get(): Returned address is not correct. Expected = %x, Actual = %x\nMake sure that you align the allocation on 4KB boundary", expectedVA, x);
  8001f1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8001f4:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8001f7:	74 1a                	je     800213 <_main+0x1db>
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	68 5c 3d 80 00       	push   $0x803d5c
  800207:	6a 3e                	push   $0x3e
  800209:	68 3c 3d 80 00       	push   $0x803d3c
  80020e:	e8 de 01 00 00       	call   8003f1 <_panic>
		expected = 0 ;
  800213:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		diff = (freeFrames - sys_calculate_free_frames());
  80021a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  80021d:	e8 79 18 00 00       	call   801a9b <sys_calculate_free_frames>
  800222:	29 c3                	sub    %eax,%ebx
  800224:	89 d8                	mov    %ebx,%eax
  800226:	89 45 dc             	mov    %eax,-0x24(%ebp)
		if (diff != expected) panic("Wrong allocation (current=%d, expected=%d): make sure that you allocate the required space in the user environment and add its frames to frames_storage", freeFrames - sys_calculate_free_frames(), expected);
  800229:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80022c:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80022f:	74 24                	je     800255 <_main+0x21d>
  800231:	8b 5d ec             	mov    -0x14(%ebp),%ebx
  800234:	e8 62 18 00 00       	call   801a9b <sys_calculate_free_frames>
  800239:	29 c3                	sub    %eax,%ebx
  80023b:	89 d8                	mov    %ebx,%eax
  80023d:	83 ec 0c             	sub    $0xc,%esp
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	50                   	push   %eax
  800244:	68 d8 3d 80 00       	push   $0x803dd8
  800249:	6a 41                	push   $0x41
  80024b:	68 3c 3d 80 00       	push   $0x803d3c
  800250:	e8 9c 01 00 00       	call   8003f1 <_panic>
	}
	sys_unlock_cons();
  800255:	e8 a8 17 00 00       	call   801a02 <sys_unlock_cons>
	//sys_unlock_cons();
	if (*x != 10) panic("Get(): Shared Variable is not created or got correctly") ;
  80025a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80025d:	8b 00                	mov    (%eax),%eax
  80025f:	83 f8 0a             	cmp    $0xa,%eax
  800262:	74 14                	je     800278 <_main+0x240>
  800264:	83 ec 04             	sub    $0x4,%esp
  800267:	68 74 3e 80 00       	push   $0x803e74
  80026c:	6a 45                	push   $0x45
  80026e:	68 3c 3d 80 00       	push   $0x803d3c
  800273:	e8 79 01 00 00       	call   8003f1 <_panic>

	*z = *x + *y ;
  800278:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800280:	8b 00                	mov    (%eax),%eax
  800282:	01 c2                	add    %eax,%edx
  800284:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800287:	89 10                	mov    %edx,(%eax)
	if (*z != 30) panic("Get(): Shared Variable is not created or got correctly") ;
  800289:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80028c:	8b 00                	mov    (%eax),%eax
  80028e:	83 f8 1e             	cmp    $0x1e,%eax
  800291:	74 14                	je     8002a7 <_main+0x26f>
  800293:	83 ec 04             	sub    $0x4,%esp
  800296:	68 74 3e 80 00       	push   $0x803e74
  80029b:	6a 48                	push   $0x48
  80029d:	68 3c 3d 80 00       	push   $0x803d3c
  8002a2:	e8 4a 01 00 00       	call   8003f1 <_panic>

	//To indicate that it's completed successfully
	inctst();
  8002a7:	e8 f6 1a 00 00       	call   801da2 <inctst>

	return;
  8002ac:	90                   	nop
}
  8002ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b0:	c9                   	leave  
  8002b1:	c3                   	ret    

008002b2 <libmain>:

volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";
void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  8002b8:	e8 a7 19 00 00       	call   801c64 <sys_getenvindex>
  8002bd:	89 45 f4             	mov    %eax,-0xc(%ebp)

	myEnv = &(envs[envIndex]);
  8002c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8002c3:	89 d0                	mov    %edx,%eax
  8002c5:	c1 e0 03             	shl    $0x3,%eax
  8002c8:	01 d0                	add    %edx,%eax
  8002ca:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  8002d1:	01 c8                	add    %ecx,%eax
  8002d3:	01 c0                	add    %eax,%eax
  8002d5:	01 d0                	add    %edx,%eax
  8002d7:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  8002de:	01 c8                	add    %ecx,%eax
  8002e0:	01 d0                	add    %edx,%eax
  8002e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e7:	a3 20 50 80 00       	mov    %eax,0x805020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  8002ec:	a1 20 50 80 00       	mov    0x805020,%eax
  8002f1:	8a 40 20             	mov    0x20(%eax),%al
  8002f4:	84 c0                	test   %al,%al
  8002f6:	74 0d                	je     800305 <libmain+0x53>
		binaryname = myEnv->prog_name;
  8002f8:	a1 20 50 80 00       	mov    0x805020,%eax
  8002fd:	83 c0 20             	add    $0x20,%eax
  800300:	a3 00 50 80 00       	mov    %eax,0x805000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800305:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800309:	7e 0a                	jle    800315 <libmain+0x63>
		binaryname = argv[0];
  80030b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80030e:	8b 00                	mov    (%eax),%eax
  800310:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	_main(argc, argv);
  800315:	83 ec 08             	sub    $0x8,%esp
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 15 fd ff ff       	call   800038 <_main>
  800323:	83 c4 10             	add    $0x10,%esp



	//	sys_lock_cons();
	sys_lock_cons();
  800326:	e8 bd 16 00 00       	call   8019e8 <sys_lock_cons>
	{
		cprintf("**************************************\n");
  80032b:	83 ec 0c             	sub    $0xc,%esp
  80032e:	68 c8 3e 80 00       	push   $0x803ec8
  800333:	e8 76 03 00 00       	call   8006ae <cprintf>
  800338:	83 c4 10             	add    $0x10,%esp
		cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  80033b:	a1 20 50 80 00       	mov    0x805020,%eax
  800340:	8b 90 a0 05 00 00    	mov    0x5a0(%eax),%edx
  800346:	a1 20 50 80 00       	mov    0x805020,%eax
  80034b:	8b 80 90 05 00 00    	mov    0x590(%eax),%eax
  800351:	83 ec 04             	sub    $0x4,%esp
  800354:	52                   	push   %edx
  800355:	50                   	push   %eax
  800356:	68 f0 3e 80 00       	push   $0x803ef0
  80035b:	e8 4e 03 00 00       	call   8006ae <cprintf>
  800360:	83 c4 10             	add    $0x10,%esp
		cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  800363:	a1 20 50 80 00       	mov    0x805020,%eax
  800368:	8b 88 b4 05 00 00    	mov    0x5b4(%eax),%ecx
  80036e:	a1 20 50 80 00       	mov    0x805020,%eax
  800373:	8b 90 b0 05 00 00    	mov    0x5b0(%eax),%edx
  800379:	a1 20 50 80 00       	mov    0x805020,%eax
  80037e:	8b 80 ac 05 00 00    	mov    0x5ac(%eax),%eax
  800384:	51                   	push   %ecx
  800385:	52                   	push   %edx
  800386:	50                   	push   %eax
  800387:	68 18 3f 80 00       	push   $0x803f18
  80038c:	e8 1d 03 00 00       	call   8006ae <cprintf>
  800391:	83 c4 10             	add    $0x10,%esp
		//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
		cprintf("Num of clocks = %d\n", myEnv->nClocks);
  800394:	a1 20 50 80 00       	mov    0x805020,%eax
  800399:	8b 80 b8 05 00 00    	mov    0x5b8(%eax),%eax
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	50                   	push   %eax
  8003a3:	68 70 3f 80 00       	push   $0x803f70
  8003a8:	e8 01 03 00 00       	call   8006ae <cprintf>
  8003ad:	83 c4 10             	add    $0x10,%esp
		cprintf("**************************************\n");
  8003b0:	83 ec 0c             	sub    $0xc,%esp
  8003b3:	68 c8 3e 80 00       	push   $0x803ec8
  8003b8:	e8 f1 02 00 00       	call   8006ae <cprintf>
  8003bd:	83 c4 10             	add    $0x10,%esp
	}
	sys_unlock_cons();
  8003c0:	e8 3d 16 00 00       	call   801a02 <sys_unlock_cons>
//	sys_unlock_cons();

	// exit gracefully
	exit();
  8003c5:	e8 19 00 00 00       	call   8003e3 <exit>
}
  8003ca:	90                   	nop
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  8003d3:	83 ec 0c             	sub    $0xc,%esp
  8003d6:	6a 00                	push   $0x0
  8003d8:	e8 53 18 00 00       	call   801c30 <sys_destroy_env>
  8003dd:	83 c4 10             	add    $0x10,%esp
}
  8003e0:	90                   	nop
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <exit>:

void
exit(void)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  8003e9:	e8 a8 18 00 00       	call   801c96 <sys_exit_env>
}
  8003ee:	90                   	nop
  8003ef:	c9                   	leave  
  8003f0:	c3                   	ret    

008003f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  8003f7:	8d 45 10             	lea    0x10(%ebp),%eax
  8003fa:	83 c0 04             	add    $0x4,%eax
  8003fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  800400:	a1 4c 50 80 00       	mov    0x80504c,%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	74 16                	je     80041f <_panic+0x2e>
		cprintf("%s: ", argv0);
  800409:	a1 4c 50 80 00       	mov    0x80504c,%eax
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	50                   	push   %eax
  800412:	68 84 3f 80 00       	push   $0x803f84
  800417:	e8 92 02 00 00       	call   8006ae <cprintf>
  80041c:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80041f:	a1 00 50 80 00       	mov    0x805000,%eax
  800424:	ff 75 0c             	pushl  0xc(%ebp)
  800427:	ff 75 08             	pushl  0x8(%ebp)
  80042a:	50                   	push   %eax
  80042b:	68 89 3f 80 00       	push   $0x803f89
  800430:	e8 79 02 00 00       	call   8006ae <cprintf>
  800435:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  800438:	8b 45 10             	mov    0x10(%ebp),%eax
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	ff 75 f4             	pushl  -0xc(%ebp)
  800441:	50                   	push   %eax
  800442:	e8 fc 01 00 00       	call   800643 <vcprintf>
  800447:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 a5 3f 80 00       	push   $0x803fa5
  800454:	e8 ea 01 00 00       	call   800643 <vcprintf>
  800459:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  80045c:	e8 82 ff ff ff       	call   8003e3 <exit>

	// should not return here
	while (1) ;
  800461:	eb fe                	jmp    800461 <_panic+0x70>

00800463 <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  800469:	a1 20 50 80 00       	mov    0x805020,%eax
  80046e:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  800474:	8b 45 0c             	mov    0xc(%ebp),%eax
  800477:	39 c2                	cmp    %eax,%edx
  800479:	74 14                	je     80048f <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  80047b:	83 ec 04             	sub    $0x4,%esp
  80047e:	68 a8 3f 80 00       	push   $0x803fa8
  800483:	6a 26                	push   $0x26
  800485:	68 f4 3f 80 00       	push   $0x803ff4
  80048a:	e8 62 ff ff ff       	call   8003f1 <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  80048f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  800496:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80049d:	e9 c5 00 00 00       	jmp    800567 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8004a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004a5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8004ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8004af:	01 d0                	add    %edx,%eax
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	75 08                	jne    8004bf <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  8004b7:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  8004ba:	e9 a5 00 00 00       	jmp    800564 <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  8004bf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8004c6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  8004cd:	eb 69                	jmp    800538 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  8004cf:	a1 20 50 80 00       	mov    0x805020,%eax
  8004d4:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  8004da:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004dd:	89 d0                	mov    %edx,%eax
  8004df:	01 c0                	add    %eax,%eax
  8004e1:	01 d0                	add    %edx,%eax
  8004e3:	c1 e0 03             	shl    $0x3,%eax
  8004e6:	01 c8                	add    %ecx,%eax
  8004e8:	8a 40 04             	mov    0x4(%eax),%al
  8004eb:	84 c0                	test   %al,%al
  8004ed:	75 46                	jne    800535 <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  8004ef:	a1 20 50 80 00       	mov    0x805020,%eax
  8004f4:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  8004fa:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004fd:	89 d0                	mov    %edx,%eax
  8004ff:	01 c0                	add    %eax,%eax
  800501:	01 d0                	add    %edx,%eax
  800503:	c1 e0 03             	shl    $0x3,%eax
  800506:	01 c8                	add    %ecx,%eax
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80050d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800510:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800515:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  800517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80051a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800521:	8b 45 08             	mov    0x8(%ebp),%eax
  800524:	01 c8                	add    %ecx,%eax
  800526:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  800528:	39 c2                	cmp    %eax,%edx
  80052a:	75 09                	jne    800535 <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  80052c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  800533:	eb 15                	jmp    80054a <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  800535:	ff 45 e8             	incl   -0x18(%ebp)
  800538:	a1 20 50 80 00       	mov    0x805020,%eax
  80053d:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  800543:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800546:	39 c2                	cmp    %eax,%edx
  800548:	77 85                	ja     8004cf <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  80054a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80054e:	75 14                	jne    800564 <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  800550:	83 ec 04             	sub    $0x4,%esp
  800553:	68 00 40 80 00       	push   $0x804000
  800558:	6a 3a                	push   $0x3a
  80055a:	68 f4 3f 80 00       	push   $0x803ff4
  80055f:	e8 8d fe ff ff       	call   8003f1 <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  800564:	ff 45 f0             	incl   -0x10(%ebp)
  800567:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80056a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80056d:	0f 8c 2f ff ff ff    	jl     8004a2 <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  800573:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80057a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800581:	eb 26                	jmp    8005a9 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  800583:	a1 20 50 80 00       	mov    0x805020,%eax
  800588:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  80058e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800591:	89 d0                	mov    %edx,%eax
  800593:	01 c0                	add    %eax,%eax
  800595:	01 d0                	add    %edx,%eax
  800597:	c1 e0 03             	shl    $0x3,%eax
  80059a:	01 c8                	add    %ecx,%eax
  80059c:	8a 40 04             	mov    0x4(%eax),%al
  80059f:	3c 01                	cmp    $0x1,%al
  8005a1:	75 03                	jne    8005a6 <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8005a3:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8005a6:	ff 45 e0             	incl   -0x20(%ebp)
  8005a9:	a1 20 50 80 00       	mov    0x805020,%eax
  8005ae:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  8005b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b7:	39 c2                	cmp    %eax,%edx
  8005b9:	77 c8                	ja     800583 <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  8005bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8005be:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8005c1:	74 14                	je     8005d7 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  8005c3:	83 ec 04             	sub    $0x4,%esp
  8005c6:	68 54 40 80 00       	push   $0x804054
  8005cb:	6a 44                	push   $0x44
  8005cd:	68 f4 3f 80 00       	push   $0x803ff4
  8005d2:	e8 1a fe ff ff       	call   8003f1 <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  8005d7:	90                   	nop
  8005d8:	c9                   	leave  
  8005d9:	c3                   	ret    

008005da <putch>:
	int idx; // current buffer index
	int cnt; // total bytes printed so far
	char buf[256];
};

static void putch(int ch, struct printbuf *b) {
  8005da:	55                   	push   %ebp
  8005db:	89 e5                	mov    %esp,%ebp
  8005dd:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8005e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e3:	8b 00                	mov    (%eax),%eax
  8005e5:	8d 48 01             	lea    0x1(%eax),%ecx
  8005e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005eb:	89 0a                	mov    %ecx,(%edx)
  8005ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f0:	88 d1                	mov    %dl,%cl
  8005f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f5:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  8005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	3d ff 00 00 00       	cmp    $0xff,%eax
  800603:	75 2c                	jne    800631 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  800605:	a0 28 50 80 00       	mov    0x805028,%al
  80060a:	0f b6 c0             	movzbl %al,%eax
  80060d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800610:	8b 12                	mov    (%edx),%edx
  800612:	89 d1                	mov    %edx,%ecx
  800614:	8b 55 0c             	mov    0xc(%ebp),%edx
  800617:	83 c2 08             	add    $0x8,%edx
  80061a:	83 ec 04             	sub    $0x4,%esp
  80061d:	50                   	push   %eax
  80061e:	51                   	push   %ecx
  80061f:	52                   	push   %edx
  800620:	e8 81 13 00 00       	call   8019a6 <sys_cputs>
  800625:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  800628:	8b 45 0c             	mov    0xc(%ebp),%eax
  80062b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800631:	8b 45 0c             	mov    0xc(%ebp),%eax
  800634:	8b 40 04             	mov    0x4(%eax),%eax
  800637:	8d 50 01             	lea    0x1(%eax),%edx
  80063a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800640:	90                   	nop
  800641:	c9                   	leave  
  800642:	c3                   	ret    

00800643 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
  800646:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80064c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800653:	00 00 00 
	b.cnt = 0;
  800656:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80065d:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  800660:	ff 75 0c             	pushl  0xc(%ebp)
  800663:	ff 75 08             	pushl  0x8(%ebp)
  800666:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80066c:	50                   	push   %eax
  80066d:	68 da 05 80 00       	push   $0x8005da
  800672:	e8 11 02 00 00       	call   800888 <vprintfmt>
  800677:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  80067a:	a0 28 50 80 00       	mov    0x805028,%al
  80067f:	0f b6 c0             	movzbl %al,%eax
  800682:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800688:	83 ec 04             	sub    $0x4,%esp
  80068b:	50                   	push   %eax
  80068c:	52                   	push   %edx
  80068d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800693:	83 c0 08             	add    $0x8,%eax
  800696:	50                   	push   %eax
  800697:	e8 0a 13 00 00       	call   8019a6 <sys_cputs>
  80069c:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  80069f:	c6 05 28 50 80 00 00 	movb   $0x0,0x805028
	return b.cnt;
  8006a6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8006ac:	c9                   	leave  
  8006ad:	c3                   	ret    

008006ae <cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int cprintf(const char *fmt, ...) {
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
  8006b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  8006b4:	c6 05 28 50 80 00 01 	movb   $0x1,0x805028
	va_start(ap, fmt);
  8006bb:	8d 45 0c             	lea    0xc(%ebp),%eax
  8006be:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8006ca:	50                   	push   %eax
  8006cb:	e8 73 ff ff ff       	call   800643 <vcprintf>
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  8006d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <atomic_cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int atomic_cprintf(const char *fmt, ...)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 18             	sub    $0x18,%esp
	int cnt;
	sys_lock_cons();
  8006e1:	e8 02 13 00 00       	call   8019e8 <sys_lock_cons>
	{
		va_list ap;
		va_start(ap, fmt);
  8006e6:	8d 45 0c             	lea    0xc(%ebp),%eax
  8006e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cnt = vcprintf(fmt, ap);
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8006f5:	50                   	push   %eax
  8006f6:	e8 48 ff ff ff       	call   800643 <vcprintf>
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
		va_end(ap);
	}
	sys_unlock_cons();
  800701:	e8 fc 12 00 00       	call   801a02 <sys_unlock_cons>
	return cnt;
  800706:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800709:	c9                   	leave  
  80070a:	c3                   	ret    

0080070b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	83 ec 14             	sub    $0x14,%esp
  800712:	8b 45 10             	mov    0x10(%ebp),%eax
  800715:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80071e:	8b 45 18             	mov    0x18(%ebp),%eax
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800729:	77 55                	ja     800780 <printnum+0x75>
  80072b:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80072e:	72 05                	jb     800735 <printnum+0x2a>
  800730:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800733:	77 4b                	ja     800780 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800735:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800738:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80073b:	8b 45 18             	mov    0x18(%ebp),%eax
  80073e:	ba 00 00 00 00       	mov    $0x0,%edx
  800743:	52                   	push   %edx
  800744:	50                   	push   %eax
  800745:	ff 75 f4             	pushl  -0xc(%ebp)
  800748:	ff 75 f0             	pushl  -0x10(%ebp)
  80074b:	e8 58 33 00 00       	call   803aa8 <__udivdi3>
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	ff 75 20             	pushl  0x20(%ebp)
  800759:	53                   	push   %ebx
  80075a:	ff 75 18             	pushl  0x18(%ebp)
  80075d:	52                   	push   %edx
  80075e:	50                   	push   %eax
  80075f:	ff 75 0c             	pushl  0xc(%ebp)
  800762:	ff 75 08             	pushl  0x8(%ebp)
  800765:	e8 a1 ff ff ff       	call   80070b <printnum>
  80076a:	83 c4 20             	add    $0x20,%esp
  80076d:	eb 1a                	jmp    800789 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	ff 75 20             	pushl  0x20(%ebp)
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	ff d0                	call   *%eax
  80077d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800780:	ff 4d 1c             	decl   0x1c(%ebp)
  800783:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800787:	7f e6                	jg     80076f <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800789:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80078c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800791:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800794:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800797:	53                   	push   %ebx
  800798:	51                   	push   %ecx
  800799:	52                   	push   %edx
  80079a:	50                   	push   %eax
  80079b:	e8 18 34 00 00       	call   803bb8 <__umoddi3>
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	05 b4 42 80 00       	add    $0x8042b4,%eax
  8007a8:	8a 00                	mov    (%eax),%al
  8007aa:	0f be c0             	movsbl %al,%eax
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	ff 75 0c             	pushl  0xc(%ebp)
  8007b3:	50                   	push   %eax
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	ff d0                	call   *%eax
  8007b9:	83 c4 10             	add    $0x10,%esp
}
  8007bc:	90                   	nop
  8007bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007c5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8007c9:	7e 1c                	jle    8007e7 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	8b 00                	mov    (%eax),%eax
  8007d0:	8d 50 08             	lea    0x8(%eax),%edx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	89 10                	mov    %edx,(%eax)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	83 e8 08             	sub    $0x8,%eax
  8007e0:	8b 50 04             	mov    0x4(%eax),%edx
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	eb 40                	jmp    800827 <getuint+0x65>
	else if (lflag)
  8007e7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007eb:	74 1e                	je     80080b <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 00                	mov    (%eax),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	89 10                	mov    %edx,(%eax)
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	8b 00                	mov    (%eax),%eax
  8007ff:	83 e8 04             	sub    $0x4,%eax
  800802:	8b 00                	mov    (%eax),%eax
  800804:	ba 00 00 00 00       	mov    $0x0,%edx
  800809:	eb 1c                	jmp    800827 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 00                	mov    (%eax),%eax
  800810:	8d 50 04             	lea    0x4(%eax),%edx
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	89 10                	mov    %edx,(%eax)
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	8b 00                	mov    (%eax),%eax
  80081d:	83 e8 04             	sub    $0x4,%eax
  800820:	8b 00                	mov    (%eax),%eax
  800822:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80082c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800830:	7e 1c                	jle    80084e <getint+0x25>
		return va_arg(*ap, long long);
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	8b 00                	mov    (%eax),%eax
  800837:	8d 50 08             	lea    0x8(%eax),%edx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	89 10                	mov    %edx,(%eax)
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 00                	mov    (%eax),%eax
  800844:	83 e8 08             	sub    $0x8,%eax
  800847:	8b 50 04             	mov    0x4(%eax),%edx
  80084a:	8b 00                	mov    (%eax),%eax
  80084c:	eb 38                	jmp    800886 <getint+0x5d>
	else if (lflag)
  80084e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800852:	74 1a                	je     80086e <getint+0x45>
		return va_arg(*ap, long);
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 00                	mov    (%eax),%eax
  800859:	8d 50 04             	lea    0x4(%eax),%edx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	89 10                	mov    %edx,(%eax)
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	8b 00                	mov    (%eax),%eax
  800866:	83 e8 04             	sub    $0x4,%eax
  800869:	8b 00                	mov    (%eax),%eax
  80086b:	99                   	cltd   
  80086c:	eb 18                	jmp    800886 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 00                	mov    (%eax),%eax
  800873:	8d 50 04             	lea    0x4(%eax),%edx
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	89 10                	mov    %edx,(%eax)
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	8b 00                	mov    (%eax),%eax
  800880:	83 e8 04             	sub    $0x4,%eax
  800883:	8b 00                	mov    (%eax),%eax
  800885:	99                   	cltd   
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800890:	eb 17                	jmp    8008a9 <vprintfmt+0x21>
			if (ch == '\0')
  800892:	85 db                	test   %ebx,%ebx
  800894:	0f 84 c1 03 00 00    	je     800c5b <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	ff 75 0c             	pushl  0xc(%ebp)
  8008a0:	53                   	push   %ebx
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	ff d0                	call   *%eax
  8008a6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ac:	8d 50 01             	lea    0x1(%eax),%edx
  8008af:	89 55 10             	mov    %edx,0x10(%ebp)
  8008b2:	8a 00                	mov    (%eax),%al
  8008b4:	0f b6 d8             	movzbl %al,%ebx
  8008b7:	83 fb 25             	cmp    $0x25,%ebx
  8008ba:	75 d6                	jne    800892 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8008bc:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8008c0:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8008c7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8008ce:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8008d5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8008df:	8d 50 01             	lea    0x1(%eax),%edx
  8008e2:	89 55 10             	mov    %edx,0x10(%ebp)
  8008e5:	8a 00                	mov    (%eax),%al
  8008e7:	0f b6 d8             	movzbl %al,%ebx
  8008ea:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8008ed:	83 f8 5b             	cmp    $0x5b,%eax
  8008f0:	0f 87 3d 03 00 00    	ja     800c33 <vprintfmt+0x3ab>
  8008f6:	8b 04 85 d8 42 80 00 	mov    0x8042d8(,%eax,4),%eax
  8008fd:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8008ff:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800903:	eb d7                	jmp    8008dc <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800905:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800909:	eb d1                	jmp    8008dc <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80090b:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800912:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800915:	89 d0                	mov    %edx,%eax
  800917:	c1 e0 02             	shl    $0x2,%eax
  80091a:	01 d0                	add    %edx,%eax
  80091c:	01 c0                	add    %eax,%eax
  80091e:	01 d8                	add    %ebx,%eax
  800920:	83 e8 30             	sub    $0x30,%eax
  800923:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800926:	8b 45 10             	mov    0x10(%ebp),%eax
  800929:	8a 00                	mov    (%eax),%al
  80092b:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80092e:	83 fb 2f             	cmp    $0x2f,%ebx
  800931:	7e 3e                	jle    800971 <vprintfmt+0xe9>
  800933:	83 fb 39             	cmp    $0x39,%ebx
  800936:	7f 39                	jg     800971 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800938:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80093b:	eb d5                	jmp    800912 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80093d:	8b 45 14             	mov    0x14(%ebp),%eax
  800940:	83 c0 04             	add    $0x4,%eax
  800943:	89 45 14             	mov    %eax,0x14(%ebp)
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	83 e8 04             	sub    $0x4,%eax
  80094c:	8b 00                	mov    (%eax),%eax
  80094e:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800951:	eb 1f                	jmp    800972 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800953:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800957:	79 83                	jns    8008dc <vprintfmt+0x54>
				width = 0;
  800959:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800960:	e9 77 ff ff ff       	jmp    8008dc <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800965:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80096c:	e9 6b ff ff ff       	jmp    8008dc <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800971:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800972:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800976:	0f 89 60 ff ff ff    	jns    8008dc <vprintfmt+0x54>
				width = precision, precision = -1;
  80097c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80097f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800982:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800989:	e9 4e ff ff ff       	jmp    8008dc <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80098e:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800991:	e9 46 ff ff ff       	jmp    8008dc <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800996:	8b 45 14             	mov    0x14(%ebp),%eax
  800999:	83 c0 04             	add    $0x4,%eax
  80099c:	89 45 14             	mov    %eax,0x14(%ebp)
  80099f:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a2:	83 e8 04             	sub    $0x4,%eax
  8009a5:	8b 00                	mov    (%eax),%eax
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	ff 75 0c             	pushl  0xc(%ebp)
  8009ad:	50                   	push   %eax
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	ff d0                	call   *%eax
  8009b3:	83 c4 10             	add    $0x10,%esp
			break;
  8009b6:	e9 9b 02 00 00       	jmp    800c56 <vprintfmt+0x3ce>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009be:	83 c0 04             	add    $0x4,%eax
  8009c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8009c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c7:	83 e8 04             	sub    $0x4,%eax
  8009ca:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8009cc:	85 db                	test   %ebx,%ebx
  8009ce:	79 02                	jns    8009d2 <vprintfmt+0x14a>
				err = -err;
  8009d0:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8009d2:	83 fb 64             	cmp    $0x64,%ebx
  8009d5:	7f 0b                	jg     8009e2 <vprintfmt+0x15a>
  8009d7:	8b 34 9d 20 41 80 00 	mov    0x804120(,%ebx,4),%esi
  8009de:	85 f6                	test   %esi,%esi
  8009e0:	75 19                	jne    8009fb <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8009e2:	53                   	push   %ebx
  8009e3:	68 c5 42 80 00       	push   $0x8042c5
  8009e8:	ff 75 0c             	pushl  0xc(%ebp)
  8009eb:	ff 75 08             	pushl  0x8(%ebp)
  8009ee:	e8 70 02 00 00       	call   800c63 <printfmt>
  8009f3:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8009f6:	e9 5b 02 00 00       	jmp    800c56 <vprintfmt+0x3ce>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009fb:	56                   	push   %esi
  8009fc:	68 ce 42 80 00       	push   $0x8042ce
  800a01:	ff 75 0c             	pushl  0xc(%ebp)
  800a04:	ff 75 08             	pushl  0x8(%ebp)
  800a07:	e8 57 02 00 00       	call   800c63 <printfmt>
  800a0c:	83 c4 10             	add    $0x10,%esp
			break;
  800a0f:	e9 42 02 00 00       	jmp    800c56 <vprintfmt+0x3ce>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a14:	8b 45 14             	mov    0x14(%ebp),%eax
  800a17:	83 c0 04             	add    $0x4,%eax
  800a1a:	89 45 14             	mov    %eax,0x14(%ebp)
  800a1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a20:	83 e8 04             	sub    $0x4,%eax
  800a23:	8b 30                	mov    (%eax),%esi
  800a25:	85 f6                	test   %esi,%esi
  800a27:	75 05                	jne    800a2e <vprintfmt+0x1a6>
				p = "(null)";
  800a29:	be d1 42 80 00       	mov    $0x8042d1,%esi
			if (width > 0 && padc != '-')
  800a2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a32:	7e 6d                	jle    800aa1 <vprintfmt+0x219>
  800a34:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800a38:	74 67                	je     800aa1 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a3a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a3d:	83 ec 08             	sub    $0x8,%esp
  800a40:	50                   	push   %eax
  800a41:	56                   	push   %esi
  800a42:	e8 1e 03 00 00       	call   800d65 <strnlen>
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800a4d:	eb 16                	jmp    800a65 <vprintfmt+0x1dd>
					putch(padc, putdat);
  800a4f:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800a53:	83 ec 08             	sub    $0x8,%esp
  800a56:	ff 75 0c             	pushl  0xc(%ebp)
  800a59:	50                   	push   %eax
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	ff d0                	call   *%eax
  800a5f:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a62:	ff 4d e4             	decl   -0x1c(%ebp)
  800a65:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a69:	7f e4                	jg     800a4f <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a6b:	eb 34                	jmp    800aa1 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  800a6d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a71:	74 1c                	je     800a8f <vprintfmt+0x207>
  800a73:	83 fb 1f             	cmp    $0x1f,%ebx
  800a76:	7e 05                	jle    800a7d <vprintfmt+0x1f5>
  800a78:	83 fb 7e             	cmp    $0x7e,%ebx
  800a7b:	7e 12                	jle    800a8f <vprintfmt+0x207>
					putch('?', putdat);
  800a7d:	83 ec 08             	sub    $0x8,%esp
  800a80:	ff 75 0c             	pushl  0xc(%ebp)
  800a83:	6a 3f                	push   $0x3f
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	ff d0                	call   *%eax
  800a8a:	83 c4 10             	add    $0x10,%esp
  800a8d:	eb 0f                	jmp    800a9e <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800a8f:	83 ec 08             	sub    $0x8,%esp
  800a92:	ff 75 0c             	pushl  0xc(%ebp)
  800a95:	53                   	push   %ebx
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	ff d0                	call   *%eax
  800a9b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a9e:	ff 4d e4             	decl   -0x1c(%ebp)
  800aa1:	89 f0                	mov    %esi,%eax
  800aa3:	8d 70 01             	lea    0x1(%eax),%esi
  800aa6:	8a 00                	mov    (%eax),%al
  800aa8:	0f be d8             	movsbl %al,%ebx
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	74 24                	je     800ad3 <vprintfmt+0x24b>
  800aaf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800ab3:	78 b8                	js     800a6d <vprintfmt+0x1e5>
  800ab5:	ff 4d e0             	decl   -0x20(%ebp)
  800ab8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800abc:	79 af                	jns    800a6d <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800abe:	eb 13                	jmp    800ad3 <vprintfmt+0x24b>
				putch(' ', putdat);
  800ac0:	83 ec 08             	sub    $0x8,%esp
  800ac3:	ff 75 0c             	pushl  0xc(%ebp)
  800ac6:	6a 20                	push   $0x20
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	ff d0                	call   *%eax
  800acd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ad0:	ff 4d e4             	decl   -0x1c(%ebp)
  800ad3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ad7:	7f e7                	jg     800ac0 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  800ad9:	e9 78 01 00 00       	jmp    800c56 <vprintfmt+0x3ce>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ade:	83 ec 08             	sub    $0x8,%esp
  800ae1:	ff 75 e8             	pushl  -0x18(%ebp)
  800ae4:	8d 45 14             	lea    0x14(%ebp),%eax
  800ae7:	50                   	push   %eax
  800ae8:	e8 3c fd ff ff       	call   800829 <getint>
  800aed:	83 c4 10             	add    $0x10,%esp
  800af0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800af3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afc:	85 d2                	test   %edx,%edx
  800afe:	79 23                	jns    800b23 <vprintfmt+0x29b>
				putch('-', putdat);
  800b00:	83 ec 08             	sub    $0x8,%esp
  800b03:	ff 75 0c             	pushl  0xc(%ebp)
  800b06:	6a 2d                	push   $0x2d
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	ff d0                	call   *%eax
  800b0d:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b13:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b16:	f7 d8                	neg    %eax
  800b18:	83 d2 00             	adc    $0x0,%edx
  800b1b:	f7 da                	neg    %edx
  800b1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b20:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800b23:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800b2a:	e9 bc 00 00 00       	jmp    800beb <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	ff 75 e8             	pushl  -0x18(%ebp)
  800b35:	8d 45 14             	lea    0x14(%ebp),%eax
  800b38:	50                   	push   %eax
  800b39:	e8 84 fc ff ff       	call   8007c2 <getuint>
  800b3e:	83 c4 10             	add    $0x10,%esp
  800b41:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b44:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800b47:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800b4e:	e9 98 00 00 00       	jmp    800beb <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b53:	83 ec 08             	sub    $0x8,%esp
  800b56:	ff 75 0c             	pushl  0xc(%ebp)
  800b59:	6a 58                	push   $0x58
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	ff d0                	call   *%eax
  800b60:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	ff 75 0c             	pushl  0xc(%ebp)
  800b69:	6a 58                	push   $0x58
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	ff d0                	call   *%eax
  800b70:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800b73:	83 ec 08             	sub    $0x8,%esp
  800b76:	ff 75 0c             	pushl  0xc(%ebp)
  800b79:	6a 58                	push   $0x58
  800b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7e:	ff d0                	call   *%eax
  800b80:	83 c4 10             	add    $0x10,%esp
			break;
  800b83:	e9 ce 00 00 00       	jmp    800c56 <vprintfmt+0x3ce>

		// pointer
		case 'p':
			putch('0', putdat);
  800b88:	83 ec 08             	sub    $0x8,%esp
  800b8b:	ff 75 0c             	pushl  0xc(%ebp)
  800b8e:	6a 30                	push   $0x30
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	ff d0                	call   *%eax
  800b95:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800b98:	83 ec 08             	sub    $0x8,%esp
  800b9b:	ff 75 0c             	pushl  0xc(%ebp)
  800b9e:	6a 78                	push   $0x78
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	ff d0                	call   *%eax
  800ba5:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800ba8:	8b 45 14             	mov    0x14(%ebp),%eax
  800bab:	83 c0 04             	add    $0x4,%eax
  800bae:	89 45 14             	mov    %eax,0x14(%ebp)
  800bb1:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb4:	83 e8 04             	sub    $0x4,%eax
  800bb7:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bbc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  800bc3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800bca:	eb 1f                	jmp    800beb <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bcc:	83 ec 08             	sub    $0x8,%esp
  800bcf:	ff 75 e8             	pushl  -0x18(%ebp)
  800bd2:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd5:	50                   	push   %eax
  800bd6:	e8 e7 fb ff ff       	call   8007c2 <getuint>
  800bdb:	83 c4 10             	add    $0x10,%esp
  800bde:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800be1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800be4:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800beb:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf2:	83 ec 04             	sub    $0x4,%esp
  800bf5:	52                   	push   %edx
  800bf6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bf9:	50                   	push   %eax
  800bfa:	ff 75 f4             	pushl  -0xc(%ebp)
  800bfd:	ff 75 f0             	pushl  -0x10(%ebp)
  800c00:	ff 75 0c             	pushl  0xc(%ebp)
  800c03:	ff 75 08             	pushl  0x8(%ebp)
  800c06:	e8 00 fb ff ff       	call   80070b <printnum>
  800c0b:	83 c4 20             	add    $0x20,%esp
			break;
  800c0e:	eb 46                	jmp    800c56 <vprintfmt+0x3ce>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	ff 75 0c             	pushl  0xc(%ebp)
  800c16:	53                   	push   %ebx
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	ff d0                	call   *%eax
  800c1c:	83 c4 10             	add    $0x10,%esp
			break;
  800c1f:	eb 35                	jmp    800c56 <vprintfmt+0x3ce>

		/**********************************/
		/*2023*/
		// DON'T Print Program Name & UD
		case '~':
			printProgName = 0;
  800c21:	c6 05 28 50 80 00 00 	movb   $0x0,0x805028
			break;
  800c28:	eb 2c                	jmp    800c56 <vprintfmt+0x3ce>
		// Print Program Name & UD
		case '@':
			printProgName = 1;
  800c2a:	c6 05 28 50 80 00 01 	movb   $0x1,0x805028
			break;
  800c31:	eb 23                	jmp    800c56 <vprintfmt+0x3ce>
		/**********************************/

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c33:	83 ec 08             	sub    $0x8,%esp
  800c36:	ff 75 0c             	pushl  0xc(%ebp)
  800c39:	6a 25                	push   $0x25
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	ff d0                	call   *%eax
  800c40:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c43:	ff 4d 10             	decl   0x10(%ebp)
  800c46:	eb 03                	jmp    800c4b <vprintfmt+0x3c3>
  800c48:	ff 4d 10             	decl   0x10(%ebp)
  800c4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4e:	48                   	dec    %eax
  800c4f:	8a 00                	mov    (%eax),%al
  800c51:	3c 25                	cmp    $0x25,%al
  800c53:	75 f3                	jne    800c48 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
  800c55:	90                   	nop
		}
	}
  800c56:	e9 35 fc ff ff       	jmp    800890 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800c5b:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c69:	8d 45 10             	lea    0x10(%ebp),%eax
  800c6c:	83 c0 04             	add    $0x4,%eax
  800c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800c72:	8b 45 10             	mov    0x10(%ebp),%eax
  800c75:	ff 75 f4             	pushl  -0xc(%ebp)
  800c78:	50                   	push   %eax
  800c79:	ff 75 0c             	pushl  0xc(%ebp)
  800c7c:	ff 75 08             	pushl  0x8(%ebp)
  800c7f:	e8 04 fc ff ff       	call   800888 <vprintfmt>
  800c84:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800c87:	90                   	nop
  800c88:	c9                   	leave  
  800c89:	c3                   	ret    

00800c8a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800c8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c90:	8b 40 08             	mov    0x8(%eax),%eax
  800c93:	8d 50 01             	lea    0x1(%eax),%edx
  800c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c99:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9f:	8b 10                	mov    (%eax),%edx
  800ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca4:	8b 40 04             	mov    0x4(%eax),%eax
  800ca7:	39 c2                	cmp    %eax,%edx
  800ca9:	73 12                	jae    800cbd <sprintputch+0x33>
		*b->buf++ = ch;
  800cab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cae:	8b 00                	mov    (%eax),%eax
  800cb0:	8d 48 01             	lea    0x1(%eax),%ecx
  800cb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb6:	89 0a                	mov    %ecx,(%edx)
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	88 10                	mov    %dl,(%eax)
}
  800cbd:	90                   	nop
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccf:	8d 50 ff             	lea    -0x1(%eax),%edx
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	01 d0                	add    %edx,%eax
  800cd7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800cda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ce1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ce5:	74 06                	je     800ced <vsnprintf+0x2d>
  800ce7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ceb:	7f 07                	jg     800cf4 <vsnprintf+0x34>
		return -E_INVAL;
  800ced:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf2:	eb 20                	jmp    800d14 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cf4:	ff 75 14             	pushl  0x14(%ebp)
  800cf7:	ff 75 10             	pushl  0x10(%ebp)
  800cfa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cfd:	50                   	push   %eax
  800cfe:	68 8a 0c 80 00       	push   $0x800c8a
  800d03:	e8 80 fb ff ff       	call   800888 <vprintfmt>
  800d08:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  800d0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d0e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    

00800d16 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d1c:	8d 45 10             	lea    0x10(%ebp),%eax
  800d1f:	83 c0 04             	add    $0x4,%eax
  800d22:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800d25:	8b 45 10             	mov    0x10(%ebp),%eax
  800d28:	ff 75 f4             	pushl  -0xc(%ebp)
  800d2b:	50                   	push   %eax
  800d2c:	ff 75 0c             	pushl  0xc(%ebp)
  800d2f:	ff 75 08             	pushl  0x8(%ebp)
  800d32:	e8 89 ff ff ff       	call   800cc0 <vsnprintf>
  800d37:	83 c4 10             	add    $0x10,%esp
  800d3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  800d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800d40:	c9                   	leave  
  800d41:	c3                   	ret    

00800d42 <strlen>:
#include <inc/string.h>
#include <inc/assert.h>

int
strlen(const char *s)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800d48:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d4f:	eb 06                	jmp    800d57 <strlen+0x15>
		n++;
  800d51:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d54:	ff 45 08             	incl   0x8(%ebp)
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	8a 00                	mov    (%eax),%al
  800d5c:	84 c0                	test   %al,%al
  800d5e:	75 f1                	jne    800d51 <strlen+0xf>
		n++;
	return n;
  800d60:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    

00800d65 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d6b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d72:	eb 09                	jmp    800d7d <strnlen+0x18>
		n++;
  800d74:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d77:	ff 45 08             	incl   0x8(%ebp)
  800d7a:	ff 4d 0c             	decl   0xc(%ebp)
  800d7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d81:	74 09                	je     800d8c <strnlen+0x27>
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	8a 00                	mov    (%eax),%al
  800d88:	84 c0                	test   %al,%al
  800d8a:	75 e8                	jne    800d74 <strnlen+0xf>
		n++;
	return n;
  800d8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800d97:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800d9d:	90                   	nop
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	8d 50 01             	lea    0x1(%eax),%edx
  800da4:	89 55 08             	mov    %edx,0x8(%ebp)
  800da7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800daa:	8d 4a 01             	lea    0x1(%edx),%ecx
  800dad:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800db0:	8a 12                	mov    (%edx),%dl
  800db2:	88 10                	mov    %dl,(%eax)
  800db4:	8a 00                	mov    (%eax),%al
  800db6:	84 c0                	test   %al,%al
  800db8:	75 e4                	jne    800d9e <strcpy+0xd>
		/* do nothing */;
	return ret;
  800dba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    

00800dbf <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc8:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800dcb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800dd2:	eb 1f                	jmp    800df3 <strncpy+0x34>
		*dst++ = *src;
  800dd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd7:	8d 50 01             	lea    0x1(%eax),%edx
  800dda:	89 55 08             	mov    %edx,0x8(%ebp)
  800ddd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de0:	8a 12                	mov    (%edx),%dl
  800de2:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800de4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de7:	8a 00                	mov    (%eax),%al
  800de9:	84 c0                	test   %al,%al
  800deb:	74 03                	je     800df0 <strncpy+0x31>
			src++;
  800ded:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800df0:	ff 45 fc             	incl   -0x4(%ebp)
  800df3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800df6:	3b 45 10             	cmp    0x10(%ebp),%eax
  800df9:	72 d9                	jb     800dd4 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800dfb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800e0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e10:	74 30                	je     800e42 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800e12:	eb 16                	jmp    800e2a <strlcpy+0x2a>
			*dst++ = *src++;
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	8d 50 01             	lea    0x1(%eax),%edx
  800e1a:	89 55 08             	mov    %edx,0x8(%ebp)
  800e1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e20:	8d 4a 01             	lea    0x1(%edx),%ecx
  800e23:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800e26:	8a 12                	mov    (%edx),%dl
  800e28:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e2a:	ff 4d 10             	decl   0x10(%ebp)
  800e2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e31:	74 09                	je     800e3c <strlcpy+0x3c>
  800e33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e36:	8a 00                	mov    (%eax),%al
  800e38:	84 c0                	test   %al,%al
  800e3a:	75 d8                	jne    800e14 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e48:	29 c2                	sub    %eax,%edx
  800e4a:	89 d0                	mov    %edx,%eax
}
  800e4c:	c9                   	leave  
  800e4d:	c3                   	ret    

00800e4e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800e51:	eb 06                	jmp    800e59 <strcmp+0xb>
		p++, q++;
  800e53:	ff 45 08             	incl   0x8(%ebp)
  800e56:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	8a 00                	mov    (%eax),%al
  800e5e:	84 c0                	test   %al,%al
  800e60:	74 0e                	je     800e70 <strcmp+0x22>
  800e62:	8b 45 08             	mov    0x8(%ebp),%eax
  800e65:	8a 10                	mov    (%eax),%dl
  800e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6a:	8a 00                	mov    (%eax),%al
  800e6c:	38 c2                	cmp    %al,%dl
  800e6e:	74 e3                	je     800e53 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	8a 00                	mov    (%eax),%al
  800e75:	0f b6 d0             	movzbl %al,%edx
  800e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7b:	8a 00                	mov    (%eax),%al
  800e7d:	0f b6 c0             	movzbl %al,%eax
  800e80:	29 c2                	sub    %eax,%edx
  800e82:	89 d0                	mov    %edx,%eax
}
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800e89:	eb 09                	jmp    800e94 <strncmp+0xe>
		n--, p++, q++;
  800e8b:	ff 4d 10             	decl   0x10(%ebp)
  800e8e:	ff 45 08             	incl   0x8(%ebp)
  800e91:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800e94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e98:	74 17                	je     800eb1 <strncmp+0x2b>
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	8a 00                	mov    (%eax),%al
  800e9f:	84 c0                	test   %al,%al
  800ea1:	74 0e                	je     800eb1 <strncmp+0x2b>
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea6:	8a 10                	mov    (%eax),%dl
  800ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eab:	8a 00                	mov    (%eax),%al
  800ead:	38 c2                	cmp    %al,%dl
  800eaf:	74 da                	je     800e8b <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800eb1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800eb5:	75 07                	jne    800ebe <strncmp+0x38>
		return 0;
  800eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebc:	eb 14                	jmp    800ed2 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	8a 00                	mov    (%eax),%al
  800ec3:	0f b6 d0             	movzbl %al,%edx
  800ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec9:	8a 00                	mov    (%eax),%al
  800ecb:	0f b6 c0             	movzbl %al,%eax
  800ece:	29 c2                	sub    %eax,%edx
  800ed0:	89 d0                	mov    %edx,%eax
}
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 04             	sub    $0x4,%esp
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ee0:	eb 12                	jmp    800ef4 <strchr+0x20>
		if (*s == c)
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	8a 00                	mov    (%eax),%al
  800ee7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800eea:	75 05                	jne    800ef1 <strchr+0x1d>
			return (char *) s;
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	eb 11                	jmp    800f02 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ef1:	ff 45 08             	incl   0x8(%ebp)
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef7:	8a 00                	mov    (%eax),%al
  800ef9:	84 c0                	test   %al,%al
  800efb:	75 e5                	jne    800ee2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 04             	sub    $0x4,%esp
  800f0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0d:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800f10:	eb 0d                	jmp    800f1f <strfind+0x1b>
		if (*s == c)
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	8a 00                	mov    (%eax),%al
  800f17:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800f1a:	74 0e                	je     800f2a <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f1c:	ff 45 08             	incl   0x8(%ebp)
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	8a 00                	mov    (%eax),%al
  800f24:	84 c0                	test   %al,%al
  800f26:	75 ea                	jne    800f12 <strfind+0xe>
  800f28:	eb 01                	jmp    800f2b <strfind+0x27>
		if (*s == c)
			break;
  800f2a:	90                   	nop
	return (char *) s;
  800f2b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800f36:	8b 45 08             	mov    0x8(%ebp),%eax
  800f39:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800f3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800f42:	eb 0e                	jmp    800f52 <memset+0x22>
		*p++ = c;
  800f44:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f47:	8d 50 01             	lea    0x1(%eax),%edx
  800f4a:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800f4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f50:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800f52:	ff 4d f8             	decl   -0x8(%ebp)
  800f55:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800f59:	79 e9                	jns    800f44 <memset+0x14>
		*p++ = c;

	return v;
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f5e:	c9                   	leave  
  800f5f:	c3                   	ret    

00800f60 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f69:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800f72:	eb 16                	jmp    800f8a <memcpy+0x2a>
		*d++ = *s++;
  800f74:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f77:	8d 50 01             	lea    0x1(%eax),%edx
  800f7a:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800f7d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f80:	8d 4a 01             	lea    0x1(%edx),%ecx
  800f83:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800f86:	8a 12                	mov    (%edx),%dl
  800f88:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800f8a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f90:	89 55 10             	mov    %edx,0x10(%ebp)
  800f93:	85 c0                	test   %eax,%eax
  800f95:	75 dd                	jne    800f74 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    

00800f9c <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fab:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800fae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fb1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800fb4:	73 50                	jae    801006 <memmove+0x6a>
  800fb6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800fb9:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbc:	01 d0                	add    %edx,%eax
  800fbe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800fc1:	76 43                	jbe    801006 <memmove+0x6a>
		s += n;
  800fc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc6:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800fc9:	8b 45 10             	mov    0x10(%ebp),%eax
  800fcc:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800fcf:	eb 10                	jmp    800fe1 <memmove+0x45>
			*--d = *--s;
  800fd1:	ff 4d f8             	decl   -0x8(%ebp)
  800fd4:	ff 4d fc             	decl   -0x4(%ebp)
  800fd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fda:	8a 10                	mov    (%eax),%dl
  800fdc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fdf:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800fe1:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fe7:	89 55 10             	mov    %edx,0x10(%ebp)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	75 e3                	jne    800fd1 <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800fee:	eb 23                	jmp    801013 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800ff0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ff3:	8d 50 01             	lea    0x1(%eax),%edx
  800ff6:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800ff9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ffc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800fff:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  801002:	8a 12                	mov    (%edx),%dl
  801004:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  801006:	8b 45 10             	mov    0x10(%ebp),%eax
  801009:	8d 50 ff             	lea    -0x1(%eax),%edx
  80100c:	89 55 10             	mov    %edx,0x10(%ebp)
  80100f:	85 c0                	test   %eax,%eax
  801011:	75 dd                	jne    800ff0 <memmove+0x54>
			*d++ = *s++;

	return dst;
  801013:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801016:	c9                   	leave  
  801017:	c3                   	ret    

00801018 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
  801021:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  801024:	8b 45 0c             	mov    0xc(%ebp),%eax
  801027:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  80102a:	eb 2a                	jmp    801056 <memcmp+0x3e>
		if (*s1 != *s2)
  80102c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80102f:	8a 10                	mov    (%eax),%dl
  801031:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801034:	8a 00                	mov    (%eax),%al
  801036:	38 c2                	cmp    %al,%dl
  801038:	74 16                	je     801050 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  80103a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80103d:	8a 00                	mov    (%eax),%al
  80103f:	0f b6 d0             	movzbl %al,%edx
  801042:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801045:	8a 00                	mov    (%eax),%al
  801047:	0f b6 c0             	movzbl %al,%eax
  80104a:	29 c2                	sub    %eax,%edx
  80104c:	89 d0                	mov    %edx,%eax
  80104e:	eb 18                	jmp    801068 <memcmp+0x50>
		s1++, s2++;
  801050:	ff 45 fc             	incl   -0x4(%ebp)
  801053:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  801056:	8b 45 10             	mov    0x10(%ebp),%eax
  801059:	8d 50 ff             	lea    -0x1(%eax),%edx
  80105c:	89 55 10             	mov    %edx,0x10(%ebp)
  80105f:	85 c0                	test   %eax,%eax
  801061:	75 c9                	jne    80102c <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801063:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801068:	c9                   	leave  
  801069:	c3                   	ret    

0080106a <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801070:	8b 55 08             	mov    0x8(%ebp),%edx
  801073:	8b 45 10             	mov    0x10(%ebp),%eax
  801076:	01 d0                	add    %edx,%eax
  801078:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80107b:	eb 15                	jmp    801092 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax
  801080:	8a 00                	mov    (%eax),%al
  801082:	0f b6 d0             	movzbl %al,%edx
  801085:	8b 45 0c             	mov    0xc(%ebp),%eax
  801088:	0f b6 c0             	movzbl %al,%eax
  80108b:	39 c2                	cmp    %eax,%edx
  80108d:	74 0d                	je     80109c <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80108f:	ff 45 08             	incl   0x8(%ebp)
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801098:	72 e3                	jb     80107d <memfind+0x13>
  80109a:	eb 01                	jmp    80109d <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  80109c:	90                   	nop
	return (void *) s;
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8010a8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8010af:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010b6:	eb 03                	jmp    8010bb <strtol+0x19>
		s++;
  8010b8:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	8a 00                	mov    (%eax),%al
  8010c0:	3c 20                	cmp    $0x20,%al
  8010c2:	74 f4                	je     8010b8 <strtol+0x16>
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	8a 00                	mov    (%eax),%al
  8010c9:	3c 09                	cmp    $0x9,%al
  8010cb:	74 eb                	je     8010b8 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	8a 00                	mov    (%eax),%al
  8010d2:	3c 2b                	cmp    $0x2b,%al
  8010d4:	75 05                	jne    8010db <strtol+0x39>
		s++;
  8010d6:	ff 45 08             	incl   0x8(%ebp)
  8010d9:	eb 13                	jmp    8010ee <strtol+0x4c>
	else if (*s == '-')
  8010db:	8b 45 08             	mov    0x8(%ebp),%eax
  8010de:	8a 00                	mov    (%eax),%al
  8010e0:	3c 2d                	cmp    $0x2d,%al
  8010e2:	75 0a                	jne    8010ee <strtol+0x4c>
		s++, neg = 1;
  8010e4:	ff 45 08             	incl   0x8(%ebp)
  8010e7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010f2:	74 06                	je     8010fa <strtol+0x58>
  8010f4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010f8:	75 20                	jne    80111a <strtol+0x78>
  8010fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fd:	8a 00                	mov    (%eax),%al
  8010ff:	3c 30                	cmp    $0x30,%al
  801101:	75 17                	jne    80111a <strtol+0x78>
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	40                   	inc    %eax
  801107:	8a 00                	mov    (%eax),%al
  801109:	3c 78                	cmp    $0x78,%al
  80110b:	75 0d                	jne    80111a <strtol+0x78>
		s += 2, base = 16;
  80110d:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801111:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801118:	eb 28                	jmp    801142 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  80111a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80111e:	75 15                	jne    801135 <strtol+0x93>
  801120:	8b 45 08             	mov    0x8(%ebp),%eax
  801123:	8a 00                	mov    (%eax),%al
  801125:	3c 30                	cmp    $0x30,%al
  801127:	75 0c                	jne    801135 <strtol+0x93>
		s++, base = 8;
  801129:	ff 45 08             	incl   0x8(%ebp)
  80112c:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801133:	eb 0d                	jmp    801142 <strtol+0xa0>
	else if (base == 0)
  801135:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801139:	75 07                	jne    801142 <strtol+0xa0>
		base = 10;
  80113b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	8a 00                	mov    (%eax),%al
  801147:	3c 2f                	cmp    $0x2f,%al
  801149:	7e 19                	jle    801164 <strtol+0xc2>
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	8a 00                	mov    (%eax),%al
  801150:	3c 39                	cmp    $0x39,%al
  801152:	7f 10                	jg     801164 <strtol+0xc2>
			dig = *s - '0';
  801154:	8b 45 08             	mov    0x8(%ebp),%eax
  801157:	8a 00                	mov    (%eax),%al
  801159:	0f be c0             	movsbl %al,%eax
  80115c:	83 e8 30             	sub    $0x30,%eax
  80115f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801162:	eb 42                	jmp    8011a6 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  801164:	8b 45 08             	mov    0x8(%ebp),%eax
  801167:	8a 00                	mov    (%eax),%al
  801169:	3c 60                	cmp    $0x60,%al
  80116b:	7e 19                	jle    801186 <strtol+0xe4>
  80116d:	8b 45 08             	mov    0x8(%ebp),%eax
  801170:	8a 00                	mov    (%eax),%al
  801172:	3c 7a                	cmp    $0x7a,%al
  801174:	7f 10                	jg     801186 <strtol+0xe4>
			dig = *s - 'a' + 10;
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
  801179:	8a 00                	mov    (%eax),%al
  80117b:	0f be c0             	movsbl %al,%eax
  80117e:	83 e8 57             	sub    $0x57,%eax
  801181:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801184:	eb 20                	jmp    8011a6 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	8a 00                	mov    (%eax),%al
  80118b:	3c 40                	cmp    $0x40,%al
  80118d:	7e 39                	jle    8011c8 <strtol+0x126>
  80118f:	8b 45 08             	mov    0x8(%ebp),%eax
  801192:	8a 00                	mov    (%eax),%al
  801194:	3c 5a                	cmp    $0x5a,%al
  801196:	7f 30                	jg     8011c8 <strtol+0x126>
			dig = *s - 'A' + 10;
  801198:	8b 45 08             	mov    0x8(%ebp),%eax
  80119b:	8a 00                	mov    (%eax),%al
  80119d:	0f be c0             	movsbl %al,%eax
  8011a0:	83 e8 37             	sub    $0x37,%eax
  8011a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8011a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a9:	3b 45 10             	cmp    0x10(%ebp),%eax
  8011ac:	7d 19                	jge    8011c7 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  8011ae:	ff 45 08             	incl   0x8(%ebp)
  8011b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011b4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bd:	01 d0                	add    %edx,%eax
  8011bf:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8011c2:	e9 7b ff ff ff       	jmp    801142 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  8011c7:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8011c8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011cc:	74 08                	je     8011d6 <strtol+0x134>
		*endptr = (char *) s;
  8011ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011d6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011da:	74 07                	je     8011e3 <strtol+0x141>
  8011dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011df:	f7 d8                	neg    %eax
  8011e1:	eb 03                	jmp    8011e6 <strtol+0x144>
  8011e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <ltostr>:

void
ltostr(long value, char *str)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  8011ee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  8011f5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  8011fc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801200:	79 13                	jns    801215 <ltostr+0x2d>
	{
		neg = 1;
  801202:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  801209:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120c:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  80120f:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  801212:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  801215:	8b 45 08             	mov    0x8(%ebp),%eax
  801218:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80121d:	99                   	cltd   
  80121e:	f7 f9                	idiv   %ecx
  801220:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  801223:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801226:	8d 50 01             	lea    0x1(%eax),%edx
  801229:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801231:	01 d0                	add    %edx,%eax
  801233:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801236:	83 c2 30             	add    $0x30,%edx
  801239:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  80123b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123e:	b8 67 66 66 66       	mov    $0x66666667,%eax
  801243:	f7 e9                	imul   %ecx
  801245:	c1 fa 02             	sar    $0x2,%edx
  801248:	89 c8                	mov    %ecx,%eax
  80124a:	c1 f8 1f             	sar    $0x1f,%eax
  80124d:	29 c2                	sub    %eax,%edx
  80124f:	89 d0                	mov    %edx,%eax
  801251:	89 45 08             	mov    %eax,0x8(%ebp)
	/*2023 FIX el7 :)*/
	//} while (value % 10 != 0);
	} while (value != 0);
  801254:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801258:	75 bb                	jne    801215 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  80125a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  801261:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801264:	48                   	dec    %eax
  801265:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  801268:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80126c:	74 3d                	je     8012ab <ltostr+0xc3>
		start = 1 ;
  80126e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  801275:	eb 34                	jmp    8012ab <ltostr+0xc3>
	{
		char tmp = str[start] ;
  801277:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127d:	01 d0                	add    %edx,%eax
  80127f:	8a 00                	mov    (%eax),%al
  801281:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  801284:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128a:	01 c2                	add    %eax,%edx
  80128c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  80128f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801292:	01 c8                	add    %ecx,%eax
  801294:	8a 00                	mov    (%eax),%al
  801296:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  801298:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80129b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129e:	01 c2                	add    %eax,%edx
  8012a0:	8a 45 eb             	mov    -0x15(%ebp),%al
  8012a3:	88 02                	mov    %al,(%edx)
		start++ ;
  8012a5:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  8012a8:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  8012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ae:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8012b1:	7c c4                	jl     801277 <ltostr+0x8f>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  8012b3:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8012b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b9:	01 d0                	add    %edx,%eax
  8012bb:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  8012be:	90                   	nop
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  8012c7:	ff 75 08             	pushl  0x8(%ebp)
  8012ca:	e8 73 fa ff ff       	call   800d42 <strlen>
  8012cf:	83 c4 04             	add    $0x4,%esp
  8012d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  8012d5:	ff 75 0c             	pushl  0xc(%ebp)
  8012d8:	e8 65 fa ff ff       	call   800d42 <strlen>
  8012dd:	83 c4 04             	add    $0x4,%esp
  8012e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  8012e3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  8012ea:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8012f1:	eb 17                	jmp    80130a <strcconcat+0x49>
		final[s] = str1[s] ;
  8012f3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8012f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8012f9:	01 c2                	add    %eax,%edx
  8012fb:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  8012fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801301:	01 c8                	add    %ecx,%eax
  801303:	8a 00                	mov    (%eax),%al
  801305:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  801307:	ff 45 fc             	incl   -0x4(%ebp)
  80130a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80130d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  801310:	7c e1                	jl     8012f3 <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  801312:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  801319:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  801320:	eb 1f                	jmp    801341 <strcconcat+0x80>
		final[s++] = str2[i] ;
  801322:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801325:	8d 50 01             	lea    0x1(%eax),%edx
  801328:	89 55 fc             	mov    %edx,-0x4(%ebp)
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	8b 45 10             	mov    0x10(%ebp),%eax
  801330:	01 c2                	add    %eax,%edx
  801332:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  801335:	8b 45 0c             	mov    0xc(%ebp),%eax
  801338:	01 c8                	add    %ecx,%eax
  80133a:	8a 00                	mov    (%eax),%al
  80133c:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  80133e:	ff 45 f8             	incl   -0x8(%ebp)
  801341:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801344:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801347:	7c d9                	jl     801322 <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  801349:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80134c:	8b 45 10             	mov    0x10(%ebp),%eax
  80134f:	01 d0                	add    %edx,%eax
  801351:	c6 00 00             	movb   $0x0,(%eax)
}
  801354:	90                   	nop
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	8b 00                	mov    (%eax),%eax
  801368:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80136f:	8b 45 10             	mov    0x10(%ebp),%eax
  801372:	01 d0                	add    %edx,%eax
  801374:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  80137a:	eb 0c                	jmp    801388 <strsplit+0x31>
			*string++ = 0;
  80137c:	8b 45 08             	mov    0x8(%ebp),%eax
  80137f:	8d 50 01             	lea    0x1(%eax),%edx
  801382:	89 55 08             	mov    %edx,0x8(%ebp)
  801385:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  801388:	8b 45 08             	mov    0x8(%ebp),%eax
  80138b:	8a 00                	mov    (%eax),%al
  80138d:	84 c0                	test   %al,%al
  80138f:	74 18                	je     8013a9 <strsplit+0x52>
  801391:	8b 45 08             	mov    0x8(%ebp),%eax
  801394:	8a 00                	mov    (%eax),%al
  801396:	0f be c0             	movsbl %al,%eax
  801399:	50                   	push   %eax
  80139a:	ff 75 0c             	pushl  0xc(%ebp)
  80139d:	e8 32 fb ff ff       	call   800ed4 <strchr>
  8013a2:	83 c4 08             	add    $0x8,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	75 d3                	jne    80137c <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  8013a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ac:	8a 00                	mov    (%eax),%al
  8013ae:	84 c0                	test   %al,%al
  8013b0:	74 5a                	je     80140c <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  8013b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b5:	8b 00                	mov    (%eax),%eax
  8013b7:	83 f8 0f             	cmp    $0xf,%eax
  8013ba:	75 07                	jne    8013c3 <strsplit+0x6c>
		{
			return 0;
  8013bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c1:	eb 66                	jmp    801429 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  8013c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c6:	8b 00                	mov    (%eax),%eax
  8013c8:	8d 48 01             	lea    0x1(%eax),%ecx
  8013cb:	8b 55 14             	mov    0x14(%ebp),%edx
  8013ce:	89 0a                	mov    %ecx,(%edx)
  8013d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8013da:	01 c2                	add    %eax,%edx
  8013dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013df:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  8013e1:	eb 03                	jmp    8013e6 <strsplit+0x8f>
			string++;
  8013e3:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  8013e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e9:	8a 00                	mov    (%eax),%al
  8013eb:	84 c0                	test   %al,%al
  8013ed:	74 8b                	je     80137a <strsplit+0x23>
  8013ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f2:	8a 00                	mov    (%eax),%al
  8013f4:	0f be c0             	movsbl %al,%eax
  8013f7:	50                   	push   %eax
  8013f8:	ff 75 0c             	pushl  0xc(%ebp)
  8013fb:	e8 d4 fa ff ff       	call   800ed4 <strchr>
  801400:	83 c4 08             	add    $0x8,%esp
  801403:	85 c0                	test   %eax,%eax
  801405:	74 dc                	je     8013e3 <strsplit+0x8c>
			string++;
	}
  801407:	e9 6e ff ff ff       	jmp    80137a <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  80140c:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  80140d:	8b 45 14             	mov    0x14(%ebp),%eax
  801410:	8b 00                	mov    (%eax),%eax
  801412:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801419:	8b 45 10             	mov    0x10(%ebp),%eax
  80141c:	01 d0                	add    %edx,%eax
  80141e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  801424:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <str2lower>:


char* str2lower(char *dst, const char *src)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	panic("str2lower is not implemented yet!");
  801431:	83 ec 04             	sub    $0x4,%esp
  801434:	68 48 44 80 00       	push   $0x804448
  801439:	68 3f 01 00 00       	push   $0x13f
  80143e:	68 6a 44 80 00       	push   $0x80446a
  801443:	e8 a9 ef ff ff       	call   8003f1 <_panic>

00801448 <sbrk>:
//=============================================
// [1] CHANGE THE BREAK LIMIT OF THE USER HEAP:
//=============================================
/*2023*/
void* sbrk(int increment)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 08             	sub    $0x8,%esp
	return (void*) sys_sbrk(increment);
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	ff 75 08             	pushl  0x8(%ebp)
  801454:	e8 f8 0a 00 00       	call   801f51 <sys_sbrk>
  801459:	83 c4 10             	add    $0x10,%esp
}
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <malloc>:
	if(pt_get_page_permissions(ptr_page_directory,virtual_address) & PERM_AVAILABLE)return 1;
	//if(virtual_address&PERM_AVAILABLE) return 1;
	return 0;
}*/
void* malloc(uint32 size)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 38             	sub    $0x38,%esp
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
  801464:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801468:	75 0a                	jne    801474 <malloc+0x16>
  80146a:	b8 00 00 00 00       	mov    $0x0,%eax
  80146f:	e9 07 02 00 00       	jmp    80167b <malloc+0x21d>
	// Write your code here, remove the panic and write your code
//	panic("malloc() is not implemented yet...!!");
//	return NULL;
	//Use sys_isUHeapPlacementStrategyFIRSTFIT() and	sys_isUHeapPlacementStrategyBESTFIT()
	//to check the current strategy
	uint32 num_pages = ROUNDUP(size ,PAGE_SIZE) / PAGE_SIZE;
  801474:	c7 45 dc 00 10 00 00 	movl   $0x1000,-0x24(%ebp)
  80147b:	8b 55 08             	mov    0x8(%ebp),%edx
  80147e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801481:	01 d0                	add    %edx,%eax
  801483:	48                   	dec    %eax
  801484:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801487:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80148a:	ba 00 00 00 00       	mov    $0x0,%edx
  80148f:	f7 75 dc             	divl   -0x24(%ebp)
  801492:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801495:	29 d0                	sub    %edx,%eax
  801497:	c1 e8 0c             	shr    $0xc,%eax
  80149a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	uint32 max_no_of_pages = ROUNDDOWN((uint32)USER_HEAP_MAX - (myEnv->heap_hard_limit + (uint32)PAGE_SIZE) ,PAGE_SIZE) / PAGE_SIZE;
  80149d:	a1 20 50 80 00       	mov    0x805020,%eax
  8014a2:	8b 40 78             	mov    0x78(%eax),%eax
  8014a5:	ba 00 f0 ff 9f       	mov    $0x9ffff000,%edx
  8014aa:	29 c2                	sub    %eax,%edx
  8014ac:	89 d0                	mov    %edx,%eax
  8014ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8014b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8014b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014b9:	c1 e8 0c             	shr    $0xc,%eax
  8014bc:	89 45 cc             	mov    %eax,-0x34(%ebp)
	void *ptr = NULL;
  8014bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	if (size <= DYN_ALLOC_MAX_BLOCK_SIZE)
  8014c6:	81 7d 08 00 08 00 00 	cmpl   $0x800,0x8(%ebp)
  8014cd:	77 42                	ja     801511 <malloc+0xb3>
	{
		if (sys_isUHeapPlacementStrategyFIRSTFIT())
  8014cf:	e8 01 09 00 00       	call   801dd5 <sys_isUHeapPlacementStrategyFIRSTFIT>
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	74 16                	je     8014ee <malloc+0x90>
		{
			
			ptr = alloc_block_FF(size);
  8014d8:	83 ec 0c             	sub    $0xc,%esp
  8014db:	ff 75 08             	pushl  0x8(%ebp)
  8014de:	e8 dd 0e 00 00       	call   8023c0 <alloc_block_FF>
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8014e9:	e9 8a 01 00 00       	jmp    801678 <malloc+0x21a>
		}
		else if (sys_isUHeapPlacementStrategyBESTFIT())
  8014ee:	e8 13 09 00 00       	call   801e06 <sys_isUHeapPlacementStrategyBESTFIT>
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	0f 84 7d 01 00 00    	je     801678 <malloc+0x21a>
			ptr = alloc_block_BF(size);
  8014fb:	83 ec 0c             	sub    $0xc,%esp
  8014fe:	ff 75 08             	pushl  0x8(%ebp)
  801501:	e8 76 13 00 00       	call   80287c <alloc_block_BF>
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80150c:	e9 67 01 00 00       	jmp    801678 <malloc+0x21a>
	}
	else if(num_pages < max_no_of_pages-1) // the else statement in kern/mem/kheap.c/kmalloc is wrong, rewrite it to be correct.
  801511:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801514:	48                   	dec    %eax
  801515:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  801518:	0f 86 53 01 00 00    	jbe    801671 <malloc+0x213>
	{
		
		uint32 i = myEnv->heap_hard_limit + PAGE_SIZE;											// start: hardlimit + 4  ______ end: KERNEL_HEAP_MAX
  80151e:	a1 20 50 80 00       	mov    0x805020,%eax
  801523:	8b 40 78             	mov    0x78(%eax),%eax
  801526:	05 00 10 00 00       	add    $0x1000,%eax
  80152b:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bool ok = 0;
  80152e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		while (i < (uint32)USER_HEAP_MAX)
  801535:	e9 de 00 00 00       	jmp    801618 <malloc+0x1ba>
		{
			
			if (!isPageMarked[UHEAP_PAGE_INDEX(i)])
  80153a:	a1 20 50 80 00       	mov    0x805020,%eax
  80153f:	8b 40 78             	mov    0x78(%eax),%eax
  801542:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801545:	29 c2                	sub    %eax,%edx
  801547:	89 d0                	mov    %edx,%eax
  801549:	2d 00 10 00 00       	sub    $0x1000,%eax
  80154e:	c1 e8 0c             	shr    $0xc,%eax
  801551:	8b 04 85 60 50 88 00 	mov    0x885060(,%eax,4),%eax
  801558:	85 c0                	test   %eax,%eax
  80155a:	0f 85 ab 00 00 00    	jne    80160b <malloc+0x1ad>
			{
				
				uint32 j = i + (uint32)PAGE_SIZE;
  801560:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801563:	05 00 10 00 00       	add    $0x1000,%eax
  801568:	89 45 e8             	mov    %eax,-0x18(%ebp)
				uint32 cnt = 0;
  80156b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

				
				while(cnt < num_pages - 1)
  801572:	eb 47                	jmp    8015bb <malloc+0x15d>
				{
					if(j >= (uint32)USER_HEAP_MAX) return NULL;
  801574:	81 7d e8 ff ff ff 9f 	cmpl   $0x9fffffff,-0x18(%ebp)
  80157b:	76 0a                	jbe    801587 <malloc+0x129>
  80157d:	b8 00 00 00 00       	mov    $0x0,%eax
  801582:	e9 f4 00 00 00       	jmp    80167b <malloc+0x21d>
					if (isPageMarked[UHEAP_PAGE_INDEX(j)])
  801587:	a1 20 50 80 00       	mov    0x805020,%eax
  80158c:	8b 40 78             	mov    0x78(%eax),%eax
  80158f:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801592:	29 c2                	sub    %eax,%edx
  801594:	89 d0                	mov    %edx,%eax
  801596:	2d 00 10 00 00       	sub    $0x1000,%eax
  80159b:	c1 e8 0c             	shr    $0xc,%eax
  80159e:	8b 04 85 60 50 88 00 	mov    0x885060(,%eax,4),%eax
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	74 08                	je     8015b1 <malloc+0x153>
					{
						
						i = j;
  8015a9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8015ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
						goto sayed;
  8015af:	eb 5a                	jmp    80160b <malloc+0x1ad>
					}

					j += (uint32)PAGE_SIZE; // <-- changed, was j ++
  8015b1:	81 45 e8 00 10 00 00 	addl   $0x1000,-0x18(%ebp)

					cnt++;
  8015b8:	ff 45 e4             	incl   -0x1c(%ebp)
				
				uint32 j = i + (uint32)PAGE_SIZE;
				uint32 cnt = 0;

				
				while(cnt < num_pages - 1)
  8015bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015be:	48                   	dec    %eax
  8015bf:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8015c2:	77 b0                	ja     801574 <malloc+0x116>

					j += (uint32)PAGE_SIZE; // <-- changed, was j ++

					cnt++;
				}
				ok = 1;
  8015c4:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
				for(int k = 0;k<num_pages;k++)
  8015cb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8015d2:	eb 2f                	jmp    801603 <malloc+0x1a5>
				{
					isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+i)]=1;
  8015d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015d7:	c1 e0 0c             	shl    $0xc,%eax
  8015da:	89 c2                	mov    %eax,%edx
  8015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015df:	01 c2                	add    %eax,%edx
  8015e1:	a1 20 50 80 00       	mov    0x805020,%eax
  8015e6:	8b 40 78             	mov    0x78(%eax),%eax
  8015e9:	29 c2                	sub    %eax,%edx
  8015eb:	89 d0                	mov    %edx,%eax
  8015ed:	2d 00 10 00 00       	sub    $0x1000,%eax
  8015f2:	c1 e8 0c             	shr    $0xc,%eax
  8015f5:	c7 04 85 60 50 88 00 	movl   $0x1,0x885060(,%eax,4)
  8015fc:	01 00 00 00 
					j += (uint32)PAGE_SIZE; // <-- changed, was j ++

					cnt++;
				}
				ok = 1;
				for(int k = 0;k<num_pages;k++)
  801600:	ff 45 e0             	incl   -0x20(%ebp)
  801603:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801606:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  801609:	72 c9                	jb     8015d4 <malloc+0x176>
				}
				

			}
			sayed:
			if(ok) break;
  80160b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80160f:	75 16                	jne    801627 <malloc+0x1c9>
			i += (uint32)PAGE_SIZE;
  801611:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
	else if(num_pages < max_no_of_pages-1) // the else statement in kern/mem/kheap.c/kmalloc is wrong, rewrite it to be correct.
	{
		
		uint32 i = myEnv->heap_hard_limit + PAGE_SIZE;											// start: hardlimit + 4  ______ end: KERNEL_HEAP_MAX
		bool ok = 0;
		while (i < (uint32)USER_HEAP_MAX)
  801618:	81 7d f0 ff ff ff 9f 	cmpl   $0x9fffffff,-0x10(%ebp)
  80161f:	0f 86 15 ff ff ff    	jbe    80153a <malloc+0xdc>
  801625:	eb 01                	jmp    801628 <malloc+0x1ca>
				}
				

			}
			sayed:
			if(ok) break;
  801627:	90                   	nop
			i += (uint32)PAGE_SIZE;
		}

		if(!ok) return NULL;
  801628:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80162c:	75 07                	jne    801635 <malloc+0x1d7>
  80162e:	b8 00 00 00 00       	mov    $0x0,%eax
  801633:	eb 46                	jmp    80167b <malloc+0x21d>
		ptr = (void*)i;
  801635:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801638:	89 45 f4             	mov    %eax,-0xc(%ebp)
		no_pages_marked[UHEAP_PAGE_INDEX(i)] = num_pages;
  80163b:	a1 20 50 80 00       	mov    0x805020,%eax
  801640:	8b 40 78             	mov    0x78(%eax),%eax
  801643:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801646:	29 c2                	sub    %eax,%edx
  801648:	89 d0                	mov    %edx,%eax
  80164a:	2d 00 10 00 00       	sub    $0x1000,%eax
  80164f:	c1 e8 0c             	shr    $0xc,%eax
  801652:	89 c2                	mov    %eax,%edx
  801654:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801657:	89 04 95 60 50 90 00 	mov    %eax,0x905060(,%edx,4)
		sys_allocate_user_mem(i, size);
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	ff 75 08             	pushl  0x8(%ebp)
  801664:	ff 75 f0             	pushl  -0x10(%ebp)
  801667:	e8 1c 09 00 00       	call   801f88 <sys_allocate_user_mem>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	eb 07                	jmp    801678 <malloc+0x21a>
		
	}
	else
	{
		return NULL;
  801671:	b8 00 00 00 00       	mov    $0x0,%eax
  801676:	eb 03                	jmp    80167b <malloc+0x21d>
	}
	return ptr;
  801678:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <free>:

//=================================
// [3] FREE SPACE FROM USER HEAP:
//=================================
void free(void* va)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 18             	sub    $0x18,%esp
	//TODO: [PROJECT'24.MS2 - #14] [3] USER HEAP [USER SIDE] - free()
	// Write your code here, remove the panic and write your code
//	panic("free() is not implemented yet...!!");
	//what's the hard_limit of user heap
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
  801683:	a1 20 50 80 00       	mov    0x805020,%eax
  801688:	8b 40 78             	mov    0x78(%eax),%eax
  80168b:	05 00 10 00 00       	add    $0x1000,%eax
  801690:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 size = 0;
  801693:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	if((uint32)va < myEnv->heap_hard_limit){
  80169a:	a1 20 50 80 00       	mov    0x805020,%eax
  80169f:	8b 50 78             	mov    0x78(%eax),%edx
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	39 c2                	cmp    %eax,%edx
  8016a7:	76 24                	jbe    8016cd <free+0x50>
		size = get_block_size(va);
  8016a9:	83 ec 0c             	sub    $0xc,%esp
  8016ac:	ff 75 08             	pushl  0x8(%ebp)
  8016af:	e8 8c 09 00 00       	call   802040 <get_block_size>
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
		free_block(va);
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 9c 1b 00 00       	call   803261 <free_block>
  8016c5:	83 c4 10             	add    $0x10,%esp
		}

	} else{
		panic("User free: The virtual Address is invalid");
	}
}
  8016c8:	e9 ac 00 00 00       	jmp    801779 <free+0xfc>
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
	uint32 size = 0;
	if((uint32)va < myEnv->heap_hard_limit){
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
  8016cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8016d3:	0f 82 89 00 00 00    	jb     801762 <free+0xe5>
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	3d ff ff ff 9f       	cmp    $0x9fffffff,%eax
  8016e1:	77 7f                	ja     801762 <free+0xe5>
		uint32 no_of_pages = no_pages_marked[UHEAP_PAGE_INDEX((uint32)va)];
  8016e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e6:	a1 20 50 80 00       	mov    0x805020,%eax
  8016eb:	8b 40 78             	mov    0x78(%eax),%eax
  8016ee:	29 c2                	sub    %eax,%edx
  8016f0:	89 d0                	mov    %edx,%eax
  8016f2:	2d 00 10 00 00       	sub    $0x1000,%eax
  8016f7:	c1 e8 0c             	shr    $0xc,%eax
  8016fa:	8b 04 85 60 50 90 00 	mov    0x905060(,%eax,4),%eax
  801701:	89 45 e8             	mov    %eax,-0x18(%ebp)
		size = no_of_pages * PAGE_SIZE;
  801704:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801707:	c1 e0 0c             	shl    $0xc,%eax
  80170a:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for(int k = 0;k<no_of_pages;k++)
  80170d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801714:	eb 42                	jmp    801758 <free+0xdb>
		{
			isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+(uint32)va)]=0;
  801716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801719:	c1 e0 0c             	shl    $0xc,%eax
  80171c:	89 c2                	mov    %eax,%edx
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	01 c2                	add    %eax,%edx
  801723:	a1 20 50 80 00       	mov    0x805020,%eax
  801728:	8b 40 78             	mov    0x78(%eax),%eax
  80172b:	29 c2                	sub    %eax,%edx
  80172d:	89 d0                	mov    %edx,%eax
  80172f:	2d 00 10 00 00       	sub    $0x1000,%eax
  801734:	c1 e8 0c             	shr    $0xc,%eax
  801737:	c7 04 85 60 50 88 00 	movl   $0x0,0x885060(,%eax,4)
  80173e:	00 00 00 00 
			sys_free_user_mem((uint32)va, k);
  801742:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801745:	8b 45 08             	mov    0x8(%ebp),%eax
  801748:	83 ec 08             	sub    $0x8,%esp
  80174b:	52                   	push   %edx
  80174c:	50                   	push   %eax
  80174d:	e8 1a 08 00 00       	call   801f6c <sys_free_user_mem>
  801752:	83 c4 10             	add    $0x10,%esp
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
		uint32 no_of_pages = no_pages_marked[UHEAP_PAGE_INDEX((uint32)va)];
		size = no_of_pages * PAGE_SIZE;
		for(int k = 0;k<no_of_pages;k++)
  801755:	ff 45 f4             	incl   -0xc(%ebp)
  801758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175b:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  80175e:	72 b6                	jb     801716 <free+0x99>
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
	uint32 size = 0;
	if((uint32)va < myEnv->heap_hard_limit){
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
  801760:	eb 17                	jmp    801779 <free+0xfc>
			isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+(uint32)va)]=0;
			sys_free_user_mem((uint32)va, k);
		}

	} else{
		panic("User free: The virtual Address is invalid");
  801762:	83 ec 04             	sub    $0x4,%esp
  801765:	68 78 44 80 00       	push   $0x804478
  80176a:	68 87 00 00 00       	push   $0x87
  80176f:	68 a2 44 80 00       	push   $0x8044a2
  801774:	e8 78 ec ff ff       	call   8003f1 <_panic>
	}
}
  801779:	90                   	nop
  80177a:	c9                   	leave  
  80177b:	c3                   	ret    

0080177c <smalloc>:

//=================================
// [4] ALLOCATE SHARED VARIABLE:
//=================================
void* smalloc(char *sharedVarName, uint32 size, uint8 isWritable)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	83 ec 28             	sub    $0x28,%esp
  801782:	8b 45 10             	mov    0x10(%ebp),%eax
  801785:	88 45 e4             	mov    %al,-0x1c(%ebp)
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
  801788:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80178c:	75 0a                	jne    801798 <smalloc+0x1c>
  80178e:	b8 00 00 00 00       	mov    $0x0,%eax
  801793:	e9 87 00 00 00       	jmp    80181f <smalloc+0xa3>
	//==============================================================
	//TODO: [PROJECT'24.MS2 - #18] [4] SHARED MEMORY [USER SIDE] - smalloc()
	// Write your code here, remove the panic and write your code
	//panic("smalloc() is not implemented yet...!!");

	void *ptr = malloc(MAX(size,PAGE_SIZE));
  801798:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80179e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  8017a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ab:	39 d0                	cmp    %edx,%eax
  8017ad:	73 02                	jae    8017b1 <smalloc+0x35>
  8017af:	89 d0                	mov    %edx,%eax
  8017b1:	83 ec 0c             	sub    $0xc,%esp
  8017b4:	50                   	push   %eax
  8017b5:	e8 a4 fc ff ff       	call   80145e <malloc>
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(ptr == NULL) return NULL;
  8017c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8017c4:	75 07                	jne    8017cd <smalloc+0x51>
  8017c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cb:	eb 52                	jmp    80181f <smalloc+0xa3>
	 int32 ret = sys_createSharedObject(sharedVarName, size,  isWritable, ptr);
  8017cd:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
  8017d1:	ff 75 ec             	pushl  -0x14(%ebp)
  8017d4:	50                   	push   %eax
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	ff 75 08             	pushl  0x8(%ebp)
  8017db:	e8 93 03 00 00       	call   801b73 <sys_createSharedObject>
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	89 45 e8             	mov    %eax,-0x18(%ebp)
	 if(ret == E_NO_SHARE || ret == E_SHARED_MEM_EXISTS) return NULL;
  8017e6:	83 7d e8 f2          	cmpl   $0xfffffff2,-0x18(%ebp)
  8017ea:	74 06                	je     8017f2 <smalloc+0x76>
  8017ec:	83 7d e8 f1          	cmpl   $0xfffffff1,-0x18(%ebp)
  8017f0:	75 07                	jne    8017f9 <smalloc+0x7d>
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f7:	eb 26                	jmp    80181f <smalloc+0xa3>
	 //cprintf("Smalloc : %x \n",ptr);


	 ids[UHEAP_PAGE_INDEX((uint32)ptr)] =  ret;
  8017f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8017fc:	a1 20 50 80 00       	mov    0x805020,%eax
  801801:	8b 40 78             	mov    0x78(%eax),%eax
  801804:	29 c2                	sub    %eax,%edx
  801806:	89 d0                	mov    %edx,%eax
  801808:	2d 00 10 00 00       	sub    $0x1000,%eax
  80180d:	c1 e8 0c             	shr    $0xc,%eax
  801810:	89 c2                	mov    %eax,%edx
  801812:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801815:	89 04 95 60 50 80 00 	mov    %eax,0x805060(,%edx,4)
	 return ptr;
  80181c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <sget>:

//========================================
// [5] SHARE ON ALLOCATED SHARED VARIABLE:
//========================================
void* sget(int32 ownerEnvID, char *sharedVarName)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 28             	sub    $0x28,%esp
	//TODO: [PROJECT'24.MS2 - #20] [4] SHARED MEMORY [USER SIDE] - sget()
	// Write your code here, remove the panic and write your code
	//panic("sget() is not implemented yet...!!");
	uint32 size = sys_getSizeOfSharedObject(ownerEnvID,sharedVarName);
  801827:	83 ec 08             	sub    $0x8,%esp
  80182a:	ff 75 0c             	pushl  0xc(%ebp)
  80182d:	ff 75 08             	pushl  0x8(%ebp)
  801830:	e8 68 03 00 00       	call   801b9d <sys_getSizeOfSharedObject>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(size == E_SHARED_MEM_NOT_EXISTS) return NULL;
  80183b:	83 7d f4 f0          	cmpl   $0xfffffff0,-0xc(%ebp)
  80183f:	75 07                	jne    801848 <sget+0x27>
  801841:	b8 00 00 00 00       	mov    $0x0,%eax
  801846:	eb 7f                	jmp    8018c7 <sget+0xa6>
	void * ptr = malloc(MAX(size,PAGE_SIZE));
  801848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80184e:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
  801855:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185b:	39 d0                	cmp    %edx,%eax
  80185d:	73 02                	jae    801861 <sget+0x40>
  80185f:	89 d0                	mov    %edx,%eax
  801861:	83 ec 0c             	sub    $0xc,%esp
  801864:	50                   	push   %eax
  801865:	e8 f4 fb ff ff       	call   80145e <malloc>
  80186a:	83 c4 10             	add    $0x10,%esp
  80186d:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if(ptr == NULL) return NULL;
  801870:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801874:	75 07                	jne    80187d <sget+0x5c>
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
  80187b:	eb 4a                	jmp    8018c7 <sget+0xa6>
	int32 ret = sys_getSharedObject(ownerEnvID,sharedVarName,ptr);
  80187d:	83 ec 04             	sub    $0x4,%esp
  801880:	ff 75 e8             	pushl  -0x18(%ebp)
  801883:	ff 75 0c             	pushl  0xc(%ebp)
  801886:	ff 75 08             	pushl  0x8(%ebp)
  801889:	e8 2c 03 00 00       	call   801bba <sys_getSharedObject>
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ids[UHEAP_PAGE_INDEX((uint32)ptr)] =  ret;
  801894:	8b 55 e8             	mov    -0x18(%ebp),%edx
  801897:	a1 20 50 80 00       	mov    0x805020,%eax
  80189c:	8b 40 78             	mov    0x78(%eax),%eax
  80189f:	29 c2                	sub    %eax,%edx
  8018a1:	89 d0                	mov    %edx,%eax
  8018a3:	2d 00 10 00 00       	sub    $0x1000,%eax
  8018a8:	c1 e8 0c             	shr    $0xc,%eax
  8018ab:	89 c2                	mov    %eax,%edx
  8018ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b0:	89 04 95 60 50 80 00 	mov    %eax,0x805060(,%edx,4)
	
	if(ret == E_SHARED_MEM_NOT_EXISTS ) return NULL;
  8018b7:	83 7d e4 f0          	cmpl   $0xfffffff0,-0x1c(%ebp)
  8018bb:	75 07                	jne    8018c4 <sget+0xa3>
  8018bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c2:	eb 03                	jmp    8018c7 <sget+0xa6>
	return ptr;
  8018c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <sfree>:
//	use sys_freeSharedObject(...); which switches to the kernel mode,
//	calls freeSharedObject(...) in "shared_memory_manager.c", then switch back to the user mode here
//	the freeSharedObject() function is empty, make sure to implement it.

void sfree(void* virtual_address)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	83 ec 18             	sub    $0x18,%esp
    //TODO: [PROJECT'24.MS2 - BONUS#4] [4] SHARED MEMORY [USER SIDE] - sfree()
    // Write your code here, remove the panic and write your code
//    panic("sfree() is not implemented yet...!!");
	int32 id = ids[UHEAP_PAGE_INDEX((uint32)virtual_address)];
  8018cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8018d2:	a1 20 50 80 00       	mov    0x805020,%eax
  8018d7:	8b 40 78             	mov    0x78(%eax),%eax
  8018da:	29 c2                	sub    %eax,%edx
  8018dc:	89 d0                	mov    %edx,%eax
  8018de:	2d 00 10 00 00       	sub    $0x1000,%eax
  8018e3:	c1 e8 0c             	shr    $0xc,%eax
  8018e6:	8b 04 85 60 50 80 00 	mov    0x805060(,%eax,4),%eax
  8018ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int ret = sys_freeSharedObject(id,virtual_address);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	ff 75 08             	pushl  0x8(%ebp)
  8018f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f9:	e8 db 02 00 00       	call   801bd9 <sys_freeSharedObject>
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	89 45 f0             	mov    %eax,-0x10(%ebp)
}
  801904:	90                   	nop
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <realloc>:
//  Hint: you may need to use the sys_move_user_mem(...)
//		which switches to the kernel mode, calls move_user_mem(...)
//		in "kern/mem/chunk_operations.c", then switch back to the user mode here
//	the move_user_mem() function is empty, make sure to implement it.
void *realloc(void *virtual_address, uint32 new_size)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	// Write your code here, remove the panic and write your code
	panic("realloc() is not implemented yet...!!");
  80190d:	83 ec 04             	sub    $0x4,%esp
  801910:	68 b0 44 80 00       	push   $0x8044b0
  801915:	68 e4 00 00 00       	push   $0xe4
  80191a:	68 a2 44 80 00       	push   $0x8044a2
  80191f:	e8 cd ea ff ff       	call   8003f1 <_panic>

00801924 <expand>:
//==================================================================================//
//========================== MODIFICATION FUNCTIONS ================================//
//==================================================================================//

void expand(uint32 newSize)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  80192a:	83 ec 04             	sub    $0x4,%esp
  80192d:	68 d6 44 80 00       	push   $0x8044d6
  801932:	68 f0 00 00 00       	push   $0xf0
  801937:	68 a2 44 80 00       	push   $0x8044a2
  80193c:	e8 b0 ea ff ff       	call   8003f1 <_panic>

00801941 <shrink>:

}
void shrink(uint32 newSize)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  801947:	83 ec 04             	sub    $0x4,%esp
  80194a:	68 d6 44 80 00       	push   $0x8044d6
  80194f:	68 f5 00 00 00       	push   $0xf5
  801954:	68 a2 44 80 00       	push   $0x8044a2
  801959:	e8 93 ea ff ff       	call   8003f1 <_panic>

0080195e <freeHeap>:

}
void freeHeap(void* virtual_address)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	68 d6 44 80 00       	push   $0x8044d6
  80196c:	68 fa 00 00 00       	push   $0xfa
  801971:	68 a2 44 80 00       	push   $0x8044a2
  801976:	e8 76 ea ff ff       	call   8003f1 <_panic>

0080197b <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  80197b:	55                   	push   %ebp
  80197c:	89 e5                	mov    %esp,%ebp
  80197e:	57                   	push   %edi
  80197f:	56                   	push   %esi
  801980:	53                   	push   %ebx
  801981:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801984:	8b 45 08             	mov    0x8(%ebp),%eax
  801987:	8b 55 0c             	mov    0xc(%ebp),%edx
  80198a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80198d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801990:	8b 7d 18             	mov    0x18(%ebp),%edi
  801993:	8b 75 1c             	mov    0x1c(%ebp),%esi
  801996:	cd 30                	int    $0x30
  801998:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  80199b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	5b                   	pop    %ebx
  8019a2:	5e                   	pop    %esi
  8019a3:	5f                   	pop    %edi
  8019a4:	5d                   	pop    %ebp
  8019a5:	c3                   	ret    

008019a6 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  8019a6:	55                   	push   %ebp
  8019a7:	89 e5                	mov    %esp,%ebp
  8019a9:	83 ec 04             	sub    $0x4,%esp
  8019ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8019af:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  8019b2:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  8019b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b9:	6a 00                	push   $0x0
  8019bb:	6a 00                	push   $0x0
  8019bd:	52                   	push   %edx
  8019be:	ff 75 0c             	pushl  0xc(%ebp)
  8019c1:	50                   	push   %eax
  8019c2:	6a 00                	push   $0x0
  8019c4:	e8 b2 ff ff ff       	call   80197b <syscall>
  8019c9:	83 c4 18             	add    $0x18,%esp
}
  8019cc:	90                   	nop
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <sys_cgetc>:

int
sys_cgetc(void)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  8019d2:	6a 00                	push   $0x0
  8019d4:	6a 00                	push   $0x0
  8019d6:	6a 00                	push   $0x0
  8019d8:	6a 00                	push   $0x0
  8019da:	6a 00                	push   $0x0
  8019dc:	6a 02                	push   $0x2
  8019de:	e8 98 ff ff ff       	call   80197b <syscall>
  8019e3:	83 c4 18             	add    $0x18,%esp
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <sys_lock_cons>:

void sys_lock_cons(void)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
	syscall(SYS_lock_cons, 0, 0, 0, 0, 0);
  8019eb:	6a 00                	push   $0x0
  8019ed:	6a 00                	push   $0x0
  8019ef:	6a 00                	push   $0x0
  8019f1:	6a 00                	push   $0x0
  8019f3:	6a 00                	push   $0x0
  8019f5:	6a 03                	push   $0x3
  8019f7:	e8 7f ff ff ff       	call   80197b <syscall>
  8019fc:	83 c4 18             	add    $0x18,%esp
}
  8019ff:	90                   	nop
  801a00:	c9                   	leave  
  801a01:	c3                   	ret    

00801a02 <sys_unlock_cons>:
void sys_unlock_cons(void)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
	syscall(SYS_unlock_cons, 0, 0, 0, 0, 0);
  801a05:	6a 00                	push   $0x0
  801a07:	6a 00                	push   $0x0
  801a09:	6a 00                	push   $0x0
  801a0b:	6a 00                	push   $0x0
  801a0d:	6a 00                	push   $0x0
  801a0f:	6a 04                	push   $0x4
  801a11:	e8 65 ff ff ff       	call   80197b <syscall>
  801a16:	83 c4 18             	add    $0x18,%esp
}
  801a19:	90                   	nop
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  801a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a22:	8b 45 08             	mov    0x8(%ebp),%eax
  801a25:	6a 00                	push   $0x0
  801a27:	6a 00                	push   $0x0
  801a29:	6a 00                	push   $0x0
  801a2b:	52                   	push   %edx
  801a2c:	50                   	push   %eax
  801a2d:	6a 08                	push   $0x8
  801a2f:	e8 47 ff ff ff       	call   80197b <syscall>
  801a34:	83 c4 18             	add    $0x18,%esp
}
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  801a3e:	8b 75 18             	mov    0x18(%ebp),%esi
  801a41:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801a44:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4d:	56                   	push   %esi
  801a4e:	53                   	push   %ebx
  801a4f:	51                   	push   %ecx
  801a50:	52                   	push   %edx
  801a51:	50                   	push   %eax
  801a52:	6a 09                	push   $0x9
  801a54:	e8 22 ff ff ff       	call   80197b <syscall>
  801a59:	83 c4 18             	add    $0x18,%esp
}
  801a5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5f:	5b                   	pop    %ebx
  801a60:	5e                   	pop    %esi
  801a61:	5d                   	pop    %ebp
  801a62:	c3                   	ret    

00801a63 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801a66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	6a 00                	push   $0x0
  801a6e:	6a 00                	push   $0x0
  801a70:	6a 00                	push   $0x0
  801a72:	52                   	push   %edx
  801a73:	50                   	push   %eax
  801a74:	6a 0a                	push   $0xa
  801a76:	e8 00 ff ff ff       	call   80197b <syscall>
  801a7b:	83 c4 18             	add    $0x18,%esp
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  801a83:	6a 00                	push   $0x0
  801a85:	6a 00                	push   $0x0
  801a87:	6a 00                	push   $0x0
  801a89:	ff 75 0c             	pushl  0xc(%ebp)
  801a8c:	ff 75 08             	pushl  0x8(%ebp)
  801a8f:	6a 0b                	push   $0xb
  801a91:	e8 e5 fe ff ff       	call   80197b <syscall>
  801a96:	83 c4 18             	add    $0x18,%esp
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  801a9e:	6a 00                	push   $0x0
  801aa0:	6a 00                	push   $0x0
  801aa2:	6a 00                	push   $0x0
  801aa4:	6a 00                	push   $0x0
  801aa6:	6a 00                	push   $0x0
  801aa8:	6a 0c                	push   $0xc
  801aaa:	e8 cc fe ff ff       	call   80197b <syscall>
  801aaf:	83 c4 18             	add    $0x18,%esp
}
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  801ab7:	6a 00                	push   $0x0
  801ab9:	6a 00                	push   $0x0
  801abb:	6a 00                	push   $0x0
  801abd:	6a 00                	push   $0x0
  801abf:	6a 00                	push   $0x0
  801ac1:	6a 0d                	push   $0xd
  801ac3:	e8 b3 fe ff ff       	call   80197b <syscall>
  801ac8:	83 c4 18             	add    $0x18,%esp
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  801ad0:	6a 00                	push   $0x0
  801ad2:	6a 00                	push   $0x0
  801ad4:	6a 00                	push   $0x0
  801ad6:	6a 00                	push   $0x0
  801ad8:	6a 00                	push   $0x0
  801ada:	6a 0e                	push   $0xe
  801adc:	e8 9a fe ff ff       	call   80197b <syscall>
  801ae1:	83 c4 18             	add    $0x18,%esp
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <sys_pf_calculate_allocated_pages>:

int sys_pf_calculate_allocated_pages()
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  801ae9:	6a 00                	push   $0x0
  801aeb:	6a 00                	push   $0x0
  801aed:	6a 00                	push   $0x0
  801aef:	6a 00                	push   $0x0
  801af1:	6a 00                	push   $0x0
  801af3:	6a 0f                	push   $0xf
  801af5:	e8 81 fe ff ff       	call   80197b <syscall>
  801afa:	83 c4 18             	add    $0x18,%esp
}
  801afd:	c9                   	leave  
  801afe:	c3                   	ret    

00801aff <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  801b02:	6a 00                	push   $0x0
  801b04:	6a 00                	push   $0x0
  801b06:	6a 00                	push   $0x0
  801b08:	6a 00                	push   $0x0
  801b0a:	ff 75 08             	pushl  0x8(%ebp)
  801b0d:	6a 10                	push   $0x10
  801b0f:	e8 67 fe ff ff       	call   80197b <syscall>
  801b14:	83 c4 18             	add    $0x18,%esp
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <sys_scarce_memory>:

void sys_scarce_memory()
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  801b1c:	6a 00                	push   $0x0
  801b1e:	6a 00                	push   $0x0
  801b20:	6a 00                	push   $0x0
  801b22:	6a 00                	push   $0x0
  801b24:	6a 00                	push   $0x0
  801b26:	6a 11                	push   $0x11
  801b28:	e8 4e fe ff ff       	call   80197b <syscall>
  801b2d:	83 c4 18             	add    $0x18,%esp
}
  801b30:	90                   	nop
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <sys_cputc>:

void
sys_cputc(const char c)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 04             	sub    $0x4,%esp
  801b39:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3c:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801b3f:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801b43:	6a 00                	push   $0x0
  801b45:	6a 00                	push   $0x0
  801b47:	6a 00                	push   $0x0
  801b49:	6a 00                	push   $0x0
  801b4b:	50                   	push   %eax
  801b4c:	6a 01                	push   $0x1
  801b4e:	e8 28 fe ff ff       	call   80197b <syscall>
  801b53:	83 c4 18             	add    $0x18,%esp
}
  801b56:	90                   	nop
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  801b5c:	6a 00                	push   $0x0
  801b5e:	6a 00                	push   $0x0
  801b60:	6a 00                	push   $0x0
  801b62:	6a 00                	push   $0x0
  801b64:	6a 00                	push   $0x0
  801b66:	6a 14                	push   $0x14
  801b68:	e8 0e fe ff ff       	call   80197b <syscall>
  801b6d:	83 c4 18             	add    $0x18,%esp
}
  801b70:	90                   	nop
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <sys_createSharedObject>:

int sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 04             	sub    $0x4,%esp
  801b79:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7c:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801b7f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801b82:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	6a 00                	push   $0x0
  801b8b:	51                   	push   %ecx
  801b8c:	52                   	push   %edx
  801b8d:	ff 75 0c             	pushl  0xc(%ebp)
  801b90:	50                   	push   %eax
  801b91:	6a 15                	push   $0x15
  801b93:	e8 e3 fd ff ff       	call   80197b <syscall>
  801b98:	83 c4 18             	add    $0x18,%esp
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <sys_getSizeOfSharedObject>:

//2017:
int sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  801ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba6:	6a 00                	push   $0x0
  801ba8:	6a 00                	push   $0x0
  801baa:	6a 00                	push   $0x0
  801bac:	52                   	push   %edx
  801bad:	50                   	push   %eax
  801bae:	6a 16                	push   $0x16
  801bb0:	e8 c6 fd ff ff       	call   80197b <syscall>
  801bb5:	83 c4 18             	add    $0x18,%esp
}
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <sys_getSharedObject>:
//==========

int sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  801bbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc6:	6a 00                	push   $0x0
  801bc8:	6a 00                	push   $0x0
  801bca:	51                   	push   %ecx
  801bcb:	52                   	push   %edx
  801bcc:	50                   	push   %eax
  801bcd:	6a 17                	push   $0x17
  801bcf:	e8 a7 fd ff ff       	call   80197b <syscall>
  801bd4:	83 c4 18             	add    $0x18,%esp
}
  801bd7:	c9                   	leave  
  801bd8:	c3                   	ret    

00801bd9 <sys_freeSharedObject>:

int sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  801bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	6a 00                	push   $0x0
  801be4:	6a 00                	push   $0x0
  801be6:	6a 00                	push   $0x0
  801be8:	52                   	push   %edx
  801be9:	50                   	push   %eax
  801bea:	6a 18                	push   $0x18
  801bec:	e8 8a fd ff ff       	call   80197b <syscall>
  801bf1:	83 c4 18             	add    $0x18,%esp
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  801bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfc:	6a 00                	push   $0x0
  801bfe:	ff 75 14             	pushl  0x14(%ebp)
  801c01:	ff 75 10             	pushl  0x10(%ebp)
  801c04:	ff 75 0c             	pushl  0xc(%ebp)
  801c07:	50                   	push   %eax
  801c08:	6a 19                	push   $0x19
  801c0a:	e8 6c fd ff ff       	call   80197b <syscall>
  801c0f:	83 c4 18             	add    $0x18,%esp
}
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <sys_run_env>:

void sys_run_env(int32 envId)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  801c17:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1a:	6a 00                	push   $0x0
  801c1c:	6a 00                	push   $0x0
  801c1e:	6a 00                	push   $0x0
  801c20:	6a 00                	push   $0x0
  801c22:	50                   	push   %eax
  801c23:	6a 1a                	push   $0x1a
  801c25:	e8 51 fd ff ff       	call   80197b <syscall>
  801c2a:	83 c4 18             	add    $0x18,%esp
}
  801c2d:	90                   	nop
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
  801c36:	6a 00                	push   $0x0
  801c38:	6a 00                	push   $0x0
  801c3a:	6a 00                	push   $0x0
  801c3c:	6a 00                	push   $0x0
  801c3e:	50                   	push   %eax
  801c3f:	6a 1b                	push   $0x1b
  801c41:	e8 35 fd ff ff       	call   80197b <syscall>
  801c46:	83 c4 18             	add    $0x18,%esp
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    

00801c4b <sys_getenvid>:

int32 sys_getenvid(void)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  801c4e:	6a 00                	push   $0x0
  801c50:	6a 00                	push   $0x0
  801c52:	6a 00                	push   $0x0
  801c54:	6a 00                	push   $0x0
  801c56:	6a 00                	push   $0x0
  801c58:	6a 05                	push   $0x5
  801c5a:	e8 1c fd ff ff       	call   80197b <syscall>
  801c5f:	83 c4 18             	add    $0x18,%esp
}
  801c62:	c9                   	leave  
  801c63:	c3                   	ret    

00801c64 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  801c67:	6a 00                	push   $0x0
  801c69:	6a 00                	push   $0x0
  801c6b:	6a 00                	push   $0x0
  801c6d:	6a 00                	push   $0x0
  801c6f:	6a 00                	push   $0x0
  801c71:	6a 06                	push   $0x6
  801c73:	e8 03 fd ff ff       	call   80197b <syscall>
  801c78:	83 c4 18             	add    $0x18,%esp
}
  801c7b:	c9                   	leave  
  801c7c:	c3                   	ret    

00801c7d <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  801c80:	6a 00                	push   $0x0
  801c82:	6a 00                	push   $0x0
  801c84:	6a 00                	push   $0x0
  801c86:	6a 00                	push   $0x0
  801c88:	6a 00                	push   $0x0
  801c8a:	6a 07                	push   $0x7
  801c8c:	e8 ea fc ff ff       	call   80197b <syscall>
  801c91:	83 c4 18             	add    $0x18,%esp
}
  801c94:	c9                   	leave  
  801c95:	c3                   	ret    

00801c96 <sys_exit_env>:


void sys_exit_env(void)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  801c99:	6a 00                	push   $0x0
  801c9b:	6a 00                	push   $0x0
  801c9d:	6a 00                	push   $0x0
  801c9f:	6a 00                	push   $0x0
  801ca1:	6a 00                	push   $0x0
  801ca3:	6a 1c                	push   $0x1c
  801ca5:	e8 d1 fc ff ff       	call   80197b <syscall>
  801caa:	83 c4 18             	add    $0x18,%esp
}
  801cad:	90                   	nop
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <sys_get_virtual_time>:


struct uint64 sys_get_virtual_time()
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  801cb6:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801cb9:	8d 50 04             	lea    0x4(%eax),%edx
  801cbc:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801cbf:	6a 00                	push   $0x0
  801cc1:	6a 00                	push   $0x0
  801cc3:	6a 00                	push   $0x0
  801cc5:	52                   	push   %edx
  801cc6:	50                   	push   %eax
  801cc7:	6a 1d                	push   $0x1d
  801cc9:	e8 ad fc ff ff       	call   80197b <syscall>
  801cce:	83 c4 18             	add    $0x18,%esp
	return result;
  801cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801cd7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801cda:	89 01                	mov    %eax,(%ecx)
  801cdc:	89 51 04             	mov    %edx,0x4(%ecx)
}
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	c9                   	leave  
  801ce3:	c2 04 00             	ret    $0x4

00801ce6 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  801ce9:	6a 00                	push   $0x0
  801ceb:	6a 00                	push   $0x0
  801ced:	ff 75 10             	pushl  0x10(%ebp)
  801cf0:	ff 75 0c             	pushl  0xc(%ebp)
  801cf3:	ff 75 08             	pushl  0x8(%ebp)
  801cf6:	6a 13                	push   $0x13
  801cf8:	e8 7e fc ff ff       	call   80197b <syscall>
  801cfd:	83 c4 18             	add    $0x18,%esp
	return ;
  801d00:	90                   	nop
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <sys_rcr2>:
uint32 sys_rcr2()
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  801d06:	6a 00                	push   $0x0
  801d08:	6a 00                	push   $0x0
  801d0a:	6a 00                	push   $0x0
  801d0c:	6a 00                	push   $0x0
  801d0e:	6a 00                	push   $0x0
  801d10:	6a 1e                	push   $0x1e
  801d12:	e8 64 fc ff ff       	call   80197b <syscall>
  801d17:	83 c4 18             	add    $0x18,%esp
}
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <sys_bypassPageFault>:

void sys_bypassPageFault(uint8 instrLength)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	8b 45 08             	mov    0x8(%ebp),%eax
  801d25:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  801d28:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  801d2c:	6a 00                	push   $0x0
  801d2e:	6a 00                	push   $0x0
  801d30:	6a 00                	push   $0x0
  801d32:	6a 00                	push   $0x0
  801d34:	50                   	push   %eax
  801d35:	6a 1f                	push   $0x1f
  801d37:	e8 3f fc ff ff       	call   80197b <syscall>
  801d3c:	83 c4 18             	add    $0x18,%esp
	return ;
  801d3f:	90                   	nop
}
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <rsttst>:
void rsttst()
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  801d45:	6a 00                	push   $0x0
  801d47:	6a 00                	push   $0x0
  801d49:	6a 00                	push   $0x0
  801d4b:	6a 00                	push   $0x0
  801d4d:	6a 00                	push   $0x0
  801d4f:	6a 21                	push   $0x21
  801d51:	e8 25 fc ff ff       	call   80197b <syscall>
  801d56:	83 c4 18             	add    $0x18,%esp
	return ;
  801d59:	90                   	nop
}
  801d5a:	c9                   	leave  
  801d5b:	c3                   	ret    

00801d5c <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	83 ec 04             	sub    $0x4,%esp
  801d62:	8b 45 14             	mov    0x14(%ebp),%eax
  801d65:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  801d68:	8b 55 18             	mov    0x18(%ebp),%edx
  801d6b:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801d6f:	52                   	push   %edx
  801d70:	50                   	push   %eax
  801d71:	ff 75 10             	pushl  0x10(%ebp)
  801d74:	ff 75 0c             	pushl  0xc(%ebp)
  801d77:	ff 75 08             	pushl  0x8(%ebp)
  801d7a:	6a 20                	push   $0x20
  801d7c:	e8 fa fb ff ff       	call   80197b <syscall>
  801d81:	83 c4 18             	add    $0x18,%esp
	return ;
  801d84:	90                   	nop
}
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <chktst>:
void chktst(uint32 n)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  801d8a:	6a 00                	push   $0x0
  801d8c:	6a 00                	push   $0x0
  801d8e:	6a 00                	push   $0x0
  801d90:	6a 00                	push   $0x0
  801d92:	ff 75 08             	pushl  0x8(%ebp)
  801d95:	6a 22                	push   $0x22
  801d97:	e8 df fb ff ff       	call   80197b <syscall>
  801d9c:	83 c4 18             	add    $0x18,%esp
	return ;
  801d9f:	90                   	nop
}
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <inctst>:

void inctst()
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  801da5:	6a 00                	push   $0x0
  801da7:	6a 00                	push   $0x0
  801da9:	6a 00                	push   $0x0
  801dab:	6a 00                	push   $0x0
  801dad:	6a 00                	push   $0x0
  801daf:	6a 23                	push   $0x23
  801db1:	e8 c5 fb ff ff       	call   80197b <syscall>
  801db6:	83 c4 18             	add    $0x18,%esp
	return ;
  801db9:	90                   	nop
}
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <gettst>:
uint32 gettst()
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  801dbf:	6a 00                	push   $0x0
  801dc1:	6a 00                	push   $0x0
  801dc3:	6a 00                	push   $0x0
  801dc5:	6a 00                	push   $0x0
  801dc7:	6a 00                	push   $0x0
  801dc9:	6a 24                	push   $0x24
  801dcb:	e8 ab fb ff ff       	call   80197b <syscall>
  801dd0:	83 c4 18             	add    $0x18,%esp
}
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    

00801dd5 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801ddb:	6a 00                	push   $0x0
  801ddd:	6a 00                	push   $0x0
  801ddf:	6a 00                	push   $0x0
  801de1:	6a 00                	push   $0x0
  801de3:	6a 00                	push   $0x0
  801de5:	6a 25                	push   $0x25
  801de7:	e8 8f fb ff ff       	call   80197b <syscall>
  801dec:	83 c4 18             	add    $0x18,%esp
  801def:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  801df2:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  801df6:	75 07                	jne    801dff <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  801df8:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfd:	eb 05                	jmp    801e04 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  801dff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801e0c:	6a 00                	push   $0x0
  801e0e:	6a 00                	push   $0x0
  801e10:	6a 00                	push   $0x0
  801e12:	6a 00                	push   $0x0
  801e14:	6a 00                	push   $0x0
  801e16:	6a 25                	push   $0x25
  801e18:	e8 5e fb ff ff       	call   80197b <syscall>
  801e1d:	83 c4 18             	add    $0x18,%esp
  801e20:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  801e23:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  801e27:	75 07                	jne    801e30 <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  801e29:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2e:	eb 05                	jmp    801e35 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  801e30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801e3d:	6a 00                	push   $0x0
  801e3f:	6a 00                	push   $0x0
  801e41:	6a 00                	push   $0x0
  801e43:	6a 00                	push   $0x0
  801e45:	6a 00                	push   $0x0
  801e47:	6a 25                	push   $0x25
  801e49:	e8 2d fb ff ff       	call   80197b <syscall>
  801e4e:	83 c4 18             	add    $0x18,%esp
  801e51:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  801e54:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  801e58:	75 07                	jne    801e61 <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  801e5a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5f:	eb 05                	jmp    801e66 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e66:	c9                   	leave  
  801e67:	c3                   	ret    

00801e68 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801e6e:	6a 00                	push   $0x0
  801e70:	6a 00                	push   $0x0
  801e72:	6a 00                	push   $0x0
  801e74:	6a 00                	push   $0x0
  801e76:	6a 00                	push   $0x0
  801e78:	6a 25                	push   $0x25
  801e7a:	e8 fc fa ff ff       	call   80197b <syscall>
  801e7f:	83 c4 18             	add    $0x18,%esp
  801e82:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  801e85:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  801e89:	75 07                	jne    801e92 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  801e8b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e90:	eb 05                	jmp    801e97 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  801e92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e97:	c9                   	leave  
  801e98:	c3                   	ret    

00801e99 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  801e9c:	6a 00                	push   $0x0
  801e9e:	6a 00                	push   $0x0
  801ea0:	6a 00                	push   $0x0
  801ea2:	6a 00                	push   $0x0
  801ea4:	ff 75 08             	pushl  0x8(%ebp)
  801ea7:	6a 26                	push   $0x26
  801ea9:	e8 cd fa ff ff       	call   80197b <syscall>
  801eae:	83 c4 18             	add    $0x18,%esp
	return ;
  801eb1:	90                   	nop
}
  801eb2:	c9                   	leave  
  801eb3:	c3                   	ret    

00801eb4 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  801eb8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801ebb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801ebe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec4:	6a 00                	push   $0x0
  801ec6:	53                   	push   %ebx
  801ec7:	51                   	push   %ecx
  801ec8:	52                   	push   %edx
  801ec9:	50                   	push   %eax
  801eca:	6a 27                	push   $0x27
  801ecc:	e8 aa fa ff ff       	call   80197b <syscall>
  801ed1:	83 c4 18             	add    $0x18,%esp
}
  801ed4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  801edc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	6a 00                	push   $0x0
  801ee4:	6a 00                	push   $0x0
  801ee6:	6a 00                	push   $0x0
  801ee8:	52                   	push   %edx
  801ee9:	50                   	push   %eax
  801eea:	6a 28                	push   $0x28
  801eec:	e8 8a fa ff ff       	call   80197b <syscall>
  801ef1:	83 c4 18             	add    $0x18,%esp
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  801ef9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801efc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eff:	8b 45 08             	mov    0x8(%ebp),%eax
  801f02:	6a 00                	push   $0x0
  801f04:	51                   	push   %ecx
  801f05:	ff 75 10             	pushl  0x10(%ebp)
  801f08:	52                   	push   %edx
  801f09:	50                   	push   %eax
  801f0a:	6a 29                	push   $0x29
  801f0c:	e8 6a fa ff ff       	call   80197b <syscall>
  801f11:	83 c4 18             	add    $0x18,%esp
}
  801f14:	c9                   	leave  
  801f15:	c3                   	ret    

00801f16 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  801f16:	55                   	push   %ebp
  801f17:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  801f19:	6a 00                	push   $0x0
  801f1b:	6a 00                	push   $0x0
  801f1d:	ff 75 10             	pushl  0x10(%ebp)
  801f20:	ff 75 0c             	pushl  0xc(%ebp)
  801f23:	ff 75 08             	pushl  0x8(%ebp)
  801f26:	6a 12                	push   $0x12
  801f28:	e8 4e fa ff ff       	call   80197b <syscall>
  801f2d:	83 c4 18             	add    $0x18,%esp
	return ;
  801f30:	90                   	nop
}
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <sys_utilities>:
void sys_utilities(char* utilityName, int value)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
	syscall(SYS_utilities, (uint32)utilityName, value, 0, 0, 0);
  801f36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	6a 00                	push   $0x0
  801f3e:	6a 00                	push   $0x0
  801f40:	6a 00                	push   $0x0
  801f42:	52                   	push   %edx
  801f43:	50                   	push   %eax
  801f44:	6a 2a                	push   $0x2a
  801f46:	e8 30 fa ff ff       	call   80197b <syscall>
  801f4b:	83 c4 18             	add    $0x18,%esp
	return;
  801f4e:	90                   	nop
}
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <sys_sbrk>:


//TODO: [PROJECT'24.MS1 - #02] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	return (void*)syscall(SYS_sbrk,increment,0,0,0,0);
  801f54:	8b 45 08             	mov    0x8(%ebp),%eax
  801f57:	6a 00                	push   $0x0
  801f59:	6a 00                	push   $0x0
  801f5b:	6a 00                	push   $0x0
  801f5d:	6a 00                	push   $0x0
  801f5f:	50                   	push   %eax
  801f60:	6a 2b                	push   $0x2b
  801f62:	e8 14 fa ff ff       	call   80197b <syscall>
  801f67:	83 c4 18             	add    $0x18,%esp
}
  801f6a:	c9                   	leave  
  801f6b:	c3                   	ret    

00801f6c <sys_free_user_mem>:

void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	syscall(SYS_free_user_mem,virtual_address,size,0,0,0);
  801f6f:	6a 00                	push   $0x0
  801f71:	6a 00                	push   $0x0
  801f73:	6a 00                	push   $0x0
  801f75:	ff 75 0c             	pushl  0xc(%ebp)
  801f78:	ff 75 08             	pushl  0x8(%ebp)
  801f7b:	6a 2c                	push   $0x2c
  801f7d:	e8 f9 f9 ff ff       	call   80197b <syscall>
  801f82:	83 c4 18             	add    $0x18,%esp
	return;
  801f85:	90                   	nop
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <sys_allocate_user_mem>:

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	syscall(SYS_allocate_user_mem,virtual_address,size,0,0,0);
  801f8b:	6a 00                	push   $0x0
  801f8d:	6a 00                	push   $0x0
  801f8f:	6a 00                	push   $0x0
  801f91:	ff 75 0c             	pushl  0xc(%ebp)
  801f94:	ff 75 08             	pushl  0x8(%ebp)
  801f97:	6a 2d                	push   $0x2d
  801f99:	e8 dd f9 ff ff       	call   80197b <syscall>
  801f9e:	83 c4 18             	add    $0x18,%esp
	return;
  801fa1:	90                   	nop
}
  801fa2:	c9                   	leave  
  801fa3:	c3                   	ret    

00801fa4 <sys_get_cpu_process>:

struct Env* sys_get_cpu_process()
{
  801fa4:	55                   	push   %ebp
  801fa5:	89 e5                	mov    %esp,%ebp
  801fa7:	83 ec 10             	sub    $0x10,%esp
   struct Env* syscall_return ;
   syscall_return  = ( struct Env*)syscall(SYS_get_cpu_process,0,0,0,0,0);
  801faa:	6a 00                	push   $0x0
  801fac:	6a 00                	push   $0x0
  801fae:	6a 00                	push   $0x0
  801fb0:	6a 00                	push   $0x0
  801fb2:	6a 00                	push   $0x0
  801fb4:	6a 2e                	push   $0x2e
  801fb6:	e8 c0 f9 ff ff       	call   80197b <syscall>
  801fbb:	83 c4 18             	add    $0x18,%esp
  801fbe:	89 45 fc             	mov    %eax,-0x4(%ebp)
   return syscall_return ;
  801fc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801fc4:	c9                   	leave  
  801fc5:	c3                   	ret    

00801fc6 <sys_init_queue>:
void sys_init_queue(struct Env_Queue*queue){
  801fc6:	55                   	push   %ebp
  801fc7:	89 e5                	mov    %esp,%ebp
	syscall(SYS_init_queue,(uint32)queue,0,0,0,0);
  801fc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcc:	6a 00                	push   $0x0
  801fce:	6a 00                	push   $0x0
  801fd0:	6a 00                	push   $0x0
  801fd2:	6a 00                	push   $0x0
  801fd4:	50                   	push   %eax
  801fd5:	6a 2f                	push   $0x2f
  801fd7:	e8 9f f9 ff ff       	call   80197b <syscall>
  801fdc:	83 c4 18             	add    $0x18,%esp
	return;
  801fdf:	90                   	nop
}
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <sys_enqueue>:
void sys_enqueue(struct Env_Queue* queue, struct Env* env){
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
	syscall(SYS_enqueue,(uint32)queue,(uint32)env,0,0,0);
  801fe5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	6a 00                	push   $0x0
  801fed:	6a 00                	push   $0x0
  801fef:	6a 00                	push   $0x0
  801ff1:	52                   	push   %edx
  801ff2:	50                   	push   %eax
  801ff3:	6a 30                	push   $0x30
  801ff5:	e8 81 f9 ff ff       	call   80197b <syscall>
  801ffa:	83 c4 18             	add    $0x18,%esp
	return;
  801ffd:	90                   	nop
}
  801ffe:	c9                   	leave  
  801fff:	c3                   	ret    

00802000 <sys_dequeue>:

struct Env* sys_dequeue(struct Env_Queue* queue)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	83 ec 10             	sub    $0x10,%esp
   struct Env* syscall_return;
   syscall_return  = ( struct Env*)syscall(SYS_dequeue,(uint32)queue,0,0,0,0);
  802006:	8b 45 08             	mov    0x8(%ebp),%eax
  802009:	6a 00                	push   $0x0
  80200b:	6a 00                	push   $0x0
  80200d:	6a 00                	push   $0x0
  80200f:	6a 00                	push   $0x0
  802011:	50                   	push   %eax
  802012:	6a 31                	push   $0x31
  802014:	e8 62 f9 ff ff       	call   80197b <syscall>
  802019:	83 c4 18             	add    $0x18,%esp
  80201c:	89 45 fc             	mov    %eax,-0x4(%ebp)
   return syscall_return ;
  80201f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  802022:	c9                   	leave  
  802023:	c3                   	ret    

00802024 <sys_sched_insert_ready>:

void sys_sched_insert_ready( struct Env* env){
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
	syscall(SYS_sched_insert_ready,(uint32)env,0,0,0,0);
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	6a 00                	push   $0x0
  80202c:	6a 00                	push   $0x0
  80202e:	6a 00                	push   $0x0
  802030:	6a 00                	push   $0x0
  802032:	50                   	push   %eax
  802033:	6a 32                	push   $0x32
  802035:	e8 41 f9 ff ff       	call   80197b <syscall>
  80203a:	83 c4 18             	add    $0x18,%esp
	return;
  80203d:	90                   	nop
}
  80203e:	c9                   	leave  
  80203f:	c3                   	ret    

00802040 <get_block_size>:

//=====================================================
// 1) GET BLOCK SIZE (including size of its meta data):
//=====================================================
__inline__ uint32 get_block_size(void* va)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	83 ec 10             	sub    $0x10,%esp
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
  802046:	8b 45 08             	mov    0x8(%ebp),%eax
  802049:	83 e8 04             	sub    $0x4,%eax
  80204c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return (*curBlkMetaData) & ~(0x1);
  80204f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802052:	8b 00                	mov    (%eax),%eax
  802054:	83 e0 fe             	and    $0xfffffffe,%eax
}
  802057:	c9                   	leave  
  802058:	c3                   	ret    

00802059 <is_free_block>:

//===========================
// 2) GET BLOCK STATUS:
//===========================
__inline__ int8 is_free_block(void* va)
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	83 ec 10             	sub    $0x10,%esp
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
  80205f:	8b 45 08             	mov    0x8(%ebp),%eax
  802062:	83 e8 04             	sub    $0x4,%eax
  802065:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return (~(*curBlkMetaData) & 0x1) ;
  802068:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80206b:	8b 00                	mov    (%eax),%eax
  80206d:	83 e0 01             	and    $0x1,%eax
  802070:	85 c0                	test   %eax,%eax
  802072:	0f 94 c0             	sete   %al
}
  802075:	c9                   	leave  
  802076:	c3                   	ret    

00802077 <alloc_block>:
//===========================
// 3) ALLOCATE BLOCK:
//===========================

void *alloc_block(uint32 size, int ALLOC_STRATEGY)
{
  802077:	55                   	push   %ebp
  802078:	89 e5                	mov    %esp,%ebp
  80207a:	83 ec 18             	sub    $0x18,%esp
	void *va = NULL;
  80207d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	switch (ALLOC_STRATEGY)
  802084:	8b 45 0c             	mov    0xc(%ebp),%eax
  802087:	83 f8 02             	cmp    $0x2,%eax
  80208a:	74 2b                	je     8020b7 <alloc_block+0x40>
  80208c:	83 f8 02             	cmp    $0x2,%eax
  80208f:	7f 07                	jg     802098 <alloc_block+0x21>
  802091:	83 f8 01             	cmp    $0x1,%eax
  802094:	74 0e                	je     8020a4 <alloc_block+0x2d>
  802096:	eb 58                	jmp    8020f0 <alloc_block+0x79>
  802098:	83 f8 03             	cmp    $0x3,%eax
  80209b:	74 2d                	je     8020ca <alloc_block+0x53>
  80209d:	83 f8 04             	cmp    $0x4,%eax
  8020a0:	74 3b                	je     8020dd <alloc_block+0x66>
  8020a2:	eb 4c                	jmp    8020f0 <alloc_block+0x79>
	{
	case DA_FF:
		va = alloc_block_FF(size);
  8020a4:	83 ec 0c             	sub    $0xc,%esp
  8020a7:	ff 75 08             	pushl  0x8(%ebp)
  8020aa:	e8 11 03 00 00       	call   8023c0 <alloc_block_FF>
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8020b5:	eb 4a                	jmp    802101 <alloc_block+0x8a>
	case DA_NF:
		va = alloc_block_NF(size);
  8020b7:	83 ec 0c             	sub    $0xc,%esp
  8020ba:	ff 75 08             	pushl  0x8(%ebp)
  8020bd:	e8 c7 19 00 00       	call   803a89 <alloc_block_NF>
  8020c2:	83 c4 10             	add    $0x10,%esp
  8020c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8020c8:	eb 37                	jmp    802101 <alloc_block+0x8a>
	case DA_BF:
		va = alloc_block_BF(size);
  8020ca:	83 ec 0c             	sub    $0xc,%esp
  8020cd:	ff 75 08             	pushl  0x8(%ebp)
  8020d0:	e8 a7 07 00 00       	call   80287c <alloc_block_BF>
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8020db:	eb 24                	jmp    802101 <alloc_block+0x8a>
	case DA_WF:
		va = alloc_block_WF(size);
  8020dd:	83 ec 0c             	sub    $0xc,%esp
  8020e0:	ff 75 08             	pushl  0x8(%ebp)
  8020e3:	e8 84 19 00 00       	call   803a6c <alloc_block_WF>
  8020e8:	83 c4 10             	add    $0x10,%esp
  8020eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8020ee:	eb 11                	jmp    802101 <alloc_block+0x8a>
	default:
		cprintf("Invalid allocation strategy\n");
  8020f0:	83 ec 0c             	sub    $0xc,%esp
  8020f3:	68 e8 44 80 00       	push   $0x8044e8
  8020f8:	e8 b1 e5 ff ff       	call   8006ae <cprintf>
  8020fd:	83 c4 10             	add    $0x10,%esp
		break;
  802100:	90                   	nop
	}
	return va;
  802101:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  802104:	c9                   	leave  
  802105:	c3                   	ret    

00802106 <print_blocks_list>:
//===========================
// 4) PRINT BLOCKS LIST:
//===========================

void print_blocks_list(struct MemBlock_LIST list)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	53                   	push   %ebx
  80210a:	83 ec 14             	sub    $0x14,%esp
	cprintf("=========================================\n");
  80210d:	83 ec 0c             	sub    $0xc,%esp
  802110:	68 08 45 80 00       	push   $0x804508
  802115:	e8 94 e5 ff ff       	call   8006ae <cprintf>
  80211a:	83 c4 10             	add    $0x10,%esp
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
  80211d:	83 ec 0c             	sub    $0xc,%esp
  802120:	68 33 45 80 00       	push   $0x804533
  802125:	e8 84 e5 ff ff       	call   8006ae <cprintf>
  80212a:	83 c4 10             	add    $0x10,%esp
	LIST_FOREACH(blk, &list)
  80212d:	8b 45 08             	mov    0x8(%ebp),%eax
  802130:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802133:	eb 37                	jmp    80216c <print_blocks_list+0x66>
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
  802135:	83 ec 0c             	sub    $0xc,%esp
  802138:	ff 75 f4             	pushl  -0xc(%ebp)
  80213b:	e8 19 ff ff ff       	call   802059 <is_free_block>
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	0f be d8             	movsbl %al,%ebx
  802146:	83 ec 0c             	sub    $0xc,%esp
  802149:	ff 75 f4             	pushl  -0xc(%ebp)
  80214c:	e8 ef fe ff ff       	call   802040 <get_block_size>
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	83 ec 04             	sub    $0x4,%esp
  802157:	53                   	push   %ebx
  802158:	50                   	push   %eax
  802159:	68 4b 45 80 00       	push   $0x80454b
  80215e:	e8 4b e5 ff ff       	call   8006ae <cprintf>
  802163:	83 c4 10             	add    $0x10,%esp
void print_blocks_list(struct MemBlock_LIST list)
{
	cprintf("=========================================\n");
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
	LIST_FOREACH(blk, &list)
  802166:	8b 45 10             	mov    0x10(%ebp),%eax
  802169:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80216c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802170:	74 07                	je     802179 <print_blocks_list+0x73>
  802172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802175:	8b 00                	mov    (%eax),%eax
  802177:	eb 05                	jmp    80217e <print_blocks_list+0x78>
  802179:	b8 00 00 00 00       	mov    $0x0,%eax
  80217e:	89 45 10             	mov    %eax,0x10(%ebp)
  802181:	8b 45 10             	mov    0x10(%ebp),%eax
  802184:	85 c0                	test   %eax,%eax
  802186:	75 ad                	jne    802135 <print_blocks_list+0x2f>
  802188:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80218c:	75 a7                	jne    802135 <print_blocks_list+0x2f>
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
	}
	cprintf("=========================================\n");
  80218e:	83 ec 0c             	sub    $0xc,%esp
  802191:	68 08 45 80 00       	push   $0x804508
  802196:	e8 13 e5 ff ff       	call   8006ae <cprintf>
  80219b:	83 c4 10             	add    $0x10,%esp

}
  80219e:	90                   	nop
  80219f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021a2:	c9                   	leave  
  8021a3:	c3                   	ret    

008021a4 <initialize_dynamic_allocator>:
// [1] INITIALIZE DYNAMIC ALLOCATOR:
//==================================

// Youssef Mohsen
void initialize_dynamic_allocator(uint32 daStart, uint32 initSizeOfAllocatedSpace)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	83 ec 18             	sub    $0x18,%esp
        //==================================================================================
        //DON'T CHANGE THESE LINES==========================================================
        //==================================================================================
        {
            if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
  8021aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ad:	83 e0 01             	and    $0x1,%eax
  8021b0:	85 c0                	test   %eax,%eax
  8021b2:	74 03                	je     8021b7 <initialize_dynamic_allocator+0x13>
  8021b4:	ff 45 0c             	incl   0xc(%ebp)
            if (initSizeOfAllocatedSpace == 0)
  8021b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8021bb:	0f 84 c7 01 00 00    	je     802388 <initialize_dynamic_allocator+0x1e4>
                return ;
            is_initialized = 1;
  8021c1:	c7 05 24 50 80 00 01 	movl   $0x1,0x805024
  8021c8:	00 00 00 
        //TODO: [PROJECT'24.MS1 - #04] [3] DYNAMIC ALLOCATOR - initialize_dynamic_allocator
        //COMMENT THE FOLLOWING LINE BEFORE START CODING
        //panic("initialize_dynamic_allocator is not implemented yet");

    // Check for bounds
    if ((daStart + initSizeOfAllocatedSpace) > KERNEL_HEAP_MAX)
  8021cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8021ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d1:	01 d0                	add    %edx,%eax
  8021d3:	3d 00 f0 ff ff       	cmp    $0xfffff000,%eax
  8021d8:	0f 87 ad 01 00 00    	ja     80238b <initialize_dynamic_allocator+0x1e7>
        return;
    if(daStart < USER_HEAP_START)
  8021de:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	0f 89 a5 01 00 00    	jns    80238e <initialize_dynamic_allocator+0x1ea>
        return;
    end_add = daStart + initSizeOfAllocatedSpace - sizeof(struct Block_Start_End);
  8021e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8021ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ef:	01 d0                	add    %edx,%eax
  8021f1:	83 e8 04             	sub    $0x4,%eax
  8021f4:	a3 44 50 80 00       	mov    %eax,0x805044
     struct BlockElement * element = NULL;
  8021f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     LIST_FOREACH(element, &freeBlocksList)
  802200:	a1 2c 50 80 00       	mov    0x80502c,%eax
  802205:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802208:	e9 87 00 00 00       	jmp    802294 <initialize_dynamic_allocator+0xf0>
     {
        LIST_REMOVE(&freeBlocksList,element);
  80220d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802211:	75 14                	jne    802227 <initialize_dynamic_allocator+0x83>
  802213:	83 ec 04             	sub    $0x4,%esp
  802216:	68 63 45 80 00       	push   $0x804563
  80221b:	6a 79                	push   $0x79
  80221d:	68 81 45 80 00       	push   $0x804581
  802222:	e8 ca e1 ff ff       	call   8003f1 <_panic>
  802227:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222a:	8b 00                	mov    (%eax),%eax
  80222c:	85 c0                	test   %eax,%eax
  80222e:	74 10                	je     802240 <initialize_dynamic_allocator+0x9c>
  802230:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802233:	8b 00                	mov    (%eax),%eax
  802235:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802238:	8b 52 04             	mov    0x4(%edx),%edx
  80223b:	89 50 04             	mov    %edx,0x4(%eax)
  80223e:	eb 0b                	jmp    80224b <initialize_dynamic_allocator+0xa7>
  802240:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802243:	8b 40 04             	mov    0x4(%eax),%eax
  802246:	a3 30 50 80 00       	mov    %eax,0x805030
  80224b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224e:	8b 40 04             	mov    0x4(%eax),%eax
  802251:	85 c0                	test   %eax,%eax
  802253:	74 0f                	je     802264 <initialize_dynamic_allocator+0xc0>
  802255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802258:	8b 40 04             	mov    0x4(%eax),%eax
  80225b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80225e:	8b 12                	mov    (%edx),%edx
  802260:	89 10                	mov    %edx,(%eax)
  802262:	eb 0a                	jmp    80226e <initialize_dynamic_allocator+0xca>
  802264:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802267:	8b 00                	mov    (%eax),%eax
  802269:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80226e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802271:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802277:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802281:	a1 38 50 80 00       	mov    0x805038,%eax
  802286:	48                   	dec    %eax
  802287:	a3 38 50 80 00       	mov    %eax,0x805038
        return;
    if(daStart < USER_HEAP_START)
        return;
    end_add = daStart + initSizeOfAllocatedSpace - sizeof(struct Block_Start_End);
     struct BlockElement * element = NULL;
     LIST_FOREACH(element, &freeBlocksList)
  80228c:	a1 34 50 80 00       	mov    0x805034,%eax
  802291:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802294:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802298:	74 07                	je     8022a1 <initialize_dynamic_allocator+0xfd>
  80229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80229d:	8b 00                	mov    (%eax),%eax
  80229f:	eb 05                	jmp    8022a6 <initialize_dynamic_allocator+0x102>
  8022a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a6:	a3 34 50 80 00       	mov    %eax,0x805034
  8022ab:	a1 34 50 80 00       	mov    0x805034,%eax
  8022b0:	85 c0                	test   %eax,%eax
  8022b2:	0f 85 55 ff ff ff    	jne    80220d <initialize_dynamic_allocator+0x69>
  8022b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8022bc:	0f 85 4b ff ff ff    	jne    80220d <initialize_dynamic_allocator+0x69>
     {
        LIST_REMOVE(&freeBlocksList,element);
     }

    // Create the BEG Block
    struct Block_Start_End* beg_block = (struct Block_Start_End*) daStart;
  8022c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    beg_block->info = 1;
  8022c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022cb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    // Create the END Block
    end_block = (struct Block_Start_End*) (end_add);
  8022d1:	a1 44 50 80 00       	mov    0x805044,%eax
  8022d6:	a3 40 50 80 00       	mov    %eax,0x805040
    end_block->info = 1;
  8022db:	a1 40 50 80 00       	mov    0x805040,%eax
  8022e0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    // Create the first free block
    struct BlockElement* first_free_block = (struct BlockElement*)(daStart + 2*sizeof(struct Block_Start_End));
  8022e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e9:	83 c0 08             	add    $0x8,%eax
  8022ec:	89 45 ec             	mov    %eax,-0x14(%ebp)


    //Assigning the Heap's Header/Footer values
    *(uint32*)((char*)daStart + 4 /*4 Byte*/) = initSizeOfAllocatedSpace - 2 * sizeof(struct Block_Start_End) /*Heap's header/footer*/;
  8022ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f2:	83 c0 04             	add    $0x4,%eax
  8022f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022f8:	83 ea 08             	sub    $0x8,%edx
  8022fb:	89 10                	mov    %edx,(%eax)
    *(uint32*)((char*)daStart + initSizeOfAllocatedSpace - 8) = initSizeOfAllocatedSpace - 2 * sizeof(struct Block_Start_End) /*Heap's header/footer*/;
  8022fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  802300:	8b 45 08             	mov    0x8(%ebp),%eax
  802303:	01 d0                	add    %edx,%eax
  802305:	83 e8 08             	sub    $0x8,%eax
  802308:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230b:	83 ea 08             	sub    $0x8,%edx
  80230e:	89 10                	mov    %edx,(%eax)

    // Initialize links to the END block
   first_free_block->prev_next_info.le_next = NULL; // Link to the END block
  802310:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802313:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
   first_free_block->prev_next_info.le_prev = NULL;
  802319:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80231c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

    // Link the first free block into the free block list
    LIST_INSERT_HEAD(&freeBlocksList , first_free_block);
  802323:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  802327:	75 17                	jne    802340 <initialize_dynamic_allocator+0x19c>
  802329:	83 ec 04             	sub    $0x4,%esp
  80232c:	68 9c 45 80 00       	push   $0x80459c
  802331:	68 90 00 00 00       	push   $0x90
  802336:	68 81 45 80 00       	push   $0x804581
  80233b:	e8 b1 e0 ff ff       	call   8003f1 <_panic>
  802340:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  802346:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802349:	89 10                	mov    %edx,(%eax)
  80234b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80234e:	8b 00                	mov    (%eax),%eax
  802350:	85 c0                	test   %eax,%eax
  802352:	74 0d                	je     802361 <initialize_dynamic_allocator+0x1bd>
  802354:	a1 2c 50 80 00       	mov    0x80502c,%eax
  802359:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80235c:	89 50 04             	mov    %edx,0x4(%eax)
  80235f:	eb 08                	jmp    802369 <initialize_dynamic_allocator+0x1c5>
  802361:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802364:	a3 30 50 80 00       	mov    %eax,0x805030
  802369:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80236c:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802371:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802374:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80237b:	a1 38 50 80 00       	mov    0x805038,%eax
  802380:	40                   	inc    %eax
  802381:	a3 38 50 80 00       	mov    %eax,0x805038
  802386:	eb 07                	jmp    80238f <initialize_dynamic_allocator+0x1eb>
        //DON'T CHANGE THESE LINES==========================================================
        //==================================================================================
        {
            if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
            if (initSizeOfAllocatedSpace == 0)
                return ;
  802388:	90                   	nop
  802389:	eb 04                	jmp    80238f <initialize_dynamic_allocator+0x1eb>
        //COMMENT THE FOLLOWING LINE BEFORE START CODING
        //panic("initialize_dynamic_allocator is not implemented yet");

    // Check for bounds
    if ((daStart + initSizeOfAllocatedSpace) > KERNEL_HEAP_MAX)
        return;
  80238b:	90                   	nop
  80238c:	eb 01                	jmp    80238f <initialize_dynamic_allocator+0x1eb>
    if(daStart < USER_HEAP_START)
        return;
  80238e:	90                   	nop
   first_free_block->prev_next_info.le_next = NULL; // Link to the END block
   first_free_block->prev_next_info.le_prev = NULL;

    // Link the first free block into the free block list
    LIST_INSERT_HEAD(&freeBlocksList , first_free_block);
}
  80238f:	c9                   	leave  
  802390:	c3                   	ret    

00802391 <set_block_data>:

//==================================
// [2] SET BLOCK HEADER & FOOTER:
//==================================
void set_block_data(void* va, uint32 totalSize, bool isAllocated)
{
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
   //TODO: [PROJECT'24.MS1 - #05] [3] DYNAMIC ALLOCATOR - set_block_data
   //COMMENT THE FOLLOWING LINE BEFORE START CODING
   //panic("set_block_data is not implemented yet");
   //Your Code is Here...

	totalSize = totalSize|isAllocated;
  802394:	8b 45 10             	mov    0x10(%ebp),%eax
  802397:	09 45 0c             	or     %eax,0xc(%ebp)
   *HEADER(va) = totalSize;
  80239a:	8b 45 08             	mov    0x8(%ebp),%eax
  80239d:	8d 50 fc             	lea    -0x4(%eax),%edx
  8023a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a3:	89 02                	mov    %eax,(%edx)
   *FOOTER(va) = totalSize;
  8023a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a8:	83 e8 04             	sub    $0x4,%eax
  8023ab:	8b 00                	mov    (%eax),%eax
  8023ad:	83 e0 fe             	and    $0xfffffffe,%eax
  8023b0:	8d 50 f8             	lea    -0x8(%eax),%edx
  8023b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b6:	01 c2                	add    %eax,%edx
  8023b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023bb:	89 02                	mov    %eax,(%edx)
}
  8023bd:	90                   	nop
  8023be:	5d                   	pop    %ebp
  8023bf:	c3                   	ret    

008023c0 <alloc_block_FF>:
//=========================================
// [3] ALLOCATE BLOCK BY FIRST FIT:
//=========================================

void *alloc_block_FF(uint32 size)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	83 ec 58             	sub    $0x58,%esp
	//==================================================================================
	//DON'T CHANGE THESE LINES==========================================================
	//==================================================================================
	{
		if (size % 2 != 0) size++;	//ensure that the size is even (to use LSB as allocation flag)
  8023c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c9:	83 e0 01             	and    $0x1,%eax
  8023cc:	85 c0                	test   %eax,%eax
  8023ce:	74 03                	je     8023d3 <alloc_block_FF+0x13>
  8023d0:	ff 45 08             	incl   0x8(%ebp)
		if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
  8023d3:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
  8023d7:	77 07                	ja     8023e0 <alloc_block_FF+0x20>
			size = DYN_ALLOC_MIN_BLOCK_SIZE ;
  8023d9:	c7 45 08 08 00 00 00 	movl   $0x8,0x8(%ebp)
		if (!is_initialized)
  8023e0:	a1 24 50 80 00       	mov    0x805024,%eax
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	75 73                	jne    80245c <alloc_block_FF+0x9c>
		{
			uint32 required_size = size + 2*sizeof(int) /*header & footer*/ + 2*sizeof(int) /*da begin & end*/ ;
  8023e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ec:	83 c0 10             	add    $0x10,%eax
  8023ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
			uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE)/PAGE_SIZE);
  8023f2:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
  8023f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8023fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8023ff:	01 d0                	add    %edx,%eax
  802401:	48                   	dec    %eax
  802402:	89 45 e8             	mov    %eax,-0x18(%ebp)
  802405:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802408:	ba 00 00 00 00       	mov    $0x0,%edx
  80240d:	f7 75 ec             	divl   -0x14(%ebp)
  802410:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802413:	29 d0                	sub    %edx,%eax
  802415:	c1 e8 0c             	shr    $0xc,%eax
  802418:	83 ec 0c             	sub    $0xc,%esp
  80241b:	50                   	push   %eax
  80241c:	e8 27 f0 ff ff       	call   801448 <sbrk>
  802421:	83 c4 10             	add    $0x10,%esp
  802424:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			uint32 da_break = (uint32)sbrk(0);
  802427:	83 ec 0c             	sub    $0xc,%esp
  80242a:	6a 00                	push   $0x0
  80242c:	e8 17 f0 ff ff       	call   801448 <sbrk>
  802431:	83 c4 10             	add    $0x10,%esp
  802434:	89 45 e0             	mov    %eax,-0x20(%ebp)
			initialize_dynamic_allocator(da_start, da_break - da_start);
  802437:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80243a:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  80243d:	83 ec 08             	sub    $0x8,%esp
  802440:	50                   	push   %eax
  802441:	ff 75 e4             	pushl  -0x1c(%ebp)
  802444:	e8 5b fd ff ff       	call   8021a4 <initialize_dynamic_allocator>
  802449:	83 c4 10             	add    $0x10,%esp
			cprintf("Initialized \n");
  80244c:	83 ec 0c             	sub    $0xc,%esp
  80244f:	68 bf 45 80 00       	push   $0x8045bf
  802454:	e8 55 e2 ff ff       	call   8006ae <cprintf>
  802459:	83 c4 10             	add    $0x10,%esp
	//TODO: [PROJECT'24.MS1 - #06] [3] DYNAMIC ALLOCATOR - alloc_block_FF
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
//	panic("alloc_block_FF is not implemented yet");
	//Your Code is Here...

	 if (size == 0) {
  80245c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802460:	75 0a                	jne    80246c <alloc_block_FF+0xac>
	        return NULL;
  802462:	b8 00 00 00 00       	mov    $0x0,%eax
  802467:	e9 0e 04 00 00       	jmp    80287a <alloc_block_FF+0x4ba>
	    }
	// cprintf("size is %d \n",size);


	    struct BlockElement *blk = NULL;
  80246c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	    LIST_FOREACH(blk, &freeBlocksList) {
  802473:	a1 2c 50 80 00       	mov    0x80502c,%eax
  802478:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80247b:	e9 f3 02 00 00       	jmp    802773 <alloc_block_FF+0x3b3>
	        void *va = (void *)blk;
  802480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802483:	89 45 bc             	mov    %eax,-0x44(%ebp)
	        uint32 blk_size = get_block_size(va);
  802486:	83 ec 0c             	sub    $0xc,%esp
  802489:	ff 75 bc             	pushl  -0x44(%ebp)
  80248c:	e8 af fb ff ff       	call   802040 <get_block_size>
  802491:	83 c4 10             	add    $0x10,%esp
  802494:	89 45 b8             	mov    %eax,-0x48(%ebp)

	        if(blk_size >= size + 2 * sizeof(uint32)) {
  802497:	8b 45 08             	mov    0x8(%ebp),%eax
  80249a:	83 c0 08             	add    $0x8,%eax
  80249d:	3b 45 b8             	cmp    -0x48(%ebp),%eax
  8024a0:	0f 87 c5 02 00 00    	ja     80276b <alloc_block_FF+0x3ab>
	            if (blk_size >= size + DYN_ALLOC_MIN_BLOCK_SIZE + 4 * sizeof(uint32))
  8024a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a9:	83 c0 18             	add    $0x18,%eax
  8024ac:	3b 45 b8             	cmp    -0x48(%ebp),%eax
  8024af:	0f 87 19 02 00 00    	ja     8026ce <alloc_block_FF+0x30e>
	            {

				uint32 remaining_size = blk_size - size - 2 * sizeof(uint32);
  8024b5:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8024b8:	2b 45 08             	sub    0x8(%ebp),%eax
  8024bb:	83 e8 08             	sub    $0x8,%eax
  8024be:	89 45 b4             	mov    %eax,-0x4c(%ebp)
				void *new_block_va = (void *)((char *)va + size + 2 * sizeof(uint32));
  8024c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c4:	8d 50 08             	lea    0x8(%eax),%edx
  8024c7:	8b 45 bc             	mov    -0x44(%ebp),%eax
  8024ca:	01 d0                	add    %edx,%eax
  8024cc:	89 45 b0             	mov    %eax,-0x50(%ebp)
				set_block_data(va, size + 2 * sizeof(uint32), 1);
  8024cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d2:	83 c0 08             	add    $0x8,%eax
  8024d5:	83 ec 04             	sub    $0x4,%esp
  8024d8:	6a 01                	push   $0x1
  8024da:	50                   	push   %eax
  8024db:	ff 75 bc             	pushl  -0x44(%ebp)
  8024de:	e8 ae fe ff ff       	call   802391 <set_block_data>
  8024e3:	83 c4 10             	add    $0x10,%esp

				if (LIST_PREV(blk)==NULL)
  8024e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024e9:	8b 40 04             	mov    0x4(%eax),%eax
  8024ec:	85 c0                	test   %eax,%eax
  8024ee:	75 68                	jne    802558 <alloc_block_FF+0x198>
				{
					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement*)new_block_va);
  8024f0:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  8024f4:	75 17                	jne    80250d <alloc_block_FF+0x14d>
  8024f6:	83 ec 04             	sub    $0x4,%esp
  8024f9:	68 9c 45 80 00       	push   $0x80459c
  8024fe:	68 d7 00 00 00       	push   $0xd7
  802503:	68 81 45 80 00       	push   $0x804581
  802508:	e8 e4 de ff ff       	call   8003f1 <_panic>
  80250d:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  802513:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802516:	89 10                	mov    %edx,(%eax)
  802518:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80251b:	8b 00                	mov    (%eax),%eax
  80251d:	85 c0                	test   %eax,%eax
  80251f:	74 0d                	je     80252e <alloc_block_FF+0x16e>
  802521:	a1 2c 50 80 00       	mov    0x80502c,%eax
  802526:	8b 55 b0             	mov    -0x50(%ebp),%edx
  802529:	89 50 04             	mov    %edx,0x4(%eax)
  80252c:	eb 08                	jmp    802536 <alloc_block_FF+0x176>
  80252e:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802531:	a3 30 50 80 00       	mov    %eax,0x805030
  802536:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802539:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80253e:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802541:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802548:	a1 38 50 80 00       	mov    0x805038,%eax
  80254d:	40                   	inc    %eax
  80254e:	a3 38 50 80 00       	mov    %eax,0x805038
  802553:	e9 dc 00 00 00       	jmp    802634 <alloc_block_FF+0x274>
				}
				else if (LIST_NEXT(blk)==NULL)
  802558:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80255b:	8b 00                	mov    (%eax),%eax
  80255d:	85 c0                	test   %eax,%eax
  80255f:	75 65                	jne    8025c6 <alloc_block_FF+0x206>
				{
					LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement*)new_block_va);
  802561:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  802565:	75 17                	jne    80257e <alloc_block_FF+0x1be>
  802567:	83 ec 04             	sub    $0x4,%esp
  80256a:	68 d0 45 80 00       	push   $0x8045d0
  80256f:	68 db 00 00 00       	push   $0xdb
  802574:	68 81 45 80 00       	push   $0x804581
  802579:	e8 73 de ff ff       	call   8003f1 <_panic>
  80257e:	8b 15 30 50 80 00    	mov    0x805030,%edx
  802584:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802587:	89 50 04             	mov    %edx,0x4(%eax)
  80258a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80258d:	8b 40 04             	mov    0x4(%eax),%eax
  802590:	85 c0                	test   %eax,%eax
  802592:	74 0c                	je     8025a0 <alloc_block_FF+0x1e0>
  802594:	a1 30 50 80 00       	mov    0x805030,%eax
  802599:	8b 55 b0             	mov    -0x50(%ebp),%edx
  80259c:	89 10                	mov    %edx,(%eax)
  80259e:	eb 08                	jmp    8025a8 <alloc_block_FF+0x1e8>
  8025a0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8025a3:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8025a8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8025ab:	a3 30 50 80 00       	mov    %eax,0x805030
  8025b0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8025b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8025b9:	a1 38 50 80 00       	mov    0x805038,%eax
  8025be:	40                   	inc    %eax
  8025bf:	a3 38 50 80 00       	mov    %eax,0x805038
  8025c4:	eb 6e                	jmp    802634 <alloc_block_FF+0x274>
				}
				else
				{
					LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement*)new_block_va);
  8025c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8025ca:	74 06                	je     8025d2 <alloc_block_FF+0x212>
  8025cc:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  8025d0:	75 17                	jne    8025e9 <alloc_block_FF+0x229>
  8025d2:	83 ec 04             	sub    $0x4,%esp
  8025d5:	68 f4 45 80 00       	push   $0x8045f4
  8025da:	68 df 00 00 00       	push   $0xdf
  8025df:	68 81 45 80 00       	push   $0x804581
  8025e4:	e8 08 de ff ff       	call   8003f1 <_panic>
  8025e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ec:	8b 10                	mov    (%eax),%edx
  8025ee:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8025f1:	89 10                	mov    %edx,(%eax)
  8025f3:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8025f6:	8b 00                	mov    (%eax),%eax
  8025f8:	85 c0                	test   %eax,%eax
  8025fa:	74 0b                	je     802607 <alloc_block_FF+0x247>
  8025fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ff:	8b 00                	mov    (%eax),%eax
  802601:	8b 55 b0             	mov    -0x50(%ebp),%edx
  802604:	89 50 04             	mov    %edx,0x4(%eax)
  802607:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80260a:	8b 55 b0             	mov    -0x50(%ebp),%edx
  80260d:	89 10                	mov    %edx,(%eax)
  80260f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802615:	89 50 04             	mov    %edx,0x4(%eax)
  802618:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80261b:	8b 00                	mov    (%eax),%eax
  80261d:	85 c0                	test   %eax,%eax
  80261f:	75 08                	jne    802629 <alloc_block_FF+0x269>
  802621:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802624:	a3 30 50 80 00       	mov    %eax,0x805030
  802629:	a1 38 50 80 00       	mov    0x805038,%eax
  80262e:	40                   	inc    %eax
  80262f:	a3 38 50 80 00       	mov    %eax,0x805038
				}
				LIST_REMOVE(&freeBlocksList, blk);
  802634:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802638:	75 17                	jne    802651 <alloc_block_FF+0x291>
  80263a:	83 ec 04             	sub    $0x4,%esp
  80263d:	68 63 45 80 00       	push   $0x804563
  802642:	68 e1 00 00 00       	push   $0xe1
  802647:	68 81 45 80 00       	push   $0x804581
  80264c:	e8 a0 dd ff ff       	call   8003f1 <_panic>
  802651:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802654:	8b 00                	mov    (%eax),%eax
  802656:	85 c0                	test   %eax,%eax
  802658:	74 10                	je     80266a <alloc_block_FF+0x2aa>
  80265a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80265d:	8b 00                	mov    (%eax),%eax
  80265f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802662:	8b 52 04             	mov    0x4(%edx),%edx
  802665:	89 50 04             	mov    %edx,0x4(%eax)
  802668:	eb 0b                	jmp    802675 <alloc_block_FF+0x2b5>
  80266a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80266d:	8b 40 04             	mov    0x4(%eax),%eax
  802670:	a3 30 50 80 00       	mov    %eax,0x805030
  802675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802678:	8b 40 04             	mov    0x4(%eax),%eax
  80267b:	85 c0                	test   %eax,%eax
  80267d:	74 0f                	je     80268e <alloc_block_FF+0x2ce>
  80267f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802682:	8b 40 04             	mov    0x4(%eax),%eax
  802685:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802688:	8b 12                	mov    (%edx),%edx
  80268a:	89 10                	mov    %edx,(%eax)
  80268c:	eb 0a                	jmp    802698 <alloc_block_FF+0x2d8>
  80268e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802691:	8b 00                	mov    (%eax),%eax
  802693:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8026a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8026ab:	a1 38 50 80 00       	mov    0x805038,%eax
  8026b0:	48                   	dec    %eax
  8026b1:	a3 38 50 80 00       	mov    %eax,0x805038
				set_block_data(new_block_va, remaining_size, 0);
  8026b6:	83 ec 04             	sub    $0x4,%esp
  8026b9:	6a 00                	push   $0x0
  8026bb:	ff 75 b4             	pushl  -0x4c(%ebp)
  8026be:	ff 75 b0             	pushl  -0x50(%ebp)
  8026c1:	e8 cb fc ff ff       	call   802391 <set_block_data>
  8026c6:	83 c4 10             	add    $0x10,%esp
  8026c9:	e9 95 00 00 00       	jmp    802763 <alloc_block_FF+0x3a3>
	            }
	            else
	            {

	            	set_block_data(va, blk_size, 1);
  8026ce:	83 ec 04             	sub    $0x4,%esp
  8026d1:	6a 01                	push   $0x1
  8026d3:	ff 75 b8             	pushl  -0x48(%ebp)
  8026d6:	ff 75 bc             	pushl  -0x44(%ebp)
  8026d9:	e8 b3 fc ff ff       	call   802391 <set_block_data>
  8026de:	83 c4 10             	add    $0x10,%esp
	            	LIST_REMOVE(&freeBlocksList,blk);
  8026e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8026e5:	75 17                	jne    8026fe <alloc_block_FF+0x33e>
  8026e7:	83 ec 04             	sub    $0x4,%esp
  8026ea:	68 63 45 80 00       	push   $0x804563
  8026ef:	68 e8 00 00 00       	push   $0xe8
  8026f4:	68 81 45 80 00       	push   $0x804581
  8026f9:	e8 f3 dc ff ff       	call   8003f1 <_panic>
  8026fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802701:	8b 00                	mov    (%eax),%eax
  802703:	85 c0                	test   %eax,%eax
  802705:	74 10                	je     802717 <alloc_block_FF+0x357>
  802707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270a:	8b 00                	mov    (%eax),%eax
  80270c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80270f:	8b 52 04             	mov    0x4(%edx),%edx
  802712:	89 50 04             	mov    %edx,0x4(%eax)
  802715:	eb 0b                	jmp    802722 <alloc_block_FF+0x362>
  802717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80271a:	8b 40 04             	mov    0x4(%eax),%eax
  80271d:	a3 30 50 80 00       	mov    %eax,0x805030
  802722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802725:	8b 40 04             	mov    0x4(%eax),%eax
  802728:	85 c0                	test   %eax,%eax
  80272a:	74 0f                	je     80273b <alloc_block_FF+0x37b>
  80272c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80272f:	8b 40 04             	mov    0x4(%eax),%eax
  802732:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802735:	8b 12                	mov    (%edx),%edx
  802737:	89 10                	mov    %edx,(%eax)
  802739:	eb 0a                	jmp    802745 <alloc_block_FF+0x385>
  80273b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80273e:	8b 00                	mov    (%eax),%eax
  802740:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802748:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  80274e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802751:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802758:	a1 38 50 80 00       	mov    0x805038,%eax
  80275d:	48                   	dec    %eax
  80275e:	a3 38 50 80 00       	mov    %eax,0x805038
	            }
	            return va;
  802763:	8b 45 bc             	mov    -0x44(%ebp),%eax
  802766:	e9 0f 01 00 00       	jmp    80287a <alloc_block_FF+0x4ba>
	    }
	// cprintf("size is %d \n",size);


	    struct BlockElement *blk = NULL;
	    LIST_FOREACH(blk, &freeBlocksList) {
  80276b:	a1 34 50 80 00       	mov    0x805034,%eax
  802770:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802773:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802777:	74 07                	je     802780 <alloc_block_FF+0x3c0>
  802779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80277c:	8b 00                	mov    (%eax),%eax
  80277e:	eb 05                	jmp    802785 <alloc_block_FF+0x3c5>
  802780:	b8 00 00 00 00       	mov    $0x0,%eax
  802785:	a3 34 50 80 00       	mov    %eax,0x805034
  80278a:	a1 34 50 80 00       	mov    0x805034,%eax
  80278f:	85 c0                	test   %eax,%eax
  802791:	0f 85 e9 fc ff ff    	jne    802480 <alloc_block_FF+0xc0>
  802797:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80279b:	0f 85 df fc ff ff    	jne    802480 <alloc_block_FF+0xc0>
	            	LIST_REMOVE(&freeBlocksList,blk);
	            }
	            return va;
	        }
	    }
	    uint32 required_size = size + 2 * sizeof(uint32);
  8027a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a4:	83 c0 08             	add    $0x8,%eax
  8027a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	    void *new_mem = sbrk(ROUNDUP(required_size, PAGE_SIZE) / PAGE_SIZE);
  8027aa:	c7 45 d8 00 10 00 00 	movl   $0x1000,-0x28(%ebp)
  8027b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8027b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8027b7:	01 d0                	add    %edx,%eax
  8027b9:	48                   	dec    %eax
  8027ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8027bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8027c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8027c5:	f7 75 d8             	divl   -0x28(%ebp)
  8027c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8027cb:	29 d0                	sub    %edx,%eax
  8027cd:	c1 e8 0c             	shr    $0xc,%eax
  8027d0:	83 ec 0c             	sub    $0xc,%esp
  8027d3:	50                   	push   %eax
  8027d4:	e8 6f ec ff ff       	call   801448 <sbrk>
  8027d9:	83 c4 10             	add    $0x10,%esp
  8027dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		if (new_mem == (void *)-1) {
  8027df:	83 7d d0 ff          	cmpl   $0xffffffff,-0x30(%ebp)
  8027e3:	75 0a                	jne    8027ef <alloc_block_FF+0x42f>
			return NULL; // Allocation failed
  8027e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8027ea:	e9 8b 00 00 00       	jmp    80287a <alloc_block_FF+0x4ba>
		}
		else {
			end_block = (struct Block_Start_End*) (new_mem + ROUNDUP(required_size, PAGE_SIZE)-sizeof(int));
  8027ef:	c7 45 cc 00 10 00 00 	movl   $0x1000,-0x34(%ebp)
  8027f6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8027f9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8027fc:	01 d0                	add    %edx,%eax
  8027fe:	48                   	dec    %eax
  8027ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  802802:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802805:	ba 00 00 00 00       	mov    $0x0,%edx
  80280a:	f7 75 cc             	divl   -0x34(%ebp)
  80280d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802810:	29 d0                	sub    %edx,%eax
  802812:	8d 50 fc             	lea    -0x4(%eax),%edx
  802815:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802818:	01 d0                	add    %edx,%eax
  80281a:	a3 40 50 80 00       	mov    %eax,0x805040
			end_block->info = 1;
  80281f:	a1 40 50 80 00       	mov    0x805040,%eax
  802824:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		set_block_data(new_mem, ROUNDUP(required_size, PAGE_SIZE), 1);
  80282a:	c7 45 c4 00 10 00 00 	movl   $0x1000,-0x3c(%ebp)
  802831:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802834:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  802837:	01 d0                	add    %edx,%eax
  802839:	48                   	dec    %eax
  80283a:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80283d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802840:	ba 00 00 00 00       	mov    $0x0,%edx
  802845:	f7 75 c4             	divl   -0x3c(%ebp)
  802848:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80284b:	29 d0                	sub    %edx,%eax
  80284d:	83 ec 04             	sub    $0x4,%esp
  802850:	6a 01                	push   $0x1
  802852:	50                   	push   %eax
  802853:	ff 75 d0             	pushl  -0x30(%ebp)
  802856:	e8 36 fb ff ff       	call   802391 <set_block_data>
  80285b:	83 c4 10             	add    $0x10,%esp
		free_block(new_mem);
  80285e:	83 ec 0c             	sub    $0xc,%esp
  802861:	ff 75 d0             	pushl  -0x30(%ebp)
  802864:	e8 f8 09 00 00       	call   803261 <free_block>
  802869:	83 c4 10             	add    $0x10,%esp
		return alloc_block_FF(size);
  80286c:	83 ec 0c             	sub    $0xc,%esp
  80286f:	ff 75 08             	pushl  0x8(%ebp)
  802872:	e8 49 fb ff ff       	call   8023c0 <alloc_block_FF>
  802877:	83 c4 10             	add    $0x10,%esp
		}
		return new_mem;
}
  80287a:	c9                   	leave  
  80287b:	c3                   	ret    

0080287c <alloc_block_BF>:
//=========================================
// [4] ALLOCATE BLOCK BY BEST FIT:
//=========================================
void *alloc_block_BF(uint32 size)
{
  80287c:	55                   	push   %ebp
  80287d:	89 e5                	mov    %esp,%ebp
  80287f:	83 ec 68             	sub    $0x68,%esp
	//Your Code is Here...
	//==================================================================================
	//DON'T CHANGE THESE LINES==========================================================
	//==================================================================================
	{
		if (size % 2 != 0) size++;	//ensure that the size is even (to use LSB as allocation flag)
  802882:	8b 45 08             	mov    0x8(%ebp),%eax
  802885:	83 e0 01             	and    $0x1,%eax
  802888:	85 c0                	test   %eax,%eax
  80288a:	74 03                	je     80288f <alloc_block_BF+0x13>
  80288c:	ff 45 08             	incl   0x8(%ebp)
		if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
  80288f:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
  802893:	77 07                	ja     80289c <alloc_block_BF+0x20>
			size = DYN_ALLOC_MIN_BLOCK_SIZE ;
  802895:	c7 45 08 08 00 00 00 	movl   $0x8,0x8(%ebp)
		if (!is_initialized)
  80289c:	a1 24 50 80 00       	mov    0x805024,%eax
  8028a1:	85 c0                	test   %eax,%eax
  8028a3:	75 73                	jne    802918 <alloc_block_BF+0x9c>
		{
			uint32 required_size = size + 2*sizeof(int) /*header & footer*/ + 2*sizeof(int) /*da begin & end*/ ;
  8028a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8028a8:	83 c0 10             	add    $0x10,%eax
  8028ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE)/PAGE_SIZE);
  8028ae:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
  8028b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8028b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028bb:	01 d0                	add    %edx,%eax
  8028bd:	48                   	dec    %eax
  8028be:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8028c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8028c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8028c9:	f7 75 e0             	divl   -0x20(%ebp)
  8028cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8028cf:	29 d0                	sub    %edx,%eax
  8028d1:	c1 e8 0c             	shr    $0xc,%eax
  8028d4:	83 ec 0c             	sub    $0xc,%esp
  8028d7:	50                   	push   %eax
  8028d8:	e8 6b eb ff ff       	call   801448 <sbrk>
  8028dd:	83 c4 10             	add    $0x10,%esp
  8028e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
			uint32 da_break = (uint32)sbrk(0);
  8028e3:	83 ec 0c             	sub    $0xc,%esp
  8028e6:	6a 00                	push   $0x0
  8028e8:	e8 5b eb ff ff       	call   801448 <sbrk>
  8028ed:	83 c4 10             	add    $0x10,%esp
  8028f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			initialize_dynamic_allocator(da_start, da_break - da_start);
  8028f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8028f6:	2b 45 d8             	sub    -0x28(%ebp),%eax
  8028f9:	83 ec 08             	sub    $0x8,%esp
  8028fc:	50                   	push   %eax
  8028fd:	ff 75 d8             	pushl  -0x28(%ebp)
  802900:	e8 9f f8 ff ff       	call   8021a4 <initialize_dynamic_allocator>
  802905:	83 c4 10             	add    $0x10,%esp
			cprintf("Initialized \n");
  802908:	83 ec 0c             	sub    $0xc,%esp
  80290b:	68 bf 45 80 00       	push   $0x8045bf
  802910:	e8 99 dd ff ff       	call   8006ae <cprintf>
  802915:	83 c4 10             	add    $0x10,%esp
		}
	}
	//==================================================================================
	//==================================================================================

	struct BlockElement *blk = NULL;
  802918:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	void *best_va=NULL;
  80291f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	uint32 best_blk_size = (uint32)KERNEL_HEAP_MAX - 2 * sizeof(uint32);
  802926:	c7 45 ec f8 ef ff ff 	movl   $0xffffeff8,-0x14(%ebp)
	bool internal = 0;
  80292d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	LIST_FOREACH(blk, &freeBlocksList) {
  802934:	a1 2c 50 80 00       	mov    0x80502c,%eax
  802939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80293c:	e9 1d 01 00 00       	jmp    802a5e <alloc_block_BF+0x1e2>
		void *va = (void *)blk;
  802941:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802944:	89 45 a8             	mov    %eax,-0x58(%ebp)
		uint32 blk_size = get_block_size(va);
  802947:	83 ec 0c             	sub    $0xc,%esp
  80294a:	ff 75 a8             	pushl  -0x58(%ebp)
  80294d:	e8 ee f6 ff ff       	call   802040 <get_block_size>
  802952:	83 c4 10             	add    $0x10,%esp
  802955:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		if (blk_size>=size + 2 * sizeof(uint32))
  802958:	8b 45 08             	mov    0x8(%ebp),%eax
  80295b:	83 c0 08             	add    $0x8,%eax
  80295e:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802961:	0f 87 ef 00 00 00    	ja     802a56 <alloc_block_BF+0x1da>
		{
			if (blk_size >= size + DYN_ALLOC_MIN_BLOCK_SIZE + 4 * sizeof(uint32))
  802967:	8b 45 08             	mov    0x8(%ebp),%eax
  80296a:	83 c0 18             	add    $0x18,%eax
  80296d:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802970:	77 1d                	ja     80298f <alloc_block_BF+0x113>
			{
				if (best_blk_size > blk_size)
  802972:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802975:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802978:	0f 86 d8 00 00 00    	jbe    802a56 <alloc_block_BF+0x1da>
				{
					best_va = va;
  80297e:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802981:	89 45 f0             	mov    %eax,-0x10(%ebp)
					best_blk_size = blk_size;
  802984:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  802987:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80298a:	e9 c7 00 00 00       	jmp    802a56 <alloc_block_BF+0x1da>
				}
			}
			else
			{
				if (blk_size == size + 2 * sizeof(uint32)){
  80298f:	8b 45 08             	mov    0x8(%ebp),%eax
  802992:	83 c0 08             	add    $0x8,%eax
  802995:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802998:	0f 85 9d 00 00 00    	jne    802a3b <alloc_block_BF+0x1bf>
					set_block_data(va, blk_size, 1);
  80299e:	83 ec 04             	sub    $0x4,%esp
  8029a1:	6a 01                	push   $0x1
  8029a3:	ff 75 a4             	pushl  -0x5c(%ebp)
  8029a6:	ff 75 a8             	pushl  -0x58(%ebp)
  8029a9:	e8 e3 f9 ff ff       	call   802391 <set_block_data>
  8029ae:	83 c4 10             	add    $0x10,%esp
					LIST_REMOVE(&freeBlocksList,blk);
  8029b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8029b5:	75 17                	jne    8029ce <alloc_block_BF+0x152>
  8029b7:	83 ec 04             	sub    $0x4,%esp
  8029ba:	68 63 45 80 00       	push   $0x804563
  8029bf:	68 2c 01 00 00       	push   $0x12c
  8029c4:	68 81 45 80 00       	push   $0x804581
  8029c9:	e8 23 da ff ff       	call   8003f1 <_panic>
  8029ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029d1:	8b 00                	mov    (%eax),%eax
  8029d3:	85 c0                	test   %eax,%eax
  8029d5:	74 10                	je     8029e7 <alloc_block_BF+0x16b>
  8029d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029da:	8b 00                	mov    (%eax),%eax
  8029dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8029df:	8b 52 04             	mov    0x4(%edx),%edx
  8029e2:	89 50 04             	mov    %edx,0x4(%eax)
  8029e5:	eb 0b                	jmp    8029f2 <alloc_block_BF+0x176>
  8029e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029ea:	8b 40 04             	mov    0x4(%eax),%eax
  8029ed:	a3 30 50 80 00       	mov    %eax,0x805030
  8029f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029f5:	8b 40 04             	mov    0x4(%eax),%eax
  8029f8:	85 c0                	test   %eax,%eax
  8029fa:	74 0f                	je     802a0b <alloc_block_BF+0x18f>
  8029fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029ff:	8b 40 04             	mov    0x4(%eax),%eax
  802a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802a05:	8b 12                	mov    (%edx),%edx
  802a07:	89 10                	mov    %edx,(%eax)
  802a09:	eb 0a                	jmp    802a15 <alloc_block_BF+0x199>
  802a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a0e:	8b 00                	mov    (%eax),%eax
  802a10:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a18:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a21:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802a28:	a1 38 50 80 00       	mov    0x805038,%eax
  802a2d:	48                   	dec    %eax
  802a2e:	a3 38 50 80 00       	mov    %eax,0x805038
					return va;
  802a33:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802a36:	e9 01 04 00 00       	jmp    802e3c <alloc_block_BF+0x5c0>
				}
				else
				{
					if (best_blk_size > blk_size)
  802a3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802a3e:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802a41:	76 13                	jbe    802a56 <alloc_block_BF+0x1da>
					{
						internal = 1;
  802a43:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
						best_va = va;
  802a4a:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802a4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
						best_blk_size = blk_size;
  802a50:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  802a53:	89 45 ec             	mov    %eax,-0x14(%ebp)

	struct BlockElement *blk = NULL;
	void *best_va=NULL;
	uint32 best_blk_size = (uint32)KERNEL_HEAP_MAX - 2 * sizeof(uint32);
	bool internal = 0;
	LIST_FOREACH(blk, &freeBlocksList) {
  802a56:	a1 34 50 80 00       	mov    0x805034,%eax
  802a5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802a5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802a62:	74 07                	je     802a6b <alloc_block_BF+0x1ef>
  802a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a67:	8b 00                	mov    (%eax),%eax
  802a69:	eb 05                	jmp    802a70 <alloc_block_BF+0x1f4>
  802a6b:	b8 00 00 00 00       	mov    $0x0,%eax
  802a70:	a3 34 50 80 00       	mov    %eax,0x805034
  802a75:	a1 34 50 80 00       	mov    0x805034,%eax
  802a7a:	85 c0                	test   %eax,%eax
  802a7c:	0f 85 bf fe ff ff    	jne    802941 <alloc_block_BF+0xc5>
  802a82:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802a86:	0f 85 b5 fe ff ff    	jne    802941 <alloc_block_BF+0xc5>
			}
		}

	}

	if (best_va !=NULL && internal ==0){
  802a8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802a90:	0f 84 26 02 00 00    	je     802cbc <alloc_block_BF+0x440>
  802a96:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  802a9a:	0f 85 1c 02 00 00    	jne    802cbc <alloc_block_BF+0x440>
		uint32 remaining_size = best_blk_size - size - 2 * sizeof(uint32);
  802aa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802aa3:	2b 45 08             	sub    0x8(%ebp),%eax
  802aa6:	83 e8 08             	sub    $0x8,%eax
  802aa9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		void *new_block_va = (void *)((char *)best_va + size + 2 * sizeof(uint32));
  802aac:	8b 45 08             	mov    0x8(%ebp),%eax
  802aaf:	8d 50 08             	lea    0x8(%eax),%edx
  802ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ab5:	01 d0                	add    %edx,%eax
  802ab7:	89 45 cc             	mov    %eax,-0x34(%ebp)
		set_block_data(best_va, size + 2 * sizeof(uint32), 1);
  802aba:	8b 45 08             	mov    0x8(%ebp),%eax
  802abd:	83 c0 08             	add    $0x8,%eax
  802ac0:	83 ec 04             	sub    $0x4,%esp
  802ac3:	6a 01                	push   $0x1
  802ac5:	50                   	push   %eax
  802ac6:	ff 75 f0             	pushl  -0x10(%ebp)
  802ac9:	e8 c3 f8 ff ff       	call   802391 <set_block_data>
  802ace:	83 c4 10             	add    $0x10,%esp

		if (LIST_PREV((struct BlockElement *)best_va)==NULL)
  802ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ad4:	8b 40 04             	mov    0x4(%eax),%eax
  802ad7:	85 c0                	test   %eax,%eax
  802ad9:	75 68                	jne    802b43 <alloc_block_BF+0x2c7>
			{

				LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement*)new_block_va);
  802adb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  802adf:	75 17                	jne    802af8 <alloc_block_BF+0x27c>
  802ae1:	83 ec 04             	sub    $0x4,%esp
  802ae4:	68 9c 45 80 00       	push   $0x80459c
  802ae9:	68 45 01 00 00       	push   $0x145
  802aee:	68 81 45 80 00       	push   $0x804581
  802af3:	e8 f9 d8 ff ff       	call   8003f1 <_panic>
  802af8:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  802afe:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b01:	89 10                	mov    %edx,(%eax)
  802b03:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b06:	8b 00                	mov    (%eax),%eax
  802b08:	85 c0                	test   %eax,%eax
  802b0a:	74 0d                	je     802b19 <alloc_block_BF+0x29d>
  802b0c:	a1 2c 50 80 00       	mov    0x80502c,%eax
  802b11:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802b14:	89 50 04             	mov    %edx,0x4(%eax)
  802b17:	eb 08                	jmp    802b21 <alloc_block_BF+0x2a5>
  802b19:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b1c:	a3 30 50 80 00       	mov    %eax,0x805030
  802b21:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b24:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802b29:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b2c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802b33:	a1 38 50 80 00       	mov    0x805038,%eax
  802b38:	40                   	inc    %eax
  802b39:	a3 38 50 80 00       	mov    %eax,0x805038
  802b3e:	e9 dc 00 00 00       	jmp    802c1f <alloc_block_BF+0x3a3>
			}
			else if (LIST_NEXT((struct BlockElement *)best_va)==NULL)
  802b43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b46:	8b 00                	mov    (%eax),%eax
  802b48:	85 c0                	test   %eax,%eax
  802b4a:	75 65                	jne    802bb1 <alloc_block_BF+0x335>
			{

				LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement*)new_block_va);
  802b4c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  802b50:	75 17                	jne    802b69 <alloc_block_BF+0x2ed>
  802b52:	83 ec 04             	sub    $0x4,%esp
  802b55:	68 d0 45 80 00       	push   $0x8045d0
  802b5a:	68 4a 01 00 00       	push   $0x14a
  802b5f:	68 81 45 80 00       	push   $0x804581
  802b64:	e8 88 d8 ff ff       	call   8003f1 <_panic>
  802b69:	8b 15 30 50 80 00    	mov    0x805030,%edx
  802b6f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b72:	89 50 04             	mov    %edx,0x4(%eax)
  802b75:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b78:	8b 40 04             	mov    0x4(%eax),%eax
  802b7b:	85 c0                	test   %eax,%eax
  802b7d:	74 0c                	je     802b8b <alloc_block_BF+0x30f>
  802b7f:	a1 30 50 80 00       	mov    0x805030,%eax
  802b84:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802b87:	89 10                	mov    %edx,(%eax)
  802b89:	eb 08                	jmp    802b93 <alloc_block_BF+0x317>
  802b8b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b8e:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802b93:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b96:	a3 30 50 80 00       	mov    %eax,0x805030
  802b9b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802b9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802ba4:	a1 38 50 80 00       	mov    0x805038,%eax
  802ba9:	40                   	inc    %eax
  802baa:	a3 38 50 80 00       	mov    %eax,0x805038
  802baf:	eb 6e                	jmp    802c1f <alloc_block_BF+0x3a3>
			}
			else
			{

				LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement *)best_va, (struct BlockElement*)new_block_va);
  802bb1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802bb5:	74 06                	je     802bbd <alloc_block_BF+0x341>
  802bb7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  802bbb:	75 17                	jne    802bd4 <alloc_block_BF+0x358>
  802bbd:	83 ec 04             	sub    $0x4,%esp
  802bc0:	68 f4 45 80 00       	push   $0x8045f4
  802bc5:	68 4f 01 00 00       	push   $0x14f
  802bca:	68 81 45 80 00       	push   $0x804581
  802bcf:	e8 1d d8 ff ff       	call   8003f1 <_panic>
  802bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bd7:	8b 10                	mov    (%eax),%edx
  802bd9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802bdc:	89 10                	mov    %edx,(%eax)
  802bde:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802be1:	8b 00                	mov    (%eax),%eax
  802be3:	85 c0                	test   %eax,%eax
  802be5:	74 0b                	je     802bf2 <alloc_block_BF+0x376>
  802be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bea:	8b 00                	mov    (%eax),%eax
  802bec:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802bef:	89 50 04             	mov    %edx,0x4(%eax)
  802bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bf5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802bf8:	89 10                	mov    %edx,(%eax)
  802bfa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802bfd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802c00:	89 50 04             	mov    %edx,0x4(%eax)
  802c03:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802c06:	8b 00                	mov    (%eax),%eax
  802c08:	85 c0                	test   %eax,%eax
  802c0a:	75 08                	jne    802c14 <alloc_block_BF+0x398>
  802c0c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802c0f:	a3 30 50 80 00       	mov    %eax,0x805030
  802c14:	a1 38 50 80 00       	mov    0x805038,%eax
  802c19:	40                   	inc    %eax
  802c1a:	a3 38 50 80 00       	mov    %eax,0x805038
			}
			LIST_REMOVE(&freeBlocksList, (struct BlockElement *)best_va);
  802c1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802c23:	75 17                	jne    802c3c <alloc_block_BF+0x3c0>
  802c25:	83 ec 04             	sub    $0x4,%esp
  802c28:	68 63 45 80 00       	push   $0x804563
  802c2d:	68 51 01 00 00       	push   $0x151
  802c32:	68 81 45 80 00       	push   $0x804581
  802c37:	e8 b5 d7 ff ff       	call   8003f1 <_panic>
  802c3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c3f:	8b 00                	mov    (%eax),%eax
  802c41:	85 c0                	test   %eax,%eax
  802c43:	74 10                	je     802c55 <alloc_block_BF+0x3d9>
  802c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c48:	8b 00                	mov    (%eax),%eax
  802c4a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802c4d:	8b 52 04             	mov    0x4(%edx),%edx
  802c50:	89 50 04             	mov    %edx,0x4(%eax)
  802c53:	eb 0b                	jmp    802c60 <alloc_block_BF+0x3e4>
  802c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c58:	8b 40 04             	mov    0x4(%eax),%eax
  802c5b:	a3 30 50 80 00       	mov    %eax,0x805030
  802c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c63:	8b 40 04             	mov    0x4(%eax),%eax
  802c66:	85 c0                	test   %eax,%eax
  802c68:	74 0f                	je     802c79 <alloc_block_BF+0x3fd>
  802c6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c6d:	8b 40 04             	mov    0x4(%eax),%eax
  802c70:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802c73:	8b 12                	mov    (%edx),%edx
  802c75:	89 10                	mov    %edx,(%eax)
  802c77:	eb 0a                	jmp    802c83 <alloc_block_BF+0x407>
  802c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c7c:	8b 00                	mov    (%eax),%eax
  802c7e:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802c8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c8f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802c96:	a1 38 50 80 00       	mov    0x805038,%eax
  802c9b:	48                   	dec    %eax
  802c9c:	a3 38 50 80 00       	mov    %eax,0x805038
			set_block_data(new_block_va, remaining_size, 0);
  802ca1:	83 ec 04             	sub    $0x4,%esp
  802ca4:	6a 00                	push   $0x0
  802ca6:	ff 75 d0             	pushl  -0x30(%ebp)
  802ca9:	ff 75 cc             	pushl  -0x34(%ebp)
  802cac:	e8 e0 f6 ff ff       	call   802391 <set_block_data>
  802cb1:	83 c4 10             	add    $0x10,%esp
			return best_va;
  802cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cb7:	e9 80 01 00 00       	jmp    802e3c <alloc_block_BF+0x5c0>
	}
	else if(internal == 1)
  802cbc:	83 7d e8 01          	cmpl   $0x1,-0x18(%ebp)
  802cc0:	0f 85 9d 00 00 00    	jne    802d63 <alloc_block_BF+0x4e7>
	{
		set_block_data(best_va, best_blk_size, 1);
  802cc6:	83 ec 04             	sub    $0x4,%esp
  802cc9:	6a 01                	push   $0x1
  802ccb:	ff 75 ec             	pushl  -0x14(%ebp)
  802cce:	ff 75 f0             	pushl  -0x10(%ebp)
  802cd1:	e8 bb f6 ff ff       	call   802391 <set_block_data>
  802cd6:	83 c4 10             	add    $0x10,%esp
		LIST_REMOVE(&freeBlocksList,(struct BlockElement *)best_va);
  802cd9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802cdd:	75 17                	jne    802cf6 <alloc_block_BF+0x47a>
  802cdf:	83 ec 04             	sub    $0x4,%esp
  802ce2:	68 63 45 80 00       	push   $0x804563
  802ce7:	68 58 01 00 00       	push   $0x158
  802cec:	68 81 45 80 00       	push   $0x804581
  802cf1:	e8 fb d6 ff ff       	call   8003f1 <_panic>
  802cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cf9:	8b 00                	mov    (%eax),%eax
  802cfb:	85 c0                	test   %eax,%eax
  802cfd:	74 10                	je     802d0f <alloc_block_BF+0x493>
  802cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d02:	8b 00                	mov    (%eax),%eax
  802d04:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d07:	8b 52 04             	mov    0x4(%edx),%edx
  802d0a:	89 50 04             	mov    %edx,0x4(%eax)
  802d0d:	eb 0b                	jmp    802d1a <alloc_block_BF+0x49e>
  802d0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d12:	8b 40 04             	mov    0x4(%eax),%eax
  802d15:	a3 30 50 80 00       	mov    %eax,0x805030
  802d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d1d:	8b 40 04             	mov    0x4(%eax),%eax
  802d20:	85 c0                	test   %eax,%eax
  802d22:	74 0f                	je     802d33 <alloc_block_BF+0x4b7>
  802d24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d27:	8b 40 04             	mov    0x4(%eax),%eax
  802d2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802d2d:	8b 12                	mov    (%edx),%edx
  802d2f:	89 10                	mov    %edx,(%eax)
  802d31:	eb 0a                	jmp    802d3d <alloc_block_BF+0x4c1>
  802d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d36:	8b 00                	mov    (%eax),%eax
  802d38:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d49:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802d50:	a1 38 50 80 00       	mov    0x805038,%eax
  802d55:	48                   	dec    %eax
  802d56:	a3 38 50 80 00       	mov    %eax,0x805038
		return best_va;
  802d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d5e:	e9 d9 00 00 00       	jmp    802e3c <alloc_block_BF+0x5c0>
	}
	uint32 required_size = size + 2 * sizeof(uint32);
  802d63:	8b 45 08             	mov    0x8(%ebp),%eax
  802d66:	83 c0 08             	add    $0x8,%eax
  802d69:	89 45 c8             	mov    %eax,-0x38(%ebp)
		    void *new_mem = sbrk(ROUNDUP(required_size, PAGE_SIZE) / PAGE_SIZE);
  802d6c:	c7 45 c4 00 10 00 00 	movl   $0x1000,-0x3c(%ebp)
  802d73:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802d76:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  802d79:	01 d0                	add    %edx,%eax
  802d7b:	48                   	dec    %eax
  802d7c:	89 45 c0             	mov    %eax,-0x40(%ebp)
  802d7f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802d82:	ba 00 00 00 00       	mov    $0x0,%edx
  802d87:	f7 75 c4             	divl   -0x3c(%ebp)
  802d8a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802d8d:	29 d0                	sub    %edx,%eax
  802d8f:	c1 e8 0c             	shr    $0xc,%eax
  802d92:	83 ec 0c             	sub    $0xc,%esp
  802d95:	50                   	push   %eax
  802d96:	e8 ad e6 ff ff       	call   801448 <sbrk>
  802d9b:	83 c4 10             	add    $0x10,%esp
  802d9e:	89 45 bc             	mov    %eax,-0x44(%ebp)
			if (new_mem == (void *)-1) {
  802da1:	83 7d bc ff          	cmpl   $0xffffffff,-0x44(%ebp)
  802da5:	75 0a                	jne    802db1 <alloc_block_BF+0x535>
				return NULL; // Allocation failed
  802da7:	b8 00 00 00 00       	mov    $0x0,%eax
  802dac:	e9 8b 00 00 00       	jmp    802e3c <alloc_block_BF+0x5c0>
			}
			else {
				end_block = (struct Block_Start_End*) (new_mem + ROUNDUP(required_size, PAGE_SIZE)-sizeof(int));
  802db1:	c7 45 b8 00 10 00 00 	movl   $0x1000,-0x48(%ebp)
  802db8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802dbb:	8b 45 b8             	mov    -0x48(%ebp),%eax
  802dbe:	01 d0                	add    %edx,%eax
  802dc0:	48                   	dec    %eax
  802dc1:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  802dc4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  802dc7:	ba 00 00 00 00       	mov    $0x0,%edx
  802dcc:	f7 75 b8             	divl   -0x48(%ebp)
  802dcf:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  802dd2:	29 d0                	sub    %edx,%eax
  802dd4:	8d 50 fc             	lea    -0x4(%eax),%edx
  802dd7:	8b 45 bc             	mov    -0x44(%ebp),%eax
  802dda:	01 d0                	add    %edx,%eax
  802ddc:	a3 40 50 80 00       	mov    %eax,0x805040
				end_block->info = 1;
  802de1:	a1 40 50 80 00       	mov    0x805040,%eax
  802de6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
				
			
			set_block_data(new_mem, ROUNDUP(required_size, PAGE_SIZE), 1);
  802dec:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  802df3:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802df6:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802df9:	01 d0                	add    %edx,%eax
  802dfb:	48                   	dec    %eax
  802dfc:	89 45 ac             	mov    %eax,-0x54(%ebp)
  802dff:	8b 45 ac             	mov    -0x54(%ebp),%eax
  802e02:	ba 00 00 00 00       	mov    $0x0,%edx
  802e07:	f7 75 b0             	divl   -0x50(%ebp)
  802e0a:	8b 45 ac             	mov    -0x54(%ebp),%eax
  802e0d:	29 d0                	sub    %edx,%eax
  802e0f:	83 ec 04             	sub    $0x4,%esp
  802e12:	6a 01                	push   $0x1
  802e14:	50                   	push   %eax
  802e15:	ff 75 bc             	pushl  -0x44(%ebp)
  802e18:	e8 74 f5 ff ff       	call   802391 <set_block_data>
  802e1d:	83 c4 10             	add    $0x10,%esp
			free_block(new_mem);
  802e20:	83 ec 0c             	sub    $0xc,%esp
  802e23:	ff 75 bc             	pushl  -0x44(%ebp)
  802e26:	e8 36 04 00 00       	call   803261 <free_block>
  802e2b:	83 c4 10             	add    $0x10,%esp
			return alloc_block_BF(size);
  802e2e:	83 ec 0c             	sub    $0xc,%esp
  802e31:	ff 75 08             	pushl  0x8(%ebp)
  802e34:	e8 43 fa ff ff       	call   80287c <alloc_block_BF>
  802e39:	83 c4 10             	add    $0x10,%esp
			}
			return new_mem;
}
  802e3c:	c9                   	leave  
  802e3d:	c3                   	ret    

00802e3e <merging>:

//===================================================
// [5] FREE BLOCK WITH COALESCING:
//===================================================
void merging(struct BlockElement *prev_block, struct BlockElement *next_block, void* va){
  802e3e:	55                   	push   %ebp
  802e3f:	89 e5                	mov    %esp,%ebp
  802e41:	53                   	push   %ebx
  802e42:	83 ec 24             	sub    $0x24,%esp
	bool prev_is_free = 0, next_is_free = 0;
  802e45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  802e4c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (prev_block != NULL && (char *)prev_block + get_block_size(prev_block) == (char *)va) {
  802e53:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802e57:	74 1e                	je     802e77 <merging+0x39>
  802e59:	ff 75 08             	pushl  0x8(%ebp)
  802e5c:	e8 df f1 ff ff       	call   802040 <get_block_size>
  802e61:	83 c4 04             	add    $0x4,%esp
  802e64:	89 c2                	mov    %eax,%edx
  802e66:	8b 45 08             	mov    0x8(%ebp),%eax
  802e69:	01 d0                	add    %edx,%eax
  802e6b:	3b 45 10             	cmp    0x10(%ebp),%eax
  802e6e:	75 07                	jne    802e77 <merging+0x39>
		prev_is_free = 1;
  802e70:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	}
	if (next_block != NULL && (char *)va + get_block_size(va) == (char *)next_block) {
  802e77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802e7b:	74 1e                	je     802e9b <merging+0x5d>
  802e7d:	ff 75 10             	pushl  0x10(%ebp)
  802e80:	e8 bb f1 ff ff       	call   802040 <get_block_size>
  802e85:	83 c4 04             	add    $0x4,%esp
  802e88:	89 c2                	mov    %eax,%edx
  802e8a:	8b 45 10             	mov    0x10(%ebp),%eax
  802e8d:	01 d0                	add    %edx,%eax
  802e8f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  802e92:	75 07                	jne    802e9b <merging+0x5d>
		next_is_free = 1;
  802e94:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	if(prev_is_free && next_is_free)
  802e9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802e9f:	0f 84 cc 00 00 00    	je     802f71 <merging+0x133>
  802ea5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802ea9:	0f 84 c2 00 00 00    	je     802f71 <merging+0x133>
	{
		//merge - 2 sides
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va) + get_block_size(next_block);
  802eaf:	ff 75 08             	pushl  0x8(%ebp)
  802eb2:	e8 89 f1 ff ff       	call   802040 <get_block_size>
  802eb7:	83 c4 04             	add    $0x4,%esp
  802eba:	89 c3                	mov    %eax,%ebx
  802ebc:	ff 75 10             	pushl  0x10(%ebp)
  802ebf:	e8 7c f1 ff ff       	call   802040 <get_block_size>
  802ec4:	83 c4 04             	add    $0x4,%esp
  802ec7:	01 c3                	add    %eax,%ebx
  802ec9:	ff 75 0c             	pushl  0xc(%ebp)
  802ecc:	e8 6f f1 ff ff       	call   802040 <get_block_size>
  802ed1:	83 c4 04             	add    $0x4,%esp
  802ed4:	01 d8                	add    %ebx,%eax
  802ed6:	89 45 ec             	mov    %eax,-0x14(%ebp)
		set_block_data(prev_block, new_block_size, 0);
  802ed9:	6a 00                	push   $0x0
  802edb:	ff 75 ec             	pushl  -0x14(%ebp)
  802ede:	ff 75 08             	pushl  0x8(%ebp)
  802ee1:	e8 ab f4 ff ff       	call   802391 <set_block_data>
  802ee6:	83 c4 0c             	add    $0xc,%esp
		LIST_REMOVE(&freeBlocksList, next_block);
  802ee9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802eed:	75 17                	jne    802f06 <merging+0xc8>
  802eef:	83 ec 04             	sub    $0x4,%esp
  802ef2:	68 63 45 80 00       	push   $0x804563
  802ef7:	68 7d 01 00 00       	push   $0x17d
  802efc:	68 81 45 80 00       	push   $0x804581
  802f01:	e8 eb d4 ff ff       	call   8003f1 <_panic>
  802f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f09:	8b 00                	mov    (%eax),%eax
  802f0b:	85 c0                	test   %eax,%eax
  802f0d:	74 10                	je     802f1f <merging+0xe1>
  802f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f12:	8b 00                	mov    (%eax),%eax
  802f14:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f17:	8b 52 04             	mov    0x4(%edx),%edx
  802f1a:	89 50 04             	mov    %edx,0x4(%eax)
  802f1d:	eb 0b                	jmp    802f2a <merging+0xec>
  802f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f22:	8b 40 04             	mov    0x4(%eax),%eax
  802f25:	a3 30 50 80 00       	mov    %eax,0x805030
  802f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f2d:	8b 40 04             	mov    0x4(%eax),%eax
  802f30:	85 c0                	test   %eax,%eax
  802f32:	74 0f                	je     802f43 <merging+0x105>
  802f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f37:	8b 40 04             	mov    0x4(%eax),%eax
  802f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f3d:	8b 12                	mov    (%edx),%edx
  802f3f:	89 10                	mov    %edx,(%eax)
  802f41:	eb 0a                	jmp    802f4d <merging+0x10f>
  802f43:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f46:	8b 00                	mov    (%eax),%eax
  802f48:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f59:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802f60:	a1 38 50 80 00       	mov    0x805038,%eax
  802f65:	48                   	dec    %eax
  802f66:	a3 38 50 80 00       	mov    %eax,0x805038
	}
	if (next_block != NULL && (char *)va + get_block_size(va) == (char *)next_block) {
		next_is_free = 1;
	}
	if(prev_is_free && next_is_free)
	{
  802f6b:	90                   	nop
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  802f6c:	e9 ea 02 00 00       	jmp    80325b <merging+0x41d>
		//merge - 2 sides
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va) + get_block_size(next_block);
		set_block_data(prev_block, new_block_size, 0);
		LIST_REMOVE(&freeBlocksList, next_block);
	}
	else if(prev_is_free)
  802f71:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802f75:	74 3b                	je     802fb2 <merging+0x174>
	{
		//merge - left side
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va);
  802f77:	83 ec 0c             	sub    $0xc,%esp
  802f7a:	ff 75 08             	pushl  0x8(%ebp)
  802f7d:	e8 be f0 ff ff       	call   802040 <get_block_size>
  802f82:	83 c4 10             	add    $0x10,%esp
  802f85:	89 c3                	mov    %eax,%ebx
  802f87:	83 ec 0c             	sub    $0xc,%esp
  802f8a:	ff 75 10             	pushl  0x10(%ebp)
  802f8d:	e8 ae f0 ff ff       	call   802040 <get_block_size>
  802f92:	83 c4 10             	add    $0x10,%esp
  802f95:	01 d8                	add    %ebx,%eax
  802f97:	89 45 e8             	mov    %eax,-0x18(%ebp)
		set_block_data(prev_block, new_block_size, 0);
  802f9a:	83 ec 04             	sub    $0x4,%esp
  802f9d:	6a 00                	push   $0x0
  802f9f:	ff 75 e8             	pushl  -0x18(%ebp)
  802fa2:	ff 75 08             	pushl  0x8(%ebp)
  802fa5:	e8 e7 f3 ff ff       	call   802391 <set_block_data>
  802faa:	83 c4 10             	add    $0x10,%esp
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  802fad:	e9 a9 02 00 00       	jmp    80325b <merging+0x41d>
	{
		//merge - left side
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va);
		set_block_data(prev_block, new_block_size, 0);
	}
	else if(next_is_free)
  802fb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802fb6:	0f 84 2d 01 00 00    	je     8030e9 <merging+0x2ab>
	{
		//merge - right side

		uint32 new_block_size = get_block_size(va) + get_block_size(next_block);
  802fbc:	83 ec 0c             	sub    $0xc,%esp
  802fbf:	ff 75 10             	pushl  0x10(%ebp)
  802fc2:	e8 79 f0 ff ff       	call   802040 <get_block_size>
  802fc7:	83 c4 10             	add    $0x10,%esp
  802fca:	89 c3                	mov    %eax,%ebx
  802fcc:	83 ec 0c             	sub    $0xc,%esp
  802fcf:	ff 75 0c             	pushl  0xc(%ebp)
  802fd2:	e8 69 f0 ff ff       	call   802040 <get_block_size>
  802fd7:	83 c4 10             	add    $0x10,%esp
  802fda:	01 d8                	add    %ebx,%eax
  802fdc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		set_block_data(va, new_block_size, 0);
  802fdf:	83 ec 04             	sub    $0x4,%esp
  802fe2:	6a 00                	push   $0x0
  802fe4:	ff 75 e4             	pushl  -0x1c(%ebp)
  802fe7:	ff 75 10             	pushl  0x10(%ebp)
  802fea:	e8 a2 f3 ff ff       	call   802391 <set_block_data>
  802fef:	83 c4 10             	add    $0x10,%esp

		struct BlockElement *va_block = (struct BlockElement *)va;
  802ff2:	8b 45 10             	mov    0x10(%ebp),%eax
  802ff5:	89 45 e0             	mov    %eax,-0x20(%ebp)
		LIST_INSERT_BEFORE(&freeBlocksList, next_block, va_block);
  802ff8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802ffc:	74 06                	je     803004 <merging+0x1c6>
  802ffe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  803002:	75 17                	jne    80301b <merging+0x1dd>
  803004:	83 ec 04             	sub    $0x4,%esp
  803007:	68 28 46 80 00       	push   $0x804628
  80300c:	68 8d 01 00 00       	push   $0x18d
  803011:	68 81 45 80 00       	push   $0x804581
  803016:	e8 d6 d3 ff ff       	call   8003f1 <_panic>
  80301b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80301e:	8b 50 04             	mov    0x4(%eax),%edx
  803021:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803024:	89 50 04             	mov    %edx,0x4(%eax)
  803027:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80302a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80302d:	89 10                	mov    %edx,(%eax)
  80302f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803032:	8b 40 04             	mov    0x4(%eax),%eax
  803035:	85 c0                	test   %eax,%eax
  803037:	74 0d                	je     803046 <merging+0x208>
  803039:	8b 45 0c             	mov    0xc(%ebp),%eax
  80303c:	8b 40 04             	mov    0x4(%eax),%eax
  80303f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803042:	89 10                	mov    %edx,(%eax)
  803044:	eb 08                	jmp    80304e <merging+0x210>
  803046:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803049:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80304e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803051:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803054:	89 50 04             	mov    %edx,0x4(%eax)
  803057:	a1 38 50 80 00       	mov    0x805038,%eax
  80305c:	40                   	inc    %eax
  80305d:	a3 38 50 80 00       	mov    %eax,0x805038
		LIST_REMOVE(&freeBlocksList, next_block);
  803062:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803066:	75 17                	jne    80307f <merging+0x241>
  803068:	83 ec 04             	sub    $0x4,%esp
  80306b:	68 63 45 80 00       	push   $0x804563
  803070:	68 8e 01 00 00       	push   $0x18e
  803075:	68 81 45 80 00       	push   $0x804581
  80307a:	e8 72 d3 ff ff       	call   8003f1 <_panic>
  80307f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803082:	8b 00                	mov    (%eax),%eax
  803084:	85 c0                	test   %eax,%eax
  803086:	74 10                	je     803098 <merging+0x25a>
  803088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80308b:	8b 00                	mov    (%eax),%eax
  80308d:	8b 55 0c             	mov    0xc(%ebp),%edx
  803090:	8b 52 04             	mov    0x4(%edx),%edx
  803093:	89 50 04             	mov    %edx,0x4(%eax)
  803096:	eb 0b                	jmp    8030a3 <merging+0x265>
  803098:	8b 45 0c             	mov    0xc(%ebp),%eax
  80309b:	8b 40 04             	mov    0x4(%eax),%eax
  80309e:	a3 30 50 80 00       	mov    %eax,0x805030
  8030a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030a6:	8b 40 04             	mov    0x4(%eax),%eax
  8030a9:	85 c0                	test   %eax,%eax
  8030ab:	74 0f                	je     8030bc <merging+0x27e>
  8030ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030b0:	8b 40 04             	mov    0x4(%eax),%eax
  8030b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8030b6:	8b 12                	mov    (%edx),%edx
  8030b8:	89 10                	mov    %edx,(%eax)
  8030ba:	eb 0a                	jmp    8030c6 <merging+0x288>
  8030bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030bf:	8b 00                	mov    (%eax),%eax
  8030c1:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8030c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8030cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030d2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8030d9:	a1 38 50 80 00       	mov    0x805038,%eax
  8030de:	48                   	dec    %eax
  8030df:	a3 38 50 80 00       	mov    %eax,0x805038
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  8030e4:	e9 72 01 00 00       	jmp    80325b <merging+0x41d>
		LIST_INSERT_BEFORE(&freeBlocksList, next_block, va_block);
		LIST_REMOVE(&freeBlocksList, next_block);
	}
	else
	{
		struct BlockElement *va_block = (struct BlockElement *)va;
  8030e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8030ec:	89 45 dc             	mov    %eax,-0x24(%ebp)

		if(prev_block != NULL && next_block != NULL) LIST_INSERT_AFTER(&freeBlocksList, prev_block, va_block);
  8030ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8030f3:	74 79                	je     80316e <merging+0x330>
  8030f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8030f9:	74 73                	je     80316e <merging+0x330>
  8030fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8030ff:	74 06                	je     803107 <merging+0x2c9>
  803101:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  803105:	75 17                	jne    80311e <merging+0x2e0>
  803107:	83 ec 04             	sub    $0x4,%esp
  80310a:	68 f4 45 80 00       	push   $0x8045f4
  80310f:	68 94 01 00 00       	push   $0x194
  803114:	68 81 45 80 00       	push   $0x804581
  803119:	e8 d3 d2 ff ff       	call   8003f1 <_panic>
  80311e:	8b 45 08             	mov    0x8(%ebp),%eax
  803121:	8b 10                	mov    (%eax),%edx
  803123:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803126:	89 10                	mov    %edx,(%eax)
  803128:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80312b:	8b 00                	mov    (%eax),%eax
  80312d:	85 c0                	test   %eax,%eax
  80312f:	74 0b                	je     80313c <merging+0x2fe>
  803131:	8b 45 08             	mov    0x8(%ebp),%eax
  803134:	8b 00                	mov    (%eax),%eax
  803136:	8b 55 dc             	mov    -0x24(%ebp),%edx
  803139:	89 50 04             	mov    %edx,0x4(%eax)
  80313c:	8b 45 08             	mov    0x8(%ebp),%eax
  80313f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  803142:	89 10                	mov    %edx,(%eax)
  803144:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803147:	8b 55 08             	mov    0x8(%ebp),%edx
  80314a:	89 50 04             	mov    %edx,0x4(%eax)
  80314d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803150:	8b 00                	mov    (%eax),%eax
  803152:	85 c0                	test   %eax,%eax
  803154:	75 08                	jne    80315e <merging+0x320>
  803156:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803159:	a3 30 50 80 00       	mov    %eax,0x805030
  80315e:	a1 38 50 80 00       	mov    0x805038,%eax
  803163:	40                   	inc    %eax
  803164:	a3 38 50 80 00       	mov    %eax,0x805038
  803169:	e9 ce 00 00 00       	jmp    80323c <merging+0x3fe>
		else if(prev_block != NULL) LIST_INSERT_TAIL(&freeBlocksList, va_block);
  80316e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  803172:	74 65                	je     8031d9 <merging+0x39b>
  803174:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  803178:	75 17                	jne    803191 <merging+0x353>
  80317a:	83 ec 04             	sub    $0x4,%esp
  80317d:	68 d0 45 80 00       	push   $0x8045d0
  803182:	68 95 01 00 00       	push   $0x195
  803187:	68 81 45 80 00       	push   $0x804581
  80318c:	e8 60 d2 ff ff       	call   8003f1 <_panic>
  803191:	8b 15 30 50 80 00    	mov    0x805030,%edx
  803197:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80319a:	89 50 04             	mov    %edx,0x4(%eax)
  80319d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8031a0:	8b 40 04             	mov    0x4(%eax),%eax
  8031a3:	85 c0                	test   %eax,%eax
  8031a5:	74 0c                	je     8031b3 <merging+0x375>
  8031a7:	a1 30 50 80 00       	mov    0x805030,%eax
  8031ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8031af:	89 10                	mov    %edx,(%eax)
  8031b1:	eb 08                	jmp    8031bb <merging+0x37d>
  8031b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8031b6:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8031bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8031be:	a3 30 50 80 00       	mov    %eax,0x805030
  8031c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8031c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8031cc:	a1 38 50 80 00       	mov    0x805038,%eax
  8031d1:	40                   	inc    %eax
  8031d2:	a3 38 50 80 00       	mov    %eax,0x805038
  8031d7:	eb 63                	jmp    80323c <merging+0x3fe>
		else
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
  8031d9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8031dd:	75 17                	jne    8031f6 <merging+0x3b8>
  8031df:	83 ec 04             	sub    $0x4,%esp
  8031e2:	68 9c 45 80 00       	push   $0x80459c
  8031e7:	68 98 01 00 00       	push   $0x198
  8031ec:	68 81 45 80 00       	push   $0x804581
  8031f1:	e8 fb d1 ff ff       	call   8003f1 <_panic>
  8031f6:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  8031fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8031ff:	89 10                	mov    %edx,(%eax)
  803201:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803204:	8b 00                	mov    (%eax),%eax
  803206:	85 c0                	test   %eax,%eax
  803208:	74 0d                	je     803217 <merging+0x3d9>
  80320a:	a1 2c 50 80 00       	mov    0x80502c,%eax
  80320f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  803212:	89 50 04             	mov    %edx,0x4(%eax)
  803215:	eb 08                	jmp    80321f <merging+0x3e1>
  803217:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80321a:	a3 30 50 80 00       	mov    %eax,0x805030
  80321f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803222:	a3 2c 50 80 00       	mov    %eax,0x80502c
  803227:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80322a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803231:	a1 38 50 80 00       	mov    0x805038,%eax
  803236:	40                   	inc    %eax
  803237:	a3 38 50 80 00       	mov    %eax,0x805038
		}
		set_block_data(va, get_block_size(va), 0);
  80323c:	83 ec 0c             	sub    $0xc,%esp
  80323f:	ff 75 10             	pushl  0x10(%ebp)
  803242:	e8 f9 ed ff ff       	call   802040 <get_block_size>
  803247:	83 c4 10             	add    $0x10,%esp
  80324a:	83 ec 04             	sub    $0x4,%esp
  80324d:	6a 00                	push   $0x0
  80324f:	50                   	push   %eax
  803250:	ff 75 10             	pushl  0x10(%ebp)
  803253:	e8 39 f1 ff ff       	call   802391 <set_block_data>
  803258:	83 c4 10             	add    $0x10,%esp
	}
}
  80325b:	90                   	nop
  80325c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80325f:	c9                   	leave  
  803260:	c3                   	ret    

00803261 <free_block>:
//===================================================
// [5] FREE BLOCK WITH COALESCING:
//===================================================
void free_block(void *va)
{
  803261:	55                   	push   %ebp
  803262:	89 e5                	mov    %esp,%ebp
  803264:	83 ec 18             	sub    $0x18,%esp
	//TODO: [PROJECT'24.MS1 - #07] [3] DYNAMIC ALLOCATOR - free_block
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("free_block is not implemented yet");
	//Your Code is Here...
	struct BlockElement *prev_block = LIST_FIRST(&freeBlocksList);
  803267:	a1 2c 50 80 00       	mov    0x80502c,%eax
  80326c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if((char *)LIST_LAST(&freeBlocksList) < (char *)va){
  80326f:	a1 30 50 80 00       	mov    0x805030,%eax
  803274:	3b 45 08             	cmp    0x8(%ebp),%eax
  803277:	73 1b                	jae    803294 <free_block+0x33>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
  803279:	a1 30 50 80 00       	mov    0x805030,%eax
  80327e:	83 ec 04             	sub    $0x4,%esp
  803281:	ff 75 08             	pushl  0x8(%ebp)
  803284:	6a 00                	push   $0x0
  803286:	50                   	push   %eax
  803287:	e8 b2 fb ff ff       	call   802e3e <merging>
  80328c:	83 c4 10             	add    $0x10,%esp
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  80328f:	e9 8b 00 00 00       	jmp    80331f <free_block+0xbe>
	struct BlockElement *prev_block = LIST_FIRST(&freeBlocksList);

	if((char *)LIST_LAST(&freeBlocksList) < (char *)va){
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
  803294:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803299:	3b 45 08             	cmp    0x8(%ebp),%eax
  80329c:	76 18                	jbe    8032b6 <free_block+0x55>
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
  80329e:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8032a3:	83 ec 04             	sub    $0x4,%esp
  8032a6:	ff 75 08             	pushl  0x8(%ebp)
  8032a9:	50                   	push   %eax
  8032aa:	6a 00                	push   $0x0
  8032ac:	e8 8d fb ff ff       	call   802e3e <merging>
  8032b1:	83 c4 10             	add    $0x10,%esp
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  8032b4:	eb 69                	jmp    80331f <free_block+0xbe>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
	}
	else LIST_FOREACH (prev_block, &freeBlocksList){
  8032b6:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8032bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8032be:	eb 39                	jmp    8032f9 <free_block+0x98>
		if((uint32 *)prev_block < (uint32 *)va && (uint32 *)prev_block->prev_next_info.le_next > (uint32 *)va ){
  8032c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032c3:	3b 45 08             	cmp    0x8(%ebp),%eax
  8032c6:	73 29                	jae    8032f1 <free_block+0x90>
  8032c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032cb:	8b 00                	mov    (%eax),%eax
  8032cd:	3b 45 08             	cmp    0x8(%ebp),%eax
  8032d0:	76 1f                	jbe    8032f1 <free_block+0x90>
			//get the address of prev and next
			struct BlockElement *next_block = LIST_NEXT(prev_block);
  8032d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032d5:	8b 00                	mov    (%eax),%eax
  8032d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
			merging(prev_block, next_block, va);
  8032da:	83 ec 04             	sub    $0x4,%esp
  8032dd:	ff 75 08             	pushl  0x8(%ebp)
  8032e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8032e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8032e6:	e8 53 fb ff ff       	call   802e3e <merging>
  8032eb:	83 c4 10             	add    $0x10,%esp
			break;
  8032ee:	90                   	nop
		}
	}
}
  8032ef:	eb 2e                	jmp    80331f <free_block+0xbe>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
	}
	else LIST_FOREACH (prev_block, &freeBlocksList){
  8032f1:	a1 34 50 80 00       	mov    0x805034,%eax
  8032f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8032f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8032fd:	74 07                	je     803306 <free_block+0xa5>
  8032ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803302:	8b 00                	mov    (%eax),%eax
  803304:	eb 05                	jmp    80330b <free_block+0xaa>
  803306:	b8 00 00 00 00       	mov    $0x0,%eax
  80330b:	a3 34 50 80 00       	mov    %eax,0x805034
  803310:	a1 34 50 80 00       	mov    0x805034,%eax
  803315:	85 c0                	test   %eax,%eax
  803317:	75 a7                	jne    8032c0 <free_block+0x5f>
  803319:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80331d:	75 a1                	jne    8032c0 <free_block+0x5f>
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  80331f:	90                   	nop
  803320:	c9                   	leave  
  803321:	c3                   	ret    

00803322 <copy_data>:

//=========================================
// [6] REALLOCATE BLOCK BY FIRST FIT:
//=========================================
void copy_data(void *va, void *new_va)
{
  803322:	55                   	push   %ebp
  803323:	89 e5                	mov    %esp,%ebp
  803325:	83 ec 10             	sub    $0x10,%esp
	uint32 va_size = get_block_size(va);
  803328:	ff 75 08             	pushl  0x8(%ebp)
  80332b:	e8 10 ed ff ff       	call   802040 <get_block_size>
  803330:	83 c4 04             	add    $0x4,%esp
  803333:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for(int i = 0; i < va_size; i++) *((char *)new_va + i) = *((char *)va + i);
  803336:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80333d:	eb 17                	jmp    803356 <copy_data+0x34>
  80333f:	8b 55 fc             	mov    -0x4(%ebp),%edx
  803342:	8b 45 0c             	mov    0xc(%ebp),%eax
  803345:	01 c2                	add    %eax,%edx
  803347:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80334a:	8b 45 08             	mov    0x8(%ebp),%eax
  80334d:	01 c8                	add    %ecx,%eax
  80334f:	8a 00                	mov    (%eax),%al
  803351:	88 02                	mov    %al,(%edx)
  803353:	ff 45 fc             	incl   -0x4(%ebp)
  803356:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803359:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  80335c:	72 e1                	jb     80333f <copy_data+0x1d>
}
  80335e:	90                   	nop
  80335f:	c9                   	leave  
  803360:	c3                   	ret    

00803361 <realloc_block_FF>:

void *realloc_block_FF(void* va, uint32 new_size)
{
  803361:	55                   	push   %ebp
  803362:	89 e5                	mov    %esp,%ebp
  803364:	83 ec 58             	sub    $0x58,%esp
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("realloc_block_FF is not implemented yet");
	//Your Code is Here...


	if(va == NULL)
  803367:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80336b:	75 23                	jne    803390 <realloc_block_FF+0x2f>
	{
		if(new_size != 0) return alloc_block_FF(new_size);
  80336d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803371:	74 13                	je     803386 <realloc_block_FF+0x25>
  803373:	83 ec 0c             	sub    $0xc,%esp
  803376:	ff 75 0c             	pushl  0xc(%ebp)
  803379:	e8 42 f0 ff ff       	call   8023c0 <alloc_block_FF>
  80337e:	83 c4 10             	add    $0x10,%esp
  803381:	e9 e4 06 00 00       	jmp    803a6a <realloc_block_FF+0x709>
		return NULL;
  803386:	b8 00 00 00 00       	mov    $0x0,%eax
  80338b:	e9 da 06 00 00       	jmp    803a6a <realloc_block_FF+0x709>
	}

	if(new_size == 0)
  803390:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803394:	75 18                	jne    8033ae <realloc_block_FF+0x4d>
	{
		free_block(va);
  803396:	83 ec 0c             	sub    $0xc,%esp
  803399:	ff 75 08             	pushl  0x8(%ebp)
  80339c:	e8 c0 fe ff ff       	call   803261 <free_block>
  8033a1:	83 c4 10             	add    $0x10,%esp
		return NULL;
  8033a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8033a9:	e9 bc 06 00 00       	jmp    803a6a <realloc_block_FF+0x709>
	}


	if(new_size < 8) new_size = 8;
  8033ae:	83 7d 0c 07          	cmpl   $0x7,0xc(%ebp)
  8033b2:	77 07                	ja     8033bb <realloc_block_FF+0x5a>
  8033b4:	c7 45 0c 08 00 00 00 	movl   $0x8,0xc(%ebp)
	new_size += (new_size % 2);
  8033bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033be:	83 e0 01             	and    $0x1,%eax
  8033c1:	01 45 0c             	add    %eax,0xc(%ebp)

	//cur Block data
	uint32 newBLOCK_size = new_size + 8;
  8033c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033c7:	83 c0 08             	add    $0x8,%eax
  8033ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 curBLOCK_size = get_block_size(va) /*BLOCK size in Bytes*/;
  8033cd:	83 ec 0c             	sub    $0xc,%esp
  8033d0:	ff 75 08             	pushl  0x8(%ebp)
  8033d3:	e8 68 ec ff ff       	call   802040 <get_block_size>
  8033d8:	83 c4 10             	add    $0x10,%esp
  8033db:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uint32 cur_size = curBLOCK_size - 8 /*8 Bytes = (Header + Footer) size*/;
  8033de:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8033e1:	83 e8 08             	sub    $0x8,%eax
  8033e4:	89 45 e8             	mov    %eax,-0x18(%ebp)

	//next Block data
	void *next_va = (void *)(FOOTER(va) + 2);
  8033e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8033ea:	83 e8 04             	sub    $0x4,%eax
  8033ed:	8b 00                	mov    (%eax),%eax
  8033ef:	83 e0 fe             	and    $0xfffffffe,%eax
  8033f2:	89 c2                	mov    %eax,%edx
  8033f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8033f7:	01 d0                	add    %edx,%eax
  8033f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32 nextBLOCK_size = get_block_size(next_va)/*&is_free_block(next_block_va)*/; //=0 if not free
  8033fc:	83 ec 0c             	sub    $0xc,%esp
  8033ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  803402:	e8 39 ec ff ff       	call   802040 <get_block_size>
  803407:	83 c4 10             	add    $0x10,%esp
  80340a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32 next_cur_size = nextBLOCK_size - 8 /*8 Bytes = (Header + Footer) size*/;
  80340d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803410:	83 e8 08             	sub    $0x8,%eax
  803413:	89 45 dc             	mov    %eax,-0x24(%ebp)


	//if the user needs the same size he owns
	if(new_size == cur_size)
  803416:	8b 45 0c             	mov    0xc(%ebp),%eax
  803419:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  80341c:	75 08                	jne    803426 <realloc_block_FF+0xc5>
	{
		 return va;
  80341e:	8b 45 08             	mov    0x8(%ebp),%eax
  803421:	e9 44 06 00 00       	jmp    803a6a <realloc_block_FF+0x709>

	}


	if(new_size < cur_size)
  803426:	8b 45 0c             	mov    0xc(%ebp),%eax
  803429:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  80342c:	0f 83 d5 03 00 00    	jae    803807 <realloc_block_FF+0x4a6>
	{
		uint32 remaining_size = cur_size - new_size; //remaining size in single Bytes
  803432:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803435:	2b 45 0c             	sub    0xc(%ebp),%eax
  803438:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if(is_free_block(next_va))
  80343b:	83 ec 0c             	sub    $0xc,%esp
  80343e:	ff 75 e4             	pushl  -0x1c(%ebp)
  803441:	e8 13 ec ff ff       	call   802059 <is_free_block>
  803446:	83 c4 10             	add    $0x10,%esp
  803449:	84 c0                	test   %al,%al
  80344b:	0f 84 3b 01 00 00    	je     80358c <realloc_block_FF+0x22b>
		{

			uint32 next_newBLOCK_size = nextBLOCK_size + remaining_size;
  803451:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803454:	8b 45 d8             	mov    -0x28(%ebp),%eax
  803457:	01 d0                	add    %edx,%eax
  803459:	89 45 cc             	mov    %eax,-0x34(%ebp)
			set_block_data(va, newBLOCK_size, 1);
  80345c:	83 ec 04             	sub    $0x4,%esp
  80345f:	6a 01                	push   $0x1
  803461:	ff 75 f0             	pushl  -0x10(%ebp)
  803464:	ff 75 08             	pushl  0x8(%ebp)
  803467:	e8 25 ef ff ff       	call   802391 <set_block_data>
  80346c:	83 c4 10             	add    $0x10,%esp
			void *next_new_va = (void *)(FOOTER(va) + 2);
  80346f:	8b 45 08             	mov    0x8(%ebp),%eax
  803472:	83 e8 04             	sub    $0x4,%eax
  803475:	8b 00                	mov    (%eax),%eax
  803477:	83 e0 fe             	and    $0xfffffffe,%eax
  80347a:	89 c2                	mov    %eax,%edx
  80347c:	8b 45 08             	mov    0x8(%ebp),%eax
  80347f:	01 d0                	add    %edx,%eax
  803481:	89 45 c8             	mov    %eax,-0x38(%ebp)
			set_block_data(next_new_va, next_newBLOCK_size, 0);
  803484:	83 ec 04             	sub    $0x4,%esp
  803487:	6a 00                	push   $0x0
  803489:	ff 75 cc             	pushl  -0x34(%ebp)
  80348c:	ff 75 c8             	pushl  -0x38(%ebp)
  80348f:	e8 fd ee ff ff       	call   802391 <set_block_data>
  803494:	83 c4 10             	add    $0x10,%esp
			LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement*)next_va, (struct BlockElement*)next_new_va);
  803497:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80349b:	74 06                	je     8034a3 <realloc_block_FF+0x142>
  80349d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8034a1:	75 17                	jne    8034ba <realloc_block_FF+0x159>
  8034a3:	83 ec 04             	sub    $0x4,%esp
  8034a6:	68 f4 45 80 00       	push   $0x8045f4
  8034ab:	68 f6 01 00 00       	push   $0x1f6
  8034b0:	68 81 45 80 00       	push   $0x804581
  8034b5:	e8 37 cf ff ff       	call   8003f1 <_panic>
  8034ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034bd:	8b 10                	mov    (%eax),%edx
  8034bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8034c2:	89 10                	mov    %edx,(%eax)
  8034c4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8034c7:	8b 00                	mov    (%eax),%eax
  8034c9:	85 c0                	test   %eax,%eax
  8034cb:	74 0b                	je     8034d8 <realloc_block_FF+0x177>
  8034cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034d0:	8b 00                	mov    (%eax),%eax
  8034d2:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8034d5:	89 50 04             	mov    %edx,0x4(%eax)
  8034d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034db:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8034de:	89 10                	mov    %edx,(%eax)
  8034e0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8034e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8034e6:	89 50 04             	mov    %edx,0x4(%eax)
  8034e9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8034ec:	8b 00                	mov    (%eax),%eax
  8034ee:	85 c0                	test   %eax,%eax
  8034f0:	75 08                	jne    8034fa <realloc_block_FF+0x199>
  8034f2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8034f5:	a3 30 50 80 00       	mov    %eax,0x805030
  8034fa:	a1 38 50 80 00       	mov    0x805038,%eax
  8034ff:	40                   	inc    %eax
  803500:	a3 38 50 80 00       	mov    %eax,0x805038
			LIST_REMOVE(&freeBlocksList, (struct BlockElement*)next_va);
  803505:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  803509:	75 17                	jne    803522 <realloc_block_FF+0x1c1>
  80350b:	83 ec 04             	sub    $0x4,%esp
  80350e:	68 63 45 80 00       	push   $0x804563
  803513:	68 f7 01 00 00       	push   $0x1f7
  803518:	68 81 45 80 00       	push   $0x804581
  80351d:	e8 cf ce ff ff       	call   8003f1 <_panic>
  803522:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803525:	8b 00                	mov    (%eax),%eax
  803527:	85 c0                	test   %eax,%eax
  803529:	74 10                	je     80353b <realloc_block_FF+0x1da>
  80352b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80352e:	8b 00                	mov    (%eax),%eax
  803530:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803533:	8b 52 04             	mov    0x4(%edx),%edx
  803536:	89 50 04             	mov    %edx,0x4(%eax)
  803539:	eb 0b                	jmp    803546 <realloc_block_FF+0x1e5>
  80353b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80353e:	8b 40 04             	mov    0x4(%eax),%eax
  803541:	a3 30 50 80 00       	mov    %eax,0x805030
  803546:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803549:	8b 40 04             	mov    0x4(%eax),%eax
  80354c:	85 c0                	test   %eax,%eax
  80354e:	74 0f                	je     80355f <realloc_block_FF+0x1fe>
  803550:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803553:	8b 40 04             	mov    0x4(%eax),%eax
  803556:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803559:	8b 12                	mov    (%edx),%edx
  80355b:	89 10                	mov    %edx,(%eax)
  80355d:	eb 0a                	jmp    803569 <realloc_block_FF+0x208>
  80355f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803562:	8b 00                	mov    (%eax),%eax
  803564:	a3 2c 50 80 00       	mov    %eax,0x80502c
  803569:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80356c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803572:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803575:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80357c:	a1 38 50 80 00       	mov    0x805038,%eax
  803581:	48                   	dec    %eax
  803582:	a3 38 50 80 00       	mov    %eax,0x805038
  803587:	e9 73 02 00 00       	jmp    8037ff <realloc_block_FF+0x49e>
		}
		else
		{
			if(remaining_size>=16)
  80358c:	83 7d d8 0f          	cmpl   $0xf,-0x28(%ebp)
  803590:	0f 86 69 02 00 00    	jbe    8037ff <realloc_block_FF+0x49e>
			{
				//uint32 next_new_size = remaining_size - 8;/*+ next_cur_size&is_free_block(next_cur_va)*/
				set_block_data(va, newBLOCK_size, 1);
  803596:	83 ec 04             	sub    $0x4,%esp
  803599:	6a 01                	push   $0x1
  80359b:	ff 75 f0             	pushl  -0x10(%ebp)
  80359e:	ff 75 08             	pushl  0x8(%ebp)
  8035a1:	e8 eb ed ff ff       	call   802391 <set_block_data>
  8035a6:	83 c4 10             	add    $0x10,%esp
				void *next_new_va = (void *)(FOOTER(va) + 2);
  8035a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8035ac:	83 e8 04             	sub    $0x4,%eax
  8035af:	8b 00                	mov    (%eax),%eax
  8035b1:	83 e0 fe             	and    $0xfffffffe,%eax
  8035b4:	89 c2                	mov    %eax,%edx
  8035b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8035b9:	01 d0                	add    %edx,%eax
  8035bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

				//insert new block to free_block_list
				uint32 list_size = LIST_SIZE(&freeBlocksList);
  8035be:	a1 38 50 80 00       	mov    0x805038,%eax
  8035c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
				if(list_size == 0)
  8035c6:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8035ca:	75 68                	jne    803634 <realloc_block_FF+0x2d3>
				{

					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement *)next_new_va);
  8035cc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8035d0:	75 17                	jne    8035e9 <realloc_block_FF+0x288>
  8035d2:	83 ec 04             	sub    $0x4,%esp
  8035d5:	68 9c 45 80 00       	push   $0x80459c
  8035da:	68 06 02 00 00       	push   $0x206
  8035df:	68 81 45 80 00       	push   $0x804581
  8035e4:	e8 08 ce ff ff       	call   8003f1 <_panic>
  8035e9:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  8035ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8035f2:	89 10                	mov    %edx,(%eax)
  8035f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8035f7:	8b 00                	mov    (%eax),%eax
  8035f9:	85 c0                	test   %eax,%eax
  8035fb:	74 0d                	je     80360a <realloc_block_FF+0x2a9>
  8035fd:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803602:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  803605:	89 50 04             	mov    %edx,0x4(%eax)
  803608:	eb 08                	jmp    803612 <realloc_block_FF+0x2b1>
  80360a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80360d:	a3 30 50 80 00       	mov    %eax,0x805030
  803612:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803615:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80361a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80361d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803624:	a1 38 50 80 00       	mov    0x805038,%eax
  803629:	40                   	inc    %eax
  80362a:	a3 38 50 80 00       	mov    %eax,0x805038
  80362f:	e9 b0 01 00 00       	jmp    8037e4 <realloc_block_FF+0x483>
				}
				else if((struct BlockElement *)next_new_va < LIST_FIRST(&freeBlocksList))
  803634:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803639:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  80363c:	76 68                	jbe    8036a6 <realloc_block_FF+0x345>
				{

					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement *)next_new_va);
  80363e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  803642:	75 17                	jne    80365b <realloc_block_FF+0x2fa>
  803644:	83 ec 04             	sub    $0x4,%esp
  803647:	68 9c 45 80 00       	push   $0x80459c
  80364c:	68 0b 02 00 00       	push   $0x20b
  803651:	68 81 45 80 00       	push   $0x804581
  803656:	e8 96 cd ff ff       	call   8003f1 <_panic>
  80365b:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  803661:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803664:	89 10                	mov    %edx,(%eax)
  803666:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803669:	8b 00                	mov    (%eax),%eax
  80366b:	85 c0                	test   %eax,%eax
  80366d:	74 0d                	je     80367c <realloc_block_FF+0x31b>
  80366f:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803674:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  803677:	89 50 04             	mov    %edx,0x4(%eax)
  80367a:	eb 08                	jmp    803684 <realloc_block_FF+0x323>
  80367c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80367f:	a3 30 50 80 00       	mov    %eax,0x805030
  803684:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803687:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80368c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80368f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803696:	a1 38 50 80 00       	mov    0x805038,%eax
  80369b:	40                   	inc    %eax
  80369c:	a3 38 50 80 00       	mov    %eax,0x805038
  8036a1:	e9 3e 01 00 00       	jmp    8037e4 <realloc_block_FF+0x483>
				}
				else if(LIST_FIRST(&freeBlocksList) < (struct BlockElement *)next_new_va)
  8036a6:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8036ab:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  8036ae:	73 68                	jae    803718 <realloc_block_FF+0x3b7>
				{

					LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement *)next_new_va);
  8036b0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8036b4:	75 17                	jne    8036cd <realloc_block_FF+0x36c>
  8036b6:	83 ec 04             	sub    $0x4,%esp
  8036b9:	68 d0 45 80 00       	push   $0x8045d0
  8036be:	68 10 02 00 00       	push   $0x210
  8036c3:	68 81 45 80 00       	push   $0x804581
  8036c8:	e8 24 cd ff ff       	call   8003f1 <_panic>
  8036cd:	8b 15 30 50 80 00    	mov    0x805030,%edx
  8036d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8036d6:	89 50 04             	mov    %edx,0x4(%eax)
  8036d9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8036dc:	8b 40 04             	mov    0x4(%eax),%eax
  8036df:	85 c0                	test   %eax,%eax
  8036e1:	74 0c                	je     8036ef <realloc_block_FF+0x38e>
  8036e3:	a1 30 50 80 00       	mov    0x805030,%eax
  8036e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8036eb:	89 10                	mov    %edx,(%eax)
  8036ed:	eb 08                	jmp    8036f7 <realloc_block_FF+0x396>
  8036ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8036f2:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8036f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8036fa:	a3 30 50 80 00       	mov    %eax,0x805030
  8036ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803702:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803708:	a1 38 50 80 00       	mov    0x805038,%eax
  80370d:	40                   	inc    %eax
  80370e:	a3 38 50 80 00       	mov    %eax,0x805038
  803713:	e9 cc 00 00 00       	jmp    8037e4 <realloc_block_FF+0x483>
				}
				else
				{

					struct BlockElement *blk = NULL;
  803718:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
					LIST_FOREACH(blk, &freeBlocksList)
  80371f:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803724:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803727:	e9 8a 00 00 00       	jmp    8037b6 <realloc_block_FF+0x455>
					{
						if(blk < (struct BlockElement *)next_new_va && LIST_NEXT(blk) < (struct BlockElement *)next_new_va)
  80372c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80372f:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  803732:	73 7a                	jae    8037ae <realloc_block_FF+0x44d>
  803734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803737:	8b 00                	mov    (%eax),%eax
  803739:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  80373c:	73 70                	jae    8037ae <realloc_block_FF+0x44d>
						{
							LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement *)next_new_va);
  80373e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803742:	74 06                	je     80374a <realloc_block_FF+0x3e9>
  803744:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  803748:	75 17                	jne    803761 <realloc_block_FF+0x400>
  80374a:	83 ec 04             	sub    $0x4,%esp
  80374d:	68 f4 45 80 00       	push   $0x8045f4
  803752:	68 1a 02 00 00       	push   $0x21a
  803757:	68 81 45 80 00       	push   $0x804581
  80375c:	e8 90 cc ff ff       	call   8003f1 <_panic>
  803761:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803764:	8b 10                	mov    (%eax),%edx
  803766:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803769:	89 10                	mov    %edx,(%eax)
  80376b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80376e:	8b 00                	mov    (%eax),%eax
  803770:	85 c0                	test   %eax,%eax
  803772:	74 0b                	je     80377f <realloc_block_FF+0x41e>
  803774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803777:	8b 00                	mov    (%eax),%eax
  803779:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80377c:	89 50 04             	mov    %edx,0x4(%eax)
  80377f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803782:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  803785:	89 10                	mov    %edx,(%eax)
  803787:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80378a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80378d:	89 50 04             	mov    %edx,0x4(%eax)
  803790:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803793:	8b 00                	mov    (%eax),%eax
  803795:	85 c0                	test   %eax,%eax
  803797:	75 08                	jne    8037a1 <realloc_block_FF+0x440>
  803799:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80379c:	a3 30 50 80 00       	mov    %eax,0x805030
  8037a1:	a1 38 50 80 00       	mov    0x805038,%eax
  8037a6:	40                   	inc    %eax
  8037a7:	a3 38 50 80 00       	mov    %eax,0x805038
							break;
  8037ac:	eb 36                	jmp    8037e4 <realloc_block_FF+0x483>
				}
				else
				{

					struct BlockElement *blk = NULL;
					LIST_FOREACH(blk, &freeBlocksList)
  8037ae:	a1 34 50 80 00       	mov    0x805034,%eax
  8037b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8037b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8037ba:	74 07                	je     8037c3 <realloc_block_FF+0x462>
  8037bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037bf:	8b 00                	mov    (%eax),%eax
  8037c1:	eb 05                	jmp    8037c8 <realloc_block_FF+0x467>
  8037c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8037c8:	a3 34 50 80 00       	mov    %eax,0x805034
  8037cd:	a1 34 50 80 00       	mov    0x805034,%eax
  8037d2:	85 c0                	test   %eax,%eax
  8037d4:	0f 85 52 ff ff ff    	jne    80372c <realloc_block_FF+0x3cb>
  8037da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8037de:	0f 85 48 ff ff ff    	jne    80372c <realloc_block_FF+0x3cb>
							LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement *)next_new_va);
							break;
						}
					}
				}
				set_block_data(next_new_va, remaining_size, 0);
  8037e4:	83 ec 04             	sub    $0x4,%esp
  8037e7:	6a 00                	push   $0x0
  8037e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8037ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8037ef:	e8 9d eb ff ff       	call   802391 <set_block_data>
  8037f4:	83 c4 10             	add    $0x10,%esp
				return va;
  8037f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8037fa:	e9 6b 02 00 00       	jmp    803a6a <realloc_block_FF+0x709>
			}
			
		}
		return va;
  8037ff:	8b 45 08             	mov    0x8(%ebp),%eax
  803802:	e9 63 02 00 00       	jmp    803a6a <realloc_block_FF+0x709>
	}

	if(new_size > cur_size)
  803807:	8b 45 0c             	mov    0xc(%ebp),%eax
  80380a:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  80380d:	0f 86 4d 02 00 00    	jbe    803a60 <realloc_block_FF+0x6ff>
	{
		if(is_free_block(next_va))
  803813:	83 ec 0c             	sub    $0xc,%esp
  803816:	ff 75 e4             	pushl  -0x1c(%ebp)
  803819:	e8 3b e8 ff ff       	call   802059 <is_free_block>
  80381e:	83 c4 10             	add    $0x10,%esp
  803821:	84 c0                	test   %al,%al
  803823:	0f 84 37 02 00 00    	je     803a60 <realloc_block_FF+0x6ff>
		{

			uint32 needed_size = new_size - cur_size; //needed size in single Bytes
  803829:	8b 45 0c             	mov    0xc(%ebp),%eax
  80382c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80382f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			if(needed_size > nextBLOCK_size)
  803832:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  803835:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  803838:	76 38                	jbe    803872 <realloc_block_FF+0x511>
			{
				void *new_va = alloc_block_FF(new_size); //new allocation
  80383a:	83 ec 0c             	sub    $0xc,%esp
  80383d:	ff 75 0c             	pushl  0xc(%ebp)
  803840:	e8 7b eb ff ff       	call   8023c0 <alloc_block_FF>
  803845:	83 c4 10             	add    $0x10,%esp
  803848:	89 45 c0             	mov    %eax,-0x40(%ebp)
				copy_data(va, new_va); //transfer data
  80384b:	83 ec 08             	sub    $0x8,%esp
  80384e:	ff 75 c0             	pushl  -0x40(%ebp)
  803851:	ff 75 08             	pushl  0x8(%ebp)
  803854:	e8 c9 fa ff ff       	call   803322 <copy_data>
  803859:	83 c4 10             	add    $0x10,%esp
				free_block(va); //set it free
  80385c:	83 ec 0c             	sub    $0xc,%esp
  80385f:	ff 75 08             	pushl  0x8(%ebp)
  803862:	e8 fa f9 ff ff       	call   803261 <free_block>
  803867:	83 c4 10             	add    $0x10,%esp
				return new_va;
  80386a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80386d:	e9 f8 01 00 00       	jmp    803a6a <realloc_block_FF+0x709>
			}
			uint32 remaining_size = nextBLOCK_size - needed_size;
  803872:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803875:	2b 45 c4             	sub    -0x3c(%ebp),%eax
  803878:	89 45 bc             	mov    %eax,-0x44(%ebp)
			if(remaining_size < 16) //merge next block to my cur block
  80387b:	83 7d bc 0f          	cmpl   $0xf,-0x44(%ebp)
  80387f:	0f 87 a0 00 00 00    	ja     803925 <realloc_block_FF+0x5c4>
			{
				//remove from free_block_list, then
				LIST_REMOVE(&freeBlocksList, (struct BlockElement *)next_va);
  803885:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  803889:	75 17                	jne    8038a2 <realloc_block_FF+0x541>
  80388b:	83 ec 04             	sub    $0x4,%esp
  80388e:	68 63 45 80 00       	push   $0x804563
  803893:	68 38 02 00 00       	push   $0x238
  803898:	68 81 45 80 00       	push   $0x804581
  80389d:	e8 4f cb ff ff       	call   8003f1 <_panic>
  8038a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038a5:	8b 00                	mov    (%eax),%eax
  8038a7:	85 c0                	test   %eax,%eax
  8038a9:	74 10                	je     8038bb <realloc_block_FF+0x55a>
  8038ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038ae:	8b 00                	mov    (%eax),%eax
  8038b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8038b3:	8b 52 04             	mov    0x4(%edx),%edx
  8038b6:	89 50 04             	mov    %edx,0x4(%eax)
  8038b9:	eb 0b                	jmp    8038c6 <realloc_block_FF+0x565>
  8038bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038be:	8b 40 04             	mov    0x4(%eax),%eax
  8038c1:	a3 30 50 80 00       	mov    %eax,0x805030
  8038c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038c9:	8b 40 04             	mov    0x4(%eax),%eax
  8038cc:	85 c0                	test   %eax,%eax
  8038ce:	74 0f                	je     8038df <realloc_block_FF+0x57e>
  8038d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038d3:	8b 40 04             	mov    0x4(%eax),%eax
  8038d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8038d9:	8b 12                	mov    (%edx),%edx
  8038db:	89 10                	mov    %edx,(%eax)
  8038dd:	eb 0a                	jmp    8038e9 <realloc_block_FF+0x588>
  8038df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038e2:	8b 00                	mov    (%eax),%eax
  8038e4:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8038e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8038f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038f5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8038fc:	a1 38 50 80 00       	mov    0x805038,%eax
  803901:	48                   	dec    %eax
  803902:	a3 38 50 80 00       	mov    %eax,0x805038

				//set block
				set_block_data(va, curBLOCK_size + nextBLOCK_size, 1);
  803907:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80390a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80390d:	01 d0                	add    %edx,%eax
  80390f:	83 ec 04             	sub    $0x4,%esp
  803912:	6a 01                	push   $0x1
  803914:	50                   	push   %eax
  803915:	ff 75 08             	pushl  0x8(%ebp)
  803918:	e8 74 ea ff ff       	call   802391 <set_block_data>
  80391d:	83 c4 10             	add    $0x10,%esp
  803920:	e9 36 01 00 00       	jmp    803a5b <realloc_block_FF+0x6fa>
			}
			else
			{
				newBLOCK_size = curBLOCK_size + needed_size;
  803925:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803928:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80392b:	01 d0                	add    %edx,%eax
  80392d:	89 45 f0             	mov    %eax,-0x10(%ebp)
				set_block_data(va, newBLOCK_size, 1);
  803930:	83 ec 04             	sub    $0x4,%esp
  803933:	6a 01                	push   $0x1
  803935:	ff 75 f0             	pushl  -0x10(%ebp)
  803938:	ff 75 08             	pushl  0x8(%ebp)
  80393b:	e8 51 ea ff ff       	call   802391 <set_block_data>
  803940:	83 c4 10             	add    $0x10,%esp
				void *next_new_va = (void *)(FOOTER(va) + 2);
  803943:	8b 45 08             	mov    0x8(%ebp),%eax
  803946:	83 e8 04             	sub    $0x4,%eax
  803949:	8b 00                	mov    (%eax),%eax
  80394b:	83 e0 fe             	and    $0xfffffffe,%eax
  80394e:	89 c2                	mov    %eax,%edx
  803950:	8b 45 08             	mov    0x8(%ebp),%eax
  803953:	01 d0                	add    %edx,%eax
  803955:	89 45 b8             	mov    %eax,-0x48(%ebp)

				//update free_block_list
				LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement*)next_va, (struct BlockElement*)next_new_va);
  803958:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80395c:	74 06                	je     803964 <realloc_block_FF+0x603>
  80395e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  803962:	75 17                	jne    80397b <realloc_block_FF+0x61a>
  803964:	83 ec 04             	sub    $0x4,%esp
  803967:	68 f4 45 80 00       	push   $0x8045f4
  80396c:	68 44 02 00 00       	push   $0x244
  803971:	68 81 45 80 00       	push   $0x804581
  803976:	e8 76 ca ff ff       	call   8003f1 <_panic>
  80397b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80397e:	8b 10                	mov    (%eax),%edx
  803980:	8b 45 b8             	mov    -0x48(%ebp),%eax
  803983:	89 10                	mov    %edx,(%eax)
  803985:	8b 45 b8             	mov    -0x48(%ebp),%eax
  803988:	8b 00                	mov    (%eax),%eax
  80398a:	85 c0                	test   %eax,%eax
  80398c:	74 0b                	je     803999 <realloc_block_FF+0x638>
  80398e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803991:	8b 00                	mov    (%eax),%eax
  803993:	8b 55 b8             	mov    -0x48(%ebp),%edx
  803996:	89 50 04             	mov    %edx,0x4(%eax)
  803999:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80399c:	8b 55 b8             	mov    -0x48(%ebp),%edx
  80399f:	89 10                	mov    %edx,(%eax)
  8039a1:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8039a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8039a7:	89 50 04             	mov    %edx,0x4(%eax)
  8039aa:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8039ad:	8b 00                	mov    (%eax),%eax
  8039af:	85 c0                	test   %eax,%eax
  8039b1:	75 08                	jne    8039bb <realloc_block_FF+0x65a>
  8039b3:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8039b6:	a3 30 50 80 00       	mov    %eax,0x805030
  8039bb:	a1 38 50 80 00       	mov    0x805038,%eax
  8039c0:	40                   	inc    %eax
  8039c1:	a3 38 50 80 00       	mov    %eax,0x805038
				LIST_REMOVE(&freeBlocksList, (struct BlockElement*)next_va);
  8039c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8039ca:	75 17                	jne    8039e3 <realloc_block_FF+0x682>
  8039cc:	83 ec 04             	sub    $0x4,%esp
  8039cf:	68 63 45 80 00       	push   $0x804563
  8039d4:	68 45 02 00 00       	push   $0x245
  8039d9:	68 81 45 80 00       	push   $0x804581
  8039de:	e8 0e ca ff ff       	call   8003f1 <_panic>
  8039e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8039e6:	8b 00                	mov    (%eax),%eax
  8039e8:	85 c0                	test   %eax,%eax
  8039ea:	74 10                	je     8039fc <realloc_block_FF+0x69b>
  8039ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8039ef:	8b 00                	mov    (%eax),%eax
  8039f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8039f4:	8b 52 04             	mov    0x4(%edx),%edx
  8039f7:	89 50 04             	mov    %edx,0x4(%eax)
  8039fa:	eb 0b                	jmp    803a07 <realloc_block_FF+0x6a6>
  8039fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8039ff:	8b 40 04             	mov    0x4(%eax),%eax
  803a02:	a3 30 50 80 00       	mov    %eax,0x805030
  803a07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803a0a:	8b 40 04             	mov    0x4(%eax),%eax
  803a0d:	85 c0                	test   %eax,%eax
  803a0f:	74 0f                	je     803a20 <realloc_block_FF+0x6bf>
  803a11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803a14:	8b 40 04             	mov    0x4(%eax),%eax
  803a17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803a1a:	8b 12                	mov    (%edx),%edx
  803a1c:	89 10                	mov    %edx,(%eax)
  803a1e:	eb 0a                	jmp    803a2a <realloc_block_FF+0x6c9>
  803a20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803a23:	8b 00                	mov    (%eax),%eax
  803a25:	a3 2c 50 80 00       	mov    %eax,0x80502c
  803a2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803a2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803a33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803a36:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803a3d:	a1 38 50 80 00       	mov    0x805038,%eax
  803a42:	48                   	dec    %eax
  803a43:	a3 38 50 80 00       	mov    %eax,0x805038
				set_block_data(next_new_va, remaining_size, 0);
  803a48:	83 ec 04             	sub    $0x4,%esp
  803a4b:	6a 00                	push   $0x0
  803a4d:	ff 75 bc             	pushl  -0x44(%ebp)
  803a50:	ff 75 b8             	pushl  -0x48(%ebp)
  803a53:	e8 39 e9 ff ff       	call   802391 <set_block_data>
  803a58:	83 c4 10             	add    $0x10,%esp
			}
			return va;
  803a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  803a5e:	eb 0a                	jmp    803a6a <realloc_block_FF+0x709>
		}
	}

	int abo_salah = 1; // abo salah NUMBER 1
  803a60:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
	return va;
  803a67:	8b 45 08             	mov    0x8(%ebp),%eax
}
  803a6a:	c9                   	leave  
  803a6b:	c3                   	ret    

00803a6c <alloc_block_WF>:
/*********************************************************************************************/
//=========================================
// [7] ALLOCATE BLOCK BY WORST FIT:
//=========================================
void *alloc_block_WF(uint32 size)
{
  803a6c:	55                   	push   %ebp
  803a6d:	89 e5                	mov    %esp,%ebp
  803a6f:	83 ec 08             	sub    $0x8,%esp
	panic("alloc_block_WF is not implemented yet");
  803a72:	83 ec 04             	sub    $0x4,%esp
  803a75:	68 60 46 80 00       	push   $0x804660
  803a7a:	68 58 02 00 00       	push   $0x258
  803a7f:	68 81 45 80 00       	push   $0x804581
  803a84:	e8 68 c9 ff ff       	call   8003f1 <_panic>

00803a89 <alloc_block_NF>:

//=========================================
// [8] ALLOCATE BLOCK BY NEXT FIT:
//=========================================
void *alloc_block_NF(uint32 size)
{
  803a89:	55                   	push   %ebp
  803a8a:	89 e5                	mov    %esp,%ebp
  803a8c:	83 ec 08             	sub    $0x8,%esp
	panic("alloc_block_NF is not implemented yet");
  803a8f:	83 ec 04             	sub    $0x4,%esp
  803a92:	68 88 46 80 00       	push   $0x804688
  803a97:	68 61 02 00 00       	push   $0x261
  803a9c:	68 81 45 80 00       	push   $0x804581
  803aa1:	e8 4b c9 ff ff       	call   8003f1 <_panic>
  803aa6:	66 90                	xchg   %ax,%ax

00803aa8 <__udivdi3>:
  803aa8:	55                   	push   %ebp
  803aa9:	57                   	push   %edi
  803aaa:	56                   	push   %esi
  803aab:	53                   	push   %ebx
  803aac:	83 ec 1c             	sub    $0x1c,%esp
  803aaf:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  803ab3:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803ab7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803abb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803abf:	89 ca                	mov    %ecx,%edx
  803ac1:	89 f8                	mov    %edi,%eax
  803ac3:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  803ac7:	85 f6                	test   %esi,%esi
  803ac9:	75 2d                	jne    803af8 <__udivdi3+0x50>
  803acb:	39 cf                	cmp    %ecx,%edi
  803acd:	77 65                	ja     803b34 <__udivdi3+0x8c>
  803acf:	89 fd                	mov    %edi,%ebp
  803ad1:	85 ff                	test   %edi,%edi
  803ad3:	75 0b                	jne    803ae0 <__udivdi3+0x38>
  803ad5:	b8 01 00 00 00       	mov    $0x1,%eax
  803ada:	31 d2                	xor    %edx,%edx
  803adc:	f7 f7                	div    %edi
  803ade:	89 c5                	mov    %eax,%ebp
  803ae0:	31 d2                	xor    %edx,%edx
  803ae2:	89 c8                	mov    %ecx,%eax
  803ae4:	f7 f5                	div    %ebp
  803ae6:	89 c1                	mov    %eax,%ecx
  803ae8:	89 d8                	mov    %ebx,%eax
  803aea:	f7 f5                	div    %ebp
  803aec:	89 cf                	mov    %ecx,%edi
  803aee:	89 fa                	mov    %edi,%edx
  803af0:	83 c4 1c             	add    $0x1c,%esp
  803af3:	5b                   	pop    %ebx
  803af4:	5e                   	pop    %esi
  803af5:	5f                   	pop    %edi
  803af6:	5d                   	pop    %ebp
  803af7:	c3                   	ret    
  803af8:	39 ce                	cmp    %ecx,%esi
  803afa:	77 28                	ja     803b24 <__udivdi3+0x7c>
  803afc:	0f bd fe             	bsr    %esi,%edi
  803aff:	83 f7 1f             	xor    $0x1f,%edi
  803b02:	75 40                	jne    803b44 <__udivdi3+0x9c>
  803b04:	39 ce                	cmp    %ecx,%esi
  803b06:	72 0a                	jb     803b12 <__udivdi3+0x6a>
  803b08:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803b0c:	0f 87 9e 00 00 00    	ja     803bb0 <__udivdi3+0x108>
  803b12:	b8 01 00 00 00       	mov    $0x1,%eax
  803b17:	89 fa                	mov    %edi,%edx
  803b19:	83 c4 1c             	add    $0x1c,%esp
  803b1c:	5b                   	pop    %ebx
  803b1d:	5e                   	pop    %esi
  803b1e:	5f                   	pop    %edi
  803b1f:	5d                   	pop    %ebp
  803b20:	c3                   	ret    
  803b21:	8d 76 00             	lea    0x0(%esi),%esi
  803b24:	31 ff                	xor    %edi,%edi
  803b26:	31 c0                	xor    %eax,%eax
  803b28:	89 fa                	mov    %edi,%edx
  803b2a:	83 c4 1c             	add    $0x1c,%esp
  803b2d:	5b                   	pop    %ebx
  803b2e:	5e                   	pop    %esi
  803b2f:	5f                   	pop    %edi
  803b30:	5d                   	pop    %ebp
  803b31:	c3                   	ret    
  803b32:	66 90                	xchg   %ax,%ax
  803b34:	89 d8                	mov    %ebx,%eax
  803b36:	f7 f7                	div    %edi
  803b38:	31 ff                	xor    %edi,%edi
  803b3a:	89 fa                	mov    %edi,%edx
  803b3c:	83 c4 1c             	add    $0x1c,%esp
  803b3f:	5b                   	pop    %ebx
  803b40:	5e                   	pop    %esi
  803b41:	5f                   	pop    %edi
  803b42:	5d                   	pop    %ebp
  803b43:	c3                   	ret    
  803b44:	bd 20 00 00 00       	mov    $0x20,%ebp
  803b49:	89 eb                	mov    %ebp,%ebx
  803b4b:	29 fb                	sub    %edi,%ebx
  803b4d:	89 f9                	mov    %edi,%ecx
  803b4f:	d3 e6                	shl    %cl,%esi
  803b51:	89 c5                	mov    %eax,%ebp
  803b53:	88 d9                	mov    %bl,%cl
  803b55:	d3 ed                	shr    %cl,%ebp
  803b57:	89 e9                	mov    %ebp,%ecx
  803b59:	09 f1                	or     %esi,%ecx
  803b5b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803b5f:	89 f9                	mov    %edi,%ecx
  803b61:	d3 e0                	shl    %cl,%eax
  803b63:	89 c5                	mov    %eax,%ebp
  803b65:	89 d6                	mov    %edx,%esi
  803b67:	88 d9                	mov    %bl,%cl
  803b69:	d3 ee                	shr    %cl,%esi
  803b6b:	89 f9                	mov    %edi,%ecx
  803b6d:	d3 e2                	shl    %cl,%edx
  803b6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803b73:	88 d9                	mov    %bl,%cl
  803b75:	d3 e8                	shr    %cl,%eax
  803b77:	09 c2                	or     %eax,%edx
  803b79:	89 d0                	mov    %edx,%eax
  803b7b:	89 f2                	mov    %esi,%edx
  803b7d:	f7 74 24 0c          	divl   0xc(%esp)
  803b81:	89 d6                	mov    %edx,%esi
  803b83:	89 c3                	mov    %eax,%ebx
  803b85:	f7 e5                	mul    %ebp
  803b87:	39 d6                	cmp    %edx,%esi
  803b89:	72 19                	jb     803ba4 <__udivdi3+0xfc>
  803b8b:	74 0b                	je     803b98 <__udivdi3+0xf0>
  803b8d:	89 d8                	mov    %ebx,%eax
  803b8f:	31 ff                	xor    %edi,%edi
  803b91:	e9 58 ff ff ff       	jmp    803aee <__udivdi3+0x46>
  803b96:	66 90                	xchg   %ax,%ax
  803b98:	8b 54 24 08          	mov    0x8(%esp),%edx
  803b9c:	89 f9                	mov    %edi,%ecx
  803b9e:	d3 e2                	shl    %cl,%edx
  803ba0:	39 c2                	cmp    %eax,%edx
  803ba2:	73 e9                	jae    803b8d <__udivdi3+0xe5>
  803ba4:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803ba7:	31 ff                	xor    %edi,%edi
  803ba9:	e9 40 ff ff ff       	jmp    803aee <__udivdi3+0x46>
  803bae:	66 90                	xchg   %ax,%ax
  803bb0:	31 c0                	xor    %eax,%eax
  803bb2:	e9 37 ff ff ff       	jmp    803aee <__udivdi3+0x46>
  803bb7:	90                   	nop

00803bb8 <__umoddi3>:
  803bb8:	55                   	push   %ebp
  803bb9:	57                   	push   %edi
  803bba:	56                   	push   %esi
  803bbb:	53                   	push   %ebx
  803bbc:	83 ec 1c             	sub    $0x1c,%esp
  803bbf:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803bc3:	8b 74 24 34          	mov    0x34(%esp),%esi
  803bc7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803bcb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  803bcf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803bd3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803bd7:	89 f3                	mov    %esi,%ebx
  803bd9:	89 fa                	mov    %edi,%edx
  803bdb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803bdf:	89 34 24             	mov    %esi,(%esp)
  803be2:	85 c0                	test   %eax,%eax
  803be4:	75 1a                	jne    803c00 <__umoddi3+0x48>
  803be6:	39 f7                	cmp    %esi,%edi
  803be8:	0f 86 a2 00 00 00    	jbe    803c90 <__umoddi3+0xd8>
  803bee:	89 c8                	mov    %ecx,%eax
  803bf0:	89 f2                	mov    %esi,%edx
  803bf2:	f7 f7                	div    %edi
  803bf4:	89 d0                	mov    %edx,%eax
  803bf6:	31 d2                	xor    %edx,%edx
  803bf8:	83 c4 1c             	add    $0x1c,%esp
  803bfb:	5b                   	pop    %ebx
  803bfc:	5e                   	pop    %esi
  803bfd:	5f                   	pop    %edi
  803bfe:	5d                   	pop    %ebp
  803bff:	c3                   	ret    
  803c00:	39 f0                	cmp    %esi,%eax
  803c02:	0f 87 ac 00 00 00    	ja     803cb4 <__umoddi3+0xfc>
  803c08:	0f bd e8             	bsr    %eax,%ebp
  803c0b:	83 f5 1f             	xor    $0x1f,%ebp
  803c0e:	0f 84 ac 00 00 00    	je     803cc0 <__umoddi3+0x108>
  803c14:	bf 20 00 00 00       	mov    $0x20,%edi
  803c19:	29 ef                	sub    %ebp,%edi
  803c1b:	89 fe                	mov    %edi,%esi
  803c1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803c21:	89 e9                	mov    %ebp,%ecx
  803c23:	d3 e0                	shl    %cl,%eax
  803c25:	89 d7                	mov    %edx,%edi
  803c27:	89 f1                	mov    %esi,%ecx
  803c29:	d3 ef                	shr    %cl,%edi
  803c2b:	09 c7                	or     %eax,%edi
  803c2d:	89 e9                	mov    %ebp,%ecx
  803c2f:	d3 e2                	shl    %cl,%edx
  803c31:	89 14 24             	mov    %edx,(%esp)
  803c34:	89 d8                	mov    %ebx,%eax
  803c36:	d3 e0                	shl    %cl,%eax
  803c38:	89 c2                	mov    %eax,%edx
  803c3a:	8b 44 24 08          	mov    0x8(%esp),%eax
  803c3e:	d3 e0                	shl    %cl,%eax
  803c40:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c44:	8b 44 24 08          	mov    0x8(%esp),%eax
  803c48:	89 f1                	mov    %esi,%ecx
  803c4a:	d3 e8                	shr    %cl,%eax
  803c4c:	09 d0                	or     %edx,%eax
  803c4e:	d3 eb                	shr    %cl,%ebx
  803c50:	89 da                	mov    %ebx,%edx
  803c52:	f7 f7                	div    %edi
  803c54:	89 d3                	mov    %edx,%ebx
  803c56:	f7 24 24             	mull   (%esp)
  803c59:	89 c6                	mov    %eax,%esi
  803c5b:	89 d1                	mov    %edx,%ecx
  803c5d:	39 d3                	cmp    %edx,%ebx
  803c5f:	0f 82 87 00 00 00    	jb     803cec <__umoddi3+0x134>
  803c65:	0f 84 91 00 00 00    	je     803cfc <__umoddi3+0x144>
  803c6b:	8b 54 24 04          	mov    0x4(%esp),%edx
  803c6f:	29 f2                	sub    %esi,%edx
  803c71:	19 cb                	sbb    %ecx,%ebx
  803c73:	89 d8                	mov    %ebx,%eax
  803c75:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  803c79:	d3 e0                	shl    %cl,%eax
  803c7b:	89 e9                	mov    %ebp,%ecx
  803c7d:	d3 ea                	shr    %cl,%edx
  803c7f:	09 d0                	or     %edx,%eax
  803c81:	89 e9                	mov    %ebp,%ecx
  803c83:	d3 eb                	shr    %cl,%ebx
  803c85:	89 da                	mov    %ebx,%edx
  803c87:	83 c4 1c             	add    $0x1c,%esp
  803c8a:	5b                   	pop    %ebx
  803c8b:	5e                   	pop    %esi
  803c8c:	5f                   	pop    %edi
  803c8d:	5d                   	pop    %ebp
  803c8e:	c3                   	ret    
  803c8f:	90                   	nop
  803c90:	89 fd                	mov    %edi,%ebp
  803c92:	85 ff                	test   %edi,%edi
  803c94:	75 0b                	jne    803ca1 <__umoddi3+0xe9>
  803c96:	b8 01 00 00 00       	mov    $0x1,%eax
  803c9b:	31 d2                	xor    %edx,%edx
  803c9d:	f7 f7                	div    %edi
  803c9f:	89 c5                	mov    %eax,%ebp
  803ca1:	89 f0                	mov    %esi,%eax
  803ca3:	31 d2                	xor    %edx,%edx
  803ca5:	f7 f5                	div    %ebp
  803ca7:	89 c8                	mov    %ecx,%eax
  803ca9:	f7 f5                	div    %ebp
  803cab:	89 d0                	mov    %edx,%eax
  803cad:	e9 44 ff ff ff       	jmp    803bf6 <__umoddi3+0x3e>
  803cb2:	66 90                	xchg   %ax,%ax
  803cb4:	89 c8                	mov    %ecx,%eax
  803cb6:	89 f2                	mov    %esi,%edx
  803cb8:	83 c4 1c             	add    $0x1c,%esp
  803cbb:	5b                   	pop    %ebx
  803cbc:	5e                   	pop    %esi
  803cbd:	5f                   	pop    %edi
  803cbe:	5d                   	pop    %ebp
  803cbf:	c3                   	ret    
  803cc0:	3b 04 24             	cmp    (%esp),%eax
  803cc3:	72 06                	jb     803ccb <__umoddi3+0x113>
  803cc5:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  803cc9:	77 0f                	ja     803cda <__umoddi3+0x122>
  803ccb:	89 f2                	mov    %esi,%edx
  803ccd:	29 f9                	sub    %edi,%ecx
  803ccf:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  803cd3:	89 14 24             	mov    %edx,(%esp)
  803cd6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803cda:	8b 44 24 04          	mov    0x4(%esp),%eax
  803cde:	8b 14 24             	mov    (%esp),%edx
  803ce1:	83 c4 1c             	add    $0x1c,%esp
  803ce4:	5b                   	pop    %ebx
  803ce5:	5e                   	pop    %esi
  803ce6:	5f                   	pop    %edi
  803ce7:	5d                   	pop    %ebp
  803ce8:	c3                   	ret    
  803ce9:	8d 76 00             	lea    0x0(%esi),%esi
  803cec:	2b 04 24             	sub    (%esp),%eax
  803cef:	19 fa                	sbb    %edi,%edx
  803cf1:	89 d1                	mov    %edx,%ecx
  803cf3:	89 c6                	mov    %eax,%esi
  803cf5:	e9 71 ff ff ff       	jmp    803c6b <__umoddi3+0xb3>
  803cfa:	66 90                	xchg   %ax,%ax
  803cfc:	39 44 24 04          	cmp    %eax,0x4(%esp)
  803d00:	72 ea                	jb     803cec <__umoddi3+0x134>
  803d02:	89 d9                	mov    %ebx,%ecx
  803d04:	e9 62 ff ff ff       	jmp    803c6b <__umoddi3+0xb3>
