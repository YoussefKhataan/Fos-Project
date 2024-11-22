
obj/user/tst_sharing_3:     file format elf32-i386


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
  800031:	e8 45 02 00 00       	call   80027b <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
// Test the SPECIAL CASES during the creation & get of shared variables
#include <inc/lib.h>

void
_main(void)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 38             	sub    $0x38,%esp
	/*=================================================*/
	//Initial test to ensure it works on "PLACEMENT" not "REPLACEMENT"
#if USE_KHEAP
	{
		if (LIST_SIZE(&(myEnv->page_WS_list)) >= myEnv->page_WS_max_size)
  80003e:	a1 20 50 80 00       	mov    0x805020,%eax
  800043:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
  800049:	a1 20 50 80 00       	mov    0x805020,%eax
  80004e:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
  800054:	39 c2                	cmp    %eax,%edx
  800056:	72 14                	jb     80006c <_main+0x34>
			panic("Please increase the WS size");
  800058:	83 ec 04             	sub    $0x4,%esp
  80005b:	68 20 3c 80 00       	push   $0x803c20
  800060:	6a 0c                	push   $0xc
  800062:	68 3c 3c 80 00       	push   $0x803c3c
  800067:	e8 4e 03 00 00       	call   8003ba <_panic>
#else
	panic("make sure to enable the kernel heap: USE_KHEAP=1");
#endif
	/*=================================================*/

	cprintf("************************************************\n");
  80006c:	83 ec 0c             	sub    $0xc,%esp
  80006f:	68 54 3c 80 00       	push   $0x803c54
  800074:	e8 fe 05 00 00       	call   800677 <cprintf>
  800079:	83 c4 10             	add    $0x10,%esp
	cprintf("MAKE SURE to have a FRESH RUN for this test\n(i.e. don't run any program/test before it)\n");
  80007c:	83 ec 0c             	sub    $0xc,%esp
  80007f:	68 88 3c 80 00       	push   $0x803c88
  800084:	e8 ee 05 00 00       	call   800677 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp
	cprintf("************************************************\n\n\n");
  80008c:	83 ec 0c             	sub    $0xc,%esp
  80008f:	68 e4 3c 80 00       	push   $0x803ce4
  800094:	e8 de 05 00 00       	call   800677 <cprintf>
  800099:	83 c4 10             	add    $0x10,%esp

	int eval = 0;
  80009c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	bool is_correct = 1;
  8000a3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	uint32 pagealloc_start = USER_HEAP_START + DYN_ALLOC_MAX_SIZE + PAGE_SIZE; //UHS + 32MB + 4KB
  8000aa:	c7 45 ec 00 10 00 82 	movl   $0x82001000,-0x14(%ebp)

	uint32 *x, *y, *z ;
	cprintf("STEP A: checking creation of shared object that is already exists... [35%] \n\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 18 3d 80 00       	push   $0x803d18
  8000b9:	e8 b9 05 00 00       	call   800677 <cprintf>
  8000be:	83 c4 10             	add    $0x10,%esp
	{
		int ret ;
		//int ret = sys_createSharedObject("x", PAGE_SIZE, 1, (void*)&x);
		x = smalloc("x", PAGE_SIZE, 1);
  8000c1:	83 ec 04             	sub    $0x4,%esp
  8000c4:	6a 01                	push   $0x1
  8000c6:	68 00 10 00 00       	push   $0x1000
  8000cb:	68 66 3d 80 00       	push   $0x803d66
  8000d0:	e8 6f 16 00 00       	call   801744 <smalloc>
  8000d5:	83 c4 10             	add    $0x10,%esp
  8000d8:	89 45 e8             	mov    %eax,-0x18(%ebp)
		int freeFrames = sys_calculate_free_frames() ;
  8000db:	e8 29 19 00 00       	call   801a09 <sys_calculate_free_frames>
  8000e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		x = smalloc("x", PAGE_SIZE, 1);
  8000e3:	83 ec 04             	sub    $0x4,%esp
  8000e6:	6a 01                	push   $0x1
  8000e8:	68 00 10 00 00       	push   $0x1000
  8000ed:	68 66 3d 80 00       	push   $0x803d66
  8000f2:	e8 4d 16 00 00       	call   801744 <smalloc>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
		if (x != NULL) {is_correct = 0; cprintf("Trying to create an already exists object and corresponding error is not returned!!");}
  8000fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800101:	74 17                	je     80011a <_main+0xe2>
  800103:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80010a:	83 ec 0c             	sub    $0xc,%esp
  80010d:	68 68 3d 80 00       	push   $0x803d68
  800112:	e8 60 05 00 00       	call   800677 <cprintf>
  800117:	83 c4 10             	add    $0x10,%esp
		if ((freeFrames - sys_calculate_free_frames()) !=  0) {is_correct = 0; cprintf("Wrong allocation: make sure that you don't allocate any memory if the shared object exists");}
  80011a:	e8 ea 18 00 00       	call   801a09 <sys_calculate_free_frames>
  80011f:	89 c2                	mov    %eax,%edx
  800121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800124:	39 c2                	cmp    %eax,%edx
  800126:	74 17                	je     80013f <_main+0x107>
  800128:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	68 bc 3d 80 00       	push   $0x803dbc
  800137:	e8 3b 05 00 00       	call   800677 <cprintf>
  80013c:	83 c4 10             	add    $0x10,%esp
	}
	if (is_correct)	eval+=35;
  80013f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800143:	74 04                	je     800149 <_main+0x111>
  800145:	83 45 f4 23          	addl   $0x23,-0xc(%ebp)
	is_correct = 1;
  800149:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	cprintf("STEP B: checking getting shared object that is NOT exists... [35%]\n\n");
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	68 18 3e 80 00       	push   $0x803e18
  800158:	e8 1a 05 00 00       	call   800677 <cprintf>
  80015d:	83 c4 10             	add    $0x10,%esp
	{
		int ret ;
		x = sget(myEnv->env_id, "xx");
  800160:	a1 20 50 80 00       	mov    0x805020,%eax
  800165:	8b 40 10             	mov    0x10(%eax),%eax
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	68 5d 3e 80 00       	push   $0x803e5d
  800170:	50                   	push   %eax
  800171:	e8 5d 16 00 00       	call   8017d3 <sget>
  800176:	83 c4 10             	add    $0x10,%esp
  800179:	89 45 e8             	mov    %eax,-0x18(%ebp)
		int freeFrames = sys_calculate_free_frames() ;
  80017c:	e8 88 18 00 00       	call   801a09 <sys_calculate_free_frames>
  800181:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if (x != NULL) {is_correct = 0; cprintf("Trying to get a NON existing object and corresponding error is not returned!!");}
  800184:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800188:	74 17                	je     8001a1 <_main+0x169>
  80018a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	68 60 3e 80 00       	push   $0x803e60
  800199:	e8 d9 04 00 00       	call   800677 <cprintf>
  80019e:	83 c4 10             	add    $0x10,%esp
		if ((freeFrames - sys_calculate_free_frames()) !=  0) {is_correct = 0; cprintf("Wrong get: make sure that you don't allocate any memory if the shared object not exists");}
  8001a1:	e8 63 18 00 00       	call   801a09 <sys_calculate_free_frames>
  8001a6:	89 c2                	mov    %eax,%edx
  8001a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001ab:	39 c2                	cmp    %eax,%edx
  8001ad:	74 17                	je     8001c6 <_main+0x18e>
  8001af:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 b0 3e 80 00       	push   $0x803eb0
  8001be:	e8 b4 04 00 00       	call   800677 <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
	}
	if (is_correct)	eval+=35;
  8001c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8001ca:	74 04                	je     8001d0 <_main+0x198>
  8001cc:	83 45 f4 23          	addl   $0x23,-0xc(%ebp)
	is_correct = 1;
  8001d0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	cprintf("STEP C: checking the creation of shared object that exceeds the SHARED area limit... [30%]\n\n");
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 08 3f 80 00       	push   $0x803f08
  8001df:	e8 93 04 00 00       	call   800677 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
	{
		int freeFrames = sys_calculate_free_frames() ;
  8001e7:	e8 1d 18 00 00       	call   801a09 <sys_calculate_free_frames>
  8001ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
		uint32 size = USER_HEAP_MAX - pagealloc_start - PAGE_SIZE + 1;
  8001ef:	b8 01 f0 ff 9f       	mov    $0x9ffff001,%eax
  8001f4:	2b 45 ec             	sub    -0x14(%ebp),%eax
  8001f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
		y = smalloc("y", size, 1);
  8001fa:	83 ec 04             	sub    $0x4,%esp
  8001fd:	6a 01                	push   $0x1
  8001ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800202:	68 65 3f 80 00       	push   $0x803f65
  800207:	e8 38 15 00 00       	call   801744 <smalloc>
  80020c:	83 c4 10             	add    $0x10,%esp
  80020f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		if (y != NULL) {is_correct = 0; cprintf("Trying to create a shared object that exceed the SHARED area limit and the corresponding error is not returned!!");}
  800212:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800216:	74 17                	je     80022f <_main+0x1f7>
  800218:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 68 3f 80 00       	push   $0x803f68
  800227:	e8 4b 04 00 00       	call   800677 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
		if ((freeFrames - sys_calculate_free_frames()) !=  0) {is_correct = 0; cprintf("Wrong allocation: make sure that you don't allocate any memory if the shared object exceed the SHARED area limit");}
  80022f:	e8 d5 17 00 00       	call   801a09 <sys_calculate_free_frames>
  800234:	89 c2                	mov    %eax,%edx
  800236:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800239:	39 c2                	cmp    %eax,%edx
  80023b:	74 17                	je     800254 <_main+0x21c>
  80023d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	68 dc 3f 80 00       	push   $0x803fdc
  80024c:	e8 26 04 00 00       	call   800677 <cprintf>
  800251:	83 c4 10             	add    $0x10,%esp
	}
	if (is_correct)	eval+=30;
  800254:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800258:	74 04                	je     80025e <_main+0x226>
  80025a:	83 45 f4 1e          	addl   $0x1e,-0xc(%ebp)
	is_correct = 1;
  80025e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	cprintf("\n%~Test of Shared Variables [Create & Get: Special Cases] completed. Eval = %d%%\n\n", eval);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	ff 75 f4             	pushl  -0xc(%ebp)
  80026b:	68 50 40 80 00       	push   $0x804050
  800270:	e8 02 04 00 00       	call   800677 <cprintf>
  800275:	83 c4 10             	add    $0x10,%esp

}
  800278:	90                   	nop
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <libmain>:

volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";
void
libmain(int argc, char **argv)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  800281:	e8 4c 19 00 00       	call   801bd2 <sys_getenvindex>
  800286:	89 45 f4             	mov    %eax,-0xc(%ebp)

	myEnv = &(envs[envIndex]);
  800289:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80028c:	89 d0                	mov    %edx,%eax
  80028e:	c1 e0 03             	shl    $0x3,%eax
  800291:	01 d0                	add    %edx,%eax
  800293:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  80029a:	01 c8                	add    %ecx,%eax
  80029c:	01 c0                	add    %eax,%eax
  80029e:	01 d0                	add    %edx,%eax
  8002a0:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  8002a7:	01 c8                	add    %ecx,%eax
  8002a9:	01 d0                	add    %edx,%eax
  8002ab:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002b0:	a3 20 50 80 00       	mov    %eax,0x805020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  8002b5:	a1 20 50 80 00       	mov    0x805020,%eax
  8002ba:	8a 40 20             	mov    0x20(%eax),%al
  8002bd:	84 c0                	test   %al,%al
  8002bf:	74 0d                	je     8002ce <libmain+0x53>
		binaryname = myEnv->prog_name;
  8002c1:	a1 20 50 80 00       	mov    0x805020,%eax
  8002c6:	83 c0 20             	add    $0x20,%eax
  8002c9:	a3 00 50 80 00       	mov    %eax,0x805000

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8002d2:	7e 0a                	jle    8002de <libmain+0x63>
		binaryname = argv[0];
  8002d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d7:	8b 00                	mov    (%eax),%eax
  8002d9:	a3 00 50 80 00       	mov    %eax,0x805000

	// call user main routine
	_main(argc, argv);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	ff 75 0c             	pushl  0xc(%ebp)
  8002e4:	ff 75 08             	pushl  0x8(%ebp)
  8002e7:	e8 4c fd ff ff       	call   800038 <_main>
  8002ec:	83 c4 10             	add    $0x10,%esp



	//	sys_lock_cons();
	sys_lock_cons();
  8002ef:	e8 62 16 00 00       	call   801956 <sys_lock_cons>
	{
		cprintf("**************************************\n");
  8002f4:	83 ec 0c             	sub    $0xc,%esp
  8002f7:	68 bc 40 80 00       	push   $0x8040bc
  8002fc:	e8 76 03 00 00       	call   800677 <cprintf>
  800301:	83 c4 10             	add    $0x10,%esp
		cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  800304:	a1 20 50 80 00       	mov    0x805020,%eax
  800309:	8b 90 a0 05 00 00    	mov    0x5a0(%eax),%edx
  80030f:	a1 20 50 80 00       	mov    0x805020,%eax
  800314:	8b 80 90 05 00 00    	mov    0x590(%eax),%eax
  80031a:	83 ec 04             	sub    $0x4,%esp
  80031d:	52                   	push   %edx
  80031e:	50                   	push   %eax
  80031f:	68 e4 40 80 00       	push   $0x8040e4
  800324:	e8 4e 03 00 00       	call   800677 <cprintf>
  800329:	83 c4 10             	add    $0x10,%esp
		cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  80032c:	a1 20 50 80 00       	mov    0x805020,%eax
  800331:	8b 88 b4 05 00 00    	mov    0x5b4(%eax),%ecx
  800337:	a1 20 50 80 00       	mov    0x805020,%eax
  80033c:	8b 90 b0 05 00 00    	mov    0x5b0(%eax),%edx
  800342:	a1 20 50 80 00       	mov    0x805020,%eax
  800347:	8b 80 ac 05 00 00    	mov    0x5ac(%eax),%eax
  80034d:	51                   	push   %ecx
  80034e:	52                   	push   %edx
  80034f:	50                   	push   %eax
  800350:	68 0c 41 80 00       	push   $0x80410c
  800355:	e8 1d 03 00 00       	call   800677 <cprintf>
  80035a:	83 c4 10             	add    $0x10,%esp
		//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
		cprintf("Num of clocks = %d\n", myEnv->nClocks);
  80035d:	a1 20 50 80 00       	mov    0x805020,%eax
  800362:	8b 80 b8 05 00 00    	mov    0x5b8(%eax),%eax
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	50                   	push   %eax
  80036c:	68 64 41 80 00       	push   $0x804164
  800371:	e8 01 03 00 00       	call   800677 <cprintf>
  800376:	83 c4 10             	add    $0x10,%esp
		cprintf("**************************************\n");
  800379:	83 ec 0c             	sub    $0xc,%esp
  80037c:	68 bc 40 80 00       	push   $0x8040bc
  800381:	e8 f1 02 00 00       	call   800677 <cprintf>
  800386:	83 c4 10             	add    $0x10,%esp
	}
	sys_unlock_cons();
  800389:	e8 e2 15 00 00       	call   801970 <sys_unlock_cons>
//	sys_unlock_cons();

	// exit gracefully
	exit();
  80038e:	e8 19 00 00 00       	call   8003ac <exit>
}
  800393:	90                   	nop
  800394:	c9                   	leave  
  800395:	c3                   	ret    

00800396 <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	6a 00                	push   $0x0
  8003a1:	e8 f8 17 00 00       	call   801b9e <sys_destroy_env>
  8003a6:	83 c4 10             	add    $0x10,%esp
}
  8003a9:	90                   	nop
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    

008003ac <exit>:

void
exit(void)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  8003b2:	e8 4d 18 00 00       	call   801c04 <sys_exit_env>
}
  8003b7:	90                   	nop
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  8003c0:	8d 45 10             	lea    0x10(%ebp),%eax
  8003c3:	83 c0 04             	add    $0x4,%eax
  8003c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  8003c9:	a1 4c 50 80 00       	mov    0x80504c,%eax
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	74 16                	je     8003e8 <_panic+0x2e>
		cprintf("%s: ", argv0);
  8003d2:	a1 4c 50 80 00       	mov    0x80504c,%eax
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	50                   	push   %eax
  8003db:	68 78 41 80 00       	push   $0x804178
  8003e0:	e8 92 02 00 00       	call   800677 <cprintf>
  8003e5:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8003e8:	a1 00 50 80 00       	mov    0x805000,%eax
  8003ed:	ff 75 0c             	pushl  0xc(%ebp)
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	50                   	push   %eax
  8003f4:	68 7d 41 80 00       	push   $0x80417d
  8003f9:	e8 79 02 00 00       	call   800677 <cprintf>
  8003fe:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  800401:	8b 45 10             	mov    0x10(%ebp),%eax
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	ff 75 f4             	pushl  -0xc(%ebp)
  80040a:	50                   	push   %eax
  80040b:	e8 fc 01 00 00       	call   80060c <vcprintf>
  800410:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	6a 00                	push   $0x0
  800418:	68 99 41 80 00       	push   $0x804199
  80041d:	e8 ea 01 00 00       	call   80060c <vcprintf>
  800422:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  800425:	e8 82 ff ff ff       	call   8003ac <exit>

	// should not return here
	while (1) ;
  80042a:	eb fe                	jmp    80042a <_panic+0x70>

0080042c <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  800432:	a1 20 50 80 00       	mov    0x805020,%eax
  800437:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  80043d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800440:	39 c2                	cmp    %eax,%edx
  800442:	74 14                	je     800458 <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	68 9c 41 80 00       	push   $0x80419c
  80044c:	6a 26                	push   $0x26
  80044e:	68 e8 41 80 00       	push   $0x8041e8
  800453:	e8 62 ff ff ff       	call   8003ba <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  800458:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  80045f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800466:	e9 c5 00 00 00       	jmp    800530 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  80046b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80046e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800475:	8b 45 08             	mov    0x8(%ebp),%eax
  800478:	01 d0                	add    %edx,%eax
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	85 c0                	test   %eax,%eax
  80047e:	75 08                	jne    800488 <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  800480:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  800483:	e9 a5 00 00 00       	jmp    80052d <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  800488:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80048f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  800496:	eb 69                	jmp    800501 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  800498:	a1 20 50 80 00       	mov    0x805020,%eax
  80049d:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  8004a3:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004a6:	89 d0                	mov    %edx,%eax
  8004a8:	01 c0                	add    %eax,%eax
  8004aa:	01 d0                	add    %edx,%eax
  8004ac:	c1 e0 03             	shl    $0x3,%eax
  8004af:	01 c8                	add    %ecx,%eax
  8004b1:	8a 40 04             	mov    0x4(%eax),%al
  8004b4:	84 c0                	test   %al,%al
  8004b6:	75 46                	jne    8004fe <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  8004b8:	a1 20 50 80 00       	mov    0x805020,%eax
  8004bd:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  8004c3:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8004c6:	89 d0                	mov    %edx,%eax
  8004c8:	01 c0                	add    %eax,%eax
  8004ca:	01 d0                	add    %edx,%eax
  8004cc:	c1 e0 03             	shl    $0x3,%eax
  8004cf:	01 c8                	add    %ecx,%eax
  8004d1:	8b 00                	mov    (%eax),%eax
  8004d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8004de:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  8004e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	01 c8                	add    %ecx,%eax
  8004ef:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  8004f1:	39 c2                	cmp    %eax,%edx
  8004f3:	75 09                	jne    8004fe <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  8004f5:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  8004fc:	eb 15                	jmp    800513 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8004fe:	ff 45 e8             	incl   -0x18(%ebp)
  800501:	a1 20 50 80 00       	mov    0x805020,%eax
  800506:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  80050c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80050f:	39 c2                	cmp    %eax,%edx
  800511:	77 85                	ja     800498 <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  800513:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800517:	75 14                	jne    80052d <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  800519:	83 ec 04             	sub    $0x4,%esp
  80051c:	68 f4 41 80 00       	push   $0x8041f4
  800521:	6a 3a                	push   $0x3a
  800523:	68 e8 41 80 00       	push   $0x8041e8
  800528:	e8 8d fe ff ff       	call   8003ba <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  80052d:	ff 45 f0             	incl   -0x10(%ebp)
  800530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800533:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800536:	0f 8c 2f ff ff ff    	jl     80046b <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  80053c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  800543:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80054a:	eb 26                	jmp    800572 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  80054c:	a1 20 50 80 00       	mov    0x805020,%eax
  800551:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  800557:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055a:	89 d0                	mov    %edx,%eax
  80055c:	01 c0                	add    %eax,%eax
  80055e:	01 d0                	add    %edx,%eax
  800560:	c1 e0 03             	shl    $0x3,%eax
  800563:	01 c8                	add    %ecx,%eax
  800565:	8a 40 04             	mov    0x4(%eax),%al
  800568:	3c 01                	cmp    $0x1,%al
  80056a:	75 03                	jne    80056f <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  80056c:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  80056f:	ff 45 e0             	incl   -0x20(%ebp)
  800572:	a1 20 50 80 00       	mov    0x805020,%eax
  800577:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  80057d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800580:	39 c2                	cmp    %eax,%edx
  800582:	77 c8                	ja     80054c <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  800584:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800587:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  80058a:	74 14                	je     8005a0 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  80058c:	83 ec 04             	sub    $0x4,%esp
  80058f:	68 48 42 80 00       	push   $0x804248
  800594:	6a 44                	push   $0x44
  800596:	68 e8 41 80 00       	push   $0x8041e8
  80059b:	e8 1a fe ff ff       	call   8003ba <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  8005a0:	90                   	nop
  8005a1:	c9                   	leave  
  8005a2:	c3                   	ret    

008005a3 <putch>:
	int idx; // current buffer index
	int cnt; // total bytes printed so far
	char buf[256];
};

static void putch(int ch, struct printbuf *b) {
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8005a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	8d 48 01             	lea    0x1(%eax),%ecx
  8005b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005b4:	89 0a                	mov    %ecx,(%edx)
  8005b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b9:	88 d1                	mov    %dl,%cl
  8005bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005be:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  8005c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005cc:	75 2c                	jne    8005fa <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  8005ce:	a0 28 50 80 00       	mov    0x805028,%al
  8005d3:	0f b6 c0             	movzbl %al,%eax
  8005d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d9:	8b 12                	mov    (%edx),%edx
  8005db:	89 d1                	mov    %edx,%ecx
  8005dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005e0:	83 c2 08             	add    $0x8,%edx
  8005e3:	83 ec 04             	sub    $0x4,%esp
  8005e6:	50                   	push   %eax
  8005e7:	51                   	push   %ecx
  8005e8:	52                   	push   %edx
  8005e9:	e8 26 13 00 00       	call   801914 <sys_cputs>
  8005ee:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  8005f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8005fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005fd:	8b 40 04             	mov    0x4(%eax),%eax
  800600:	8d 50 01             	lea    0x1(%eax),%edx
  800603:	8b 45 0c             	mov    0xc(%ebp),%eax
  800606:	89 50 04             	mov    %edx,0x4(%eax)
}
  800609:	90                   	nop
  80060a:	c9                   	leave  
  80060b:	c3                   	ret    

0080060c <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  80060c:	55                   	push   %ebp
  80060d:	89 e5                	mov    %esp,%ebp
  80060f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800615:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80061c:	00 00 00 
	b.cnt = 0;
  80061f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800626:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  800629:	ff 75 0c             	pushl  0xc(%ebp)
  80062c:	ff 75 08             	pushl  0x8(%ebp)
  80062f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800635:	50                   	push   %eax
  800636:	68 a3 05 80 00       	push   $0x8005a3
  80063b:	e8 11 02 00 00       	call   800851 <vprintfmt>
  800640:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  800643:	a0 28 50 80 00       	mov    0x805028,%al
  800648:	0f b6 c0             	movzbl %al,%eax
  80064b:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800651:	83 ec 04             	sub    $0x4,%esp
  800654:	50                   	push   %eax
  800655:	52                   	push   %edx
  800656:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80065c:	83 c0 08             	add    $0x8,%eax
  80065f:	50                   	push   %eax
  800660:	e8 af 12 00 00       	call   801914 <sys_cputs>
  800665:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  800668:	c6 05 28 50 80 00 00 	movb   $0x0,0x805028
	return b.cnt;
  80066f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800675:	c9                   	leave  
  800676:	c3                   	ret    

00800677 <cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int cprintf(const char *fmt, ...) {
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  80067d:	c6 05 28 50 80 00 01 	movb   $0x1,0x805028
	va_start(ap, fmt);
  800684:	8d 45 0c             	lea    0xc(%ebp),%eax
  800687:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  80068a:	8b 45 08             	mov    0x8(%ebp),%eax
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	ff 75 f4             	pushl  -0xc(%ebp)
  800693:	50                   	push   %eax
  800694:	e8 73 ff ff ff       	call   80060c <vcprintf>
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  80069f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8006a2:	c9                   	leave  
  8006a3:	c3                   	ret    

008006a4 <atomic_cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int atomic_cprintf(const char *fmt, ...)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 18             	sub    $0x18,%esp
	int cnt;
	sys_lock_cons();
  8006aa:	e8 a7 12 00 00       	call   801956 <sys_lock_cons>
	{
		va_list ap;
		va_start(ap, fmt);
  8006af:	8d 45 0c             	lea    0xc(%ebp),%eax
  8006b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cnt = vcprintf(fmt, ap);
  8006b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8006be:	50                   	push   %eax
  8006bf:	e8 48 ff ff ff       	call   80060c <vcprintf>
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
		va_end(ap);
	}
	sys_unlock_cons();
  8006ca:	e8 a1 12 00 00       	call   801970 <sys_unlock_cons>
	return cnt;
  8006cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	53                   	push   %ebx
  8006d8:	83 ec 14             	sub    $0x14,%esp
  8006db:	8b 45 10             	mov    0x10(%ebp),%eax
  8006de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006e7:	8b 45 18             	mov    0x18(%ebp),%eax
  8006ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ef:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8006f2:	77 55                	ja     800749 <printnum+0x75>
  8006f4:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8006f7:	72 05                	jb     8006fe <printnum+0x2a>
  8006f9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8006fc:	77 4b                	ja     800749 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8006fe:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800701:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800704:	8b 45 18             	mov    0x18(%ebp),%eax
  800707:	ba 00 00 00 00       	mov    $0x0,%edx
  80070c:	52                   	push   %edx
  80070d:	50                   	push   %eax
  80070e:	ff 75 f4             	pushl  -0xc(%ebp)
  800711:	ff 75 f0             	pushl  -0x10(%ebp)
  800714:	e8 93 32 00 00       	call   8039ac <__udivdi3>
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	83 ec 04             	sub    $0x4,%esp
  80071f:	ff 75 20             	pushl  0x20(%ebp)
  800722:	53                   	push   %ebx
  800723:	ff 75 18             	pushl  0x18(%ebp)
  800726:	52                   	push   %edx
  800727:	50                   	push   %eax
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	ff 75 08             	pushl  0x8(%ebp)
  80072e:	e8 a1 ff ff ff       	call   8006d4 <printnum>
  800733:	83 c4 20             	add    $0x20,%esp
  800736:	eb 1a                	jmp    800752 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	ff 75 0c             	pushl  0xc(%ebp)
  80073e:	ff 75 20             	pushl  0x20(%ebp)
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	ff d0                	call   *%eax
  800746:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800749:	ff 4d 1c             	decl   0x1c(%ebp)
  80074c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800750:	7f e6                	jg     800738 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800752:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800755:	bb 00 00 00 00       	mov    $0x0,%ebx
  80075a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800760:	53                   	push   %ebx
  800761:	51                   	push   %ecx
  800762:	52                   	push   %edx
  800763:	50                   	push   %eax
  800764:	e8 53 33 00 00       	call   803abc <__umoddi3>
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	05 b4 44 80 00       	add    $0x8044b4,%eax
  800771:	8a 00                	mov    (%eax),%al
  800773:	0f be c0             	movsbl %al,%eax
  800776:	83 ec 08             	sub    $0x8,%esp
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	ff d0                	call   *%eax
  800782:	83 c4 10             	add    $0x10,%esp
}
  800785:	90                   	nop
  800786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800792:	7e 1c                	jle    8007b0 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	8b 00                	mov    (%eax),%eax
  800799:	8d 50 08             	lea    0x8(%eax),%edx
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	89 10                	mov    %edx,(%eax)
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	8b 00                	mov    (%eax),%eax
  8007a6:	83 e8 08             	sub    $0x8,%eax
  8007a9:	8b 50 04             	mov    0x4(%eax),%edx
  8007ac:	8b 00                	mov    (%eax),%eax
  8007ae:	eb 40                	jmp    8007f0 <getuint+0x65>
	else if (lflag)
  8007b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007b4:	74 1e                	je     8007d4 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 00                	mov    (%eax),%eax
  8007bb:	8d 50 04             	lea    0x4(%eax),%edx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	89 10                	mov    %edx,(%eax)
  8007c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c6:	8b 00                	mov    (%eax),%eax
  8007c8:	83 e8 04             	sub    $0x4,%eax
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d2:	eb 1c                	jmp    8007f0 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	8b 00                	mov    (%eax),%eax
  8007d9:	8d 50 04             	lea    0x4(%eax),%edx
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	89 10                	mov    %edx,(%eax)
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	8b 00                	mov    (%eax),%eax
  8007e6:	83 e8 04             	sub    $0x4,%eax
  8007e9:	8b 00                	mov    (%eax),%eax
  8007eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007f5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8007f9:	7e 1c                	jle    800817 <getint+0x25>
		return va_arg(*ap, long long);
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 00                	mov    (%eax),%eax
  800800:	8d 50 08             	lea    0x8(%eax),%edx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	89 10                	mov    %edx,(%eax)
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 00                	mov    (%eax),%eax
  80080d:	83 e8 08             	sub    $0x8,%eax
  800810:	8b 50 04             	mov    0x4(%eax),%edx
  800813:	8b 00                	mov    (%eax),%eax
  800815:	eb 38                	jmp    80084f <getint+0x5d>
	else if (lflag)
  800817:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80081b:	74 1a                	je     800837 <getint+0x45>
		return va_arg(*ap, long);
  80081d:	8b 45 08             	mov    0x8(%ebp),%eax
  800820:	8b 00                	mov    (%eax),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 10                	mov    %edx,(%eax)
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	8b 00                	mov    (%eax),%eax
  80082f:	83 e8 04             	sub    $0x4,%eax
  800832:	8b 00                	mov    (%eax),%eax
  800834:	99                   	cltd   
  800835:	eb 18                	jmp    80084f <getint+0x5d>
	else
		return va_arg(*ap, int);
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	8b 00                	mov    (%eax),%eax
  80083c:	8d 50 04             	lea    0x4(%eax),%edx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	89 10                	mov    %edx,(%eax)
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 00                	mov    (%eax),%eax
  800849:	83 e8 04             	sub    $0x4,%eax
  80084c:	8b 00                	mov    (%eax),%eax
  80084e:	99                   	cltd   
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800859:	eb 17                	jmp    800872 <vprintfmt+0x21>
			if (ch == '\0')
  80085b:	85 db                	test   %ebx,%ebx
  80085d:	0f 84 c1 03 00 00    	je     800c24 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	ff 75 0c             	pushl  0xc(%ebp)
  800869:	53                   	push   %ebx
  80086a:	8b 45 08             	mov    0x8(%ebp),%eax
  80086d:	ff d0                	call   *%eax
  80086f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800872:	8b 45 10             	mov    0x10(%ebp),%eax
  800875:	8d 50 01             	lea    0x1(%eax),%edx
  800878:	89 55 10             	mov    %edx,0x10(%ebp)
  80087b:	8a 00                	mov    (%eax),%al
  80087d:	0f b6 d8             	movzbl %al,%ebx
  800880:	83 fb 25             	cmp    $0x25,%ebx
  800883:	75 d6                	jne    80085b <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800885:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800889:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800890:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800897:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80089e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a8:	8d 50 01             	lea    0x1(%eax),%edx
  8008ab:	89 55 10             	mov    %edx,0x10(%ebp)
  8008ae:	8a 00                	mov    (%eax),%al
  8008b0:	0f b6 d8             	movzbl %al,%ebx
  8008b3:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8008b6:	83 f8 5b             	cmp    $0x5b,%eax
  8008b9:	0f 87 3d 03 00 00    	ja     800bfc <vprintfmt+0x3ab>
  8008bf:	8b 04 85 d8 44 80 00 	mov    0x8044d8(,%eax,4),%eax
  8008c6:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8008c8:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8008cc:	eb d7                	jmp    8008a5 <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008ce:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8008d2:	eb d1                	jmp    8008a5 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008d4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8008db:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	c1 e0 02             	shl    $0x2,%eax
  8008e3:	01 d0                	add    %edx,%eax
  8008e5:	01 c0                	add    %eax,%eax
  8008e7:	01 d8                	add    %ebx,%eax
  8008e9:	83 e8 30             	sub    $0x30,%eax
  8008ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8008ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f2:	8a 00                	mov    (%eax),%al
  8008f4:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8008f7:	83 fb 2f             	cmp    $0x2f,%ebx
  8008fa:	7e 3e                	jle    80093a <vprintfmt+0xe9>
  8008fc:	83 fb 39             	cmp    $0x39,%ebx
  8008ff:	7f 39                	jg     80093a <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800901:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800904:	eb d5                	jmp    8008db <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	83 c0 04             	add    $0x4,%eax
  80090c:	89 45 14             	mov    %eax,0x14(%ebp)
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	83 e8 04             	sub    $0x4,%eax
  800915:	8b 00                	mov    (%eax),%eax
  800917:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80091a:	eb 1f                	jmp    80093b <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80091c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800920:	79 83                	jns    8008a5 <vprintfmt+0x54>
				width = 0;
  800922:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800929:	e9 77 ff ff ff       	jmp    8008a5 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  80092e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800935:	e9 6b ff ff ff       	jmp    8008a5 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  80093a:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80093b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093f:	0f 89 60 ff ff ff    	jns    8008a5 <vprintfmt+0x54>
				width = precision, precision = -1;
  800945:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800948:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800952:	e9 4e ff ff ff       	jmp    8008a5 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800957:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  80095a:	e9 46 ff ff ff       	jmp    8008a5 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	83 c0 04             	add    $0x4,%eax
  800965:	89 45 14             	mov    %eax,0x14(%ebp)
  800968:	8b 45 14             	mov    0x14(%ebp),%eax
  80096b:	83 e8 04             	sub    $0x4,%eax
  80096e:	8b 00                	mov    (%eax),%eax
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	50                   	push   %eax
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	ff d0                	call   *%eax
  80097c:	83 c4 10             	add    $0x10,%esp
			break;
  80097f:	e9 9b 02 00 00       	jmp    800c1f <vprintfmt+0x3ce>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800984:	8b 45 14             	mov    0x14(%ebp),%eax
  800987:	83 c0 04             	add    $0x4,%eax
  80098a:	89 45 14             	mov    %eax,0x14(%ebp)
  80098d:	8b 45 14             	mov    0x14(%ebp),%eax
  800990:	83 e8 04             	sub    $0x4,%eax
  800993:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800995:	85 db                	test   %ebx,%ebx
  800997:	79 02                	jns    80099b <vprintfmt+0x14a>
				err = -err;
  800999:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80099b:	83 fb 64             	cmp    $0x64,%ebx
  80099e:	7f 0b                	jg     8009ab <vprintfmt+0x15a>
  8009a0:	8b 34 9d 20 43 80 00 	mov    0x804320(,%ebx,4),%esi
  8009a7:	85 f6                	test   %esi,%esi
  8009a9:	75 19                	jne    8009c4 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8009ab:	53                   	push   %ebx
  8009ac:	68 c5 44 80 00       	push   $0x8044c5
  8009b1:	ff 75 0c             	pushl  0xc(%ebp)
  8009b4:	ff 75 08             	pushl  0x8(%ebp)
  8009b7:	e8 70 02 00 00       	call   800c2c <printfmt>
  8009bc:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8009bf:	e9 5b 02 00 00       	jmp    800c1f <vprintfmt+0x3ce>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009c4:	56                   	push   %esi
  8009c5:	68 ce 44 80 00       	push   $0x8044ce
  8009ca:	ff 75 0c             	pushl  0xc(%ebp)
  8009cd:	ff 75 08             	pushl  0x8(%ebp)
  8009d0:	e8 57 02 00 00       	call   800c2c <printfmt>
  8009d5:	83 c4 10             	add    $0x10,%esp
			break;
  8009d8:	e9 42 02 00 00       	jmp    800c1f <vprintfmt+0x3ce>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e0:	83 c0 04             	add    $0x4,%eax
  8009e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8009e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e9:	83 e8 04             	sub    $0x4,%eax
  8009ec:	8b 30                	mov    (%eax),%esi
  8009ee:	85 f6                	test   %esi,%esi
  8009f0:	75 05                	jne    8009f7 <vprintfmt+0x1a6>
				p = "(null)";
  8009f2:	be d1 44 80 00       	mov    $0x8044d1,%esi
			if (width > 0 && padc != '-')
  8009f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8009fb:	7e 6d                	jle    800a6a <vprintfmt+0x219>
  8009fd:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800a01:	74 67                	je     800a6a <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a03:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	50                   	push   %eax
  800a0a:	56                   	push   %esi
  800a0b:	e8 1e 03 00 00       	call   800d2e <strnlen>
  800a10:	83 c4 10             	add    $0x10,%esp
  800a13:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800a16:	eb 16                	jmp    800a2e <vprintfmt+0x1dd>
					putch(padc, putdat);
  800a18:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800a1c:	83 ec 08             	sub    $0x8,%esp
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	50                   	push   %eax
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	ff d0                	call   *%eax
  800a28:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a2b:	ff 4d e4             	decl   -0x1c(%ebp)
  800a2e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a32:	7f e4                	jg     800a18 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a34:	eb 34                	jmp    800a6a <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  800a36:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a3a:	74 1c                	je     800a58 <vprintfmt+0x207>
  800a3c:	83 fb 1f             	cmp    $0x1f,%ebx
  800a3f:	7e 05                	jle    800a46 <vprintfmt+0x1f5>
  800a41:	83 fb 7e             	cmp    $0x7e,%ebx
  800a44:	7e 12                	jle    800a58 <vprintfmt+0x207>
					putch('?', putdat);
  800a46:	83 ec 08             	sub    $0x8,%esp
  800a49:	ff 75 0c             	pushl  0xc(%ebp)
  800a4c:	6a 3f                	push   $0x3f
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	ff d0                	call   *%eax
  800a53:	83 c4 10             	add    $0x10,%esp
  800a56:	eb 0f                	jmp    800a67 <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	ff 75 0c             	pushl  0xc(%ebp)
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	ff d0                	call   *%eax
  800a64:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a67:	ff 4d e4             	decl   -0x1c(%ebp)
  800a6a:	89 f0                	mov    %esi,%eax
  800a6c:	8d 70 01             	lea    0x1(%eax),%esi
  800a6f:	8a 00                	mov    (%eax),%al
  800a71:	0f be d8             	movsbl %al,%ebx
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	74 24                	je     800a9c <vprintfmt+0x24b>
  800a78:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a7c:	78 b8                	js     800a36 <vprintfmt+0x1e5>
  800a7e:	ff 4d e0             	decl   -0x20(%ebp)
  800a81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a85:	79 af                	jns    800a36 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a87:	eb 13                	jmp    800a9c <vprintfmt+0x24b>
				putch(' ', putdat);
  800a89:	83 ec 08             	sub    $0x8,%esp
  800a8c:	ff 75 0c             	pushl  0xc(%ebp)
  800a8f:	6a 20                	push   $0x20
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	ff d0                	call   *%eax
  800a96:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a99:	ff 4d e4             	decl   -0x1c(%ebp)
  800a9c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800aa0:	7f e7                	jg     800a89 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  800aa2:	e9 78 01 00 00       	jmp    800c1f <vprintfmt+0x3ce>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800aa7:	83 ec 08             	sub    $0x8,%esp
  800aaa:	ff 75 e8             	pushl  -0x18(%ebp)
  800aad:	8d 45 14             	lea    0x14(%ebp),%eax
  800ab0:	50                   	push   %eax
  800ab1:	e8 3c fd ff ff       	call   8007f2 <getint>
  800ab6:	83 c4 10             	add    $0x10,%esp
  800ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800abc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac5:	85 d2                	test   %edx,%edx
  800ac7:	79 23                	jns    800aec <vprintfmt+0x29b>
				putch('-', putdat);
  800ac9:	83 ec 08             	sub    $0x8,%esp
  800acc:	ff 75 0c             	pushl  0xc(%ebp)
  800acf:	6a 2d                	push   $0x2d
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	ff d0                	call   *%eax
  800ad6:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800adc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adf:	f7 d8                	neg    %eax
  800ae1:	83 d2 00             	adc    $0x0,%edx
  800ae4:	f7 da                	neg    %edx
  800ae6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ae9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800aec:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800af3:	e9 bc 00 00 00       	jmp    800bb4 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	ff 75 e8             	pushl  -0x18(%ebp)
  800afe:	8d 45 14             	lea    0x14(%ebp),%eax
  800b01:	50                   	push   %eax
  800b02:	e8 84 fc ff ff       	call   80078b <getuint>
  800b07:	83 c4 10             	add    $0x10,%esp
  800b0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b0d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800b10:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800b17:	e9 98 00 00 00       	jmp    800bb4 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	ff 75 0c             	pushl  0xc(%ebp)
  800b22:	6a 58                	push   $0x58
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	ff d0                	call   *%eax
  800b29:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	ff 75 0c             	pushl  0xc(%ebp)
  800b32:	6a 58                	push   $0x58
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	ff d0                	call   *%eax
  800b39:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800b3c:	83 ec 08             	sub    $0x8,%esp
  800b3f:	ff 75 0c             	pushl  0xc(%ebp)
  800b42:	6a 58                	push   $0x58
  800b44:	8b 45 08             	mov    0x8(%ebp),%eax
  800b47:	ff d0                	call   *%eax
  800b49:	83 c4 10             	add    $0x10,%esp
			break;
  800b4c:	e9 ce 00 00 00       	jmp    800c1f <vprintfmt+0x3ce>

		// pointer
		case 'p':
			putch('0', putdat);
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	ff 75 0c             	pushl  0xc(%ebp)
  800b57:	6a 30                	push   $0x30
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	ff d0                	call   *%eax
  800b5e:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	ff 75 0c             	pushl  0xc(%ebp)
  800b67:	6a 78                	push   $0x78
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	ff d0                	call   *%eax
  800b6e:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800b71:	8b 45 14             	mov    0x14(%ebp),%eax
  800b74:	83 c0 04             	add    $0x4,%eax
  800b77:	89 45 14             	mov    %eax,0x14(%ebp)
  800b7a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7d:	83 e8 04             	sub    $0x4,%eax
  800b80:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  800b8c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800b93:	eb 1f                	jmp    800bb4 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b95:	83 ec 08             	sub    $0x8,%esp
  800b98:	ff 75 e8             	pushl  -0x18(%ebp)
  800b9b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9e:	50                   	push   %eax
  800b9f:	e8 e7 fb ff ff       	call   80078b <getuint>
  800ba4:	83 c4 10             	add    $0x10,%esp
  800ba7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800baa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800bad:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bb4:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bbb:	83 ec 04             	sub    $0x4,%esp
  800bbe:	52                   	push   %edx
  800bbf:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc2:	50                   	push   %eax
  800bc3:	ff 75 f4             	pushl  -0xc(%ebp)
  800bc6:	ff 75 f0             	pushl  -0x10(%ebp)
  800bc9:	ff 75 0c             	pushl  0xc(%ebp)
  800bcc:	ff 75 08             	pushl  0x8(%ebp)
  800bcf:	e8 00 fb ff ff       	call   8006d4 <printnum>
  800bd4:	83 c4 20             	add    $0x20,%esp
			break;
  800bd7:	eb 46                	jmp    800c1f <vprintfmt+0x3ce>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bd9:	83 ec 08             	sub    $0x8,%esp
  800bdc:	ff 75 0c             	pushl  0xc(%ebp)
  800bdf:	53                   	push   %ebx
  800be0:	8b 45 08             	mov    0x8(%ebp),%eax
  800be3:	ff d0                	call   *%eax
  800be5:	83 c4 10             	add    $0x10,%esp
			break;
  800be8:	eb 35                	jmp    800c1f <vprintfmt+0x3ce>

		/**********************************/
		/*2023*/
		// DON'T Print Program Name & UD
		case '~':
			printProgName = 0;
  800bea:	c6 05 28 50 80 00 00 	movb   $0x0,0x805028
			break;
  800bf1:	eb 2c                	jmp    800c1f <vprintfmt+0x3ce>
		// Print Program Name & UD
		case '@':
			printProgName = 1;
  800bf3:	c6 05 28 50 80 00 01 	movb   $0x1,0x805028
			break;
  800bfa:	eb 23                	jmp    800c1f <vprintfmt+0x3ce>
		/**********************************/

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bfc:	83 ec 08             	sub    $0x8,%esp
  800bff:	ff 75 0c             	pushl  0xc(%ebp)
  800c02:	6a 25                	push   $0x25
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	ff d0                	call   *%eax
  800c09:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c0c:	ff 4d 10             	decl   0x10(%ebp)
  800c0f:	eb 03                	jmp    800c14 <vprintfmt+0x3c3>
  800c11:	ff 4d 10             	decl   0x10(%ebp)
  800c14:	8b 45 10             	mov    0x10(%ebp),%eax
  800c17:	48                   	dec    %eax
  800c18:	8a 00                	mov    (%eax),%al
  800c1a:	3c 25                	cmp    $0x25,%al
  800c1c:	75 f3                	jne    800c11 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
  800c1e:	90                   	nop
		}
	}
  800c1f:	e9 35 fc ff ff       	jmp    800859 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800c24:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800c25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c32:	8d 45 10             	lea    0x10(%ebp),%eax
  800c35:	83 c0 04             	add    $0x4,%eax
  800c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800c3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800c3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800c41:	50                   	push   %eax
  800c42:	ff 75 0c             	pushl  0xc(%ebp)
  800c45:	ff 75 08             	pushl  0x8(%ebp)
  800c48:	e8 04 fc ff ff       	call   800851 <vprintfmt>
  800c4d:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800c50:	90                   	nop
  800c51:	c9                   	leave  
  800c52:	c3                   	ret    

00800c53 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800c56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c59:	8b 40 08             	mov    0x8(%eax),%eax
  800c5c:	8d 50 01             	lea    0x1(%eax),%edx
  800c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c62:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800c65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c68:	8b 10                	mov    (%eax),%edx
  800c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6d:	8b 40 04             	mov    0x4(%eax),%eax
  800c70:	39 c2                	cmp    %eax,%edx
  800c72:	73 12                	jae    800c86 <sprintputch+0x33>
		*b->buf++ = ch;
  800c74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c77:	8b 00                	mov    (%eax),%eax
  800c79:	8d 48 01             	lea    0x1(%eax),%ecx
  800c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7f:	89 0a                	mov    %ecx,(%edx)
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	88 10                	mov    %dl,(%eax)
}
  800c86:	90                   	nop
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c98:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9e:	01 d0                	add    %edx,%eax
  800ca0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ca3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800caa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800cae:	74 06                	je     800cb6 <vsnprintf+0x2d>
  800cb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb4:	7f 07                	jg     800cbd <vsnprintf+0x34>
		return -E_INVAL;
  800cb6:	b8 03 00 00 00       	mov    $0x3,%eax
  800cbb:	eb 20                	jmp    800cdd <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cbd:	ff 75 14             	pushl  0x14(%ebp)
  800cc0:	ff 75 10             	pushl  0x10(%ebp)
  800cc3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc6:	50                   	push   %eax
  800cc7:	68 53 0c 80 00       	push   $0x800c53
  800ccc:	e8 80 fb ff ff       	call   800851 <vprintfmt>
  800cd1:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  800cd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800cdd:	c9                   	leave  
  800cde:	c3                   	ret    

00800cdf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce5:	8d 45 10             	lea    0x10(%ebp),%eax
  800ce8:	83 c0 04             	add    $0x4,%eax
  800ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800cee:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf1:	ff 75 f4             	pushl  -0xc(%ebp)
  800cf4:	50                   	push   %eax
  800cf5:	ff 75 0c             	pushl  0xc(%ebp)
  800cf8:	ff 75 08             	pushl  0x8(%ebp)
  800cfb:	e8 89 ff ff ff       	call   800c89 <vsnprintf>
  800d00:	83 c4 10             	add    $0x10,%esp
  800d03:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  800d06:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <strlen>:
#include <inc/string.h>
#include <inc/assert.h>

int
strlen(const char *s)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800d11:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d18:	eb 06                	jmp    800d20 <strlen+0x15>
		n++;
  800d1a:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d1d:	ff 45 08             	incl   0x8(%ebp)
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	8a 00                	mov    (%eax),%al
  800d25:	84 c0                	test   %al,%al
  800d27:	75 f1                	jne    800d1a <strlen+0xf>
		n++;
	return n;
  800d29:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d34:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d3b:	eb 09                	jmp    800d46 <strnlen+0x18>
		n++;
  800d3d:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d40:	ff 45 08             	incl   0x8(%ebp)
  800d43:	ff 4d 0c             	decl   0xc(%ebp)
  800d46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4a:	74 09                	je     800d55 <strnlen+0x27>
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8a 00                	mov    (%eax),%al
  800d51:	84 c0                	test   %al,%al
  800d53:	75 e8                	jne    800d3d <strnlen+0xf>
		n++;
	return n;
  800d55:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d58:	c9                   	leave  
  800d59:	c3                   	ret    

00800d5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800d66:	90                   	nop
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	8d 50 01             	lea    0x1(%eax),%edx
  800d6d:	89 55 08             	mov    %edx,0x8(%ebp)
  800d70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d73:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d76:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d79:	8a 12                	mov    (%edx),%dl
  800d7b:	88 10                	mov    %dl,(%eax)
  800d7d:	8a 00                	mov    (%eax),%al
  800d7f:	84 c0                	test   %al,%al
  800d81:	75 e4                	jne    800d67 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800d83:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800d94:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800d9b:	eb 1f                	jmp    800dbc <strncpy+0x34>
		*dst++ = *src;
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	8d 50 01             	lea    0x1(%eax),%edx
  800da3:	89 55 08             	mov    %edx,0x8(%ebp)
  800da6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da9:	8a 12                	mov    (%edx),%dl
  800dab:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800dad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db0:	8a 00                	mov    (%eax),%al
  800db2:	84 c0                	test   %al,%al
  800db4:	74 03                	je     800db9 <strncpy+0x31>
			src++;
  800db6:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db9:	ff 45 fc             	incl   -0x4(%ebp)
  800dbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dbf:	3b 45 10             	cmp    0x10(%ebp),%eax
  800dc2:	72 d9                	jb     800d9d <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800dc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dc7:	c9                   	leave  
  800dc8:	c3                   	ret    

00800dc9 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800dd5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dd9:	74 30                	je     800e0b <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800ddb:	eb 16                	jmp    800df3 <strlcpy+0x2a>
			*dst++ = *src++;
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	8d 50 01             	lea    0x1(%eax),%edx
  800de3:	89 55 08             	mov    %edx,0x8(%ebp)
  800de6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de9:	8d 4a 01             	lea    0x1(%edx),%ecx
  800dec:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800def:	8a 12                	mov    (%edx),%dl
  800df1:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df3:	ff 4d 10             	decl   0x10(%ebp)
  800df6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dfa:	74 09                	je     800e05 <strlcpy+0x3c>
  800dfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dff:	8a 00                	mov    (%eax),%al
  800e01:	84 c0                	test   %al,%al
  800e03:	75 d8                	jne    800ddd <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800e11:	29 c2                	sub    %eax,%edx
  800e13:	89 d0                	mov    %edx,%eax
}
  800e15:	c9                   	leave  
  800e16:	c3                   	ret    

00800e17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800e1a:	eb 06                	jmp    800e22 <strcmp+0xb>
		p++, q++;
  800e1c:	ff 45 08             	incl   0x8(%ebp)
  800e1f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e22:	8b 45 08             	mov    0x8(%ebp),%eax
  800e25:	8a 00                	mov    (%eax),%al
  800e27:	84 c0                	test   %al,%al
  800e29:	74 0e                	je     800e39 <strcmp+0x22>
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	8a 10                	mov    (%eax),%dl
  800e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e33:	8a 00                	mov    (%eax),%al
  800e35:	38 c2                	cmp    %al,%dl
  800e37:	74 e3                	je     800e1c <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	8a 00                	mov    (%eax),%al
  800e3e:	0f b6 d0             	movzbl %al,%edx
  800e41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e44:	8a 00                	mov    (%eax),%al
  800e46:	0f b6 c0             	movzbl %al,%eax
  800e49:	29 c2                	sub    %eax,%edx
  800e4b:	89 d0                	mov    %edx,%eax
}
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800e52:	eb 09                	jmp    800e5d <strncmp+0xe>
		n--, p++, q++;
  800e54:	ff 4d 10             	decl   0x10(%ebp)
  800e57:	ff 45 08             	incl   0x8(%ebp)
  800e5a:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800e5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e61:	74 17                	je     800e7a <strncmp+0x2b>
  800e63:	8b 45 08             	mov    0x8(%ebp),%eax
  800e66:	8a 00                	mov    (%eax),%al
  800e68:	84 c0                	test   %al,%al
  800e6a:	74 0e                	je     800e7a <strncmp+0x2b>
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	8a 10                	mov    (%eax),%dl
  800e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e74:	8a 00                	mov    (%eax),%al
  800e76:	38 c2                	cmp    %al,%dl
  800e78:	74 da                	je     800e54 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800e7a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e7e:	75 07                	jne    800e87 <strncmp+0x38>
		return 0;
  800e80:	b8 00 00 00 00       	mov    $0x0,%eax
  800e85:	eb 14                	jmp    800e9b <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	8a 00                	mov    (%eax),%al
  800e8c:	0f b6 d0             	movzbl %al,%edx
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	8a 00                	mov    (%eax),%al
  800e94:	0f b6 c0             	movzbl %al,%eax
  800e97:	29 c2                	sub    %eax,%edx
  800e99:	89 d0                	mov    %edx,%eax
}
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	83 ec 04             	sub    $0x4,%esp
  800ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea6:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ea9:	eb 12                	jmp    800ebd <strchr+0x20>
		if (*s == c)
  800eab:	8b 45 08             	mov    0x8(%ebp),%eax
  800eae:	8a 00                	mov    (%eax),%al
  800eb0:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800eb3:	75 05                	jne    800eba <strchr+0x1d>
			return (char *) s;
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	eb 11                	jmp    800ecb <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800eba:	ff 45 08             	incl   0x8(%ebp)
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	8a 00                	mov    (%eax),%al
  800ec2:	84 c0                	test   %al,%al
  800ec4:	75 e5                	jne    800eab <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800ec6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    

00800ecd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed6:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ed9:	eb 0d                	jmp    800ee8 <strfind+0x1b>
		if (*s == c)
  800edb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ede:	8a 00                	mov    (%eax),%al
  800ee0:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ee3:	74 0e                	je     800ef3 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ee5:	ff 45 08             	incl   0x8(%ebp)
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eeb:	8a 00                	mov    (%eax),%al
  800eed:	84 c0                	test   %al,%al
  800eef:	75 ea                	jne    800edb <strfind+0xe>
  800ef1:	eb 01                	jmp    800ef4 <strfind+0x27>
		if (*s == c)
			break;
  800ef3:	90                   	nop
	return (char *) s;
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ef7:	c9                   	leave  
  800ef8:	c3                   	ret    

00800ef9 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800f05:	8b 45 10             	mov    0x10(%ebp),%eax
  800f08:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800f0b:	eb 0e                	jmp    800f1b <memset+0x22>
		*p++ = c;
  800f0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f10:	8d 50 01             	lea    0x1(%eax),%edx
  800f13:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800f16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f19:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800f1b:	ff 4d f8             	decl   -0x8(%ebp)
  800f1e:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800f22:	79 e9                	jns    800f0d <memset+0x14>
		*p++ = c;

	return v;
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f32:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800f3b:	eb 16                	jmp    800f53 <memcpy+0x2a>
		*d++ = *s++;
  800f3d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800f40:	8d 50 01             	lea    0x1(%eax),%edx
  800f43:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800f46:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f49:	8d 4a 01             	lea    0x1(%edx),%ecx
  800f4c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800f4f:	8a 12                	mov    (%edx),%dl
  800f51:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800f53:	8b 45 10             	mov    0x10(%ebp),%eax
  800f56:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f59:	89 55 10             	mov    %edx,0x10(%ebp)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	75 dd                	jne    800f3d <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800f60:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800f71:	8b 45 08             	mov    0x8(%ebp),%eax
  800f74:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800f77:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f7a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800f7d:	73 50                	jae    800fcf <memmove+0x6a>
  800f7f:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800f82:	8b 45 10             	mov    0x10(%ebp),%eax
  800f85:	01 d0                	add    %edx,%eax
  800f87:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800f8a:	76 43                	jbe    800fcf <memmove+0x6a>
		s += n;
  800f8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8f:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800f92:	8b 45 10             	mov    0x10(%ebp),%eax
  800f95:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800f98:	eb 10                	jmp    800faa <memmove+0x45>
			*--d = *--s;
  800f9a:	ff 4d f8             	decl   -0x8(%ebp)
  800f9d:	ff 4d fc             	decl   -0x4(%ebp)
  800fa0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fa3:	8a 10                	mov    (%eax),%dl
  800fa5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fa8:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800faa:	8b 45 10             	mov    0x10(%ebp),%eax
  800fad:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fb0:	89 55 10             	mov    %edx,0x10(%ebp)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	75 e3                	jne    800f9a <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800fb7:	eb 23                	jmp    800fdc <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800fb9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fbc:	8d 50 01             	lea    0x1(%eax),%edx
  800fbf:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800fc2:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800fc5:	8d 4a 01             	lea    0x1(%edx),%ecx
  800fc8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800fcb:	8a 12                	mov    (%edx),%dl
  800fcd:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800fcf:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd2:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fd5:	89 55 10             	mov    %edx,0x10(%ebp)
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	75 dd                	jne    800fb9 <memmove+0x54>
			*d++ = *s++;

	return dst;
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fea:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800fed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff0:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ff3:	eb 2a                	jmp    80101f <memcmp+0x3e>
		if (*s1 != *s2)
  800ff5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ff8:	8a 10                	mov    (%eax),%dl
  800ffa:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ffd:	8a 00                	mov    (%eax),%al
  800fff:	38 c2                	cmp    %al,%dl
  801001:	74 16                	je     801019 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  801003:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801006:	8a 00                	mov    (%eax),%al
  801008:	0f b6 d0             	movzbl %al,%edx
  80100b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80100e:	8a 00                	mov    (%eax),%al
  801010:	0f b6 c0             	movzbl %al,%eax
  801013:	29 c2                	sub    %eax,%edx
  801015:	89 d0                	mov    %edx,%eax
  801017:	eb 18                	jmp    801031 <memcmp+0x50>
		s1++, s2++;
  801019:	ff 45 fc             	incl   -0x4(%ebp)
  80101c:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  80101f:	8b 45 10             	mov    0x10(%ebp),%eax
  801022:	8d 50 ff             	lea    -0x1(%eax),%edx
  801025:	89 55 10             	mov    %edx,0x10(%ebp)
  801028:	85 c0                	test   %eax,%eax
  80102a:	75 c9                	jne    800ff5 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80102c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801039:	8b 55 08             	mov    0x8(%ebp),%edx
  80103c:	8b 45 10             	mov    0x10(%ebp),%eax
  80103f:	01 d0                	add    %edx,%eax
  801041:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801044:	eb 15                	jmp    80105b <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	8a 00                	mov    (%eax),%al
  80104b:	0f b6 d0             	movzbl %al,%edx
  80104e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801051:	0f b6 c0             	movzbl %al,%eax
  801054:	39 c2                	cmp    %eax,%edx
  801056:	74 0d                	je     801065 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801058:	ff 45 08             	incl   0x8(%ebp)
  80105b:	8b 45 08             	mov    0x8(%ebp),%eax
  80105e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801061:	72 e3                	jb     801046 <memfind+0x13>
  801063:	eb 01                	jmp    801066 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  801065:	90                   	nop
	return (void *) s;
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801069:	c9                   	leave  
  80106a:	c3                   	ret    

0080106b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801071:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801078:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107f:	eb 03                	jmp    801084 <strtol+0x19>
		s++;
  801081:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801084:	8b 45 08             	mov    0x8(%ebp),%eax
  801087:	8a 00                	mov    (%eax),%al
  801089:	3c 20                	cmp    $0x20,%al
  80108b:	74 f4                	je     801081 <strtol+0x16>
  80108d:	8b 45 08             	mov    0x8(%ebp),%eax
  801090:	8a 00                	mov    (%eax),%al
  801092:	3c 09                	cmp    $0x9,%al
  801094:	74 eb                	je     801081 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	8a 00                	mov    (%eax),%al
  80109b:	3c 2b                	cmp    $0x2b,%al
  80109d:	75 05                	jne    8010a4 <strtol+0x39>
		s++;
  80109f:	ff 45 08             	incl   0x8(%ebp)
  8010a2:	eb 13                	jmp    8010b7 <strtol+0x4c>
	else if (*s == '-')
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	8a 00                	mov    (%eax),%al
  8010a9:	3c 2d                	cmp    $0x2d,%al
  8010ab:	75 0a                	jne    8010b7 <strtol+0x4c>
		s++, neg = 1;
  8010ad:	ff 45 08             	incl   0x8(%ebp)
  8010b0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010bb:	74 06                	je     8010c3 <strtol+0x58>
  8010bd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010c1:	75 20                	jne    8010e3 <strtol+0x78>
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	8a 00                	mov    (%eax),%al
  8010c8:	3c 30                	cmp    $0x30,%al
  8010ca:	75 17                	jne    8010e3 <strtol+0x78>
  8010cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cf:	40                   	inc    %eax
  8010d0:	8a 00                	mov    (%eax),%al
  8010d2:	3c 78                	cmp    $0x78,%al
  8010d4:	75 0d                	jne    8010e3 <strtol+0x78>
		s += 2, base = 16;
  8010d6:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010da:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010e1:	eb 28                	jmp    80110b <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  8010e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010e7:	75 15                	jne    8010fe <strtol+0x93>
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	8a 00                	mov    (%eax),%al
  8010ee:	3c 30                	cmp    $0x30,%al
  8010f0:	75 0c                	jne    8010fe <strtol+0x93>
		s++, base = 8;
  8010f2:	ff 45 08             	incl   0x8(%ebp)
  8010f5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010fc:	eb 0d                	jmp    80110b <strtol+0xa0>
	else if (base == 0)
  8010fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801102:	75 07                	jne    80110b <strtol+0xa0>
		base = 10;
  801104:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	8a 00                	mov    (%eax),%al
  801110:	3c 2f                	cmp    $0x2f,%al
  801112:	7e 19                	jle    80112d <strtol+0xc2>
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	8a 00                	mov    (%eax),%al
  801119:	3c 39                	cmp    $0x39,%al
  80111b:	7f 10                	jg     80112d <strtol+0xc2>
			dig = *s - '0';
  80111d:	8b 45 08             	mov    0x8(%ebp),%eax
  801120:	8a 00                	mov    (%eax),%al
  801122:	0f be c0             	movsbl %al,%eax
  801125:	83 e8 30             	sub    $0x30,%eax
  801128:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80112b:	eb 42                	jmp    80116f <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  80112d:	8b 45 08             	mov    0x8(%ebp),%eax
  801130:	8a 00                	mov    (%eax),%al
  801132:	3c 60                	cmp    $0x60,%al
  801134:	7e 19                	jle    80114f <strtol+0xe4>
  801136:	8b 45 08             	mov    0x8(%ebp),%eax
  801139:	8a 00                	mov    (%eax),%al
  80113b:	3c 7a                	cmp    $0x7a,%al
  80113d:	7f 10                	jg     80114f <strtol+0xe4>
			dig = *s - 'a' + 10;
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	8a 00                	mov    (%eax),%al
  801144:	0f be c0             	movsbl %al,%eax
  801147:	83 e8 57             	sub    $0x57,%eax
  80114a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80114d:	eb 20                	jmp    80116f <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	8a 00                	mov    (%eax),%al
  801154:	3c 40                	cmp    $0x40,%al
  801156:	7e 39                	jle    801191 <strtol+0x126>
  801158:	8b 45 08             	mov    0x8(%ebp),%eax
  80115b:	8a 00                	mov    (%eax),%al
  80115d:	3c 5a                	cmp    $0x5a,%al
  80115f:	7f 30                	jg     801191 <strtol+0x126>
			dig = *s - 'A' + 10;
  801161:	8b 45 08             	mov    0x8(%ebp),%eax
  801164:	8a 00                	mov    (%eax),%al
  801166:	0f be c0             	movsbl %al,%eax
  801169:	83 e8 37             	sub    $0x37,%eax
  80116c:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80116f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801172:	3b 45 10             	cmp    0x10(%ebp),%eax
  801175:	7d 19                	jge    801190 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  801177:	ff 45 08             	incl   0x8(%ebp)
  80117a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80117d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801181:	89 c2                	mov    %eax,%edx
  801183:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801186:	01 d0                	add    %edx,%eax
  801188:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80118b:	e9 7b ff ff ff       	jmp    80110b <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  801190:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801191:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801195:	74 08                	je     80119f <strtol+0x134>
		*endptr = (char *) s;
  801197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119a:	8b 55 08             	mov    0x8(%ebp),%edx
  80119d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80119f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011a3:	74 07                	je     8011ac <strtol+0x141>
  8011a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011a8:	f7 d8                	neg    %eax
  8011aa:	eb 03                	jmp    8011af <strtol+0x144>
  8011ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011af:	c9                   	leave  
  8011b0:	c3                   	ret    

008011b1 <ltostr>:

void
ltostr(long value, char *str)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  8011b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  8011be:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  8011c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8011c9:	79 13                	jns    8011de <ltostr+0x2d>
	{
		neg = 1;
  8011cb:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  8011d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d5:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  8011d8:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  8011db:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  8011de:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8011e6:	99                   	cltd   
  8011e7:	f7 f9                	idiv   %ecx
  8011e9:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  8011ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011ef:	8d 50 01             	lea    0x1(%eax),%edx
  8011f2:	89 55 f8             	mov    %edx,-0x8(%ebp)
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fa:	01 d0                	add    %edx,%eax
  8011fc:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8011ff:	83 c2 30             	add    $0x30,%edx
  801202:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  801204:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801207:	b8 67 66 66 66       	mov    $0x66666667,%eax
  80120c:	f7 e9                	imul   %ecx
  80120e:	c1 fa 02             	sar    $0x2,%edx
  801211:	89 c8                	mov    %ecx,%eax
  801213:	c1 f8 1f             	sar    $0x1f,%eax
  801216:	29 c2                	sub    %eax,%edx
  801218:	89 d0                	mov    %edx,%eax
  80121a:	89 45 08             	mov    %eax,0x8(%ebp)
	/*2023 FIX el7 :)*/
	//} while (value % 10 != 0);
	} while (value != 0);
  80121d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801221:	75 bb                	jne    8011de <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  801223:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  80122a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80122d:	48                   	dec    %eax
  80122e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  801231:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801235:	74 3d                	je     801274 <ltostr+0xc3>
		start = 1 ;
  801237:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  80123e:	eb 34                	jmp    801274 <ltostr+0xc3>
	{
		char tmp = str[start] ;
  801240:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801243:	8b 45 0c             	mov    0xc(%ebp),%eax
  801246:	01 d0                	add    %edx,%eax
  801248:	8a 00                	mov    (%eax),%al
  80124a:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  80124d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801250:	8b 45 0c             	mov    0xc(%ebp),%eax
  801253:	01 c2                	add    %eax,%edx
  801255:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801258:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125b:	01 c8                	add    %ecx,%eax
  80125d:	8a 00                	mov    (%eax),%al
  80125f:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  801261:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801264:	8b 45 0c             	mov    0xc(%ebp),%eax
  801267:	01 c2                	add    %eax,%edx
  801269:	8a 45 eb             	mov    -0x15(%ebp),%al
  80126c:	88 02                	mov    %al,(%edx)
		start++ ;
  80126e:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  801271:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  801274:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801277:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80127a:	7c c4                	jl     801240 <ltostr+0x8f>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  80127c:	8b 55 f8             	mov    -0x8(%ebp),%edx
  80127f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801282:	01 d0                	add    %edx,%eax
  801284:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  801287:	90                   	nop
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  80128a:	55                   	push   %ebp
  80128b:	89 e5                	mov    %esp,%ebp
  80128d:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 73 fa ff ff       	call   800d0b <strlen>
  801298:	83 c4 04             	add    $0x4,%esp
  80129b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  80129e:	ff 75 0c             	pushl  0xc(%ebp)
  8012a1:	e8 65 fa ff ff       	call   800d0b <strlen>
  8012a6:	83 c4 04             	add    $0x4,%esp
  8012a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  8012ac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  8012b3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8012ba:	eb 17                	jmp    8012d3 <strcconcat+0x49>
		final[s] = str1[s] ;
  8012bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8012bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8012c2:	01 c2                	add    %eax,%edx
  8012c4:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  8012c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ca:	01 c8                	add    %ecx,%eax
  8012cc:	8a 00                	mov    (%eax),%al
  8012ce:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  8012d0:	ff 45 fc             	incl   -0x4(%ebp)
  8012d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012d6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  8012d9:	7c e1                	jl     8012bc <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  8012db:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  8012e2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  8012e9:	eb 1f                	jmp    80130a <strcconcat+0x80>
		final[s++] = str2[i] ;
  8012eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012ee:	8d 50 01             	lea    0x1(%eax),%edx
  8012f1:	89 55 fc             	mov    %edx,-0x4(%ebp)
  8012f4:	89 c2                	mov    %eax,%edx
  8012f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8012f9:	01 c2                	add    %eax,%edx
  8012fb:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  8012fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801301:	01 c8                	add    %ecx,%eax
  801303:	8a 00                	mov    (%eax),%al
  801305:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  801307:	ff 45 f8             	incl   -0x8(%ebp)
  80130a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80130d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801310:	7c d9                	jl     8012eb <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  801312:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801315:	8b 45 10             	mov    0x10(%ebp),%eax
  801318:	01 d0                	add    %edx,%eax
  80131a:	c6 00 00             	movb   $0x0,(%eax)
}
  80131d:	90                   	nop
  80131e:	c9                   	leave  
  80131f:	c3                   	ret    

00801320 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  801323:	8b 45 14             	mov    0x14(%ebp),%eax
  801326:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  80132c:	8b 45 14             	mov    0x14(%ebp),%eax
  80132f:	8b 00                	mov    (%eax),%eax
  801331:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801338:	8b 45 10             	mov    0x10(%ebp),%eax
  80133b:	01 d0                	add    %edx,%eax
  80133d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  801343:	eb 0c                	jmp    801351 <strsplit+0x31>
			*string++ = 0;
  801345:	8b 45 08             	mov    0x8(%ebp),%eax
  801348:	8d 50 01             	lea    0x1(%eax),%edx
  80134b:	89 55 08             	mov    %edx,0x8(%ebp)
  80134e:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  801351:	8b 45 08             	mov    0x8(%ebp),%eax
  801354:	8a 00                	mov    (%eax),%al
  801356:	84 c0                	test   %al,%al
  801358:	74 18                	je     801372 <strsplit+0x52>
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
  80135d:	8a 00                	mov    (%eax),%al
  80135f:	0f be c0             	movsbl %al,%eax
  801362:	50                   	push   %eax
  801363:	ff 75 0c             	pushl  0xc(%ebp)
  801366:	e8 32 fb ff ff       	call   800e9d <strchr>
  80136b:	83 c4 08             	add    $0x8,%esp
  80136e:	85 c0                	test   %eax,%eax
  801370:	75 d3                	jne    801345 <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  801372:	8b 45 08             	mov    0x8(%ebp),%eax
  801375:	8a 00                	mov    (%eax),%al
  801377:	84 c0                	test   %al,%al
  801379:	74 5a                	je     8013d5 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  80137b:	8b 45 14             	mov    0x14(%ebp),%eax
  80137e:	8b 00                	mov    (%eax),%eax
  801380:	83 f8 0f             	cmp    $0xf,%eax
  801383:	75 07                	jne    80138c <strsplit+0x6c>
		{
			return 0;
  801385:	b8 00 00 00 00       	mov    $0x0,%eax
  80138a:	eb 66                	jmp    8013f2 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  80138c:	8b 45 14             	mov    0x14(%ebp),%eax
  80138f:	8b 00                	mov    (%eax),%eax
  801391:	8d 48 01             	lea    0x1(%eax),%ecx
  801394:	8b 55 14             	mov    0x14(%ebp),%edx
  801397:	89 0a                	mov    %ecx,(%edx)
  801399:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8013a3:	01 c2                	add    %eax,%edx
  8013a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a8:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  8013aa:	eb 03                	jmp    8013af <strsplit+0x8f>
			string++;
  8013ac:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	8a 00                	mov    (%eax),%al
  8013b4:	84 c0                	test   %al,%al
  8013b6:	74 8b                	je     801343 <strsplit+0x23>
  8013b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bb:	8a 00                	mov    (%eax),%al
  8013bd:	0f be c0             	movsbl %al,%eax
  8013c0:	50                   	push   %eax
  8013c1:	ff 75 0c             	pushl  0xc(%ebp)
  8013c4:	e8 d4 fa ff ff       	call   800e9d <strchr>
  8013c9:	83 c4 08             	add    $0x8,%esp
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	74 dc                	je     8013ac <strsplit+0x8c>
			string++;
	}
  8013d0:	e9 6e ff ff ff       	jmp    801343 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  8013d5:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  8013d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d9:	8b 00                	mov    (%eax),%eax
  8013db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8013e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e5:	01 d0                	add    %edx,%eax
  8013e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  8013ed:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <str2lower>:


char* str2lower(char *dst, const char *src)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	panic("str2lower is not implemented yet!");
  8013fa:	83 ec 04             	sub    $0x4,%esp
  8013fd:	68 48 46 80 00       	push   $0x804648
  801402:	68 3f 01 00 00       	push   $0x13f
  801407:	68 6a 46 80 00       	push   $0x80466a
  80140c:	e8 a9 ef ff ff       	call   8003ba <_panic>

00801411 <sbrk>:
//=============================================
// [1] CHANGE THE BREAK LIMIT OF THE USER HEAP:
//=============================================
/*2023*/
void* sbrk(int increment)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	83 ec 08             	sub    $0x8,%esp
	return (void*) sys_sbrk(increment);
  801417:	83 ec 0c             	sub    $0xc,%esp
  80141a:	ff 75 08             	pushl  0x8(%ebp)
  80141d:	e8 9d 0a 00 00       	call   801ebf <sys_sbrk>
  801422:	83 c4 10             	add    $0x10,%esp
}
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <malloc>:
	if(pt_get_page_permissions(ptr_page_directory,virtual_address) & PERM_AVAILABLE)return 1;
	//if(virtual_address&PERM_AVAILABLE) return 1;
	return 0;
}*/
void* malloc(uint32 size)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 38             	sub    $0x38,%esp
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
  80142d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801431:	75 0a                	jne    80143d <malloc+0x16>
  801433:	b8 00 00 00 00       	mov    $0x0,%eax
  801438:	e9 07 02 00 00       	jmp    801644 <malloc+0x21d>
	// Write your code here, remove the panic and write your code
//	panic("malloc() is not implemented yet...!!");
//	return NULL;
	//Use sys_isUHeapPlacementStrategyFIRSTFIT() and	sys_isUHeapPlacementStrategyBESTFIT()
	//to check the current strategy
	uint32 num_pages = ROUNDUP(size ,PAGE_SIZE) / PAGE_SIZE;
  80143d:	c7 45 dc 00 10 00 00 	movl   $0x1000,-0x24(%ebp)
  801444:	8b 55 08             	mov    0x8(%ebp),%edx
  801447:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80144a:	01 d0                	add    %edx,%eax
  80144c:	48                   	dec    %eax
  80144d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801450:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801453:	ba 00 00 00 00       	mov    $0x0,%edx
  801458:	f7 75 dc             	divl   -0x24(%ebp)
  80145b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80145e:	29 d0                	sub    %edx,%eax
  801460:	c1 e8 0c             	shr    $0xc,%eax
  801463:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	uint32 max_no_of_pages = ROUNDDOWN((uint32)USER_HEAP_MAX - (myEnv->heap_hard_limit + (uint32)PAGE_SIZE) ,PAGE_SIZE) / PAGE_SIZE;
  801466:	a1 20 50 80 00       	mov    0x805020,%eax
  80146b:	8b 40 78             	mov    0x78(%eax),%eax
  80146e:	ba 00 f0 ff 9f       	mov    $0x9ffff000,%edx
  801473:	29 c2                	sub    %eax,%edx
  801475:	89 d0                	mov    %edx,%eax
  801477:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80147a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80147d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801482:	c1 e8 0c             	shr    $0xc,%eax
  801485:	89 45 cc             	mov    %eax,-0x34(%ebp)
	void *ptr = NULL;
  801488:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	if (size <= DYN_ALLOC_MAX_BLOCK_SIZE)
  80148f:	81 7d 08 00 08 00 00 	cmpl   $0x800,0x8(%ebp)
  801496:	77 42                	ja     8014da <malloc+0xb3>
	{
		if (sys_isUHeapPlacementStrategyFIRSTFIT())
  801498:	e8 a6 08 00 00       	call   801d43 <sys_isUHeapPlacementStrategyFIRSTFIT>
  80149d:	85 c0                	test   %eax,%eax
  80149f:	74 16                	je     8014b7 <malloc+0x90>
		{
			//cprintf("47\n");
			ptr = alloc_block_FF(size);
  8014a1:	83 ec 0c             	sub    $0xc,%esp
  8014a4:	ff 75 08             	pushl  0x8(%ebp)
  8014a7:	e8 e6 0d 00 00       	call   802292 <alloc_block_FF>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8014b2:	e9 8a 01 00 00       	jmp    801641 <malloc+0x21a>
		}
		else if (sys_isUHeapPlacementStrategyBESTFIT())
  8014b7:	e8 b8 08 00 00       	call   801d74 <sys_isUHeapPlacementStrategyBESTFIT>
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	0f 84 7d 01 00 00    	je     801641 <malloc+0x21a>
			ptr = alloc_block_BF(size);
  8014c4:	83 ec 0c             	sub    $0xc,%esp
  8014c7:	ff 75 08             	pushl  0x8(%ebp)
  8014ca:	e8 7f 12 00 00       	call   80274e <alloc_block_BF>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8014d5:	e9 67 01 00 00       	jmp    801641 <malloc+0x21a>
	}
	else if(num_pages < max_no_of_pages-1) // the else statement in kern/mem/kheap.c/kmalloc is wrong, rewrite it to be correct.
  8014da:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014dd:	48                   	dec    %eax
  8014de:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  8014e1:	0f 86 53 01 00 00    	jbe    80163a <malloc+0x213>
	{
		//cprintf("52\n");
		uint32 i = myEnv->heap_hard_limit + PAGE_SIZE;											// start: hardlimit + 4  ______ end: KERNEL_HEAP_MAX
  8014e7:	a1 20 50 80 00       	mov    0x805020,%eax
  8014ec:	8b 40 78             	mov    0x78(%eax),%eax
  8014ef:	05 00 10 00 00       	add    $0x1000,%eax
  8014f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bool ok = 0;
  8014f7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		while (i < (uint32)USER_HEAP_MAX)
  8014fe:	e9 de 00 00 00       	jmp    8015e1 <malloc+0x1ba>
		{
			//cprintf("57\n");
			if (!isPageMarked[UHEAP_PAGE_INDEX(i)])
  801503:	a1 20 50 80 00       	mov    0x805020,%eax
  801508:	8b 40 78             	mov    0x78(%eax),%eax
  80150b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80150e:	29 c2                	sub    %eax,%edx
  801510:	89 d0                	mov    %edx,%eax
  801512:	2d 00 10 00 00       	sub    $0x1000,%eax
  801517:	c1 e8 0c             	shr    $0xc,%eax
  80151a:	8b 04 85 60 50 80 00 	mov    0x805060(,%eax,4),%eax
  801521:	85 c0                	test   %eax,%eax
  801523:	0f 85 ab 00 00 00    	jne    8015d4 <malloc+0x1ad>
			{
				//cprintf("60\n");
				uint32 j = i + (uint32)PAGE_SIZE;
  801529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152c:	05 00 10 00 00       	add    $0x1000,%eax
  801531:	89 45 e8             	mov    %eax,-0x18(%ebp)
				uint32 cnt = 0;
  801534:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

				//cprintf("64\n");
				while(cnt < num_pages - 1)
  80153b:	eb 47                	jmp    801584 <malloc+0x15d>
				{
					if(j >= (uint32)USER_HEAP_MAX) return NULL;
  80153d:	81 7d e8 ff ff ff 9f 	cmpl   $0x9fffffff,-0x18(%ebp)
  801544:	76 0a                	jbe    801550 <malloc+0x129>
  801546:	b8 00 00 00 00       	mov    $0x0,%eax
  80154b:	e9 f4 00 00 00       	jmp    801644 <malloc+0x21d>
					if (isPageMarked[UHEAP_PAGE_INDEX(j)])
  801550:	a1 20 50 80 00       	mov    0x805020,%eax
  801555:	8b 40 78             	mov    0x78(%eax),%eax
  801558:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80155b:	29 c2                	sub    %eax,%edx
  80155d:	89 d0                	mov    %edx,%eax
  80155f:	2d 00 10 00 00       	sub    $0x1000,%eax
  801564:	c1 e8 0c             	shr    $0xc,%eax
  801567:	8b 04 85 60 50 80 00 	mov    0x805060(,%eax,4),%eax
  80156e:	85 c0                	test   %eax,%eax
  801570:	74 08                	je     80157a <malloc+0x153>
					{
						//cprintf("71\n");
						i = j;
  801572:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801575:	89 45 f0             	mov    %eax,-0x10(%ebp)
						goto sayed;
  801578:	eb 5a                	jmp    8015d4 <malloc+0x1ad>
					}

					j += (uint32)PAGE_SIZE; // <-- changed, was j ++
  80157a:	81 45 e8 00 10 00 00 	addl   $0x1000,-0x18(%ebp)

					cnt++;
  801581:	ff 45 e4             	incl   -0x1c(%ebp)
				//cprintf("60\n");
				uint32 j = i + (uint32)PAGE_SIZE;
				uint32 cnt = 0;

				//cprintf("64\n");
				while(cnt < num_pages - 1)
  801584:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801587:	48                   	dec    %eax
  801588:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  80158b:	77 b0                	ja     80153d <malloc+0x116>

					j += (uint32)PAGE_SIZE; // <-- changed, was j ++

					cnt++;
				}
				ok = 1;
  80158d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
				for(int k = 0;k<num_pages;k++)
  801594:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  80159b:	eb 2f                	jmp    8015cc <malloc+0x1a5>
				{
					isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+i)]=1;
  80159d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015a0:	c1 e0 0c             	shl    $0xc,%eax
  8015a3:	89 c2                	mov    %eax,%edx
  8015a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a8:	01 c2                	add    %eax,%edx
  8015aa:	a1 20 50 80 00       	mov    0x805020,%eax
  8015af:	8b 40 78             	mov    0x78(%eax),%eax
  8015b2:	29 c2                	sub    %eax,%edx
  8015b4:	89 d0                	mov    %edx,%eax
  8015b6:	2d 00 10 00 00       	sub    $0x1000,%eax
  8015bb:	c1 e8 0c             	shr    $0xc,%eax
  8015be:	c7 04 85 60 50 80 00 	movl   $0x1,0x805060(,%eax,4)
  8015c5:	01 00 00 00 
					j += (uint32)PAGE_SIZE; // <-- changed, was j ++

					cnt++;
				}
				ok = 1;
				for(int k = 0;k<num_pages;k++)
  8015c9:	ff 45 e0             	incl   -0x20(%ebp)
  8015cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015cf:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  8015d2:	72 c9                	jb     80159d <malloc+0x176>
				}
				//cprintf("79\n");

			}
			sayed:
			if(ok) break;
  8015d4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015d8:	75 16                	jne    8015f0 <malloc+0x1c9>
			i += (uint32)PAGE_SIZE;
  8015da:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
	else if(num_pages < max_no_of_pages-1) // the else statement in kern/mem/kheap.c/kmalloc is wrong, rewrite it to be correct.
	{
		//cprintf("52\n");
		uint32 i = myEnv->heap_hard_limit + PAGE_SIZE;											// start: hardlimit + 4  ______ end: KERNEL_HEAP_MAX
		bool ok = 0;
		while (i < (uint32)USER_HEAP_MAX)
  8015e1:	81 7d f0 ff ff ff 9f 	cmpl   $0x9fffffff,-0x10(%ebp)
  8015e8:	0f 86 15 ff ff ff    	jbe    801503 <malloc+0xdc>
  8015ee:	eb 01                	jmp    8015f1 <malloc+0x1ca>
				}
				//cprintf("79\n");

			}
			sayed:
			if(ok) break;
  8015f0:	90                   	nop
			i += (uint32)PAGE_SIZE;
		}

		if(!ok) return NULL;
  8015f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8015f5:	75 07                	jne    8015fe <malloc+0x1d7>
  8015f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015fc:	eb 46                	jmp    801644 <malloc+0x21d>
		ptr = (void*)i;
  8015fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801601:	89 45 f4             	mov    %eax,-0xc(%ebp)
		no_pages_marked[UHEAP_PAGE_INDEX(i)] = num_pages;
  801604:	a1 20 50 80 00       	mov    0x805020,%eax
  801609:	8b 40 78             	mov    0x78(%eax),%eax
  80160c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80160f:	29 c2                	sub    %eax,%edx
  801611:	89 d0                	mov    %edx,%eax
  801613:	2d 00 10 00 00       	sub    $0x1000,%eax
  801618:	c1 e8 0c             	shr    $0xc,%eax
  80161b:	89 c2                	mov    %eax,%edx
  80161d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801620:	89 04 95 60 50 88 00 	mov    %eax,0x885060(,%edx,4)
		sys_allocate_user_mem(i, size);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	ff 75 08             	pushl  0x8(%ebp)
  80162d:	ff 75 f0             	pushl  -0x10(%ebp)
  801630:	e8 c1 08 00 00       	call   801ef6 <sys_allocate_user_mem>
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	eb 07                	jmp    801641 <malloc+0x21a>
		//cprintf("91\n");
	}
	else
	{
		return NULL;
  80163a:	b8 00 00 00 00       	mov    $0x0,%eax
  80163f:	eb 03                	jmp    801644 <malloc+0x21d>
	}
	return ptr;
  801641:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801644:	c9                   	leave  
  801645:	c3                   	ret    

00801646 <free>:

//=================================
// [3] FREE SPACE FROM USER HEAP:
//=================================
void free(void* va)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 18             	sub    $0x18,%esp
	//TODO: [PROJECT'24.MS2 - #14] [3] USER HEAP [USER SIDE] - free()
	// Write your code here, remove the panic and write your code
//	panic("free() is not implemented yet...!!");
	//what's the hard_limit of user heap
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
  80164c:	a1 20 50 80 00       	mov    0x805020,%eax
  801651:	8b 40 78             	mov    0x78(%eax),%eax
  801654:	05 00 10 00 00       	add    $0x1000,%eax
  801659:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 size = 0;
  80165c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	if((uint32)va < myEnv->heap_hard_limit){
  801663:	a1 20 50 80 00       	mov    0x805020,%eax
  801668:	8b 50 78             	mov    0x78(%eax),%edx
  80166b:	8b 45 08             	mov    0x8(%ebp),%eax
  80166e:	39 c2                	cmp    %eax,%edx
  801670:	76 24                	jbe    801696 <free+0x50>
		size = get_block_size(va);
  801672:	83 ec 0c             	sub    $0xc,%esp
  801675:	ff 75 08             	pushl  0x8(%ebp)
  801678:	e8 95 08 00 00       	call   801f12 <get_block_size>
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	89 45 ec             	mov    %eax,-0x14(%ebp)
		free_block(va);
  801683:	83 ec 0c             	sub    $0xc,%esp
  801686:	ff 75 08             	pushl  0x8(%ebp)
  801689:	e8 c8 1a 00 00       	call   803156 <free_block>
  80168e:	83 c4 10             	add    $0x10,%esp
		}
		sys_free_user_mem((uint32)va, size);
	} else{
		panic("User free: The virtual Address is invalid");
	}
}
  801691:	e9 ac 00 00 00       	jmp    801742 <free+0xfc>
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
	uint32 size = 0;
	if((uint32)va < myEnv->heap_hard_limit){
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80169c:	0f 82 89 00 00 00    	jb     80172b <free+0xe5>
  8016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a5:	3d ff ff ff 9f       	cmp    $0x9fffffff,%eax
  8016aa:	77 7f                	ja     80172b <free+0xe5>
		uint32 no_of_pages = no_pages_marked[UHEAP_PAGE_INDEX((uint32)va)];
  8016ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8016af:	a1 20 50 80 00       	mov    0x805020,%eax
  8016b4:	8b 40 78             	mov    0x78(%eax),%eax
  8016b7:	29 c2                	sub    %eax,%edx
  8016b9:	89 d0                	mov    %edx,%eax
  8016bb:	2d 00 10 00 00       	sub    $0x1000,%eax
  8016c0:	c1 e8 0c             	shr    $0xc,%eax
  8016c3:	8b 04 85 60 50 88 00 	mov    0x885060(,%eax,4),%eax
  8016ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
		size = no_of_pages * PAGE_SIZE;
  8016cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8016d0:	c1 e0 0c             	shl    $0xc,%eax
  8016d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for(int k = 0;k<no_of_pages;k++)
  8016d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8016dd:	eb 2f                	jmp    80170e <free+0xc8>
		{
			isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+(uint32)va)]=0;
  8016df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e2:	c1 e0 0c             	shl    $0xc,%eax
  8016e5:	89 c2                	mov    %eax,%edx
  8016e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ea:	01 c2                	add    %eax,%edx
  8016ec:	a1 20 50 80 00       	mov    0x805020,%eax
  8016f1:	8b 40 78             	mov    0x78(%eax),%eax
  8016f4:	29 c2                	sub    %eax,%edx
  8016f6:	89 d0                	mov    %edx,%eax
  8016f8:	2d 00 10 00 00       	sub    $0x1000,%eax
  8016fd:	c1 e8 0c             	shr    $0xc,%eax
  801700:	c7 04 85 60 50 80 00 	movl   $0x0,0x805060(,%eax,4)
  801707:	00 00 00 00 
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
		uint32 no_of_pages = no_pages_marked[UHEAP_PAGE_INDEX((uint32)va)];
		size = no_of_pages * PAGE_SIZE;
		for(int k = 0;k<no_of_pages;k++)
  80170b:	ff 45 f4             	incl   -0xc(%ebp)
  80170e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801711:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  801714:	72 c9                	jb     8016df <free+0x99>
		{
			isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+(uint32)va)]=0;
		}
		sys_free_user_mem((uint32)va, size);
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	83 ec 08             	sub    $0x8,%esp
  80171c:	ff 75 ec             	pushl  -0x14(%ebp)
  80171f:	50                   	push   %eax
  801720:	e8 b5 07 00 00       	call   801eda <sys_free_user_mem>
  801725:	83 c4 10             	add    $0x10,%esp
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
	uint32 size = 0;
	if((uint32)va < myEnv->heap_hard_limit){
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
  801728:	90                   	nop
		}
		sys_free_user_mem((uint32)va, size);
	} else{
		panic("User free: The virtual Address is invalid");
	}
}
  801729:	eb 17                	jmp    801742 <free+0xfc>
		{
			isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+(uint32)va)]=0;
		}
		sys_free_user_mem((uint32)va, size);
	} else{
		panic("User free: The virtual Address is invalid");
  80172b:	83 ec 04             	sub    $0x4,%esp
  80172e:	68 78 46 80 00       	push   $0x804678
  801733:	68 84 00 00 00       	push   $0x84
  801738:	68 a2 46 80 00       	push   $0x8046a2
  80173d:	e8 78 ec ff ff       	call   8003ba <_panic>
	}
}
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <smalloc>:

//=================================
// [4] ALLOCATE SHARED VARIABLE:
//=================================
void* smalloc(char *sharedVarName, uint32 size, uint8 isWritable)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	83 ec 28             	sub    $0x28,%esp
  80174a:	8b 45 10             	mov    0x10(%ebp),%eax
  80174d:	88 45 e4             	mov    %al,-0x1c(%ebp)
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
  801750:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801754:	75 07                	jne    80175d <smalloc+0x19>
  801756:	b8 00 00 00 00       	mov    $0x0,%eax
  80175b:	eb 74                	jmp    8017d1 <smalloc+0x8d>
	//==============================================================
	//TODO: [PROJECT'24.MS2 - #18] [4] SHARED MEMORY [USER SIDE] - smalloc()
	// Write your code here, remove the panic and write your code
	//panic("smalloc() is not implemented yet...!!");
	void *ptr = malloc(MAX(size,PAGE_SIZE));
  80175d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801760:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801763:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  80176a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80176d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801770:	39 d0                	cmp    %edx,%eax
  801772:	73 02                	jae    801776 <smalloc+0x32>
  801774:	89 d0                	mov    %edx,%eax
  801776:	83 ec 0c             	sub    $0xc,%esp
  801779:	50                   	push   %eax
  80177a:	e8 a8 fc ff ff       	call   801427 <malloc>
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(ptr == NULL) return NULL;
  801785:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801789:	75 07                	jne    801792 <smalloc+0x4e>
  80178b:	b8 00 00 00 00       	mov    $0x0,%eax
  801790:	eb 3f                	jmp    8017d1 <smalloc+0x8d>
	 int ret = sys_createSharedObject(sharedVarName, size,  isWritable, ptr);
  801792:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
  801796:	ff 75 ec             	pushl  -0x14(%ebp)
  801799:	50                   	push   %eax
  80179a:	ff 75 0c             	pushl  0xc(%ebp)
  80179d:	ff 75 08             	pushl  0x8(%ebp)
  8017a0:	e8 3c 03 00 00       	call   801ae1 <sys_createSharedObject>
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	89 45 e8             	mov    %eax,-0x18(%ebp)
	 if(ret == E_NO_SHARE || ret == E_SHARED_MEM_EXISTS) return NULL;
  8017ab:	83 7d e8 f2          	cmpl   $0xfffffff2,-0x18(%ebp)
  8017af:	74 06                	je     8017b7 <smalloc+0x73>
  8017b1:	83 7d e8 f1          	cmpl   $0xfffffff1,-0x18(%ebp)
  8017b5:	75 07                	jne    8017be <smalloc+0x7a>
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bc:	eb 13                	jmp    8017d1 <smalloc+0x8d>
	 cprintf("153\n");
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	68 ae 46 80 00       	push   $0x8046ae
  8017c6:	e8 ac ee ff ff       	call   800677 <cprintf>
  8017cb:	83 c4 10             	add    $0x10,%esp
	 return ptr;
  8017ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <sget>:

//========================================
// [5] SHARE ON ALLOCATED SHARED VARIABLE:
//========================================
void* sget(int32 ownerEnvID, char *sharedVarName)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	83 ec 28             	sub    $0x28,%esp
	//TODO: [PROJECT'24.MS2 - #20] [4] SHARED MEMORY [USER SIDE] - sget()
	// Write your code here, remove the panic and write your code
	//panic("sget() is not implemented yet...!!");
	int size = sys_getSizeOfSharedObject(ownerEnvID,sharedVarName);
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	ff 75 0c             	pushl  0xc(%ebp)
  8017df:	ff 75 08             	pushl  0x8(%ebp)
  8017e2:	e8 24 03 00 00       	call   801b0b <sys_getSizeOfSharedObject>
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(size == E_SHARED_MEM_NOT_EXISTS) return NULL;
  8017ed:	83 7d f4 f0          	cmpl   $0xfffffff0,-0xc(%ebp)
  8017f1:	75 07                	jne    8017fa <sget+0x27>
  8017f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f8:	eb 5c                	jmp    801856 <sget+0x83>
	void * ptr = malloc(MAX(size,PAGE_SIZE));
  8017fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801800:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
  801807:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80180a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180d:	39 d0                	cmp    %edx,%eax
  80180f:	7d 02                	jge    801813 <sget+0x40>
  801811:	89 d0                	mov    %edx,%eax
  801813:	83 ec 0c             	sub    $0xc,%esp
  801816:	50                   	push   %eax
  801817:	e8 0b fc ff ff       	call   801427 <malloc>
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if(ptr == NULL) return NULL;
  801822:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801826:	75 07                	jne    80182f <sget+0x5c>
  801828:	b8 00 00 00 00       	mov    $0x0,%eax
  80182d:	eb 27                	jmp    801856 <sget+0x83>
	int ret = sys_getSharedObject(ownerEnvID,sharedVarName,ptr);
  80182f:	83 ec 04             	sub    $0x4,%esp
  801832:	ff 75 e8             	pushl  -0x18(%ebp)
  801835:	ff 75 0c             	pushl  0xc(%ebp)
  801838:	ff 75 08             	pushl  0x8(%ebp)
  80183b:	e8 e8 02 00 00       	call   801b28 <sys_getSharedObject>
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(ret == E_SHARED_MEM_NOT_EXISTS ) return NULL;
  801846:	83 7d e4 f0          	cmpl   $0xfffffff0,-0x1c(%ebp)
  80184a:	75 07                	jne    801853 <sget+0x80>
  80184c:	b8 00 00 00 00       	mov    $0x0,%eax
  801851:	eb 03                	jmp    801856 <sget+0x83>
	return ptr;
  801853:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  801856:	c9                   	leave  
  801857:	c3                   	ret    

00801858 <sfree>:
//	use sys_freeSharedObject(...); which switches to the kernel mode,
//	calls freeSharedObject(...) in "shared_memory_manager.c", then switch back to the user mode here
//	the freeSharedObject() function is empty, make sure to implement it.

void sfree(void* virtual_address)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 08             	sub    $0x8,%esp
	//TODO: [PROJECT'24.MS2 - BONUS#4] [4] SHARED MEMORY [USER SIDE] - sfree()
	// Write your code here, remove the panic and write your code
	panic("sfree() is not implemented yet...!!");
  80185e:	83 ec 04             	sub    $0x4,%esp
  801861:	68 b4 46 80 00       	push   $0x8046b4
  801866:	68 c2 00 00 00       	push   $0xc2
  80186b:	68 a2 46 80 00       	push   $0x8046a2
  801870:	e8 45 eb ff ff       	call   8003ba <_panic>

00801875 <realloc>:
//  Hint: you may need to use the sys_move_user_mem(...)
//		which switches to the kernel mode, calls move_user_mem(...)
//		in "kern/mem/chunk_operations.c", then switch back to the user mode here
//	the move_user_mem() function is empty, make sure to implement it.
void *realloc(void *virtual_address, uint32 new_size)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	// Write your code here, remove the panic and write your code
	panic("realloc() is not implemented yet...!!");
  80187b:	83 ec 04             	sub    $0x4,%esp
  80187e:	68 d8 46 80 00       	push   $0x8046d8
  801883:	68 d9 00 00 00       	push   $0xd9
  801888:	68 a2 46 80 00       	push   $0x8046a2
  80188d:	e8 28 eb ff ff       	call   8003ba <_panic>

00801892 <expand>:
//==================================================================================//
//========================== MODIFICATION FUNCTIONS ================================//
//==================================================================================//

void expand(uint32 newSize)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  801898:	83 ec 04             	sub    $0x4,%esp
  80189b:	68 fe 46 80 00       	push   $0x8046fe
  8018a0:	68 e5 00 00 00       	push   $0xe5
  8018a5:	68 a2 46 80 00       	push   $0x8046a2
  8018aa:	e8 0b eb ff ff       	call   8003ba <_panic>

008018af <shrink>:

}
void shrink(uint32 newSize)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  8018b5:	83 ec 04             	sub    $0x4,%esp
  8018b8:	68 fe 46 80 00       	push   $0x8046fe
  8018bd:	68 ea 00 00 00       	push   $0xea
  8018c2:	68 a2 46 80 00       	push   $0x8046a2
  8018c7:	e8 ee ea ff ff       	call   8003ba <_panic>

008018cc <freeHeap>:

}
void freeHeap(void* virtual_address)
{
  8018cc:	55                   	push   %ebp
  8018cd:	89 e5                	mov    %esp,%ebp
  8018cf:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  8018d2:	83 ec 04             	sub    $0x4,%esp
  8018d5:	68 fe 46 80 00       	push   $0x8046fe
  8018da:	68 ef 00 00 00       	push   $0xef
  8018df:	68 a2 46 80 00       	push   $0x8046a2
  8018e4:	e8 d1 ea ff ff       	call   8003ba <_panic>

008018e9 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	57                   	push   %edi
  8018ed:	56                   	push   %esi
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018fb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8018fe:	8b 7d 18             	mov    0x18(%ebp),%edi
  801901:	8b 75 1c             	mov    0x1c(%ebp),%esi
  801904:	cd 30                	int    $0x30
  801906:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  801909:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5f                   	pop    %edi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	83 ec 04             	sub    $0x4,%esp
  80191a:	8b 45 10             	mov    0x10(%ebp),%eax
  80191d:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  801920:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801924:	8b 45 08             	mov    0x8(%ebp),%eax
  801927:	6a 00                	push   $0x0
  801929:	6a 00                	push   $0x0
  80192b:	52                   	push   %edx
  80192c:	ff 75 0c             	pushl  0xc(%ebp)
  80192f:	50                   	push   %eax
  801930:	6a 00                	push   $0x0
  801932:	e8 b2 ff ff ff       	call   8018e9 <syscall>
  801937:	83 c4 18             	add    $0x18,%esp
}
  80193a:	90                   	nop
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <sys_cgetc>:

int
sys_cgetc(void)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  801940:	6a 00                	push   $0x0
  801942:	6a 00                	push   $0x0
  801944:	6a 00                	push   $0x0
  801946:	6a 00                	push   $0x0
  801948:	6a 00                	push   $0x0
  80194a:	6a 02                	push   $0x2
  80194c:	e8 98 ff ff ff       	call   8018e9 <syscall>
  801951:	83 c4 18             	add    $0x18,%esp
}
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <sys_lock_cons>:

void sys_lock_cons(void)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
	syscall(SYS_lock_cons, 0, 0, 0, 0, 0);
  801959:	6a 00                	push   $0x0
  80195b:	6a 00                	push   $0x0
  80195d:	6a 00                	push   $0x0
  80195f:	6a 00                	push   $0x0
  801961:	6a 00                	push   $0x0
  801963:	6a 03                	push   $0x3
  801965:	e8 7f ff ff ff       	call   8018e9 <syscall>
  80196a:	83 c4 18             	add    $0x18,%esp
}
  80196d:	90                   	nop
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <sys_unlock_cons>:
void sys_unlock_cons(void)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
	syscall(SYS_unlock_cons, 0, 0, 0, 0, 0);
  801973:	6a 00                	push   $0x0
  801975:	6a 00                	push   $0x0
  801977:	6a 00                	push   $0x0
  801979:	6a 00                	push   $0x0
  80197b:	6a 00                	push   $0x0
  80197d:	6a 04                	push   $0x4
  80197f:	e8 65 ff ff ff       	call   8018e9 <syscall>
  801984:	83 c4 18             	add    $0x18,%esp
}
  801987:	90                   	nop
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  80198d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801990:	8b 45 08             	mov    0x8(%ebp),%eax
  801993:	6a 00                	push   $0x0
  801995:	6a 00                	push   $0x0
  801997:	6a 00                	push   $0x0
  801999:	52                   	push   %edx
  80199a:	50                   	push   %eax
  80199b:	6a 08                	push   $0x8
  80199d:	e8 47 ff ff ff       	call   8018e9 <syscall>
  8019a2:	83 c4 18             	add    $0x18,%esp
}
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  8019ac:	8b 75 18             	mov    0x18(%ebp),%esi
  8019af:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8019b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	51                   	push   %ecx
  8019be:	52                   	push   %edx
  8019bf:	50                   	push   %eax
  8019c0:	6a 09                	push   $0x9
  8019c2:	e8 22 ff ff ff       	call   8018e9 <syscall>
  8019c7:	83 c4 18             	add    $0x18,%esp
}
  8019ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5e                   	pop    %esi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  8019d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	6a 00                	push   $0x0
  8019dc:	6a 00                	push   $0x0
  8019de:	6a 00                	push   $0x0
  8019e0:	52                   	push   %edx
  8019e1:	50                   	push   %eax
  8019e2:	6a 0a                	push   $0xa
  8019e4:	e8 00 ff ff ff       	call   8018e9 <syscall>
  8019e9:	83 c4 18             	add    $0x18,%esp
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  8019f1:	6a 00                	push   $0x0
  8019f3:	6a 00                	push   $0x0
  8019f5:	6a 00                	push   $0x0
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	ff 75 08             	pushl  0x8(%ebp)
  8019fd:	6a 0b                	push   $0xb
  8019ff:	e8 e5 fe ff ff       	call   8018e9 <syscall>
  801a04:	83 c4 18             	add    $0x18,%esp
}
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  801a0c:	6a 00                	push   $0x0
  801a0e:	6a 00                	push   $0x0
  801a10:	6a 00                	push   $0x0
  801a12:	6a 00                	push   $0x0
  801a14:	6a 00                	push   $0x0
  801a16:	6a 0c                	push   $0xc
  801a18:	e8 cc fe ff ff       	call   8018e9 <syscall>
  801a1d:	83 c4 18             	add    $0x18,%esp
}
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  801a25:	6a 00                	push   $0x0
  801a27:	6a 00                	push   $0x0
  801a29:	6a 00                	push   $0x0
  801a2b:	6a 00                	push   $0x0
  801a2d:	6a 00                	push   $0x0
  801a2f:	6a 0d                	push   $0xd
  801a31:	e8 b3 fe ff ff       	call   8018e9 <syscall>
  801a36:	83 c4 18             	add    $0x18,%esp
}
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    

00801a3b <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  801a3b:	55                   	push   %ebp
  801a3c:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  801a3e:	6a 00                	push   $0x0
  801a40:	6a 00                	push   $0x0
  801a42:	6a 00                	push   $0x0
  801a44:	6a 00                	push   $0x0
  801a46:	6a 00                	push   $0x0
  801a48:	6a 0e                	push   $0xe
  801a4a:	e8 9a fe ff ff       	call   8018e9 <syscall>
  801a4f:	83 c4 18             	add    $0x18,%esp
}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <sys_pf_calculate_allocated_pages>:

int sys_pf_calculate_allocated_pages()
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  801a57:	6a 00                	push   $0x0
  801a59:	6a 00                	push   $0x0
  801a5b:	6a 00                	push   $0x0
  801a5d:	6a 00                	push   $0x0
  801a5f:	6a 00                	push   $0x0
  801a61:	6a 0f                	push   $0xf
  801a63:	e8 81 fe ff ff       	call   8018e9 <syscall>
  801a68:	83 c4 18             	add    $0x18,%esp
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  801a70:	6a 00                	push   $0x0
  801a72:	6a 00                	push   $0x0
  801a74:	6a 00                	push   $0x0
  801a76:	6a 00                	push   $0x0
  801a78:	ff 75 08             	pushl  0x8(%ebp)
  801a7b:	6a 10                	push   $0x10
  801a7d:	e8 67 fe ff ff       	call   8018e9 <syscall>
  801a82:	83 c4 18             	add    $0x18,%esp
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <sys_scarce_memory>:

void sys_scarce_memory()
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  801a8a:	6a 00                	push   $0x0
  801a8c:	6a 00                	push   $0x0
  801a8e:	6a 00                	push   $0x0
  801a90:	6a 00                	push   $0x0
  801a92:	6a 00                	push   $0x0
  801a94:	6a 11                	push   $0x11
  801a96:	e8 4e fe ff ff       	call   8018e9 <syscall>
  801a9b:	83 c4 18             	add    $0x18,%esp
}
  801a9e:	90                   	nop
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <sys_cputc>:

void
sys_cputc(const char c)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 04             	sub    $0x4,%esp
  801aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aaa:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801aad:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801ab1:	6a 00                	push   $0x0
  801ab3:	6a 00                	push   $0x0
  801ab5:	6a 00                	push   $0x0
  801ab7:	6a 00                	push   $0x0
  801ab9:	50                   	push   %eax
  801aba:	6a 01                	push   $0x1
  801abc:	e8 28 fe ff ff       	call   8018e9 <syscall>
  801ac1:	83 c4 18             	add    $0x18,%esp
}
  801ac4:	90                   	nop
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  801aca:	6a 00                	push   $0x0
  801acc:	6a 00                	push   $0x0
  801ace:	6a 00                	push   $0x0
  801ad0:	6a 00                	push   $0x0
  801ad2:	6a 00                	push   $0x0
  801ad4:	6a 14                	push   $0x14
  801ad6:	e8 0e fe ff ff       	call   8018e9 <syscall>
  801adb:	83 c4 18             	add    $0x18,%esp
}
  801ade:	90                   	nop
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <sys_createSharedObject>:

int sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  801aea:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801aed:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801af0:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801af4:	8b 45 08             	mov    0x8(%ebp),%eax
  801af7:	6a 00                	push   $0x0
  801af9:	51                   	push   %ecx
  801afa:	52                   	push   %edx
  801afb:	ff 75 0c             	pushl  0xc(%ebp)
  801afe:	50                   	push   %eax
  801aff:	6a 15                	push   $0x15
  801b01:	e8 e3 fd ff ff       	call   8018e9 <syscall>
  801b06:	83 c4 18             	add    $0x18,%esp
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <sys_getSizeOfSharedObject>:

//2017:
int sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  801b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b11:	8b 45 08             	mov    0x8(%ebp),%eax
  801b14:	6a 00                	push   $0x0
  801b16:	6a 00                	push   $0x0
  801b18:	6a 00                	push   $0x0
  801b1a:	52                   	push   %edx
  801b1b:	50                   	push   %eax
  801b1c:	6a 16                	push   $0x16
  801b1e:	e8 c6 fd ff ff       	call   8018e9 <syscall>
  801b23:	83 c4 18             	add    $0x18,%esp
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <sys_getSharedObject>:
//==========

int sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  801b2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	6a 00                	push   $0x0
  801b36:	6a 00                	push   $0x0
  801b38:	51                   	push   %ecx
  801b39:	52                   	push   %edx
  801b3a:	50                   	push   %eax
  801b3b:	6a 17                	push   $0x17
  801b3d:	e8 a7 fd ff ff       	call   8018e9 <syscall>
  801b42:	83 c4 18             	add    $0x18,%esp
}
  801b45:	c9                   	leave  
  801b46:	c3                   	ret    

00801b47 <sys_freeSharedObject>:

int sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  801b47:	55                   	push   %ebp
  801b48:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  801b4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b50:	6a 00                	push   $0x0
  801b52:	6a 00                	push   $0x0
  801b54:	6a 00                	push   $0x0
  801b56:	52                   	push   %edx
  801b57:	50                   	push   %eax
  801b58:	6a 18                	push   $0x18
  801b5a:	e8 8a fd ff ff       	call   8018e9 <syscall>
  801b5f:	83 c4 18             	add    $0x18,%esp
}
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6a:	6a 00                	push   $0x0
  801b6c:	ff 75 14             	pushl  0x14(%ebp)
  801b6f:	ff 75 10             	pushl  0x10(%ebp)
  801b72:	ff 75 0c             	pushl  0xc(%ebp)
  801b75:	50                   	push   %eax
  801b76:	6a 19                	push   $0x19
  801b78:	e8 6c fd ff ff       	call   8018e9 <syscall>
  801b7d:	83 c4 18             	add    $0x18,%esp
}
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <sys_run_env>:

void sys_run_env(int32 envId)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	6a 00                	push   $0x0
  801b8a:	6a 00                	push   $0x0
  801b8c:	6a 00                	push   $0x0
  801b8e:	6a 00                	push   $0x0
  801b90:	50                   	push   %eax
  801b91:	6a 1a                	push   $0x1a
  801b93:	e8 51 fd ff ff       	call   8018e9 <syscall>
  801b98:	83 c4 18             	add    $0x18,%esp
}
  801b9b:	90                   	nop
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  801ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba4:	6a 00                	push   $0x0
  801ba6:	6a 00                	push   $0x0
  801ba8:	6a 00                	push   $0x0
  801baa:	6a 00                	push   $0x0
  801bac:	50                   	push   %eax
  801bad:	6a 1b                	push   $0x1b
  801baf:	e8 35 fd ff ff       	call   8018e9 <syscall>
  801bb4:	83 c4 18             	add    $0x18,%esp
}
  801bb7:	c9                   	leave  
  801bb8:	c3                   	ret    

00801bb9 <sys_getenvid>:

int32 sys_getenvid(void)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  801bbc:	6a 00                	push   $0x0
  801bbe:	6a 00                	push   $0x0
  801bc0:	6a 00                	push   $0x0
  801bc2:	6a 00                	push   $0x0
  801bc4:	6a 00                	push   $0x0
  801bc6:	6a 05                	push   $0x5
  801bc8:	e8 1c fd ff ff       	call   8018e9 <syscall>
  801bcd:	83 c4 18             	add    $0x18,%esp
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  801bd5:	6a 00                	push   $0x0
  801bd7:	6a 00                	push   $0x0
  801bd9:	6a 00                	push   $0x0
  801bdb:	6a 00                	push   $0x0
  801bdd:	6a 00                	push   $0x0
  801bdf:	6a 06                	push   $0x6
  801be1:	e8 03 fd ff ff       	call   8018e9 <syscall>
  801be6:	83 c4 18             	add    $0x18,%esp
}
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    

00801beb <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  801bee:	6a 00                	push   $0x0
  801bf0:	6a 00                	push   $0x0
  801bf2:	6a 00                	push   $0x0
  801bf4:	6a 00                	push   $0x0
  801bf6:	6a 00                	push   $0x0
  801bf8:	6a 07                	push   $0x7
  801bfa:	e8 ea fc ff ff       	call   8018e9 <syscall>
  801bff:	83 c4 18             	add    $0x18,%esp
}
  801c02:	c9                   	leave  
  801c03:	c3                   	ret    

00801c04 <sys_exit_env>:


void sys_exit_env(void)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  801c07:	6a 00                	push   $0x0
  801c09:	6a 00                	push   $0x0
  801c0b:	6a 00                	push   $0x0
  801c0d:	6a 00                	push   $0x0
  801c0f:	6a 00                	push   $0x0
  801c11:	6a 1c                	push   $0x1c
  801c13:	e8 d1 fc ff ff       	call   8018e9 <syscall>
  801c18:	83 c4 18             	add    $0x18,%esp
}
  801c1b:	90                   	nop
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <sys_get_virtual_time>:


struct uint64 sys_get_virtual_time()
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  801c24:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801c27:	8d 50 04             	lea    0x4(%eax),%edx
  801c2a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801c2d:	6a 00                	push   $0x0
  801c2f:	6a 00                	push   $0x0
  801c31:	6a 00                	push   $0x0
  801c33:	52                   	push   %edx
  801c34:	50                   	push   %eax
  801c35:	6a 1d                	push   $0x1d
  801c37:	e8 ad fc ff ff       	call   8018e9 <syscall>
  801c3c:	83 c4 18             	add    $0x18,%esp
	return result;
  801c3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c42:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801c45:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801c48:	89 01                	mov    %eax,(%ecx)
  801c4a:	89 51 04             	mov    %edx,0x4(%ecx)
}
  801c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c50:	c9                   	leave  
  801c51:	c2 04 00             	ret    $0x4

00801c54 <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  801c57:	6a 00                	push   $0x0
  801c59:	6a 00                	push   $0x0
  801c5b:	ff 75 10             	pushl  0x10(%ebp)
  801c5e:	ff 75 0c             	pushl  0xc(%ebp)
  801c61:	ff 75 08             	pushl  0x8(%ebp)
  801c64:	6a 13                	push   $0x13
  801c66:	e8 7e fc ff ff       	call   8018e9 <syscall>
  801c6b:	83 c4 18             	add    $0x18,%esp
	return ;
  801c6e:	90                   	nop
}
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    

00801c71 <sys_rcr2>:
uint32 sys_rcr2()
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  801c74:	6a 00                	push   $0x0
  801c76:	6a 00                	push   $0x0
  801c78:	6a 00                	push   $0x0
  801c7a:	6a 00                	push   $0x0
  801c7c:	6a 00                	push   $0x0
  801c7e:	6a 1e                	push   $0x1e
  801c80:	e8 64 fc ff ff       	call   8018e9 <syscall>
  801c85:	83 c4 18             	add    $0x18,%esp
}
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <sys_bypassPageFault>:

void sys_bypassPageFault(uint8 instrLength)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 04             	sub    $0x4,%esp
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  801c96:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  801c9a:	6a 00                	push   $0x0
  801c9c:	6a 00                	push   $0x0
  801c9e:	6a 00                	push   $0x0
  801ca0:	6a 00                	push   $0x0
  801ca2:	50                   	push   %eax
  801ca3:	6a 1f                	push   $0x1f
  801ca5:	e8 3f fc ff ff       	call   8018e9 <syscall>
  801caa:	83 c4 18             	add    $0x18,%esp
	return ;
  801cad:	90                   	nop
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <rsttst>:
void rsttst()
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  801cb3:	6a 00                	push   $0x0
  801cb5:	6a 00                	push   $0x0
  801cb7:	6a 00                	push   $0x0
  801cb9:	6a 00                	push   $0x0
  801cbb:	6a 00                	push   $0x0
  801cbd:	6a 21                	push   $0x21
  801cbf:	e8 25 fc ff ff       	call   8018e9 <syscall>
  801cc4:	83 c4 18             	add    $0x18,%esp
	return ;
  801cc7:	90                   	nop
}
  801cc8:	c9                   	leave  
  801cc9:	c3                   	ret    

00801cca <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd3:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  801cd6:	8b 55 18             	mov    0x18(%ebp),%edx
  801cd9:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801cdd:	52                   	push   %edx
  801cde:	50                   	push   %eax
  801cdf:	ff 75 10             	pushl  0x10(%ebp)
  801ce2:	ff 75 0c             	pushl  0xc(%ebp)
  801ce5:	ff 75 08             	pushl  0x8(%ebp)
  801ce8:	6a 20                	push   $0x20
  801cea:	e8 fa fb ff ff       	call   8018e9 <syscall>
  801cef:	83 c4 18             	add    $0x18,%esp
	return ;
  801cf2:	90                   	nop
}
  801cf3:	c9                   	leave  
  801cf4:	c3                   	ret    

00801cf5 <chktst>:
void chktst(uint32 n)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  801cf8:	6a 00                	push   $0x0
  801cfa:	6a 00                	push   $0x0
  801cfc:	6a 00                	push   $0x0
  801cfe:	6a 00                	push   $0x0
  801d00:	ff 75 08             	pushl  0x8(%ebp)
  801d03:	6a 22                	push   $0x22
  801d05:	e8 df fb ff ff       	call   8018e9 <syscall>
  801d0a:	83 c4 18             	add    $0x18,%esp
	return ;
  801d0d:	90                   	nop
}
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <inctst>:

void inctst()
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  801d13:	6a 00                	push   $0x0
  801d15:	6a 00                	push   $0x0
  801d17:	6a 00                	push   $0x0
  801d19:	6a 00                	push   $0x0
  801d1b:	6a 00                	push   $0x0
  801d1d:	6a 23                	push   $0x23
  801d1f:	e8 c5 fb ff ff       	call   8018e9 <syscall>
  801d24:	83 c4 18             	add    $0x18,%esp
	return ;
  801d27:	90                   	nop
}
  801d28:	c9                   	leave  
  801d29:	c3                   	ret    

00801d2a <gettst>:
uint32 gettst()
{
  801d2a:	55                   	push   %ebp
  801d2b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  801d2d:	6a 00                	push   $0x0
  801d2f:	6a 00                	push   $0x0
  801d31:	6a 00                	push   $0x0
  801d33:	6a 00                	push   $0x0
  801d35:	6a 00                	push   $0x0
  801d37:	6a 24                	push   $0x24
  801d39:	e8 ab fb ff ff       	call   8018e9 <syscall>
  801d3e:	83 c4 18             	add    $0x18,%esp
}
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801d49:	6a 00                	push   $0x0
  801d4b:	6a 00                	push   $0x0
  801d4d:	6a 00                	push   $0x0
  801d4f:	6a 00                	push   $0x0
  801d51:	6a 00                	push   $0x0
  801d53:	6a 25                	push   $0x25
  801d55:	e8 8f fb ff ff       	call   8018e9 <syscall>
  801d5a:	83 c4 18             	add    $0x18,%esp
  801d5d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  801d60:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  801d64:	75 07                	jne    801d6d <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	eb 05                	jmp    801d72 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801d7a:	6a 00                	push   $0x0
  801d7c:	6a 00                	push   $0x0
  801d7e:	6a 00                	push   $0x0
  801d80:	6a 00                	push   $0x0
  801d82:	6a 00                	push   $0x0
  801d84:	6a 25                	push   $0x25
  801d86:	e8 5e fb ff ff       	call   8018e9 <syscall>
  801d8b:	83 c4 18             	add    $0x18,%esp
  801d8e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  801d91:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  801d95:	75 07                	jne    801d9e <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  801d97:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9c:	eb 05                	jmp    801da3 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  801d9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801dab:	6a 00                	push   $0x0
  801dad:	6a 00                	push   $0x0
  801daf:	6a 00                	push   $0x0
  801db1:	6a 00                	push   $0x0
  801db3:	6a 00                	push   $0x0
  801db5:	6a 25                	push   $0x25
  801db7:	e8 2d fb ff ff       	call   8018e9 <syscall>
  801dbc:	83 c4 18             	add    $0x18,%esp
  801dbf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  801dc2:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  801dc6:	75 07                	jne    801dcf <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  801dc8:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcd:	eb 05                	jmp    801dd4 <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  801dcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  801ddc:	6a 00                	push   $0x0
  801dde:	6a 00                	push   $0x0
  801de0:	6a 00                	push   $0x0
  801de2:	6a 00                	push   $0x0
  801de4:	6a 00                	push   $0x0
  801de6:	6a 25                	push   $0x25
  801de8:	e8 fc fa ff ff       	call   8018e9 <syscall>
  801ded:	83 c4 18             	add    $0x18,%esp
  801df0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  801df3:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  801df7:	75 07                	jne    801e00 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  801df9:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfe:	eb 05                	jmp    801e05 <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    

00801e07 <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  801e0a:	6a 00                	push   $0x0
  801e0c:	6a 00                	push   $0x0
  801e0e:	6a 00                	push   $0x0
  801e10:	6a 00                	push   $0x0
  801e12:	ff 75 08             	pushl  0x8(%ebp)
  801e15:	6a 26                	push   $0x26
  801e17:	e8 cd fa ff ff       	call   8018e9 <syscall>
  801e1c:	83 c4 18             	add    $0x18,%esp
	return ;
  801e1f:	90                   	nop
}
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  801e26:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801e29:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801e2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e32:	6a 00                	push   $0x0
  801e34:	53                   	push   %ebx
  801e35:	51                   	push   %ecx
  801e36:	52                   	push   %edx
  801e37:	50                   	push   %eax
  801e38:	6a 27                	push   $0x27
  801e3a:	e8 aa fa ff ff       	call   8018e9 <syscall>
  801e3f:	83 c4 18             	add    $0x18,%esp
}
  801e42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  801e4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e50:	6a 00                	push   $0x0
  801e52:	6a 00                	push   $0x0
  801e54:	6a 00                	push   $0x0
  801e56:	52                   	push   %edx
  801e57:	50                   	push   %eax
  801e58:	6a 28                	push   $0x28
  801e5a:	e8 8a fa ff ff       	call   8018e9 <syscall>
  801e5f:	83 c4 18             	add    $0x18,%esp
}
  801e62:	c9                   	leave  
  801e63:	c3                   	ret    

00801e64 <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  801e67:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e70:	6a 00                	push   $0x0
  801e72:	51                   	push   %ecx
  801e73:	ff 75 10             	pushl  0x10(%ebp)
  801e76:	52                   	push   %edx
  801e77:	50                   	push   %eax
  801e78:	6a 29                	push   $0x29
  801e7a:	e8 6a fa ff ff       	call   8018e9 <syscall>
  801e7f:	83 c4 18             	add    $0x18,%esp
}
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  801e87:	6a 00                	push   $0x0
  801e89:	6a 00                	push   $0x0
  801e8b:	ff 75 10             	pushl  0x10(%ebp)
  801e8e:	ff 75 0c             	pushl  0xc(%ebp)
  801e91:	ff 75 08             	pushl  0x8(%ebp)
  801e94:	6a 12                	push   $0x12
  801e96:	e8 4e fa ff ff       	call   8018e9 <syscall>
  801e9b:	83 c4 18             	add    $0x18,%esp
	return ;
  801e9e:	90                   	nop
}
  801e9f:	c9                   	leave  
  801ea0:	c3                   	ret    

00801ea1 <sys_utilities>:
void sys_utilities(char* utilityName, int value)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
	syscall(SYS_utilities, (uint32)utilityName, value, 0, 0, 0);
  801ea4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	6a 00                	push   $0x0
  801eac:	6a 00                	push   $0x0
  801eae:	6a 00                	push   $0x0
  801eb0:	52                   	push   %edx
  801eb1:	50                   	push   %eax
  801eb2:	6a 2a                	push   $0x2a
  801eb4:	e8 30 fa ff ff       	call   8018e9 <syscall>
  801eb9:	83 c4 18             	add    $0x18,%esp
	return;
  801ebc:	90                   	nop
}
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <sys_sbrk>:


//TODO: [PROJECT'24.MS1 - #02] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	return (void*)syscall(SYS_sbrk,increment,0,0,0,0);
  801ec2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec5:	6a 00                	push   $0x0
  801ec7:	6a 00                	push   $0x0
  801ec9:	6a 00                	push   $0x0
  801ecb:	6a 00                	push   $0x0
  801ecd:	50                   	push   %eax
  801ece:	6a 2b                	push   $0x2b
  801ed0:	e8 14 fa ff ff       	call   8018e9 <syscall>
  801ed5:	83 c4 18             	add    $0x18,%esp
}
  801ed8:	c9                   	leave  
  801ed9:	c3                   	ret    

00801eda <sys_free_user_mem>:

void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	syscall(SYS_free_user_mem,virtual_address,size,0,0,0);
  801edd:	6a 00                	push   $0x0
  801edf:	6a 00                	push   $0x0
  801ee1:	6a 00                	push   $0x0
  801ee3:	ff 75 0c             	pushl  0xc(%ebp)
  801ee6:	ff 75 08             	pushl  0x8(%ebp)
  801ee9:	6a 2c                	push   $0x2c
  801eeb:	e8 f9 f9 ff ff       	call   8018e9 <syscall>
  801ef0:	83 c4 18             	add    $0x18,%esp
	return;
  801ef3:	90                   	nop
}
  801ef4:	c9                   	leave  
  801ef5:	c3                   	ret    

00801ef6 <sys_allocate_user_mem>:

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	syscall(SYS_allocate_user_mem,virtual_address,size,0,0,0);
  801ef9:	6a 00                	push   $0x0
  801efb:	6a 00                	push   $0x0
  801efd:	6a 00                	push   $0x0
  801eff:	ff 75 0c             	pushl  0xc(%ebp)
  801f02:	ff 75 08             	pushl  0x8(%ebp)
  801f05:	6a 2d                	push   $0x2d
  801f07:	e8 dd f9 ff ff       	call   8018e9 <syscall>
  801f0c:	83 c4 18             	add    $0x18,%esp
	return;
  801f0f:	90                   	nop
}
  801f10:	c9                   	leave  
  801f11:	c3                   	ret    

00801f12 <get_block_size>:

//=====================================================
// 1) GET BLOCK SIZE (including size of its meta data):
//=====================================================
__inline__ uint32 get_block_size(void* va)
{
  801f12:	55                   	push   %ebp
  801f13:	89 e5                	mov    %esp,%ebp
  801f15:	83 ec 10             	sub    $0x10,%esp
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
  801f18:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1b:	83 e8 04             	sub    $0x4,%eax
  801f1e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return (*curBlkMetaData) & ~(0x1);
  801f21:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f24:	8b 00                	mov    (%eax),%eax
  801f26:	83 e0 fe             	and    $0xfffffffe,%eax
}
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <is_free_block>:

//===========================
// 2) GET BLOCK STATUS:
//===========================
__inline__ int8 is_free_block(void* va)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	83 ec 10             	sub    $0x10,%esp
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
  801f31:	8b 45 08             	mov    0x8(%ebp),%eax
  801f34:	83 e8 04             	sub    $0x4,%eax
  801f37:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return (~(*curBlkMetaData) & 0x1) ;
  801f3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801f3d:	8b 00                	mov    (%eax),%eax
  801f3f:	83 e0 01             	and    $0x1,%eax
  801f42:	85 c0                	test   %eax,%eax
  801f44:	0f 94 c0             	sete   %al
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    

00801f49 <alloc_block>:
//===========================
// 3) ALLOCATE BLOCK:
//===========================

void *alloc_block(uint32 size, int ALLOC_STRATEGY)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	83 ec 18             	sub    $0x18,%esp
	void *va = NULL;
  801f4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	switch (ALLOC_STRATEGY)
  801f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f59:	83 f8 02             	cmp    $0x2,%eax
  801f5c:	74 2b                	je     801f89 <alloc_block+0x40>
  801f5e:	83 f8 02             	cmp    $0x2,%eax
  801f61:	7f 07                	jg     801f6a <alloc_block+0x21>
  801f63:	83 f8 01             	cmp    $0x1,%eax
  801f66:	74 0e                	je     801f76 <alloc_block+0x2d>
  801f68:	eb 58                	jmp    801fc2 <alloc_block+0x79>
  801f6a:	83 f8 03             	cmp    $0x3,%eax
  801f6d:	74 2d                	je     801f9c <alloc_block+0x53>
  801f6f:	83 f8 04             	cmp    $0x4,%eax
  801f72:	74 3b                	je     801faf <alloc_block+0x66>
  801f74:	eb 4c                	jmp    801fc2 <alloc_block+0x79>
	{
	case DA_FF:
		va = alloc_block_FF(size);
  801f76:	83 ec 0c             	sub    $0xc,%esp
  801f79:	ff 75 08             	pushl  0x8(%ebp)
  801f7c:	e8 11 03 00 00       	call   802292 <alloc_block_FF>
  801f81:	83 c4 10             	add    $0x10,%esp
  801f84:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  801f87:	eb 4a                	jmp    801fd3 <alloc_block+0x8a>
	case DA_NF:
		va = alloc_block_NF(size);
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	ff 75 08             	pushl  0x8(%ebp)
  801f8f:	e8 fa 19 00 00       	call   80398e <alloc_block_NF>
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  801f9a:	eb 37                	jmp    801fd3 <alloc_block+0x8a>
	case DA_BF:
		va = alloc_block_BF(size);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	ff 75 08             	pushl  0x8(%ebp)
  801fa2:	e8 a7 07 00 00       	call   80274e <alloc_block_BF>
  801fa7:	83 c4 10             	add    $0x10,%esp
  801faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  801fad:	eb 24                	jmp    801fd3 <alloc_block+0x8a>
	case DA_WF:
		va = alloc_block_WF(size);
  801faf:	83 ec 0c             	sub    $0xc,%esp
  801fb2:	ff 75 08             	pushl  0x8(%ebp)
  801fb5:	e8 b7 19 00 00       	call   803971 <alloc_block_WF>
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  801fc0:	eb 11                	jmp    801fd3 <alloc_block+0x8a>
	default:
		cprintf("Invalid allocation strategy\n");
  801fc2:	83 ec 0c             	sub    $0xc,%esp
  801fc5:	68 10 47 80 00       	push   $0x804710
  801fca:	e8 a8 e6 ff ff       	call   800677 <cprintf>
  801fcf:	83 c4 10             	add    $0x10,%esp
		break;
  801fd2:	90                   	nop
	}
	return va;
  801fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <print_blocks_list>:
//===========================
// 4) PRINT BLOCKS LIST:
//===========================

void print_blocks_list(struct MemBlock_LIST list)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	53                   	push   %ebx
  801fdc:	83 ec 14             	sub    $0x14,%esp
	cprintf("=========================================\n");
  801fdf:	83 ec 0c             	sub    $0xc,%esp
  801fe2:	68 30 47 80 00       	push   $0x804730
  801fe7:	e8 8b e6 ff ff       	call   800677 <cprintf>
  801fec:	83 c4 10             	add    $0x10,%esp
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
  801fef:	83 ec 0c             	sub    $0xc,%esp
  801ff2:	68 5b 47 80 00       	push   $0x80475b
  801ff7:	e8 7b e6 ff ff       	call   800677 <cprintf>
  801ffc:	83 c4 10             	add    $0x10,%esp
	LIST_FOREACH(blk, &list)
  801fff:	8b 45 08             	mov    0x8(%ebp),%eax
  802002:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802005:	eb 37                	jmp    80203e <print_blocks_list+0x66>
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
  802007:	83 ec 0c             	sub    $0xc,%esp
  80200a:	ff 75 f4             	pushl  -0xc(%ebp)
  80200d:	e8 19 ff ff ff       	call   801f2b <is_free_block>
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	0f be d8             	movsbl %al,%ebx
  802018:	83 ec 0c             	sub    $0xc,%esp
  80201b:	ff 75 f4             	pushl  -0xc(%ebp)
  80201e:	e8 ef fe ff ff       	call   801f12 <get_block_size>
  802023:	83 c4 10             	add    $0x10,%esp
  802026:	83 ec 04             	sub    $0x4,%esp
  802029:	53                   	push   %ebx
  80202a:	50                   	push   %eax
  80202b:	68 73 47 80 00       	push   $0x804773
  802030:	e8 42 e6 ff ff       	call   800677 <cprintf>
  802035:	83 c4 10             	add    $0x10,%esp
void print_blocks_list(struct MemBlock_LIST list)
{
	cprintf("=========================================\n");
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
	LIST_FOREACH(blk, &list)
  802038:	8b 45 10             	mov    0x10(%ebp),%eax
  80203b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80203e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802042:	74 07                	je     80204b <print_blocks_list+0x73>
  802044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802047:	8b 00                	mov    (%eax),%eax
  802049:	eb 05                	jmp    802050 <print_blocks_list+0x78>
  80204b:	b8 00 00 00 00       	mov    $0x0,%eax
  802050:	89 45 10             	mov    %eax,0x10(%ebp)
  802053:	8b 45 10             	mov    0x10(%ebp),%eax
  802056:	85 c0                	test   %eax,%eax
  802058:	75 ad                	jne    802007 <print_blocks_list+0x2f>
  80205a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80205e:	75 a7                	jne    802007 <print_blocks_list+0x2f>
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
	}
	cprintf("=========================================\n");
  802060:	83 ec 0c             	sub    $0xc,%esp
  802063:	68 30 47 80 00       	push   $0x804730
  802068:	e8 0a e6 ff ff       	call   800677 <cprintf>
  80206d:	83 c4 10             	add    $0x10,%esp

}
  802070:	90                   	nop
  802071:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802074:	c9                   	leave  
  802075:	c3                   	ret    

00802076 <initialize_dynamic_allocator>:
// [1] INITIALIZE DYNAMIC ALLOCATOR:
//==================================

// Youssef Mohsen
void initialize_dynamic_allocator(uint32 daStart, uint32 initSizeOfAllocatedSpace)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	83 ec 18             	sub    $0x18,%esp
        //==================================================================================
        //DON'T CHANGE THESE LINES==========================================================
        //==================================================================================
        {
            if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
  80207c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80207f:	83 e0 01             	and    $0x1,%eax
  802082:	85 c0                	test   %eax,%eax
  802084:	74 03                	je     802089 <initialize_dynamic_allocator+0x13>
  802086:	ff 45 0c             	incl   0xc(%ebp)
            if (initSizeOfAllocatedSpace == 0)
  802089:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80208d:	0f 84 c7 01 00 00    	je     80225a <initialize_dynamic_allocator+0x1e4>
                return ;
            is_initialized = 1;
  802093:	c7 05 24 50 80 00 01 	movl   $0x1,0x805024
  80209a:	00 00 00 
        //TODO: [PROJECT'24.MS1 - #04] [3] DYNAMIC ALLOCATOR - initialize_dynamic_allocator
        //COMMENT THE FOLLOWING LINE BEFORE START CODING
        //panic("initialize_dynamic_allocator is not implemented yet");

    // Check for bounds
    if ((daStart + initSizeOfAllocatedSpace) > KERNEL_HEAP_MAX)
  80209d:	8b 55 08             	mov    0x8(%ebp),%edx
  8020a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a3:	01 d0                	add    %edx,%eax
  8020a5:	3d 00 f0 ff ff       	cmp    $0xfffff000,%eax
  8020aa:	0f 87 ad 01 00 00    	ja     80225d <initialize_dynamic_allocator+0x1e7>
        return;
    if(daStart < USER_HEAP_START)
  8020b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	0f 89 a5 01 00 00    	jns    802260 <initialize_dynamic_allocator+0x1ea>
        return;
    end_add = daStart + initSizeOfAllocatedSpace - sizeof(struct Block_Start_End);
  8020bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8020be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c1:	01 d0                	add    %edx,%eax
  8020c3:	83 e8 04             	sub    $0x4,%eax
  8020c6:	a3 44 50 80 00       	mov    %eax,0x805044
     struct BlockElement * element = NULL;
  8020cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     LIST_FOREACH(element, &freeBlocksList)
  8020d2:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8020d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8020da:	e9 87 00 00 00       	jmp    802166 <initialize_dynamic_allocator+0xf0>
     {
        LIST_REMOVE(&freeBlocksList,element);
  8020df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8020e3:	75 14                	jne    8020f9 <initialize_dynamic_allocator+0x83>
  8020e5:	83 ec 04             	sub    $0x4,%esp
  8020e8:	68 8b 47 80 00       	push   $0x80478b
  8020ed:	6a 79                	push   $0x79
  8020ef:	68 a9 47 80 00       	push   $0x8047a9
  8020f4:	e8 c1 e2 ff ff       	call   8003ba <_panic>
  8020f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fc:	8b 00                	mov    (%eax),%eax
  8020fe:	85 c0                	test   %eax,%eax
  802100:	74 10                	je     802112 <initialize_dynamic_allocator+0x9c>
  802102:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802105:	8b 00                	mov    (%eax),%eax
  802107:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80210a:	8b 52 04             	mov    0x4(%edx),%edx
  80210d:	89 50 04             	mov    %edx,0x4(%eax)
  802110:	eb 0b                	jmp    80211d <initialize_dynamic_allocator+0xa7>
  802112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802115:	8b 40 04             	mov    0x4(%eax),%eax
  802118:	a3 30 50 80 00       	mov    %eax,0x805030
  80211d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802120:	8b 40 04             	mov    0x4(%eax),%eax
  802123:	85 c0                	test   %eax,%eax
  802125:	74 0f                	je     802136 <initialize_dynamic_allocator+0xc0>
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	8b 40 04             	mov    0x4(%eax),%eax
  80212d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802130:	8b 12                	mov    (%edx),%edx
  802132:	89 10                	mov    %edx,(%eax)
  802134:	eb 0a                	jmp    802140 <initialize_dynamic_allocator+0xca>
  802136:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802139:	8b 00                	mov    (%eax),%eax
  80213b:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802140:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802143:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802153:	a1 38 50 80 00       	mov    0x805038,%eax
  802158:	48                   	dec    %eax
  802159:	a3 38 50 80 00       	mov    %eax,0x805038
        return;
    if(daStart < USER_HEAP_START)
        return;
    end_add = daStart + initSizeOfAllocatedSpace - sizeof(struct Block_Start_End);
     struct BlockElement * element = NULL;
     LIST_FOREACH(element, &freeBlocksList)
  80215e:	a1 34 50 80 00       	mov    0x805034,%eax
  802163:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802166:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80216a:	74 07                	je     802173 <initialize_dynamic_allocator+0xfd>
  80216c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216f:	8b 00                	mov    (%eax),%eax
  802171:	eb 05                	jmp    802178 <initialize_dynamic_allocator+0x102>
  802173:	b8 00 00 00 00       	mov    $0x0,%eax
  802178:	a3 34 50 80 00       	mov    %eax,0x805034
  80217d:	a1 34 50 80 00       	mov    0x805034,%eax
  802182:	85 c0                	test   %eax,%eax
  802184:	0f 85 55 ff ff ff    	jne    8020df <initialize_dynamic_allocator+0x69>
  80218a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80218e:	0f 85 4b ff ff ff    	jne    8020df <initialize_dynamic_allocator+0x69>
     {
        LIST_REMOVE(&freeBlocksList,element);
     }

    // Create the BEG Block
    struct Block_Start_End* beg_block = (struct Block_Start_End*) daStart;
  802194:	8b 45 08             	mov    0x8(%ebp),%eax
  802197:	89 45 f0             	mov    %eax,-0x10(%ebp)
    beg_block->info = 1;
  80219a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80219d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    // Create the END Block
    end_block = (struct Block_Start_End*) (end_add);
  8021a3:	a1 44 50 80 00       	mov    0x805044,%eax
  8021a8:	a3 40 50 80 00       	mov    %eax,0x805040
    end_block->info = 1;
  8021ad:	a1 40 50 80 00       	mov    0x805040,%eax
  8021b2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    // Create the first free block
    struct BlockElement* first_free_block = (struct BlockElement*)(daStart + 2*sizeof(struct Block_Start_End));
  8021b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bb:	83 c0 08             	add    $0x8,%eax
  8021be:	89 45 ec             	mov    %eax,-0x14(%ebp)


    //Assigning the Heap's Header/Footer values
    *(uint32*)((char*)daStart + 4 /*4 Byte*/) = initSizeOfAllocatedSpace - 2 * sizeof(struct Block_Start_End) /*Heap's header/footer*/;
  8021c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c4:	83 c0 04             	add    $0x4,%eax
  8021c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ca:	83 ea 08             	sub    $0x8,%edx
  8021cd:	89 10                	mov    %edx,(%eax)
    *(uint32*)((char*)daStart + initSizeOfAllocatedSpace - 8) = initSizeOfAllocatedSpace - 2 * sizeof(struct Block_Start_End) /*Heap's header/footer*/;
  8021cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d5:	01 d0                	add    %edx,%eax
  8021d7:	83 e8 08             	sub    $0x8,%eax
  8021da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021dd:	83 ea 08             	sub    $0x8,%edx
  8021e0:	89 10                	mov    %edx,(%eax)

    // Initialize links to the END block
   first_free_block->prev_next_info.le_next = NULL; // Link to the END block
  8021e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
   first_free_block->prev_next_info.le_prev = NULL;
  8021eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8021ee:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

    // Link the first free block into the free block list
    LIST_INSERT_HEAD(&freeBlocksList , first_free_block);
  8021f5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8021f9:	75 17                	jne    802212 <initialize_dynamic_allocator+0x19c>
  8021fb:	83 ec 04             	sub    $0x4,%esp
  8021fe:	68 c4 47 80 00       	push   $0x8047c4
  802203:	68 90 00 00 00       	push   $0x90
  802208:	68 a9 47 80 00       	push   $0x8047a9
  80220d:	e8 a8 e1 ff ff       	call   8003ba <_panic>
  802212:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  802218:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80221b:	89 10                	mov    %edx,(%eax)
  80221d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802220:	8b 00                	mov    (%eax),%eax
  802222:	85 c0                	test   %eax,%eax
  802224:	74 0d                	je     802233 <initialize_dynamic_allocator+0x1bd>
  802226:	a1 2c 50 80 00       	mov    0x80502c,%eax
  80222b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80222e:	89 50 04             	mov    %edx,0x4(%eax)
  802231:	eb 08                	jmp    80223b <initialize_dynamic_allocator+0x1c5>
  802233:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802236:	a3 30 50 80 00       	mov    %eax,0x805030
  80223b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80223e:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802243:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802246:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80224d:	a1 38 50 80 00       	mov    0x805038,%eax
  802252:	40                   	inc    %eax
  802253:	a3 38 50 80 00       	mov    %eax,0x805038
  802258:	eb 07                	jmp    802261 <initialize_dynamic_allocator+0x1eb>
        //DON'T CHANGE THESE LINES==========================================================
        //==================================================================================
        {
            if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
            if (initSizeOfAllocatedSpace == 0)
                return ;
  80225a:	90                   	nop
  80225b:	eb 04                	jmp    802261 <initialize_dynamic_allocator+0x1eb>
        //COMMENT THE FOLLOWING LINE BEFORE START CODING
        //panic("initialize_dynamic_allocator is not implemented yet");

    // Check for bounds
    if ((daStart + initSizeOfAllocatedSpace) > KERNEL_HEAP_MAX)
        return;
  80225d:	90                   	nop
  80225e:	eb 01                	jmp    802261 <initialize_dynamic_allocator+0x1eb>
    if(daStart < USER_HEAP_START)
        return;
  802260:	90                   	nop
   first_free_block->prev_next_info.le_next = NULL; // Link to the END block
   first_free_block->prev_next_info.le_prev = NULL;

    // Link the first free block into the free block list
    LIST_INSERT_HEAD(&freeBlocksList , first_free_block);
}
  802261:	c9                   	leave  
  802262:	c3                   	ret    

00802263 <set_block_data>:

//==================================
// [2] SET BLOCK HEADER & FOOTER:
//==================================
void set_block_data(void* va, uint32 totalSize, bool isAllocated)
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
   //TODO: [PROJECT'24.MS1 - #05] [3] DYNAMIC ALLOCATOR - set_block_data
   //COMMENT THE FOLLOWING LINE BEFORE START CODING
   //panic("set_block_data is not implemented yet");
   //Your Code is Here...

	totalSize = totalSize|isAllocated;
  802266:	8b 45 10             	mov    0x10(%ebp),%eax
  802269:	09 45 0c             	or     %eax,0xc(%ebp)
   *HEADER(va) = totalSize;
  80226c:	8b 45 08             	mov    0x8(%ebp),%eax
  80226f:	8d 50 fc             	lea    -0x4(%eax),%edx
  802272:	8b 45 0c             	mov    0xc(%ebp),%eax
  802275:	89 02                	mov    %eax,(%edx)
   *FOOTER(va) = totalSize;
  802277:	8b 45 08             	mov    0x8(%ebp),%eax
  80227a:	83 e8 04             	sub    $0x4,%eax
  80227d:	8b 00                	mov    (%eax),%eax
  80227f:	83 e0 fe             	and    $0xfffffffe,%eax
  802282:	8d 50 f8             	lea    -0x8(%eax),%edx
  802285:	8b 45 08             	mov    0x8(%ebp),%eax
  802288:	01 c2                	add    %eax,%edx
  80228a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80228d:	89 02                	mov    %eax,(%edx)
}
  80228f:	90                   	nop
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    

00802292 <alloc_block_FF>:
//=========================================
// [3] ALLOCATE BLOCK BY FIRST FIT:
//=========================================

void *alloc_block_FF(uint32 size)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 58             	sub    $0x58,%esp
	//==================================================================================
	//DON'T CHANGE THESE LINES==========================================================
	//==================================================================================
	{
		if (size % 2 != 0) size++;	//ensure that the size is even (to use LSB as allocation flag)
  802298:	8b 45 08             	mov    0x8(%ebp),%eax
  80229b:	83 e0 01             	and    $0x1,%eax
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	74 03                	je     8022a5 <alloc_block_FF+0x13>
  8022a2:	ff 45 08             	incl   0x8(%ebp)
		if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
  8022a5:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
  8022a9:	77 07                	ja     8022b2 <alloc_block_FF+0x20>
			size = DYN_ALLOC_MIN_BLOCK_SIZE ;
  8022ab:	c7 45 08 08 00 00 00 	movl   $0x8,0x8(%ebp)
		if (!is_initialized)
  8022b2:	a1 24 50 80 00       	mov    0x805024,%eax
  8022b7:	85 c0                	test   %eax,%eax
  8022b9:	75 73                	jne    80232e <alloc_block_FF+0x9c>
		{
			uint32 required_size = size + 2*sizeof(int) /*header & footer*/ + 2*sizeof(int) /*da begin & end*/ ;
  8022bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022be:	83 c0 10             	add    $0x10,%eax
  8022c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
			uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE)/PAGE_SIZE);
  8022c4:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
  8022cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8022d1:	01 d0                	add    %edx,%eax
  8022d3:	48                   	dec    %eax
  8022d4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  8022d7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022da:	ba 00 00 00 00       	mov    $0x0,%edx
  8022df:	f7 75 ec             	divl   -0x14(%ebp)
  8022e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8022e5:	29 d0                	sub    %edx,%eax
  8022e7:	c1 e8 0c             	shr    $0xc,%eax
  8022ea:	83 ec 0c             	sub    $0xc,%esp
  8022ed:	50                   	push   %eax
  8022ee:	e8 1e f1 ff ff       	call   801411 <sbrk>
  8022f3:	83 c4 10             	add    $0x10,%esp
  8022f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			uint32 da_break = (uint32)sbrk(0);
  8022f9:	83 ec 0c             	sub    $0xc,%esp
  8022fc:	6a 00                	push   $0x0
  8022fe:	e8 0e f1 ff ff       	call   801411 <sbrk>
  802303:	83 c4 10             	add    $0x10,%esp
  802306:	89 45 e0             	mov    %eax,-0x20(%ebp)
			initialize_dynamic_allocator(da_start, da_break - da_start);
  802309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80230c:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  80230f:	83 ec 08             	sub    $0x8,%esp
  802312:	50                   	push   %eax
  802313:	ff 75 e4             	pushl  -0x1c(%ebp)
  802316:	e8 5b fd ff ff       	call   802076 <initialize_dynamic_allocator>
  80231b:	83 c4 10             	add    $0x10,%esp
			cprintf("Initialized \n");
  80231e:	83 ec 0c             	sub    $0xc,%esp
  802321:	68 e7 47 80 00       	push   $0x8047e7
  802326:	e8 4c e3 ff ff       	call   800677 <cprintf>
  80232b:	83 c4 10             	add    $0x10,%esp
	//TODO: [PROJECT'24.MS1 - #06] [3] DYNAMIC ALLOCATOR - alloc_block_FF
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
//	panic("alloc_block_FF is not implemented yet");
	//Your Code is Here...

	 if (size == 0) {
  80232e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802332:	75 0a                	jne    80233e <alloc_block_FF+0xac>
	        return NULL;
  802334:	b8 00 00 00 00       	mov    $0x0,%eax
  802339:	e9 0e 04 00 00       	jmp    80274c <alloc_block_FF+0x4ba>
	    }
	// cprintf("size is %d \n",size);


	    struct BlockElement *blk = NULL;
  80233e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	    LIST_FOREACH(blk, &freeBlocksList) {
  802345:	a1 2c 50 80 00       	mov    0x80502c,%eax
  80234a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80234d:	e9 f3 02 00 00       	jmp    802645 <alloc_block_FF+0x3b3>
	        void *va = (void *)blk;
  802352:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802355:	89 45 bc             	mov    %eax,-0x44(%ebp)
	        uint32 blk_size = get_block_size(va);
  802358:	83 ec 0c             	sub    $0xc,%esp
  80235b:	ff 75 bc             	pushl  -0x44(%ebp)
  80235e:	e8 af fb ff ff       	call   801f12 <get_block_size>
  802363:	83 c4 10             	add    $0x10,%esp
  802366:	89 45 b8             	mov    %eax,-0x48(%ebp)

	        if(blk_size >= size + 2 * sizeof(uint32)) {
  802369:	8b 45 08             	mov    0x8(%ebp),%eax
  80236c:	83 c0 08             	add    $0x8,%eax
  80236f:	3b 45 b8             	cmp    -0x48(%ebp),%eax
  802372:	0f 87 c5 02 00 00    	ja     80263d <alloc_block_FF+0x3ab>
	            if (blk_size >= size + DYN_ALLOC_MIN_BLOCK_SIZE + 4 * sizeof(uint32))
  802378:	8b 45 08             	mov    0x8(%ebp),%eax
  80237b:	83 c0 18             	add    $0x18,%eax
  80237e:	3b 45 b8             	cmp    -0x48(%ebp),%eax
  802381:	0f 87 19 02 00 00    	ja     8025a0 <alloc_block_FF+0x30e>
	            {

				uint32 remaining_size = blk_size - size - 2 * sizeof(uint32);
  802387:	8b 45 b8             	mov    -0x48(%ebp),%eax
  80238a:	2b 45 08             	sub    0x8(%ebp),%eax
  80238d:	83 e8 08             	sub    $0x8,%eax
  802390:	89 45 b4             	mov    %eax,-0x4c(%ebp)
				void *new_block_va = (void *)((char *)va + size + 2 * sizeof(uint32));
  802393:	8b 45 08             	mov    0x8(%ebp),%eax
  802396:	8d 50 08             	lea    0x8(%eax),%edx
  802399:	8b 45 bc             	mov    -0x44(%ebp),%eax
  80239c:	01 d0                	add    %edx,%eax
  80239e:	89 45 b0             	mov    %eax,-0x50(%ebp)
				set_block_data(va, size + 2 * sizeof(uint32), 1);
  8023a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023a4:	83 c0 08             	add    $0x8,%eax
  8023a7:	83 ec 04             	sub    $0x4,%esp
  8023aa:	6a 01                	push   $0x1
  8023ac:	50                   	push   %eax
  8023ad:	ff 75 bc             	pushl  -0x44(%ebp)
  8023b0:	e8 ae fe ff ff       	call   802263 <set_block_data>
  8023b5:	83 c4 10             	add    $0x10,%esp

				if (LIST_PREV(blk)==NULL)
  8023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023bb:	8b 40 04             	mov    0x4(%eax),%eax
  8023be:	85 c0                	test   %eax,%eax
  8023c0:	75 68                	jne    80242a <alloc_block_FF+0x198>
				{
					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement*)new_block_va);
  8023c2:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  8023c6:	75 17                	jne    8023df <alloc_block_FF+0x14d>
  8023c8:	83 ec 04             	sub    $0x4,%esp
  8023cb:	68 c4 47 80 00       	push   $0x8047c4
  8023d0:	68 d7 00 00 00       	push   $0xd7
  8023d5:	68 a9 47 80 00       	push   $0x8047a9
  8023da:	e8 db df ff ff       	call   8003ba <_panic>
  8023df:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  8023e5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8023e8:	89 10                	mov    %edx,(%eax)
  8023ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8023ed:	8b 00                	mov    (%eax),%eax
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	74 0d                	je     802400 <alloc_block_FF+0x16e>
  8023f3:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8023f8:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8023fb:	89 50 04             	mov    %edx,0x4(%eax)
  8023fe:	eb 08                	jmp    802408 <alloc_block_FF+0x176>
  802400:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802403:	a3 30 50 80 00       	mov    %eax,0x805030
  802408:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80240b:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802410:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802413:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80241a:	a1 38 50 80 00       	mov    0x805038,%eax
  80241f:	40                   	inc    %eax
  802420:	a3 38 50 80 00       	mov    %eax,0x805038
  802425:	e9 dc 00 00 00       	jmp    802506 <alloc_block_FF+0x274>
				}
				else if (LIST_NEXT(blk)==NULL)
  80242a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242d:	8b 00                	mov    (%eax),%eax
  80242f:	85 c0                	test   %eax,%eax
  802431:	75 65                	jne    802498 <alloc_block_FF+0x206>
				{
					LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement*)new_block_va);
  802433:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  802437:	75 17                	jne    802450 <alloc_block_FF+0x1be>
  802439:	83 ec 04             	sub    $0x4,%esp
  80243c:	68 f8 47 80 00       	push   $0x8047f8
  802441:	68 db 00 00 00       	push   $0xdb
  802446:	68 a9 47 80 00       	push   $0x8047a9
  80244b:	e8 6a df ff ff       	call   8003ba <_panic>
  802450:	8b 15 30 50 80 00    	mov    0x805030,%edx
  802456:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802459:	89 50 04             	mov    %edx,0x4(%eax)
  80245c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80245f:	8b 40 04             	mov    0x4(%eax),%eax
  802462:	85 c0                	test   %eax,%eax
  802464:	74 0c                	je     802472 <alloc_block_FF+0x1e0>
  802466:	a1 30 50 80 00       	mov    0x805030,%eax
  80246b:	8b 55 b0             	mov    -0x50(%ebp),%edx
  80246e:	89 10                	mov    %edx,(%eax)
  802470:	eb 08                	jmp    80247a <alloc_block_FF+0x1e8>
  802472:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802475:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80247a:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80247d:	a3 30 50 80 00       	mov    %eax,0x805030
  802482:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  80248b:	a1 38 50 80 00       	mov    0x805038,%eax
  802490:	40                   	inc    %eax
  802491:	a3 38 50 80 00       	mov    %eax,0x805038
  802496:	eb 6e                	jmp    802506 <alloc_block_FF+0x274>
				}
				else
				{
					LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement*)new_block_va);
  802498:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80249c:	74 06                	je     8024a4 <alloc_block_FF+0x212>
  80249e:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  8024a2:	75 17                	jne    8024bb <alloc_block_FF+0x229>
  8024a4:	83 ec 04             	sub    $0x4,%esp
  8024a7:	68 1c 48 80 00       	push   $0x80481c
  8024ac:	68 df 00 00 00       	push   $0xdf
  8024b1:	68 a9 47 80 00       	push   $0x8047a9
  8024b6:	e8 ff de ff ff       	call   8003ba <_panic>
  8024bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024be:	8b 10                	mov    (%eax),%edx
  8024c0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8024c3:	89 10                	mov    %edx,(%eax)
  8024c5:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8024c8:	8b 00                	mov    (%eax),%eax
  8024ca:	85 c0                	test   %eax,%eax
  8024cc:	74 0b                	je     8024d9 <alloc_block_FF+0x247>
  8024ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d1:	8b 00                	mov    (%eax),%eax
  8024d3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8024d6:	89 50 04             	mov    %edx,0x4(%eax)
  8024d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024dc:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8024df:	89 10                	mov    %edx,(%eax)
  8024e1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8024e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8024e7:	89 50 04             	mov    %edx,0x4(%eax)
  8024ea:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8024ed:	8b 00                	mov    (%eax),%eax
  8024ef:	85 c0                	test   %eax,%eax
  8024f1:	75 08                	jne    8024fb <alloc_block_FF+0x269>
  8024f3:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8024f6:	a3 30 50 80 00       	mov    %eax,0x805030
  8024fb:	a1 38 50 80 00       	mov    0x805038,%eax
  802500:	40                   	inc    %eax
  802501:	a3 38 50 80 00       	mov    %eax,0x805038
				}
				LIST_REMOVE(&freeBlocksList, blk);
  802506:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80250a:	75 17                	jne    802523 <alloc_block_FF+0x291>
  80250c:	83 ec 04             	sub    $0x4,%esp
  80250f:	68 8b 47 80 00       	push   $0x80478b
  802514:	68 e1 00 00 00       	push   $0xe1
  802519:	68 a9 47 80 00       	push   $0x8047a9
  80251e:	e8 97 de ff ff       	call   8003ba <_panic>
  802523:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802526:	8b 00                	mov    (%eax),%eax
  802528:	85 c0                	test   %eax,%eax
  80252a:	74 10                	je     80253c <alloc_block_FF+0x2aa>
  80252c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80252f:	8b 00                	mov    (%eax),%eax
  802531:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802534:	8b 52 04             	mov    0x4(%edx),%edx
  802537:	89 50 04             	mov    %edx,0x4(%eax)
  80253a:	eb 0b                	jmp    802547 <alloc_block_FF+0x2b5>
  80253c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253f:	8b 40 04             	mov    0x4(%eax),%eax
  802542:	a3 30 50 80 00       	mov    %eax,0x805030
  802547:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80254a:	8b 40 04             	mov    0x4(%eax),%eax
  80254d:	85 c0                	test   %eax,%eax
  80254f:	74 0f                	je     802560 <alloc_block_FF+0x2ce>
  802551:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802554:	8b 40 04             	mov    0x4(%eax),%eax
  802557:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80255a:	8b 12                	mov    (%edx),%edx
  80255c:	89 10                	mov    %edx,(%eax)
  80255e:	eb 0a                	jmp    80256a <alloc_block_FF+0x2d8>
  802560:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802563:	8b 00                	mov    (%eax),%eax
  802565:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80256a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80256d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802573:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802576:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80257d:	a1 38 50 80 00       	mov    0x805038,%eax
  802582:	48                   	dec    %eax
  802583:	a3 38 50 80 00       	mov    %eax,0x805038
				set_block_data(new_block_va, remaining_size, 0);
  802588:	83 ec 04             	sub    $0x4,%esp
  80258b:	6a 00                	push   $0x0
  80258d:	ff 75 b4             	pushl  -0x4c(%ebp)
  802590:	ff 75 b0             	pushl  -0x50(%ebp)
  802593:	e8 cb fc ff ff       	call   802263 <set_block_data>
  802598:	83 c4 10             	add    $0x10,%esp
  80259b:	e9 95 00 00 00       	jmp    802635 <alloc_block_FF+0x3a3>
	            }
	            else
	            {

	            	set_block_data(va, blk_size, 1);
  8025a0:	83 ec 04             	sub    $0x4,%esp
  8025a3:	6a 01                	push   $0x1
  8025a5:	ff 75 b8             	pushl  -0x48(%ebp)
  8025a8:	ff 75 bc             	pushl  -0x44(%ebp)
  8025ab:	e8 b3 fc ff ff       	call   802263 <set_block_data>
  8025b0:	83 c4 10             	add    $0x10,%esp
	            	LIST_REMOVE(&freeBlocksList,blk);
  8025b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8025b7:	75 17                	jne    8025d0 <alloc_block_FF+0x33e>
  8025b9:	83 ec 04             	sub    $0x4,%esp
  8025bc:	68 8b 47 80 00       	push   $0x80478b
  8025c1:	68 e8 00 00 00       	push   $0xe8
  8025c6:	68 a9 47 80 00       	push   $0x8047a9
  8025cb:	e8 ea dd ff ff       	call   8003ba <_panic>
  8025d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d3:	8b 00                	mov    (%eax),%eax
  8025d5:	85 c0                	test   %eax,%eax
  8025d7:	74 10                	je     8025e9 <alloc_block_FF+0x357>
  8025d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025dc:	8b 00                	mov    (%eax),%eax
  8025de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025e1:	8b 52 04             	mov    0x4(%edx),%edx
  8025e4:	89 50 04             	mov    %edx,0x4(%eax)
  8025e7:	eb 0b                	jmp    8025f4 <alloc_block_FF+0x362>
  8025e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ec:	8b 40 04             	mov    0x4(%eax),%eax
  8025ef:	a3 30 50 80 00       	mov    %eax,0x805030
  8025f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f7:	8b 40 04             	mov    0x4(%eax),%eax
  8025fa:	85 c0                	test   %eax,%eax
  8025fc:	74 0f                	je     80260d <alloc_block_FF+0x37b>
  8025fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802601:	8b 40 04             	mov    0x4(%eax),%eax
  802604:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802607:	8b 12                	mov    (%edx),%edx
  802609:	89 10                	mov    %edx,(%eax)
  80260b:	eb 0a                	jmp    802617 <alloc_block_FF+0x385>
  80260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802610:	8b 00                	mov    (%eax),%eax
  802612:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802617:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80261a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802620:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802623:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80262a:	a1 38 50 80 00       	mov    0x805038,%eax
  80262f:	48                   	dec    %eax
  802630:	a3 38 50 80 00       	mov    %eax,0x805038
	            }
	            return va;
  802635:	8b 45 bc             	mov    -0x44(%ebp),%eax
  802638:	e9 0f 01 00 00       	jmp    80274c <alloc_block_FF+0x4ba>
	    }
	// cprintf("size is %d \n",size);


	    struct BlockElement *blk = NULL;
	    LIST_FOREACH(blk, &freeBlocksList) {
  80263d:	a1 34 50 80 00       	mov    0x805034,%eax
  802642:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802645:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802649:	74 07                	je     802652 <alloc_block_FF+0x3c0>
  80264b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80264e:	8b 00                	mov    (%eax),%eax
  802650:	eb 05                	jmp    802657 <alloc_block_FF+0x3c5>
  802652:	b8 00 00 00 00       	mov    $0x0,%eax
  802657:	a3 34 50 80 00       	mov    %eax,0x805034
  80265c:	a1 34 50 80 00       	mov    0x805034,%eax
  802661:	85 c0                	test   %eax,%eax
  802663:	0f 85 e9 fc ff ff    	jne    802352 <alloc_block_FF+0xc0>
  802669:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80266d:	0f 85 df fc ff ff    	jne    802352 <alloc_block_FF+0xc0>
	            	LIST_REMOVE(&freeBlocksList,blk);
	            }
	            return va;
	        }
	    }
	    uint32 required_size = size + 2 * sizeof(uint32);
  802673:	8b 45 08             	mov    0x8(%ebp),%eax
  802676:	83 c0 08             	add    $0x8,%eax
  802679:	89 45 dc             	mov    %eax,-0x24(%ebp)
	    void *new_mem = sbrk(ROUNDUP(required_size, PAGE_SIZE) / PAGE_SIZE);
  80267c:	c7 45 d8 00 10 00 00 	movl   $0x1000,-0x28(%ebp)
  802683:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802686:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802689:	01 d0                	add    %edx,%eax
  80268b:	48                   	dec    %eax
  80268c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80268f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802692:	ba 00 00 00 00       	mov    $0x0,%edx
  802697:	f7 75 d8             	divl   -0x28(%ebp)
  80269a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80269d:	29 d0                	sub    %edx,%eax
  80269f:	c1 e8 0c             	shr    $0xc,%eax
  8026a2:	83 ec 0c             	sub    $0xc,%esp
  8026a5:	50                   	push   %eax
  8026a6:	e8 66 ed ff ff       	call   801411 <sbrk>
  8026ab:	83 c4 10             	add    $0x10,%esp
  8026ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		if (new_mem == (void *)-1) {
  8026b1:	83 7d d0 ff          	cmpl   $0xffffffff,-0x30(%ebp)
  8026b5:	75 0a                	jne    8026c1 <alloc_block_FF+0x42f>
			return NULL; // Allocation failed
  8026b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8026bc:	e9 8b 00 00 00       	jmp    80274c <alloc_block_FF+0x4ba>
		}
		else {
			end_block = (struct Block_Start_End*) (new_mem + ROUNDUP(required_size, PAGE_SIZE)-sizeof(int));
  8026c1:	c7 45 cc 00 10 00 00 	movl   $0x1000,-0x34(%ebp)
  8026c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8026cb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8026ce:	01 d0                	add    %edx,%eax
  8026d0:	48                   	dec    %eax
  8026d1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8026d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8026d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8026dc:	f7 75 cc             	divl   -0x34(%ebp)
  8026df:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8026e2:	29 d0                	sub    %edx,%eax
  8026e4:	8d 50 fc             	lea    -0x4(%eax),%edx
  8026e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8026ea:	01 d0                	add    %edx,%eax
  8026ec:	a3 40 50 80 00       	mov    %eax,0x805040
			end_block->info = 1;
  8026f1:	a1 40 50 80 00       	mov    0x805040,%eax
  8026f6:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		set_block_data(new_mem, ROUNDUP(required_size, PAGE_SIZE), 1);
  8026fc:	c7 45 c4 00 10 00 00 	movl   $0x1000,-0x3c(%ebp)
  802703:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802706:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  802709:	01 d0                	add    %edx,%eax
  80270b:	48                   	dec    %eax
  80270c:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80270f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802712:	ba 00 00 00 00       	mov    $0x0,%edx
  802717:	f7 75 c4             	divl   -0x3c(%ebp)
  80271a:	8b 45 c0             	mov    -0x40(%ebp),%eax
  80271d:	29 d0                	sub    %edx,%eax
  80271f:	83 ec 04             	sub    $0x4,%esp
  802722:	6a 01                	push   $0x1
  802724:	50                   	push   %eax
  802725:	ff 75 d0             	pushl  -0x30(%ebp)
  802728:	e8 36 fb ff ff       	call   802263 <set_block_data>
  80272d:	83 c4 10             	add    $0x10,%esp
		free_block(new_mem);
  802730:	83 ec 0c             	sub    $0xc,%esp
  802733:	ff 75 d0             	pushl  -0x30(%ebp)
  802736:	e8 1b 0a 00 00       	call   803156 <free_block>
  80273b:	83 c4 10             	add    $0x10,%esp
		return alloc_block_FF(size);
  80273e:	83 ec 0c             	sub    $0xc,%esp
  802741:	ff 75 08             	pushl  0x8(%ebp)
  802744:	e8 49 fb ff ff       	call   802292 <alloc_block_FF>
  802749:	83 c4 10             	add    $0x10,%esp
		}
		return new_mem;
}
  80274c:	c9                   	leave  
  80274d:	c3                   	ret    

0080274e <alloc_block_BF>:
//=========================================
// [4] ALLOCATE BLOCK BY BEST FIT:
//=========================================
void *alloc_block_BF(uint32 size)
{
  80274e:	55                   	push   %ebp
  80274f:	89 e5                	mov    %esp,%ebp
  802751:	83 ec 68             	sub    $0x68,%esp
	//Your Code is Here...
	//==================================================================================
	//DON'T CHANGE THESE LINES==========================================================
	//==================================================================================
	{
		if (size % 2 != 0) size++;	//ensure that the size is even (to use LSB as allocation flag)
  802754:	8b 45 08             	mov    0x8(%ebp),%eax
  802757:	83 e0 01             	and    $0x1,%eax
  80275a:	85 c0                	test   %eax,%eax
  80275c:	74 03                	je     802761 <alloc_block_BF+0x13>
  80275e:	ff 45 08             	incl   0x8(%ebp)
		if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
  802761:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
  802765:	77 07                	ja     80276e <alloc_block_BF+0x20>
			size = DYN_ALLOC_MIN_BLOCK_SIZE ;
  802767:	c7 45 08 08 00 00 00 	movl   $0x8,0x8(%ebp)
		if (!is_initialized)
  80276e:	a1 24 50 80 00       	mov    0x805024,%eax
  802773:	85 c0                	test   %eax,%eax
  802775:	75 73                	jne    8027ea <alloc_block_BF+0x9c>
		{
			uint32 required_size = size + 2*sizeof(int) /*header & footer*/ + 2*sizeof(int) /*da begin & end*/ ;
  802777:	8b 45 08             	mov    0x8(%ebp),%eax
  80277a:	83 c0 10             	add    $0x10,%eax
  80277d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE)/PAGE_SIZE);
  802780:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
  802787:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80278a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80278d:	01 d0                	add    %edx,%eax
  80278f:	48                   	dec    %eax
  802790:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802793:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802796:	ba 00 00 00 00       	mov    $0x0,%edx
  80279b:	f7 75 e0             	divl   -0x20(%ebp)
  80279e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8027a1:	29 d0                	sub    %edx,%eax
  8027a3:	c1 e8 0c             	shr    $0xc,%eax
  8027a6:	83 ec 0c             	sub    $0xc,%esp
  8027a9:	50                   	push   %eax
  8027aa:	e8 62 ec ff ff       	call   801411 <sbrk>
  8027af:	83 c4 10             	add    $0x10,%esp
  8027b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
			uint32 da_break = (uint32)sbrk(0);
  8027b5:	83 ec 0c             	sub    $0xc,%esp
  8027b8:	6a 00                	push   $0x0
  8027ba:	e8 52 ec ff ff       	call   801411 <sbrk>
  8027bf:	83 c4 10             	add    $0x10,%esp
  8027c2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			initialize_dynamic_allocator(da_start, da_break - da_start);
  8027c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8027c8:	2b 45 d8             	sub    -0x28(%ebp),%eax
  8027cb:	83 ec 08             	sub    $0x8,%esp
  8027ce:	50                   	push   %eax
  8027cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8027d2:	e8 9f f8 ff ff       	call   802076 <initialize_dynamic_allocator>
  8027d7:	83 c4 10             	add    $0x10,%esp
			cprintf("Initialized \n");
  8027da:	83 ec 0c             	sub    $0xc,%esp
  8027dd:	68 e7 47 80 00       	push   $0x8047e7
  8027e2:	e8 90 de ff ff       	call   800677 <cprintf>
  8027e7:	83 c4 10             	add    $0x10,%esp
		}
	}
	//==================================================================================
	//==================================================================================

	struct BlockElement *blk = NULL;
  8027ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	void *best_va=NULL;
  8027f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	uint32 best_blk_size = (uint32)KERNEL_HEAP_MAX - 2 * sizeof(uint32);
  8027f8:	c7 45 ec f8 ef ff ff 	movl   $0xffffeff8,-0x14(%ebp)
	bool internal = 0;
  8027ff:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	LIST_FOREACH(blk, &freeBlocksList) {
  802806:	a1 2c 50 80 00       	mov    0x80502c,%eax
  80280b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80280e:	e9 1d 01 00 00       	jmp    802930 <alloc_block_BF+0x1e2>
		void *va = (void *)blk;
  802813:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802816:	89 45 a8             	mov    %eax,-0x58(%ebp)
		uint32 blk_size = get_block_size(va);
  802819:	83 ec 0c             	sub    $0xc,%esp
  80281c:	ff 75 a8             	pushl  -0x58(%ebp)
  80281f:	e8 ee f6 ff ff       	call   801f12 <get_block_size>
  802824:	83 c4 10             	add    $0x10,%esp
  802827:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		if (blk_size>=size + 2 * sizeof(uint32))
  80282a:	8b 45 08             	mov    0x8(%ebp),%eax
  80282d:	83 c0 08             	add    $0x8,%eax
  802830:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802833:	0f 87 ef 00 00 00    	ja     802928 <alloc_block_BF+0x1da>
		{
			if (blk_size >= size + DYN_ALLOC_MIN_BLOCK_SIZE + 4 * sizeof(uint32))
  802839:	8b 45 08             	mov    0x8(%ebp),%eax
  80283c:	83 c0 18             	add    $0x18,%eax
  80283f:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802842:	77 1d                	ja     802861 <alloc_block_BF+0x113>
			{
				if (best_blk_size > blk_size)
  802844:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802847:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  80284a:	0f 86 d8 00 00 00    	jbe    802928 <alloc_block_BF+0x1da>
				{
					best_va = va;
  802850:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802853:	89 45 f0             	mov    %eax,-0x10(%ebp)
					best_blk_size = blk_size;
  802856:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  802859:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80285c:	e9 c7 00 00 00       	jmp    802928 <alloc_block_BF+0x1da>
				}
			}
			else
			{
				if (blk_size == size + 2 * sizeof(uint32)){
  802861:	8b 45 08             	mov    0x8(%ebp),%eax
  802864:	83 c0 08             	add    $0x8,%eax
  802867:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  80286a:	0f 85 9d 00 00 00    	jne    80290d <alloc_block_BF+0x1bf>
					set_block_data(va, blk_size, 1);
  802870:	83 ec 04             	sub    $0x4,%esp
  802873:	6a 01                	push   $0x1
  802875:	ff 75 a4             	pushl  -0x5c(%ebp)
  802878:	ff 75 a8             	pushl  -0x58(%ebp)
  80287b:	e8 e3 f9 ff ff       	call   802263 <set_block_data>
  802880:	83 c4 10             	add    $0x10,%esp
					LIST_REMOVE(&freeBlocksList,blk);
  802883:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802887:	75 17                	jne    8028a0 <alloc_block_BF+0x152>
  802889:	83 ec 04             	sub    $0x4,%esp
  80288c:	68 8b 47 80 00       	push   $0x80478b
  802891:	68 2c 01 00 00       	push   $0x12c
  802896:	68 a9 47 80 00       	push   $0x8047a9
  80289b:	e8 1a db ff ff       	call   8003ba <_panic>
  8028a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a3:	8b 00                	mov    (%eax),%eax
  8028a5:	85 c0                	test   %eax,%eax
  8028a7:	74 10                	je     8028b9 <alloc_block_BF+0x16b>
  8028a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ac:	8b 00                	mov    (%eax),%eax
  8028ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028b1:	8b 52 04             	mov    0x4(%edx),%edx
  8028b4:	89 50 04             	mov    %edx,0x4(%eax)
  8028b7:	eb 0b                	jmp    8028c4 <alloc_block_BF+0x176>
  8028b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028bc:	8b 40 04             	mov    0x4(%eax),%eax
  8028bf:	a3 30 50 80 00       	mov    %eax,0x805030
  8028c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028c7:	8b 40 04             	mov    0x4(%eax),%eax
  8028ca:	85 c0                	test   %eax,%eax
  8028cc:	74 0f                	je     8028dd <alloc_block_BF+0x18f>
  8028ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028d1:	8b 40 04             	mov    0x4(%eax),%eax
  8028d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028d7:	8b 12                	mov    (%edx),%edx
  8028d9:	89 10                	mov    %edx,(%eax)
  8028db:	eb 0a                	jmp    8028e7 <alloc_block_BF+0x199>
  8028dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028e0:	8b 00                	mov    (%eax),%eax
  8028e2:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8028e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8028f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028f3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8028fa:	a1 38 50 80 00       	mov    0x805038,%eax
  8028ff:	48                   	dec    %eax
  802900:	a3 38 50 80 00       	mov    %eax,0x805038
					return va;
  802905:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802908:	e9 24 04 00 00       	jmp    802d31 <alloc_block_BF+0x5e3>
				}
				else
				{
					if (best_blk_size > blk_size)
  80290d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802910:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802913:	76 13                	jbe    802928 <alloc_block_BF+0x1da>
					{
						internal = 1;
  802915:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
						best_va = va;
  80291c:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80291f:	89 45 f0             	mov    %eax,-0x10(%ebp)
						best_blk_size = blk_size;
  802922:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  802925:	89 45 ec             	mov    %eax,-0x14(%ebp)

	struct BlockElement *blk = NULL;
	void *best_va=NULL;
	uint32 best_blk_size = (uint32)KERNEL_HEAP_MAX - 2 * sizeof(uint32);
	bool internal = 0;
	LIST_FOREACH(blk, &freeBlocksList) {
  802928:	a1 34 50 80 00       	mov    0x805034,%eax
  80292d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802930:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802934:	74 07                	je     80293d <alloc_block_BF+0x1ef>
  802936:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802939:	8b 00                	mov    (%eax),%eax
  80293b:	eb 05                	jmp    802942 <alloc_block_BF+0x1f4>
  80293d:	b8 00 00 00 00       	mov    $0x0,%eax
  802942:	a3 34 50 80 00       	mov    %eax,0x805034
  802947:	a1 34 50 80 00       	mov    0x805034,%eax
  80294c:	85 c0                	test   %eax,%eax
  80294e:	0f 85 bf fe ff ff    	jne    802813 <alloc_block_BF+0xc5>
  802954:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802958:	0f 85 b5 fe ff ff    	jne    802813 <alloc_block_BF+0xc5>
			}
		}

	}

	if (best_va !=NULL && internal ==0){
  80295e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802962:	0f 84 26 02 00 00    	je     802b8e <alloc_block_BF+0x440>
  802968:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  80296c:	0f 85 1c 02 00 00    	jne    802b8e <alloc_block_BF+0x440>
		uint32 remaining_size = best_blk_size - size - 2 * sizeof(uint32);
  802972:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802975:	2b 45 08             	sub    0x8(%ebp),%eax
  802978:	83 e8 08             	sub    $0x8,%eax
  80297b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		void *new_block_va = (void *)((char *)best_va + size + 2 * sizeof(uint32));
  80297e:	8b 45 08             	mov    0x8(%ebp),%eax
  802981:	8d 50 08             	lea    0x8(%eax),%edx
  802984:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802987:	01 d0                	add    %edx,%eax
  802989:	89 45 cc             	mov    %eax,-0x34(%ebp)
		set_block_data(best_va, size + 2 * sizeof(uint32), 1);
  80298c:	8b 45 08             	mov    0x8(%ebp),%eax
  80298f:	83 c0 08             	add    $0x8,%eax
  802992:	83 ec 04             	sub    $0x4,%esp
  802995:	6a 01                	push   $0x1
  802997:	50                   	push   %eax
  802998:	ff 75 f0             	pushl  -0x10(%ebp)
  80299b:	e8 c3 f8 ff ff       	call   802263 <set_block_data>
  8029a0:	83 c4 10             	add    $0x10,%esp

		if (LIST_PREV((struct BlockElement *)best_va)==NULL)
  8029a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8029a6:	8b 40 04             	mov    0x4(%eax),%eax
  8029a9:	85 c0                	test   %eax,%eax
  8029ab:	75 68                	jne    802a15 <alloc_block_BF+0x2c7>
			{

				LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement*)new_block_va);
  8029ad:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8029b1:	75 17                	jne    8029ca <alloc_block_BF+0x27c>
  8029b3:	83 ec 04             	sub    $0x4,%esp
  8029b6:	68 c4 47 80 00       	push   $0x8047c4
  8029bb:	68 45 01 00 00       	push   $0x145
  8029c0:	68 a9 47 80 00       	push   $0x8047a9
  8029c5:	e8 f0 d9 ff ff       	call   8003ba <_panic>
  8029ca:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  8029d0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8029d3:	89 10                	mov    %edx,(%eax)
  8029d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8029d8:	8b 00                	mov    (%eax),%eax
  8029da:	85 c0                	test   %eax,%eax
  8029dc:	74 0d                	je     8029eb <alloc_block_BF+0x29d>
  8029de:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8029e3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8029e6:	89 50 04             	mov    %edx,0x4(%eax)
  8029e9:	eb 08                	jmp    8029f3 <alloc_block_BF+0x2a5>
  8029eb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8029ee:	a3 30 50 80 00       	mov    %eax,0x805030
  8029f3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8029f6:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8029fb:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8029fe:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802a05:	a1 38 50 80 00       	mov    0x805038,%eax
  802a0a:	40                   	inc    %eax
  802a0b:	a3 38 50 80 00       	mov    %eax,0x805038
  802a10:	e9 dc 00 00 00       	jmp    802af1 <alloc_block_BF+0x3a3>
			}
			else if (LIST_NEXT((struct BlockElement *)best_va)==NULL)
  802a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a18:	8b 00                	mov    (%eax),%eax
  802a1a:	85 c0                	test   %eax,%eax
  802a1c:	75 65                	jne    802a83 <alloc_block_BF+0x335>
			{

				LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement*)new_block_va);
  802a1e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  802a22:	75 17                	jne    802a3b <alloc_block_BF+0x2ed>
  802a24:	83 ec 04             	sub    $0x4,%esp
  802a27:	68 f8 47 80 00       	push   $0x8047f8
  802a2c:	68 4a 01 00 00       	push   $0x14a
  802a31:	68 a9 47 80 00       	push   $0x8047a9
  802a36:	e8 7f d9 ff ff       	call   8003ba <_panic>
  802a3b:	8b 15 30 50 80 00    	mov    0x805030,%edx
  802a41:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802a44:	89 50 04             	mov    %edx,0x4(%eax)
  802a47:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802a4a:	8b 40 04             	mov    0x4(%eax),%eax
  802a4d:	85 c0                	test   %eax,%eax
  802a4f:	74 0c                	je     802a5d <alloc_block_BF+0x30f>
  802a51:	a1 30 50 80 00       	mov    0x805030,%eax
  802a56:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802a59:	89 10                	mov    %edx,(%eax)
  802a5b:	eb 08                	jmp    802a65 <alloc_block_BF+0x317>
  802a5d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802a60:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802a65:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802a68:	a3 30 50 80 00       	mov    %eax,0x805030
  802a6d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802a70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802a76:	a1 38 50 80 00       	mov    0x805038,%eax
  802a7b:	40                   	inc    %eax
  802a7c:	a3 38 50 80 00       	mov    %eax,0x805038
  802a81:	eb 6e                	jmp    802af1 <alloc_block_BF+0x3a3>
			}
			else
			{

				LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement *)best_va, (struct BlockElement*)new_block_va);
  802a83:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802a87:	74 06                	je     802a8f <alloc_block_BF+0x341>
  802a89:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  802a8d:	75 17                	jne    802aa6 <alloc_block_BF+0x358>
  802a8f:	83 ec 04             	sub    $0x4,%esp
  802a92:	68 1c 48 80 00       	push   $0x80481c
  802a97:	68 4f 01 00 00       	push   $0x14f
  802a9c:	68 a9 47 80 00       	push   $0x8047a9
  802aa1:	e8 14 d9 ff ff       	call   8003ba <_panic>
  802aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802aa9:	8b 10                	mov    (%eax),%edx
  802aab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802aae:	89 10                	mov    %edx,(%eax)
  802ab0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802ab3:	8b 00                	mov    (%eax),%eax
  802ab5:	85 c0                	test   %eax,%eax
  802ab7:	74 0b                	je     802ac4 <alloc_block_BF+0x376>
  802ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802abc:	8b 00                	mov    (%eax),%eax
  802abe:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802ac1:	89 50 04             	mov    %edx,0x4(%eax)
  802ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ac7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802aca:	89 10                	mov    %edx,(%eax)
  802acc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802acf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802ad2:	89 50 04             	mov    %edx,0x4(%eax)
  802ad5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802ad8:	8b 00                	mov    (%eax),%eax
  802ada:	85 c0                	test   %eax,%eax
  802adc:	75 08                	jne    802ae6 <alloc_block_BF+0x398>
  802ade:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802ae1:	a3 30 50 80 00       	mov    %eax,0x805030
  802ae6:	a1 38 50 80 00       	mov    0x805038,%eax
  802aeb:	40                   	inc    %eax
  802aec:	a3 38 50 80 00       	mov    %eax,0x805038
			}
			LIST_REMOVE(&freeBlocksList, (struct BlockElement *)best_va);
  802af1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802af5:	75 17                	jne    802b0e <alloc_block_BF+0x3c0>
  802af7:	83 ec 04             	sub    $0x4,%esp
  802afa:	68 8b 47 80 00       	push   $0x80478b
  802aff:	68 51 01 00 00       	push   $0x151
  802b04:	68 a9 47 80 00       	push   $0x8047a9
  802b09:	e8 ac d8 ff ff       	call   8003ba <_panic>
  802b0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b11:	8b 00                	mov    (%eax),%eax
  802b13:	85 c0                	test   %eax,%eax
  802b15:	74 10                	je     802b27 <alloc_block_BF+0x3d9>
  802b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b1a:	8b 00                	mov    (%eax),%eax
  802b1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b1f:	8b 52 04             	mov    0x4(%edx),%edx
  802b22:	89 50 04             	mov    %edx,0x4(%eax)
  802b25:	eb 0b                	jmp    802b32 <alloc_block_BF+0x3e4>
  802b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b2a:	8b 40 04             	mov    0x4(%eax),%eax
  802b2d:	a3 30 50 80 00       	mov    %eax,0x805030
  802b32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b35:	8b 40 04             	mov    0x4(%eax),%eax
  802b38:	85 c0                	test   %eax,%eax
  802b3a:	74 0f                	je     802b4b <alloc_block_BF+0x3fd>
  802b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b3f:	8b 40 04             	mov    0x4(%eax),%eax
  802b42:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b45:	8b 12                	mov    (%edx),%edx
  802b47:	89 10                	mov    %edx,(%eax)
  802b49:	eb 0a                	jmp    802b55 <alloc_block_BF+0x407>
  802b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b4e:	8b 00                	mov    (%eax),%eax
  802b50:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802b55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b61:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802b68:	a1 38 50 80 00       	mov    0x805038,%eax
  802b6d:	48                   	dec    %eax
  802b6e:	a3 38 50 80 00       	mov    %eax,0x805038
			set_block_data(new_block_va, remaining_size, 0);
  802b73:	83 ec 04             	sub    $0x4,%esp
  802b76:	6a 00                	push   $0x0
  802b78:	ff 75 d0             	pushl  -0x30(%ebp)
  802b7b:	ff 75 cc             	pushl  -0x34(%ebp)
  802b7e:	e8 e0 f6 ff ff       	call   802263 <set_block_data>
  802b83:	83 c4 10             	add    $0x10,%esp
			return best_va;
  802b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b89:	e9 a3 01 00 00       	jmp    802d31 <alloc_block_BF+0x5e3>
	}
	else if(internal == 1)
  802b8e:	83 7d e8 01          	cmpl   $0x1,-0x18(%ebp)
  802b92:	0f 85 9d 00 00 00    	jne    802c35 <alloc_block_BF+0x4e7>
	{
		set_block_data(best_va, best_blk_size, 1);
  802b98:	83 ec 04             	sub    $0x4,%esp
  802b9b:	6a 01                	push   $0x1
  802b9d:	ff 75 ec             	pushl  -0x14(%ebp)
  802ba0:	ff 75 f0             	pushl  -0x10(%ebp)
  802ba3:	e8 bb f6 ff ff       	call   802263 <set_block_data>
  802ba8:	83 c4 10             	add    $0x10,%esp
		LIST_REMOVE(&freeBlocksList,(struct BlockElement *)best_va);
  802bab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802baf:	75 17                	jne    802bc8 <alloc_block_BF+0x47a>
  802bb1:	83 ec 04             	sub    $0x4,%esp
  802bb4:	68 8b 47 80 00       	push   $0x80478b
  802bb9:	68 58 01 00 00       	push   $0x158
  802bbe:	68 a9 47 80 00       	push   $0x8047a9
  802bc3:	e8 f2 d7 ff ff       	call   8003ba <_panic>
  802bc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bcb:	8b 00                	mov    (%eax),%eax
  802bcd:	85 c0                	test   %eax,%eax
  802bcf:	74 10                	je     802be1 <alloc_block_BF+0x493>
  802bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bd4:	8b 00                	mov    (%eax),%eax
  802bd6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802bd9:	8b 52 04             	mov    0x4(%edx),%edx
  802bdc:	89 50 04             	mov    %edx,0x4(%eax)
  802bdf:	eb 0b                	jmp    802bec <alloc_block_BF+0x49e>
  802be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802be4:	8b 40 04             	mov    0x4(%eax),%eax
  802be7:	a3 30 50 80 00       	mov    %eax,0x805030
  802bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bef:	8b 40 04             	mov    0x4(%eax),%eax
  802bf2:	85 c0                	test   %eax,%eax
  802bf4:	74 0f                	je     802c05 <alloc_block_BF+0x4b7>
  802bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bf9:	8b 40 04             	mov    0x4(%eax),%eax
  802bfc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802bff:	8b 12                	mov    (%edx),%edx
  802c01:	89 10                	mov    %edx,(%eax)
  802c03:	eb 0a                	jmp    802c0f <alloc_block_BF+0x4c1>
  802c05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c08:	8b 00                	mov    (%eax),%eax
  802c0a:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802c0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c12:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c1b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802c22:	a1 38 50 80 00       	mov    0x805038,%eax
  802c27:	48                   	dec    %eax
  802c28:	a3 38 50 80 00       	mov    %eax,0x805038
		return best_va;
  802c2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c30:	e9 fc 00 00 00       	jmp    802d31 <alloc_block_BF+0x5e3>
	}
	uint32 required_size = size + 2 * sizeof(uint32);
  802c35:	8b 45 08             	mov    0x8(%ebp),%eax
  802c38:	83 c0 08             	add    $0x8,%eax
  802c3b:	89 45 c8             	mov    %eax,-0x38(%ebp)
		    void *new_mem = sbrk(ROUNDUP(required_size, PAGE_SIZE) / PAGE_SIZE);
  802c3e:	c7 45 c4 00 10 00 00 	movl   $0x1000,-0x3c(%ebp)
  802c45:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802c48:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  802c4b:	01 d0                	add    %edx,%eax
  802c4d:	48                   	dec    %eax
  802c4e:	89 45 c0             	mov    %eax,-0x40(%ebp)
  802c51:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802c54:	ba 00 00 00 00       	mov    $0x0,%edx
  802c59:	f7 75 c4             	divl   -0x3c(%ebp)
  802c5c:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802c5f:	29 d0                	sub    %edx,%eax
  802c61:	c1 e8 0c             	shr    $0xc,%eax
  802c64:	83 ec 0c             	sub    $0xc,%esp
  802c67:	50                   	push   %eax
  802c68:	e8 a4 e7 ff ff       	call   801411 <sbrk>
  802c6d:	83 c4 10             	add    $0x10,%esp
  802c70:	89 45 bc             	mov    %eax,-0x44(%ebp)
			if (new_mem == (void *)-1) {
  802c73:	83 7d bc ff          	cmpl   $0xffffffff,-0x44(%ebp)
  802c77:	75 0a                	jne    802c83 <alloc_block_BF+0x535>
				return NULL; // Allocation failed
  802c79:	b8 00 00 00 00       	mov    $0x0,%eax
  802c7e:	e9 ae 00 00 00       	jmp    802d31 <alloc_block_BF+0x5e3>
			}
			else {
				end_block = (struct Block_Start_End*) (new_mem + ROUNDUP(required_size, PAGE_SIZE)-sizeof(int));
  802c83:	c7 45 b8 00 10 00 00 	movl   $0x1000,-0x48(%ebp)
  802c8a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802c8d:	8b 45 b8             	mov    -0x48(%ebp),%eax
  802c90:	01 d0                	add    %edx,%eax
  802c92:	48                   	dec    %eax
  802c93:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  802c96:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  802c99:	ba 00 00 00 00       	mov    $0x0,%edx
  802c9e:	f7 75 b8             	divl   -0x48(%ebp)
  802ca1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  802ca4:	29 d0                	sub    %edx,%eax
  802ca6:	8d 50 fc             	lea    -0x4(%eax),%edx
  802ca9:	8b 45 bc             	mov    -0x44(%ebp),%eax
  802cac:	01 d0                	add    %edx,%eax
  802cae:	a3 40 50 80 00       	mov    %eax,0x805040
				end_block->info = 1;
  802cb3:	a1 40 50 80 00       	mov    0x805040,%eax
  802cb8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
				cprintf("251\n");
  802cbe:	83 ec 0c             	sub    $0xc,%esp
  802cc1:	68 50 48 80 00       	push   $0x804850
  802cc6:	e8 ac d9 ff ff       	call   800677 <cprintf>
  802ccb:	83 c4 10             	add    $0x10,%esp
			cprintf("address : %x\n",new_mem);
  802cce:	83 ec 08             	sub    $0x8,%esp
  802cd1:	ff 75 bc             	pushl  -0x44(%ebp)
  802cd4:	68 55 48 80 00       	push   $0x804855
  802cd9:	e8 99 d9 ff ff       	call   800677 <cprintf>
  802cde:	83 c4 10             	add    $0x10,%esp
			set_block_data(new_mem, ROUNDUP(required_size, PAGE_SIZE), 1);
  802ce1:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  802ce8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802ceb:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802cee:	01 d0                	add    %edx,%eax
  802cf0:	48                   	dec    %eax
  802cf1:	89 45 ac             	mov    %eax,-0x54(%ebp)
  802cf4:	8b 45 ac             	mov    -0x54(%ebp),%eax
  802cf7:	ba 00 00 00 00       	mov    $0x0,%edx
  802cfc:	f7 75 b0             	divl   -0x50(%ebp)
  802cff:	8b 45 ac             	mov    -0x54(%ebp),%eax
  802d02:	29 d0                	sub    %edx,%eax
  802d04:	83 ec 04             	sub    $0x4,%esp
  802d07:	6a 01                	push   $0x1
  802d09:	50                   	push   %eax
  802d0a:	ff 75 bc             	pushl  -0x44(%ebp)
  802d0d:	e8 51 f5 ff ff       	call   802263 <set_block_data>
  802d12:	83 c4 10             	add    $0x10,%esp
			free_block(new_mem);
  802d15:	83 ec 0c             	sub    $0xc,%esp
  802d18:	ff 75 bc             	pushl  -0x44(%ebp)
  802d1b:	e8 36 04 00 00       	call   803156 <free_block>
  802d20:	83 c4 10             	add    $0x10,%esp
			return alloc_block_BF(size);
  802d23:	83 ec 0c             	sub    $0xc,%esp
  802d26:	ff 75 08             	pushl  0x8(%ebp)
  802d29:	e8 20 fa ff ff       	call   80274e <alloc_block_BF>
  802d2e:	83 c4 10             	add    $0x10,%esp
			}
			return new_mem;
}
  802d31:	c9                   	leave  
  802d32:	c3                   	ret    

00802d33 <merging>:

//===================================================
// [5] FREE BLOCK WITH COALESCING:
//===================================================
void merging(struct BlockElement *prev_block, struct BlockElement *next_block, void* va){
  802d33:	55                   	push   %ebp
  802d34:	89 e5                	mov    %esp,%ebp
  802d36:	53                   	push   %ebx
  802d37:	83 ec 24             	sub    $0x24,%esp
	bool prev_is_free = 0, next_is_free = 0;
  802d3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  802d41:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (prev_block != NULL && (char *)prev_block + get_block_size(prev_block) == (char *)va) {
  802d48:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802d4c:	74 1e                	je     802d6c <merging+0x39>
  802d4e:	ff 75 08             	pushl  0x8(%ebp)
  802d51:	e8 bc f1 ff ff       	call   801f12 <get_block_size>
  802d56:	83 c4 04             	add    $0x4,%esp
  802d59:	89 c2                	mov    %eax,%edx
  802d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  802d5e:	01 d0                	add    %edx,%eax
  802d60:	3b 45 10             	cmp    0x10(%ebp),%eax
  802d63:	75 07                	jne    802d6c <merging+0x39>
		prev_is_free = 1;
  802d65:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	}
	if (next_block != NULL && (char *)va + get_block_size(va) == (char *)next_block) {
  802d6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802d70:	74 1e                	je     802d90 <merging+0x5d>
  802d72:	ff 75 10             	pushl  0x10(%ebp)
  802d75:	e8 98 f1 ff ff       	call   801f12 <get_block_size>
  802d7a:	83 c4 04             	add    $0x4,%esp
  802d7d:	89 c2                	mov    %eax,%edx
  802d7f:	8b 45 10             	mov    0x10(%ebp),%eax
  802d82:	01 d0                	add    %edx,%eax
  802d84:	3b 45 0c             	cmp    0xc(%ebp),%eax
  802d87:	75 07                	jne    802d90 <merging+0x5d>
		next_is_free = 1;
  802d89:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	if(prev_is_free && next_is_free)
  802d90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802d94:	0f 84 cc 00 00 00    	je     802e66 <merging+0x133>
  802d9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802d9e:	0f 84 c2 00 00 00    	je     802e66 <merging+0x133>
	{
		//merge - 2 sides
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va) + get_block_size(next_block);
  802da4:	ff 75 08             	pushl  0x8(%ebp)
  802da7:	e8 66 f1 ff ff       	call   801f12 <get_block_size>
  802dac:	83 c4 04             	add    $0x4,%esp
  802daf:	89 c3                	mov    %eax,%ebx
  802db1:	ff 75 10             	pushl  0x10(%ebp)
  802db4:	e8 59 f1 ff ff       	call   801f12 <get_block_size>
  802db9:	83 c4 04             	add    $0x4,%esp
  802dbc:	01 c3                	add    %eax,%ebx
  802dbe:	ff 75 0c             	pushl  0xc(%ebp)
  802dc1:	e8 4c f1 ff ff       	call   801f12 <get_block_size>
  802dc6:	83 c4 04             	add    $0x4,%esp
  802dc9:	01 d8                	add    %ebx,%eax
  802dcb:	89 45 ec             	mov    %eax,-0x14(%ebp)
		set_block_data(prev_block, new_block_size, 0);
  802dce:	6a 00                	push   $0x0
  802dd0:	ff 75 ec             	pushl  -0x14(%ebp)
  802dd3:	ff 75 08             	pushl  0x8(%ebp)
  802dd6:	e8 88 f4 ff ff       	call   802263 <set_block_data>
  802ddb:	83 c4 0c             	add    $0xc,%esp
		LIST_REMOVE(&freeBlocksList, next_block);
  802dde:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802de2:	75 17                	jne    802dfb <merging+0xc8>
  802de4:	83 ec 04             	sub    $0x4,%esp
  802de7:	68 8b 47 80 00       	push   $0x80478b
  802dec:	68 7d 01 00 00       	push   $0x17d
  802df1:	68 a9 47 80 00       	push   $0x8047a9
  802df6:	e8 bf d5 ff ff       	call   8003ba <_panic>
  802dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  802dfe:	8b 00                	mov    (%eax),%eax
  802e00:	85 c0                	test   %eax,%eax
  802e02:	74 10                	je     802e14 <merging+0xe1>
  802e04:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e07:	8b 00                	mov    (%eax),%eax
  802e09:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e0c:	8b 52 04             	mov    0x4(%edx),%edx
  802e0f:	89 50 04             	mov    %edx,0x4(%eax)
  802e12:	eb 0b                	jmp    802e1f <merging+0xec>
  802e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e17:	8b 40 04             	mov    0x4(%eax),%eax
  802e1a:	a3 30 50 80 00       	mov    %eax,0x805030
  802e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e22:	8b 40 04             	mov    0x4(%eax),%eax
  802e25:	85 c0                	test   %eax,%eax
  802e27:	74 0f                	je     802e38 <merging+0x105>
  802e29:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e2c:	8b 40 04             	mov    0x4(%eax),%eax
  802e2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e32:	8b 12                	mov    (%edx),%edx
  802e34:	89 10                	mov    %edx,(%eax)
  802e36:	eb 0a                	jmp    802e42 <merging+0x10f>
  802e38:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e3b:	8b 00                	mov    (%eax),%eax
  802e3d:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e45:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e4e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802e55:	a1 38 50 80 00       	mov    0x805038,%eax
  802e5a:	48                   	dec    %eax
  802e5b:	a3 38 50 80 00       	mov    %eax,0x805038
	}
	if (next_block != NULL && (char *)va + get_block_size(va) == (char *)next_block) {
		next_is_free = 1;
	}
	if(prev_is_free && next_is_free)
	{
  802e60:	90                   	nop
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  802e61:	e9 ea 02 00 00       	jmp    803150 <merging+0x41d>
		//merge - 2 sides
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va) + get_block_size(next_block);
		set_block_data(prev_block, new_block_size, 0);
		LIST_REMOVE(&freeBlocksList, next_block);
	}
	else if(prev_is_free)
  802e66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802e6a:	74 3b                	je     802ea7 <merging+0x174>
	{
		//merge - left side
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va);
  802e6c:	83 ec 0c             	sub    $0xc,%esp
  802e6f:	ff 75 08             	pushl  0x8(%ebp)
  802e72:	e8 9b f0 ff ff       	call   801f12 <get_block_size>
  802e77:	83 c4 10             	add    $0x10,%esp
  802e7a:	89 c3                	mov    %eax,%ebx
  802e7c:	83 ec 0c             	sub    $0xc,%esp
  802e7f:	ff 75 10             	pushl  0x10(%ebp)
  802e82:	e8 8b f0 ff ff       	call   801f12 <get_block_size>
  802e87:	83 c4 10             	add    $0x10,%esp
  802e8a:	01 d8                	add    %ebx,%eax
  802e8c:	89 45 e8             	mov    %eax,-0x18(%ebp)
		set_block_data(prev_block, new_block_size, 0);
  802e8f:	83 ec 04             	sub    $0x4,%esp
  802e92:	6a 00                	push   $0x0
  802e94:	ff 75 e8             	pushl  -0x18(%ebp)
  802e97:	ff 75 08             	pushl  0x8(%ebp)
  802e9a:	e8 c4 f3 ff ff       	call   802263 <set_block_data>
  802e9f:	83 c4 10             	add    $0x10,%esp
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  802ea2:	e9 a9 02 00 00       	jmp    803150 <merging+0x41d>
	{
		//merge - left side
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va);
		set_block_data(prev_block, new_block_size, 0);
	}
	else if(next_is_free)
  802ea7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802eab:	0f 84 2d 01 00 00    	je     802fde <merging+0x2ab>
	{
		//merge - right side

		uint32 new_block_size = get_block_size(va) + get_block_size(next_block);
  802eb1:	83 ec 0c             	sub    $0xc,%esp
  802eb4:	ff 75 10             	pushl  0x10(%ebp)
  802eb7:	e8 56 f0 ff ff       	call   801f12 <get_block_size>
  802ebc:	83 c4 10             	add    $0x10,%esp
  802ebf:	89 c3                	mov    %eax,%ebx
  802ec1:	83 ec 0c             	sub    $0xc,%esp
  802ec4:	ff 75 0c             	pushl  0xc(%ebp)
  802ec7:	e8 46 f0 ff ff       	call   801f12 <get_block_size>
  802ecc:	83 c4 10             	add    $0x10,%esp
  802ecf:	01 d8                	add    %ebx,%eax
  802ed1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		set_block_data(va, new_block_size, 0);
  802ed4:	83 ec 04             	sub    $0x4,%esp
  802ed7:	6a 00                	push   $0x0
  802ed9:	ff 75 e4             	pushl  -0x1c(%ebp)
  802edc:	ff 75 10             	pushl  0x10(%ebp)
  802edf:	e8 7f f3 ff ff       	call   802263 <set_block_data>
  802ee4:	83 c4 10             	add    $0x10,%esp

		struct BlockElement *va_block = (struct BlockElement *)va;
  802ee7:	8b 45 10             	mov    0x10(%ebp),%eax
  802eea:	89 45 e0             	mov    %eax,-0x20(%ebp)
		LIST_INSERT_BEFORE(&freeBlocksList, next_block, va_block);
  802eed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802ef1:	74 06                	je     802ef9 <merging+0x1c6>
  802ef3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  802ef7:	75 17                	jne    802f10 <merging+0x1dd>
  802ef9:	83 ec 04             	sub    $0x4,%esp
  802efc:	68 64 48 80 00       	push   $0x804864
  802f01:	68 8d 01 00 00       	push   $0x18d
  802f06:	68 a9 47 80 00       	push   $0x8047a9
  802f0b:	e8 aa d4 ff ff       	call   8003ba <_panic>
  802f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f13:	8b 50 04             	mov    0x4(%eax),%edx
  802f16:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f19:	89 50 04             	mov    %edx,0x4(%eax)
  802f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f22:	89 10                	mov    %edx,(%eax)
  802f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f27:	8b 40 04             	mov    0x4(%eax),%eax
  802f2a:	85 c0                	test   %eax,%eax
  802f2c:	74 0d                	je     802f3b <merging+0x208>
  802f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f31:	8b 40 04             	mov    0x4(%eax),%eax
  802f34:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802f37:	89 10                	mov    %edx,(%eax)
  802f39:	eb 08                	jmp    802f43 <merging+0x210>
  802f3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f3e:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802f43:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f46:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802f49:	89 50 04             	mov    %edx,0x4(%eax)
  802f4c:	a1 38 50 80 00       	mov    0x805038,%eax
  802f51:	40                   	inc    %eax
  802f52:	a3 38 50 80 00       	mov    %eax,0x805038
		LIST_REMOVE(&freeBlocksList, next_block);
  802f57:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802f5b:	75 17                	jne    802f74 <merging+0x241>
  802f5d:	83 ec 04             	sub    $0x4,%esp
  802f60:	68 8b 47 80 00       	push   $0x80478b
  802f65:	68 8e 01 00 00       	push   $0x18e
  802f6a:	68 a9 47 80 00       	push   $0x8047a9
  802f6f:	e8 46 d4 ff ff       	call   8003ba <_panic>
  802f74:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f77:	8b 00                	mov    (%eax),%eax
  802f79:	85 c0                	test   %eax,%eax
  802f7b:	74 10                	je     802f8d <merging+0x25a>
  802f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f80:	8b 00                	mov    (%eax),%eax
  802f82:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f85:	8b 52 04             	mov    0x4(%edx),%edx
  802f88:	89 50 04             	mov    %edx,0x4(%eax)
  802f8b:	eb 0b                	jmp    802f98 <merging+0x265>
  802f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f90:	8b 40 04             	mov    0x4(%eax),%eax
  802f93:	a3 30 50 80 00       	mov    %eax,0x805030
  802f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f9b:	8b 40 04             	mov    0x4(%eax),%eax
  802f9e:	85 c0                	test   %eax,%eax
  802fa0:	74 0f                	je     802fb1 <merging+0x27e>
  802fa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fa5:	8b 40 04             	mov    0x4(%eax),%eax
  802fa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  802fab:	8b 12                	mov    (%edx),%edx
  802fad:	89 10                	mov    %edx,(%eax)
  802faf:	eb 0a                	jmp    802fbb <merging+0x288>
  802fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fb4:	8b 00                	mov    (%eax),%eax
  802fb6:	a3 2c 50 80 00       	mov    %eax,0x80502c
  802fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fbe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802fc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fc7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802fce:	a1 38 50 80 00       	mov    0x805038,%eax
  802fd3:	48                   	dec    %eax
  802fd4:	a3 38 50 80 00       	mov    %eax,0x805038
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  802fd9:	e9 72 01 00 00       	jmp    803150 <merging+0x41d>
		LIST_INSERT_BEFORE(&freeBlocksList, next_block, va_block);
		LIST_REMOVE(&freeBlocksList, next_block);
	}
	else
	{
		struct BlockElement *va_block = (struct BlockElement *)va;
  802fde:	8b 45 10             	mov    0x10(%ebp),%eax
  802fe1:	89 45 dc             	mov    %eax,-0x24(%ebp)

		if(prev_block != NULL && next_block != NULL) LIST_INSERT_AFTER(&freeBlocksList, prev_block, va_block);
  802fe4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802fe8:	74 79                	je     803063 <merging+0x330>
  802fea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802fee:	74 73                	je     803063 <merging+0x330>
  802ff0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802ff4:	74 06                	je     802ffc <merging+0x2c9>
  802ff6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  802ffa:	75 17                	jne    803013 <merging+0x2e0>
  802ffc:	83 ec 04             	sub    $0x4,%esp
  802fff:	68 1c 48 80 00       	push   $0x80481c
  803004:	68 94 01 00 00       	push   $0x194
  803009:	68 a9 47 80 00       	push   $0x8047a9
  80300e:	e8 a7 d3 ff ff       	call   8003ba <_panic>
  803013:	8b 45 08             	mov    0x8(%ebp),%eax
  803016:	8b 10                	mov    (%eax),%edx
  803018:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80301b:	89 10                	mov    %edx,(%eax)
  80301d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803020:	8b 00                	mov    (%eax),%eax
  803022:	85 c0                	test   %eax,%eax
  803024:	74 0b                	je     803031 <merging+0x2fe>
  803026:	8b 45 08             	mov    0x8(%ebp),%eax
  803029:	8b 00                	mov    (%eax),%eax
  80302b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80302e:	89 50 04             	mov    %edx,0x4(%eax)
  803031:	8b 45 08             	mov    0x8(%ebp),%eax
  803034:	8b 55 dc             	mov    -0x24(%ebp),%edx
  803037:	89 10                	mov    %edx,(%eax)
  803039:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80303c:	8b 55 08             	mov    0x8(%ebp),%edx
  80303f:	89 50 04             	mov    %edx,0x4(%eax)
  803042:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803045:	8b 00                	mov    (%eax),%eax
  803047:	85 c0                	test   %eax,%eax
  803049:	75 08                	jne    803053 <merging+0x320>
  80304b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80304e:	a3 30 50 80 00       	mov    %eax,0x805030
  803053:	a1 38 50 80 00       	mov    0x805038,%eax
  803058:	40                   	inc    %eax
  803059:	a3 38 50 80 00       	mov    %eax,0x805038
  80305e:	e9 ce 00 00 00       	jmp    803131 <merging+0x3fe>
		else if(prev_block != NULL) LIST_INSERT_TAIL(&freeBlocksList, va_block);
  803063:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  803067:	74 65                	je     8030ce <merging+0x39b>
  803069:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80306d:	75 17                	jne    803086 <merging+0x353>
  80306f:	83 ec 04             	sub    $0x4,%esp
  803072:	68 f8 47 80 00       	push   $0x8047f8
  803077:	68 95 01 00 00       	push   $0x195
  80307c:	68 a9 47 80 00       	push   $0x8047a9
  803081:	e8 34 d3 ff ff       	call   8003ba <_panic>
  803086:	8b 15 30 50 80 00    	mov    0x805030,%edx
  80308c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80308f:	89 50 04             	mov    %edx,0x4(%eax)
  803092:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803095:	8b 40 04             	mov    0x4(%eax),%eax
  803098:	85 c0                	test   %eax,%eax
  80309a:	74 0c                	je     8030a8 <merging+0x375>
  80309c:	a1 30 50 80 00       	mov    0x805030,%eax
  8030a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8030a4:	89 10                	mov    %edx,(%eax)
  8030a6:	eb 08                	jmp    8030b0 <merging+0x37d>
  8030a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8030ab:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8030b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8030b3:	a3 30 50 80 00       	mov    %eax,0x805030
  8030b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8030bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8030c1:	a1 38 50 80 00       	mov    0x805038,%eax
  8030c6:	40                   	inc    %eax
  8030c7:	a3 38 50 80 00       	mov    %eax,0x805038
  8030cc:	eb 63                	jmp    803131 <merging+0x3fe>
		else
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
  8030ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8030d2:	75 17                	jne    8030eb <merging+0x3b8>
  8030d4:	83 ec 04             	sub    $0x4,%esp
  8030d7:	68 c4 47 80 00       	push   $0x8047c4
  8030dc:	68 98 01 00 00       	push   $0x198
  8030e1:	68 a9 47 80 00       	push   $0x8047a9
  8030e6:	e8 cf d2 ff ff       	call   8003ba <_panic>
  8030eb:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  8030f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8030f4:	89 10                	mov    %edx,(%eax)
  8030f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8030f9:	8b 00                	mov    (%eax),%eax
  8030fb:	85 c0                	test   %eax,%eax
  8030fd:	74 0d                	je     80310c <merging+0x3d9>
  8030ff:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803104:	8b 55 dc             	mov    -0x24(%ebp),%edx
  803107:	89 50 04             	mov    %edx,0x4(%eax)
  80310a:	eb 08                	jmp    803114 <merging+0x3e1>
  80310c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80310f:	a3 30 50 80 00       	mov    %eax,0x805030
  803114:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803117:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80311c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80311f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803126:	a1 38 50 80 00       	mov    0x805038,%eax
  80312b:	40                   	inc    %eax
  80312c:	a3 38 50 80 00       	mov    %eax,0x805038
		}
		set_block_data(va, get_block_size(va), 0);
  803131:	83 ec 0c             	sub    $0xc,%esp
  803134:	ff 75 10             	pushl  0x10(%ebp)
  803137:	e8 d6 ed ff ff       	call   801f12 <get_block_size>
  80313c:	83 c4 10             	add    $0x10,%esp
  80313f:	83 ec 04             	sub    $0x4,%esp
  803142:	6a 00                	push   $0x0
  803144:	50                   	push   %eax
  803145:	ff 75 10             	pushl  0x10(%ebp)
  803148:	e8 16 f1 ff ff       	call   802263 <set_block_data>
  80314d:	83 c4 10             	add    $0x10,%esp
	}
}
  803150:	90                   	nop
  803151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803154:	c9                   	leave  
  803155:	c3                   	ret    

00803156 <free_block>:
//===================================================
// [5] FREE BLOCK WITH COALESCING:
//===================================================
void free_block(void *va)
{
  803156:	55                   	push   %ebp
  803157:	89 e5                	mov    %esp,%ebp
  803159:	83 ec 18             	sub    $0x18,%esp
	//TODO: [PROJECT'24.MS1 - #07] [3] DYNAMIC ALLOCATOR - free_block
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("free_block is not implemented yet");
	//Your Code is Here...
	struct BlockElement *prev_block = LIST_FIRST(&freeBlocksList);
  80315c:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803161:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if((char *)LIST_LAST(&freeBlocksList) < (char *)va){
  803164:	a1 30 50 80 00       	mov    0x805030,%eax
  803169:	3b 45 08             	cmp    0x8(%ebp),%eax
  80316c:	73 1b                	jae    803189 <free_block+0x33>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
  80316e:	a1 30 50 80 00       	mov    0x805030,%eax
  803173:	83 ec 04             	sub    $0x4,%esp
  803176:	ff 75 08             	pushl  0x8(%ebp)
  803179:	6a 00                	push   $0x0
  80317b:	50                   	push   %eax
  80317c:	e8 b2 fb ff ff       	call   802d33 <merging>
  803181:	83 c4 10             	add    $0x10,%esp
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  803184:	e9 8b 00 00 00       	jmp    803214 <free_block+0xbe>
	struct BlockElement *prev_block = LIST_FIRST(&freeBlocksList);

	if((char *)LIST_LAST(&freeBlocksList) < (char *)va){
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
  803189:	a1 2c 50 80 00       	mov    0x80502c,%eax
  80318e:	3b 45 08             	cmp    0x8(%ebp),%eax
  803191:	76 18                	jbe    8031ab <free_block+0x55>
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
  803193:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803198:	83 ec 04             	sub    $0x4,%esp
  80319b:	ff 75 08             	pushl  0x8(%ebp)
  80319e:	50                   	push   %eax
  80319f:	6a 00                	push   $0x0
  8031a1:	e8 8d fb ff ff       	call   802d33 <merging>
  8031a6:	83 c4 10             	add    $0x10,%esp
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  8031a9:	eb 69                	jmp    803214 <free_block+0xbe>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
	}
	else LIST_FOREACH (prev_block, &freeBlocksList){
  8031ab:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8031b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8031b3:	eb 39                	jmp    8031ee <free_block+0x98>
		if((uint32 *)prev_block < (uint32 *)va && (uint32 *)prev_block->prev_next_info.le_next > (uint32 *)va ){
  8031b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031b8:	3b 45 08             	cmp    0x8(%ebp),%eax
  8031bb:	73 29                	jae    8031e6 <free_block+0x90>
  8031bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031c0:	8b 00                	mov    (%eax),%eax
  8031c2:	3b 45 08             	cmp    0x8(%ebp),%eax
  8031c5:	76 1f                	jbe    8031e6 <free_block+0x90>
			//get the address of prev and next
			struct BlockElement *next_block = LIST_NEXT(prev_block);
  8031c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031ca:	8b 00                	mov    (%eax),%eax
  8031cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
			merging(prev_block, next_block, va);
  8031cf:	83 ec 04             	sub    $0x4,%esp
  8031d2:	ff 75 08             	pushl  0x8(%ebp)
  8031d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8031d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8031db:	e8 53 fb ff ff       	call   802d33 <merging>
  8031e0:	83 c4 10             	add    $0x10,%esp
			break;
  8031e3:	90                   	nop
		}
	}
}
  8031e4:	eb 2e                	jmp    803214 <free_block+0xbe>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
	}
	else LIST_FOREACH (prev_block, &freeBlocksList){
  8031e6:	a1 34 50 80 00       	mov    0x805034,%eax
  8031eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8031ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8031f2:	74 07                	je     8031fb <free_block+0xa5>
  8031f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031f7:	8b 00                	mov    (%eax),%eax
  8031f9:	eb 05                	jmp    803200 <free_block+0xaa>
  8031fb:	b8 00 00 00 00       	mov    $0x0,%eax
  803200:	a3 34 50 80 00       	mov    %eax,0x805034
  803205:	a1 34 50 80 00       	mov    0x805034,%eax
  80320a:	85 c0                	test   %eax,%eax
  80320c:	75 a7                	jne    8031b5 <free_block+0x5f>
  80320e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803212:	75 a1                	jne    8031b5 <free_block+0x5f>
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  803214:	90                   	nop
  803215:	c9                   	leave  
  803216:	c3                   	ret    

00803217 <copy_data>:

//=========================================
// [6] REALLOCATE BLOCK BY FIRST FIT:
//=========================================
void copy_data(void *va, void *new_va)
{
  803217:	55                   	push   %ebp
  803218:	89 e5                	mov    %esp,%ebp
  80321a:	83 ec 10             	sub    $0x10,%esp
	uint32 va_size = get_block_size(va);
  80321d:	ff 75 08             	pushl  0x8(%ebp)
  803220:	e8 ed ec ff ff       	call   801f12 <get_block_size>
  803225:	83 c4 04             	add    $0x4,%esp
  803228:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for(int i = 0; i < va_size; i++) *((char *)new_va + i) = *((char *)va + i);
  80322b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  803232:	eb 17                	jmp    80324b <copy_data+0x34>
  803234:	8b 55 fc             	mov    -0x4(%ebp),%edx
  803237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80323a:	01 c2                	add    %eax,%edx
  80323c:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80323f:	8b 45 08             	mov    0x8(%ebp),%eax
  803242:	01 c8                	add    %ecx,%eax
  803244:	8a 00                	mov    (%eax),%al
  803246:	88 02                	mov    %al,(%edx)
  803248:	ff 45 fc             	incl   -0x4(%ebp)
  80324b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80324e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  803251:	72 e1                	jb     803234 <copy_data+0x1d>
}
  803253:	90                   	nop
  803254:	c9                   	leave  
  803255:	c3                   	ret    

00803256 <realloc_block_FF>:

void *realloc_block_FF(void* va, uint32 new_size)
{
  803256:	55                   	push   %ebp
  803257:	89 e5                	mov    %esp,%ebp
  803259:	83 ec 58             	sub    $0x58,%esp
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("realloc_block_FF is not implemented yet");
	//Your Code is Here...


	if(va == NULL)
  80325c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  803260:	75 23                	jne    803285 <realloc_block_FF+0x2f>
	{
		if(new_size != 0) return alloc_block_FF(new_size);
  803262:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803266:	74 13                	je     80327b <realloc_block_FF+0x25>
  803268:	83 ec 0c             	sub    $0xc,%esp
  80326b:	ff 75 0c             	pushl  0xc(%ebp)
  80326e:	e8 1f f0 ff ff       	call   802292 <alloc_block_FF>
  803273:	83 c4 10             	add    $0x10,%esp
  803276:	e9 f4 06 00 00       	jmp    80396f <realloc_block_FF+0x719>
		return NULL;
  80327b:	b8 00 00 00 00       	mov    $0x0,%eax
  803280:	e9 ea 06 00 00       	jmp    80396f <realloc_block_FF+0x719>
	}

	if(new_size == 0)
  803285:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803289:	75 18                	jne    8032a3 <realloc_block_FF+0x4d>
	{
		free_block(va);
  80328b:	83 ec 0c             	sub    $0xc,%esp
  80328e:	ff 75 08             	pushl  0x8(%ebp)
  803291:	e8 c0 fe ff ff       	call   803156 <free_block>
  803296:	83 c4 10             	add    $0x10,%esp
		return NULL;
  803299:	b8 00 00 00 00       	mov    $0x0,%eax
  80329e:	e9 cc 06 00 00       	jmp    80396f <realloc_block_FF+0x719>
	}


	if(new_size < 8) new_size = 8;
  8032a3:	83 7d 0c 07          	cmpl   $0x7,0xc(%ebp)
  8032a7:	77 07                	ja     8032b0 <realloc_block_FF+0x5a>
  8032a9:	c7 45 0c 08 00 00 00 	movl   $0x8,0xc(%ebp)
	new_size += (new_size % 2);
  8032b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032b3:	83 e0 01             	and    $0x1,%eax
  8032b6:	01 45 0c             	add    %eax,0xc(%ebp)

	//cur Block data
	uint32 newBLOCK_size = new_size + 8;
  8032b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032bc:	83 c0 08             	add    $0x8,%eax
  8032bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 curBLOCK_size = get_block_size(va) /*BLOCK size in Bytes*/;
  8032c2:	83 ec 0c             	sub    $0xc,%esp
  8032c5:	ff 75 08             	pushl  0x8(%ebp)
  8032c8:	e8 45 ec ff ff       	call   801f12 <get_block_size>
  8032cd:	83 c4 10             	add    $0x10,%esp
  8032d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uint32 cur_size = curBLOCK_size - 8 /*8 Bytes = (Header + Footer) size*/;
  8032d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8032d6:	83 e8 08             	sub    $0x8,%eax
  8032d9:	89 45 e8             	mov    %eax,-0x18(%ebp)

	//next Block data
	void *next_va = (void *)(FOOTER(va) + 2);
  8032dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8032df:	83 e8 04             	sub    $0x4,%eax
  8032e2:	8b 00                	mov    (%eax),%eax
  8032e4:	83 e0 fe             	and    $0xfffffffe,%eax
  8032e7:	89 c2                	mov    %eax,%edx
  8032e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8032ec:	01 d0                	add    %edx,%eax
  8032ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32 nextBLOCK_size = get_block_size(next_va)/*&is_free_block(next_block_va)*/; //=0 if not free
  8032f1:	83 ec 0c             	sub    $0xc,%esp
  8032f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8032f7:	e8 16 ec ff ff       	call   801f12 <get_block_size>
  8032fc:	83 c4 10             	add    $0x10,%esp
  8032ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32 next_cur_size = nextBLOCK_size - 8 /*8 Bytes = (Header + Footer) size*/;
  803302:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803305:	83 e8 08             	sub    $0x8,%eax
  803308:	89 45 dc             	mov    %eax,-0x24(%ebp)


	//if the user needs the same size he owns
	if(new_size == cur_size)
  80330b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80330e:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  803311:	75 08                	jne    80331b <realloc_block_FF+0xc5>
	{
		 return va;
  803313:	8b 45 08             	mov    0x8(%ebp),%eax
  803316:	e9 54 06 00 00       	jmp    80396f <realloc_block_FF+0x719>

	}


	if(new_size < cur_size)
  80331b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80331e:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  803321:	0f 83 e5 03 00 00    	jae    80370c <realloc_block_FF+0x4b6>
	{
		uint32 remaining_size = cur_size - new_size; //remaining size in single Bytes
  803327:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80332a:	2b 45 0c             	sub    0xc(%ebp),%eax
  80332d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if(is_free_block(next_va))
  803330:	83 ec 0c             	sub    $0xc,%esp
  803333:	ff 75 e4             	pushl  -0x1c(%ebp)
  803336:	e8 f0 eb ff ff       	call   801f2b <is_free_block>
  80333b:	83 c4 10             	add    $0x10,%esp
  80333e:	84 c0                	test   %al,%al
  803340:	0f 84 3b 01 00 00    	je     803481 <realloc_block_FF+0x22b>
		{

			uint32 next_newBLOCK_size = nextBLOCK_size + remaining_size;
  803346:	8b 55 e0             	mov    -0x20(%ebp),%edx
  803349:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80334c:	01 d0                	add    %edx,%eax
  80334e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			set_block_data(va, newBLOCK_size, 1);
  803351:	83 ec 04             	sub    $0x4,%esp
  803354:	6a 01                	push   $0x1
  803356:	ff 75 f0             	pushl  -0x10(%ebp)
  803359:	ff 75 08             	pushl  0x8(%ebp)
  80335c:	e8 02 ef ff ff       	call   802263 <set_block_data>
  803361:	83 c4 10             	add    $0x10,%esp
			void *next_new_va = (void *)(FOOTER(va) + 2);
  803364:	8b 45 08             	mov    0x8(%ebp),%eax
  803367:	83 e8 04             	sub    $0x4,%eax
  80336a:	8b 00                	mov    (%eax),%eax
  80336c:	83 e0 fe             	and    $0xfffffffe,%eax
  80336f:	89 c2                	mov    %eax,%edx
  803371:	8b 45 08             	mov    0x8(%ebp),%eax
  803374:	01 d0                	add    %edx,%eax
  803376:	89 45 c8             	mov    %eax,-0x38(%ebp)
			set_block_data(next_new_va, next_newBLOCK_size, 0);
  803379:	83 ec 04             	sub    $0x4,%esp
  80337c:	6a 00                	push   $0x0
  80337e:	ff 75 cc             	pushl  -0x34(%ebp)
  803381:	ff 75 c8             	pushl  -0x38(%ebp)
  803384:	e8 da ee ff ff       	call   802263 <set_block_data>
  803389:	83 c4 10             	add    $0x10,%esp
			LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement*)next_va, (struct BlockElement*)next_new_va);
  80338c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  803390:	74 06                	je     803398 <realloc_block_FF+0x142>
  803392:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  803396:	75 17                	jne    8033af <realloc_block_FF+0x159>
  803398:	83 ec 04             	sub    $0x4,%esp
  80339b:	68 1c 48 80 00       	push   $0x80481c
  8033a0:	68 f6 01 00 00       	push   $0x1f6
  8033a5:	68 a9 47 80 00       	push   $0x8047a9
  8033aa:	e8 0b d0 ff ff       	call   8003ba <_panic>
  8033af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8033b2:	8b 10                	mov    (%eax),%edx
  8033b4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8033b7:	89 10                	mov    %edx,(%eax)
  8033b9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8033bc:	8b 00                	mov    (%eax),%eax
  8033be:	85 c0                	test   %eax,%eax
  8033c0:	74 0b                	je     8033cd <realloc_block_FF+0x177>
  8033c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8033c5:	8b 00                	mov    (%eax),%eax
  8033c7:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8033ca:	89 50 04             	mov    %edx,0x4(%eax)
  8033cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8033d0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8033d3:	89 10                	mov    %edx,(%eax)
  8033d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8033d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8033db:	89 50 04             	mov    %edx,0x4(%eax)
  8033de:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8033e1:	8b 00                	mov    (%eax),%eax
  8033e3:	85 c0                	test   %eax,%eax
  8033e5:	75 08                	jne    8033ef <realloc_block_FF+0x199>
  8033e7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8033ea:	a3 30 50 80 00       	mov    %eax,0x805030
  8033ef:	a1 38 50 80 00       	mov    0x805038,%eax
  8033f4:	40                   	inc    %eax
  8033f5:	a3 38 50 80 00       	mov    %eax,0x805038
			LIST_REMOVE(&freeBlocksList, (struct BlockElement*)next_va);
  8033fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8033fe:	75 17                	jne    803417 <realloc_block_FF+0x1c1>
  803400:	83 ec 04             	sub    $0x4,%esp
  803403:	68 8b 47 80 00       	push   $0x80478b
  803408:	68 f7 01 00 00       	push   $0x1f7
  80340d:	68 a9 47 80 00       	push   $0x8047a9
  803412:	e8 a3 cf ff ff       	call   8003ba <_panic>
  803417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80341a:	8b 00                	mov    (%eax),%eax
  80341c:	85 c0                	test   %eax,%eax
  80341e:	74 10                	je     803430 <realloc_block_FF+0x1da>
  803420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803423:	8b 00                	mov    (%eax),%eax
  803425:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803428:	8b 52 04             	mov    0x4(%edx),%edx
  80342b:	89 50 04             	mov    %edx,0x4(%eax)
  80342e:	eb 0b                	jmp    80343b <realloc_block_FF+0x1e5>
  803430:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803433:	8b 40 04             	mov    0x4(%eax),%eax
  803436:	a3 30 50 80 00       	mov    %eax,0x805030
  80343b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80343e:	8b 40 04             	mov    0x4(%eax),%eax
  803441:	85 c0                	test   %eax,%eax
  803443:	74 0f                	je     803454 <realloc_block_FF+0x1fe>
  803445:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803448:	8b 40 04             	mov    0x4(%eax),%eax
  80344b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80344e:	8b 12                	mov    (%edx),%edx
  803450:	89 10                	mov    %edx,(%eax)
  803452:	eb 0a                	jmp    80345e <realloc_block_FF+0x208>
  803454:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803457:	8b 00                	mov    (%eax),%eax
  803459:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80345e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803461:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803467:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80346a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803471:	a1 38 50 80 00       	mov    0x805038,%eax
  803476:	48                   	dec    %eax
  803477:	a3 38 50 80 00       	mov    %eax,0x805038
  80347c:	e9 83 02 00 00       	jmp    803704 <realloc_block_FF+0x4ae>
		}
		else
		{
			if(remaining_size>=16)
  803481:	83 7d d8 0f          	cmpl   $0xf,-0x28(%ebp)
  803485:	0f 86 69 02 00 00    	jbe    8036f4 <realloc_block_FF+0x49e>
			{
				//uint32 next_new_size = remaining_size - 8;/*+ next_cur_size&is_free_block(next_cur_va)*/
				set_block_data(va, newBLOCK_size, 1);
  80348b:	83 ec 04             	sub    $0x4,%esp
  80348e:	6a 01                	push   $0x1
  803490:	ff 75 f0             	pushl  -0x10(%ebp)
  803493:	ff 75 08             	pushl  0x8(%ebp)
  803496:	e8 c8 ed ff ff       	call   802263 <set_block_data>
  80349b:	83 c4 10             	add    $0x10,%esp
				void *next_new_va = (void *)(FOOTER(va) + 2);
  80349e:	8b 45 08             	mov    0x8(%ebp),%eax
  8034a1:	83 e8 04             	sub    $0x4,%eax
  8034a4:	8b 00                	mov    (%eax),%eax
  8034a6:	83 e0 fe             	and    $0xfffffffe,%eax
  8034a9:	89 c2                	mov    %eax,%edx
  8034ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8034ae:	01 d0                	add    %edx,%eax
  8034b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

				//insert new block to free_block_list
				uint32 list_size = LIST_SIZE(&freeBlocksList);
  8034b3:	a1 38 50 80 00       	mov    0x805038,%eax
  8034b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
				if(list_size == 0)
  8034bb:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8034bf:	75 68                	jne    803529 <realloc_block_FF+0x2d3>
				{

					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement *)next_new_va);
  8034c1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8034c5:	75 17                	jne    8034de <realloc_block_FF+0x288>
  8034c7:	83 ec 04             	sub    $0x4,%esp
  8034ca:	68 c4 47 80 00       	push   $0x8047c4
  8034cf:	68 06 02 00 00       	push   $0x206
  8034d4:	68 a9 47 80 00       	push   $0x8047a9
  8034d9:	e8 dc ce ff ff       	call   8003ba <_panic>
  8034de:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  8034e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8034e7:	89 10                	mov    %edx,(%eax)
  8034e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8034ec:	8b 00                	mov    (%eax),%eax
  8034ee:	85 c0                	test   %eax,%eax
  8034f0:	74 0d                	je     8034ff <realloc_block_FF+0x2a9>
  8034f2:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8034f7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8034fa:	89 50 04             	mov    %edx,0x4(%eax)
  8034fd:	eb 08                	jmp    803507 <realloc_block_FF+0x2b1>
  8034ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803502:	a3 30 50 80 00       	mov    %eax,0x805030
  803507:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80350a:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80350f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803512:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803519:	a1 38 50 80 00       	mov    0x805038,%eax
  80351e:	40                   	inc    %eax
  80351f:	a3 38 50 80 00       	mov    %eax,0x805038
  803524:	e9 b0 01 00 00       	jmp    8036d9 <realloc_block_FF+0x483>
				}
				else if((struct BlockElement *)next_new_va < LIST_FIRST(&freeBlocksList))
  803529:	a1 2c 50 80 00       	mov    0x80502c,%eax
  80352e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  803531:	76 68                	jbe    80359b <realloc_block_FF+0x345>
				{

					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement *)next_new_va);
  803533:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  803537:	75 17                	jne    803550 <realloc_block_FF+0x2fa>
  803539:	83 ec 04             	sub    $0x4,%esp
  80353c:	68 c4 47 80 00       	push   $0x8047c4
  803541:	68 0b 02 00 00       	push   $0x20b
  803546:	68 a9 47 80 00       	push   $0x8047a9
  80354b:	e8 6a ce ff ff       	call   8003ba <_panic>
  803550:	8b 15 2c 50 80 00    	mov    0x80502c,%edx
  803556:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803559:	89 10                	mov    %edx,(%eax)
  80355b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80355e:	8b 00                	mov    (%eax),%eax
  803560:	85 c0                	test   %eax,%eax
  803562:	74 0d                	je     803571 <realloc_block_FF+0x31b>
  803564:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803569:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80356c:	89 50 04             	mov    %edx,0x4(%eax)
  80356f:	eb 08                	jmp    803579 <realloc_block_FF+0x323>
  803571:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803574:	a3 30 50 80 00       	mov    %eax,0x805030
  803579:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80357c:	a3 2c 50 80 00       	mov    %eax,0x80502c
  803581:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803584:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80358b:	a1 38 50 80 00       	mov    0x805038,%eax
  803590:	40                   	inc    %eax
  803591:	a3 38 50 80 00       	mov    %eax,0x805038
  803596:	e9 3e 01 00 00       	jmp    8036d9 <realloc_block_FF+0x483>
				}
				else if(LIST_FIRST(&freeBlocksList) < (struct BlockElement *)next_new_va)
  80359b:	a1 2c 50 80 00       	mov    0x80502c,%eax
  8035a0:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  8035a3:	73 68                	jae    80360d <realloc_block_FF+0x3b7>
				{

					LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement *)next_new_va);
  8035a5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8035a9:	75 17                	jne    8035c2 <realloc_block_FF+0x36c>
  8035ab:	83 ec 04             	sub    $0x4,%esp
  8035ae:	68 f8 47 80 00       	push   $0x8047f8
  8035b3:	68 10 02 00 00       	push   $0x210
  8035b8:	68 a9 47 80 00       	push   $0x8047a9
  8035bd:	e8 f8 cd ff ff       	call   8003ba <_panic>
  8035c2:	8b 15 30 50 80 00    	mov    0x805030,%edx
  8035c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8035cb:	89 50 04             	mov    %edx,0x4(%eax)
  8035ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8035d1:	8b 40 04             	mov    0x4(%eax),%eax
  8035d4:	85 c0                	test   %eax,%eax
  8035d6:	74 0c                	je     8035e4 <realloc_block_FF+0x38e>
  8035d8:	a1 30 50 80 00       	mov    0x805030,%eax
  8035dd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8035e0:	89 10                	mov    %edx,(%eax)
  8035e2:	eb 08                	jmp    8035ec <realloc_block_FF+0x396>
  8035e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8035e7:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8035ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8035ef:	a3 30 50 80 00       	mov    %eax,0x805030
  8035f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8035f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8035fd:	a1 38 50 80 00       	mov    0x805038,%eax
  803602:	40                   	inc    %eax
  803603:	a3 38 50 80 00       	mov    %eax,0x805038
  803608:	e9 cc 00 00 00       	jmp    8036d9 <realloc_block_FF+0x483>
				}
				else
				{

					struct BlockElement *blk = NULL;
  80360d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
					LIST_FOREACH(blk, &freeBlocksList)
  803614:	a1 2c 50 80 00       	mov    0x80502c,%eax
  803619:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80361c:	e9 8a 00 00 00       	jmp    8036ab <realloc_block_FF+0x455>
					{
						if(blk < (struct BlockElement *)next_new_va && LIST_NEXT(blk) < (struct BlockElement *)next_new_va)
  803621:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803624:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  803627:	73 7a                	jae    8036a3 <realloc_block_FF+0x44d>
  803629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80362c:	8b 00                	mov    (%eax),%eax
  80362e:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  803631:	73 70                	jae    8036a3 <realloc_block_FF+0x44d>
						{
							LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement *)next_new_va);
  803633:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803637:	74 06                	je     80363f <realloc_block_FF+0x3e9>
  803639:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80363d:	75 17                	jne    803656 <realloc_block_FF+0x400>
  80363f:	83 ec 04             	sub    $0x4,%esp
  803642:	68 1c 48 80 00       	push   $0x80481c
  803647:	68 1a 02 00 00       	push   $0x21a
  80364c:	68 a9 47 80 00       	push   $0x8047a9
  803651:	e8 64 cd ff ff       	call   8003ba <_panic>
  803656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803659:	8b 10                	mov    (%eax),%edx
  80365b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80365e:	89 10                	mov    %edx,(%eax)
  803660:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803663:	8b 00                	mov    (%eax),%eax
  803665:	85 c0                	test   %eax,%eax
  803667:	74 0b                	je     803674 <realloc_block_FF+0x41e>
  803669:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80366c:	8b 00                	mov    (%eax),%eax
  80366e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  803671:	89 50 04             	mov    %edx,0x4(%eax)
  803674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803677:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80367a:	89 10                	mov    %edx,(%eax)
  80367c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80367f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803682:	89 50 04             	mov    %edx,0x4(%eax)
  803685:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803688:	8b 00                	mov    (%eax),%eax
  80368a:	85 c0                	test   %eax,%eax
  80368c:	75 08                	jne    803696 <realloc_block_FF+0x440>
  80368e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803691:	a3 30 50 80 00       	mov    %eax,0x805030
  803696:	a1 38 50 80 00       	mov    0x805038,%eax
  80369b:	40                   	inc    %eax
  80369c:	a3 38 50 80 00       	mov    %eax,0x805038
							break;
  8036a1:	eb 36                	jmp    8036d9 <realloc_block_FF+0x483>
				}
				else
				{

					struct BlockElement *blk = NULL;
					LIST_FOREACH(blk, &freeBlocksList)
  8036a3:	a1 34 50 80 00       	mov    0x805034,%eax
  8036a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8036ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8036af:	74 07                	je     8036b8 <realloc_block_FF+0x462>
  8036b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036b4:	8b 00                	mov    (%eax),%eax
  8036b6:	eb 05                	jmp    8036bd <realloc_block_FF+0x467>
  8036b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8036bd:	a3 34 50 80 00       	mov    %eax,0x805034
  8036c2:	a1 34 50 80 00       	mov    0x805034,%eax
  8036c7:	85 c0                	test   %eax,%eax
  8036c9:	0f 85 52 ff ff ff    	jne    803621 <realloc_block_FF+0x3cb>
  8036cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8036d3:	0f 85 48 ff ff ff    	jne    803621 <realloc_block_FF+0x3cb>
							LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement *)next_new_va);
							break;
						}
					}
				}
				set_block_data(next_new_va, remaining_size, 0);
  8036d9:	83 ec 04             	sub    $0x4,%esp
  8036dc:	6a 00                	push   $0x0
  8036de:	ff 75 d8             	pushl  -0x28(%ebp)
  8036e1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8036e4:	e8 7a eb ff ff       	call   802263 <set_block_data>
  8036e9:	83 c4 10             	add    $0x10,%esp
				return va;
  8036ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8036ef:	e9 7b 02 00 00       	jmp    80396f <realloc_block_FF+0x719>
			}
			cprintf("16\n");
  8036f4:	83 ec 0c             	sub    $0xc,%esp
  8036f7:	68 99 48 80 00       	push   $0x804899
  8036fc:	e8 76 cf ff ff       	call   800677 <cprintf>
  803701:	83 c4 10             	add    $0x10,%esp
		}
		return va;
  803704:	8b 45 08             	mov    0x8(%ebp),%eax
  803707:	e9 63 02 00 00       	jmp    80396f <realloc_block_FF+0x719>
	}

	if(new_size > cur_size)
  80370c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80370f:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  803712:	0f 86 4d 02 00 00    	jbe    803965 <realloc_block_FF+0x70f>
	{
		if(is_free_block(next_va))
  803718:	83 ec 0c             	sub    $0xc,%esp
  80371b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80371e:	e8 08 e8 ff ff       	call   801f2b <is_free_block>
  803723:	83 c4 10             	add    $0x10,%esp
  803726:	84 c0                	test   %al,%al
  803728:	0f 84 37 02 00 00    	je     803965 <realloc_block_FF+0x70f>
		{

			uint32 needed_size = new_size - cur_size; //needed size in single Bytes
  80372e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803731:	2b 45 e8             	sub    -0x18(%ebp),%eax
  803734:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			if(needed_size > nextBLOCK_size)
  803737:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80373a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  80373d:	76 38                	jbe    803777 <realloc_block_FF+0x521>
			{
				free_block(va); //set it free
  80373f:	83 ec 0c             	sub    $0xc,%esp
  803742:	ff 75 08             	pushl  0x8(%ebp)
  803745:	e8 0c fa ff ff       	call   803156 <free_block>
  80374a:	83 c4 10             	add    $0x10,%esp
				void *new_va = alloc_block_FF(new_size); //new allocation
  80374d:	83 ec 0c             	sub    $0xc,%esp
  803750:	ff 75 0c             	pushl  0xc(%ebp)
  803753:	e8 3a eb ff ff       	call   802292 <alloc_block_FF>
  803758:	83 c4 10             	add    $0x10,%esp
  80375b:	89 45 c0             	mov    %eax,-0x40(%ebp)
				copy_data(va, new_va); //transfer data
  80375e:	83 ec 08             	sub    $0x8,%esp
  803761:	ff 75 c0             	pushl  -0x40(%ebp)
  803764:	ff 75 08             	pushl  0x8(%ebp)
  803767:	e8 ab fa ff ff       	call   803217 <copy_data>
  80376c:	83 c4 10             	add    $0x10,%esp
				return new_va;
  80376f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  803772:	e9 f8 01 00 00       	jmp    80396f <realloc_block_FF+0x719>
			}
			uint32 remaining_size = nextBLOCK_size - needed_size;
  803777:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80377a:	2b 45 c4             	sub    -0x3c(%ebp),%eax
  80377d:	89 45 bc             	mov    %eax,-0x44(%ebp)
			if(remaining_size < 16) //merge next block to my cur block
  803780:	83 7d bc 0f          	cmpl   $0xf,-0x44(%ebp)
  803784:	0f 87 a0 00 00 00    	ja     80382a <realloc_block_FF+0x5d4>
			{
				//remove from free_block_list, then
				LIST_REMOVE(&freeBlocksList, (struct BlockElement *)next_va);
  80378a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80378e:	75 17                	jne    8037a7 <realloc_block_FF+0x551>
  803790:	83 ec 04             	sub    $0x4,%esp
  803793:	68 8b 47 80 00       	push   $0x80478b
  803798:	68 38 02 00 00       	push   $0x238
  80379d:	68 a9 47 80 00       	push   $0x8047a9
  8037a2:	e8 13 cc ff ff       	call   8003ba <_panic>
  8037a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037aa:	8b 00                	mov    (%eax),%eax
  8037ac:	85 c0                	test   %eax,%eax
  8037ae:	74 10                	je     8037c0 <realloc_block_FF+0x56a>
  8037b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037b3:	8b 00                	mov    (%eax),%eax
  8037b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8037b8:	8b 52 04             	mov    0x4(%edx),%edx
  8037bb:	89 50 04             	mov    %edx,0x4(%eax)
  8037be:	eb 0b                	jmp    8037cb <realloc_block_FF+0x575>
  8037c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037c3:	8b 40 04             	mov    0x4(%eax),%eax
  8037c6:	a3 30 50 80 00       	mov    %eax,0x805030
  8037cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037ce:	8b 40 04             	mov    0x4(%eax),%eax
  8037d1:	85 c0                	test   %eax,%eax
  8037d3:	74 0f                	je     8037e4 <realloc_block_FF+0x58e>
  8037d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037d8:	8b 40 04             	mov    0x4(%eax),%eax
  8037db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8037de:	8b 12                	mov    (%edx),%edx
  8037e0:	89 10                	mov    %edx,(%eax)
  8037e2:	eb 0a                	jmp    8037ee <realloc_block_FF+0x598>
  8037e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037e7:	8b 00                	mov    (%eax),%eax
  8037e9:	a3 2c 50 80 00       	mov    %eax,0x80502c
  8037ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8037f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037fa:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803801:	a1 38 50 80 00       	mov    0x805038,%eax
  803806:	48                   	dec    %eax
  803807:	a3 38 50 80 00       	mov    %eax,0x805038

				//set block
				set_block_data(va, curBLOCK_size + nextBLOCK_size, 1);
  80380c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80380f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803812:	01 d0                	add    %edx,%eax
  803814:	83 ec 04             	sub    $0x4,%esp
  803817:	6a 01                	push   $0x1
  803819:	50                   	push   %eax
  80381a:	ff 75 08             	pushl  0x8(%ebp)
  80381d:	e8 41 ea ff ff       	call   802263 <set_block_data>
  803822:	83 c4 10             	add    $0x10,%esp
  803825:	e9 36 01 00 00       	jmp    803960 <realloc_block_FF+0x70a>
			}
			else
			{
				newBLOCK_size = curBLOCK_size + needed_size;
  80382a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80382d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  803830:	01 d0                	add    %edx,%eax
  803832:	89 45 f0             	mov    %eax,-0x10(%ebp)
				set_block_data(va, newBLOCK_size, 1);
  803835:	83 ec 04             	sub    $0x4,%esp
  803838:	6a 01                	push   $0x1
  80383a:	ff 75 f0             	pushl  -0x10(%ebp)
  80383d:	ff 75 08             	pushl  0x8(%ebp)
  803840:	e8 1e ea ff ff       	call   802263 <set_block_data>
  803845:	83 c4 10             	add    $0x10,%esp
				void *next_new_va = (void *)(FOOTER(va) + 2);
  803848:	8b 45 08             	mov    0x8(%ebp),%eax
  80384b:	83 e8 04             	sub    $0x4,%eax
  80384e:	8b 00                	mov    (%eax),%eax
  803850:	83 e0 fe             	and    $0xfffffffe,%eax
  803853:	89 c2                	mov    %eax,%edx
  803855:	8b 45 08             	mov    0x8(%ebp),%eax
  803858:	01 d0                	add    %edx,%eax
  80385a:	89 45 b8             	mov    %eax,-0x48(%ebp)

				//update free_block_list
				LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement*)next_va, (struct BlockElement*)next_new_va);
  80385d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  803861:	74 06                	je     803869 <realloc_block_FF+0x613>
  803863:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  803867:	75 17                	jne    803880 <realloc_block_FF+0x62a>
  803869:	83 ec 04             	sub    $0x4,%esp
  80386c:	68 1c 48 80 00       	push   $0x80481c
  803871:	68 44 02 00 00       	push   $0x244
  803876:	68 a9 47 80 00       	push   $0x8047a9
  80387b:	e8 3a cb ff ff       	call   8003ba <_panic>
  803880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803883:	8b 10                	mov    (%eax),%edx
  803885:	8b 45 b8             	mov    -0x48(%ebp),%eax
  803888:	89 10                	mov    %edx,(%eax)
  80388a:	8b 45 b8             	mov    -0x48(%ebp),%eax
  80388d:	8b 00                	mov    (%eax),%eax
  80388f:	85 c0                	test   %eax,%eax
  803891:	74 0b                	je     80389e <realloc_block_FF+0x648>
  803893:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803896:	8b 00                	mov    (%eax),%eax
  803898:	8b 55 b8             	mov    -0x48(%ebp),%edx
  80389b:	89 50 04             	mov    %edx,0x4(%eax)
  80389e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038a1:	8b 55 b8             	mov    -0x48(%ebp),%edx
  8038a4:	89 10                	mov    %edx,(%eax)
  8038a6:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8038a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8038ac:	89 50 04             	mov    %edx,0x4(%eax)
  8038af:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8038b2:	8b 00                	mov    (%eax),%eax
  8038b4:	85 c0                	test   %eax,%eax
  8038b6:	75 08                	jne    8038c0 <realloc_block_FF+0x66a>
  8038b8:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8038bb:	a3 30 50 80 00       	mov    %eax,0x805030
  8038c0:	a1 38 50 80 00       	mov    0x805038,%eax
  8038c5:	40                   	inc    %eax
  8038c6:	a3 38 50 80 00       	mov    %eax,0x805038
				LIST_REMOVE(&freeBlocksList, (struct BlockElement*)next_va);
  8038cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8038cf:	75 17                	jne    8038e8 <realloc_block_FF+0x692>
  8038d1:	83 ec 04             	sub    $0x4,%esp
  8038d4:	68 8b 47 80 00       	push   $0x80478b
  8038d9:	68 45 02 00 00       	push   $0x245
  8038de:	68 a9 47 80 00       	push   $0x8047a9
  8038e3:	e8 d2 ca ff ff       	call   8003ba <_panic>
  8038e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038eb:	8b 00                	mov    (%eax),%eax
  8038ed:	85 c0                	test   %eax,%eax
  8038ef:	74 10                	je     803901 <realloc_block_FF+0x6ab>
  8038f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8038f4:	8b 00                	mov    (%eax),%eax
  8038f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8038f9:	8b 52 04             	mov    0x4(%edx),%edx
  8038fc:	89 50 04             	mov    %edx,0x4(%eax)
  8038ff:	eb 0b                	jmp    80390c <realloc_block_FF+0x6b6>
  803901:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803904:	8b 40 04             	mov    0x4(%eax),%eax
  803907:	a3 30 50 80 00       	mov    %eax,0x805030
  80390c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80390f:	8b 40 04             	mov    0x4(%eax),%eax
  803912:	85 c0                	test   %eax,%eax
  803914:	74 0f                	je     803925 <realloc_block_FF+0x6cf>
  803916:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803919:	8b 40 04             	mov    0x4(%eax),%eax
  80391c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80391f:	8b 12                	mov    (%edx),%edx
  803921:	89 10                	mov    %edx,(%eax)
  803923:	eb 0a                	jmp    80392f <realloc_block_FF+0x6d9>
  803925:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803928:	8b 00                	mov    (%eax),%eax
  80392a:	a3 2c 50 80 00       	mov    %eax,0x80502c
  80392f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803932:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803938:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80393b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803942:	a1 38 50 80 00       	mov    0x805038,%eax
  803947:	48                   	dec    %eax
  803948:	a3 38 50 80 00       	mov    %eax,0x805038
				set_block_data(next_new_va, remaining_size, 0);
  80394d:	83 ec 04             	sub    $0x4,%esp
  803950:	6a 00                	push   $0x0
  803952:	ff 75 bc             	pushl  -0x44(%ebp)
  803955:	ff 75 b8             	pushl  -0x48(%ebp)
  803958:	e8 06 e9 ff ff       	call   802263 <set_block_data>
  80395d:	83 c4 10             	add    $0x10,%esp
			}
			return va;
  803960:	8b 45 08             	mov    0x8(%ebp),%eax
  803963:	eb 0a                	jmp    80396f <realloc_block_FF+0x719>
		}
	}

	int abo_salah = 1; // abo salah NUMBER 1
  803965:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
	return va;
  80396c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80396f:	c9                   	leave  
  803970:	c3                   	ret    

00803971 <alloc_block_WF>:
/*********************************************************************************************/
//=========================================
// [7] ALLOCATE BLOCK BY WORST FIT:
//=========================================
void *alloc_block_WF(uint32 size)
{
  803971:	55                   	push   %ebp
  803972:	89 e5                	mov    %esp,%ebp
  803974:	83 ec 08             	sub    $0x8,%esp
	panic("alloc_block_WF is not implemented yet");
  803977:	83 ec 04             	sub    $0x4,%esp
  80397a:	68 a0 48 80 00       	push   $0x8048a0
  80397f:	68 58 02 00 00       	push   $0x258
  803984:	68 a9 47 80 00       	push   $0x8047a9
  803989:	e8 2c ca ff ff       	call   8003ba <_panic>

0080398e <alloc_block_NF>:

//=========================================
// [8] ALLOCATE BLOCK BY NEXT FIT:
//=========================================
void *alloc_block_NF(uint32 size)
{
  80398e:	55                   	push   %ebp
  80398f:	89 e5                	mov    %esp,%ebp
  803991:	83 ec 08             	sub    $0x8,%esp
	panic("alloc_block_NF is not implemented yet");
  803994:	83 ec 04             	sub    $0x4,%esp
  803997:	68 c8 48 80 00       	push   $0x8048c8
  80399c:	68 61 02 00 00       	push   $0x261
  8039a1:	68 a9 47 80 00       	push   $0x8047a9
  8039a6:	e8 0f ca ff ff       	call   8003ba <_panic>
  8039ab:	90                   	nop

008039ac <__udivdi3>:
  8039ac:	55                   	push   %ebp
  8039ad:	57                   	push   %edi
  8039ae:	56                   	push   %esi
  8039af:	53                   	push   %ebx
  8039b0:	83 ec 1c             	sub    $0x1c,%esp
  8039b3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8039b7:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8039bb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8039bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8039c3:	89 ca                	mov    %ecx,%edx
  8039c5:	89 f8                	mov    %edi,%eax
  8039c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8039cb:	85 f6                	test   %esi,%esi
  8039cd:	75 2d                	jne    8039fc <__udivdi3+0x50>
  8039cf:	39 cf                	cmp    %ecx,%edi
  8039d1:	77 65                	ja     803a38 <__udivdi3+0x8c>
  8039d3:	89 fd                	mov    %edi,%ebp
  8039d5:	85 ff                	test   %edi,%edi
  8039d7:	75 0b                	jne    8039e4 <__udivdi3+0x38>
  8039d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8039de:	31 d2                	xor    %edx,%edx
  8039e0:	f7 f7                	div    %edi
  8039e2:	89 c5                	mov    %eax,%ebp
  8039e4:	31 d2                	xor    %edx,%edx
  8039e6:	89 c8                	mov    %ecx,%eax
  8039e8:	f7 f5                	div    %ebp
  8039ea:	89 c1                	mov    %eax,%ecx
  8039ec:	89 d8                	mov    %ebx,%eax
  8039ee:	f7 f5                	div    %ebp
  8039f0:	89 cf                	mov    %ecx,%edi
  8039f2:	89 fa                	mov    %edi,%edx
  8039f4:	83 c4 1c             	add    $0x1c,%esp
  8039f7:	5b                   	pop    %ebx
  8039f8:	5e                   	pop    %esi
  8039f9:	5f                   	pop    %edi
  8039fa:	5d                   	pop    %ebp
  8039fb:	c3                   	ret    
  8039fc:	39 ce                	cmp    %ecx,%esi
  8039fe:	77 28                	ja     803a28 <__udivdi3+0x7c>
  803a00:	0f bd fe             	bsr    %esi,%edi
  803a03:	83 f7 1f             	xor    $0x1f,%edi
  803a06:	75 40                	jne    803a48 <__udivdi3+0x9c>
  803a08:	39 ce                	cmp    %ecx,%esi
  803a0a:	72 0a                	jb     803a16 <__udivdi3+0x6a>
  803a0c:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803a10:	0f 87 9e 00 00 00    	ja     803ab4 <__udivdi3+0x108>
  803a16:	b8 01 00 00 00       	mov    $0x1,%eax
  803a1b:	89 fa                	mov    %edi,%edx
  803a1d:	83 c4 1c             	add    $0x1c,%esp
  803a20:	5b                   	pop    %ebx
  803a21:	5e                   	pop    %esi
  803a22:	5f                   	pop    %edi
  803a23:	5d                   	pop    %ebp
  803a24:	c3                   	ret    
  803a25:	8d 76 00             	lea    0x0(%esi),%esi
  803a28:	31 ff                	xor    %edi,%edi
  803a2a:	31 c0                	xor    %eax,%eax
  803a2c:	89 fa                	mov    %edi,%edx
  803a2e:	83 c4 1c             	add    $0x1c,%esp
  803a31:	5b                   	pop    %ebx
  803a32:	5e                   	pop    %esi
  803a33:	5f                   	pop    %edi
  803a34:	5d                   	pop    %ebp
  803a35:	c3                   	ret    
  803a36:	66 90                	xchg   %ax,%ax
  803a38:	89 d8                	mov    %ebx,%eax
  803a3a:	f7 f7                	div    %edi
  803a3c:	31 ff                	xor    %edi,%edi
  803a3e:	89 fa                	mov    %edi,%edx
  803a40:	83 c4 1c             	add    $0x1c,%esp
  803a43:	5b                   	pop    %ebx
  803a44:	5e                   	pop    %esi
  803a45:	5f                   	pop    %edi
  803a46:	5d                   	pop    %ebp
  803a47:	c3                   	ret    
  803a48:	bd 20 00 00 00       	mov    $0x20,%ebp
  803a4d:	89 eb                	mov    %ebp,%ebx
  803a4f:	29 fb                	sub    %edi,%ebx
  803a51:	89 f9                	mov    %edi,%ecx
  803a53:	d3 e6                	shl    %cl,%esi
  803a55:	89 c5                	mov    %eax,%ebp
  803a57:	88 d9                	mov    %bl,%cl
  803a59:	d3 ed                	shr    %cl,%ebp
  803a5b:	89 e9                	mov    %ebp,%ecx
  803a5d:	09 f1                	or     %esi,%ecx
  803a5f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803a63:	89 f9                	mov    %edi,%ecx
  803a65:	d3 e0                	shl    %cl,%eax
  803a67:	89 c5                	mov    %eax,%ebp
  803a69:	89 d6                	mov    %edx,%esi
  803a6b:	88 d9                	mov    %bl,%cl
  803a6d:	d3 ee                	shr    %cl,%esi
  803a6f:	89 f9                	mov    %edi,%ecx
  803a71:	d3 e2                	shl    %cl,%edx
  803a73:	8b 44 24 08          	mov    0x8(%esp),%eax
  803a77:	88 d9                	mov    %bl,%cl
  803a79:	d3 e8                	shr    %cl,%eax
  803a7b:	09 c2                	or     %eax,%edx
  803a7d:	89 d0                	mov    %edx,%eax
  803a7f:	89 f2                	mov    %esi,%edx
  803a81:	f7 74 24 0c          	divl   0xc(%esp)
  803a85:	89 d6                	mov    %edx,%esi
  803a87:	89 c3                	mov    %eax,%ebx
  803a89:	f7 e5                	mul    %ebp
  803a8b:	39 d6                	cmp    %edx,%esi
  803a8d:	72 19                	jb     803aa8 <__udivdi3+0xfc>
  803a8f:	74 0b                	je     803a9c <__udivdi3+0xf0>
  803a91:	89 d8                	mov    %ebx,%eax
  803a93:	31 ff                	xor    %edi,%edi
  803a95:	e9 58 ff ff ff       	jmp    8039f2 <__udivdi3+0x46>
  803a9a:	66 90                	xchg   %ax,%ax
  803a9c:	8b 54 24 08          	mov    0x8(%esp),%edx
  803aa0:	89 f9                	mov    %edi,%ecx
  803aa2:	d3 e2                	shl    %cl,%edx
  803aa4:	39 c2                	cmp    %eax,%edx
  803aa6:	73 e9                	jae    803a91 <__udivdi3+0xe5>
  803aa8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803aab:	31 ff                	xor    %edi,%edi
  803aad:	e9 40 ff ff ff       	jmp    8039f2 <__udivdi3+0x46>
  803ab2:	66 90                	xchg   %ax,%ax
  803ab4:	31 c0                	xor    %eax,%eax
  803ab6:	e9 37 ff ff ff       	jmp    8039f2 <__udivdi3+0x46>
  803abb:	90                   	nop

00803abc <__umoddi3>:
  803abc:	55                   	push   %ebp
  803abd:	57                   	push   %edi
  803abe:	56                   	push   %esi
  803abf:	53                   	push   %ebx
  803ac0:	83 ec 1c             	sub    $0x1c,%esp
  803ac3:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803ac7:	8b 74 24 34          	mov    0x34(%esp),%esi
  803acb:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803acf:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  803ad3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803ad7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803adb:	89 f3                	mov    %esi,%ebx
  803add:	89 fa                	mov    %edi,%edx
  803adf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803ae3:	89 34 24             	mov    %esi,(%esp)
  803ae6:	85 c0                	test   %eax,%eax
  803ae8:	75 1a                	jne    803b04 <__umoddi3+0x48>
  803aea:	39 f7                	cmp    %esi,%edi
  803aec:	0f 86 a2 00 00 00    	jbe    803b94 <__umoddi3+0xd8>
  803af2:	89 c8                	mov    %ecx,%eax
  803af4:	89 f2                	mov    %esi,%edx
  803af6:	f7 f7                	div    %edi
  803af8:	89 d0                	mov    %edx,%eax
  803afa:	31 d2                	xor    %edx,%edx
  803afc:	83 c4 1c             	add    $0x1c,%esp
  803aff:	5b                   	pop    %ebx
  803b00:	5e                   	pop    %esi
  803b01:	5f                   	pop    %edi
  803b02:	5d                   	pop    %ebp
  803b03:	c3                   	ret    
  803b04:	39 f0                	cmp    %esi,%eax
  803b06:	0f 87 ac 00 00 00    	ja     803bb8 <__umoddi3+0xfc>
  803b0c:	0f bd e8             	bsr    %eax,%ebp
  803b0f:	83 f5 1f             	xor    $0x1f,%ebp
  803b12:	0f 84 ac 00 00 00    	je     803bc4 <__umoddi3+0x108>
  803b18:	bf 20 00 00 00       	mov    $0x20,%edi
  803b1d:	29 ef                	sub    %ebp,%edi
  803b1f:	89 fe                	mov    %edi,%esi
  803b21:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803b25:	89 e9                	mov    %ebp,%ecx
  803b27:	d3 e0                	shl    %cl,%eax
  803b29:	89 d7                	mov    %edx,%edi
  803b2b:	89 f1                	mov    %esi,%ecx
  803b2d:	d3 ef                	shr    %cl,%edi
  803b2f:	09 c7                	or     %eax,%edi
  803b31:	89 e9                	mov    %ebp,%ecx
  803b33:	d3 e2                	shl    %cl,%edx
  803b35:	89 14 24             	mov    %edx,(%esp)
  803b38:	89 d8                	mov    %ebx,%eax
  803b3a:	d3 e0                	shl    %cl,%eax
  803b3c:	89 c2                	mov    %eax,%edx
  803b3e:	8b 44 24 08          	mov    0x8(%esp),%eax
  803b42:	d3 e0                	shl    %cl,%eax
  803b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b48:	8b 44 24 08          	mov    0x8(%esp),%eax
  803b4c:	89 f1                	mov    %esi,%ecx
  803b4e:	d3 e8                	shr    %cl,%eax
  803b50:	09 d0                	or     %edx,%eax
  803b52:	d3 eb                	shr    %cl,%ebx
  803b54:	89 da                	mov    %ebx,%edx
  803b56:	f7 f7                	div    %edi
  803b58:	89 d3                	mov    %edx,%ebx
  803b5a:	f7 24 24             	mull   (%esp)
  803b5d:	89 c6                	mov    %eax,%esi
  803b5f:	89 d1                	mov    %edx,%ecx
  803b61:	39 d3                	cmp    %edx,%ebx
  803b63:	0f 82 87 00 00 00    	jb     803bf0 <__umoddi3+0x134>
  803b69:	0f 84 91 00 00 00    	je     803c00 <__umoddi3+0x144>
  803b6f:	8b 54 24 04          	mov    0x4(%esp),%edx
  803b73:	29 f2                	sub    %esi,%edx
  803b75:	19 cb                	sbb    %ecx,%ebx
  803b77:	89 d8                	mov    %ebx,%eax
  803b79:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  803b7d:	d3 e0                	shl    %cl,%eax
  803b7f:	89 e9                	mov    %ebp,%ecx
  803b81:	d3 ea                	shr    %cl,%edx
  803b83:	09 d0                	or     %edx,%eax
  803b85:	89 e9                	mov    %ebp,%ecx
  803b87:	d3 eb                	shr    %cl,%ebx
  803b89:	89 da                	mov    %ebx,%edx
  803b8b:	83 c4 1c             	add    $0x1c,%esp
  803b8e:	5b                   	pop    %ebx
  803b8f:	5e                   	pop    %esi
  803b90:	5f                   	pop    %edi
  803b91:	5d                   	pop    %ebp
  803b92:	c3                   	ret    
  803b93:	90                   	nop
  803b94:	89 fd                	mov    %edi,%ebp
  803b96:	85 ff                	test   %edi,%edi
  803b98:	75 0b                	jne    803ba5 <__umoddi3+0xe9>
  803b9a:	b8 01 00 00 00       	mov    $0x1,%eax
  803b9f:	31 d2                	xor    %edx,%edx
  803ba1:	f7 f7                	div    %edi
  803ba3:	89 c5                	mov    %eax,%ebp
  803ba5:	89 f0                	mov    %esi,%eax
  803ba7:	31 d2                	xor    %edx,%edx
  803ba9:	f7 f5                	div    %ebp
  803bab:	89 c8                	mov    %ecx,%eax
  803bad:	f7 f5                	div    %ebp
  803baf:	89 d0                	mov    %edx,%eax
  803bb1:	e9 44 ff ff ff       	jmp    803afa <__umoddi3+0x3e>
  803bb6:	66 90                	xchg   %ax,%ax
  803bb8:	89 c8                	mov    %ecx,%eax
  803bba:	89 f2                	mov    %esi,%edx
  803bbc:	83 c4 1c             	add    $0x1c,%esp
  803bbf:	5b                   	pop    %ebx
  803bc0:	5e                   	pop    %esi
  803bc1:	5f                   	pop    %edi
  803bc2:	5d                   	pop    %ebp
  803bc3:	c3                   	ret    
  803bc4:	3b 04 24             	cmp    (%esp),%eax
  803bc7:	72 06                	jb     803bcf <__umoddi3+0x113>
  803bc9:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  803bcd:	77 0f                	ja     803bde <__umoddi3+0x122>
  803bcf:	89 f2                	mov    %esi,%edx
  803bd1:	29 f9                	sub    %edi,%ecx
  803bd3:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  803bd7:	89 14 24             	mov    %edx,(%esp)
  803bda:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803bde:	8b 44 24 04          	mov    0x4(%esp),%eax
  803be2:	8b 14 24             	mov    (%esp),%edx
  803be5:	83 c4 1c             	add    $0x1c,%esp
  803be8:	5b                   	pop    %ebx
  803be9:	5e                   	pop    %esi
  803bea:	5f                   	pop    %edi
  803beb:	5d                   	pop    %ebp
  803bec:	c3                   	ret    
  803bed:	8d 76 00             	lea    0x0(%esi),%esi
  803bf0:	2b 04 24             	sub    (%esp),%eax
  803bf3:	19 fa                	sbb    %edi,%edx
  803bf5:	89 d1                	mov    %edx,%ecx
  803bf7:	89 c6                	mov    %eax,%esi
  803bf9:	e9 71 ff ff ff       	jmp    803b6f <__umoddi3+0xb3>
  803bfe:	66 90                	xchg   %ax,%ax
  803c00:	39 44 24 04          	cmp    %eax,0x4(%esp)
  803c04:	72 ea                	jb     803bf0 <__umoddi3+0x134>
  803c06:	89 d9                	mov    %ebx,%ecx
  803c08:	e9 62 ff ff ff       	jmp    803b6f <__umoddi3+0xb3>
