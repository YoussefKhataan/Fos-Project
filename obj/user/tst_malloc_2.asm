
obj/user/tst_malloc_2:     file format elf32-i386


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
  800031:	e8 8b 05 00 00       	call   8005c1 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <check_block>:
#define USER_TST_UTILITIES_H_
#include <inc/types.h>
#include <inc/stdio.h>

int check_block(void* va, void* expectedVA, uint32 expectedSize, uint8 expectedFlag)
{
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 28             	sub    $0x28,%esp
  80003e:	8b 45 14             	mov    0x14(%ebp),%eax
  800041:	88 45 e4             	mov    %al,-0x1c(%ebp)
	//Check returned va
	if(va != expectedVA)
  800044:	8b 45 08             	mov    0x8(%ebp),%eax
  800047:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80004a:	74 1d                	je     800069 <check_block+0x31>
	{
		cprintf("wrong block address. Expected %x, Actual %x\n", expectedVA, va);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	ff 75 08             	pushl  0x8(%ebp)
  800052:	ff 75 0c             	pushl  0xc(%ebp)
  800055:	68 60 3f 80 00       	push   $0x803f60
  80005a:	e8 5e 09 00 00       	call   8009bd <cprintf>
  80005f:	83 c4 10             	add    $0x10,%esp
		return 0;
  800062:	b8 00 00 00 00       	mov    $0x0,%eax
  800067:	eb 55                	jmp    8000be <check_block+0x86>
	}
	//Check header & footer
	uint32 header = *((uint32*)va-1);
  800069:	8b 45 08             	mov    0x8(%ebp),%eax
  80006c:	8b 40 fc             	mov    -0x4(%eax),%eax
  80006f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32 footer = *((uint32*)(va + expectedSize - 8));
  800072:	8b 45 10             	mov    0x10(%ebp),%eax
  800075:	8d 50 f8             	lea    -0x8(%eax),%edx
  800078:	8b 45 08             	mov    0x8(%ebp),%eax
  80007b:	01 d0                	add    %edx,%eax
  80007d:	8b 00                	mov    (%eax),%eax
  80007f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 expectedData = expectedSize | expectedFlag ;
  800082:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
  800086:	0b 45 10             	or     0x10(%ebp),%eax
  800089:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(header != expectedData || footer != expectedData)
  80008c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80008f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800092:	75 08                	jne    80009c <check_block+0x64>
  800094:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800097:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  80009a:	74 1d                	je     8000b9 <check_block+0x81>
	{
		cprintf("wrong header/footer data. Expected %d, Actual H:%d F:%d\n", expectedData, header, footer);
  80009c:	ff 75 f0             	pushl  -0x10(%ebp)
  80009f:	ff 75 f4             	pushl  -0xc(%ebp)
  8000a2:	ff 75 ec             	pushl  -0x14(%ebp)
  8000a5:	68 90 3f 80 00       	push   $0x803f90
  8000aa:	e8 0e 09 00 00       	call   8009bd <cprintf>
  8000af:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	eb 05                	jmp    8000be <check_block+0x86>
	}
	return 1;
  8000b9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <_main>:
short* startVAs[numOfAllocs*allocCntPerSize+1] ;
short* midVAs[numOfAllocs*allocCntPerSize+1] ;
short* endVAs[numOfAllocs*allocCntPerSize+1] ;

void _main(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	81 ec a4 00 00 00    	sub    $0xa4,%esp

	//cprintf("1\n");
	//Initial test to ensure it works on "PLACEMENT" not "REPLACEMENT"
#if USE_KHEAP
	{
		if (LIST_SIZE(&(myEnv->page_WS_list)) >= myEnv->page_WS_max_size)
  8000ca:	a1 20 50 80 00       	mov    0x805020,%eax
  8000cf:	8b 90 a0 00 00 00    	mov    0xa0(%eax),%edx
  8000d5:	a1 20 50 80 00       	mov    0x805020,%eax
  8000da:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
  8000e0:	39 c2                	cmp    %eax,%edx
  8000e2:	72 14                	jb     8000f8 <_main+0x38>
			panic("Please increase the WS size");
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	68 c9 3f 80 00       	push   $0x803fc9
  8000ec:	6a 25                	push   $0x25
  8000ee:	68 e5 3f 80 00       	push   $0x803fe5
  8000f3:	e8 08 06 00 00       	call   800700 <_panic>
#endif

	/*=================================================*/


	int eval = 0;
  8000f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	bool is_correct = 1;
  8000ff:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	int targetAllocatedSpace = 3*Mega;
  800106:	c7 45 c8 00 00 30 00 	movl   $0x300000,-0x38(%ebp)

	void * va ;
	int idx = 0;
  80010d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	bool chk;
	int usedDiskPages = sys_pf_calculate_allocated_pages() ;
  800114:	e8 81 1c 00 00       	call   801d9a <sys_pf_calculate_allocated_pages>
  800119:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	int freeFrames = sys_calculate_free_frames() ;
  80011c:	e8 2e 1c 00 00       	call   801d4f <sys_calculate_free_frames>
  800121:	89 45 c0             	mov    %eax,-0x40(%ebp)
	void* expectedVA;
	uint32 actualSize, expectedSize, curTotalSize,roundedTotalSize ;
	//====================================================================//
	/*INITIAL ALLOC Scenario 1: Try to allocate set of blocks with different sizes*/
	cprintf("%~\n1: [BLOCK ALLOCATOR] allocate set of blocks with different sizes [all should fit] [30%]\n") ;
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	68 fc 3f 80 00       	push   $0x803ffc
  80012c:	e8 8c 08 00 00       	call   8009bd <cprintf>
  800131:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  800134:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		void* curVA = (void*) USER_HEAP_START + sizeof(int) /*BEG Block*/ ;
  80013b:	c7 45 e0 04 00 00 80 	movl   $0x80000004,-0x20(%ebp)
		curTotalSize = sizeof(int);
  800142:	c7 45 e4 04 00 00 00 	movl   $0x4,-0x1c(%ebp)
		for (int i = 0; i < numOfAllocs; ++i)
  800149:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800150:	e9 9e 01 00 00       	jmp    8002f3 <_main+0x233>
		{
			for (int j = 0; j < allocCntPerSize; ++j)
  800155:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80015c:	e9 82 01 00 00       	jmp    8002e3 <_main+0x223>
			{
				actualSize = allocSizes[i] - sizeOfMetaData;
  800161:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800164:	8b 04 85 00 50 80 00 	mov    0x805000(,%eax,4),%eax
  80016b:	83 e8 08             	sub    $0x8,%eax
  80016e:	89 45 bc             	mov    %eax,-0x44(%ebp)
				va = startVAs[idx] = malloc(actualSize);
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	ff 75 bc             	pushl  -0x44(%ebp)
  800177:	e8 f1 15 00 00       	call   80176d <malloc>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	89 c2                	mov    %eax,%edx
  800181:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800184:	89 14 85 60 50 80 00 	mov    %edx,0x805060(,%eax,4)
  80018b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80018e:	8b 04 85 60 50 80 00 	mov    0x805060(,%eax,4),%eax
  800195:	89 45 b8             	mov    %eax,-0x48(%ebp)
				midVAs[idx] = va + actualSize/2 ;
  800198:	8b 45 bc             	mov    -0x44(%ebp),%eax
  80019b:	d1 e8                	shr    %eax
  80019d:	89 c2                	mov    %eax,%edx
  80019f:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8001a2:	01 c2                	add    %eax,%edx
  8001a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001a7:	89 14 85 60 7c 80 00 	mov    %edx,0x807c60(,%eax,4)
				endVAs[idx] = va + actualSize - sizeof(short);
  8001ae:	8b 45 bc             	mov    -0x44(%ebp),%eax
  8001b1:	8d 50 fe             	lea    -0x2(%eax),%edx
  8001b4:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8001b7:	01 c2                	add    %eax,%edx
  8001b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8001bc:	89 14 85 60 66 80 00 	mov    %edx,0x806660(,%eax,4)
				//Check returned va
				expectedVA = (curVA + sizeOfMetaData/2);
  8001c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c6:	83 c0 04             	add    $0x4,%eax
  8001c9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
				expectedSize = allocSizes[i];
  8001cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001cf:	8b 04 85 00 50 80 00 	mov    0x805000(,%eax,4),%eax
  8001d6:	89 45 e8             	mov    %eax,-0x18(%ebp)
				curTotalSize += allocSizes[i] ;
  8001d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001dc:	8b 04 85 00 50 80 00 	mov    0x805000(,%eax,4),%eax
  8001e3:	01 45 e4             	add    %eax,-0x1c(%ebp)
				//============================================================
				//Check if the remaining area doesn't fit the DynAllocBlock,
				//so update the curVA & curTotalSize to skip this area
				roundedTotalSize = ROUNDUP(curTotalSize, PAGE_SIZE);
  8001e6:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  8001ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8001f0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8001f3:	01 d0                	add    %edx,%eax
  8001f5:	48                   	dec    %eax
  8001f6:	89 45 ac             	mov    %eax,-0x54(%ebp)
  8001f9:	8b 45 ac             	mov    -0x54(%ebp),%eax
  8001fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800201:	f7 75 b0             	divl   -0x50(%ebp)
  800204:	8b 45 ac             	mov    -0x54(%ebp),%eax
  800207:	29 d0                	sub    %edx,%eax
  800209:	89 45 a8             	mov    %eax,-0x58(%ebp)
				int diff = (roundedTotalSize - curTotalSize) ;
  80020c:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80020f:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  800212:	89 45 a4             	mov    %eax,-0x5c(%ebp)
				if (diff > 0 && diff < (DYN_ALLOC_MIN_BLOCK_SIZE + sizeOfMetaData))
  800215:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  800219:	7e 48                	jle    800263 <_main+0x1a3>
  80021b:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
  80021f:	7f 42                	jg     800263 <_main+0x1a3>
				{
//					cprintf("%~\n FRAGMENTATION: curVA = %x diff = %d\n", curVA, diff);
//					cprintf("%~\n Allocated block @ %x with size = %d\n", va, get_block_size(va));

					curVA = ROUNDUP(curVA, PAGE_SIZE)- sizeof(int) /*next alloc will start at END Block (after sbrk)*/;
  800221:	c7 45 a0 00 10 00 00 	movl   $0x1000,-0x60(%ebp)
  800228:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80022b:	8b 45 a0             	mov    -0x60(%ebp),%eax
  80022e:	01 d0                	add    %edx,%eax
  800230:	48                   	dec    %eax
  800231:	89 45 9c             	mov    %eax,-0x64(%ebp)
  800234:	8b 45 9c             	mov    -0x64(%ebp),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
  80023c:	f7 75 a0             	divl   -0x60(%ebp)
  80023f:	8b 45 9c             	mov    -0x64(%ebp),%eax
  800242:	29 d0                	sub    %edx,%eax
  800244:	83 e8 04             	sub    $0x4,%eax
  800247:	89 45 e0             	mov    %eax,-0x20(%ebp)
					curTotalSize = roundedTotalSize - sizeof(int) /*exclude END Block*/;
  80024a:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80024d:	83 e8 04             	sub    $0x4,%eax
  800250:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					expectedSize += diff - sizeof(int) /*exclude END Block*/;
  800253:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  800256:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800259:	01 d0                	add    %edx,%eax
  80025b:	83 e8 04             	sub    $0x4,%eax
  80025e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  800261:	eb 0d                	jmp    800270 <_main+0x1b0>
				}
				else
				{
					curVA += allocSizes[i] ;
  800263:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800266:	8b 04 85 00 50 80 00 	mov    0x805000(,%eax,4),%eax
  80026d:	01 45 e0             	add    %eax,-0x20(%ebp)
				}
				//============================================================
				if (is_correct)
  800270:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800274:	74 37                	je     8002ad <_main+0x1ed>
				{
					if (check_block(va, expectedVA, expectedSize, 1) == 0)
  800276:	6a 01                	push   $0x1
  800278:	ff 75 e8             	pushl  -0x18(%ebp)
  80027b:	ff 75 b4             	pushl  -0x4c(%ebp)
  80027e:	ff 75 b8             	pushl  -0x48(%ebp)
  800281:	e8 b2 fd ff ff       	call   800038 <check_block>
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	85 c0                	test   %eax,%eax
  80028b:	75 20                	jne    8002ad <_main+0x1ed>
					{
						if (is_correct)
  80028d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800291:	74 1a                	je     8002ad <_main+0x1ed>
						{
							is_correct = 0;
  800293:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
							cprintf("alloc_block_xx #1.%d: WRONG ALLOC\n", idx);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	ff 75 ec             	pushl  -0x14(%ebp)
  8002a0:	68 58 40 80 00       	push   $0x804058
  8002a5:	e8 13 07 00 00       	call   8009bd <cprintf>
  8002aa:	83 c4 10             	add    $0x10,%esp
						}
					}
				}
				*(startVAs[idx]) = idx ;
  8002ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002b0:	8b 14 85 60 50 80 00 	mov    0x805060(,%eax,4),%edx
  8002b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002ba:	66 89 02             	mov    %ax,(%edx)
				*(midVAs[idx]) = idx ;
  8002bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002c0:	8b 14 85 60 7c 80 00 	mov    0x807c60(,%eax,4),%edx
  8002c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002ca:	66 89 02             	mov    %ax,(%edx)
				*(endVAs[idx]) = idx ;
  8002cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002d0:	8b 14 85 60 66 80 00 	mov    0x806660(,%eax,4),%edx
  8002d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8002da:	66 89 02             	mov    %ax,(%edx)
				idx++;
  8002dd:	ff 45 ec             	incl   -0x14(%ebp)
		is_correct = 1;
		void* curVA = (void*) USER_HEAP_START + sizeof(int) /*BEG Block*/ ;
		curTotalSize = sizeof(int);
		for (int i = 0; i < numOfAllocs; ++i)
		{
			for (int j = 0; j < allocCntPerSize; ++j)
  8002e0:	ff 45 d8             	incl   -0x28(%ebp)
  8002e3:	81 7d d8 c7 00 00 00 	cmpl   $0xc7,-0x28(%ebp)
  8002ea:	0f 8e 71 fe ff ff    	jle    800161 <_main+0xa1>
	cprintf("%~\n1: [BLOCK ALLOCATOR] allocate set of blocks with different sizes [all should fit] [30%]\n") ;
	{
		is_correct = 1;
		void* curVA = (void*) USER_HEAP_START + sizeof(int) /*BEG Block*/ ;
		curTotalSize = sizeof(int);
		for (int i = 0; i < numOfAllocs; ++i)
  8002f0:	ff 45 dc             	incl   -0x24(%ebp)
  8002f3:	83 7d dc 06          	cmpl   $0x6,-0x24(%ebp)
  8002f7:	0f 8e 58 fe ff ff    	jle    800155 <_main+0x95>
				idx++;
			}
			//if (is_correct == 0)
			//break;
		}
		if (is_correct)
  8002fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800301:	74 04                	je     800307 <_main+0x247>
		{
			eval += 30;
  800303:	83 45 f4 1e          	addl   $0x1e,-0xc(%ebp)
		}
	}

	//====================================================================//
	/*INITIAL ALLOC Scenario 2: Check stored data inside each allocated block*/
	cprintf("%~\n2: Check stored data inside each allocated block [30%]\n") ;
  800307:	83 ec 0c             	sub    $0xc,%esp
  80030a:	68 7c 40 80 00       	push   $0x80407c
  80030f:	e8 a9 06 00 00       	call   8009bd <cprintf>
  800314:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  800317:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

		for (int i = 0; i < idx; ++i)
  80031e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800325:	eb 5b                	jmp    800382 <_main+0x2c2>
		{
			if (*(startVAs[i]) != i || *(midVAs[i]) != i ||	*(endVAs[i]) != i)
  800327:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80032a:	8b 04 85 60 50 80 00 	mov    0x805060(,%eax,4),%eax
  800331:	66 8b 00             	mov    (%eax),%ax
  800334:	98                   	cwtl   
  800335:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  800338:	75 26                	jne    800360 <_main+0x2a0>
  80033a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80033d:	8b 04 85 60 7c 80 00 	mov    0x807c60(,%eax,4),%eax
  800344:	66 8b 00             	mov    (%eax),%ax
  800347:	98                   	cwtl   
  800348:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  80034b:	75 13                	jne    800360 <_main+0x2a0>
  80034d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800350:	8b 04 85 60 66 80 00 	mov    0x806660(,%eax,4),%eax
  800357:	66 8b 00             	mov    (%eax),%ax
  80035a:	98                   	cwtl   
  80035b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  80035e:	74 1f                	je     80037f <_main+0x2bf>
			{
				is_correct = 0;
  800360:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
				cprintf("alloc_block_xx #2.%d: WRONG! content of the block is not correct. Expected %d\n",i, i);
  800367:	83 ec 04             	sub    $0x4,%esp
  80036a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80036d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800370:	68 b8 40 80 00       	push   $0x8040b8
  800375:	e8 43 06 00 00       	call   8009bd <cprintf>
  80037a:	83 c4 10             	add    $0x10,%esp
				break;
  80037d:	eb 0b                	jmp    80038a <_main+0x2ca>
	/*INITIAL ALLOC Scenario 2: Check stored data inside each allocated block*/
	cprintf("%~\n2: Check stored data inside each allocated block [30%]\n") ;
	{
		is_correct = 1;

		for (int i = 0; i < idx; ++i)
  80037f:	ff 45 d4             	incl   -0x2c(%ebp)
  800382:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800385:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800388:	7c 9d                	jl     800327 <_main+0x267>
				is_correct = 0;
				cprintf("alloc_block_xx #2.%d: WRONG! content of the block is not correct. Expected %d\n",i, i);
				break;
			}
		}
		if (is_correct)
  80038a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80038e:	74 04                	je     800394 <_main+0x2d4>
		{
			eval += 30;
  800390:	83 45 f4 1e          	addl   $0x1e,-0xc(%ebp)
		}
	}

	/*Check page file*/
	cprintf("%~\n3: Check page file size (nothing should be allocated) [10%]\n") ;
  800394:	83 ec 0c             	sub    $0xc,%esp
  800397:	68 08 41 80 00       	push   $0x804108
  80039c:	e8 1c 06 00 00       	call   8009bd <cprintf>
  8003a1:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  8003a4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		if ((sys_pf_calculate_allocated_pages() - usedDiskPages) != 0)
  8003ab:	e8 ea 19 00 00       	call   801d9a <sys_pf_calculate_allocated_pages>
  8003b0:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
  8003b3:	74 17                	je     8003cc <_main+0x30c>
		{
			cprintf("page(s) are allocated in PageFile while not expected to\n");
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	68 48 41 80 00       	push   $0x804148
  8003bd:	e8 fb 05 00 00       	call   8009bd <cprintf>
  8003c2:	83 c4 10             	add    $0x10,%esp
			is_correct = 0;
  8003c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		}
		if (is_correct)
  8003cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8003d0:	74 04                	je     8003d6 <_main+0x316>
		{
			eval += 10;
  8003d2:	83 45 f4 0a          	addl   $0xa,-0xc(%ebp)
		}
	}

	uint32 expectedAllocatedSize = 0;
  8003d6:	c7 45 98 00 00 00 00 	movl   $0x0,-0x68(%ebp)
//	for (int i = 0; i < numOfAllocs; ++i)
//	{
//		expectedAllocatedSize += allocCntPerSize * allocSizes[i] ;
//	}
//	expectedAllocatedSize = ROUNDUP(expectedAllocatedSize, PAGE_SIZE);
	expectedAllocatedSize = ROUNDUP(curTotalSize, PAGE_SIZE);
  8003dd:	c7 45 94 00 10 00 00 	movl   $0x1000,-0x6c(%ebp)
  8003e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e7:	8b 45 94             	mov    -0x6c(%ebp),%eax
  8003ea:	01 d0                	add    %edx,%eax
  8003ec:	48                   	dec    %eax
  8003ed:	89 45 90             	mov    %eax,-0x70(%ebp)
  8003f0:	8b 45 90             	mov    -0x70(%ebp),%eax
  8003f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f8:	f7 75 94             	divl   -0x6c(%ebp)
  8003fb:	8b 45 90             	mov    -0x70(%ebp),%eax
  8003fe:	29 d0                	sub    %edx,%eax
  800400:	89 45 98             	mov    %eax,-0x68(%ebp)
	uint32 expectedAllocNumOfPages = expectedAllocatedSize / PAGE_SIZE; 				/*# pages*/
  800403:	8b 45 98             	mov    -0x68(%ebp),%eax
  800406:	c1 e8 0c             	shr    $0xc,%eax
  800409:	89 45 8c             	mov    %eax,-0x74(%ebp)
	uint32 expectedAllocNumOfTables = ROUNDUP(expectedAllocatedSize, PTSIZE) / PTSIZE; 	/*# tables*/
  80040c:	c7 45 88 00 00 40 00 	movl   $0x400000,-0x78(%ebp)
  800413:	8b 55 98             	mov    -0x68(%ebp),%edx
  800416:	8b 45 88             	mov    -0x78(%ebp),%eax
  800419:	01 d0                	add    %edx,%eax
  80041b:	48                   	dec    %eax
  80041c:	89 45 84             	mov    %eax,-0x7c(%ebp)
  80041f:	8b 45 84             	mov    -0x7c(%ebp),%eax
  800422:	ba 00 00 00 00       	mov    $0x0,%edx
  800427:	f7 75 88             	divl   -0x78(%ebp)
  80042a:	8b 45 84             	mov    -0x7c(%ebp),%eax
  80042d:	29 d0                	sub    %edx,%eax
  80042f:	c1 e8 16             	shr    $0x16,%eax
  800432:	89 45 80             	mov    %eax,-0x80(%ebp)
	uint32 expectedAllocNumOfPagesForWS = ROUNDUP(expectedAllocNumOfPages * (sizeof(struct WorkingSetElement) + sizeOfMetaData), PAGE_SIZE) / PAGE_SIZE; 				/*# pages*/
  800435:	c7 85 7c ff ff ff 00 	movl   $0x1000,-0x84(%ebp)
  80043c:	10 00 00 
  80043f:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800442:	c1 e0 05             	shl    $0x5,%eax
  800445:	89 c2                	mov    %eax,%edx
  800447:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  80044d:	01 d0                	add    %edx,%eax
  80044f:	48                   	dec    %eax
  800450:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  800456:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  80045c:	ba 00 00 00 00       	mov    $0x0,%edx
  800461:	f7 b5 7c ff ff ff    	divl   -0x84(%ebp)
  800467:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  80046d:	29 d0                	sub    %edx,%eax
  80046f:	c1 e8 0c             	shr    $0xc,%eax
  800472:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)

	/*Check memory allocation*/
	cprintf("%~\n4: Check total allocation in RAM (for pages, tables & WS) [10%]\n") ;
  800478:	83 ec 0c             	sub    $0xc,%esp
  80047b:	68 84 41 80 00       	push   $0x804184
  800480:	e8 38 05 00 00       	call   8009bd <cprintf>
  800485:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  800488:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		uint32 expected = expectedAllocNumOfPages + expectedAllocNumOfTables  + expectedAllocNumOfPagesForWS;
  80048f:	8b 55 8c             	mov    -0x74(%ebp),%edx
  800492:	8b 45 80             	mov    -0x80(%ebp),%eax
  800495:	01 c2                	add    %eax,%edx
  800497:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  80049d:	01 d0                	add    %edx,%eax
  80049f:	89 85 70 ff ff ff    	mov    %eax,-0x90(%ebp)
		uint32 actual = (freeFrames - sys_calculate_free_frames()) ;
  8004a5:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004a8:	e8 a2 18 00 00       	call   801d4f <sys_calculate_free_frames>
  8004ad:	29 c3                	sub    %eax,%ebx
  8004af:	89 d8                	mov    %ebx,%eax
  8004b1:	89 85 6c ff ff ff    	mov    %eax,-0x94(%ebp)
		if (expected != actual)
  8004b7:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
  8004bd:	3b 85 6c ff ff ff    	cmp    -0x94(%ebp),%eax
  8004c3:	74 23                	je     8004e8 <_main+0x428>
		{
			cprintf("number of allocated pages in MEMORY not correct. Expected %d, Actual %d\n", expected, actual);
  8004c5:	83 ec 04             	sub    $0x4,%esp
  8004c8:	ff b5 6c ff ff ff    	pushl  -0x94(%ebp)
  8004ce:	ff b5 70 ff ff ff    	pushl  -0x90(%ebp)
  8004d4:	68 c8 41 80 00       	push   $0x8041c8
  8004d9:	e8 df 04 00 00       	call   8009bd <cprintf>
  8004de:	83 c4 10             	add    $0x10,%esp
			is_correct = 0;
  8004e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		}
		if (is_correct)
  8004e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8004ec:	74 04                	je     8004f2 <_main+0x432>
		{
			eval += 10;
  8004ee:	83 45 f4 0a          	addl   $0xa,-0xc(%ebp)
		}
	}

	/*Check WS elements*/
	cprintf("%~\n5: Check content of WS [20%]\n") ;
  8004f2:	83 ec 0c             	sub    $0xc,%esp
  8004f5:	68 14 42 80 00       	push   $0x804214
  8004fa:	e8 be 04 00 00       	call   8009bd <cprintf>
  8004ff:	83 c4 10             	add    $0x10,%esp
	{
		is_correct = 1;
  800502:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
		uint32* expectedVAs = malloc(expectedAllocNumOfPages*sizeof(int));
  800509:	8b 45 8c             	mov    -0x74(%ebp),%eax
  80050c:	c1 e0 02             	shl    $0x2,%eax
  80050f:	83 ec 0c             	sub    $0xc,%esp
  800512:	50                   	push   %eax
  800513:	e8 55 12 00 00       	call   80176d <malloc>
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	89 85 68 ff ff ff    	mov    %eax,-0x98(%ebp)
		int i = 0;
  800521:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		for (uint32 va = USER_HEAP_START; va < USER_HEAP_START + expectedAllocatedSize; va+=PAGE_SIZE)
  800528:	c7 45 cc 00 00 00 80 	movl   $0x80000000,-0x34(%ebp)
  80052f:	eb 24                	jmp    800555 <_main+0x495>
		{
			expectedVAs[i++] = va;
  800531:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800534:	8d 50 01             	lea    0x1(%eax),%edx
  800537:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80053a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800541:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  800547:	01 c2                	add    %eax,%edx
  800549:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80054c:	89 02                	mov    %eax,(%edx)
	cprintf("%~\n5: Check content of WS [20%]\n") ;
	{
		is_correct = 1;
		uint32* expectedVAs = malloc(expectedAllocNumOfPages*sizeof(int));
		int i = 0;
		for (uint32 va = USER_HEAP_START; va < USER_HEAP_START + expectedAllocatedSize; va+=PAGE_SIZE)
  80054e:	81 45 cc 00 10 00 00 	addl   $0x1000,-0x34(%ebp)
  800555:	8b 45 98             	mov    -0x68(%ebp),%eax
  800558:	05 00 00 00 80       	add    $0x80000000,%eax
  80055d:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800560:	77 cf                	ja     800531 <_main+0x471>
		{
			expectedVAs[i++] = va;
		}
		chk = sys_check_WS_list(expectedVAs, expectedAllocNumOfPages, 0, 2);
  800562:	8b 45 8c             	mov    -0x74(%ebp),%eax
  800565:	6a 02                	push   $0x2
  800567:	6a 00                	push   $0x0
  800569:	50                   	push   %eax
  80056a:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800570:	e8 35 1c 00 00       	call   8021aa <sys_check_WS_list>
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	89 85 64 ff ff ff    	mov    %eax,-0x9c(%ebp)
		if (chk != 1)
  80057e:	83 bd 64 ff ff ff 01 	cmpl   $0x1,-0x9c(%ebp)
  800585:	74 17                	je     80059e <_main+0x4de>
		{
			cprintf("malloc: page is not added to WS\n");
  800587:	83 ec 0c             	sub    $0xc,%esp
  80058a:	68 38 42 80 00       	push   $0x804238
  80058f:	e8 29 04 00 00       	call   8009bd <cprintf>
  800594:	83 c4 10             	add    $0x10,%esp
			is_correct = 0;
  800597:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		}
		if (is_correct)
  80059e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8005a2:	74 04                	je     8005a8 <_main+0x4e8>
		{
			eval += 20;
  8005a4:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
		}
	}

	cprintf("%~\ntest malloc (2) [DYNAMIC ALLOCATOR] is finished. Evaluation = %d%\n", eval);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8005ae:	68 5c 42 80 00       	push   $0x80425c
  8005b3:	e8 05 04 00 00       	call   8009bd <cprintf>
  8005b8:	83 c4 10             	add    $0x10,%esp

	return;
  8005bb:	90                   	nop
}
  8005bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005bf:	c9                   	leave  
  8005c0:	c3                   	ret    

008005c1 <libmain>:

volatile struct Env *myEnv = NULL;
volatile char *binaryname = "(PROGRAM NAME UNKNOWN)";
void
libmain(int argc, char **argv)
{
  8005c1:	55                   	push   %ebp
  8005c2:	89 e5                	mov    %esp,%ebp
  8005c4:	83 ec 18             	sub    $0x18,%esp
	int envIndex = sys_getenvindex();
  8005c7:	e8 4c 19 00 00       	call   801f18 <sys_getenvindex>
  8005cc:	89 45 f4             	mov    %eax,-0xc(%ebp)

	myEnv = &(envs[envIndex]);
  8005cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005d2:	89 d0                	mov    %edx,%eax
  8005d4:	c1 e0 03             	shl    $0x3,%eax
  8005d7:	01 d0                	add    %edx,%eax
  8005d9:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  8005e0:	01 c8                	add    %ecx,%eax
  8005e2:	01 c0                	add    %eax,%eax
  8005e4:	01 d0                	add    %edx,%eax
  8005e6:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
  8005ed:	01 c8                	add    %ecx,%eax
  8005ef:	01 d0                	add    %edx,%eax
  8005f1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005f6:	a3 20 50 80 00       	mov    %eax,0x805020

	//SET THE PROGRAM NAME
	if (myEnv->prog_name[0] != '\0')
  8005fb:	a1 20 50 80 00       	mov    0x805020,%eax
  800600:	8a 40 20             	mov    0x20(%eax),%al
  800603:	84 c0                	test   %al,%al
  800605:	74 0d                	je     800614 <libmain+0x53>
		binaryname = myEnv->prog_name;
  800607:	a1 20 50 80 00       	mov    0x805020,%eax
  80060c:	83 c0 20             	add    $0x20,%eax
  80060f:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// set env to point at our env structure in envs[].
	// env = envs;

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800614:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800618:	7e 0a                	jle    800624 <libmain+0x63>
		binaryname = argv[0];
  80061a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	_main(argc, argv);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	ff 75 0c             	pushl  0xc(%ebp)
  80062a:	ff 75 08             	pushl  0x8(%ebp)
  80062d:	e8 8e fa ff ff       	call   8000c0 <_main>
  800632:	83 c4 10             	add    $0x10,%esp



	//	sys_lock_cons();
	sys_lock_cons();
  800635:	e8 62 16 00 00       	call   801c9c <sys_lock_cons>
	{
		cprintf("**************************************\n");
  80063a:	83 ec 0c             	sub    $0xc,%esp
  80063d:	68 bc 42 80 00       	push   $0x8042bc
  800642:	e8 76 03 00 00       	call   8009bd <cprintf>
  800647:	83 c4 10             	add    $0x10,%esp
		cprintf("Num of PAGE faults = %d, modif = %d\n", myEnv->pageFaultsCounter, myEnv->nModifiedPages);
  80064a:	a1 20 50 80 00       	mov    0x805020,%eax
  80064f:	8b 90 a0 05 00 00    	mov    0x5a0(%eax),%edx
  800655:	a1 20 50 80 00       	mov    0x805020,%eax
  80065a:	8b 80 90 05 00 00    	mov    0x590(%eax),%eax
  800660:	83 ec 04             	sub    $0x4,%esp
  800663:	52                   	push   %edx
  800664:	50                   	push   %eax
  800665:	68 e4 42 80 00       	push   $0x8042e4
  80066a:	e8 4e 03 00 00       	call   8009bd <cprintf>
  80066f:	83 c4 10             	add    $0x10,%esp
		cprintf("# PAGE IN (from disk) = %d, # PAGE OUT (on disk) = %d, # NEW PAGE ADDED (on disk) = %d\n", myEnv->nPageIn, myEnv->nPageOut,myEnv->nNewPageAdded);
  800672:	a1 20 50 80 00       	mov    0x805020,%eax
  800677:	8b 88 b4 05 00 00    	mov    0x5b4(%eax),%ecx
  80067d:	a1 20 50 80 00       	mov    0x805020,%eax
  800682:	8b 90 b0 05 00 00    	mov    0x5b0(%eax),%edx
  800688:	a1 20 50 80 00       	mov    0x805020,%eax
  80068d:	8b 80 ac 05 00 00    	mov    0x5ac(%eax),%eax
  800693:	51                   	push   %ecx
  800694:	52                   	push   %edx
  800695:	50                   	push   %eax
  800696:	68 0c 43 80 00       	push   $0x80430c
  80069b:	e8 1d 03 00 00       	call   8009bd <cprintf>
  8006a0:	83 c4 10             	add    $0x10,%esp
		//cprintf("Num of freeing scarce memory = %d, freeing full working set = %d\n", myEnv->freeingScarceMemCounter, myEnv->freeingFullWSCounter);
		cprintf("Num of clocks = %d\n", myEnv->nClocks);
  8006a3:	a1 20 50 80 00       	mov    0x805020,%eax
  8006a8:	8b 80 b8 05 00 00    	mov    0x5b8(%eax),%eax
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	50                   	push   %eax
  8006b2:	68 64 43 80 00       	push   $0x804364
  8006b7:	e8 01 03 00 00       	call   8009bd <cprintf>
  8006bc:	83 c4 10             	add    $0x10,%esp
		cprintf("**************************************\n");
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	68 bc 42 80 00       	push   $0x8042bc
  8006c7:	e8 f1 02 00 00       	call   8009bd <cprintf>
  8006cc:	83 c4 10             	add    $0x10,%esp
	}
	sys_unlock_cons();
  8006cf:	e8 e2 15 00 00       	call   801cb6 <sys_unlock_cons>
//	sys_unlock_cons();

	// exit gracefully
	exit();
  8006d4:	e8 19 00 00 00       	call   8006f2 <exit>
}
  8006d9:	90                   	nop
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <destroy>:

#include <inc/lib.h>

void
destroy(void)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	83 ec 08             	sub    $0x8,%esp
	sys_destroy_env(0);
  8006e2:	83 ec 0c             	sub    $0xc,%esp
  8006e5:	6a 00                	push   $0x0
  8006e7:	e8 f8 17 00 00       	call   801ee4 <sys_destroy_env>
  8006ec:	83 c4 10             	add    $0x10,%esp
}
  8006ef:	90                   	nop
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <exit>:

void
exit(void)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 08             	sub    $0x8,%esp
	sys_exit_env();
  8006f8:	e8 4d 18 00 00       	call   801f4a <sys_exit_env>
}
  8006fd:	90                   	nop
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	va_start(ap, fmt);
  800706:	8d 45 10             	lea    0x10(%ebp),%eax
  800709:	83 c0 04             	add    $0x4,%eax
  80070c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Print the panic message
	if (argv0)
  80070f:	a1 54 92 80 00       	mov    0x809254,%eax
  800714:	85 c0                	test   %eax,%eax
  800716:	74 16                	je     80072e <_panic+0x2e>
		cprintf("%s: ", argv0);
  800718:	a1 54 92 80 00       	mov    0x809254,%eax
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	50                   	push   %eax
  800721:	68 78 43 80 00       	push   $0x804378
  800726:	e8 92 02 00 00       	call   8009bd <cprintf>
  80072b:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  80072e:	a1 1c 50 80 00       	mov    0x80501c,%eax
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	ff 75 08             	pushl  0x8(%ebp)
  800739:	50                   	push   %eax
  80073a:	68 7d 43 80 00       	push   $0x80437d
  80073f:	e8 79 02 00 00       	call   8009bd <cprintf>
  800744:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  800747:	8b 45 10             	mov    0x10(%ebp),%eax
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	ff 75 f4             	pushl  -0xc(%ebp)
  800750:	50                   	push   %eax
  800751:	e8 fc 01 00 00       	call   800952 <vcprintf>
  800756:	83 c4 10             	add    $0x10,%esp
	vcprintf("\n", NULL);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	6a 00                	push   $0x0
  80075e:	68 99 43 80 00       	push   $0x804399
  800763:	e8 ea 01 00 00       	call   800952 <vcprintf>
  800768:	83 c4 10             	add    $0x10,%esp
	// Cause a breakpoint exception
//	while (1);
//		asm volatile("int3");

	//2013: exit the panic env only
	exit() ;
  80076b:	e8 82 ff ff ff       	call   8006f2 <exit>

	// should not return here
	while (1) ;
  800770:	eb fe                	jmp    800770 <_panic+0x70>

00800772 <CheckWSArrayWithoutLastIndex>:
}

void CheckWSArrayWithoutLastIndex(uint32 *expectedPages, int arraySize)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	83 ec 28             	sub    $0x28,%esp
	if (arraySize != myEnv->page_WS_max_size)
  800778:	a1 20 50 80 00       	mov    0x805020,%eax
  80077d:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  800783:	8b 45 0c             	mov    0xc(%ebp),%eax
  800786:	39 c2                	cmp    %eax,%edx
  800788:	74 14                	je     80079e <CheckWSArrayWithoutLastIndex+0x2c>
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
  80078a:	83 ec 04             	sub    $0x4,%esp
  80078d:	68 9c 43 80 00       	push   $0x80439c
  800792:	6a 26                	push   $0x26
  800794:	68 e8 43 80 00       	push   $0x8043e8
  800799:	e8 62 ff ff ff       	call   800700 <_panic>
	}
	int expectedNumOfEmptyLocs = 0;
  80079e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	for (int e = 0; e < arraySize; e++) {
  8007a5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8007ac:	e9 c5 00 00 00       	jmp    800876 <CheckWSArrayWithoutLastIndex+0x104>
		if (expectedPages[e] == 0) {
  8007b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	01 d0                	add    %edx,%eax
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	75 08                	jne    8007ce <CheckWSArrayWithoutLastIndex+0x5c>
			expectedNumOfEmptyLocs++;
  8007c6:	ff 45 f4             	incl   -0xc(%ebp)
			continue;
  8007c9:	e9 a5 00 00 00       	jmp    800873 <CheckWSArrayWithoutLastIndex+0x101>
		}
		int found = 0;
  8007ce:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8007d5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  8007dc:	eb 69                	jmp    800847 <CheckWSArrayWithoutLastIndex+0xd5>
			if (myEnv->__uptr_pws[w].empty == 0) {
  8007de:	a1 20 50 80 00       	mov    0x805020,%eax
  8007e3:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  8007e9:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8007ec:	89 d0                	mov    %edx,%eax
  8007ee:	01 c0                	add    %eax,%eax
  8007f0:	01 d0                	add    %edx,%eax
  8007f2:	c1 e0 03             	shl    $0x3,%eax
  8007f5:	01 c8                	add    %ecx,%eax
  8007f7:	8a 40 04             	mov    0x4(%eax),%al
  8007fa:	84 c0                	test   %al,%al
  8007fc:	75 46                	jne    800844 <CheckWSArrayWithoutLastIndex+0xd2>
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  8007fe:	a1 20 50 80 00       	mov    0x805020,%eax
  800803:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  800809:	8b 55 e8             	mov    -0x18(%ebp),%edx
  80080c:	89 d0                	mov    %edx,%eax
  80080e:	01 c0                	add    %eax,%eax
  800810:	01 d0                	add    %edx,%eax
  800812:	c1 e0 03             	shl    $0x3,%eax
  800815:	01 c8                	add    %ecx,%eax
  800817:	8b 00                	mov    (%eax),%eax
  800819:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80081c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80081f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800824:	89 c2                	mov    %eax,%edx
						== expectedPages[e]) {
  800826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800829:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	01 c8                	add    %ecx,%eax
  800835:	8b 00                	mov    (%eax),%eax
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
			if (myEnv->__uptr_pws[w].empty == 0) {
				if (ROUNDDOWN(myEnv->__uptr_pws[w].virtual_address, PAGE_SIZE)
  800837:	39 c2                	cmp    %eax,%edx
  800839:	75 09                	jne    800844 <CheckWSArrayWithoutLastIndex+0xd2>
						== expectedPages[e]) {
					found = 1;
  80083b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
					break;
  800842:	eb 15                	jmp    800859 <CheckWSArrayWithoutLastIndex+0xe7>
		if (expectedPages[e] == 0) {
			expectedNumOfEmptyLocs++;
			continue;
		}
		int found = 0;
		for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  800844:	ff 45 e8             	incl   -0x18(%ebp)
  800847:	a1 20 50 80 00       	mov    0x805020,%eax
  80084c:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  800852:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800855:	39 c2                	cmp    %eax,%edx
  800857:	77 85                	ja     8007de <CheckWSArrayWithoutLastIndex+0x6c>
					found = 1;
					break;
				}
			}
		}
		if (!found)
  800859:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80085d:	75 14                	jne    800873 <CheckWSArrayWithoutLastIndex+0x101>
			panic(
  80085f:	83 ec 04             	sub    $0x4,%esp
  800862:	68 f4 43 80 00       	push   $0x8043f4
  800867:	6a 3a                	push   $0x3a
  800869:	68 e8 43 80 00       	push   $0x8043e8
  80086e:	e8 8d fe ff ff       	call   800700 <_panic>
	if (arraySize != myEnv->page_WS_max_size)
	{
		panic("number of expected pages SHOULD BE EQUAL to max WS size... review your TA!!");
	}
	int expectedNumOfEmptyLocs = 0;
	for (int e = 0; e < arraySize; e++) {
  800873:	ff 45 f0             	incl   -0x10(%ebp)
  800876:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800879:	3b 45 0c             	cmp    0xc(%ebp),%eax
  80087c:	0f 8c 2f ff ff ff    	jl     8007b1 <CheckWSArrayWithoutLastIndex+0x3f>
		}
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
  800882:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  800889:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800890:	eb 26                	jmp    8008b8 <CheckWSArrayWithoutLastIndex+0x146>
		if (myEnv->__uptr_pws[w].empty == 1) {
  800892:	a1 20 50 80 00       	mov    0x805020,%eax
  800897:	8b 88 88 05 00 00    	mov    0x588(%eax),%ecx
  80089d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008a0:	89 d0                	mov    %edx,%eax
  8008a2:	01 c0                	add    %eax,%eax
  8008a4:	01 d0                	add    %edx,%eax
  8008a6:	c1 e0 03             	shl    $0x3,%eax
  8008a9:	01 c8                	add    %ecx,%eax
  8008ab:	8a 40 04             	mov    0x4(%eax),%al
  8008ae:	3c 01                	cmp    $0x1,%al
  8008b0:	75 03                	jne    8008b5 <CheckWSArrayWithoutLastIndex+0x143>
			actualNumOfEmptyLocs++;
  8008b2:	ff 45 e4             	incl   -0x1c(%ebp)
		if (!found)
			panic(
					"PAGE WS entry checking failed... trace it by printing page WS before & after fault");
	}
	int actualNumOfEmptyLocs = 0;
	for (int w = 0; w < myEnv->page_WS_max_size; w++) {
  8008b5:	ff 45 e0             	incl   -0x20(%ebp)
  8008b8:	a1 20 50 80 00       	mov    0x805020,%eax
  8008bd:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
  8008c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c6:	39 c2                	cmp    %eax,%edx
  8008c8:	77 c8                	ja     800892 <CheckWSArrayWithoutLastIndex+0x120>
		if (myEnv->__uptr_pws[w].empty == 1) {
			actualNumOfEmptyLocs++;
		}
	}
	if (expectedNumOfEmptyLocs != actualNumOfEmptyLocs)
  8008ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cd:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8008d0:	74 14                	je     8008e6 <CheckWSArrayWithoutLastIndex+0x174>
		panic(
  8008d2:	83 ec 04             	sub    $0x4,%esp
  8008d5:	68 48 44 80 00       	push   $0x804448
  8008da:	6a 44                	push   $0x44
  8008dc:	68 e8 43 80 00       	push   $0x8043e8
  8008e1:	e8 1a fe ff ff       	call   800700 <_panic>
				"PAGE WS entry checking failed... number of empty locations is not correct");
}
  8008e6:	90                   	nop
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    

008008e9 <putch>:
	int idx; // current buffer index
	int cnt; // total bytes printed so far
	char buf[256];
};

static void putch(int ch, struct printbuf *b) {
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f2:	8b 00                	mov    (%eax),%eax
  8008f4:	8d 48 01             	lea    0x1(%eax),%ecx
  8008f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fa:	89 0a                	mov    %ecx,(%edx)
  8008fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ff:	88 d1                	mov    %dl,%cl
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
  800904:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256 - 1) {
  800908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090b:	8b 00                	mov    (%eax),%eax
  80090d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800912:	75 2c                	jne    800940 <putch+0x57>
		sys_cputs(b->buf, b->idx, printProgName);
  800914:	a0 40 50 80 00       	mov    0x805040,%al
  800919:	0f b6 c0             	movzbl %al,%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	8b 12                	mov    (%edx),%edx
  800921:	89 d1                	mov    %edx,%ecx
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	83 c2 08             	add    $0x8,%edx
  800929:	83 ec 04             	sub    $0x4,%esp
  80092c:	50                   	push   %eax
  80092d:	51                   	push   %ecx
  80092e:	52                   	push   %edx
  80092f:	e8 26 13 00 00       	call   801c5a <sys_cputs>
  800934:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800940:	8b 45 0c             	mov    0xc(%ebp),%eax
  800943:	8b 40 04             	mov    0x4(%eax),%eax
  800946:	8d 50 01             	lea    0x1(%eax),%edx
  800949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094c:	89 50 04             	mov    %edx,0x4(%eax)
}
  80094f:	90                   	nop
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <vcprintf>:

int vcprintf(const char *fmt, va_list ap) {
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80095b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800962:	00 00 00 
	b.cnt = 0;
  800965:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80096c:	00 00 00 
	vprintfmt((void*) putch, &b, fmt, ap);
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	ff 75 08             	pushl  0x8(%ebp)
  800975:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80097b:	50                   	push   %eax
  80097c:	68 e9 08 80 00       	push   $0x8008e9
  800981:	e8 11 02 00 00       	call   800b97 <vprintfmt>
  800986:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx, printProgName);
  800989:	a0 40 50 80 00       	mov    0x805040,%al
  80098e:	0f b6 c0             	movzbl %al,%eax
  800991:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
  800997:	83 ec 04             	sub    $0x4,%esp
  80099a:	50                   	push   %eax
  80099b:	52                   	push   %edx
  80099c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009a2:	83 c0 08             	add    $0x8,%eax
  8009a5:	50                   	push   %eax
  8009a6:	e8 af 12 00 00       	call   801c5a <sys_cputs>
  8009ab:	83 c4 10             	add    $0x10,%esp

	printProgName = 0;
  8009ae:	c6 05 40 50 80 00 00 	movb   $0x0,0x805040
	return b.cnt;
  8009b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int cprintf(const char *fmt, ...) {
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;
	printProgName = 1 ;
  8009c3:	c6 05 40 50 80 00 01 	movb   $0x1,0x805040
	va_start(ap, fmt);
  8009ca:	8d 45 0c             	lea    0xc(%ebp),%eax
  8009cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8009d9:	50                   	push   %eax
  8009da:	e8 73 ff ff ff       	call   800952 <vcprintf>
  8009df:	83 c4 10             	add    $0x10,%esp
  8009e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  8009e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <atomic_cprintf>:

//%@: to print the program name and ID before the message
//%~: to print the message directly
int atomic_cprintf(const char *fmt, ...)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 18             	sub    $0x18,%esp
	int cnt;
	sys_lock_cons();
  8009f0:	e8 a7 12 00 00       	call   801c9c <sys_lock_cons>
	{
		va_list ap;
		va_start(ap, fmt);
  8009f5:	8d 45 0c             	lea    0xc(%ebp),%eax
  8009f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
		cnt = vcprintf(fmt, ap);
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	83 ec 08             	sub    $0x8,%esp
  800a01:	ff 75 f4             	pushl  -0xc(%ebp)
  800a04:	50                   	push   %eax
  800a05:	e8 48 ff ff ff       	call   800952 <vcprintf>
  800a0a:	83 c4 10             	add    $0x10,%esp
  800a0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
		va_end(ap);
	}
	sys_unlock_cons();
  800a10:	e8 a1 12 00 00       	call   801cb6 <sys_unlock_cons>
	return cnt;
  800a15:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	83 ec 14             	sub    $0x14,%esp
  800a21:	8b 45 10             	mov    0x10(%ebp),%eax
  800a24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a27:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a2d:	8b 45 18             	mov    0x18(%ebp),%eax
  800a30:	ba 00 00 00 00       	mov    $0x0,%edx
  800a35:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800a38:	77 55                	ja     800a8f <printnum+0x75>
  800a3a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800a3d:	72 05                	jb     800a44 <printnum+0x2a>
  800a3f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800a42:	77 4b                	ja     800a8f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a44:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800a47:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800a4a:	8b 45 18             	mov    0x18(%ebp),%eax
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	52                   	push   %edx
  800a53:	50                   	push   %eax
  800a54:	ff 75 f4             	pushl  -0xc(%ebp)
  800a57:	ff 75 f0             	pushl  -0x10(%ebp)
  800a5a:	e8 95 32 00 00       	call   803cf4 <__udivdi3>
  800a5f:	83 c4 10             	add    $0x10,%esp
  800a62:	83 ec 04             	sub    $0x4,%esp
  800a65:	ff 75 20             	pushl  0x20(%ebp)
  800a68:	53                   	push   %ebx
  800a69:	ff 75 18             	pushl  0x18(%ebp)
  800a6c:	52                   	push   %edx
  800a6d:	50                   	push   %eax
  800a6e:	ff 75 0c             	pushl  0xc(%ebp)
  800a71:	ff 75 08             	pushl  0x8(%ebp)
  800a74:	e8 a1 ff ff ff       	call   800a1a <printnum>
  800a79:	83 c4 20             	add    $0x20,%esp
  800a7c:	eb 1a                	jmp    800a98 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	ff 75 0c             	pushl  0xc(%ebp)
  800a84:	ff 75 20             	pushl  0x20(%ebp)
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	ff d0                	call   *%eax
  800a8c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800a8f:	ff 4d 1c             	decl   0x1c(%ebp)
  800a92:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800a96:	7f e6                	jg     800a7e <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a98:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800a9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aa6:	53                   	push   %ebx
  800aa7:	51                   	push   %ecx
  800aa8:	52                   	push   %edx
  800aa9:	50                   	push   %eax
  800aaa:	e8 55 33 00 00       	call   803e04 <__umoddi3>
  800aaf:	83 c4 10             	add    $0x10,%esp
  800ab2:	05 b4 46 80 00       	add    $0x8046b4,%eax
  800ab7:	8a 00                	mov    (%eax),%al
  800ab9:	0f be c0             	movsbl %al,%eax
  800abc:	83 ec 08             	sub    $0x8,%esp
  800abf:	ff 75 0c             	pushl  0xc(%ebp)
  800ac2:	50                   	push   %eax
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	ff d0                	call   *%eax
  800ac8:	83 c4 10             	add    $0x10,%esp
}
  800acb:	90                   	nop
  800acc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800acf:	c9                   	leave  
  800ad0:	c3                   	ret    

00800ad1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800ad4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800ad8:	7e 1c                	jle    800af6 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	8b 00                	mov    (%eax),%eax
  800adf:	8d 50 08             	lea    0x8(%eax),%edx
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	89 10                	mov    %edx,(%eax)
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	8b 00                	mov    (%eax),%eax
  800aec:	83 e8 08             	sub    $0x8,%eax
  800aef:	8b 50 04             	mov    0x4(%eax),%edx
  800af2:	8b 00                	mov    (%eax),%eax
  800af4:	eb 40                	jmp    800b36 <getuint+0x65>
	else if (lflag)
  800af6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afa:	74 1e                	je     800b1a <getuint+0x49>
		return va_arg(*ap, unsigned long);
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 00                	mov    (%eax),%eax
  800b01:	8d 50 04             	lea    0x4(%eax),%edx
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	89 10                	mov    %edx,(%eax)
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 00                	mov    (%eax),%eax
  800b0e:	83 e8 04             	sub    $0x4,%eax
  800b11:	8b 00                	mov    (%eax),%eax
  800b13:	ba 00 00 00 00       	mov    $0x0,%edx
  800b18:	eb 1c                	jmp    800b36 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1d:	8b 00                	mov    (%eax),%eax
  800b1f:	8d 50 04             	lea    0x4(%eax),%edx
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	89 10                	mov    %edx,(%eax)
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 00                	mov    (%eax),%eax
  800b2c:	83 e8 04             	sub    $0x4,%eax
  800b2f:	8b 00                	mov    (%eax),%eax
  800b31:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800b3b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800b3f:	7e 1c                	jle    800b5d <getint+0x25>
		return va_arg(*ap, long long);
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	8d 50 08             	lea    0x8(%eax),%edx
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	89 10                	mov    %edx,(%eax)
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	8b 00                	mov    (%eax),%eax
  800b53:	83 e8 08             	sub    $0x8,%eax
  800b56:	8b 50 04             	mov    0x4(%eax),%edx
  800b59:	8b 00                	mov    (%eax),%eax
  800b5b:	eb 38                	jmp    800b95 <getint+0x5d>
	else if (lflag)
  800b5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b61:	74 1a                	je     800b7d <getint+0x45>
		return va_arg(*ap, long);
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 00                	mov    (%eax),%eax
  800b68:	8d 50 04             	lea    0x4(%eax),%edx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	89 10                	mov    %edx,(%eax)
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8b 00                	mov    (%eax),%eax
  800b75:	83 e8 04             	sub    $0x4,%eax
  800b78:	8b 00                	mov    (%eax),%eax
  800b7a:	99                   	cltd   
  800b7b:	eb 18                	jmp    800b95 <getint+0x5d>
	else
		return va_arg(*ap, int);
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	8b 00                	mov    (%eax),%eax
  800b82:	8d 50 04             	lea    0x4(%eax),%edx
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	89 10                	mov    %edx,(%eax)
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	8b 00                	mov    (%eax),%eax
  800b8f:	83 e8 04             	sub    $0x4,%eax
  800b92:	8b 00                	mov    (%eax),%eax
  800b94:	99                   	cltd   
}
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b9f:	eb 17                	jmp    800bb8 <vprintfmt+0x21>
			if (ch == '\0')
  800ba1:	85 db                	test   %ebx,%ebx
  800ba3:	0f 84 c1 03 00 00    	je     800f6a <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800ba9:	83 ec 08             	sub    $0x8,%esp
  800bac:	ff 75 0c             	pushl  0xc(%ebp)
  800baf:	53                   	push   %ebx
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	ff d0                	call   *%eax
  800bb5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800bb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bbb:	8d 50 01             	lea    0x1(%eax),%edx
  800bbe:	89 55 10             	mov    %edx,0x10(%ebp)
  800bc1:	8a 00                	mov    (%eax),%al
  800bc3:	0f b6 d8             	movzbl %al,%ebx
  800bc6:	83 fb 25             	cmp    $0x25,%ebx
  800bc9:	75 d6                	jne    800ba1 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800bcb:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800bcf:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800bd6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800bdd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800be4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800beb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bee:	8d 50 01             	lea    0x1(%eax),%edx
  800bf1:	89 55 10             	mov    %edx,0x10(%ebp)
  800bf4:	8a 00                	mov    (%eax),%al
  800bf6:	0f b6 d8             	movzbl %al,%ebx
  800bf9:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800bfc:	83 f8 5b             	cmp    $0x5b,%eax
  800bff:	0f 87 3d 03 00 00    	ja     800f42 <vprintfmt+0x3ab>
  800c05:	8b 04 85 d8 46 80 00 	mov    0x8046d8(,%eax,4),%eax
  800c0c:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800c0e:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800c12:	eb d7                	jmp    800beb <vprintfmt+0x54>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c14:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800c18:	eb d1                	jmp    800beb <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c1a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800c21:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800c24:	89 d0                	mov    %edx,%eax
  800c26:	c1 e0 02             	shl    $0x2,%eax
  800c29:	01 d0                	add    %edx,%eax
  800c2b:	01 c0                	add    %eax,%eax
  800c2d:	01 d8                	add    %ebx,%eax
  800c2f:	83 e8 30             	sub    $0x30,%eax
  800c32:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800c35:	8b 45 10             	mov    0x10(%ebp),%eax
  800c38:	8a 00                	mov    (%eax),%al
  800c3a:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800c3d:	83 fb 2f             	cmp    $0x2f,%ebx
  800c40:	7e 3e                	jle    800c80 <vprintfmt+0xe9>
  800c42:	83 fb 39             	cmp    $0x39,%ebx
  800c45:	7f 39                	jg     800c80 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800c47:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800c4a:	eb d5                	jmp    800c21 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800c4c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c4f:	83 c0 04             	add    $0x4,%eax
  800c52:	89 45 14             	mov    %eax,0x14(%ebp)
  800c55:	8b 45 14             	mov    0x14(%ebp),%eax
  800c58:	83 e8 04             	sub    $0x4,%eax
  800c5b:	8b 00                	mov    (%eax),%eax
  800c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800c60:	eb 1f                	jmp    800c81 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800c62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c66:	79 83                	jns    800beb <vprintfmt+0x54>
				width = 0;
  800c68:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800c6f:	e9 77 ff ff ff       	jmp    800beb <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800c74:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c7b:	e9 6b ff ff ff       	jmp    800beb <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800c80:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800c81:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c85:	0f 89 60 ff ff ff    	jns    800beb <vprintfmt+0x54>
				width = precision, precision = -1;
  800c8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c91:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800c98:	e9 4e ff ff ff       	jmp    800beb <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c9d:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800ca0:	e9 46 ff ff ff       	jmp    800beb <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800ca5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca8:	83 c0 04             	add    $0x4,%eax
  800cab:	89 45 14             	mov    %eax,0x14(%ebp)
  800cae:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb1:	83 e8 04             	sub    $0x4,%eax
  800cb4:	8b 00                	mov    (%eax),%eax
  800cb6:	83 ec 08             	sub    $0x8,%esp
  800cb9:	ff 75 0c             	pushl  0xc(%ebp)
  800cbc:	50                   	push   %eax
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	ff d0                	call   *%eax
  800cc2:	83 c4 10             	add    $0x10,%esp
			break;
  800cc5:	e9 9b 02 00 00       	jmp    800f65 <vprintfmt+0x3ce>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800cca:	8b 45 14             	mov    0x14(%ebp),%eax
  800ccd:	83 c0 04             	add    $0x4,%eax
  800cd0:	89 45 14             	mov    %eax,0x14(%ebp)
  800cd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd6:	83 e8 04             	sub    $0x4,%eax
  800cd9:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800cdb:	85 db                	test   %ebx,%ebx
  800cdd:	79 02                	jns    800ce1 <vprintfmt+0x14a>
				err = -err;
  800cdf:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800ce1:	83 fb 64             	cmp    $0x64,%ebx
  800ce4:	7f 0b                	jg     800cf1 <vprintfmt+0x15a>
  800ce6:	8b 34 9d 20 45 80 00 	mov    0x804520(,%ebx,4),%esi
  800ced:	85 f6                	test   %esi,%esi
  800cef:	75 19                	jne    800d0a <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  800cf1:	53                   	push   %ebx
  800cf2:	68 c5 46 80 00       	push   $0x8046c5
  800cf7:	ff 75 0c             	pushl  0xc(%ebp)
  800cfa:	ff 75 08             	pushl  0x8(%ebp)
  800cfd:	e8 70 02 00 00       	call   800f72 <printfmt>
  800d02:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800d05:	e9 5b 02 00 00       	jmp    800f65 <vprintfmt+0x3ce>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800d0a:	56                   	push   %esi
  800d0b:	68 ce 46 80 00       	push   $0x8046ce
  800d10:	ff 75 0c             	pushl  0xc(%ebp)
  800d13:	ff 75 08             	pushl  0x8(%ebp)
  800d16:	e8 57 02 00 00       	call   800f72 <printfmt>
  800d1b:	83 c4 10             	add    $0x10,%esp
			break;
  800d1e:	e9 42 02 00 00       	jmp    800f65 <vprintfmt+0x3ce>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d23:	8b 45 14             	mov    0x14(%ebp),%eax
  800d26:	83 c0 04             	add    $0x4,%eax
  800d29:	89 45 14             	mov    %eax,0x14(%ebp)
  800d2c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2f:	83 e8 04             	sub    $0x4,%eax
  800d32:	8b 30                	mov    (%eax),%esi
  800d34:	85 f6                	test   %esi,%esi
  800d36:	75 05                	jne    800d3d <vprintfmt+0x1a6>
				p = "(null)";
  800d38:	be d1 46 80 00       	mov    $0x8046d1,%esi
			if (width > 0 && padc != '-')
  800d3d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d41:	7e 6d                	jle    800db0 <vprintfmt+0x219>
  800d43:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800d47:	74 67                	je     800db0 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800d49:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d4c:	83 ec 08             	sub    $0x8,%esp
  800d4f:	50                   	push   %eax
  800d50:	56                   	push   %esi
  800d51:	e8 1e 03 00 00       	call   801074 <strnlen>
  800d56:	83 c4 10             	add    $0x10,%esp
  800d59:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800d5c:	eb 16                	jmp    800d74 <vprintfmt+0x1dd>
					putch(padc, putdat);
  800d5e:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800d62:	83 ec 08             	sub    $0x8,%esp
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	50                   	push   %eax
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	ff d0                	call   *%eax
  800d6e:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d71:	ff 4d e4             	decl   -0x1c(%ebp)
  800d74:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d78:	7f e4                	jg     800d5e <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d7a:	eb 34                	jmp    800db0 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  800d7c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d80:	74 1c                	je     800d9e <vprintfmt+0x207>
  800d82:	83 fb 1f             	cmp    $0x1f,%ebx
  800d85:	7e 05                	jle    800d8c <vprintfmt+0x1f5>
  800d87:	83 fb 7e             	cmp    $0x7e,%ebx
  800d8a:	7e 12                	jle    800d9e <vprintfmt+0x207>
					putch('?', putdat);
  800d8c:	83 ec 08             	sub    $0x8,%esp
  800d8f:	ff 75 0c             	pushl  0xc(%ebp)
  800d92:	6a 3f                	push   $0x3f
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	ff d0                	call   *%eax
  800d99:	83 c4 10             	add    $0x10,%esp
  800d9c:	eb 0f                	jmp    800dad <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800d9e:	83 ec 08             	sub    $0x8,%esp
  800da1:	ff 75 0c             	pushl  0xc(%ebp)
  800da4:	53                   	push   %ebx
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	ff d0                	call   *%eax
  800daa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800dad:	ff 4d e4             	decl   -0x1c(%ebp)
  800db0:	89 f0                	mov    %esi,%eax
  800db2:	8d 70 01             	lea    0x1(%eax),%esi
  800db5:	8a 00                	mov    (%eax),%al
  800db7:	0f be d8             	movsbl %al,%ebx
  800dba:	85 db                	test   %ebx,%ebx
  800dbc:	74 24                	je     800de2 <vprintfmt+0x24b>
  800dbe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dc2:	78 b8                	js     800d7c <vprintfmt+0x1e5>
  800dc4:	ff 4d e0             	decl   -0x20(%ebp)
  800dc7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dcb:	79 af                	jns    800d7c <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800dcd:	eb 13                	jmp    800de2 <vprintfmt+0x24b>
				putch(' ', putdat);
  800dcf:	83 ec 08             	sub    $0x8,%esp
  800dd2:	ff 75 0c             	pushl  0xc(%ebp)
  800dd5:	6a 20                	push   $0x20
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	ff d0                	call   *%eax
  800ddc:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ddf:	ff 4d e4             	decl   -0x1c(%ebp)
  800de2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800de6:	7f e7                	jg     800dcf <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  800de8:	e9 78 01 00 00       	jmp    800f65 <vprintfmt+0x3ce>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ded:	83 ec 08             	sub    $0x8,%esp
  800df0:	ff 75 e8             	pushl  -0x18(%ebp)
  800df3:	8d 45 14             	lea    0x14(%ebp),%eax
  800df6:	50                   	push   %eax
  800df7:	e8 3c fd ff ff       	call   800b38 <getint>
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e02:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800e05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e0b:	85 d2                	test   %edx,%edx
  800e0d:	79 23                	jns    800e32 <vprintfmt+0x29b>
				putch('-', putdat);
  800e0f:	83 ec 08             	sub    $0x8,%esp
  800e12:	ff 75 0c             	pushl  0xc(%ebp)
  800e15:	6a 2d                	push   $0x2d
  800e17:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1a:	ff d0                	call   *%eax
  800e1c:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e25:	f7 d8                	neg    %eax
  800e27:	83 d2 00             	adc    $0x0,%edx
  800e2a:	f7 da                	neg    %edx
  800e2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e2f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800e32:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800e39:	e9 bc 00 00 00       	jmp    800efa <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800e3e:	83 ec 08             	sub    $0x8,%esp
  800e41:	ff 75 e8             	pushl  -0x18(%ebp)
  800e44:	8d 45 14             	lea    0x14(%ebp),%eax
  800e47:	50                   	push   %eax
  800e48:	e8 84 fc ff ff       	call   800ad1 <getuint>
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800e53:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800e56:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800e5d:	e9 98 00 00 00       	jmp    800efa <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	ff 75 0c             	pushl  0xc(%ebp)
  800e68:	6a 58                	push   $0x58
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	ff d0                	call   *%eax
  800e6f:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	ff 75 0c             	pushl  0xc(%ebp)
  800e78:	6a 58                	push   $0x58
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7d:	ff d0                	call   *%eax
  800e7f:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	ff 75 0c             	pushl  0xc(%ebp)
  800e88:	6a 58                	push   $0x58
  800e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8d:	ff d0                	call   *%eax
  800e8f:	83 c4 10             	add    $0x10,%esp
			break;
  800e92:	e9 ce 00 00 00       	jmp    800f65 <vprintfmt+0x3ce>

		// pointer
		case 'p':
			putch('0', putdat);
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	ff 75 0c             	pushl  0xc(%ebp)
  800e9d:	6a 30                	push   $0x30
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	ff d0                	call   *%eax
  800ea4:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	ff 75 0c             	pushl  0xc(%ebp)
  800ead:	6a 78                	push   $0x78
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	ff d0                	call   *%eax
  800eb4:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800eb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800eba:	83 c0 04             	add    $0x4,%eax
  800ebd:	89 45 14             	mov    %eax,0x14(%ebp)
  800ec0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec3:	83 e8 04             	sub    $0x4,%eax
  800ec6:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ec8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ecb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  800ed2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800ed9:	eb 1f                	jmp    800efa <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800edb:	83 ec 08             	sub    $0x8,%esp
  800ede:	ff 75 e8             	pushl  -0x18(%ebp)
  800ee1:	8d 45 14             	lea    0x14(%ebp),%eax
  800ee4:	50                   	push   %eax
  800ee5:	e8 e7 fb ff ff       	call   800ad1 <getuint>
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ef0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800ef3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800efa:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800efe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	52                   	push   %edx
  800f05:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f08:	50                   	push   %eax
  800f09:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0c:	ff 75 f0             	pushl  -0x10(%ebp)
  800f0f:	ff 75 0c             	pushl  0xc(%ebp)
  800f12:	ff 75 08             	pushl  0x8(%ebp)
  800f15:	e8 00 fb ff ff       	call   800a1a <printnum>
  800f1a:	83 c4 20             	add    $0x20,%esp
			break;
  800f1d:	eb 46                	jmp    800f65 <vprintfmt+0x3ce>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	ff 75 0c             	pushl  0xc(%ebp)
  800f25:	53                   	push   %ebx
  800f26:	8b 45 08             	mov    0x8(%ebp),%eax
  800f29:	ff d0                	call   *%eax
  800f2b:	83 c4 10             	add    $0x10,%esp
			break;
  800f2e:	eb 35                	jmp    800f65 <vprintfmt+0x3ce>

		/**********************************/
		/*2023*/
		// DON'T Print Program Name & UD
		case '~':
			printProgName = 0;
  800f30:	c6 05 40 50 80 00 00 	movb   $0x0,0x805040
			break;
  800f37:	eb 2c                	jmp    800f65 <vprintfmt+0x3ce>
		// Print Program Name & UD
		case '@':
			printProgName = 1;
  800f39:	c6 05 40 50 80 00 01 	movb   $0x1,0x805040
			break;
  800f40:	eb 23                	jmp    800f65 <vprintfmt+0x3ce>
		/**********************************/

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800f42:	83 ec 08             	sub    $0x8,%esp
  800f45:	ff 75 0c             	pushl  0xc(%ebp)
  800f48:	6a 25                	push   $0x25
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4d:	ff d0                	call   *%eax
  800f4f:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800f52:	ff 4d 10             	decl   0x10(%ebp)
  800f55:	eb 03                	jmp    800f5a <vprintfmt+0x3c3>
  800f57:	ff 4d 10             	decl   0x10(%ebp)
  800f5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5d:	48                   	dec    %eax
  800f5e:	8a 00                	mov    (%eax),%al
  800f60:	3c 25                	cmp    $0x25,%al
  800f62:	75 f3                	jne    800f57 <vprintfmt+0x3c0>
				/* do nothing */;
			break;
  800f64:	90                   	nop
		}
	}
  800f65:	e9 35 fc ff ff       	jmp    800b9f <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800f6a:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800f6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6e:	5b                   	pop    %ebx
  800f6f:	5e                   	pop    %esi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800f78:	8d 45 10             	lea    0x10(%ebp),%eax
  800f7b:	83 c0 04             	add    $0x4,%eax
  800f7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800f81:	8b 45 10             	mov    0x10(%ebp),%eax
  800f84:	ff 75 f4             	pushl  -0xc(%ebp)
  800f87:	50                   	push   %eax
  800f88:	ff 75 0c             	pushl  0xc(%ebp)
  800f8b:	ff 75 08             	pushl  0x8(%ebp)
  800f8e:	e8 04 fc ff ff       	call   800b97 <vprintfmt>
  800f93:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800f96:	90                   	nop
  800f97:	c9                   	leave  
  800f98:	c3                   	ret    

00800f99 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800f9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9f:	8b 40 08             	mov    0x8(%eax),%eax
  800fa2:	8d 50 01             	lea    0x1(%eax),%edx
  800fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa8:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fae:	8b 10                	mov    (%eax),%edx
  800fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb3:	8b 40 04             	mov    0x4(%eax),%eax
  800fb6:	39 c2                	cmp    %eax,%edx
  800fb8:	73 12                	jae    800fcc <sprintputch+0x33>
		*b->buf++ = ch;
  800fba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbd:	8b 00                	mov    (%eax),%eax
  800fbf:	8d 48 01             	lea    0x1(%eax),%ecx
  800fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc5:	89 0a                	mov    %ecx,(%edx)
  800fc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fca:	88 10                	mov    %dl,(%eax)
}
  800fcc:	90                   	nop
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fde:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	01 d0                	add    %edx,%eax
  800fe6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800fe9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ff0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800ff4:	74 06                	je     800ffc <vsnprintf+0x2d>
  800ff6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ffa:	7f 07                	jg     801003 <vsnprintf+0x34>
		return -E_INVAL;
  800ffc:	b8 03 00 00 00       	mov    $0x3,%eax
  801001:	eb 20                	jmp    801023 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801003:	ff 75 14             	pushl  0x14(%ebp)
  801006:	ff 75 10             	pushl  0x10(%ebp)
  801009:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80100c:	50                   	push   %eax
  80100d:	68 99 0f 80 00       	push   $0x800f99
  801012:	e8 80 fb ff ff       	call   800b97 <vprintfmt>
  801017:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  80101a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80101d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801023:	c9                   	leave  
  801024:	c3                   	ret    

00801025 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80102b:	8d 45 10             	lea    0x10(%ebp),%eax
  80102e:	83 c0 04             	add    $0x4,%eax
  801031:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  801034:	8b 45 10             	mov    0x10(%ebp),%eax
  801037:	ff 75 f4             	pushl  -0xc(%ebp)
  80103a:	50                   	push   %eax
  80103b:	ff 75 0c             	pushl  0xc(%ebp)
  80103e:	ff 75 08             	pushl  0x8(%ebp)
  801041:	e8 89 ff ff ff       	call   800fcf <vsnprintf>
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  80104c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80104f:	c9                   	leave  
  801050:	c3                   	ret    

00801051 <strlen>:
#include <inc/string.h>
#include <inc/assert.h>

int
strlen(const char *s)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  801057:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80105e:	eb 06                	jmp    801066 <strlen+0x15>
		n++;
  801060:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801063:	ff 45 08             	incl   0x8(%ebp)
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	8a 00                	mov    (%eax),%al
  80106b:	84 c0                	test   %al,%al
  80106d:	75 f1                	jne    801060 <strlen+0xf>
		n++;
	return n;
  80106f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  801072:	c9                   	leave  
  801073:	c3                   	ret    

00801074 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80107a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801081:	eb 09                	jmp    80108c <strnlen+0x18>
		n++;
  801083:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801086:	ff 45 08             	incl   0x8(%ebp)
  801089:	ff 4d 0c             	decl   0xc(%ebp)
  80108c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801090:	74 09                	je     80109b <strnlen+0x27>
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	8a 00                	mov    (%eax),%al
  801097:	84 c0                	test   %al,%al
  801099:	75 e8                	jne    801083 <strnlen+0xf>
		n++;
	return n;
  80109b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8010ac:	90                   	nop
  8010ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b0:	8d 50 01             	lea    0x1(%eax),%edx
  8010b3:	89 55 08             	mov    %edx,0x8(%ebp)
  8010b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8010bc:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8010bf:	8a 12                	mov    (%edx),%dl
  8010c1:	88 10                	mov    %dl,(%eax)
  8010c3:	8a 00                	mov    (%eax),%al
  8010c5:	84 c0                	test   %al,%al
  8010c7:	75 e4                	jne    8010ad <strcpy+0xd>
		/* do nothing */;
	return ret;
  8010c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    

008010ce <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8010da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8010e1:	eb 1f                	jmp    801102 <strncpy+0x34>
		*dst++ = *src;
  8010e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e6:	8d 50 01             	lea    0x1(%eax),%edx
  8010e9:	89 55 08             	mov    %edx,0x8(%ebp)
  8010ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ef:	8a 12                	mov    (%edx),%dl
  8010f1:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8010f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f6:	8a 00                	mov    (%eax),%al
  8010f8:	84 c0                	test   %al,%al
  8010fa:	74 03                	je     8010ff <strncpy+0x31>
			src++;
  8010fc:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010ff:	ff 45 fc             	incl   -0x4(%ebp)
  801102:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801105:	3b 45 10             	cmp    0x10(%ebp),%eax
  801108:	72 d9                	jb     8010e3 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80110a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80111b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80111f:	74 30                	je     801151 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  801121:	eb 16                	jmp    801139 <strlcpy+0x2a>
			*dst++ = *src++;
  801123:	8b 45 08             	mov    0x8(%ebp),%eax
  801126:	8d 50 01             	lea    0x1(%eax),%edx
  801129:	89 55 08             	mov    %edx,0x8(%ebp)
  80112c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801132:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  801135:	8a 12                	mov    (%edx),%dl
  801137:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801139:	ff 4d 10             	decl   0x10(%ebp)
  80113c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801140:	74 09                	je     80114b <strlcpy+0x3c>
  801142:	8b 45 0c             	mov    0xc(%ebp),%eax
  801145:	8a 00                	mov    (%eax),%al
  801147:	84 c0                	test   %al,%al
  801149:	75 d8                	jne    801123 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  80114b:	8b 45 08             	mov    0x8(%ebp),%eax
  80114e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801151:	8b 55 08             	mov    0x8(%ebp),%edx
  801154:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801157:	29 c2                	sub    %eax,%edx
  801159:	89 d0                	mov    %edx,%eax
}
  80115b:	c9                   	leave  
  80115c:	c3                   	ret    

0080115d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  801160:	eb 06                	jmp    801168 <strcmp+0xb>
		p++, q++;
  801162:	ff 45 08             	incl   0x8(%ebp)
  801165:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801168:	8b 45 08             	mov    0x8(%ebp),%eax
  80116b:	8a 00                	mov    (%eax),%al
  80116d:	84 c0                	test   %al,%al
  80116f:	74 0e                	je     80117f <strcmp+0x22>
  801171:	8b 45 08             	mov    0x8(%ebp),%eax
  801174:	8a 10                	mov    (%eax),%dl
  801176:	8b 45 0c             	mov    0xc(%ebp),%eax
  801179:	8a 00                	mov    (%eax),%al
  80117b:	38 c2                	cmp    %al,%dl
  80117d:	74 e3                	je     801162 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	8a 00                	mov    (%eax),%al
  801184:	0f b6 d0             	movzbl %al,%edx
  801187:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118a:	8a 00                	mov    (%eax),%al
  80118c:	0f b6 c0             	movzbl %al,%eax
  80118f:	29 c2                	sub    %eax,%edx
  801191:	89 d0                	mov    %edx,%eax
}
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    

00801195 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  801198:	eb 09                	jmp    8011a3 <strncmp+0xe>
		n--, p++, q++;
  80119a:	ff 4d 10             	decl   0x10(%ebp)
  80119d:	ff 45 08             	incl   0x8(%ebp)
  8011a0:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  8011a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8011a7:	74 17                	je     8011c0 <strncmp+0x2b>
  8011a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ac:	8a 00                	mov    (%eax),%al
  8011ae:	84 c0                	test   %al,%al
  8011b0:	74 0e                	je     8011c0 <strncmp+0x2b>
  8011b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b5:	8a 10                	mov    (%eax),%dl
  8011b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ba:	8a 00                	mov    (%eax),%al
  8011bc:	38 c2                	cmp    %al,%dl
  8011be:	74 da                	je     80119a <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  8011c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8011c4:	75 07                	jne    8011cd <strncmp+0x38>
		return 0;
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cb:	eb 14                	jmp    8011e1 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8011cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d0:	8a 00                	mov    (%eax),%al
  8011d2:	0f b6 d0             	movzbl %al,%edx
  8011d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d8:	8a 00                	mov    (%eax),%al
  8011da:	0f b6 c0             	movzbl %al,%eax
  8011dd:	29 c2                	sub    %eax,%edx
  8011df:	89 d0                	mov    %edx,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    

008011e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ec:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8011ef:	eb 12                	jmp    801203 <strchr+0x20>
		if (*s == c)
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	8a 00                	mov    (%eax),%al
  8011f6:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8011f9:	75 05                	jne    801200 <strchr+0x1d>
			return (char *) s;
  8011fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fe:	eb 11                	jmp    801211 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801200:	ff 45 08             	incl   0x8(%ebp)
  801203:	8b 45 08             	mov    0x8(%ebp),%eax
  801206:	8a 00                	mov    (%eax),%al
  801208:	84 c0                	test   %al,%al
  80120a:	75 e5                	jne    8011f1 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	83 ec 04             	sub    $0x4,%esp
  801219:	8b 45 0c             	mov    0xc(%ebp),%eax
  80121c:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  80121f:	eb 0d                	jmp    80122e <strfind+0x1b>
		if (*s == c)
  801221:	8b 45 08             	mov    0x8(%ebp),%eax
  801224:	8a 00                	mov    (%eax),%al
  801226:	3a 45 fc             	cmp    -0x4(%ebp),%al
  801229:	74 0e                	je     801239 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80122b:	ff 45 08             	incl   0x8(%ebp)
  80122e:	8b 45 08             	mov    0x8(%ebp),%eax
  801231:	8a 00                	mov    (%eax),%al
  801233:	84 c0                	test   %al,%al
  801235:	75 ea                	jne    801221 <strfind+0xe>
  801237:	eb 01                	jmp    80123a <strfind+0x27>
		if (*s == c)
			break;
  801239:	90                   	nop
	return (char *) s;
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <memset>:


void *
memset(void *v, int c, uint32 n)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  801245:	8b 45 08             	mov    0x8(%ebp),%eax
  801248:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  80124b:	8b 45 10             	mov    0x10(%ebp),%eax
  80124e:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  801251:	eb 0e                	jmp    801261 <memset+0x22>
		*p++ = c;
  801253:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801256:	8d 50 01             	lea    0x1(%eax),%edx
  801259:	89 55 fc             	mov    %edx,-0x4(%ebp)
  80125c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125f:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  801261:	ff 4d f8             	decl   -0x8(%ebp)
  801264:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  801268:	79 e9                	jns    801253 <memset+0x14>
		*p++ = c;

	return v;
  80126a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  801275:	8b 45 0c             	mov    0xc(%ebp),%eax
  801278:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  80127b:	8b 45 08             	mov    0x8(%ebp),%eax
  80127e:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  801281:	eb 16                	jmp    801299 <memcpy+0x2a>
		*d++ = *s++;
  801283:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801286:	8d 50 01             	lea    0x1(%eax),%edx
  801289:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80128c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80128f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801292:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  801295:	8a 12                	mov    (%edx),%dl
  801297:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  801299:	8b 45 10             	mov    0x10(%ebp),%eax
  80129c:	8d 50 ff             	lea    -0x1(%eax),%edx
  80129f:	89 55 10             	mov    %edx,0x10(%ebp)
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	75 dd                	jne    801283 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  8012a6:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  8012b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  8012b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  8012bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  8012c3:	73 50                	jae    801315 <memmove+0x6a>
  8012c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8012c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8012cb:	01 d0                	add    %edx,%eax
  8012cd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  8012d0:	76 43                	jbe    801315 <memmove+0x6a>
		s += n;
  8012d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8012d5:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  8012d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8012db:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  8012de:	eb 10                	jmp    8012f0 <memmove+0x45>
			*--d = *--s;
  8012e0:	ff 4d f8             	decl   -0x8(%ebp)
  8012e3:	ff 4d fc             	decl   -0x4(%ebp)
  8012e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e9:	8a 10                	mov    (%eax),%dl
  8012eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8012ee:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  8012f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012f3:	8d 50 ff             	lea    -0x1(%eax),%edx
  8012f6:	89 55 10             	mov    %edx,0x10(%ebp)
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	75 e3                	jne    8012e0 <memmove+0x35>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8012fd:	eb 23                	jmp    801322 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  8012ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801302:	8d 50 01             	lea    0x1(%eax),%edx
  801305:	89 55 f8             	mov    %edx,-0x8(%ebp)
  801308:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80130b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80130e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  801311:	8a 12                	mov    (%edx),%dl
  801313:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  801315:	8b 45 10             	mov    0x10(%ebp),%eax
  801318:	8d 50 ff             	lea    -0x1(%eax),%edx
  80131b:	89 55 10             	mov    %edx,0x10(%ebp)
  80131e:	85 c0                	test   %eax,%eax
  801320:	75 dd                	jne    8012ff <memmove+0x54>
			*d++ = *s++;

	return dst;
  801322:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801325:	c9                   	leave  
  801326:	c3                   	ret    

00801327 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  801333:	8b 45 0c             	mov    0xc(%ebp),%eax
  801336:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  801339:	eb 2a                	jmp    801365 <memcmp+0x3e>
		if (*s1 != *s2)
  80133b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80133e:	8a 10                	mov    (%eax),%dl
  801340:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801343:	8a 00                	mov    (%eax),%al
  801345:	38 c2                	cmp    %al,%dl
  801347:	74 16                	je     80135f <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  801349:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80134c:	8a 00                	mov    (%eax),%al
  80134e:	0f b6 d0             	movzbl %al,%edx
  801351:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801354:	8a 00                	mov    (%eax),%al
  801356:	0f b6 c0             	movzbl %al,%eax
  801359:	29 c2                	sub    %eax,%edx
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	eb 18                	jmp    801377 <memcmp+0x50>
		s1++, s2++;
  80135f:	ff 45 fc             	incl   -0x4(%ebp)
  801362:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  801365:	8b 45 10             	mov    0x10(%ebp),%eax
  801368:	8d 50 ff             	lea    -0x1(%eax),%edx
  80136b:	89 55 10             	mov    %edx,0x10(%ebp)
  80136e:	85 c0                	test   %eax,%eax
  801370:	75 c9                	jne    80133b <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801372:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801377:	c9                   	leave  
  801378:	c3                   	ret    

00801379 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  80137f:	8b 55 08             	mov    0x8(%ebp),%edx
  801382:	8b 45 10             	mov    0x10(%ebp),%eax
  801385:	01 d0                	add    %edx,%eax
  801387:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80138a:	eb 15                	jmp    8013a1 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  80138c:	8b 45 08             	mov    0x8(%ebp),%eax
  80138f:	8a 00                	mov    (%eax),%al
  801391:	0f b6 d0             	movzbl %al,%edx
  801394:	8b 45 0c             	mov    0xc(%ebp),%eax
  801397:	0f b6 c0             	movzbl %al,%eax
  80139a:	39 c2                	cmp    %eax,%edx
  80139c:	74 0d                	je     8013ab <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80139e:	ff 45 08             	incl   0x8(%ebp)
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  8013a7:	72 e3                	jb     80138c <memfind+0x13>
  8013a9:	eb 01                	jmp    8013ac <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  8013ab:	90                   	nop
	return (void *) s;
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  8013b7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  8013be:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013c5:	eb 03                	jmp    8013ca <strtol+0x19>
		s++;
  8013c7:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	8a 00                	mov    (%eax),%al
  8013cf:	3c 20                	cmp    $0x20,%al
  8013d1:	74 f4                	je     8013c7 <strtol+0x16>
  8013d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d6:	8a 00                	mov    (%eax),%al
  8013d8:	3c 09                	cmp    $0x9,%al
  8013da:	74 eb                	je     8013c7 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  8013dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013df:	8a 00                	mov    (%eax),%al
  8013e1:	3c 2b                	cmp    $0x2b,%al
  8013e3:	75 05                	jne    8013ea <strtol+0x39>
		s++;
  8013e5:	ff 45 08             	incl   0x8(%ebp)
  8013e8:	eb 13                	jmp    8013fd <strtol+0x4c>
	else if (*s == '-')
  8013ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ed:	8a 00                	mov    (%eax),%al
  8013ef:	3c 2d                	cmp    $0x2d,%al
  8013f1:	75 0a                	jne    8013fd <strtol+0x4c>
		s++, neg = 1;
  8013f3:	ff 45 08             	incl   0x8(%ebp)
  8013f6:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8013fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801401:	74 06                	je     801409 <strtol+0x58>
  801403:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801407:	75 20                	jne    801429 <strtol+0x78>
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	8a 00                	mov    (%eax),%al
  80140e:	3c 30                	cmp    $0x30,%al
  801410:	75 17                	jne    801429 <strtol+0x78>
  801412:	8b 45 08             	mov    0x8(%ebp),%eax
  801415:	40                   	inc    %eax
  801416:	8a 00                	mov    (%eax),%al
  801418:	3c 78                	cmp    $0x78,%al
  80141a:	75 0d                	jne    801429 <strtol+0x78>
		s += 2, base = 16;
  80141c:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801420:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  801427:	eb 28                	jmp    801451 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  801429:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80142d:	75 15                	jne    801444 <strtol+0x93>
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	8a 00                	mov    (%eax),%al
  801434:	3c 30                	cmp    $0x30,%al
  801436:	75 0c                	jne    801444 <strtol+0x93>
		s++, base = 8;
  801438:	ff 45 08             	incl   0x8(%ebp)
  80143b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801442:	eb 0d                	jmp    801451 <strtol+0xa0>
	else if (base == 0)
  801444:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801448:	75 07                	jne    801451 <strtol+0xa0>
		base = 10;
  80144a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	8a 00                	mov    (%eax),%al
  801456:	3c 2f                	cmp    $0x2f,%al
  801458:	7e 19                	jle    801473 <strtol+0xc2>
  80145a:	8b 45 08             	mov    0x8(%ebp),%eax
  80145d:	8a 00                	mov    (%eax),%al
  80145f:	3c 39                	cmp    $0x39,%al
  801461:	7f 10                	jg     801473 <strtol+0xc2>
			dig = *s - '0';
  801463:	8b 45 08             	mov    0x8(%ebp),%eax
  801466:	8a 00                	mov    (%eax),%al
  801468:	0f be c0             	movsbl %al,%eax
  80146b:	83 e8 30             	sub    $0x30,%eax
  80146e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801471:	eb 42                	jmp    8014b5 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  801473:	8b 45 08             	mov    0x8(%ebp),%eax
  801476:	8a 00                	mov    (%eax),%al
  801478:	3c 60                	cmp    $0x60,%al
  80147a:	7e 19                	jle    801495 <strtol+0xe4>
  80147c:	8b 45 08             	mov    0x8(%ebp),%eax
  80147f:	8a 00                	mov    (%eax),%al
  801481:	3c 7a                	cmp    $0x7a,%al
  801483:	7f 10                	jg     801495 <strtol+0xe4>
			dig = *s - 'a' + 10;
  801485:	8b 45 08             	mov    0x8(%ebp),%eax
  801488:	8a 00                	mov    (%eax),%al
  80148a:	0f be c0             	movsbl %al,%eax
  80148d:	83 e8 57             	sub    $0x57,%eax
  801490:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801493:	eb 20                	jmp    8014b5 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  801495:	8b 45 08             	mov    0x8(%ebp),%eax
  801498:	8a 00                	mov    (%eax),%al
  80149a:	3c 40                	cmp    $0x40,%al
  80149c:	7e 39                	jle    8014d7 <strtol+0x126>
  80149e:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a1:	8a 00                	mov    (%eax),%al
  8014a3:	3c 5a                	cmp    $0x5a,%al
  8014a5:	7f 30                	jg     8014d7 <strtol+0x126>
			dig = *s - 'A' + 10;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	8a 00                	mov    (%eax),%al
  8014ac:	0f be c0             	movsbl %al,%eax
  8014af:	83 e8 37             	sub    $0x37,%eax
  8014b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	3b 45 10             	cmp    0x10(%ebp),%eax
  8014bb:	7d 19                	jge    8014d6 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  8014bd:	ff 45 08             	incl   0x8(%ebp)
  8014c0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014c3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014c7:	89 c2                	mov    %eax,%edx
  8014c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cc:	01 d0                	add    %edx,%eax
  8014ce:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  8014d1:	e9 7b ff ff ff       	jmp    801451 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  8014d6:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014d7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014db:	74 08                	je     8014e5 <strtol+0x134>
		*endptr = (char *) s;
  8014dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8014e5:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8014e9:	74 07                	je     8014f2 <strtol+0x141>
  8014eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8014ee:	f7 d8                	neg    %eax
  8014f0:	eb 03                	jmp    8014f5 <strtol+0x144>
  8014f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8014f5:	c9                   	leave  
  8014f6:	c3                   	ret    

008014f7 <ltostr>:

void
ltostr(long value, char *str)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 20             	sub    $0x20,%esp
	int neg = 0;
  8014fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int s = 0 ;
  801504:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// plus/minus sign
	if (value < 0)
  80150b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80150f:	79 13                	jns    801524 <ltostr+0x2d>
	{
		neg = 1;
  801511:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
		str[0] = '-';
  801518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151b:	c6 00 2d             	movb   $0x2d,(%eax)
		value = value * -1 ;
  80151e:	f7 5d 08             	negl   0x8(%ebp)
		s++ ;
  801521:	ff 45 f8             	incl   -0x8(%ebp)
	}
	do
	{
		int mod = value % 10 ;
  801524:	8b 45 08             	mov    0x8(%ebp),%eax
  801527:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80152c:	99                   	cltd   
  80152d:	f7 f9                	idiv   %ecx
  80152f:	89 55 ec             	mov    %edx,-0x14(%ebp)
		str[s++] = mod + '0' ;
  801532:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801535:	8d 50 01             	lea    0x1(%eax),%edx
  801538:	89 55 f8             	mov    %edx,-0x8(%ebp)
  80153b:	89 c2                	mov    %eax,%edx
  80153d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801540:	01 d0                	add    %edx,%eax
  801542:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801545:	83 c2 30             	add    $0x30,%edx
  801548:	88 10                	mov    %dl,(%eax)
		value = value / 10 ;
  80154a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80154d:	b8 67 66 66 66       	mov    $0x66666667,%eax
  801552:	f7 e9                	imul   %ecx
  801554:	c1 fa 02             	sar    $0x2,%edx
  801557:	89 c8                	mov    %ecx,%eax
  801559:	c1 f8 1f             	sar    $0x1f,%eax
  80155c:	29 c2                	sub    %eax,%edx
  80155e:	89 d0                	mov    %edx,%eax
  801560:	89 45 08             	mov    %eax,0x8(%ebp)
	/*2023 FIX el7 :)*/
	//} while (value % 10 != 0);
	} while (value != 0);
  801563:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801567:	75 bb                	jne    801524 <ltostr+0x2d>

	//reverse the string
	int start = 0 ;
  801569:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int end = s-1 ;
  801570:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801573:	48                   	dec    %eax
  801574:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (neg)
  801577:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80157b:	74 3d                	je     8015ba <ltostr+0xc3>
		start = 1 ;
  80157d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while(start<end)
  801584:	eb 34                	jmp    8015ba <ltostr+0xc3>
	{
		char tmp = str[start] ;
  801586:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801589:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158c:	01 d0                	add    %edx,%eax
  80158e:	8a 00                	mov    (%eax),%al
  801590:	88 45 eb             	mov    %al,-0x15(%ebp)
		str[start] = str[end] ;
  801593:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801596:	8b 45 0c             	mov    0xc(%ebp),%eax
  801599:	01 c2                	add    %eax,%edx
  80159b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  80159e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a1:	01 c8                	add    %ecx,%eax
  8015a3:	8a 00                	mov    (%eax),%al
  8015a5:	88 02                	mov    %al,(%edx)
		str[end] = tmp;
  8015a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ad:	01 c2                	add    %eax,%edx
  8015af:	8a 45 eb             	mov    -0x15(%ebp),%al
  8015b2:	88 02                	mov    %al,(%edx)
		start++ ;
  8015b4:	ff 45 f4             	incl   -0xc(%ebp)
		end-- ;
  8015b7:	ff 4d f0             	decl   -0x10(%ebp)
	//reverse the string
	int start = 0 ;
	int end = s-1 ;
	if (neg)
		start = 1 ;
	while(start<end)
  8015ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015bd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8015c0:	7c c4                	jl     801586 <ltostr+0x8f>
		str[end] = tmp;
		start++ ;
		end-- ;
	}

	str[s] = 0 ;
  8015c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
  8015c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c8:	01 d0                	add    %edx,%eax
  8015ca:	c6 00 00             	movb   $0x0,(%eax)
	// we don't properly detect overflow!

}
  8015cd:	90                   	nop
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <strcconcat>:

void
strcconcat(const char *str1, const char *str2, char *final)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	83 ec 10             	sub    $0x10,%esp
	int len1 = strlen(str1);
  8015d6:	ff 75 08             	pushl  0x8(%ebp)
  8015d9:	e8 73 fa ff ff       	call   801051 <strlen>
  8015de:	83 c4 04             	add    $0x4,%esp
  8015e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int len2 = strlen(str2);
  8015e4:	ff 75 0c             	pushl  0xc(%ebp)
  8015e7:	e8 65 fa ff ff       	call   801051 <strlen>
  8015ec:	83 c4 04             	add    $0x4,%esp
  8015ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int s = 0 ;
  8015f2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	for (s=0 ; s < len1 ; s++)
  8015f9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  801600:	eb 17                	jmp    801619 <strcconcat+0x49>
		final[s] = str1[s] ;
  801602:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801605:	8b 45 10             	mov    0x10(%ebp),%eax
  801608:	01 c2                	add    %eax,%edx
  80160a:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	01 c8                	add    %ecx,%eax
  801612:	8a 00                	mov    (%eax),%al
  801614:	88 02                	mov    %al,(%edx)
strcconcat(const char *str1, const char *str2, char *final)
{
	int len1 = strlen(str1);
	int len2 = strlen(str2);
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
  801616:	ff 45 fc             	incl   -0x4(%ebp)
  801619:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80161c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  80161f:	7c e1                	jl     801602 <strcconcat+0x32>
		final[s] = str1[s] ;

	int i = 0 ;
  801621:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (i=0 ; i < len2 ; i++)
  801628:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  80162f:	eb 1f                	jmp    801650 <strcconcat+0x80>
		final[s++] = str2[i] ;
  801631:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801634:	8d 50 01             	lea    0x1(%eax),%edx
  801637:	89 55 fc             	mov    %edx,-0x4(%ebp)
  80163a:	89 c2                	mov    %eax,%edx
  80163c:	8b 45 10             	mov    0x10(%ebp),%eax
  80163f:	01 c2                	add    %eax,%edx
  801641:	8b 4d f8             	mov    -0x8(%ebp),%ecx
  801644:	8b 45 0c             	mov    0xc(%ebp),%eax
  801647:	01 c8                	add    %ecx,%eax
  801649:	8a 00                	mov    (%eax),%al
  80164b:	88 02                	mov    %al,(%edx)
	int s = 0 ;
	for (s=0 ; s < len1 ; s++)
		final[s] = str1[s] ;

	int i = 0 ;
	for (i=0 ; i < len2 ; i++)
  80164d:	ff 45 f8             	incl   -0x8(%ebp)
  801650:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801653:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  801656:	7c d9                	jl     801631 <strcconcat+0x61>
		final[s++] = str2[i] ;

	final[s] = 0;
  801658:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80165b:	8b 45 10             	mov    0x10(%ebp),%eax
  80165e:	01 d0                	add    %edx,%eax
  801660:	c6 00 00             	movb   $0x0,(%eax)
}
  801663:	90                   	nop
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <strsplit>:
int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  801669:	8b 45 14             	mov    0x14(%ebp),%eax
  80166c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  801672:	8b 45 14             	mov    0x14(%ebp),%eax
  801675:	8b 00                	mov    (%eax),%eax
  801677:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80167e:	8b 45 10             	mov    0x10(%ebp),%eax
  801681:	01 d0                	add    %edx,%eax
  801683:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  801689:	eb 0c                	jmp    801697 <strsplit+0x31>
			*string++ = 0;
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	8d 50 01             	lea    0x1(%eax),%edx
  801691:	89 55 08             	mov    %edx,0x8(%ebp)
  801694:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1)
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  801697:	8b 45 08             	mov    0x8(%ebp),%eax
  80169a:	8a 00                	mov    (%eax),%al
  80169c:	84 c0                	test   %al,%al
  80169e:	74 18                	je     8016b8 <strsplit+0x52>
  8016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a3:	8a 00                	mov    (%eax),%al
  8016a5:	0f be c0             	movsbl %al,%eax
  8016a8:	50                   	push   %eax
  8016a9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ac:	e8 32 fb ff ff       	call   8011e3 <strchr>
  8016b1:	83 c4 08             	add    $0x8,%esp
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	75 d3                	jne    80168b <strsplit+0x25>
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
  8016b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bb:	8a 00                	mov    (%eax),%al
  8016bd:	84 c0                	test   %al,%al
  8016bf:	74 5a                	je     80171b <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1)
  8016c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c4:	8b 00                	mov    (%eax),%eax
  8016c6:	83 f8 0f             	cmp    $0xf,%eax
  8016c9:	75 07                	jne    8016d2 <strsplit+0x6c>
		{
			return 0;
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d0:	eb 66                	jmp    801738 <strsplit+0xd2>
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  8016d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d5:	8b 00                	mov    (%eax),%eax
  8016d7:	8d 48 01             	lea    0x1(%eax),%ecx
  8016da:	8b 55 14             	mov    0x14(%ebp),%edx
  8016dd:	89 0a                	mov    %ecx,(%edx)
  8016df:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8016e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e9:	01 c2                	add    %eax,%edx
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  8016f0:	eb 03                	jmp    8016f5 <strsplit+0x8f>
			string++;
  8016f2:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}

		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  8016f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f8:	8a 00                	mov    (%eax),%al
  8016fa:	84 c0                	test   %al,%al
  8016fc:	74 8b                	je     801689 <strsplit+0x23>
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	8a 00                	mov    (%eax),%al
  801703:	0f be c0             	movsbl %al,%eax
  801706:	50                   	push   %eax
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	e8 d4 fa ff ff       	call   8011e3 <strchr>
  80170f:	83 c4 08             	add    $0x8,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	74 dc                	je     8016f2 <strsplit+0x8c>
			string++;
	}
  801716:	e9 6e ff ff ff       	jmp    801689 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;

		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  80171b:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  80171c:	8b 45 14             	mov    0x14(%ebp),%eax
  80171f:	8b 00                	mov    (%eax),%eax
  801721:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801728:	8b 45 10             	mov    0x10(%ebp),%eax
  80172b:	01 d0                	add    %edx,%eax
  80172d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  801733:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801738:	c9                   	leave  
  801739:	c3                   	ret    

0080173a <str2lower>:


char* str2lower(char *dst, const char *src)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	panic("str2lower is not implemented yet!");
  801740:	83 ec 04             	sub    $0x4,%esp
  801743:	68 48 48 80 00       	push   $0x804848
  801748:	68 3f 01 00 00       	push   $0x13f
  80174d:	68 6a 48 80 00       	push   $0x80486a
  801752:	e8 a9 ef ff ff       	call   800700 <_panic>

00801757 <sbrk>:
//=============================================
// [1] CHANGE THE BREAK LIMIT OF THE USER HEAP:
//=============================================
/*2023*/
void* sbrk(int increment)
{
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	83 ec 08             	sub    $0x8,%esp
	return (void*) sys_sbrk(increment);
  80175d:	83 ec 0c             	sub    $0xc,%esp
  801760:	ff 75 08             	pushl  0x8(%ebp)
  801763:	e8 9d 0a 00 00       	call   802205 <sys_sbrk>
  801768:	83 c4 10             	add    $0x10,%esp
}
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    

0080176d <malloc>:
	if(pt_get_page_permissions(ptr_page_directory,virtual_address) & PERM_AVAILABLE)return 1;
	//if(virtual_address&PERM_AVAILABLE) return 1;
	return 0;
}*/
void* malloc(uint32 size)
{
  80176d:	55                   	push   %ebp
  80176e:	89 e5                	mov    %esp,%ebp
  801770:	83 ec 38             	sub    $0x38,%esp
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
  801773:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  801777:	75 0a                	jne    801783 <malloc+0x16>
  801779:	b8 00 00 00 00       	mov    $0x0,%eax
  80177e:	e9 07 02 00 00       	jmp    80198a <malloc+0x21d>
	// Write your code here, remove the panic and write your code
//	panic("malloc() is not implemented yet...!!");
//	return NULL;
	//Use sys_isUHeapPlacementStrategyFIRSTFIT() and	sys_isUHeapPlacementStrategyBESTFIT()
	//to check the current strategy
	uint32 num_pages = ROUNDUP(size ,PAGE_SIZE) / PAGE_SIZE;
  801783:	c7 45 dc 00 10 00 00 	movl   $0x1000,-0x24(%ebp)
  80178a:	8b 55 08             	mov    0x8(%ebp),%edx
  80178d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801790:	01 d0                	add    %edx,%eax
  801792:	48                   	dec    %eax
  801793:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801796:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	f7 75 dc             	divl   -0x24(%ebp)
  8017a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8017a4:	29 d0                	sub    %edx,%eax
  8017a6:	c1 e8 0c             	shr    $0xc,%eax
  8017a9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	uint32 max_no_of_pages = ROUNDDOWN((uint32)USER_HEAP_MAX - (myEnv->heap_hard_limit + (uint32)PAGE_SIZE) ,PAGE_SIZE) / PAGE_SIZE;
  8017ac:	a1 20 50 80 00       	mov    0x805020,%eax
  8017b1:	8b 40 78             	mov    0x78(%eax),%eax
  8017b4:	ba 00 f0 ff 9f       	mov    $0x9ffff000,%edx
  8017b9:	29 c2                	sub    %eax,%edx
  8017bb:	89 d0                	mov    %edx,%eax
  8017bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8017c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017c8:	c1 e8 0c             	shr    $0xc,%eax
  8017cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
	void *ptr = NULL;
  8017ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	if (size <= DYN_ALLOC_MAX_BLOCK_SIZE)
  8017d5:	81 7d 08 00 08 00 00 	cmpl   $0x800,0x8(%ebp)
  8017dc:	77 42                	ja     801820 <malloc+0xb3>
	{
		if (sys_isUHeapPlacementStrategyFIRSTFIT())
  8017de:	e8 a6 08 00 00       	call   802089 <sys_isUHeapPlacementStrategyFIRSTFIT>
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	74 16                	je     8017fd <malloc+0x90>
		{
			//cprintf("47\n");
			ptr = alloc_block_FF(size);
  8017e7:	83 ec 0c             	sub    $0xc,%esp
  8017ea:	ff 75 08             	pushl  0x8(%ebp)
  8017ed:	e8 e6 0d 00 00       	call   8025d8 <alloc_block_FF>
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8017f8:	e9 8a 01 00 00       	jmp    801987 <malloc+0x21a>
		}
		else if (sys_isUHeapPlacementStrategyBESTFIT())
  8017fd:	e8 b8 08 00 00       	call   8020ba <sys_isUHeapPlacementStrategyBESTFIT>
  801802:	85 c0                	test   %eax,%eax
  801804:	0f 84 7d 01 00 00    	je     801987 <malloc+0x21a>
			ptr = alloc_block_BF(size);
  80180a:	83 ec 0c             	sub    $0xc,%esp
  80180d:	ff 75 08             	pushl  0x8(%ebp)
  801810:	e8 7f 12 00 00       	call   802a94 <alloc_block_BF>
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80181b:	e9 67 01 00 00       	jmp    801987 <malloc+0x21a>
	}
	else if(num_pages < max_no_of_pages-1) // the else statement in kern/mem/kheap.c/kmalloc is wrong, rewrite it to be correct.
  801820:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801823:	48                   	dec    %eax
  801824:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  801827:	0f 86 53 01 00 00    	jbe    801980 <malloc+0x213>
	{
		//cprintf("52\n");
		uint32 i = myEnv->heap_hard_limit + PAGE_SIZE;											// start: hardlimit + 4  ______ end: KERNEL_HEAP_MAX
  80182d:	a1 20 50 80 00       	mov    0x805020,%eax
  801832:	8b 40 78             	mov    0x78(%eax),%eax
  801835:	05 00 10 00 00       	add    $0x1000,%eax
  80183a:	89 45 f0             	mov    %eax,-0x10(%ebp)
		bool ok = 0;
  80183d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		while (i < (uint32)USER_HEAP_MAX)
  801844:	e9 de 00 00 00       	jmp    801927 <malloc+0x1ba>
		{
			//cprintf("57\n");
			if (!isPageMarked[UHEAP_PAGE_INDEX(i)])
  801849:	a1 20 50 80 00       	mov    0x805020,%eax
  80184e:	8b 40 78             	mov    0x78(%eax),%eax
  801851:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801854:	29 c2                	sub    %eax,%edx
  801856:	89 d0                	mov    %edx,%eax
  801858:	2d 00 10 00 00       	sub    $0x1000,%eax
  80185d:	c1 e8 0c             	shr    $0xc,%eax
  801860:	8b 04 85 60 92 80 00 	mov    0x809260(,%eax,4),%eax
  801867:	85 c0                	test   %eax,%eax
  801869:	0f 85 ab 00 00 00    	jne    80191a <malloc+0x1ad>
			{
				//cprintf("60\n");
				uint32 j = i + (uint32)PAGE_SIZE;
  80186f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801872:	05 00 10 00 00       	add    $0x1000,%eax
  801877:	89 45 e8             	mov    %eax,-0x18(%ebp)
				uint32 cnt = 0;
  80187a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

				//cprintf("64\n");
				while(cnt < num_pages - 1)
  801881:	eb 47                	jmp    8018ca <malloc+0x15d>
				{
					if(j >= (uint32)USER_HEAP_MAX) return NULL;
  801883:	81 7d e8 ff ff ff 9f 	cmpl   $0x9fffffff,-0x18(%ebp)
  80188a:	76 0a                	jbe    801896 <malloc+0x129>
  80188c:	b8 00 00 00 00       	mov    $0x0,%eax
  801891:	e9 f4 00 00 00       	jmp    80198a <malloc+0x21d>
					if (isPageMarked[UHEAP_PAGE_INDEX(j)])
  801896:	a1 20 50 80 00       	mov    0x805020,%eax
  80189b:	8b 40 78             	mov    0x78(%eax),%eax
  80189e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8018a1:	29 c2                	sub    %eax,%edx
  8018a3:	89 d0                	mov    %edx,%eax
  8018a5:	2d 00 10 00 00       	sub    $0x1000,%eax
  8018aa:	c1 e8 0c             	shr    $0xc,%eax
  8018ad:	8b 04 85 60 92 80 00 	mov    0x809260(,%eax,4),%eax
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	74 08                	je     8018c0 <malloc+0x153>
					{
						//cprintf("71\n");
						i = j;
  8018b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8018bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
						goto sayed;
  8018be:	eb 5a                	jmp    80191a <malloc+0x1ad>
					}

					j += (uint32)PAGE_SIZE; // <-- changed, was j ++
  8018c0:	81 45 e8 00 10 00 00 	addl   $0x1000,-0x18(%ebp)

					cnt++;
  8018c7:	ff 45 e4             	incl   -0x1c(%ebp)
				//cprintf("60\n");
				uint32 j = i + (uint32)PAGE_SIZE;
				uint32 cnt = 0;

				//cprintf("64\n");
				while(cnt < num_pages - 1)
  8018ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018cd:	48                   	dec    %eax
  8018ce:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  8018d1:	77 b0                	ja     801883 <malloc+0x116>

					j += (uint32)PAGE_SIZE; // <-- changed, was j ++

					cnt++;
				}
				ok = 1;
  8018d3:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
				for(int k = 0;k<num_pages;k++)
  8018da:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8018e1:	eb 2f                	jmp    801912 <malloc+0x1a5>
				{
					isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+i)]=1;
  8018e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018e6:	c1 e0 0c             	shl    $0xc,%eax
  8018e9:	89 c2                	mov    %eax,%edx
  8018eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ee:	01 c2                	add    %eax,%edx
  8018f0:	a1 20 50 80 00       	mov    0x805020,%eax
  8018f5:	8b 40 78             	mov    0x78(%eax),%eax
  8018f8:	29 c2                	sub    %eax,%edx
  8018fa:	89 d0                	mov    %edx,%eax
  8018fc:	2d 00 10 00 00       	sub    $0x1000,%eax
  801901:	c1 e8 0c             	shr    $0xc,%eax
  801904:	c7 04 85 60 92 80 00 	movl   $0x1,0x809260(,%eax,4)
  80190b:	01 00 00 00 
					j += (uint32)PAGE_SIZE; // <-- changed, was j ++

					cnt++;
				}
				ok = 1;
				for(int k = 0;k<num_pages;k++)
  80190f:	ff 45 e0             	incl   -0x20(%ebp)
  801912:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801915:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  801918:	72 c9                	jb     8018e3 <malloc+0x176>
				}
				//cprintf("79\n");

			}
			sayed:
			if(ok) break;
  80191a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80191e:	75 16                	jne    801936 <malloc+0x1c9>
			i += (uint32)PAGE_SIZE;
  801920:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
	else if(num_pages < max_no_of_pages-1) // the else statement in kern/mem/kheap.c/kmalloc is wrong, rewrite it to be correct.
	{
		//cprintf("52\n");
		uint32 i = myEnv->heap_hard_limit + PAGE_SIZE;											// start: hardlimit + 4  ______ end: KERNEL_HEAP_MAX
		bool ok = 0;
		while (i < (uint32)USER_HEAP_MAX)
  801927:	81 7d f0 ff ff ff 9f 	cmpl   $0x9fffffff,-0x10(%ebp)
  80192e:	0f 86 15 ff ff ff    	jbe    801849 <malloc+0xdc>
  801934:	eb 01                	jmp    801937 <malloc+0x1ca>
				}
				//cprintf("79\n");

			}
			sayed:
			if(ok) break;
  801936:	90                   	nop
			i += (uint32)PAGE_SIZE;
		}

		if(!ok) return NULL;
  801937:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80193b:	75 07                	jne    801944 <malloc+0x1d7>
  80193d:	b8 00 00 00 00       	mov    $0x0,%eax
  801942:	eb 46                	jmp    80198a <malloc+0x21d>
		ptr = (void*)i;
  801944:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801947:	89 45 f4             	mov    %eax,-0xc(%ebp)
		no_pages_marked[UHEAP_PAGE_INDEX(i)] = num_pages;
  80194a:	a1 20 50 80 00       	mov    0x805020,%eax
  80194f:	8b 40 78             	mov    0x78(%eax),%eax
  801952:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801955:	29 c2                	sub    %eax,%edx
  801957:	89 d0                	mov    %edx,%eax
  801959:	2d 00 10 00 00       	sub    $0x1000,%eax
  80195e:	c1 e8 0c             	shr    $0xc,%eax
  801961:	89 c2                	mov    %eax,%edx
  801963:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801966:	89 04 95 60 92 88 00 	mov    %eax,0x889260(,%edx,4)
		sys_allocate_user_mem(i, size);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	ff 75 08             	pushl  0x8(%ebp)
  801973:	ff 75 f0             	pushl  -0x10(%ebp)
  801976:	e8 c1 08 00 00       	call   80223c <sys_allocate_user_mem>
  80197b:	83 c4 10             	add    $0x10,%esp
  80197e:	eb 07                	jmp    801987 <malloc+0x21a>
		//cprintf("91\n");
	}
	else
	{
		return NULL;
  801980:	b8 00 00 00 00       	mov    $0x0,%eax
  801985:	eb 03                	jmp    80198a <malloc+0x21d>
	}
	return ptr;
  801987:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <free>:

//=================================
// [3] FREE SPACE FROM USER HEAP:
//=================================
void free(void* va)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 18             	sub    $0x18,%esp
	//TODO: [PROJECT'24.MS2 - #14] [3] USER HEAP [USER SIDE] - free()
	// Write your code here, remove the panic and write your code
//	panic("free() is not implemented yet...!!");
	//what's the hard_limit of user heap
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
  801992:	a1 20 50 80 00       	mov    0x805020,%eax
  801997:	8b 40 78             	mov    0x78(%eax),%eax
  80199a:	05 00 10 00 00       	add    $0x1000,%eax
  80199f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 size = 0;
  8019a2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	if((uint32)va < myEnv->heap_hard_limit){
  8019a9:	a1 20 50 80 00       	mov    0x805020,%eax
  8019ae:	8b 50 78             	mov    0x78(%eax),%edx
  8019b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b4:	39 c2                	cmp    %eax,%edx
  8019b6:	76 24                	jbe    8019dc <free+0x50>
		size = get_block_size(va);
  8019b8:	83 ec 0c             	sub    $0xc,%esp
  8019bb:	ff 75 08             	pushl  0x8(%ebp)
  8019be:	e8 95 08 00 00       	call   802258 <get_block_size>
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
		free_block(va);
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	ff 75 08             	pushl  0x8(%ebp)
  8019cf:	e8 c8 1a 00 00       	call   80349c <free_block>
  8019d4:	83 c4 10             	add    $0x10,%esp
		}
		sys_free_user_mem((uint32)va, size);
	} else{
		panic("User free: The virtual Address is invalid");
	}
}
  8019d7:	e9 ac 00 00 00       	jmp    801a88 <free+0xfc>
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
	uint32 size = 0;
	if((uint32)va < myEnv->heap_hard_limit){
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
  8019dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019df:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8019e2:	0f 82 89 00 00 00    	jb     801a71 <free+0xe5>
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	3d ff ff ff 9f       	cmp    $0x9fffffff,%eax
  8019f0:	77 7f                	ja     801a71 <free+0xe5>
		uint32 no_of_pages = no_pages_marked[UHEAP_PAGE_INDEX((uint32)va)];
  8019f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8019f5:	a1 20 50 80 00       	mov    0x805020,%eax
  8019fa:	8b 40 78             	mov    0x78(%eax),%eax
  8019fd:	29 c2                	sub    %eax,%edx
  8019ff:	89 d0                	mov    %edx,%eax
  801a01:	2d 00 10 00 00       	sub    $0x1000,%eax
  801a06:	c1 e8 0c             	shr    $0xc,%eax
  801a09:	8b 04 85 60 92 88 00 	mov    0x889260(,%eax,4),%eax
  801a10:	89 45 e8             	mov    %eax,-0x18(%ebp)
		size = no_of_pages * PAGE_SIZE;
  801a13:	8b 45 e8             	mov    -0x18(%ebp),%eax
  801a16:	c1 e0 0c             	shl    $0xc,%eax
  801a19:	89 45 ec             	mov    %eax,-0x14(%ebp)
		for(int k = 0;k<no_of_pages;k++)
  801a1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  801a23:	eb 2f                	jmp    801a54 <free+0xc8>
		{
			isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+(uint32)va)]=0;
  801a25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a28:	c1 e0 0c             	shl    $0xc,%eax
  801a2b:	89 c2                	mov    %eax,%edx
  801a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a30:	01 c2                	add    %eax,%edx
  801a32:	a1 20 50 80 00       	mov    0x805020,%eax
  801a37:	8b 40 78             	mov    0x78(%eax),%eax
  801a3a:	29 c2                	sub    %eax,%edx
  801a3c:	89 d0                	mov    %edx,%eax
  801a3e:	2d 00 10 00 00       	sub    $0x1000,%eax
  801a43:	c1 e8 0c             	shr    $0xc,%eax
  801a46:	c7 04 85 60 92 80 00 	movl   $0x0,0x809260(,%eax,4)
  801a4d:	00 00 00 00 
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
		uint32 no_of_pages = no_pages_marked[UHEAP_PAGE_INDEX((uint32)va)];
		size = no_of_pages * PAGE_SIZE;
		for(int k = 0;k<no_of_pages;k++)
  801a51:	ff 45 f4             	incl   -0xc(%ebp)
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  801a5a:	72 c9                	jb     801a25 <free+0x99>
		{
			isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+(uint32)va)]=0;
		}
		sys_free_user_mem((uint32)va, size);
  801a5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5f:	83 ec 08             	sub    $0x8,%esp
  801a62:	ff 75 ec             	pushl  -0x14(%ebp)
  801a65:	50                   	push   %eax
  801a66:	e8 b5 07 00 00       	call   802220 <sys_free_user_mem>
  801a6b:	83 c4 10             	add    $0x10,%esp
	uint32 pageA_start = myEnv->heap_hard_limit + PAGE_SIZE;
	uint32 size = 0;
	if((uint32)va < myEnv->heap_hard_limit){
		size = get_block_size(va);
		free_block(va);
	} else if((uint32)va >= pageA_start && (uint32)va < USER_HEAP_MAX){
  801a6e:	90                   	nop
		}
		sys_free_user_mem((uint32)va, size);
	} else{
		panic("User free: The virtual Address is invalid");
	}
}
  801a6f:	eb 17                	jmp    801a88 <free+0xfc>
		{
			isPageMarked[UHEAP_PAGE_INDEX((k*PAGE_SIZE)+(uint32)va)]=0;
		}
		sys_free_user_mem((uint32)va, size);
	} else{
		panic("User free: The virtual Address is invalid");
  801a71:	83 ec 04             	sub    $0x4,%esp
  801a74:	68 78 48 80 00       	push   $0x804878
  801a79:	68 84 00 00 00       	push   $0x84
  801a7e:	68 a2 48 80 00       	push   $0x8048a2
  801a83:	e8 78 ec ff ff       	call   800700 <_panic>
	}
}
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <smalloc>:

//=================================
// [4] ALLOCATE SHARED VARIABLE:
//=================================
void* smalloc(char *sharedVarName, uint32 size, uint8 isWritable)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 28             	sub    $0x28,%esp
  801a90:	8b 45 10             	mov    0x10(%ebp),%eax
  801a93:	88 45 e4             	mov    %al,-0x1c(%ebp)
	//==============================================================
	//DON'T CHANGE THIS CODE========================================
	if (size == 0) return NULL ;
  801a96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a9a:	75 07                	jne    801aa3 <smalloc+0x19>
  801a9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa1:	eb 74                	jmp    801b17 <smalloc+0x8d>
	//==============================================================
	//TODO: [PROJECT'24.MS2 - #18] [4] SHARED MEMORY [USER SIDE] - smalloc()
	// Write your code here, remove the panic and write your code
	//panic("smalloc() is not implemented yet...!!");
	void *ptr = malloc(MAX(size,PAGE_SIZE));
  801aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801aa9:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  801ab0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab6:	39 d0                	cmp    %edx,%eax
  801ab8:	73 02                	jae    801abc <smalloc+0x32>
  801aba:	89 d0                	mov    %edx,%eax
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	50                   	push   %eax
  801ac0:	e8 a8 fc ff ff       	call   80176d <malloc>
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(ptr == NULL) return NULL;
  801acb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  801acf:	75 07                	jne    801ad8 <smalloc+0x4e>
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad6:	eb 3f                	jmp    801b17 <smalloc+0x8d>
	 int ret = sys_createSharedObject(sharedVarName, size,  isWritable, ptr);
  801ad8:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
  801adc:	ff 75 ec             	pushl  -0x14(%ebp)
  801adf:	50                   	push   %eax
  801ae0:	ff 75 0c             	pushl  0xc(%ebp)
  801ae3:	ff 75 08             	pushl  0x8(%ebp)
  801ae6:	e8 3c 03 00 00       	call   801e27 <sys_createSharedObject>
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	89 45 e8             	mov    %eax,-0x18(%ebp)
	 if(ret == E_NO_SHARE || ret == E_SHARED_MEM_EXISTS) return NULL;
  801af1:	83 7d e8 f2          	cmpl   $0xfffffff2,-0x18(%ebp)
  801af5:	74 06                	je     801afd <smalloc+0x73>
  801af7:	83 7d e8 f1          	cmpl   $0xfffffff1,-0x18(%ebp)
  801afb:	75 07                	jne    801b04 <smalloc+0x7a>
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
  801b02:	eb 13                	jmp    801b17 <smalloc+0x8d>
	 cprintf("153\n");
  801b04:	83 ec 0c             	sub    $0xc,%esp
  801b07:	68 ae 48 80 00       	push   $0x8048ae
  801b0c:	e8 ac ee ff ff       	call   8009bd <cprintf>
  801b11:	83 c4 10             	add    $0x10,%esp
	 return ptr;
  801b14:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <sget>:

//========================================
// [5] SHARE ON ALLOCATED SHARED VARIABLE:
//========================================
void* sget(int32 ownerEnvID, char *sharedVarName)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 28             	sub    $0x28,%esp
	//TODO: [PROJECT'24.MS2 - #20] [4] SHARED MEMORY [USER SIDE] - sget()
	// Write your code here, remove the panic and write your code
	//panic("sget() is not implemented yet...!!");
	int size = sys_getSizeOfSharedObject(ownerEnvID,sharedVarName);
  801b1f:	83 ec 08             	sub    $0x8,%esp
  801b22:	ff 75 0c             	pushl  0xc(%ebp)
  801b25:	ff 75 08             	pushl  0x8(%ebp)
  801b28:	e8 24 03 00 00       	call   801e51 <sys_getSizeOfSharedObject>
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(size == E_SHARED_MEM_NOT_EXISTS) return NULL;
  801b33:	83 7d f4 f0          	cmpl   $0xfffffff0,-0xc(%ebp)
  801b37:	75 07                	jne    801b40 <sget+0x27>
  801b39:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3e:	eb 5c                	jmp    801b9c <sget+0x83>
	void * ptr = malloc(MAX(size,PAGE_SIZE));
  801b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801b46:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
  801b4d:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b53:	39 d0                	cmp    %edx,%eax
  801b55:	7d 02                	jge    801b59 <sget+0x40>
  801b57:	89 d0                	mov    %edx,%eax
  801b59:	83 ec 0c             	sub    $0xc,%esp
  801b5c:	50                   	push   %eax
  801b5d:	e8 0b fc ff ff       	call   80176d <malloc>
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	89 45 e8             	mov    %eax,-0x18(%ebp)
	if(ptr == NULL) return NULL;
  801b68:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  801b6c:	75 07                	jne    801b75 <sget+0x5c>
  801b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b73:	eb 27                	jmp    801b9c <sget+0x83>
	int ret = sys_getSharedObject(ownerEnvID,sharedVarName,ptr);
  801b75:	83 ec 04             	sub    $0x4,%esp
  801b78:	ff 75 e8             	pushl  -0x18(%ebp)
  801b7b:	ff 75 0c             	pushl  0xc(%ebp)
  801b7e:	ff 75 08             	pushl  0x8(%ebp)
  801b81:	e8 e8 02 00 00       	call   801e6e <sys_getSharedObject>
  801b86:	83 c4 10             	add    $0x10,%esp
  801b89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if(ret == E_SHARED_MEM_NOT_EXISTS ) return NULL;
  801b8c:	83 7d e4 f0          	cmpl   $0xfffffff0,-0x1c(%ebp)
  801b90:	75 07                	jne    801b99 <sget+0x80>
  801b92:	b8 00 00 00 00       	mov    $0x0,%eax
  801b97:	eb 03                	jmp    801b9c <sget+0x83>
	return ptr;
  801b99:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  801b9c:	c9                   	leave  
  801b9d:	c3                   	ret    

00801b9e <sfree>:
//	use sys_freeSharedObject(...); which switches to the kernel mode,
//	calls freeSharedObject(...) in "shared_memory_manager.c", then switch back to the user mode here
//	the freeSharedObject() function is empty, make sure to implement it.

void sfree(void* virtual_address)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	83 ec 08             	sub    $0x8,%esp
	//TODO: [PROJECT'24.MS2 - BONUS#4] [4] SHARED MEMORY [USER SIDE] - sfree()
	// Write your code here, remove the panic and write your code
	panic("sfree() is not implemented yet...!!");
  801ba4:	83 ec 04             	sub    $0x4,%esp
  801ba7:	68 b4 48 80 00       	push   $0x8048b4
  801bac:	68 c2 00 00 00       	push   $0xc2
  801bb1:	68 a2 48 80 00       	push   $0x8048a2
  801bb6:	e8 45 eb ff ff       	call   800700 <_panic>

00801bbb <realloc>:
//  Hint: you may need to use the sys_move_user_mem(...)
//		which switches to the kernel mode, calls move_user_mem(...)
//		in "kern/mem/chunk_operations.c", then switch back to the user mode here
//	the move_user_mem() function is empty, make sure to implement it.
void *realloc(void *virtual_address, uint32 new_size)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	83 ec 08             	sub    $0x8,%esp
	//[PROJECT]
	// Write your code here, remove the panic and write your code
	panic("realloc() is not implemented yet...!!");
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	68 d8 48 80 00       	push   $0x8048d8
  801bc9:	68 d9 00 00 00       	push   $0xd9
  801bce:	68 a2 48 80 00       	push   $0x8048a2
  801bd3:	e8 28 eb ff ff       	call   800700 <_panic>

00801bd8 <expand>:
//==================================================================================//
//========================== MODIFICATION FUNCTIONS ================================//
//==================================================================================//

void expand(uint32 newSize)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  801bde:	83 ec 04             	sub    $0x4,%esp
  801be1:	68 fe 48 80 00       	push   $0x8048fe
  801be6:	68 e5 00 00 00       	push   $0xe5
  801beb:	68 a2 48 80 00       	push   $0x8048a2
  801bf0:	e8 0b eb ff ff       	call   800700 <_panic>

00801bf5 <shrink>:

}
void shrink(uint32 newSize)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  801bfb:	83 ec 04             	sub    $0x4,%esp
  801bfe:	68 fe 48 80 00       	push   $0x8048fe
  801c03:	68 ea 00 00 00       	push   $0xea
  801c08:	68 a2 48 80 00       	push   $0x8048a2
  801c0d:	e8 ee ea ff ff       	call   800700 <_panic>

00801c12 <freeHeap>:

}
void freeHeap(void* virtual_address)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	83 ec 08             	sub    $0x8,%esp
	panic("Not Implemented");
  801c18:	83 ec 04             	sub    $0x4,%esp
  801c1b:	68 fe 48 80 00       	push   $0x8048fe
  801c20:	68 ef 00 00 00       	push   $0xef
  801c25:	68 a2 48 80 00       	push   $0x8048a2
  801c2a:	e8 d1 ea ff ff       	call   800700 <_panic>

00801c2f <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	57                   	push   %edi
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	83 ec 10             	sub    $0x10,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801c41:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801c44:	8b 7d 18             	mov    0x18(%ebp),%edi
  801c47:	8b 75 1c             	mov    0x1c(%ebp),%esi
  801c4a:	cd 30                	int    $0x30
  801c4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	return ret;
  801c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	5b                   	pop    %ebx
  801c56:	5e                   	pop    %esi
  801c57:	5f                   	pop    %edi
  801c58:	5d                   	pop    %ebp
  801c59:	c3                   	ret    

00801c5a <sys_cputs>:

void
sys_cputs(const char *s, uint32 len, uint8 printProgName)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 04             	sub    $0x4,%esp
  801c60:	8b 45 10             	mov    0x10(%ebp),%eax
  801c63:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputs, (uint32) s, len, (uint32)printProgName, 0, 0);
  801c66:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801c6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6d:	6a 00                	push   $0x0
  801c6f:	6a 00                	push   $0x0
  801c71:	52                   	push   %edx
  801c72:	ff 75 0c             	pushl  0xc(%ebp)
  801c75:	50                   	push   %eax
  801c76:	6a 00                	push   $0x0
  801c78:	e8 b2 ff ff ff       	call   801c2f <syscall>
  801c7d:	83 c4 18             	add    $0x18,%esp
}
  801c80:	90                   	nop
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <sys_cgetc>:

int
sys_cgetc(void)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  801c86:	6a 00                	push   $0x0
  801c88:	6a 00                	push   $0x0
  801c8a:	6a 00                	push   $0x0
  801c8c:	6a 00                	push   $0x0
  801c8e:	6a 00                	push   $0x0
  801c90:	6a 02                	push   $0x2
  801c92:	e8 98 ff ff ff       	call   801c2f <syscall>
  801c97:	83 c4 18             	add    $0x18,%esp
}
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <sys_lock_cons>:

void sys_lock_cons(void)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_lock_cons, 0, 0, 0, 0, 0);
  801c9f:	6a 00                	push   $0x0
  801ca1:	6a 00                	push   $0x0
  801ca3:	6a 00                	push   $0x0
  801ca5:	6a 00                	push   $0x0
  801ca7:	6a 00                	push   $0x0
  801ca9:	6a 03                	push   $0x3
  801cab:	e8 7f ff ff ff       	call   801c2f <syscall>
  801cb0:	83 c4 18             	add    $0x18,%esp
}
  801cb3:	90                   	nop
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <sys_unlock_cons>:
void sys_unlock_cons(void)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
	syscall(SYS_unlock_cons, 0, 0, 0, 0, 0);
  801cb9:	6a 00                	push   $0x0
  801cbb:	6a 00                	push   $0x0
  801cbd:	6a 00                	push   $0x0
  801cbf:	6a 00                	push   $0x0
  801cc1:	6a 00                	push   $0x0
  801cc3:	6a 04                	push   $0x4
  801cc5:	e8 65 ff ff ff       	call   801c2f <syscall>
  801cca:	83 c4 18             	add    $0x18,%esp
}
  801ccd:	90                   	nop
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <__sys_allocate_page>:

int __sys_allocate_page(void *va, int perm)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  801cd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd9:	6a 00                	push   $0x0
  801cdb:	6a 00                	push   $0x0
  801cdd:	6a 00                	push   $0x0
  801cdf:	52                   	push   %edx
  801ce0:	50                   	push   %eax
  801ce1:	6a 08                	push   $0x8
  801ce3:	e8 47 ff ff ff       	call   801c2f <syscall>
  801ce8:	83 c4 18             	add    $0x18,%esp
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <__sys_map_frame>:

int __sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  801cf2:	8b 75 18             	mov    0x18(%ebp),%esi
  801cf5:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801cf8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801d01:	56                   	push   %esi
  801d02:	53                   	push   %ebx
  801d03:	51                   	push   %ecx
  801d04:	52                   	push   %edx
  801d05:	50                   	push   %eax
  801d06:	6a 09                	push   $0x9
  801d08:	e8 22 ff ff ff       	call   801c2f <syscall>
  801d0d:	83 c4 18             	add    $0x18,%esp
}
  801d10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5d                   	pop    %ebp
  801d16:	c3                   	ret    

00801d17 <__sys_unmap_frame>:

int __sys_unmap_frame(int32 envid, void *va)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801d1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	6a 00                	push   $0x0
  801d22:	6a 00                	push   $0x0
  801d24:	6a 00                	push   $0x0
  801d26:	52                   	push   %edx
  801d27:	50                   	push   %eax
  801d28:	6a 0a                	push   $0xa
  801d2a:	e8 00 ff ff ff       	call   801c2f <syscall>
  801d2f:	83 c4 18             	add    $0x18,%esp
}
  801d32:	c9                   	leave  
  801d33:	c3                   	ret    

00801d34 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  801d34:	55                   	push   %ebp
  801d35:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  801d37:	6a 00                	push   $0x0
  801d39:	6a 00                	push   $0x0
  801d3b:	6a 00                	push   $0x0
  801d3d:	ff 75 0c             	pushl  0xc(%ebp)
  801d40:	ff 75 08             	pushl  0x8(%ebp)
  801d43:	6a 0b                	push   $0xb
  801d45:	e8 e5 fe ff ff       	call   801c2f <syscall>
  801d4a:	83 c4 18             	add    $0x18,%esp
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  801d52:	6a 00                	push   $0x0
  801d54:	6a 00                	push   $0x0
  801d56:	6a 00                	push   $0x0
  801d58:	6a 00                	push   $0x0
  801d5a:	6a 00                	push   $0x0
  801d5c:	6a 0c                	push   $0xc
  801d5e:	e8 cc fe ff ff       	call   801c2f <syscall>
  801d63:	83 c4 18             	add    $0x18,%esp
}
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <sys_calculate_modified_frames>:
uint32 sys_calculate_modified_frames()
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_modified_frames, 0, 0, 0, 0, 0);
  801d6b:	6a 00                	push   $0x0
  801d6d:	6a 00                	push   $0x0
  801d6f:	6a 00                	push   $0x0
  801d71:	6a 00                	push   $0x0
  801d73:	6a 00                	push   $0x0
  801d75:	6a 0d                	push   $0xd
  801d77:	e8 b3 fe ff ff       	call   801c2f <syscall>
  801d7c:	83 c4 18             	add    $0x18,%esp
}
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    

00801d81 <sys_calculate_notmod_frames>:

uint32 sys_calculate_notmod_frames()
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_notmod_frames, 0, 0, 0, 0, 0);
  801d84:	6a 00                	push   $0x0
  801d86:	6a 00                	push   $0x0
  801d88:	6a 00                	push   $0x0
  801d8a:	6a 00                	push   $0x0
  801d8c:	6a 00                	push   $0x0
  801d8e:	6a 0e                	push   $0xe
  801d90:	e8 9a fe ff ff       	call   801c2f <syscall>
  801d95:	83 c4 18             	add    $0x18,%esp
}
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <sys_pf_calculate_allocated_pages>:

int sys_pf_calculate_allocated_pages()
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_pf_calc_allocated_pages, 0,0,0,0,0);
  801d9d:	6a 00                	push   $0x0
  801d9f:	6a 00                	push   $0x0
  801da1:	6a 00                	push   $0x0
  801da3:	6a 00                	push   $0x0
  801da5:	6a 00                	push   $0x0
  801da7:	6a 0f                	push   $0xf
  801da9:	e8 81 fe ff ff       	call   801c2f <syscall>
  801dae:	83 c4 18             	add    $0x18,%esp
}
  801db1:	c9                   	leave  
  801db2:	c3                   	ret    

00801db3 <sys_calculate_pages_tobe_removed_ready_exit>:

int sys_calculate_pages_tobe_removed_ready_exit(uint32 WS_or_MEMORY_flag)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calculate_pages_tobe_removed_ready_exit, WS_or_MEMORY_flag,0,0,0,0);
  801db6:	6a 00                	push   $0x0
  801db8:	6a 00                	push   $0x0
  801dba:	6a 00                	push   $0x0
  801dbc:	6a 00                	push   $0x0
  801dbe:	ff 75 08             	pushl  0x8(%ebp)
  801dc1:	6a 10                	push   $0x10
  801dc3:	e8 67 fe ff ff       	call   801c2f <syscall>
  801dc8:	83 c4 18             	add    $0x18,%esp
}
  801dcb:	c9                   	leave  
  801dcc:	c3                   	ret    

00801dcd <sys_scarce_memory>:

void sys_scarce_memory()
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
	syscall(SYS_scarce_memory,0,0,0,0,0);
  801dd0:	6a 00                	push   $0x0
  801dd2:	6a 00                	push   $0x0
  801dd4:	6a 00                	push   $0x0
  801dd6:	6a 00                	push   $0x0
  801dd8:	6a 00                	push   $0x0
  801dda:	6a 11                	push   $0x11
  801ddc:	e8 4e fe ff ff       	call   801c2f <syscall>
  801de1:	83 c4 18             	add    $0x18,%esp
}
  801de4:	90                   	nop
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <sys_cputc>:

void
sys_cputc(const char c)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	83 ec 04             	sub    $0x4,%esp
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_cputc, (uint32) c, 0, 0, 0, 0);
  801df3:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  801df7:	6a 00                	push   $0x0
  801df9:	6a 00                	push   $0x0
  801dfb:	6a 00                	push   $0x0
  801dfd:	6a 00                	push   $0x0
  801dff:	50                   	push   %eax
  801e00:	6a 01                	push   $0x1
  801e02:	e8 28 fe ff ff       	call   801c2f <syscall>
  801e07:	83 c4 18             	add    $0x18,%esp
}
  801e0a:	90                   	nop
  801e0b:	c9                   	leave  
  801e0c:	c3                   	ret    

00801e0d <sys_clear_ffl>:


//NEW'12: BONUS2 Testing
void
sys_clear_ffl()
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
	syscall(SYS_clearFFL,0, 0, 0, 0, 0);
  801e10:	6a 00                	push   $0x0
  801e12:	6a 00                	push   $0x0
  801e14:	6a 00                	push   $0x0
  801e16:	6a 00                	push   $0x0
  801e18:	6a 00                	push   $0x0
  801e1a:	6a 14                	push   $0x14
  801e1c:	e8 0e fe ff ff       	call   801c2f <syscall>
  801e21:	83 c4 18             	add    $0x18,%esp
}
  801e24:	90                   	nop
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <sys_createSharedObject>:

int sys_createSharedObject(char* shareName, uint32 size, uint8 isWritable, void* virtual_address)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	83 ec 04             	sub    $0x4,%esp
  801e2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e30:	88 45 fc             	mov    %al,-0x4(%ebp)
	return syscall(SYS_create_shared_object,(uint32)shareName, (uint32)size, isWritable, (uint32)virtual_address,  0);
  801e33:	8b 4d 14             	mov    0x14(%ebp),%ecx
  801e36:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
  801e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3d:	6a 00                	push   $0x0
  801e3f:	51                   	push   %ecx
  801e40:	52                   	push   %edx
  801e41:	ff 75 0c             	pushl  0xc(%ebp)
  801e44:	50                   	push   %eax
  801e45:	6a 15                	push   $0x15
  801e47:	e8 e3 fd ff ff       	call   801c2f <syscall>
  801e4c:	83 c4 18             	add    $0x18,%esp
}
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <sys_getSizeOfSharedObject>:

//2017:
int sys_getSizeOfSharedObject(int32 ownerID, char* shareName)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_size_of_shared_object,(uint32) ownerID, (uint32)shareName, 0, 0, 0);
  801e54:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e57:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5a:	6a 00                	push   $0x0
  801e5c:	6a 00                	push   $0x0
  801e5e:	6a 00                	push   $0x0
  801e60:	52                   	push   %edx
  801e61:	50                   	push   %eax
  801e62:	6a 16                	push   $0x16
  801e64:	e8 c6 fd ff ff       	call   801c2f <syscall>
  801e69:	83 c4 18             	add    $0x18,%esp
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    

00801e6e <sys_getSharedObject>:
//==========

int sys_getSharedObject(int32 ownerID, char* shareName, void* virtual_address)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_shared_object,(uint32) ownerID, (uint32)shareName, (uint32)virtual_address, 0, 0);
  801e71:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801e74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e77:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7a:	6a 00                	push   $0x0
  801e7c:	6a 00                	push   $0x0
  801e7e:	51                   	push   %ecx
  801e7f:	52                   	push   %edx
  801e80:	50                   	push   %eax
  801e81:	6a 17                	push   $0x17
  801e83:	e8 a7 fd ff ff       	call   801c2f <syscall>
  801e88:	83 c4 18             	add    $0x18,%esp
}
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <sys_freeSharedObject>:

int sys_freeSharedObject(int32 sharedObjectID, void *startVA)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_free_shared_object,(uint32) sharedObjectID, (uint32) startVA, 0, 0, 0);
  801e90:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e93:	8b 45 08             	mov    0x8(%ebp),%eax
  801e96:	6a 00                	push   $0x0
  801e98:	6a 00                	push   $0x0
  801e9a:	6a 00                	push   $0x0
  801e9c:	52                   	push   %edx
  801e9d:	50                   	push   %eax
  801e9e:	6a 18                	push   $0x18
  801ea0:	e8 8a fd ff ff       	call   801c2f <syscall>
  801ea5:	83 c4 18             	add    $0x18,%esp
}
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <sys_create_env>:

int sys_create_env(char* programName, unsigned int page_WS_size,unsigned int LRU_second_list_size,unsigned int percent_WS_pages_to_remove)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_create_env,(uint32)programName, (uint32)page_WS_size,(uint32)LRU_second_list_size, (uint32)percent_WS_pages_to_remove, 0);
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb0:	6a 00                	push   $0x0
  801eb2:	ff 75 14             	pushl  0x14(%ebp)
  801eb5:	ff 75 10             	pushl  0x10(%ebp)
  801eb8:	ff 75 0c             	pushl  0xc(%ebp)
  801ebb:	50                   	push   %eax
  801ebc:	6a 19                	push   $0x19
  801ebe:	e8 6c fd ff ff       	call   801c2f <syscall>
  801ec3:	83 c4 18             	add    $0x18,%esp
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <sys_run_env>:

void sys_run_env(int32 envId)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
	syscall(SYS_run_env, (int32)envId, 0, 0, 0, 0);
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ece:	6a 00                	push   $0x0
  801ed0:	6a 00                	push   $0x0
  801ed2:	6a 00                	push   $0x0
  801ed4:	6a 00                	push   $0x0
  801ed6:	50                   	push   %eax
  801ed7:	6a 1a                	push   $0x1a
  801ed9:	e8 51 fd ff ff       	call   801c2f <syscall>
  801ede:	83 c4 18             	add    $0x18,%esp
}
  801ee1:	90                   	nop
  801ee2:	c9                   	leave  
  801ee3:	c3                   	ret    

00801ee4 <sys_destroy_env>:

int sys_destroy_env(int32  envid)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_destroy_env, envid, 0, 0, 0, 0);
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eea:	6a 00                	push   $0x0
  801eec:	6a 00                	push   $0x0
  801eee:	6a 00                	push   $0x0
  801ef0:	6a 00                	push   $0x0
  801ef2:	50                   	push   %eax
  801ef3:	6a 1b                	push   $0x1b
  801ef5:	e8 35 fd ff ff       	call   801c2f <syscall>
  801efa:	83 c4 18             	add    $0x18,%esp
}
  801efd:	c9                   	leave  
  801efe:	c3                   	ret    

00801eff <sys_getenvid>:

int32 sys_getenvid(void)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  801f02:	6a 00                	push   $0x0
  801f04:	6a 00                	push   $0x0
  801f06:	6a 00                	push   $0x0
  801f08:	6a 00                	push   $0x0
  801f0a:	6a 00                	push   $0x0
  801f0c:	6a 05                	push   $0x5
  801f0e:	e8 1c fd ff ff       	call   801c2f <syscall>
  801f13:	83 c4 18             	add    $0x18,%esp
}
  801f16:	c9                   	leave  
  801f17:	c3                   	ret    

00801f18 <sys_getenvindex>:

//2017
int32 sys_getenvindex(void)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvindex, 0, 0, 0, 0, 0);
  801f1b:	6a 00                	push   $0x0
  801f1d:	6a 00                	push   $0x0
  801f1f:	6a 00                	push   $0x0
  801f21:	6a 00                	push   $0x0
  801f23:	6a 00                	push   $0x0
  801f25:	6a 06                	push   $0x6
  801f27:	e8 03 fd ff ff       	call   801c2f <syscall>
  801f2c:	83 c4 18             	add    $0x18,%esp
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <sys_getparentenvid>:

int32 sys_getparentenvid(void)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getparentenvid, 0, 0, 0, 0, 0);
  801f34:	6a 00                	push   $0x0
  801f36:	6a 00                	push   $0x0
  801f38:	6a 00                	push   $0x0
  801f3a:	6a 00                	push   $0x0
  801f3c:	6a 00                	push   $0x0
  801f3e:	6a 07                	push   $0x7
  801f40:	e8 ea fc ff ff       	call   801c2f <syscall>
  801f45:	83 c4 18             	add    $0x18,%esp
}
  801f48:	c9                   	leave  
  801f49:	c3                   	ret    

00801f4a <sys_exit_env>:


void sys_exit_env(void)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
	syscall(SYS_exit_env, 0, 0, 0, 0, 0);
  801f4d:	6a 00                	push   $0x0
  801f4f:	6a 00                	push   $0x0
  801f51:	6a 00                	push   $0x0
  801f53:	6a 00                	push   $0x0
  801f55:	6a 00                	push   $0x0
  801f57:	6a 1c                	push   $0x1c
  801f59:	e8 d1 fc ff ff       	call   801c2f <syscall>
  801f5e:	83 c4 18             	add    $0x18,%esp
}
  801f61:	90                   	nop
  801f62:	c9                   	leave  
  801f63:	c3                   	ret    

00801f64 <sys_get_virtual_time>:


struct uint64 sys_get_virtual_time()
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	83 ec 10             	sub    $0x10,%esp
	struct uint64 result;
	syscall(SYS_get_virtual_time, (uint32)&(result.low), (uint32)&(result.hi), 0, 0, 0);
  801f6a:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801f6d:	8d 50 04             	lea    0x4(%eax),%edx
  801f70:	8d 45 f8             	lea    -0x8(%ebp),%eax
  801f73:	6a 00                	push   $0x0
  801f75:	6a 00                	push   $0x0
  801f77:	6a 00                	push   $0x0
  801f79:	52                   	push   %edx
  801f7a:	50                   	push   %eax
  801f7b:	6a 1d                	push   $0x1d
  801f7d:	e8 ad fc ff ff       	call   801c2f <syscall>
  801f82:	83 c4 18             	add    $0x18,%esp
	return result;
  801f85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f88:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801f8b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  801f8e:	89 01                	mov    %eax,(%ecx)
  801f90:	89 51 04             	mov    %edx,0x4(%ecx)
}
  801f93:	8b 45 08             	mov    0x8(%ebp),%eax
  801f96:	c9                   	leave  
  801f97:	c2 04 00             	ret    $0x4

00801f9a <sys_move_user_mem>:

// 2014
void sys_move_user_mem(uint32 src_virtual_address, uint32 dst_virtual_address, uint32 size)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
	syscall(SYS_move_user_mem, src_virtual_address, dst_virtual_address, size, 0, 0);
  801f9d:	6a 00                	push   $0x0
  801f9f:	6a 00                	push   $0x0
  801fa1:	ff 75 10             	pushl  0x10(%ebp)
  801fa4:	ff 75 0c             	pushl  0xc(%ebp)
  801fa7:	ff 75 08             	pushl  0x8(%ebp)
  801faa:	6a 13                	push   $0x13
  801fac:	e8 7e fc ff ff       	call   801c2f <syscall>
  801fb1:	83 c4 18             	add    $0x18,%esp
	return ;
  801fb4:	90                   	nop
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <sys_rcr2>:
uint32 sys_rcr2()
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_rcr2, 0, 0, 0, 0, 0);
  801fba:	6a 00                	push   $0x0
  801fbc:	6a 00                	push   $0x0
  801fbe:	6a 00                	push   $0x0
  801fc0:	6a 00                	push   $0x0
  801fc2:	6a 00                	push   $0x0
  801fc4:	6a 1e                	push   $0x1e
  801fc6:	e8 64 fc ff ff       	call   801c2f <syscall>
  801fcb:	83 c4 18             	add    $0x18,%esp
}
  801fce:	c9                   	leave  
  801fcf:	c3                   	ret    

00801fd0 <sys_bypassPageFault>:

void sys_bypassPageFault(uint8 instrLength)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	83 ec 04             	sub    $0x4,%esp
  801fd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd9:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_bypassPageFault, instrLength, 0, 0, 0, 0);
  801fdc:	0f b6 45 fc          	movzbl -0x4(%ebp),%eax
  801fe0:	6a 00                	push   $0x0
  801fe2:	6a 00                	push   $0x0
  801fe4:	6a 00                	push   $0x0
  801fe6:	6a 00                	push   $0x0
  801fe8:	50                   	push   %eax
  801fe9:	6a 1f                	push   $0x1f
  801feb:	e8 3f fc ff ff       	call   801c2f <syscall>
  801ff0:	83 c4 18             	add    $0x18,%esp
	return ;
  801ff3:	90                   	nop
}
  801ff4:	c9                   	leave  
  801ff5:	c3                   	ret    

00801ff6 <rsttst>:
void rsttst()
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
	syscall(SYS_rsttst, 0, 0, 0, 0, 0);
  801ff9:	6a 00                	push   $0x0
  801ffb:	6a 00                	push   $0x0
  801ffd:	6a 00                	push   $0x0
  801fff:	6a 00                	push   $0x0
  802001:	6a 00                	push   $0x0
  802003:	6a 21                	push   $0x21
  802005:	e8 25 fc ff ff       	call   801c2f <syscall>
  80200a:	83 c4 18             	add    $0x18,%esp
	return ;
  80200d:	90                   	nop
}
  80200e:	c9                   	leave  
  80200f:	c3                   	ret    

00802010 <tst>:
void tst(uint32 n, uint32 v1, uint32 v2, char c, int inv)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	83 ec 04             	sub    $0x4,%esp
  802016:	8b 45 14             	mov    0x14(%ebp),%eax
  802019:	88 45 fc             	mov    %al,-0x4(%ebp)
	syscall(SYS_testNum, n, v1, v2, c, inv);
  80201c:	8b 55 18             	mov    0x18(%ebp),%edx
  80201f:	0f be 45 fc          	movsbl -0x4(%ebp),%eax
  802023:	52                   	push   %edx
  802024:	50                   	push   %eax
  802025:	ff 75 10             	pushl  0x10(%ebp)
  802028:	ff 75 0c             	pushl  0xc(%ebp)
  80202b:	ff 75 08             	pushl  0x8(%ebp)
  80202e:	6a 20                	push   $0x20
  802030:	e8 fa fb ff ff       	call   801c2f <syscall>
  802035:	83 c4 18             	add    $0x18,%esp
	return ;
  802038:	90                   	nop
}
  802039:	c9                   	leave  
  80203a:	c3                   	ret    

0080203b <chktst>:
void chktst(uint32 n)
{
  80203b:	55                   	push   %ebp
  80203c:	89 e5                	mov    %esp,%ebp
	syscall(SYS_chktst, n, 0, 0, 0, 0);
  80203e:	6a 00                	push   $0x0
  802040:	6a 00                	push   $0x0
  802042:	6a 00                	push   $0x0
  802044:	6a 00                	push   $0x0
  802046:	ff 75 08             	pushl  0x8(%ebp)
  802049:	6a 22                	push   $0x22
  80204b:	e8 df fb ff ff       	call   801c2f <syscall>
  802050:	83 c4 18             	add    $0x18,%esp
	return ;
  802053:	90                   	nop
}
  802054:	c9                   	leave  
  802055:	c3                   	ret    

00802056 <inctst>:

void inctst()
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
	syscall(SYS_inctst, 0, 0, 0, 0, 0);
  802059:	6a 00                	push   $0x0
  80205b:	6a 00                	push   $0x0
  80205d:	6a 00                	push   $0x0
  80205f:	6a 00                	push   $0x0
  802061:	6a 00                	push   $0x0
  802063:	6a 23                	push   $0x23
  802065:	e8 c5 fb ff ff       	call   801c2f <syscall>
  80206a:	83 c4 18             	add    $0x18,%esp
	return ;
  80206d:	90                   	nop
}
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <gettst>:
uint32 gettst()
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_gettst, 0, 0, 0, 0, 0);
  802073:	6a 00                	push   $0x0
  802075:	6a 00                	push   $0x0
  802077:	6a 00                	push   $0x0
  802079:	6a 00                	push   $0x0
  80207b:	6a 00                	push   $0x0
  80207d:	6a 24                	push   $0x24
  80207f:	e8 ab fb ff ff       	call   801c2f <syscall>
  802084:	83 c4 18             	add    $0x18,%esp
}
  802087:	c9                   	leave  
  802088:	c3                   	ret    

00802089 <sys_isUHeapPlacementStrategyFIRSTFIT>:


//2015
uint32 sys_isUHeapPlacementStrategyFIRSTFIT()
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  80208f:	6a 00                	push   $0x0
  802091:	6a 00                	push   $0x0
  802093:	6a 00                	push   $0x0
  802095:	6a 00                	push   $0x0
  802097:	6a 00                	push   $0x0
  802099:	6a 25                	push   $0x25
  80209b:	e8 8f fb ff ff       	call   801c2f <syscall>
  8020a0:	83 c4 18             	add    $0x18,%esp
  8020a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_FIRSTFIT)
  8020a6:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
  8020aa:	75 07                	jne    8020b3 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2a>
		return 1;
  8020ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b1:	eb 05                	jmp    8020b8 <sys_isUHeapPlacementStrategyFIRSTFIT+0x2f>
	else
		return 0;
  8020b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020b8:	c9                   	leave  
  8020b9:	c3                   	ret    

008020ba <sys_isUHeapPlacementStrategyBESTFIT>:
uint32 sys_isUHeapPlacementStrategyBESTFIT()
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8020c0:	6a 00                	push   $0x0
  8020c2:	6a 00                	push   $0x0
  8020c4:	6a 00                	push   $0x0
  8020c6:	6a 00                	push   $0x0
  8020c8:	6a 00                	push   $0x0
  8020ca:	6a 25                	push   $0x25
  8020cc:	e8 5e fb ff ff       	call   801c2f <syscall>
  8020d1:	83 c4 18             	add    $0x18,%esp
  8020d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_BESTFIT)
  8020d7:	83 7d fc 02          	cmpl   $0x2,-0x4(%ebp)
  8020db:	75 07                	jne    8020e4 <sys_isUHeapPlacementStrategyBESTFIT+0x2a>
		return 1;
  8020dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8020e2:	eb 05                	jmp    8020e9 <sys_isUHeapPlacementStrategyBESTFIT+0x2f>
	else
		return 0;
  8020e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <sys_isUHeapPlacementStrategyNEXTFIT>:
uint32 sys_isUHeapPlacementStrategyNEXTFIT()
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  8020f1:	6a 00                	push   $0x0
  8020f3:	6a 00                	push   $0x0
  8020f5:	6a 00                	push   $0x0
  8020f7:	6a 00                	push   $0x0
  8020f9:	6a 00                	push   $0x0
  8020fb:	6a 25                	push   $0x25
  8020fd:	e8 2d fb ff ff       	call   801c2f <syscall>
  802102:	83 c4 18             	add    $0x18,%esp
  802105:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_NEXTFIT)
  802108:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
  80210c:	75 07                	jne    802115 <sys_isUHeapPlacementStrategyNEXTFIT+0x2a>
		return 1;
  80210e:	b8 01 00 00 00       	mov    $0x1,%eax
  802113:	eb 05                	jmp    80211a <sys_isUHeapPlacementStrategyNEXTFIT+0x2f>
	else
		return 0;
  802115:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <sys_isUHeapPlacementStrategyWORSTFIT>:
uint32 sys_isUHeapPlacementStrategyWORSTFIT()
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 10             	sub    $0x10,%esp
	uint32 ret = syscall(SYS_get_heap_strategy, 0, 0, 0, 0, 0);
  802122:	6a 00                	push   $0x0
  802124:	6a 00                	push   $0x0
  802126:	6a 00                	push   $0x0
  802128:	6a 00                	push   $0x0
  80212a:	6a 00                	push   $0x0
  80212c:	6a 25                	push   $0x25
  80212e:	e8 fc fa ff ff       	call   801c2f <syscall>
  802133:	83 c4 18             	add    $0x18,%esp
  802136:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (ret == UHP_PLACE_WORSTFIT)
  802139:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
  80213d:	75 07                	jne    802146 <sys_isUHeapPlacementStrategyWORSTFIT+0x2a>
		return 1;
  80213f:	b8 01 00 00 00       	mov    $0x1,%eax
  802144:	eb 05                	jmp    80214b <sys_isUHeapPlacementStrategyWORSTFIT+0x2f>
	else
		return 0;
  802146:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80214b:	c9                   	leave  
  80214c:	c3                   	ret    

0080214d <sys_set_uheap_strategy>:

void sys_set_uheap_strategy(uint32 heapStrategy)
{
  80214d:	55                   	push   %ebp
  80214e:	89 e5                	mov    %esp,%ebp
	syscall(SYS_set_heap_strategy, heapStrategy, 0, 0, 0, 0);
  802150:	6a 00                	push   $0x0
  802152:	6a 00                	push   $0x0
  802154:	6a 00                	push   $0x0
  802156:	6a 00                	push   $0x0
  802158:	ff 75 08             	pushl  0x8(%ebp)
  80215b:	6a 26                	push   $0x26
  80215d:	e8 cd fa ff ff       	call   801c2f <syscall>
  802162:	83 c4 18             	add    $0x18,%esp
	return ;
  802165:	90                   	nop
}
  802166:	c9                   	leave  
  802167:	c3                   	ret    

00802168 <sys_check_LRU_lists>:

//2020
int sys_check_LRU_lists(uint32* active_list_content, uint32* second_list_content, int actual_active_list_size, int actual_second_list_size)
{
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	53                   	push   %ebx
	return syscall(SYS_check_LRU_lists, (uint32)active_list_content, (uint32)second_list_content, (uint32)actual_active_list_size, (uint32)actual_second_list_size, 0);
  80216c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80216f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802172:	8b 55 0c             	mov    0xc(%ebp),%edx
  802175:	8b 45 08             	mov    0x8(%ebp),%eax
  802178:	6a 00                	push   $0x0
  80217a:	53                   	push   %ebx
  80217b:	51                   	push   %ecx
  80217c:	52                   	push   %edx
  80217d:	50                   	push   %eax
  80217e:	6a 27                	push   $0x27
  802180:	e8 aa fa ff ff       	call   801c2f <syscall>
  802185:	83 c4 18             	add    $0x18,%esp
}
  802188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80218b:	c9                   	leave  
  80218c:	c3                   	ret    

0080218d <sys_check_LRU_lists_free>:

int sys_check_LRU_lists_free(uint32* list_content, int list_size)
{
  80218d:	55                   	push   %ebp
  80218e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_LRU_lists_free, (uint32)list_content, (uint32)list_size , 0, 0, 0);
  802190:	8b 55 0c             	mov    0xc(%ebp),%edx
  802193:	8b 45 08             	mov    0x8(%ebp),%eax
  802196:	6a 00                	push   $0x0
  802198:	6a 00                	push   $0x0
  80219a:	6a 00                	push   $0x0
  80219c:	52                   	push   %edx
  80219d:	50                   	push   %eax
  80219e:	6a 28                	push   $0x28
  8021a0:	e8 8a fa ff ff       	call   801c2f <syscall>
  8021a5:	83 c4 18             	add    $0x18,%esp
}
  8021a8:	c9                   	leave  
  8021a9:	c3                   	ret    

008021aa <sys_check_WS_list>:

int sys_check_WS_list(uint32* WS_list_content, int actual_WS_list_size, uint32 last_WS_element_content, bool chk_in_order)
{
  8021aa:	55                   	push   %ebp
  8021ab:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_check_WS_list, (uint32)WS_list_content, (uint32)actual_WS_list_size , last_WS_element_content, (uint32)chk_in_order, 0);
  8021ad:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8021b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b6:	6a 00                	push   $0x0
  8021b8:	51                   	push   %ecx
  8021b9:	ff 75 10             	pushl  0x10(%ebp)
  8021bc:	52                   	push   %edx
  8021bd:	50                   	push   %eax
  8021be:	6a 29                	push   $0x29
  8021c0:	e8 6a fa ff ff       	call   801c2f <syscall>
  8021c5:	83 c4 18             	add    $0x18,%esp
}
  8021c8:	c9                   	leave  
  8021c9:	c3                   	ret    

008021ca <sys_allocate_chunk>:
void sys_allocate_chunk(uint32 virtual_address, uint32 size, uint32 perms)
{
  8021ca:	55                   	push   %ebp
  8021cb:	89 e5                	mov    %esp,%ebp
	syscall(SYS_allocate_chunk_in_mem, virtual_address, size, perms, 0, 0);
  8021cd:	6a 00                	push   $0x0
  8021cf:	6a 00                	push   $0x0
  8021d1:	ff 75 10             	pushl  0x10(%ebp)
  8021d4:	ff 75 0c             	pushl  0xc(%ebp)
  8021d7:	ff 75 08             	pushl  0x8(%ebp)
  8021da:	6a 12                	push   $0x12
  8021dc:	e8 4e fa ff ff       	call   801c2f <syscall>
  8021e1:	83 c4 18             	add    $0x18,%esp
	return ;
  8021e4:	90                   	nop
}
  8021e5:	c9                   	leave  
  8021e6:	c3                   	ret    

008021e7 <sys_utilities>:
void sys_utilities(char* utilityName, int value)
{
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
	syscall(SYS_utilities, (uint32)utilityName, value, 0, 0, 0);
  8021ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f0:	6a 00                	push   $0x0
  8021f2:	6a 00                	push   $0x0
  8021f4:	6a 00                	push   $0x0
  8021f6:	52                   	push   %edx
  8021f7:	50                   	push   %eax
  8021f8:	6a 2a                	push   $0x2a
  8021fa:	e8 30 fa ff ff       	call   801c2f <syscall>
  8021ff:	83 c4 18             	add    $0x18,%esp
	return;
  802202:	90                   	nop
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <sys_sbrk>:


//TODO: [PROJECT'24.MS1 - #02] [2] SYSTEM CALLS - Implement these system calls
void* sys_sbrk(int increment)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	return (void*)syscall(SYS_sbrk,increment,0,0,0,0);
  802208:	8b 45 08             	mov    0x8(%ebp),%eax
  80220b:	6a 00                	push   $0x0
  80220d:	6a 00                	push   $0x0
  80220f:	6a 00                	push   $0x0
  802211:	6a 00                	push   $0x0
  802213:	50                   	push   %eax
  802214:	6a 2b                	push   $0x2b
  802216:	e8 14 fa ff ff       	call   801c2f <syscall>
  80221b:	83 c4 18             	add    $0x18,%esp
}
  80221e:	c9                   	leave  
  80221f:	c3                   	ret    

00802220 <sys_free_user_mem>:

void sys_free_user_mem(uint32 virtual_address, uint32 size)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	syscall(SYS_free_user_mem,virtual_address,size,0,0,0);
  802223:	6a 00                	push   $0x0
  802225:	6a 00                	push   $0x0
  802227:	6a 00                	push   $0x0
  802229:	ff 75 0c             	pushl  0xc(%ebp)
  80222c:	ff 75 08             	pushl  0x8(%ebp)
  80222f:	6a 2c                	push   $0x2c
  802231:	e8 f9 f9 ff ff       	call   801c2f <syscall>
  802236:	83 c4 18             	add    $0x18,%esp
	return;
  802239:	90                   	nop
}
  80223a:	c9                   	leave  
  80223b:	c3                   	ret    

0080223c <sys_allocate_user_mem>:

void sys_allocate_user_mem(uint32 virtual_address, uint32 size)
{
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
	//Comment the following line before start coding...
	//panic("not implemented yet");

	syscall(SYS_allocate_user_mem,virtual_address,size,0,0,0);
  80223f:	6a 00                	push   $0x0
  802241:	6a 00                	push   $0x0
  802243:	6a 00                	push   $0x0
  802245:	ff 75 0c             	pushl  0xc(%ebp)
  802248:	ff 75 08             	pushl  0x8(%ebp)
  80224b:	6a 2d                	push   $0x2d
  80224d:	e8 dd f9 ff ff       	call   801c2f <syscall>
  802252:	83 c4 18             	add    $0x18,%esp
	return;
  802255:	90                   	nop
}
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <get_block_size>:

//=====================================================
// 1) GET BLOCK SIZE (including size of its meta data):
//=====================================================
__inline__ uint32 get_block_size(void* va)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	83 ec 10             	sub    $0x10,%esp
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
  80225e:	8b 45 08             	mov    0x8(%ebp),%eax
  802261:	83 e8 04             	sub    $0x4,%eax
  802264:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return (*curBlkMetaData) & ~(0x1);
  802267:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80226a:	8b 00                	mov    (%eax),%eax
  80226c:	83 e0 fe             	and    $0xfffffffe,%eax
}
  80226f:	c9                   	leave  
  802270:	c3                   	ret    

00802271 <is_free_block>:

//===========================
// 2) GET BLOCK STATUS:
//===========================
__inline__ int8 is_free_block(void* va)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	83 ec 10             	sub    $0x10,%esp
	uint32 *curBlkMetaData = ((uint32 *)va - 1) ;
  802277:	8b 45 08             	mov    0x8(%ebp),%eax
  80227a:	83 e8 04             	sub    $0x4,%eax
  80227d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return (~(*curBlkMetaData) & 0x1) ;
  802280:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802283:	8b 00                	mov    (%eax),%eax
  802285:	83 e0 01             	and    $0x1,%eax
  802288:	85 c0                	test   %eax,%eax
  80228a:	0f 94 c0             	sete   %al
}
  80228d:	c9                   	leave  
  80228e:	c3                   	ret    

0080228f <alloc_block>:
//===========================
// 3) ALLOCATE BLOCK:
//===========================

void *alloc_block(uint32 size, int ALLOC_STRATEGY)
{
  80228f:	55                   	push   %ebp
  802290:	89 e5                	mov    %esp,%ebp
  802292:	83 ec 18             	sub    $0x18,%esp
	void *va = NULL;
  802295:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	switch (ALLOC_STRATEGY)
  80229c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229f:	83 f8 02             	cmp    $0x2,%eax
  8022a2:	74 2b                	je     8022cf <alloc_block+0x40>
  8022a4:	83 f8 02             	cmp    $0x2,%eax
  8022a7:	7f 07                	jg     8022b0 <alloc_block+0x21>
  8022a9:	83 f8 01             	cmp    $0x1,%eax
  8022ac:	74 0e                	je     8022bc <alloc_block+0x2d>
  8022ae:	eb 58                	jmp    802308 <alloc_block+0x79>
  8022b0:	83 f8 03             	cmp    $0x3,%eax
  8022b3:	74 2d                	je     8022e2 <alloc_block+0x53>
  8022b5:	83 f8 04             	cmp    $0x4,%eax
  8022b8:	74 3b                	je     8022f5 <alloc_block+0x66>
  8022ba:	eb 4c                	jmp    802308 <alloc_block+0x79>
	{
	case DA_FF:
		va = alloc_block_FF(size);
  8022bc:	83 ec 0c             	sub    $0xc,%esp
  8022bf:	ff 75 08             	pushl  0x8(%ebp)
  8022c2:	e8 11 03 00 00       	call   8025d8 <alloc_block_FF>
  8022c7:	83 c4 10             	add    $0x10,%esp
  8022ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8022cd:	eb 4a                	jmp    802319 <alloc_block+0x8a>
	case DA_NF:
		va = alloc_block_NF(size);
  8022cf:	83 ec 0c             	sub    $0xc,%esp
  8022d2:	ff 75 08             	pushl  0x8(%ebp)
  8022d5:	e8 fa 19 00 00       	call   803cd4 <alloc_block_NF>
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8022e0:	eb 37                	jmp    802319 <alloc_block+0x8a>
	case DA_BF:
		va = alloc_block_BF(size);
  8022e2:	83 ec 0c             	sub    $0xc,%esp
  8022e5:	ff 75 08             	pushl  0x8(%ebp)
  8022e8:	e8 a7 07 00 00       	call   802a94 <alloc_block_BF>
  8022ed:	83 c4 10             	add    $0x10,%esp
  8022f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  8022f3:	eb 24                	jmp    802319 <alloc_block+0x8a>
	case DA_WF:
		va = alloc_block_WF(size);
  8022f5:	83 ec 0c             	sub    $0xc,%esp
  8022f8:	ff 75 08             	pushl  0x8(%ebp)
  8022fb:	e8 b7 19 00 00       	call   803cb7 <alloc_block_WF>
  802300:	83 c4 10             	add    $0x10,%esp
  802303:	89 45 f4             	mov    %eax,-0xc(%ebp)
		break;
  802306:	eb 11                	jmp    802319 <alloc_block+0x8a>
	default:
		cprintf("Invalid allocation strategy\n");
  802308:	83 ec 0c             	sub    $0xc,%esp
  80230b:	68 10 49 80 00       	push   $0x804910
  802310:	e8 a8 e6 ff ff       	call   8009bd <cprintf>
  802315:	83 c4 10             	add    $0x10,%esp
		break;
  802318:	90                   	nop
	}
	return va;
  802319:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80231c:	c9                   	leave  
  80231d:	c3                   	ret    

0080231e <print_blocks_list>:
//===========================
// 4) PRINT BLOCKS LIST:
//===========================

void print_blocks_list(struct MemBlock_LIST list)
{
  80231e:	55                   	push   %ebp
  80231f:	89 e5                	mov    %esp,%ebp
  802321:	53                   	push   %ebx
  802322:	83 ec 14             	sub    $0x14,%esp
	cprintf("=========================================\n");
  802325:	83 ec 0c             	sub    $0xc,%esp
  802328:	68 30 49 80 00       	push   $0x804930
  80232d:	e8 8b e6 ff ff       	call   8009bd <cprintf>
  802332:	83 c4 10             	add    $0x10,%esp
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
  802335:	83 ec 0c             	sub    $0xc,%esp
  802338:	68 5b 49 80 00       	push   $0x80495b
  80233d:	e8 7b e6 ff ff       	call   8009bd <cprintf>
  802342:	83 c4 10             	add    $0x10,%esp
	LIST_FOREACH(blk, &list)
  802345:	8b 45 08             	mov    0x8(%ebp),%eax
  802348:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80234b:	eb 37                	jmp    802384 <print_blocks_list+0x66>
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
  80234d:	83 ec 0c             	sub    $0xc,%esp
  802350:	ff 75 f4             	pushl  -0xc(%ebp)
  802353:	e8 19 ff ff ff       	call   802271 <is_free_block>
  802358:	83 c4 10             	add    $0x10,%esp
  80235b:	0f be d8             	movsbl %al,%ebx
  80235e:	83 ec 0c             	sub    $0xc,%esp
  802361:	ff 75 f4             	pushl  -0xc(%ebp)
  802364:	e8 ef fe ff ff       	call   802258 <get_block_size>
  802369:	83 c4 10             	add    $0x10,%esp
  80236c:	83 ec 04             	sub    $0x4,%esp
  80236f:	53                   	push   %ebx
  802370:	50                   	push   %eax
  802371:	68 73 49 80 00       	push   $0x804973
  802376:	e8 42 e6 ff ff       	call   8009bd <cprintf>
  80237b:	83 c4 10             	add    $0x10,%esp
void print_blocks_list(struct MemBlock_LIST list)
{
	cprintf("=========================================\n");
	struct BlockElement* blk ;
	cprintf("\nDynAlloc Blocks List:\n");
	LIST_FOREACH(blk, &list)
  80237e:	8b 45 10             	mov    0x10(%ebp),%eax
  802381:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802384:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802388:	74 07                	je     802391 <print_blocks_list+0x73>
  80238a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238d:	8b 00                	mov    (%eax),%eax
  80238f:	eb 05                	jmp    802396 <print_blocks_list+0x78>
  802391:	b8 00 00 00 00       	mov    $0x0,%eax
  802396:	89 45 10             	mov    %eax,0x10(%ebp)
  802399:	8b 45 10             	mov    0x10(%ebp),%eax
  80239c:	85 c0                	test   %eax,%eax
  80239e:	75 ad                	jne    80234d <print_blocks_list+0x2f>
  8023a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8023a4:	75 a7                	jne    80234d <print_blocks_list+0x2f>
	{
		cprintf("(size: %d, isFree: %d)\n", get_block_size(blk), is_free_block(blk)) ;
	}
	cprintf("=========================================\n");
  8023a6:	83 ec 0c             	sub    $0xc,%esp
  8023a9:	68 30 49 80 00       	push   $0x804930
  8023ae:	e8 0a e6 ff ff       	call   8009bd <cprintf>
  8023b3:	83 c4 10             	add    $0x10,%esp

}
  8023b6:	90                   	nop
  8023b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023ba:	c9                   	leave  
  8023bb:	c3                   	ret    

008023bc <initialize_dynamic_allocator>:
// [1] INITIALIZE DYNAMIC ALLOCATOR:
//==================================

// Youssef Mohsen
void initialize_dynamic_allocator(uint32 daStart, uint32 initSizeOfAllocatedSpace)
{
  8023bc:	55                   	push   %ebp
  8023bd:	89 e5                	mov    %esp,%ebp
  8023bf:	83 ec 18             	sub    $0x18,%esp
        //==================================================================================
        //DON'T CHANGE THESE LINES==========================================================
        //==================================================================================
        {
            if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
  8023c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c5:	83 e0 01             	and    $0x1,%eax
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	74 03                	je     8023cf <initialize_dynamic_allocator+0x13>
  8023cc:	ff 45 0c             	incl   0xc(%ebp)
            if (initSizeOfAllocatedSpace == 0)
  8023cf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8023d3:	0f 84 c7 01 00 00    	je     8025a0 <initialize_dynamic_allocator+0x1e4>
                return ;
            is_initialized = 1;
  8023d9:	c7 05 24 50 80 00 01 	movl   $0x1,0x805024
  8023e0:	00 00 00 
        //TODO: [PROJECT'24.MS1 - #04] [3] DYNAMIC ALLOCATOR - initialize_dynamic_allocator
        //COMMENT THE FOLLOWING LINE BEFORE START CODING
        //panic("initialize_dynamic_allocator is not implemented yet");

    // Check for bounds
    if ((daStart + initSizeOfAllocatedSpace) > KERNEL_HEAP_MAX)
  8023e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8023e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e9:	01 d0                	add    %edx,%eax
  8023eb:	3d 00 f0 ff ff       	cmp    $0xfffff000,%eax
  8023f0:	0f 87 ad 01 00 00    	ja     8025a3 <initialize_dynamic_allocator+0x1e7>
        return;
    if(daStart < USER_HEAP_START)
  8023f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f9:	85 c0                	test   %eax,%eax
  8023fb:	0f 89 a5 01 00 00    	jns    8025a6 <initialize_dynamic_allocator+0x1ea>
        return;
    end_add = daStart + initSizeOfAllocatedSpace - sizeof(struct Block_Start_End);
  802401:	8b 55 08             	mov    0x8(%ebp),%edx
  802404:	8b 45 0c             	mov    0xc(%ebp),%eax
  802407:	01 d0                	add    %edx,%eax
  802409:	83 e8 04             	sub    $0x4,%eax
  80240c:	a3 4c 92 80 00       	mov    %eax,0x80924c
     struct BlockElement * element = NULL;
  802411:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     LIST_FOREACH(element, &freeBlocksList)
  802418:	a1 44 50 80 00       	mov    0x805044,%eax
  80241d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802420:	e9 87 00 00 00       	jmp    8024ac <initialize_dynamic_allocator+0xf0>
     {
        LIST_REMOVE(&freeBlocksList,element);
  802425:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802429:	75 14                	jne    80243f <initialize_dynamic_allocator+0x83>
  80242b:	83 ec 04             	sub    $0x4,%esp
  80242e:	68 8b 49 80 00       	push   $0x80498b
  802433:	6a 79                	push   $0x79
  802435:	68 a9 49 80 00       	push   $0x8049a9
  80243a:	e8 c1 e2 ff ff       	call   800700 <_panic>
  80243f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802442:	8b 00                	mov    (%eax),%eax
  802444:	85 c0                	test   %eax,%eax
  802446:	74 10                	je     802458 <initialize_dynamic_allocator+0x9c>
  802448:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80244b:	8b 00                	mov    (%eax),%eax
  80244d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802450:	8b 52 04             	mov    0x4(%edx),%edx
  802453:	89 50 04             	mov    %edx,0x4(%eax)
  802456:	eb 0b                	jmp    802463 <initialize_dynamic_allocator+0xa7>
  802458:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80245b:	8b 40 04             	mov    0x4(%eax),%eax
  80245e:	a3 48 50 80 00       	mov    %eax,0x805048
  802463:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802466:	8b 40 04             	mov    0x4(%eax),%eax
  802469:	85 c0                	test   %eax,%eax
  80246b:	74 0f                	je     80247c <initialize_dynamic_allocator+0xc0>
  80246d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802470:	8b 40 04             	mov    0x4(%eax),%eax
  802473:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802476:	8b 12                	mov    (%edx),%edx
  802478:	89 10                	mov    %edx,(%eax)
  80247a:	eb 0a                	jmp    802486 <initialize_dynamic_allocator+0xca>
  80247c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247f:	8b 00                	mov    (%eax),%eax
  802481:	a3 44 50 80 00       	mov    %eax,0x805044
  802486:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802489:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  80248f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802492:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802499:	a1 50 50 80 00       	mov    0x805050,%eax
  80249e:	48                   	dec    %eax
  80249f:	a3 50 50 80 00       	mov    %eax,0x805050
        return;
    if(daStart < USER_HEAP_START)
        return;
    end_add = daStart + initSizeOfAllocatedSpace - sizeof(struct Block_Start_End);
     struct BlockElement * element = NULL;
     LIST_FOREACH(element, &freeBlocksList)
  8024a4:	a1 4c 50 80 00       	mov    0x80504c,%eax
  8024a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8024ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8024b0:	74 07                	je     8024b9 <initialize_dynamic_allocator+0xfd>
  8024b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024b5:	8b 00                	mov    (%eax),%eax
  8024b7:	eb 05                	jmp    8024be <initialize_dynamic_allocator+0x102>
  8024b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8024be:	a3 4c 50 80 00       	mov    %eax,0x80504c
  8024c3:	a1 4c 50 80 00       	mov    0x80504c,%eax
  8024c8:	85 c0                	test   %eax,%eax
  8024ca:	0f 85 55 ff ff ff    	jne    802425 <initialize_dynamic_allocator+0x69>
  8024d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8024d4:	0f 85 4b ff ff ff    	jne    802425 <initialize_dynamic_allocator+0x69>
     {
        LIST_REMOVE(&freeBlocksList,element);
     }

    // Create the BEG Block
    struct Block_Start_End* beg_block = (struct Block_Start_End*) daStart;
  8024da:	8b 45 08             	mov    0x8(%ebp),%eax
  8024dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    beg_block->info = 1;
  8024e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8024e3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)

    // Create the END Block
    end_block = (struct Block_Start_End*) (end_add);
  8024e9:	a1 4c 92 80 00       	mov    0x80924c,%eax
  8024ee:	a3 48 92 80 00       	mov    %eax,0x809248
    end_block->info = 1;
  8024f3:	a1 48 92 80 00       	mov    0x809248,%eax
  8024f8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    // Create the first free block
    struct BlockElement* first_free_block = (struct BlockElement*)(daStart + 2*sizeof(struct Block_Start_End));
  8024fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802501:	83 c0 08             	add    $0x8,%eax
  802504:	89 45 ec             	mov    %eax,-0x14(%ebp)


    //Assigning the Heap's Header/Footer values
    *(uint32*)((char*)daStart + 4 /*4 Byte*/) = initSizeOfAllocatedSpace - 2 * sizeof(struct Block_Start_End) /*Heap's header/footer*/;
  802507:	8b 45 08             	mov    0x8(%ebp),%eax
  80250a:	83 c0 04             	add    $0x4,%eax
  80250d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802510:	83 ea 08             	sub    $0x8,%edx
  802513:	89 10                	mov    %edx,(%eax)
    *(uint32*)((char*)daStart + initSizeOfAllocatedSpace - 8) = initSizeOfAllocatedSpace - 2 * sizeof(struct Block_Start_End) /*Heap's header/footer*/;
  802515:	8b 55 0c             	mov    0xc(%ebp),%edx
  802518:	8b 45 08             	mov    0x8(%ebp),%eax
  80251b:	01 d0                	add    %edx,%eax
  80251d:	83 e8 08             	sub    $0x8,%eax
  802520:	8b 55 0c             	mov    0xc(%ebp),%edx
  802523:	83 ea 08             	sub    $0x8,%edx
  802526:	89 10                	mov    %edx,(%eax)

    // Initialize links to the END block
   first_free_block->prev_next_info.le_next = NULL; // Link to the END block
  802528:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80252b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
   first_free_block->prev_next_info.le_prev = NULL;
  802531:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802534:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)

    // Link the first free block into the free block list
    LIST_INSERT_HEAD(&freeBlocksList , first_free_block);
  80253b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  80253f:	75 17                	jne    802558 <initialize_dynamic_allocator+0x19c>
  802541:	83 ec 04             	sub    $0x4,%esp
  802544:	68 c4 49 80 00       	push   $0x8049c4
  802549:	68 90 00 00 00       	push   $0x90
  80254e:	68 a9 49 80 00       	push   $0x8049a9
  802553:	e8 a8 e1 ff ff       	call   800700 <_panic>
  802558:	8b 15 44 50 80 00    	mov    0x805044,%edx
  80255e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802561:	89 10                	mov    %edx,(%eax)
  802563:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802566:	8b 00                	mov    (%eax),%eax
  802568:	85 c0                	test   %eax,%eax
  80256a:	74 0d                	je     802579 <initialize_dynamic_allocator+0x1bd>
  80256c:	a1 44 50 80 00       	mov    0x805044,%eax
  802571:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802574:	89 50 04             	mov    %edx,0x4(%eax)
  802577:	eb 08                	jmp    802581 <initialize_dynamic_allocator+0x1c5>
  802579:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80257c:	a3 48 50 80 00       	mov    %eax,0x805048
  802581:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802584:	a3 44 50 80 00       	mov    %eax,0x805044
  802589:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80258c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802593:	a1 50 50 80 00       	mov    0x805050,%eax
  802598:	40                   	inc    %eax
  802599:	a3 50 50 80 00       	mov    %eax,0x805050
  80259e:	eb 07                	jmp    8025a7 <initialize_dynamic_allocator+0x1eb>
        //DON'T CHANGE THESE LINES==========================================================
        //==================================================================================
        {
            if (initSizeOfAllocatedSpace % 2 != 0) initSizeOfAllocatedSpace++; //ensure it's multiple of 2
            if (initSizeOfAllocatedSpace == 0)
                return ;
  8025a0:	90                   	nop
  8025a1:	eb 04                	jmp    8025a7 <initialize_dynamic_allocator+0x1eb>
        //COMMENT THE FOLLOWING LINE BEFORE START CODING
        //panic("initialize_dynamic_allocator is not implemented yet");

    // Check for bounds
    if ((daStart + initSizeOfAllocatedSpace) > KERNEL_HEAP_MAX)
        return;
  8025a3:	90                   	nop
  8025a4:	eb 01                	jmp    8025a7 <initialize_dynamic_allocator+0x1eb>
    if(daStart < USER_HEAP_START)
        return;
  8025a6:	90                   	nop
   first_free_block->prev_next_info.le_next = NULL; // Link to the END block
   first_free_block->prev_next_info.le_prev = NULL;

    // Link the first free block into the free block list
    LIST_INSERT_HEAD(&freeBlocksList , first_free_block);
}
  8025a7:	c9                   	leave  
  8025a8:	c3                   	ret    

008025a9 <set_block_data>:

//==================================
// [2] SET BLOCK HEADER & FOOTER:
//==================================
void set_block_data(void* va, uint32 totalSize, bool isAllocated)
{
  8025a9:	55                   	push   %ebp
  8025aa:	89 e5                	mov    %esp,%ebp
   //TODO: [PROJECT'24.MS1 - #05] [3] DYNAMIC ALLOCATOR - set_block_data
   //COMMENT THE FOLLOWING LINE BEFORE START CODING
   //panic("set_block_data is not implemented yet");
   //Your Code is Here...

	totalSize = totalSize|isAllocated;
  8025ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8025af:	09 45 0c             	or     %eax,0xc(%ebp)
   *HEADER(va) = totalSize;
  8025b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b5:	8d 50 fc             	lea    -0x4(%eax),%edx
  8025b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025bb:	89 02                	mov    %eax,(%edx)
   *FOOTER(va) = totalSize;
  8025bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c0:	83 e8 04             	sub    $0x4,%eax
  8025c3:	8b 00                	mov    (%eax),%eax
  8025c5:	83 e0 fe             	and    $0xfffffffe,%eax
  8025c8:	8d 50 f8             	lea    -0x8(%eax),%edx
  8025cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ce:	01 c2                	add    %eax,%edx
  8025d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025d3:	89 02                	mov    %eax,(%edx)
}
  8025d5:	90                   	nop
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    

008025d8 <alloc_block_FF>:
//=========================================
// [3] ALLOCATE BLOCK BY FIRST FIT:
//=========================================

void *alloc_block_FF(uint32 size)
{
  8025d8:	55                   	push   %ebp
  8025d9:	89 e5                	mov    %esp,%ebp
  8025db:	83 ec 58             	sub    $0x58,%esp
	//==================================================================================
	//DON'T CHANGE THESE LINES==========================================================
	//==================================================================================
	{
		if (size % 2 != 0) size++;	//ensure that the size is even (to use LSB as allocation flag)
  8025de:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e1:	83 e0 01             	and    $0x1,%eax
  8025e4:	85 c0                	test   %eax,%eax
  8025e6:	74 03                	je     8025eb <alloc_block_FF+0x13>
  8025e8:	ff 45 08             	incl   0x8(%ebp)
		if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
  8025eb:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
  8025ef:	77 07                	ja     8025f8 <alloc_block_FF+0x20>
			size = DYN_ALLOC_MIN_BLOCK_SIZE ;
  8025f1:	c7 45 08 08 00 00 00 	movl   $0x8,0x8(%ebp)
		if (!is_initialized)
  8025f8:	a1 24 50 80 00       	mov    0x805024,%eax
  8025fd:	85 c0                	test   %eax,%eax
  8025ff:	75 73                	jne    802674 <alloc_block_FF+0x9c>
		{
			uint32 required_size = size + 2*sizeof(int) /*header & footer*/ + 2*sizeof(int) /*da begin & end*/ ;
  802601:	8b 45 08             	mov    0x8(%ebp),%eax
  802604:	83 c0 10             	add    $0x10,%eax
  802607:	89 45 f0             	mov    %eax,-0x10(%ebp)
			uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE)/PAGE_SIZE);
  80260a:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
  802611:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802614:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802617:	01 d0                	add    %edx,%eax
  802619:	48                   	dec    %eax
  80261a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  80261d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  802620:	ba 00 00 00 00       	mov    $0x0,%edx
  802625:	f7 75 ec             	divl   -0x14(%ebp)
  802628:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80262b:	29 d0                	sub    %edx,%eax
  80262d:	c1 e8 0c             	shr    $0xc,%eax
  802630:	83 ec 0c             	sub    $0xc,%esp
  802633:	50                   	push   %eax
  802634:	e8 1e f1 ff ff       	call   801757 <sbrk>
  802639:	83 c4 10             	add    $0x10,%esp
  80263c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			uint32 da_break = (uint32)sbrk(0);
  80263f:	83 ec 0c             	sub    $0xc,%esp
  802642:	6a 00                	push   $0x0
  802644:	e8 0e f1 ff ff       	call   801757 <sbrk>
  802649:	83 c4 10             	add    $0x10,%esp
  80264c:	89 45 e0             	mov    %eax,-0x20(%ebp)
			initialize_dynamic_allocator(da_start, da_break - da_start);
  80264f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802652:	2b 45 e4             	sub    -0x1c(%ebp),%eax
  802655:	83 ec 08             	sub    $0x8,%esp
  802658:	50                   	push   %eax
  802659:	ff 75 e4             	pushl  -0x1c(%ebp)
  80265c:	e8 5b fd ff ff       	call   8023bc <initialize_dynamic_allocator>
  802661:	83 c4 10             	add    $0x10,%esp
			cprintf("Initialized \n");
  802664:	83 ec 0c             	sub    $0xc,%esp
  802667:	68 e7 49 80 00       	push   $0x8049e7
  80266c:	e8 4c e3 ff ff       	call   8009bd <cprintf>
  802671:	83 c4 10             	add    $0x10,%esp
	//TODO: [PROJECT'24.MS1 - #06] [3] DYNAMIC ALLOCATOR - alloc_block_FF
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
//	panic("alloc_block_FF is not implemented yet");
	//Your Code is Here...

	 if (size == 0) {
  802674:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  802678:	75 0a                	jne    802684 <alloc_block_FF+0xac>
	        return NULL;
  80267a:	b8 00 00 00 00       	mov    $0x0,%eax
  80267f:	e9 0e 04 00 00       	jmp    802a92 <alloc_block_FF+0x4ba>
	    }
	// cprintf("size is %d \n",size);


	    struct BlockElement *blk = NULL;
  802684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	    LIST_FOREACH(blk, &freeBlocksList) {
  80268b:	a1 44 50 80 00       	mov    0x805044,%eax
  802690:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802693:	e9 f3 02 00 00       	jmp    80298b <alloc_block_FF+0x3b3>
	        void *va = (void *)blk;
  802698:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80269b:	89 45 bc             	mov    %eax,-0x44(%ebp)
	        uint32 blk_size = get_block_size(va);
  80269e:	83 ec 0c             	sub    $0xc,%esp
  8026a1:	ff 75 bc             	pushl  -0x44(%ebp)
  8026a4:	e8 af fb ff ff       	call   802258 <get_block_size>
  8026a9:	83 c4 10             	add    $0x10,%esp
  8026ac:	89 45 b8             	mov    %eax,-0x48(%ebp)

	        if(blk_size >= size + 2 * sizeof(uint32)) {
  8026af:	8b 45 08             	mov    0x8(%ebp),%eax
  8026b2:	83 c0 08             	add    $0x8,%eax
  8026b5:	3b 45 b8             	cmp    -0x48(%ebp),%eax
  8026b8:	0f 87 c5 02 00 00    	ja     802983 <alloc_block_FF+0x3ab>
	            if (blk_size >= size + DYN_ALLOC_MIN_BLOCK_SIZE + 4 * sizeof(uint32))
  8026be:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c1:	83 c0 18             	add    $0x18,%eax
  8026c4:	3b 45 b8             	cmp    -0x48(%ebp),%eax
  8026c7:	0f 87 19 02 00 00    	ja     8028e6 <alloc_block_FF+0x30e>
	            {

				uint32 remaining_size = blk_size - size - 2 * sizeof(uint32);
  8026cd:	8b 45 b8             	mov    -0x48(%ebp),%eax
  8026d0:	2b 45 08             	sub    0x8(%ebp),%eax
  8026d3:	83 e8 08             	sub    $0x8,%eax
  8026d6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
				void *new_block_va = (void *)((char *)va + size + 2 * sizeof(uint32));
  8026d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8026dc:	8d 50 08             	lea    0x8(%eax),%edx
  8026df:	8b 45 bc             	mov    -0x44(%ebp),%eax
  8026e2:	01 d0                	add    %edx,%eax
  8026e4:	89 45 b0             	mov    %eax,-0x50(%ebp)
				set_block_data(va, size + 2 * sizeof(uint32), 1);
  8026e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ea:	83 c0 08             	add    $0x8,%eax
  8026ed:	83 ec 04             	sub    $0x4,%esp
  8026f0:	6a 01                	push   $0x1
  8026f2:	50                   	push   %eax
  8026f3:	ff 75 bc             	pushl  -0x44(%ebp)
  8026f6:	e8 ae fe ff ff       	call   8025a9 <set_block_data>
  8026fb:	83 c4 10             	add    $0x10,%esp

				if (LIST_PREV(blk)==NULL)
  8026fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802701:	8b 40 04             	mov    0x4(%eax),%eax
  802704:	85 c0                	test   %eax,%eax
  802706:	75 68                	jne    802770 <alloc_block_FF+0x198>
				{
					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement*)new_block_va);
  802708:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  80270c:	75 17                	jne    802725 <alloc_block_FF+0x14d>
  80270e:	83 ec 04             	sub    $0x4,%esp
  802711:	68 c4 49 80 00       	push   $0x8049c4
  802716:	68 d7 00 00 00       	push   $0xd7
  80271b:	68 a9 49 80 00       	push   $0x8049a9
  802720:	e8 db df ff ff       	call   800700 <_panic>
  802725:	8b 15 44 50 80 00    	mov    0x805044,%edx
  80272b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80272e:	89 10                	mov    %edx,(%eax)
  802730:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802733:	8b 00                	mov    (%eax),%eax
  802735:	85 c0                	test   %eax,%eax
  802737:	74 0d                	je     802746 <alloc_block_FF+0x16e>
  802739:	a1 44 50 80 00       	mov    0x805044,%eax
  80273e:	8b 55 b0             	mov    -0x50(%ebp),%edx
  802741:	89 50 04             	mov    %edx,0x4(%eax)
  802744:	eb 08                	jmp    80274e <alloc_block_FF+0x176>
  802746:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802749:	a3 48 50 80 00       	mov    %eax,0x805048
  80274e:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802751:	a3 44 50 80 00       	mov    %eax,0x805044
  802756:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802759:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802760:	a1 50 50 80 00       	mov    0x805050,%eax
  802765:	40                   	inc    %eax
  802766:	a3 50 50 80 00       	mov    %eax,0x805050
  80276b:	e9 dc 00 00 00       	jmp    80284c <alloc_block_FF+0x274>
				}
				else if (LIST_NEXT(blk)==NULL)
  802770:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802773:	8b 00                	mov    (%eax),%eax
  802775:	85 c0                	test   %eax,%eax
  802777:	75 65                	jne    8027de <alloc_block_FF+0x206>
				{
					LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement*)new_block_va);
  802779:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  80277d:	75 17                	jne    802796 <alloc_block_FF+0x1be>
  80277f:	83 ec 04             	sub    $0x4,%esp
  802782:	68 f8 49 80 00       	push   $0x8049f8
  802787:	68 db 00 00 00       	push   $0xdb
  80278c:	68 a9 49 80 00       	push   $0x8049a9
  802791:	e8 6a df ff ff       	call   800700 <_panic>
  802796:	8b 15 48 50 80 00    	mov    0x805048,%edx
  80279c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80279f:	89 50 04             	mov    %edx,0x4(%eax)
  8027a2:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8027a5:	8b 40 04             	mov    0x4(%eax),%eax
  8027a8:	85 c0                	test   %eax,%eax
  8027aa:	74 0c                	je     8027b8 <alloc_block_FF+0x1e0>
  8027ac:	a1 48 50 80 00       	mov    0x805048,%eax
  8027b1:	8b 55 b0             	mov    -0x50(%ebp),%edx
  8027b4:	89 10                	mov    %edx,(%eax)
  8027b6:	eb 08                	jmp    8027c0 <alloc_block_FF+0x1e8>
  8027b8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8027bb:	a3 44 50 80 00       	mov    %eax,0x805044
  8027c0:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8027c3:	a3 48 50 80 00       	mov    %eax,0x805048
  8027c8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  8027cb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8027d1:	a1 50 50 80 00       	mov    0x805050,%eax
  8027d6:	40                   	inc    %eax
  8027d7:	a3 50 50 80 00       	mov    %eax,0x805050
  8027dc:	eb 6e                	jmp    80284c <alloc_block_FF+0x274>
				}
				else
				{
					LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement*)new_block_va);
  8027de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8027e2:	74 06                	je     8027ea <alloc_block_FF+0x212>
  8027e4:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  8027e8:	75 17                	jne    802801 <alloc_block_FF+0x229>
  8027ea:	83 ec 04             	sub    $0x4,%esp
  8027ed:	68 1c 4a 80 00       	push   $0x804a1c
  8027f2:	68 df 00 00 00       	push   $0xdf
  8027f7:	68 a9 49 80 00       	push   $0x8049a9
  8027fc:	e8 ff de ff ff       	call   800700 <_panic>
  802801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802804:	8b 10                	mov    (%eax),%edx
  802806:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802809:	89 10                	mov    %edx,(%eax)
  80280b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80280e:	8b 00                	mov    (%eax),%eax
  802810:	85 c0                	test   %eax,%eax
  802812:	74 0b                	je     80281f <alloc_block_FF+0x247>
  802814:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802817:	8b 00                	mov    (%eax),%eax
  802819:	8b 55 b0             	mov    -0x50(%ebp),%edx
  80281c:	89 50 04             	mov    %edx,0x4(%eax)
  80281f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802822:	8b 55 b0             	mov    -0x50(%ebp),%edx
  802825:	89 10                	mov    %edx,(%eax)
  802827:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80282a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80282d:	89 50 04             	mov    %edx,0x4(%eax)
  802830:	8b 45 b0             	mov    -0x50(%ebp),%eax
  802833:	8b 00                	mov    (%eax),%eax
  802835:	85 c0                	test   %eax,%eax
  802837:	75 08                	jne    802841 <alloc_block_FF+0x269>
  802839:	8b 45 b0             	mov    -0x50(%ebp),%eax
  80283c:	a3 48 50 80 00       	mov    %eax,0x805048
  802841:	a1 50 50 80 00       	mov    0x805050,%eax
  802846:	40                   	inc    %eax
  802847:	a3 50 50 80 00       	mov    %eax,0x805050
				}
				LIST_REMOVE(&freeBlocksList, blk);
  80284c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802850:	75 17                	jne    802869 <alloc_block_FF+0x291>
  802852:	83 ec 04             	sub    $0x4,%esp
  802855:	68 8b 49 80 00       	push   $0x80498b
  80285a:	68 e1 00 00 00       	push   $0xe1
  80285f:	68 a9 49 80 00       	push   $0x8049a9
  802864:	e8 97 de ff ff       	call   800700 <_panic>
  802869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80286c:	8b 00                	mov    (%eax),%eax
  80286e:	85 c0                	test   %eax,%eax
  802870:	74 10                	je     802882 <alloc_block_FF+0x2aa>
  802872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802875:	8b 00                	mov    (%eax),%eax
  802877:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80287a:	8b 52 04             	mov    0x4(%edx),%edx
  80287d:	89 50 04             	mov    %edx,0x4(%eax)
  802880:	eb 0b                	jmp    80288d <alloc_block_FF+0x2b5>
  802882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802885:	8b 40 04             	mov    0x4(%eax),%eax
  802888:	a3 48 50 80 00       	mov    %eax,0x805048
  80288d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802890:	8b 40 04             	mov    0x4(%eax),%eax
  802893:	85 c0                	test   %eax,%eax
  802895:	74 0f                	je     8028a6 <alloc_block_FF+0x2ce>
  802897:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80289a:	8b 40 04             	mov    0x4(%eax),%eax
  80289d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8028a0:	8b 12                	mov    (%edx),%edx
  8028a2:	89 10                	mov    %edx,(%eax)
  8028a4:	eb 0a                	jmp    8028b0 <alloc_block_FF+0x2d8>
  8028a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a9:	8b 00                	mov    (%eax),%eax
  8028ab:	a3 44 50 80 00       	mov    %eax,0x805044
  8028b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8028b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028bc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8028c3:	a1 50 50 80 00       	mov    0x805050,%eax
  8028c8:	48                   	dec    %eax
  8028c9:	a3 50 50 80 00       	mov    %eax,0x805050
				set_block_data(new_block_va, remaining_size, 0);
  8028ce:	83 ec 04             	sub    $0x4,%esp
  8028d1:	6a 00                	push   $0x0
  8028d3:	ff 75 b4             	pushl  -0x4c(%ebp)
  8028d6:	ff 75 b0             	pushl  -0x50(%ebp)
  8028d9:	e8 cb fc ff ff       	call   8025a9 <set_block_data>
  8028de:	83 c4 10             	add    $0x10,%esp
  8028e1:	e9 95 00 00 00       	jmp    80297b <alloc_block_FF+0x3a3>
	            }
	            else
	            {

	            	set_block_data(va, blk_size, 1);
  8028e6:	83 ec 04             	sub    $0x4,%esp
  8028e9:	6a 01                	push   $0x1
  8028eb:	ff 75 b8             	pushl  -0x48(%ebp)
  8028ee:	ff 75 bc             	pushl  -0x44(%ebp)
  8028f1:	e8 b3 fc ff ff       	call   8025a9 <set_block_data>
  8028f6:	83 c4 10             	add    $0x10,%esp
	            	LIST_REMOVE(&freeBlocksList,blk);
  8028f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8028fd:	75 17                	jne    802916 <alloc_block_FF+0x33e>
  8028ff:	83 ec 04             	sub    $0x4,%esp
  802902:	68 8b 49 80 00       	push   $0x80498b
  802907:	68 e8 00 00 00       	push   $0xe8
  80290c:	68 a9 49 80 00       	push   $0x8049a9
  802911:	e8 ea dd ff ff       	call   800700 <_panic>
  802916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802919:	8b 00                	mov    (%eax),%eax
  80291b:	85 c0                	test   %eax,%eax
  80291d:	74 10                	je     80292f <alloc_block_FF+0x357>
  80291f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802922:	8b 00                	mov    (%eax),%eax
  802924:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802927:	8b 52 04             	mov    0x4(%edx),%edx
  80292a:	89 50 04             	mov    %edx,0x4(%eax)
  80292d:	eb 0b                	jmp    80293a <alloc_block_FF+0x362>
  80292f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802932:	8b 40 04             	mov    0x4(%eax),%eax
  802935:	a3 48 50 80 00       	mov    %eax,0x805048
  80293a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80293d:	8b 40 04             	mov    0x4(%eax),%eax
  802940:	85 c0                	test   %eax,%eax
  802942:	74 0f                	je     802953 <alloc_block_FF+0x37b>
  802944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802947:	8b 40 04             	mov    0x4(%eax),%eax
  80294a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80294d:	8b 12                	mov    (%edx),%edx
  80294f:	89 10                	mov    %edx,(%eax)
  802951:	eb 0a                	jmp    80295d <alloc_block_FF+0x385>
  802953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802956:	8b 00                	mov    (%eax),%eax
  802958:	a3 44 50 80 00       	mov    %eax,0x805044
  80295d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802960:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802969:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802970:	a1 50 50 80 00       	mov    0x805050,%eax
  802975:	48                   	dec    %eax
  802976:	a3 50 50 80 00       	mov    %eax,0x805050
	            }
	            return va;
  80297b:	8b 45 bc             	mov    -0x44(%ebp),%eax
  80297e:	e9 0f 01 00 00       	jmp    802a92 <alloc_block_FF+0x4ba>
	    }
	// cprintf("size is %d \n",size);


	    struct BlockElement *blk = NULL;
	    LIST_FOREACH(blk, &freeBlocksList) {
  802983:	a1 4c 50 80 00       	mov    0x80504c,%eax
  802988:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80298b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80298f:	74 07                	je     802998 <alloc_block_FF+0x3c0>
  802991:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802994:	8b 00                	mov    (%eax),%eax
  802996:	eb 05                	jmp    80299d <alloc_block_FF+0x3c5>
  802998:	b8 00 00 00 00       	mov    $0x0,%eax
  80299d:	a3 4c 50 80 00       	mov    %eax,0x80504c
  8029a2:	a1 4c 50 80 00       	mov    0x80504c,%eax
  8029a7:	85 c0                	test   %eax,%eax
  8029a9:	0f 85 e9 fc ff ff    	jne    802698 <alloc_block_FF+0xc0>
  8029af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8029b3:	0f 85 df fc ff ff    	jne    802698 <alloc_block_FF+0xc0>
	            	LIST_REMOVE(&freeBlocksList,blk);
	            }
	            return va;
	        }
	    }
	    uint32 required_size = size + 2 * sizeof(uint32);
  8029b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8029bc:	83 c0 08             	add    $0x8,%eax
  8029bf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	    void *new_mem = sbrk(ROUNDUP(required_size, PAGE_SIZE) / PAGE_SIZE);
  8029c2:	c7 45 d8 00 10 00 00 	movl   $0x1000,-0x28(%ebp)
  8029c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8029cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8029cf:	01 d0                	add    %edx,%eax
  8029d1:	48                   	dec    %eax
  8029d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8029d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8029d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8029dd:	f7 75 d8             	divl   -0x28(%ebp)
  8029e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8029e3:	29 d0                	sub    %edx,%eax
  8029e5:	c1 e8 0c             	shr    $0xc,%eax
  8029e8:	83 ec 0c             	sub    $0xc,%esp
  8029eb:	50                   	push   %eax
  8029ec:	e8 66 ed ff ff       	call   801757 <sbrk>
  8029f1:	83 c4 10             	add    $0x10,%esp
  8029f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		if (new_mem == (void *)-1) {
  8029f7:	83 7d d0 ff          	cmpl   $0xffffffff,-0x30(%ebp)
  8029fb:	75 0a                	jne    802a07 <alloc_block_FF+0x42f>
			return NULL; // Allocation failed
  8029fd:	b8 00 00 00 00       	mov    $0x0,%eax
  802a02:	e9 8b 00 00 00       	jmp    802a92 <alloc_block_FF+0x4ba>
		}
		else {
			end_block = (struct Block_Start_End*) (new_mem + ROUNDUP(required_size, PAGE_SIZE)-sizeof(int));
  802a07:	c7 45 cc 00 10 00 00 	movl   $0x1000,-0x34(%ebp)
  802a0e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802a11:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802a14:	01 d0                	add    %edx,%eax
  802a16:	48                   	dec    %eax
  802a17:	89 45 c8             	mov    %eax,-0x38(%ebp)
  802a1a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  802a22:	f7 75 cc             	divl   -0x34(%ebp)
  802a25:	8b 45 c8             	mov    -0x38(%ebp),%eax
  802a28:	29 d0                	sub    %edx,%eax
  802a2a:	8d 50 fc             	lea    -0x4(%eax),%edx
  802a2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  802a30:	01 d0                	add    %edx,%eax
  802a32:	a3 48 92 80 00       	mov    %eax,0x809248
			end_block->info = 1;
  802a37:	a1 48 92 80 00       	mov    0x809248,%eax
  802a3c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		set_block_data(new_mem, ROUNDUP(required_size, PAGE_SIZE), 1);
  802a42:	c7 45 c4 00 10 00 00 	movl   $0x1000,-0x3c(%ebp)
  802a49:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802a4c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  802a4f:	01 d0                	add    %edx,%eax
  802a51:	48                   	dec    %eax
  802a52:	89 45 c0             	mov    %eax,-0x40(%ebp)
  802a55:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802a58:	ba 00 00 00 00       	mov    $0x0,%edx
  802a5d:	f7 75 c4             	divl   -0x3c(%ebp)
  802a60:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802a63:	29 d0                	sub    %edx,%eax
  802a65:	83 ec 04             	sub    $0x4,%esp
  802a68:	6a 01                	push   $0x1
  802a6a:	50                   	push   %eax
  802a6b:	ff 75 d0             	pushl  -0x30(%ebp)
  802a6e:	e8 36 fb ff ff       	call   8025a9 <set_block_data>
  802a73:	83 c4 10             	add    $0x10,%esp
		free_block(new_mem);
  802a76:	83 ec 0c             	sub    $0xc,%esp
  802a79:	ff 75 d0             	pushl  -0x30(%ebp)
  802a7c:	e8 1b 0a 00 00       	call   80349c <free_block>
  802a81:	83 c4 10             	add    $0x10,%esp
		return alloc_block_FF(size);
  802a84:	83 ec 0c             	sub    $0xc,%esp
  802a87:	ff 75 08             	pushl  0x8(%ebp)
  802a8a:	e8 49 fb ff ff       	call   8025d8 <alloc_block_FF>
  802a8f:	83 c4 10             	add    $0x10,%esp
		}
		return new_mem;
}
  802a92:	c9                   	leave  
  802a93:	c3                   	ret    

00802a94 <alloc_block_BF>:
//=========================================
// [4] ALLOCATE BLOCK BY BEST FIT:
//=========================================
void *alloc_block_BF(uint32 size)
{
  802a94:	55                   	push   %ebp
  802a95:	89 e5                	mov    %esp,%ebp
  802a97:	83 ec 68             	sub    $0x68,%esp
	//Your Code is Here...
	//==================================================================================
	//DON'T CHANGE THESE LINES==========================================================
	//==================================================================================
	{
		if (size % 2 != 0) size++;	//ensure that the size is even (to use LSB as allocation flag)
  802a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  802a9d:	83 e0 01             	and    $0x1,%eax
  802aa0:	85 c0                	test   %eax,%eax
  802aa2:	74 03                	je     802aa7 <alloc_block_BF+0x13>
  802aa4:	ff 45 08             	incl   0x8(%ebp)
		if (size < DYN_ALLOC_MIN_BLOCK_SIZE)
  802aa7:	83 7d 08 07          	cmpl   $0x7,0x8(%ebp)
  802aab:	77 07                	ja     802ab4 <alloc_block_BF+0x20>
			size = DYN_ALLOC_MIN_BLOCK_SIZE ;
  802aad:	c7 45 08 08 00 00 00 	movl   $0x8,0x8(%ebp)
		if (!is_initialized)
  802ab4:	a1 24 50 80 00       	mov    0x805024,%eax
  802ab9:	85 c0                	test   %eax,%eax
  802abb:	75 73                	jne    802b30 <alloc_block_BF+0x9c>
		{
			uint32 required_size = size + 2*sizeof(int) /*header & footer*/ + 2*sizeof(int) /*da begin & end*/ ;
  802abd:	8b 45 08             	mov    0x8(%ebp),%eax
  802ac0:	83 c0 10             	add    $0x10,%eax
  802ac3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			uint32 da_start = (uint32)sbrk(ROUNDUP(required_size, PAGE_SIZE)/PAGE_SIZE);
  802ac6:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)
  802acd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802ad0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802ad3:	01 d0                	add    %edx,%eax
  802ad5:	48                   	dec    %eax
  802ad6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802ad9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802adc:	ba 00 00 00 00       	mov    $0x0,%edx
  802ae1:	f7 75 e0             	divl   -0x20(%ebp)
  802ae4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802ae7:	29 d0                	sub    %edx,%eax
  802ae9:	c1 e8 0c             	shr    $0xc,%eax
  802aec:	83 ec 0c             	sub    $0xc,%esp
  802aef:	50                   	push   %eax
  802af0:	e8 62 ec ff ff       	call   801757 <sbrk>
  802af5:	83 c4 10             	add    $0x10,%esp
  802af8:	89 45 d8             	mov    %eax,-0x28(%ebp)
			uint32 da_break = (uint32)sbrk(0);
  802afb:	83 ec 0c             	sub    $0xc,%esp
  802afe:	6a 00                	push   $0x0
  802b00:	e8 52 ec ff ff       	call   801757 <sbrk>
  802b05:	83 c4 10             	add    $0x10,%esp
  802b08:	89 45 d4             	mov    %eax,-0x2c(%ebp)
			initialize_dynamic_allocator(da_start, da_break - da_start);
  802b0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802b0e:	2b 45 d8             	sub    -0x28(%ebp),%eax
  802b11:	83 ec 08             	sub    $0x8,%esp
  802b14:	50                   	push   %eax
  802b15:	ff 75 d8             	pushl  -0x28(%ebp)
  802b18:	e8 9f f8 ff ff       	call   8023bc <initialize_dynamic_allocator>
  802b1d:	83 c4 10             	add    $0x10,%esp
			cprintf("Initialized \n");
  802b20:	83 ec 0c             	sub    $0xc,%esp
  802b23:	68 e7 49 80 00       	push   $0x8049e7
  802b28:	e8 90 de ff ff       	call   8009bd <cprintf>
  802b2d:	83 c4 10             	add    $0x10,%esp
		}
	}
	//==================================================================================
	//==================================================================================

	struct BlockElement *blk = NULL;
  802b30:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	void *best_va=NULL;
  802b37:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	uint32 best_blk_size = (uint32)KERNEL_HEAP_MAX - 2 * sizeof(uint32);
  802b3e:	c7 45 ec f8 ef ff ff 	movl   $0xffffeff8,-0x14(%ebp)
	bool internal = 0;
  802b45:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
	LIST_FOREACH(blk, &freeBlocksList) {
  802b4c:	a1 44 50 80 00       	mov    0x805044,%eax
  802b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802b54:	e9 1d 01 00 00       	jmp    802c76 <alloc_block_BF+0x1e2>
		void *va = (void *)blk;
  802b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b5c:	89 45 a8             	mov    %eax,-0x58(%ebp)
		uint32 blk_size = get_block_size(va);
  802b5f:	83 ec 0c             	sub    $0xc,%esp
  802b62:	ff 75 a8             	pushl  -0x58(%ebp)
  802b65:	e8 ee f6 ff ff       	call   802258 <get_block_size>
  802b6a:	83 c4 10             	add    $0x10,%esp
  802b6d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		if (blk_size>=size + 2 * sizeof(uint32))
  802b70:	8b 45 08             	mov    0x8(%ebp),%eax
  802b73:	83 c0 08             	add    $0x8,%eax
  802b76:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802b79:	0f 87 ef 00 00 00    	ja     802c6e <alloc_block_BF+0x1da>
		{
			if (blk_size >= size + DYN_ALLOC_MIN_BLOCK_SIZE + 4 * sizeof(uint32))
  802b7f:	8b 45 08             	mov    0x8(%ebp),%eax
  802b82:	83 c0 18             	add    $0x18,%eax
  802b85:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802b88:	77 1d                	ja     802ba7 <alloc_block_BF+0x113>
			{
				if (best_blk_size > blk_size)
  802b8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802b8d:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802b90:	0f 86 d8 00 00 00    	jbe    802c6e <alloc_block_BF+0x1da>
				{
					best_va = va;
  802b96:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802b99:	89 45 f0             	mov    %eax,-0x10(%ebp)
					best_blk_size = blk_size;
  802b9c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  802b9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802ba2:	e9 c7 00 00 00       	jmp    802c6e <alloc_block_BF+0x1da>
				}
			}
			else
			{
				if (blk_size == size + 2 * sizeof(uint32)){
  802ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  802baa:	83 c0 08             	add    $0x8,%eax
  802bad:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802bb0:	0f 85 9d 00 00 00    	jne    802c53 <alloc_block_BF+0x1bf>
					set_block_data(va, blk_size, 1);
  802bb6:	83 ec 04             	sub    $0x4,%esp
  802bb9:	6a 01                	push   $0x1
  802bbb:	ff 75 a4             	pushl  -0x5c(%ebp)
  802bbe:	ff 75 a8             	pushl  -0x58(%ebp)
  802bc1:	e8 e3 f9 ff ff       	call   8025a9 <set_block_data>
  802bc6:	83 c4 10             	add    $0x10,%esp
					LIST_REMOVE(&freeBlocksList,blk);
  802bc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802bcd:	75 17                	jne    802be6 <alloc_block_BF+0x152>
  802bcf:	83 ec 04             	sub    $0x4,%esp
  802bd2:	68 8b 49 80 00       	push   $0x80498b
  802bd7:	68 2c 01 00 00       	push   $0x12c
  802bdc:	68 a9 49 80 00       	push   $0x8049a9
  802be1:	e8 1a db ff ff       	call   800700 <_panic>
  802be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802be9:	8b 00                	mov    (%eax),%eax
  802beb:	85 c0                	test   %eax,%eax
  802bed:	74 10                	je     802bff <alloc_block_BF+0x16b>
  802bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802bf2:	8b 00                	mov    (%eax),%eax
  802bf4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802bf7:	8b 52 04             	mov    0x4(%edx),%edx
  802bfa:	89 50 04             	mov    %edx,0x4(%eax)
  802bfd:	eb 0b                	jmp    802c0a <alloc_block_BF+0x176>
  802bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c02:	8b 40 04             	mov    0x4(%eax),%eax
  802c05:	a3 48 50 80 00       	mov    %eax,0x805048
  802c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c0d:	8b 40 04             	mov    0x4(%eax),%eax
  802c10:	85 c0                	test   %eax,%eax
  802c12:	74 0f                	je     802c23 <alloc_block_BF+0x18f>
  802c14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c17:	8b 40 04             	mov    0x4(%eax),%eax
  802c1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c1d:	8b 12                	mov    (%edx),%edx
  802c1f:	89 10                	mov    %edx,(%eax)
  802c21:	eb 0a                	jmp    802c2d <alloc_block_BF+0x199>
  802c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c26:	8b 00                	mov    (%eax),%eax
  802c28:	a3 44 50 80 00       	mov    %eax,0x805044
  802c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c39:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802c40:	a1 50 50 80 00       	mov    0x805050,%eax
  802c45:	48                   	dec    %eax
  802c46:	a3 50 50 80 00       	mov    %eax,0x805050
					return va;
  802c4b:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802c4e:	e9 24 04 00 00       	jmp    803077 <alloc_block_BF+0x5e3>
				}
				else
				{
					if (best_blk_size > blk_size)
  802c53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802c56:	3b 45 a4             	cmp    -0x5c(%ebp),%eax
  802c59:	76 13                	jbe    802c6e <alloc_block_BF+0x1da>
					{
						internal = 1;
  802c5b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
						best_va = va;
  802c62:	8b 45 a8             	mov    -0x58(%ebp),%eax
  802c65:	89 45 f0             	mov    %eax,-0x10(%ebp)
						best_blk_size = blk_size;
  802c68:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  802c6b:	89 45 ec             	mov    %eax,-0x14(%ebp)

	struct BlockElement *blk = NULL;
	void *best_va=NULL;
	uint32 best_blk_size = (uint32)KERNEL_HEAP_MAX - 2 * sizeof(uint32);
	bool internal = 0;
	LIST_FOREACH(blk, &freeBlocksList) {
  802c6e:	a1 4c 50 80 00       	mov    0x80504c,%eax
  802c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802c76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802c7a:	74 07                	je     802c83 <alloc_block_BF+0x1ef>
  802c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c7f:	8b 00                	mov    (%eax),%eax
  802c81:	eb 05                	jmp    802c88 <alloc_block_BF+0x1f4>
  802c83:	b8 00 00 00 00       	mov    $0x0,%eax
  802c88:	a3 4c 50 80 00       	mov    %eax,0x80504c
  802c8d:	a1 4c 50 80 00       	mov    0x80504c,%eax
  802c92:	85 c0                	test   %eax,%eax
  802c94:	0f 85 bf fe ff ff    	jne    802b59 <alloc_block_BF+0xc5>
  802c9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  802c9e:	0f 85 b5 fe ff ff    	jne    802b59 <alloc_block_BF+0xc5>
			}
		}

	}

	if (best_va !=NULL && internal ==0){
  802ca4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802ca8:	0f 84 26 02 00 00    	je     802ed4 <alloc_block_BF+0x440>
  802cae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  802cb2:	0f 85 1c 02 00 00    	jne    802ed4 <alloc_block_BF+0x440>
		uint32 remaining_size = best_blk_size - size - 2 * sizeof(uint32);
  802cb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802cbb:	2b 45 08             	sub    0x8(%ebp),%eax
  802cbe:	83 e8 08             	sub    $0x8,%eax
  802cc1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		void *new_block_va = (void *)((char *)best_va + size + 2 * sizeof(uint32));
  802cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  802cc7:	8d 50 08             	lea    0x8(%eax),%edx
  802cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ccd:	01 d0                	add    %edx,%eax
  802ccf:	89 45 cc             	mov    %eax,-0x34(%ebp)
		set_block_data(best_va, size + 2 * sizeof(uint32), 1);
  802cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  802cd5:	83 c0 08             	add    $0x8,%eax
  802cd8:	83 ec 04             	sub    $0x4,%esp
  802cdb:	6a 01                	push   $0x1
  802cdd:	50                   	push   %eax
  802cde:	ff 75 f0             	pushl  -0x10(%ebp)
  802ce1:	e8 c3 f8 ff ff       	call   8025a9 <set_block_data>
  802ce6:	83 c4 10             	add    $0x10,%esp

		if (LIST_PREV((struct BlockElement *)best_va)==NULL)
  802ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cec:	8b 40 04             	mov    0x4(%eax),%eax
  802cef:	85 c0                	test   %eax,%eax
  802cf1:	75 68                	jne    802d5b <alloc_block_BF+0x2c7>
			{

				LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement*)new_block_va);
  802cf3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  802cf7:	75 17                	jne    802d10 <alloc_block_BF+0x27c>
  802cf9:	83 ec 04             	sub    $0x4,%esp
  802cfc:	68 c4 49 80 00       	push   $0x8049c4
  802d01:	68 45 01 00 00       	push   $0x145
  802d06:	68 a9 49 80 00       	push   $0x8049a9
  802d0b:	e8 f0 d9 ff ff       	call   800700 <_panic>
  802d10:	8b 15 44 50 80 00    	mov    0x805044,%edx
  802d16:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802d19:	89 10                	mov    %edx,(%eax)
  802d1b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802d1e:	8b 00                	mov    (%eax),%eax
  802d20:	85 c0                	test   %eax,%eax
  802d22:	74 0d                	je     802d31 <alloc_block_BF+0x29d>
  802d24:	a1 44 50 80 00       	mov    0x805044,%eax
  802d29:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802d2c:	89 50 04             	mov    %edx,0x4(%eax)
  802d2f:	eb 08                	jmp    802d39 <alloc_block_BF+0x2a5>
  802d31:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802d34:	a3 48 50 80 00       	mov    %eax,0x805048
  802d39:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802d3c:	a3 44 50 80 00       	mov    %eax,0x805044
  802d41:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802d44:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802d4b:	a1 50 50 80 00       	mov    0x805050,%eax
  802d50:	40                   	inc    %eax
  802d51:	a3 50 50 80 00       	mov    %eax,0x805050
  802d56:	e9 dc 00 00 00       	jmp    802e37 <alloc_block_BF+0x3a3>
			}
			else if (LIST_NEXT((struct BlockElement *)best_va)==NULL)
  802d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d5e:	8b 00                	mov    (%eax),%eax
  802d60:	85 c0                	test   %eax,%eax
  802d62:	75 65                	jne    802dc9 <alloc_block_BF+0x335>
			{

				LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement*)new_block_va);
  802d64:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  802d68:	75 17                	jne    802d81 <alloc_block_BF+0x2ed>
  802d6a:	83 ec 04             	sub    $0x4,%esp
  802d6d:	68 f8 49 80 00       	push   $0x8049f8
  802d72:	68 4a 01 00 00       	push   $0x14a
  802d77:	68 a9 49 80 00       	push   $0x8049a9
  802d7c:	e8 7f d9 ff ff       	call   800700 <_panic>
  802d81:	8b 15 48 50 80 00    	mov    0x805048,%edx
  802d87:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802d8a:	89 50 04             	mov    %edx,0x4(%eax)
  802d8d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802d90:	8b 40 04             	mov    0x4(%eax),%eax
  802d93:	85 c0                	test   %eax,%eax
  802d95:	74 0c                	je     802da3 <alloc_block_BF+0x30f>
  802d97:	a1 48 50 80 00       	mov    0x805048,%eax
  802d9c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802d9f:	89 10                	mov    %edx,(%eax)
  802da1:	eb 08                	jmp    802dab <alloc_block_BF+0x317>
  802da3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802da6:	a3 44 50 80 00       	mov    %eax,0x805044
  802dab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802dae:	a3 48 50 80 00       	mov    %eax,0x805048
  802db3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802db6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802dbc:	a1 50 50 80 00       	mov    0x805050,%eax
  802dc1:	40                   	inc    %eax
  802dc2:	a3 50 50 80 00       	mov    %eax,0x805050
  802dc7:	eb 6e                	jmp    802e37 <alloc_block_BF+0x3a3>
			}
			else
			{

				LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement *)best_va, (struct BlockElement*)new_block_va);
  802dc9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802dcd:	74 06                	je     802dd5 <alloc_block_BF+0x341>
  802dcf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  802dd3:	75 17                	jne    802dec <alloc_block_BF+0x358>
  802dd5:	83 ec 04             	sub    $0x4,%esp
  802dd8:	68 1c 4a 80 00       	push   $0x804a1c
  802ddd:	68 4f 01 00 00       	push   $0x14f
  802de2:	68 a9 49 80 00       	push   $0x8049a9
  802de7:	e8 14 d9 ff ff       	call   800700 <_panic>
  802dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802def:	8b 10                	mov    (%eax),%edx
  802df1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802df4:	89 10                	mov    %edx,(%eax)
  802df6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802df9:	8b 00                	mov    (%eax),%eax
  802dfb:	85 c0                	test   %eax,%eax
  802dfd:	74 0b                	je     802e0a <alloc_block_BF+0x376>
  802dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e02:	8b 00                	mov    (%eax),%eax
  802e04:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802e07:	89 50 04             	mov    %edx,0x4(%eax)
  802e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e0d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802e10:	89 10                	mov    %edx,(%eax)
  802e12:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802e15:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802e18:	89 50 04             	mov    %edx,0x4(%eax)
  802e1b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802e1e:	8b 00                	mov    (%eax),%eax
  802e20:	85 c0                	test   %eax,%eax
  802e22:	75 08                	jne    802e2c <alloc_block_BF+0x398>
  802e24:	8b 45 cc             	mov    -0x34(%ebp),%eax
  802e27:	a3 48 50 80 00       	mov    %eax,0x805048
  802e2c:	a1 50 50 80 00       	mov    0x805050,%eax
  802e31:	40                   	inc    %eax
  802e32:	a3 50 50 80 00       	mov    %eax,0x805050
			}
			LIST_REMOVE(&freeBlocksList, (struct BlockElement *)best_va);
  802e37:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802e3b:	75 17                	jne    802e54 <alloc_block_BF+0x3c0>
  802e3d:	83 ec 04             	sub    $0x4,%esp
  802e40:	68 8b 49 80 00       	push   $0x80498b
  802e45:	68 51 01 00 00       	push   $0x151
  802e4a:	68 a9 49 80 00       	push   $0x8049a9
  802e4f:	e8 ac d8 ff ff       	call   800700 <_panic>
  802e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e57:	8b 00                	mov    (%eax),%eax
  802e59:	85 c0                	test   %eax,%eax
  802e5b:	74 10                	je     802e6d <alloc_block_BF+0x3d9>
  802e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e60:	8b 00                	mov    (%eax),%eax
  802e62:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802e65:	8b 52 04             	mov    0x4(%edx),%edx
  802e68:	89 50 04             	mov    %edx,0x4(%eax)
  802e6b:	eb 0b                	jmp    802e78 <alloc_block_BF+0x3e4>
  802e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e70:	8b 40 04             	mov    0x4(%eax),%eax
  802e73:	a3 48 50 80 00       	mov    %eax,0x805048
  802e78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e7b:	8b 40 04             	mov    0x4(%eax),%eax
  802e7e:	85 c0                	test   %eax,%eax
  802e80:	74 0f                	je     802e91 <alloc_block_BF+0x3fd>
  802e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e85:	8b 40 04             	mov    0x4(%eax),%eax
  802e88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802e8b:	8b 12                	mov    (%edx),%edx
  802e8d:	89 10                	mov    %edx,(%eax)
  802e8f:	eb 0a                	jmp    802e9b <alloc_block_BF+0x407>
  802e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e94:	8b 00                	mov    (%eax),%eax
  802e96:	a3 44 50 80 00       	mov    %eax,0x805044
  802e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ea7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802eae:	a1 50 50 80 00       	mov    0x805050,%eax
  802eb3:	48                   	dec    %eax
  802eb4:	a3 50 50 80 00       	mov    %eax,0x805050
			set_block_data(new_block_va, remaining_size, 0);
  802eb9:	83 ec 04             	sub    $0x4,%esp
  802ebc:	6a 00                	push   $0x0
  802ebe:	ff 75 d0             	pushl  -0x30(%ebp)
  802ec1:	ff 75 cc             	pushl  -0x34(%ebp)
  802ec4:	e8 e0 f6 ff ff       	call   8025a9 <set_block_data>
  802ec9:	83 c4 10             	add    $0x10,%esp
			return best_va;
  802ecc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ecf:	e9 a3 01 00 00       	jmp    803077 <alloc_block_BF+0x5e3>
	}
	else if(internal == 1)
  802ed4:	83 7d e8 01          	cmpl   $0x1,-0x18(%ebp)
  802ed8:	0f 85 9d 00 00 00    	jne    802f7b <alloc_block_BF+0x4e7>
	{
		set_block_data(best_va, best_blk_size, 1);
  802ede:	83 ec 04             	sub    $0x4,%esp
  802ee1:	6a 01                	push   $0x1
  802ee3:	ff 75 ec             	pushl  -0x14(%ebp)
  802ee6:	ff 75 f0             	pushl  -0x10(%ebp)
  802ee9:	e8 bb f6 ff ff       	call   8025a9 <set_block_data>
  802eee:	83 c4 10             	add    $0x10,%esp
		LIST_REMOVE(&freeBlocksList,(struct BlockElement *)best_va);
  802ef1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802ef5:	75 17                	jne    802f0e <alloc_block_BF+0x47a>
  802ef7:	83 ec 04             	sub    $0x4,%esp
  802efa:	68 8b 49 80 00       	push   $0x80498b
  802eff:	68 58 01 00 00       	push   $0x158
  802f04:	68 a9 49 80 00       	push   $0x8049a9
  802f09:	e8 f2 d7 ff ff       	call   800700 <_panic>
  802f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f11:	8b 00                	mov    (%eax),%eax
  802f13:	85 c0                	test   %eax,%eax
  802f15:	74 10                	je     802f27 <alloc_block_BF+0x493>
  802f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f1a:	8b 00                	mov    (%eax),%eax
  802f1c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802f1f:	8b 52 04             	mov    0x4(%edx),%edx
  802f22:	89 50 04             	mov    %edx,0x4(%eax)
  802f25:	eb 0b                	jmp    802f32 <alloc_block_BF+0x49e>
  802f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f2a:	8b 40 04             	mov    0x4(%eax),%eax
  802f2d:	a3 48 50 80 00       	mov    %eax,0x805048
  802f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f35:	8b 40 04             	mov    0x4(%eax),%eax
  802f38:	85 c0                	test   %eax,%eax
  802f3a:	74 0f                	je     802f4b <alloc_block_BF+0x4b7>
  802f3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f3f:	8b 40 04             	mov    0x4(%eax),%eax
  802f42:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802f45:	8b 12                	mov    (%edx),%edx
  802f47:	89 10                	mov    %edx,(%eax)
  802f49:	eb 0a                	jmp    802f55 <alloc_block_BF+0x4c1>
  802f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f4e:	8b 00                	mov    (%eax),%eax
  802f50:	a3 44 50 80 00       	mov    %eax,0x805044
  802f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  802f5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f61:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  802f68:	a1 50 50 80 00       	mov    0x805050,%eax
  802f6d:	48                   	dec    %eax
  802f6e:	a3 50 50 80 00       	mov    %eax,0x805050
		return best_va;
  802f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802f76:	e9 fc 00 00 00       	jmp    803077 <alloc_block_BF+0x5e3>
	}
	uint32 required_size = size + 2 * sizeof(uint32);
  802f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  802f7e:	83 c0 08             	add    $0x8,%eax
  802f81:	89 45 c8             	mov    %eax,-0x38(%ebp)
		    void *new_mem = sbrk(ROUNDUP(required_size, PAGE_SIZE) / PAGE_SIZE);
  802f84:	c7 45 c4 00 10 00 00 	movl   $0x1000,-0x3c(%ebp)
  802f8b:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802f8e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  802f91:	01 d0                	add    %edx,%eax
  802f93:	48                   	dec    %eax
  802f94:	89 45 c0             	mov    %eax,-0x40(%ebp)
  802f97:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802f9a:	ba 00 00 00 00       	mov    $0x0,%edx
  802f9f:	f7 75 c4             	divl   -0x3c(%ebp)
  802fa2:	8b 45 c0             	mov    -0x40(%ebp),%eax
  802fa5:	29 d0                	sub    %edx,%eax
  802fa7:	c1 e8 0c             	shr    $0xc,%eax
  802faa:	83 ec 0c             	sub    $0xc,%esp
  802fad:	50                   	push   %eax
  802fae:	e8 a4 e7 ff ff       	call   801757 <sbrk>
  802fb3:	83 c4 10             	add    $0x10,%esp
  802fb6:	89 45 bc             	mov    %eax,-0x44(%ebp)
			if (new_mem == (void *)-1) {
  802fb9:	83 7d bc ff          	cmpl   $0xffffffff,-0x44(%ebp)
  802fbd:	75 0a                	jne    802fc9 <alloc_block_BF+0x535>
				return NULL; // Allocation failed
  802fbf:	b8 00 00 00 00       	mov    $0x0,%eax
  802fc4:	e9 ae 00 00 00       	jmp    803077 <alloc_block_BF+0x5e3>
			}
			else {
				end_block = (struct Block_Start_End*) (new_mem + ROUNDUP(required_size, PAGE_SIZE)-sizeof(int));
  802fc9:	c7 45 b8 00 10 00 00 	movl   $0x1000,-0x48(%ebp)
  802fd0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  802fd3:	8b 45 b8             	mov    -0x48(%ebp),%eax
  802fd6:	01 d0                	add    %edx,%eax
  802fd8:	48                   	dec    %eax
  802fd9:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  802fdc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  802fdf:	ba 00 00 00 00       	mov    $0x0,%edx
  802fe4:	f7 75 b8             	divl   -0x48(%ebp)
  802fe7:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  802fea:	29 d0                	sub    %edx,%eax
  802fec:	8d 50 fc             	lea    -0x4(%eax),%edx
  802fef:	8b 45 bc             	mov    -0x44(%ebp),%eax
  802ff2:	01 d0                	add    %edx,%eax
  802ff4:	a3 48 92 80 00       	mov    %eax,0x809248
				end_block->info = 1;
  802ff9:	a1 48 92 80 00       	mov    0x809248,%eax
  802ffe:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
				cprintf("251\n");
  803004:	83 ec 0c             	sub    $0xc,%esp
  803007:	68 50 4a 80 00       	push   $0x804a50
  80300c:	e8 ac d9 ff ff       	call   8009bd <cprintf>
  803011:	83 c4 10             	add    $0x10,%esp
			cprintf("address : %x\n",new_mem);
  803014:	83 ec 08             	sub    $0x8,%esp
  803017:	ff 75 bc             	pushl  -0x44(%ebp)
  80301a:	68 55 4a 80 00       	push   $0x804a55
  80301f:	e8 99 d9 ff ff       	call   8009bd <cprintf>
  803024:	83 c4 10             	add    $0x10,%esp
			set_block_data(new_mem, ROUNDUP(required_size, PAGE_SIZE), 1);
  803027:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  80302e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  803031:	8b 45 b0             	mov    -0x50(%ebp),%eax
  803034:	01 d0                	add    %edx,%eax
  803036:	48                   	dec    %eax
  803037:	89 45 ac             	mov    %eax,-0x54(%ebp)
  80303a:	8b 45 ac             	mov    -0x54(%ebp),%eax
  80303d:	ba 00 00 00 00       	mov    $0x0,%edx
  803042:	f7 75 b0             	divl   -0x50(%ebp)
  803045:	8b 45 ac             	mov    -0x54(%ebp),%eax
  803048:	29 d0                	sub    %edx,%eax
  80304a:	83 ec 04             	sub    $0x4,%esp
  80304d:	6a 01                	push   $0x1
  80304f:	50                   	push   %eax
  803050:	ff 75 bc             	pushl  -0x44(%ebp)
  803053:	e8 51 f5 ff ff       	call   8025a9 <set_block_data>
  803058:	83 c4 10             	add    $0x10,%esp
			free_block(new_mem);
  80305b:	83 ec 0c             	sub    $0xc,%esp
  80305e:	ff 75 bc             	pushl  -0x44(%ebp)
  803061:	e8 36 04 00 00       	call   80349c <free_block>
  803066:	83 c4 10             	add    $0x10,%esp
			return alloc_block_BF(size);
  803069:	83 ec 0c             	sub    $0xc,%esp
  80306c:	ff 75 08             	pushl  0x8(%ebp)
  80306f:	e8 20 fa ff ff       	call   802a94 <alloc_block_BF>
  803074:	83 c4 10             	add    $0x10,%esp
			}
			return new_mem;
}
  803077:	c9                   	leave  
  803078:	c3                   	ret    

00803079 <merging>:

//===================================================
// [5] FREE BLOCK WITH COALESCING:
//===================================================
void merging(struct BlockElement *prev_block, struct BlockElement *next_block, void* va){
  803079:	55                   	push   %ebp
  80307a:	89 e5                	mov    %esp,%ebp
  80307c:	53                   	push   %ebx
  80307d:	83 ec 24             	sub    $0x24,%esp
	bool prev_is_free = 0, next_is_free = 0;
  803080:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  803087:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	if (prev_block != NULL && (char *)prev_block + get_block_size(prev_block) == (char *)va) {
  80308e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  803092:	74 1e                	je     8030b2 <merging+0x39>
  803094:	ff 75 08             	pushl  0x8(%ebp)
  803097:	e8 bc f1 ff ff       	call   802258 <get_block_size>
  80309c:	83 c4 04             	add    $0x4,%esp
  80309f:	89 c2                	mov    %eax,%edx
  8030a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8030a4:	01 d0                	add    %edx,%eax
  8030a6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8030a9:	75 07                	jne    8030b2 <merging+0x39>
		prev_is_free = 1;
  8030ab:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	}
	if (next_block != NULL && (char *)va + get_block_size(va) == (char *)next_block) {
  8030b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8030b6:	74 1e                	je     8030d6 <merging+0x5d>
  8030b8:	ff 75 10             	pushl  0x10(%ebp)
  8030bb:	e8 98 f1 ff ff       	call   802258 <get_block_size>
  8030c0:	83 c4 04             	add    $0x4,%esp
  8030c3:	89 c2                	mov    %eax,%edx
  8030c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8030c8:	01 d0                	add    %edx,%eax
  8030ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
  8030cd:	75 07                	jne    8030d6 <merging+0x5d>
		next_is_free = 1;
  8030cf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
	}
	if(prev_is_free && next_is_free)
  8030d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8030da:	0f 84 cc 00 00 00    	je     8031ac <merging+0x133>
  8030e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8030e4:	0f 84 c2 00 00 00    	je     8031ac <merging+0x133>
	{
		//merge - 2 sides
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va) + get_block_size(next_block);
  8030ea:	ff 75 08             	pushl  0x8(%ebp)
  8030ed:	e8 66 f1 ff ff       	call   802258 <get_block_size>
  8030f2:	83 c4 04             	add    $0x4,%esp
  8030f5:	89 c3                	mov    %eax,%ebx
  8030f7:	ff 75 10             	pushl  0x10(%ebp)
  8030fa:	e8 59 f1 ff ff       	call   802258 <get_block_size>
  8030ff:	83 c4 04             	add    $0x4,%esp
  803102:	01 c3                	add    %eax,%ebx
  803104:	ff 75 0c             	pushl  0xc(%ebp)
  803107:	e8 4c f1 ff ff       	call   802258 <get_block_size>
  80310c:	83 c4 04             	add    $0x4,%esp
  80310f:	01 d8                	add    %ebx,%eax
  803111:	89 45 ec             	mov    %eax,-0x14(%ebp)
		set_block_data(prev_block, new_block_size, 0);
  803114:	6a 00                	push   $0x0
  803116:	ff 75 ec             	pushl  -0x14(%ebp)
  803119:	ff 75 08             	pushl  0x8(%ebp)
  80311c:	e8 88 f4 ff ff       	call   8025a9 <set_block_data>
  803121:	83 c4 0c             	add    $0xc,%esp
		LIST_REMOVE(&freeBlocksList, next_block);
  803124:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803128:	75 17                	jne    803141 <merging+0xc8>
  80312a:	83 ec 04             	sub    $0x4,%esp
  80312d:	68 8b 49 80 00       	push   $0x80498b
  803132:	68 7d 01 00 00       	push   $0x17d
  803137:	68 a9 49 80 00       	push   $0x8049a9
  80313c:	e8 bf d5 ff ff       	call   800700 <_panic>
  803141:	8b 45 0c             	mov    0xc(%ebp),%eax
  803144:	8b 00                	mov    (%eax),%eax
  803146:	85 c0                	test   %eax,%eax
  803148:	74 10                	je     80315a <merging+0xe1>
  80314a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80314d:	8b 00                	mov    (%eax),%eax
  80314f:	8b 55 0c             	mov    0xc(%ebp),%edx
  803152:	8b 52 04             	mov    0x4(%edx),%edx
  803155:	89 50 04             	mov    %edx,0x4(%eax)
  803158:	eb 0b                	jmp    803165 <merging+0xec>
  80315a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80315d:	8b 40 04             	mov    0x4(%eax),%eax
  803160:	a3 48 50 80 00       	mov    %eax,0x805048
  803165:	8b 45 0c             	mov    0xc(%ebp),%eax
  803168:	8b 40 04             	mov    0x4(%eax),%eax
  80316b:	85 c0                	test   %eax,%eax
  80316d:	74 0f                	je     80317e <merging+0x105>
  80316f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803172:	8b 40 04             	mov    0x4(%eax),%eax
  803175:	8b 55 0c             	mov    0xc(%ebp),%edx
  803178:	8b 12                	mov    (%edx),%edx
  80317a:	89 10                	mov    %edx,(%eax)
  80317c:	eb 0a                	jmp    803188 <merging+0x10f>
  80317e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803181:	8b 00                	mov    (%eax),%eax
  803183:	a3 44 50 80 00       	mov    %eax,0x805044
  803188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80318b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803191:	8b 45 0c             	mov    0xc(%ebp),%eax
  803194:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80319b:	a1 50 50 80 00       	mov    0x805050,%eax
  8031a0:	48                   	dec    %eax
  8031a1:	a3 50 50 80 00       	mov    %eax,0x805050
	}
	if (next_block != NULL && (char *)va + get_block_size(va) == (char *)next_block) {
		next_is_free = 1;
	}
	if(prev_is_free && next_is_free)
	{
  8031a6:	90                   	nop
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  8031a7:	e9 ea 02 00 00       	jmp    803496 <merging+0x41d>
		//merge - 2 sides
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va) + get_block_size(next_block);
		set_block_data(prev_block, new_block_size, 0);
		LIST_REMOVE(&freeBlocksList, next_block);
	}
	else if(prev_is_free)
  8031ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8031b0:	74 3b                	je     8031ed <merging+0x174>
	{
		//merge - left side
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va);
  8031b2:	83 ec 0c             	sub    $0xc,%esp
  8031b5:	ff 75 08             	pushl  0x8(%ebp)
  8031b8:	e8 9b f0 ff ff       	call   802258 <get_block_size>
  8031bd:	83 c4 10             	add    $0x10,%esp
  8031c0:	89 c3                	mov    %eax,%ebx
  8031c2:	83 ec 0c             	sub    $0xc,%esp
  8031c5:	ff 75 10             	pushl  0x10(%ebp)
  8031c8:	e8 8b f0 ff ff       	call   802258 <get_block_size>
  8031cd:	83 c4 10             	add    $0x10,%esp
  8031d0:	01 d8                	add    %ebx,%eax
  8031d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
		set_block_data(prev_block, new_block_size, 0);
  8031d5:	83 ec 04             	sub    $0x4,%esp
  8031d8:	6a 00                	push   $0x0
  8031da:	ff 75 e8             	pushl  -0x18(%ebp)
  8031dd:	ff 75 08             	pushl  0x8(%ebp)
  8031e0:	e8 c4 f3 ff ff       	call   8025a9 <set_block_data>
  8031e5:	83 c4 10             	add    $0x10,%esp
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  8031e8:	e9 a9 02 00 00       	jmp    803496 <merging+0x41d>
	{
		//merge - left side
		uint32 new_block_size = get_block_size(prev_block) + get_block_size(va);
		set_block_data(prev_block, new_block_size, 0);
	}
	else if(next_is_free)
  8031ed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8031f1:	0f 84 2d 01 00 00    	je     803324 <merging+0x2ab>
	{
		//merge - right side

		uint32 new_block_size = get_block_size(va) + get_block_size(next_block);
  8031f7:	83 ec 0c             	sub    $0xc,%esp
  8031fa:	ff 75 10             	pushl  0x10(%ebp)
  8031fd:	e8 56 f0 ff ff       	call   802258 <get_block_size>
  803202:	83 c4 10             	add    $0x10,%esp
  803205:	89 c3                	mov    %eax,%ebx
  803207:	83 ec 0c             	sub    $0xc,%esp
  80320a:	ff 75 0c             	pushl  0xc(%ebp)
  80320d:	e8 46 f0 ff ff       	call   802258 <get_block_size>
  803212:	83 c4 10             	add    $0x10,%esp
  803215:	01 d8                	add    %ebx,%eax
  803217:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		set_block_data(va, new_block_size, 0);
  80321a:	83 ec 04             	sub    $0x4,%esp
  80321d:	6a 00                	push   $0x0
  80321f:	ff 75 e4             	pushl  -0x1c(%ebp)
  803222:	ff 75 10             	pushl  0x10(%ebp)
  803225:	e8 7f f3 ff ff       	call   8025a9 <set_block_data>
  80322a:	83 c4 10             	add    $0x10,%esp

		struct BlockElement *va_block = (struct BlockElement *)va;
  80322d:	8b 45 10             	mov    0x10(%ebp),%eax
  803230:	89 45 e0             	mov    %eax,-0x20(%ebp)
		LIST_INSERT_BEFORE(&freeBlocksList, next_block, va_block);
  803233:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803237:	74 06                	je     80323f <merging+0x1c6>
  803239:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80323d:	75 17                	jne    803256 <merging+0x1dd>
  80323f:	83 ec 04             	sub    $0x4,%esp
  803242:	68 64 4a 80 00       	push   $0x804a64
  803247:	68 8d 01 00 00       	push   $0x18d
  80324c:	68 a9 49 80 00       	push   $0x8049a9
  803251:	e8 aa d4 ff ff       	call   800700 <_panic>
  803256:	8b 45 0c             	mov    0xc(%ebp),%eax
  803259:	8b 50 04             	mov    0x4(%eax),%edx
  80325c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80325f:	89 50 04             	mov    %edx,0x4(%eax)
  803262:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803265:	8b 55 0c             	mov    0xc(%ebp),%edx
  803268:	89 10                	mov    %edx,(%eax)
  80326a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80326d:	8b 40 04             	mov    0x4(%eax),%eax
  803270:	85 c0                	test   %eax,%eax
  803272:	74 0d                	je     803281 <merging+0x208>
  803274:	8b 45 0c             	mov    0xc(%ebp),%eax
  803277:	8b 40 04             	mov    0x4(%eax),%eax
  80327a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80327d:	89 10                	mov    %edx,(%eax)
  80327f:	eb 08                	jmp    803289 <merging+0x210>
  803281:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803284:	a3 44 50 80 00       	mov    %eax,0x805044
  803289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80328c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80328f:	89 50 04             	mov    %edx,0x4(%eax)
  803292:	a1 50 50 80 00       	mov    0x805050,%eax
  803297:	40                   	inc    %eax
  803298:	a3 50 50 80 00       	mov    %eax,0x805050
		LIST_REMOVE(&freeBlocksList, next_block);
  80329d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8032a1:	75 17                	jne    8032ba <merging+0x241>
  8032a3:	83 ec 04             	sub    $0x4,%esp
  8032a6:	68 8b 49 80 00       	push   $0x80498b
  8032ab:	68 8e 01 00 00       	push   $0x18e
  8032b0:	68 a9 49 80 00       	push   $0x8049a9
  8032b5:	e8 46 d4 ff ff       	call   800700 <_panic>
  8032ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032bd:	8b 00                	mov    (%eax),%eax
  8032bf:	85 c0                	test   %eax,%eax
  8032c1:	74 10                	je     8032d3 <merging+0x25a>
  8032c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032c6:	8b 00                	mov    (%eax),%eax
  8032c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8032cb:	8b 52 04             	mov    0x4(%edx),%edx
  8032ce:	89 50 04             	mov    %edx,0x4(%eax)
  8032d1:	eb 0b                	jmp    8032de <merging+0x265>
  8032d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032d6:	8b 40 04             	mov    0x4(%eax),%eax
  8032d9:	a3 48 50 80 00       	mov    %eax,0x805048
  8032de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032e1:	8b 40 04             	mov    0x4(%eax),%eax
  8032e4:	85 c0                	test   %eax,%eax
  8032e6:	74 0f                	je     8032f7 <merging+0x27e>
  8032e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032eb:	8b 40 04             	mov    0x4(%eax),%eax
  8032ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8032f1:	8b 12                	mov    (%edx),%edx
  8032f3:	89 10                	mov    %edx,(%eax)
  8032f5:	eb 0a                	jmp    803301 <merging+0x288>
  8032f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032fa:	8b 00                	mov    (%eax),%eax
  8032fc:	a3 44 50 80 00       	mov    %eax,0x805044
  803301:	8b 45 0c             	mov    0xc(%ebp),%eax
  803304:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  80330a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80330d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803314:	a1 50 50 80 00       	mov    0x805050,%eax
  803319:	48                   	dec    %eax
  80331a:	a3 50 50 80 00       	mov    %eax,0x805050
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
		}
		set_block_data(va, get_block_size(va), 0);
	}
}
  80331f:	e9 72 01 00 00       	jmp    803496 <merging+0x41d>
		LIST_INSERT_BEFORE(&freeBlocksList, next_block, va_block);
		LIST_REMOVE(&freeBlocksList, next_block);
	}
	else
	{
		struct BlockElement *va_block = (struct BlockElement *)va;
  803324:	8b 45 10             	mov    0x10(%ebp),%eax
  803327:	89 45 dc             	mov    %eax,-0x24(%ebp)

		if(prev_block != NULL && next_block != NULL) LIST_INSERT_AFTER(&freeBlocksList, prev_block, va_block);
  80332a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80332e:	74 79                	je     8033a9 <merging+0x330>
  803330:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803334:	74 73                	je     8033a9 <merging+0x330>
  803336:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80333a:	74 06                	je     803342 <merging+0x2c9>
  80333c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  803340:	75 17                	jne    803359 <merging+0x2e0>
  803342:	83 ec 04             	sub    $0x4,%esp
  803345:	68 1c 4a 80 00       	push   $0x804a1c
  80334a:	68 94 01 00 00       	push   $0x194
  80334f:	68 a9 49 80 00       	push   $0x8049a9
  803354:	e8 a7 d3 ff ff       	call   800700 <_panic>
  803359:	8b 45 08             	mov    0x8(%ebp),%eax
  80335c:	8b 10                	mov    (%eax),%edx
  80335e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803361:	89 10                	mov    %edx,(%eax)
  803363:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803366:	8b 00                	mov    (%eax),%eax
  803368:	85 c0                	test   %eax,%eax
  80336a:	74 0b                	je     803377 <merging+0x2fe>
  80336c:	8b 45 08             	mov    0x8(%ebp),%eax
  80336f:	8b 00                	mov    (%eax),%eax
  803371:	8b 55 dc             	mov    -0x24(%ebp),%edx
  803374:	89 50 04             	mov    %edx,0x4(%eax)
  803377:	8b 45 08             	mov    0x8(%ebp),%eax
  80337a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80337d:	89 10                	mov    %edx,(%eax)
  80337f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803382:	8b 55 08             	mov    0x8(%ebp),%edx
  803385:	89 50 04             	mov    %edx,0x4(%eax)
  803388:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80338b:	8b 00                	mov    (%eax),%eax
  80338d:	85 c0                	test   %eax,%eax
  80338f:	75 08                	jne    803399 <merging+0x320>
  803391:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803394:	a3 48 50 80 00       	mov    %eax,0x805048
  803399:	a1 50 50 80 00       	mov    0x805050,%eax
  80339e:	40                   	inc    %eax
  80339f:	a3 50 50 80 00       	mov    %eax,0x805050
  8033a4:	e9 ce 00 00 00       	jmp    803477 <merging+0x3fe>
		else if(prev_block != NULL) LIST_INSERT_TAIL(&freeBlocksList, va_block);
  8033a9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8033ad:	74 65                	je     803414 <merging+0x39b>
  8033af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8033b3:	75 17                	jne    8033cc <merging+0x353>
  8033b5:	83 ec 04             	sub    $0x4,%esp
  8033b8:	68 f8 49 80 00       	push   $0x8049f8
  8033bd:	68 95 01 00 00       	push   $0x195
  8033c2:	68 a9 49 80 00       	push   $0x8049a9
  8033c7:	e8 34 d3 ff ff       	call   800700 <_panic>
  8033cc:	8b 15 48 50 80 00    	mov    0x805048,%edx
  8033d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8033d5:	89 50 04             	mov    %edx,0x4(%eax)
  8033d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8033db:	8b 40 04             	mov    0x4(%eax),%eax
  8033de:	85 c0                	test   %eax,%eax
  8033e0:	74 0c                	je     8033ee <merging+0x375>
  8033e2:	a1 48 50 80 00       	mov    0x805048,%eax
  8033e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8033ea:	89 10                	mov    %edx,(%eax)
  8033ec:	eb 08                	jmp    8033f6 <merging+0x37d>
  8033ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8033f1:	a3 44 50 80 00       	mov    %eax,0x805044
  8033f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8033f9:	a3 48 50 80 00       	mov    %eax,0x805048
  8033fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803401:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803407:	a1 50 50 80 00       	mov    0x805050,%eax
  80340c:	40                   	inc    %eax
  80340d:	a3 50 50 80 00       	mov    %eax,0x805050
  803412:	eb 63                	jmp    803477 <merging+0x3fe>
		else
		{
			LIST_INSERT_HEAD(&freeBlocksList, va_block);
  803414:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  803418:	75 17                	jne    803431 <merging+0x3b8>
  80341a:	83 ec 04             	sub    $0x4,%esp
  80341d:	68 c4 49 80 00       	push   $0x8049c4
  803422:	68 98 01 00 00       	push   $0x198
  803427:	68 a9 49 80 00       	push   $0x8049a9
  80342c:	e8 cf d2 ff ff       	call   800700 <_panic>
  803431:	8b 15 44 50 80 00    	mov    0x805044,%edx
  803437:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80343a:	89 10                	mov    %edx,(%eax)
  80343c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80343f:	8b 00                	mov    (%eax),%eax
  803441:	85 c0                	test   %eax,%eax
  803443:	74 0d                	je     803452 <merging+0x3d9>
  803445:	a1 44 50 80 00       	mov    0x805044,%eax
  80344a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80344d:	89 50 04             	mov    %edx,0x4(%eax)
  803450:	eb 08                	jmp    80345a <merging+0x3e1>
  803452:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803455:	a3 48 50 80 00       	mov    %eax,0x805048
  80345a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80345d:	a3 44 50 80 00       	mov    %eax,0x805044
  803462:	8b 45 dc             	mov    -0x24(%ebp),%eax
  803465:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80346c:	a1 50 50 80 00       	mov    0x805050,%eax
  803471:	40                   	inc    %eax
  803472:	a3 50 50 80 00       	mov    %eax,0x805050
		}
		set_block_data(va, get_block_size(va), 0);
  803477:	83 ec 0c             	sub    $0xc,%esp
  80347a:	ff 75 10             	pushl  0x10(%ebp)
  80347d:	e8 d6 ed ff ff       	call   802258 <get_block_size>
  803482:	83 c4 10             	add    $0x10,%esp
  803485:	83 ec 04             	sub    $0x4,%esp
  803488:	6a 00                	push   $0x0
  80348a:	50                   	push   %eax
  80348b:	ff 75 10             	pushl  0x10(%ebp)
  80348e:	e8 16 f1 ff ff       	call   8025a9 <set_block_data>
  803493:	83 c4 10             	add    $0x10,%esp
	}
}
  803496:	90                   	nop
  803497:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80349a:	c9                   	leave  
  80349b:	c3                   	ret    

0080349c <free_block>:
//===================================================
// [5] FREE BLOCK WITH COALESCING:
//===================================================
void free_block(void *va)
{
  80349c:	55                   	push   %ebp
  80349d:	89 e5                	mov    %esp,%ebp
  80349f:	83 ec 18             	sub    $0x18,%esp
	//TODO: [PROJECT'24.MS1 - #07] [3] DYNAMIC ALLOCATOR - free_block
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("free_block is not implemented yet");
	//Your Code is Here...
	struct BlockElement *prev_block = LIST_FIRST(&freeBlocksList);
  8034a2:	a1 44 50 80 00       	mov    0x805044,%eax
  8034a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if((char *)LIST_LAST(&freeBlocksList) < (char *)va){
  8034aa:	a1 48 50 80 00       	mov    0x805048,%eax
  8034af:	3b 45 08             	cmp    0x8(%ebp),%eax
  8034b2:	73 1b                	jae    8034cf <free_block+0x33>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
  8034b4:	a1 48 50 80 00       	mov    0x805048,%eax
  8034b9:	83 ec 04             	sub    $0x4,%esp
  8034bc:	ff 75 08             	pushl  0x8(%ebp)
  8034bf:	6a 00                	push   $0x0
  8034c1:	50                   	push   %eax
  8034c2:	e8 b2 fb ff ff       	call   803079 <merging>
  8034c7:	83 c4 10             	add    $0x10,%esp
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  8034ca:	e9 8b 00 00 00       	jmp    80355a <free_block+0xbe>
	struct BlockElement *prev_block = LIST_FIRST(&freeBlocksList);

	if((char *)LIST_LAST(&freeBlocksList) < (char *)va){
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
  8034cf:	a1 44 50 80 00       	mov    0x805044,%eax
  8034d4:	3b 45 08             	cmp    0x8(%ebp),%eax
  8034d7:	76 18                	jbe    8034f1 <free_block+0x55>
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
  8034d9:	a1 44 50 80 00       	mov    0x805044,%eax
  8034de:	83 ec 04             	sub    $0x4,%esp
  8034e1:	ff 75 08             	pushl  0x8(%ebp)
  8034e4:	50                   	push   %eax
  8034e5:	6a 00                	push   $0x0
  8034e7:	e8 8d fb ff ff       	call   803079 <merging>
  8034ec:	83 c4 10             	add    $0x10,%esp
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  8034ef:	eb 69                	jmp    80355a <free_block+0xbe>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
	}
	else LIST_FOREACH (prev_block, &freeBlocksList){
  8034f1:	a1 44 50 80 00       	mov    0x805044,%eax
  8034f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8034f9:	eb 39                	jmp    803534 <free_block+0x98>
		if((uint32 *)prev_block < (uint32 *)va && (uint32 *)prev_block->prev_next_info.le_next > (uint32 *)va ){
  8034fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034fe:	3b 45 08             	cmp    0x8(%ebp),%eax
  803501:	73 29                	jae    80352c <free_block+0x90>
  803503:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803506:	8b 00                	mov    (%eax),%eax
  803508:	3b 45 08             	cmp    0x8(%ebp),%eax
  80350b:	76 1f                	jbe    80352c <free_block+0x90>
			//get the address of prev and next
			struct BlockElement *next_block = LIST_NEXT(prev_block);
  80350d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803510:	8b 00                	mov    (%eax),%eax
  803512:	89 45 f0             	mov    %eax,-0x10(%ebp)
			merging(prev_block, next_block, va);
  803515:	83 ec 04             	sub    $0x4,%esp
  803518:	ff 75 08             	pushl  0x8(%ebp)
  80351b:	ff 75 f0             	pushl  -0x10(%ebp)
  80351e:	ff 75 f4             	pushl  -0xc(%ebp)
  803521:	e8 53 fb ff ff       	call   803079 <merging>
  803526:	83 c4 10             	add    $0x10,%esp
			break;
  803529:	90                   	nop
		}
	}
}
  80352a:	eb 2e                	jmp    80355a <free_block+0xbe>
		merging(LIST_LAST(&freeBlocksList), NULL, va);
	}
	else if((char *)LIST_FIRST(&freeBlocksList) > (char *)va) {
		merging(NULL, LIST_FIRST(&freeBlocksList),va);
	}
	else LIST_FOREACH (prev_block, &freeBlocksList){
  80352c:	a1 4c 50 80 00       	mov    0x80504c,%eax
  803531:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803534:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803538:	74 07                	je     803541 <free_block+0xa5>
  80353a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80353d:	8b 00                	mov    (%eax),%eax
  80353f:	eb 05                	jmp    803546 <free_block+0xaa>
  803541:	b8 00 00 00 00       	mov    $0x0,%eax
  803546:	a3 4c 50 80 00       	mov    %eax,0x80504c
  80354b:	a1 4c 50 80 00       	mov    0x80504c,%eax
  803550:	85 c0                	test   %eax,%eax
  803552:	75 a7                	jne    8034fb <free_block+0x5f>
  803554:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803558:	75 a1                	jne    8034fb <free_block+0x5f>
			struct BlockElement *next_block = LIST_NEXT(prev_block);
			merging(prev_block, next_block, va);
			break;
		}
	}
}
  80355a:	90                   	nop
  80355b:	c9                   	leave  
  80355c:	c3                   	ret    

0080355d <copy_data>:

//=========================================
// [6] REALLOCATE BLOCK BY FIRST FIT:
//=========================================
void copy_data(void *va, void *new_va)
{
  80355d:	55                   	push   %ebp
  80355e:	89 e5                	mov    %esp,%ebp
  803560:	83 ec 10             	sub    $0x10,%esp
	uint32 va_size = get_block_size(va);
  803563:	ff 75 08             	pushl  0x8(%ebp)
  803566:	e8 ed ec ff ff       	call   802258 <get_block_size>
  80356b:	83 c4 04             	add    $0x4,%esp
  80356e:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for(int i = 0; i < va_size; i++) *((char *)new_va + i) = *((char *)va + i);
  803571:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  803578:	eb 17                	jmp    803591 <copy_data+0x34>
  80357a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  80357d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803580:	01 c2                	add    %eax,%edx
  803582:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  803585:	8b 45 08             	mov    0x8(%ebp),%eax
  803588:	01 c8                	add    %ecx,%eax
  80358a:	8a 00                	mov    (%eax),%al
  80358c:	88 02                	mov    %al,(%edx)
  80358e:	ff 45 fc             	incl   -0x4(%ebp)
  803591:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803594:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  803597:	72 e1                	jb     80357a <copy_data+0x1d>
}
  803599:	90                   	nop
  80359a:	c9                   	leave  
  80359b:	c3                   	ret    

0080359c <realloc_block_FF>:

void *realloc_block_FF(void* va, uint32 new_size)
{
  80359c:	55                   	push   %ebp
  80359d:	89 e5                	mov    %esp,%ebp
  80359f:	83 ec 58             	sub    $0x58,%esp
	//COMMENT THE FOLLOWING LINE BEFORE START CODING
	//panic("realloc_block_FF is not implemented yet");
	//Your Code is Here...


	if(va == NULL)
  8035a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8035a6:	75 23                	jne    8035cb <realloc_block_FF+0x2f>
	{
		if(new_size != 0) return alloc_block_FF(new_size);
  8035a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8035ac:	74 13                	je     8035c1 <realloc_block_FF+0x25>
  8035ae:	83 ec 0c             	sub    $0xc,%esp
  8035b1:	ff 75 0c             	pushl  0xc(%ebp)
  8035b4:	e8 1f f0 ff ff       	call   8025d8 <alloc_block_FF>
  8035b9:	83 c4 10             	add    $0x10,%esp
  8035bc:	e9 f4 06 00 00       	jmp    803cb5 <realloc_block_FF+0x719>
		return NULL;
  8035c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8035c6:	e9 ea 06 00 00       	jmp    803cb5 <realloc_block_FF+0x719>
	}

	if(new_size == 0)
  8035cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8035cf:	75 18                	jne    8035e9 <realloc_block_FF+0x4d>
	{
		free_block(va);
  8035d1:	83 ec 0c             	sub    $0xc,%esp
  8035d4:	ff 75 08             	pushl  0x8(%ebp)
  8035d7:	e8 c0 fe ff ff       	call   80349c <free_block>
  8035dc:	83 c4 10             	add    $0x10,%esp
		return NULL;
  8035df:	b8 00 00 00 00       	mov    $0x0,%eax
  8035e4:	e9 cc 06 00 00       	jmp    803cb5 <realloc_block_FF+0x719>
	}


	if(new_size < 8) new_size = 8;
  8035e9:	83 7d 0c 07          	cmpl   $0x7,0xc(%ebp)
  8035ed:	77 07                	ja     8035f6 <realloc_block_FF+0x5a>
  8035ef:	c7 45 0c 08 00 00 00 	movl   $0x8,0xc(%ebp)
	new_size += (new_size % 2);
  8035f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035f9:	83 e0 01             	and    $0x1,%eax
  8035fc:	01 45 0c             	add    %eax,0xc(%ebp)

	//cur Block data
	uint32 newBLOCK_size = new_size + 8;
  8035ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  803602:	83 c0 08             	add    $0x8,%eax
  803605:	89 45 f0             	mov    %eax,-0x10(%ebp)
	uint32 curBLOCK_size = get_block_size(va) /*BLOCK size in Bytes*/;
  803608:	83 ec 0c             	sub    $0xc,%esp
  80360b:	ff 75 08             	pushl  0x8(%ebp)
  80360e:	e8 45 ec ff ff       	call   802258 <get_block_size>
  803613:	83 c4 10             	add    $0x10,%esp
  803616:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uint32 cur_size = curBLOCK_size - 8 /*8 Bytes = (Header + Footer) size*/;
  803619:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80361c:	83 e8 08             	sub    $0x8,%eax
  80361f:	89 45 e8             	mov    %eax,-0x18(%ebp)

	//next Block data
	void *next_va = (void *)(FOOTER(va) + 2);
  803622:	8b 45 08             	mov    0x8(%ebp),%eax
  803625:	83 e8 04             	sub    $0x4,%eax
  803628:	8b 00                	mov    (%eax),%eax
  80362a:	83 e0 fe             	and    $0xfffffffe,%eax
  80362d:	89 c2                	mov    %eax,%edx
  80362f:	8b 45 08             	mov    0x8(%ebp),%eax
  803632:	01 d0                	add    %edx,%eax
  803634:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32 nextBLOCK_size = get_block_size(next_va)/*&is_free_block(next_block_va)*/; //=0 if not free
  803637:	83 ec 0c             	sub    $0xc,%esp
  80363a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80363d:	e8 16 ec ff ff       	call   802258 <get_block_size>
  803642:	83 c4 10             	add    $0x10,%esp
  803645:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uint32 next_cur_size = nextBLOCK_size - 8 /*8 Bytes = (Header + Footer) size*/;
  803648:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80364b:	83 e8 08             	sub    $0x8,%eax
  80364e:	89 45 dc             	mov    %eax,-0x24(%ebp)


	//if the user needs the same size he owns
	if(new_size == cur_size)
  803651:	8b 45 0c             	mov    0xc(%ebp),%eax
  803654:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  803657:	75 08                	jne    803661 <realloc_block_FF+0xc5>
	{
		 return va;
  803659:	8b 45 08             	mov    0x8(%ebp),%eax
  80365c:	e9 54 06 00 00       	jmp    803cb5 <realloc_block_FF+0x719>

	}


	if(new_size < cur_size)
  803661:	8b 45 0c             	mov    0xc(%ebp),%eax
  803664:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  803667:	0f 83 e5 03 00 00    	jae    803a52 <realloc_block_FF+0x4b6>
	{
		uint32 remaining_size = cur_size - new_size; //remaining size in single Bytes
  80366d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  803670:	2b 45 0c             	sub    0xc(%ebp),%eax
  803673:	89 45 d8             	mov    %eax,-0x28(%ebp)
		if(is_free_block(next_va))
  803676:	83 ec 0c             	sub    $0xc,%esp
  803679:	ff 75 e4             	pushl  -0x1c(%ebp)
  80367c:	e8 f0 eb ff ff       	call   802271 <is_free_block>
  803681:	83 c4 10             	add    $0x10,%esp
  803684:	84 c0                	test   %al,%al
  803686:	0f 84 3b 01 00 00    	je     8037c7 <realloc_block_FF+0x22b>
		{

			uint32 next_newBLOCK_size = nextBLOCK_size + remaining_size;
  80368c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80368f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  803692:	01 d0                	add    %edx,%eax
  803694:	89 45 cc             	mov    %eax,-0x34(%ebp)
			set_block_data(va, newBLOCK_size, 1);
  803697:	83 ec 04             	sub    $0x4,%esp
  80369a:	6a 01                	push   $0x1
  80369c:	ff 75 f0             	pushl  -0x10(%ebp)
  80369f:	ff 75 08             	pushl  0x8(%ebp)
  8036a2:	e8 02 ef ff ff       	call   8025a9 <set_block_data>
  8036a7:	83 c4 10             	add    $0x10,%esp
			void *next_new_va = (void *)(FOOTER(va) + 2);
  8036aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8036ad:	83 e8 04             	sub    $0x4,%eax
  8036b0:	8b 00                	mov    (%eax),%eax
  8036b2:	83 e0 fe             	and    $0xfffffffe,%eax
  8036b5:	89 c2                	mov    %eax,%edx
  8036b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8036ba:	01 d0                	add    %edx,%eax
  8036bc:	89 45 c8             	mov    %eax,-0x38(%ebp)
			set_block_data(next_new_va, next_newBLOCK_size, 0);
  8036bf:	83 ec 04             	sub    $0x4,%esp
  8036c2:	6a 00                	push   $0x0
  8036c4:	ff 75 cc             	pushl  -0x34(%ebp)
  8036c7:	ff 75 c8             	pushl  -0x38(%ebp)
  8036ca:	e8 da ee ff ff       	call   8025a9 <set_block_data>
  8036cf:	83 c4 10             	add    $0x10,%esp
			LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement*)next_va, (struct BlockElement*)next_new_va);
  8036d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8036d6:	74 06                	je     8036de <realloc_block_FF+0x142>
  8036d8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8036dc:	75 17                	jne    8036f5 <realloc_block_FF+0x159>
  8036de:	83 ec 04             	sub    $0x4,%esp
  8036e1:	68 1c 4a 80 00       	push   $0x804a1c
  8036e6:	68 f6 01 00 00       	push   $0x1f6
  8036eb:	68 a9 49 80 00       	push   $0x8049a9
  8036f0:	e8 0b d0 ff ff       	call   800700 <_panic>
  8036f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8036f8:	8b 10                	mov    (%eax),%edx
  8036fa:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8036fd:	89 10                	mov    %edx,(%eax)
  8036ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
  803702:	8b 00                	mov    (%eax),%eax
  803704:	85 c0                	test   %eax,%eax
  803706:	74 0b                	je     803713 <realloc_block_FF+0x177>
  803708:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80370b:	8b 00                	mov    (%eax),%eax
  80370d:	8b 55 c8             	mov    -0x38(%ebp),%edx
  803710:	89 50 04             	mov    %edx,0x4(%eax)
  803713:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803716:	8b 55 c8             	mov    -0x38(%ebp),%edx
  803719:	89 10                	mov    %edx,(%eax)
  80371b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80371e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803721:	89 50 04             	mov    %edx,0x4(%eax)
  803724:	8b 45 c8             	mov    -0x38(%ebp),%eax
  803727:	8b 00                	mov    (%eax),%eax
  803729:	85 c0                	test   %eax,%eax
  80372b:	75 08                	jne    803735 <realloc_block_FF+0x199>
  80372d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  803730:	a3 48 50 80 00       	mov    %eax,0x805048
  803735:	a1 50 50 80 00       	mov    0x805050,%eax
  80373a:	40                   	inc    %eax
  80373b:	a3 50 50 80 00       	mov    %eax,0x805050
			LIST_REMOVE(&freeBlocksList, (struct BlockElement*)next_va);
  803740:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  803744:	75 17                	jne    80375d <realloc_block_FF+0x1c1>
  803746:	83 ec 04             	sub    $0x4,%esp
  803749:	68 8b 49 80 00       	push   $0x80498b
  80374e:	68 f7 01 00 00       	push   $0x1f7
  803753:	68 a9 49 80 00       	push   $0x8049a9
  803758:	e8 a3 cf ff ff       	call   800700 <_panic>
  80375d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803760:	8b 00                	mov    (%eax),%eax
  803762:	85 c0                	test   %eax,%eax
  803764:	74 10                	je     803776 <realloc_block_FF+0x1da>
  803766:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803769:	8b 00                	mov    (%eax),%eax
  80376b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80376e:	8b 52 04             	mov    0x4(%edx),%edx
  803771:	89 50 04             	mov    %edx,0x4(%eax)
  803774:	eb 0b                	jmp    803781 <realloc_block_FF+0x1e5>
  803776:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803779:	8b 40 04             	mov    0x4(%eax),%eax
  80377c:	a3 48 50 80 00       	mov    %eax,0x805048
  803781:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803784:	8b 40 04             	mov    0x4(%eax),%eax
  803787:	85 c0                	test   %eax,%eax
  803789:	74 0f                	je     80379a <realloc_block_FF+0x1fe>
  80378b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80378e:	8b 40 04             	mov    0x4(%eax),%eax
  803791:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803794:	8b 12                	mov    (%edx),%edx
  803796:	89 10                	mov    %edx,(%eax)
  803798:	eb 0a                	jmp    8037a4 <realloc_block_FF+0x208>
  80379a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80379d:	8b 00                	mov    (%eax),%eax
  80379f:	a3 44 50 80 00       	mov    %eax,0x805044
  8037a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  8037ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8037b0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8037b7:	a1 50 50 80 00       	mov    0x805050,%eax
  8037bc:	48                   	dec    %eax
  8037bd:	a3 50 50 80 00       	mov    %eax,0x805050
  8037c2:	e9 83 02 00 00       	jmp    803a4a <realloc_block_FF+0x4ae>
		}
		else
		{
			if(remaining_size>=16)
  8037c7:	83 7d d8 0f          	cmpl   $0xf,-0x28(%ebp)
  8037cb:	0f 86 69 02 00 00    	jbe    803a3a <realloc_block_FF+0x49e>
			{
				//uint32 next_new_size = remaining_size - 8;/*+ next_cur_size&is_free_block(next_cur_va)*/
				set_block_data(va, newBLOCK_size, 1);
  8037d1:	83 ec 04             	sub    $0x4,%esp
  8037d4:	6a 01                	push   $0x1
  8037d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8037d9:	ff 75 08             	pushl  0x8(%ebp)
  8037dc:	e8 c8 ed ff ff       	call   8025a9 <set_block_data>
  8037e1:	83 c4 10             	add    $0x10,%esp
				void *next_new_va = (void *)(FOOTER(va) + 2);
  8037e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8037e7:	83 e8 04             	sub    $0x4,%eax
  8037ea:	8b 00                	mov    (%eax),%eax
  8037ec:	83 e0 fe             	and    $0xfffffffe,%eax
  8037ef:	89 c2                	mov    %eax,%edx
  8037f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8037f4:	01 d0                	add    %edx,%eax
  8037f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

				//insert new block to free_block_list
				uint32 list_size = LIST_SIZE(&freeBlocksList);
  8037f9:	a1 50 50 80 00       	mov    0x805050,%eax
  8037fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
				if(list_size == 0)
  803801:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  803805:	75 68                	jne    80386f <realloc_block_FF+0x2d3>
				{

					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement *)next_new_va);
  803807:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80380b:	75 17                	jne    803824 <realloc_block_FF+0x288>
  80380d:	83 ec 04             	sub    $0x4,%esp
  803810:	68 c4 49 80 00       	push   $0x8049c4
  803815:	68 06 02 00 00       	push   $0x206
  80381a:	68 a9 49 80 00       	push   $0x8049a9
  80381f:	e8 dc ce ff ff       	call   800700 <_panic>
  803824:	8b 15 44 50 80 00    	mov    0x805044,%edx
  80382a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80382d:	89 10                	mov    %edx,(%eax)
  80382f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803832:	8b 00                	mov    (%eax),%eax
  803834:	85 c0                	test   %eax,%eax
  803836:	74 0d                	je     803845 <realloc_block_FF+0x2a9>
  803838:	a1 44 50 80 00       	mov    0x805044,%eax
  80383d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  803840:	89 50 04             	mov    %edx,0x4(%eax)
  803843:	eb 08                	jmp    80384d <realloc_block_FF+0x2b1>
  803845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803848:	a3 48 50 80 00       	mov    %eax,0x805048
  80384d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803850:	a3 44 50 80 00       	mov    %eax,0x805044
  803855:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803858:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  80385f:	a1 50 50 80 00       	mov    0x805050,%eax
  803864:	40                   	inc    %eax
  803865:	a3 50 50 80 00       	mov    %eax,0x805050
  80386a:	e9 b0 01 00 00       	jmp    803a1f <realloc_block_FF+0x483>
				}
				else if((struct BlockElement *)next_new_va < LIST_FIRST(&freeBlocksList))
  80386f:	a1 44 50 80 00       	mov    0x805044,%eax
  803874:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  803877:	76 68                	jbe    8038e1 <realloc_block_FF+0x345>
				{

					LIST_INSERT_HEAD(&freeBlocksList, (struct BlockElement *)next_new_va);
  803879:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80387d:	75 17                	jne    803896 <realloc_block_FF+0x2fa>
  80387f:	83 ec 04             	sub    $0x4,%esp
  803882:	68 c4 49 80 00       	push   $0x8049c4
  803887:	68 0b 02 00 00       	push   $0x20b
  80388c:	68 a9 49 80 00       	push   $0x8049a9
  803891:	e8 6a ce ff ff       	call   800700 <_panic>
  803896:	8b 15 44 50 80 00    	mov    0x805044,%edx
  80389c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80389f:	89 10                	mov    %edx,(%eax)
  8038a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8038a4:	8b 00                	mov    (%eax),%eax
  8038a6:	85 c0                	test   %eax,%eax
  8038a8:	74 0d                	je     8038b7 <realloc_block_FF+0x31b>
  8038aa:	a1 44 50 80 00       	mov    0x805044,%eax
  8038af:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8038b2:	89 50 04             	mov    %edx,0x4(%eax)
  8038b5:	eb 08                	jmp    8038bf <realloc_block_FF+0x323>
  8038b7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8038ba:	a3 48 50 80 00       	mov    %eax,0x805048
  8038bf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8038c2:	a3 44 50 80 00       	mov    %eax,0x805044
  8038c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8038ca:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  8038d1:	a1 50 50 80 00       	mov    0x805050,%eax
  8038d6:	40                   	inc    %eax
  8038d7:	a3 50 50 80 00       	mov    %eax,0x805050
  8038dc:	e9 3e 01 00 00       	jmp    803a1f <realloc_block_FF+0x483>
				}
				else if(LIST_FIRST(&freeBlocksList) < (struct BlockElement *)next_new_va)
  8038e1:	a1 44 50 80 00       	mov    0x805044,%eax
  8038e6:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  8038e9:	73 68                	jae    803953 <realloc_block_FF+0x3b7>
				{

					LIST_INSERT_TAIL(&freeBlocksList, (struct BlockElement *)next_new_va);
  8038eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8038ef:	75 17                	jne    803908 <realloc_block_FF+0x36c>
  8038f1:	83 ec 04             	sub    $0x4,%esp
  8038f4:	68 f8 49 80 00       	push   $0x8049f8
  8038f9:	68 10 02 00 00       	push   $0x210
  8038fe:	68 a9 49 80 00       	push   $0x8049a9
  803903:	e8 f8 cd ff ff       	call   800700 <_panic>
  803908:	8b 15 48 50 80 00    	mov    0x805048,%edx
  80390e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803911:	89 50 04             	mov    %edx,0x4(%eax)
  803914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803917:	8b 40 04             	mov    0x4(%eax),%eax
  80391a:	85 c0                	test   %eax,%eax
  80391c:	74 0c                	je     80392a <realloc_block_FF+0x38e>
  80391e:	a1 48 50 80 00       	mov    0x805048,%eax
  803923:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  803926:	89 10                	mov    %edx,(%eax)
  803928:	eb 08                	jmp    803932 <realloc_block_FF+0x396>
  80392a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80392d:	a3 44 50 80 00       	mov    %eax,0x805044
  803932:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803935:	a3 48 50 80 00       	mov    %eax,0x805048
  80393a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80393d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803943:	a1 50 50 80 00       	mov    0x805050,%eax
  803948:	40                   	inc    %eax
  803949:	a3 50 50 80 00       	mov    %eax,0x805050
  80394e:	e9 cc 00 00 00       	jmp    803a1f <realloc_block_FF+0x483>
				}
				else
				{

					struct BlockElement *blk = NULL;
  803953:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
					LIST_FOREACH(blk, &freeBlocksList)
  80395a:	a1 44 50 80 00       	mov    0x805044,%eax
  80395f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  803962:	e9 8a 00 00 00       	jmp    8039f1 <realloc_block_FF+0x455>
					{
						if(blk < (struct BlockElement *)next_new_va && LIST_NEXT(blk) < (struct BlockElement *)next_new_va)
  803967:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80396a:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  80396d:	73 7a                	jae    8039e9 <realloc_block_FF+0x44d>
  80396f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803972:	8b 00                	mov    (%eax),%eax
  803974:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
  803977:	73 70                	jae    8039e9 <realloc_block_FF+0x44d>
						{
							LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement *)next_new_va);
  803979:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  80397d:	74 06                	je     803985 <realloc_block_FF+0x3e9>
  80397f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  803983:	75 17                	jne    80399c <realloc_block_FF+0x400>
  803985:	83 ec 04             	sub    $0x4,%esp
  803988:	68 1c 4a 80 00       	push   $0x804a1c
  80398d:	68 1a 02 00 00       	push   $0x21a
  803992:	68 a9 49 80 00       	push   $0x8049a9
  803997:	e8 64 cd ff ff       	call   800700 <_panic>
  80399c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80399f:	8b 10                	mov    (%eax),%edx
  8039a1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8039a4:	89 10                	mov    %edx,(%eax)
  8039a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8039a9:	8b 00                	mov    (%eax),%eax
  8039ab:	85 c0                	test   %eax,%eax
  8039ad:	74 0b                	je     8039ba <realloc_block_FF+0x41e>
  8039af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039b2:	8b 00                	mov    (%eax),%eax
  8039b4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8039b7:	89 50 04             	mov    %edx,0x4(%eax)
  8039ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039bd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8039c0:	89 10                	mov    %edx,(%eax)
  8039c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8039c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8039c8:	89 50 04             	mov    %edx,0x4(%eax)
  8039cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8039ce:	8b 00                	mov    (%eax),%eax
  8039d0:	85 c0                	test   %eax,%eax
  8039d2:	75 08                	jne    8039dc <realloc_block_FF+0x440>
  8039d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8039d7:	a3 48 50 80 00       	mov    %eax,0x805048
  8039dc:	a1 50 50 80 00       	mov    0x805050,%eax
  8039e1:	40                   	inc    %eax
  8039e2:	a3 50 50 80 00       	mov    %eax,0x805050
							break;
  8039e7:	eb 36                	jmp    803a1f <realloc_block_FF+0x483>
				}
				else
				{

					struct BlockElement *blk = NULL;
					LIST_FOREACH(blk, &freeBlocksList)
  8039e9:	a1 4c 50 80 00       	mov    0x80504c,%eax
  8039ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8039f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8039f5:	74 07                	je     8039fe <realloc_block_FF+0x462>
  8039f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039fa:	8b 00                	mov    (%eax),%eax
  8039fc:	eb 05                	jmp    803a03 <realloc_block_FF+0x467>
  8039fe:	b8 00 00 00 00       	mov    $0x0,%eax
  803a03:	a3 4c 50 80 00       	mov    %eax,0x80504c
  803a08:	a1 4c 50 80 00       	mov    0x80504c,%eax
  803a0d:	85 c0                	test   %eax,%eax
  803a0f:	0f 85 52 ff ff ff    	jne    803967 <realloc_block_FF+0x3cb>
  803a15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  803a19:	0f 85 48 ff ff ff    	jne    803967 <realloc_block_FF+0x3cb>
							LIST_INSERT_AFTER(&freeBlocksList, blk, (struct BlockElement *)next_new_va);
							break;
						}
					}
				}
				set_block_data(next_new_va, remaining_size, 0);
  803a1f:	83 ec 04             	sub    $0x4,%esp
  803a22:	6a 00                	push   $0x0
  803a24:	ff 75 d8             	pushl  -0x28(%ebp)
  803a27:	ff 75 d4             	pushl  -0x2c(%ebp)
  803a2a:	e8 7a eb ff ff       	call   8025a9 <set_block_data>
  803a2f:	83 c4 10             	add    $0x10,%esp
				return va;
  803a32:	8b 45 08             	mov    0x8(%ebp),%eax
  803a35:	e9 7b 02 00 00       	jmp    803cb5 <realloc_block_FF+0x719>
			}
			cprintf("16\n");
  803a3a:	83 ec 0c             	sub    $0xc,%esp
  803a3d:	68 99 4a 80 00       	push   $0x804a99
  803a42:	e8 76 cf ff ff       	call   8009bd <cprintf>
  803a47:	83 c4 10             	add    $0x10,%esp
		}
		return va;
  803a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  803a4d:	e9 63 02 00 00       	jmp    803cb5 <realloc_block_FF+0x719>
	}

	if(new_size > cur_size)
  803a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a55:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  803a58:	0f 86 4d 02 00 00    	jbe    803cab <realloc_block_FF+0x70f>
	{
		if(is_free_block(next_va))
  803a5e:	83 ec 0c             	sub    $0xc,%esp
  803a61:	ff 75 e4             	pushl  -0x1c(%ebp)
  803a64:	e8 08 e8 ff ff       	call   802271 <is_free_block>
  803a69:	83 c4 10             	add    $0x10,%esp
  803a6c:	84 c0                	test   %al,%al
  803a6e:	0f 84 37 02 00 00    	je     803cab <realloc_block_FF+0x70f>
		{

			uint32 needed_size = new_size - cur_size; //needed size in single Bytes
  803a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a77:	2b 45 e8             	sub    -0x18(%ebp),%eax
  803a7a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			if(needed_size > nextBLOCK_size)
  803a7d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  803a80:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  803a83:	76 38                	jbe    803abd <realloc_block_FF+0x521>
			{
				free_block(va); //set it free
  803a85:	83 ec 0c             	sub    $0xc,%esp
  803a88:	ff 75 08             	pushl  0x8(%ebp)
  803a8b:	e8 0c fa ff ff       	call   80349c <free_block>
  803a90:	83 c4 10             	add    $0x10,%esp
				void *new_va = alloc_block_FF(new_size); //new allocation
  803a93:	83 ec 0c             	sub    $0xc,%esp
  803a96:	ff 75 0c             	pushl  0xc(%ebp)
  803a99:	e8 3a eb ff ff       	call   8025d8 <alloc_block_FF>
  803a9e:	83 c4 10             	add    $0x10,%esp
  803aa1:	89 45 c0             	mov    %eax,-0x40(%ebp)
				copy_data(va, new_va); //transfer data
  803aa4:	83 ec 08             	sub    $0x8,%esp
  803aa7:	ff 75 c0             	pushl  -0x40(%ebp)
  803aaa:	ff 75 08             	pushl  0x8(%ebp)
  803aad:	e8 ab fa ff ff       	call   80355d <copy_data>
  803ab2:	83 c4 10             	add    $0x10,%esp
				return new_va;
  803ab5:	8b 45 c0             	mov    -0x40(%ebp),%eax
  803ab8:	e9 f8 01 00 00       	jmp    803cb5 <realloc_block_FF+0x719>
			}
			uint32 remaining_size = nextBLOCK_size - needed_size;
  803abd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803ac0:	2b 45 c4             	sub    -0x3c(%ebp),%eax
  803ac3:	89 45 bc             	mov    %eax,-0x44(%ebp)
			if(remaining_size < 16) //merge next block to my cur block
  803ac6:	83 7d bc 0f          	cmpl   $0xf,-0x44(%ebp)
  803aca:	0f 87 a0 00 00 00    	ja     803b70 <realloc_block_FF+0x5d4>
			{
				//remove from free_block_list, then
				LIST_REMOVE(&freeBlocksList, (struct BlockElement *)next_va);
  803ad0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  803ad4:	75 17                	jne    803aed <realloc_block_FF+0x551>
  803ad6:	83 ec 04             	sub    $0x4,%esp
  803ad9:	68 8b 49 80 00       	push   $0x80498b
  803ade:	68 38 02 00 00       	push   $0x238
  803ae3:	68 a9 49 80 00       	push   $0x8049a9
  803ae8:	e8 13 cc ff ff       	call   800700 <_panic>
  803aed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803af0:	8b 00                	mov    (%eax),%eax
  803af2:	85 c0                	test   %eax,%eax
  803af4:	74 10                	je     803b06 <realloc_block_FF+0x56a>
  803af6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803af9:	8b 00                	mov    (%eax),%eax
  803afb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803afe:	8b 52 04             	mov    0x4(%edx),%edx
  803b01:	89 50 04             	mov    %edx,0x4(%eax)
  803b04:	eb 0b                	jmp    803b11 <realloc_block_FF+0x575>
  803b06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b09:	8b 40 04             	mov    0x4(%eax),%eax
  803b0c:	a3 48 50 80 00       	mov    %eax,0x805048
  803b11:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b14:	8b 40 04             	mov    0x4(%eax),%eax
  803b17:	85 c0                	test   %eax,%eax
  803b19:	74 0f                	je     803b2a <realloc_block_FF+0x58e>
  803b1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b1e:	8b 40 04             	mov    0x4(%eax),%eax
  803b21:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803b24:	8b 12                	mov    (%edx),%edx
  803b26:	89 10                	mov    %edx,(%eax)
  803b28:	eb 0a                	jmp    803b34 <realloc_block_FF+0x598>
  803b2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b2d:	8b 00                	mov    (%eax),%eax
  803b2f:	a3 44 50 80 00       	mov    %eax,0x805044
  803b34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803b3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b40:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803b47:	a1 50 50 80 00       	mov    0x805050,%eax
  803b4c:	48                   	dec    %eax
  803b4d:	a3 50 50 80 00       	mov    %eax,0x805050

				//set block
				set_block_data(va, curBLOCK_size + nextBLOCK_size, 1);
  803b52:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803b55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803b58:	01 d0                	add    %edx,%eax
  803b5a:	83 ec 04             	sub    $0x4,%esp
  803b5d:	6a 01                	push   $0x1
  803b5f:	50                   	push   %eax
  803b60:	ff 75 08             	pushl  0x8(%ebp)
  803b63:	e8 41 ea ff ff       	call   8025a9 <set_block_data>
  803b68:	83 c4 10             	add    $0x10,%esp
  803b6b:	e9 36 01 00 00       	jmp    803ca6 <realloc_block_FF+0x70a>
			}
			else
			{
				newBLOCK_size = curBLOCK_size + needed_size;
  803b70:	8b 55 ec             	mov    -0x14(%ebp),%edx
  803b73:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  803b76:	01 d0                	add    %edx,%eax
  803b78:	89 45 f0             	mov    %eax,-0x10(%ebp)
				set_block_data(va, newBLOCK_size, 1);
  803b7b:	83 ec 04             	sub    $0x4,%esp
  803b7e:	6a 01                	push   $0x1
  803b80:	ff 75 f0             	pushl  -0x10(%ebp)
  803b83:	ff 75 08             	pushl  0x8(%ebp)
  803b86:	e8 1e ea ff ff       	call   8025a9 <set_block_data>
  803b8b:	83 c4 10             	add    $0x10,%esp
				void *next_new_va = (void *)(FOOTER(va) + 2);
  803b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  803b91:	83 e8 04             	sub    $0x4,%eax
  803b94:	8b 00                	mov    (%eax),%eax
  803b96:	83 e0 fe             	and    $0xfffffffe,%eax
  803b99:	89 c2                	mov    %eax,%edx
  803b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  803b9e:	01 d0                	add    %edx,%eax
  803ba0:	89 45 b8             	mov    %eax,-0x48(%ebp)

				//update free_block_list
				LIST_INSERT_AFTER(&freeBlocksList, (struct BlockElement*)next_va, (struct BlockElement*)next_new_va);
  803ba3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  803ba7:	74 06                	je     803baf <realloc_block_FF+0x613>
  803ba9:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  803bad:	75 17                	jne    803bc6 <realloc_block_FF+0x62a>
  803baf:	83 ec 04             	sub    $0x4,%esp
  803bb2:	68 1c 4a 80 00       	push   $0x804a1c
  803bb7:	68 44 02 00 00       	push   $0x244
  803bbc:	68 a9 49 80 00       	push   $0x8049a9
  803bc1:	e8 3a cb ff ff       	call   800700 <_panic>
  803bc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803bc9:	8b 10                	mov    (%eax),%edx
  803bcb:	8b 45 b8             	mov    -0x48(%ebp),%eax
  803bce:	89 10                	mov    %edx,(%eax)
  803bd0:	8b 45 b8             	mov    -0x48(%ebp),%eax
  803bd3:	8b 00                	mov    (%eax),%eax
  803bd5:	85 c0                	test   %eax,%eax
  803bd7:	74 0b                	je     803be4 <realloc_block_FF+0x648>
  803bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803bdc:	8b 00                	mov    (%eax),%eax
  803bde:	8b 55 b8             	mov    -0x48(%ebp),%edx
  803be1:	89 50 04             	mov    %edx,0x4(%eax)
  803be4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803be7:	8b 55 b8             	mov    -0x48(%ebp),%edx
  803bea:	89 10                	mov    %edx,(%eax)
  803bec:	8b 45 b8             	mov    -0x48(%ebp),%eax
  803bef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803bf2:	89 50 04             	mov    %edx,0x4(%eax)
  803bf5:	8b 45 b8             	mov    -0x48(%ebp),%eax
  803bf8:	8b 00                	mov    (%eax),%eax
  803bfa:	85 c0                	test   %eax,%eax
  803bfc:	75 08                	jne    803c06 <realloc_block_FF+0x66a>
  803bfe:	8b 45 b8             	mov    -0x48(%ebp),%eax
  803c01:	a3 48 50 80 00       	mov    %eax,0x805048
  803c06:	a1 50 50 80 00       	mov    0x805050,%eax
  803c0b:	40                   	inc    %eax
  803c0c:	a3 50 50 80 00       	mov    %eax,0x805050
				LIST_REMOVE(&freeBlocksList, (struct BlockElement*)next_va);
  803c11:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  803c15:	75 17                	jne    803c2e <realloc_block_FF+0x692>
  803c17:	83 ec 04             	sub    $0x4,%esp
  803c1a:	68 8b 49 80 00       	push   $0x80498b
  803c1f:	68 45 02 00 00       	push   $0x245
  803c24:	68 a9 49 80 00       	push   $0x8049a9
  803c29:	e8 d2 ca ff ff       	call   800700 <_panic>
  803c2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c31:	8b 00                	mov    (%eax),%eax
  803c33:	85 c0                	test   %eax,%eax
  803c35:	74 10                	je     803c47 <realloc_block_FF+0x6ab>
  803c37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c3a:	8b 00                	mov    (%eax),%eax
  803c3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803c3f:	8b 52 04             	mov    0x4(%edx),%edx
  803c42:	89 50 04             	mov    %edx,0x4(%eax)
  803c45:	eb 0b                	jmp    803c52 <realloc_block_FF+0x6b6>
  803c47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c4a:	8b 40 04             	mov    0x4(%eax),%eax
  803c4d:	a3 48 50 80 00       	mov    %eax,0x805048
  803c52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c55:	8b 40 04             	mov    0x4(%eax),%eax
  803c58:	85 c0                	test   %eax,%eax
  803c5a:	74 0f                	je     803c6b <realloc_block_FF+0x6cf>
  803c5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c5f:	8b 40 04             	mov    0x4(%eax),%eax
  803c62:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  803c65:	8b 12                	mov    (%edx),%edx
  803c67:	89 10                	mov    %edx,(%eax)
  803c69:	eb 0a                	jmp    803c75 <realloc_block_FF+0x6d9>
  803c6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c6e:	8b 00                	mov    (%eax),%eax
  803c70:	a3 44 50 80 00       	mov    %eax,0x805044
  803c75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  803c7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c81:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  803c88:	a1 50 50 80 00       	mov    0x805050,%eax
  803c8d:	48                   	dec    %eax
  803c8e:	a3 50 50 80 00       	mov    %eax,0x805050
				set_block_data(next_new_va, remaining_size, 0);
  803c93:	83 ec 04             	sub    $0x4,%esp
  803c96:	6a 00                	push   $0x0
  803c98:	ff 75 bc             	pushl  -0x44(%ebp)
  803c9b:	ff 75 b8             	pushl  -0x48(%ebp)
  803c9e:	e8 06 e9 ff ff       	call   8025a9 <set_block_data>
  803ca3:	83 c4 10             	add    $0x10,%esp
			}
			return va;
  803ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  803ca9:	eb 0a                	jmp    803cb5 <realloc_block_FF+0x719>
		}
	}

	int abo_salah = 1; // abo salah NUMBER 1
  803cab:	c7 45 b4 01 00 00 00 	movl   $0x1,-0x4c(%ebp)
	return va;
  803cb2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  803cb5:	c9                   	leave  
  803cb6:	c3                   	ret    

00803cb7 <alloc_block_WF>:
/*********************************************************************************************/
//=========================================
// [7] ALLOCATE BLOCK BY WORST FIT:
//=========================================
void *alloc_block_WF(uint32 size)
{
  803cb7:	55                   	push   %ebp
  803cb8:	89 e5                	mov    %esp,%ebp
  803cba:	83 ec 08             	sub    $0x8,%esp
	panic("alloc_block_WF is not implemented yet");
  803cbd:	83 ec 04             	sub    $0x4,%esp
  803cc0:	68 a0 4a 80 00       	push   $0x804aa0
  803cc5:	68 58 02 00 00       	push   $0x258
  803cca:	68 a9 49 80 00       	push   $0x8049a9
  803ccf:	e8 2c ca ff ff       	call   800700 <_panic>

00803cd4 <alloc_block_NF>:

//=========================================
// [8] ALLOCATE BLOCK BY NEXT FIT:
//=========================================
void *alloc_block_NF(uint32 size)
{
  803cd4:	55                   	push   %ebp
  803cd5:	89 e5                	mov    %esp,%ebp
  803cd7:	83 ec 08             	sub    $0x8,%esp
	panic("alloc_block_NF is not implemented yet");
  803cda:	83 ec 04             	sub    $0x4,%esp
  803cdd:	68 c8 4a 80 00       	push   $0x804ac8
  803ce2:	68 61 02 00 00       	push   $0x261
  803ce7:	68 a9 49 80 00       	push   $0x8049a9
  803cec:	e8 0f ca ff ff       	call   800700 <_panic>
  803cf1:	66 90                	xchg   %ax,%ax
  803cf3:	90                   	nop

00803cf4 <__udivdi3>:
  803cf4:	55                   	push   %ebp
  803cf5:	57                   	push   %edi
  803cf6:	56                   	push   %esi
  803cf7:	53                   	push   %ebx
  803cf8:	83 ec 1c             	sub    $0x1c,%esp
  803cfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  803cff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803d07:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803d0b:	89 ca                	mov    %ecx,%edx
  803d0d:	89 f8                	mov    %edi,%eax
  803d0f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  803d13:	85 f6                	test   %esi,%esi
  803d15:	75 2d                	jne    803d44 <__udivdi3+0x50>
  803d17:	39 cf                	cmp    %ecx,%edi
  803d19:	77 65                	ja     803d80 <__udivdi3+0x8c>
  803d1b:	89 fd                	mov    %edi,%ebp
  803d1d:	85 ff                	test   %edi,%edi
  803d1f:	75 0b                	jne    803d2c <__udivdi3+0x38>
  803d21:	b8 01 00 00 00       	mov    $0x1,%eax
  803d26:	31 d2                	xor    %edx,%edx
  803d28:	f7 f7                	div    %edi
  803d2a:	89 c5                	mov    %eax,%ebp
  803d2c:	31 d2                	xor    %edx,%edx
  803d2e:	89 c8                	mov    %ecx,%eax
  803d30:	f7 f5                	div    %ebp
  803d32:	89 c1                	mov    %eax,%ecx
  803d34:	89 d8                	mov    %ebx,%eax
  803d36:	f7 f5                	div    %ebp
  803d38:	89 cf                	mov    %ecx,%edi
  803d3a:	89 fa                	mov    %edi,%edx
  803d3c:	83 c4 1c             	add    $0x1c,%esp
  803d3f:	5b                   	pop    %ebx
  803d40:	5e                   	pop    %esi
  803d41:	5f                   	pop    %edi
  803d42:	5d                   	pop    %ebp
  803d43:	c3                   	ret    
  803d44:	39 ce                	cmp    %ecx,%esi
  803d46:	77 28                	ja     803d70 <__udivdi3+0x7c>
  803d48:	0f bd fe             	bsr    %esi,%edi
  803d4b:	83 f7 1f             	xor    $0x1f,%edi
  803d4e:	75 40                	jne    803d90 <__udivdi3+0x9c>
  803d50:	39 ce                	cmp    %ecx,%esi
  803d52:	72 0a                	jb     803d5e <__udivdi3+0x6a>
  803d54:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803d58:	0f 87 9e 00 00 00    	ja     803dfc <__udivdi3+0x108>
  803d5e:	b8 01 00 00 00       	mov    $0x1,%eax
  803d63:	89 fa                	mov    %edi,%edx
  803d65:	83 c4 1c             	add    $0x1c,%esp
  803d68:	5b                   	pop    %ebx
  803d69:	5e                   	pop    %esi
  803d6a:	5f                   	pop    %edi
  803d6b:	5d                   	pop    %ebp
  803d6c:	c3                   	ret    
  803d6d:	8d 76 00             	lea    0x0(%esi),%esi
  803d70:	31 ff                	xor    %edi,%edi
  803d72:	31 c0                	xor    %eax,%eax
  803d74:	89 fa                	mov    %edi,%edx
  803d76:	83 c4 1c             	add    $0x1c,%esp
  803d79:	5b                   	pop    %ebx
  803d7a:	5e                   	pop    %esi
  803d7b:	5f                   	pop    %edi
  803d7c:	5d                   	pop    %ebp
  803d7d:	c3                   	ret    
  803d7e:	66 90                	xchg   %ax,%ax
  803d80:	89 d8                	mov    %ebx,%eax
  803d82:	f7 f7                	div    %edi
  803d84:	31 ff                	xor    %edi,%edi
  803d86:	89 fa                	mov    %edi,%edx
  803d88:	83 c4 1c             	add    $0x1c,%esp
  803d8b:	5b                   	pop    %ebx
  803d8c:	5e                   	pop    %esi
  803d8d:	5f                   	pop    %edi
  803d8e:	5d                   	pop    %ebp
  803d8f:	c3                   	ret    
  803d90:	bd 20 00 00 00       	mov    $0x20,%ebp
  803d95:	89 eb                	mov    %ebp,%ebx
  803d97:	29 fb                	sub    %edi,%ebx
  803d99:	89 f9                	mov    %edi,%ecx
  803d9b:	d3 e6                	shl    %cl,%esi
  803d9d:	89 c5                	mov    %eax,%ebp
  803d9f:	88 d9                	mov    %bl,%cl
  803da1:	d3 ed                	shr    %cl,%ebp
  803da3:	89 e9                	mov    %ebp,%ecx
  803da5:	09 f1                	or     %esi,%ecx
  803da7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803dab:	89 f9                	mov    %edi,%ecx
  803dad:	d3 e0                	shl    %cl,%eax
  803daf:	89 c5                	mov    %eax,%ebp
  803db1:	89 d6                	mov    %edx,%esi
  803db3:	88 d9                	mov    %bl,%cl
  803db5:	d3 ee                	shr    %cl,%esi
  803db7:	89 f9                	mov    %edi,%ecx
  803db9:	d3 e2                	shl    %cl,%edx
  803dbb:	8b 44 24 08          	mov    0x8(%esp),%eax
  803dbf:	88 d9                	mov    %bl,%cl
  803dc1:	d3 e8                	shr    %cl,%eax
  803dc3:	09 c2                	or     %eax,%edx
  803dc5:	89 d0                	mov    %edx,%eax
  803dc7:	89 f2                	mov    %esi,%edx
  803dc9:	f7 74 24 0c          	divl   0xc(%esp)
  803dcd:	89 d6                	mov    %edx,%esi
  803dcf:	89 c3                	mov    %eax,%ebx
  803dd1:	f7 e5                	mul    %ebp
  803dd3:	39 d6                	cmp    %edx,%esi
  803dd5:	72 19                	jb     803df0 <__udivdi3+0xfc>
  803dd7:	74 0b                	je     803de4 <__udivdi3+0xf0>
  803dd9:	89 d8                	mov    %ebx,%eax
  803ddb:	31 ff                	xor    %edi,%edi
  803ddd:	e9 58 ff ff ff       	jmp    803d3a <__udivdi3+0x46>
  803de2:	66 90                	xchg   %ax,%ax
  803de4:	8b 54 24 08          	mov    0x8(%esp),%edx
  803de8:	89 f9                	mov    %edi,%ecx
  803dea:	d3 e2                	shl    %cl,%edx
  803dec:	39 c2                	cmp    %eax,%edx
  803dee:	73 e9                	jae    803dd9 <__udivdi3+0xe5>
  803df0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803df3:	31 ff                	xor    %edi,%edi
  803df5:	e9 40 ff ff ff       	jmp    803d3a <__udivdi3+0x46>
  803dfa:	66 90                	xchg   %ax,%ax
  803dfc:	31 c0                	xor    %eax,%eax
  803dfe:	e9 37 ff ff ff       	jmp    803d3a <__udivdi3+0x46>
  803e03:	90                   	nop

00803e04 <__umoddi3>:
  803e04:	55                   	push   %ebp
  803e05:	57                   	push   %edi
  803e06:	56                   	push   %esi
  803e07:	53                   	push   %ebx
  803e08:	83 ec 1c             	sub    $0x1c,%esp
  803e0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  803e0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803e17:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  803e1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803e1f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803e23:	89 f3                	mov    %esi,%ebx
  803e25:	89 fa                	mov    %edi,%edx
  803e27:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803e2b:	89 34 24             	mov    %esi,(%esp)
  803e2e:	85 c0                	test   %eax,%eax
  803e30:	75 1a                	jne    803e4c <__umoddi3+0x48>
  803e32:	39 f7                	cmp    %esi,%edi
  803e34:	0f 86 a2 00 00 00    	jbe    803edc <__umoddi3+0xd8>
  803e3a:	89 c8                	mov    %ecx,%eax
  803e3c:	89 f2                	mov    %esi,%edx
  803e3e:	f7 f7                	div    %edi
  803e40:	89 d0                	mov    %edx,%eax
  803e42:	31 d2                	xor    %edx,%edx
  803e44:	83 c4 1c             	add    $0x1c,%esp
  803e47:	5b                   	pop    %ebx
  803e48:	5e                   	pop    %esi
  803e49:	5f                   	pop    %edi
  803e4a:	5d                   	pop    %ebp
  803e4b:	c3                   	ret    
  803e4c:	39 f0                	cmp    %esi,%eax
  803e4e:	0f 87 ac 00 00 00    	ja     803f00 <__umoddi3+0xfc>
  803e54:	0f bd e8             	bsr    %eax,%ebp
  803e57:	83 f5 1f             	xor    $0x1f,%ebp
  803e5a:	0f 84 ac 00 00 00    	je     803f0c <__umoddi3+0x108>
  803e60:	bf 20 00 00 00       	mov    $0x20,%edi
  803e65:	29 ef                	sub    %ebp,%edi
  803e67:	89 fe                	mov    %edi,%esi
  803e69:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803e6d:	89 e9                	mov    %ebp,%ecx
  803e6f:	d3 e0                	shl    %cl,%eax
  803e71:	89 d7                	mov    %edx,%edi
  803e73:	89 f1                	mov    %esi,%ecx
  803e75:	d3 ef                	shr    %cl,%edi
  803e77:	09 c7                	or     %eax,%edi
  803e79:	89 e9                	mov    %ebp,%ecx
  803e7b:	d3 e2                	shl    %cl,%edx
  803e7d:	89 14 24             	mov    %edx,(%esp)
  803e80:	89 d8                	mov    %ebx,%eax
  803e82:	d3 e0                	shl    %cl,%eax
  803e84:	89 c2                	mov    %eax,%edx
  803e86:	8b 44 24 08          	mov    0x8(%esp),%eax
  803e8a:	d3 e0                	shl    %cl,%eax
  803e8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803e90:	8b 44 24 08          	mov    0x8(%esp),%eax
  803e94:	89 f1                	mov    %esi,%ecx
  803e96:	d3 e8                	shr    %cl,%eax
  803e98:	09 d0                	or     %edx,%eax
  803e9a:	d3 eb                	shr    %cl,%ebx
  803e9c:	89 da                	mov    %ebx,%edx
  803e9e:	f7 f7                	div    %edi
  803ea0:	89 d3                	mov    %edx,%ebx
  803ea2:	f7 24 24             	mull   (%esp)
  803ea5:	89 c6                	mov    %eax,%esi
  803ea7:	89 d1                	mov    %edx,%ecx
  803ea9:	39 d3                	cmp    %edx,%ebx
  803eab:	0f 82 87 00 00 00    	jb     803f38 <__umoddi3+0x134>
  803eb1:	0f 84 91 00 00 00    	je     803f48 <__umoddi3+0x144>
  803eb7:	8b 54 24 04          	mov    0x4(%esp),%edx
  803ebb:	29 f2                	sub    %esi,%edx
  803ebd:	19 cb                	sbb    %ecx,%ebx
  803ebf:	89 d8                	mov    %ebx,%eax
  803ec1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  803ec5:	d3 e0                	shl    %cl,%eax
  803ec7:	89 e9                	mov    %ebp,%ecx
  803ec9:	d3 ea                	shr    %cl,%edx
  803ecb:	09 d0                	or     %edx,%eax
  803ecd:	89 e9                	mov    %ebp,%ecx
  803ecf:	d3 eb                	shr    %cl,%ebx
  803ed1:	89 da                	mov    %ebx,%edx
  803ed3:	83 c4 1c             	add    $0x1c,%esp
  803ed6:	5b                   	pop    %ebx
  803ed7:	5e                   	pop    %esi
  803ed8:	5f                   	pop    %edi
  803ed9:	5d                   	pop    %ebp
  803eda:	c3                   	ret    
  803edb:	90                   	nop
  803edc:	89 fd                	mov    %edi,%ebp
  803ede:	85 ff                	test   %edi,%edi
  803ee0:	75 0b                	jne    803eed <__umoddi3+0xe9>
  803ee2:	b8 01 00 00 00       	mov    $0x1,%eax
  803ee7:	31 d2                	xor    %edx,%edx
  803ee9:	f7 f7                	div    %edi
  803eeb:	89 c5                	mov    %eax,%ebp
  803eed:	89 f0                	mov    %esi,%eax
  803eef:	31 d2                	xor    %edx,%edx
  803ef1:	f7 f5                	div    %ebp
  803ef3:	89 c8                	mov    %ecx,%eax
  803ef5:	f7 f5                	div    %ebp
  803ef7:	89 d0                	mov    %edx,%eax
  803ef9:	e9 44 ff ff ff       	jmp    803e42 <__umoddi3+0x3e>
  803efe:	66 90                	xchg   %ax,%ax
  803f00:	89 c8                	mov    %ecx,%eax
  803f02:	89 f2                	mov    %esi,%edx
  803f04:	83 c4 1c             	add    $0x1c,%esp
  803f07:	5b                   	pop    %ebx
  803f08:	5e                   	pop    %esi
  803f09:	5f                   	pop    %edi
  803f0a:	5d                   	pop    %ebp
  803f0b:	c3                   	ret    
  803f0c:	3b 04 24             	cmp    (%esp),%eax
  803f0f:	72 06                	jb     803f17 <__umoddi3+0x113>
  803f11:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  803f15:	77 0f                	ja     803f26 <__umoddi3+0x122>
  803f17:	89 f2                	mov    %esi,%edx
  803f19:	29 f9                	sub    %edi,%ecx
  803f1b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  803f1f:	89 14 24             	mov    %edx,(%esp)
  803f22:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803f26:	8b 44 24 04          	mov    0x4(%esp),%eax
  803f2a:	8b 14 24             	mov    (%esp),%edx
  803f2d:	83 c4 1c             	add    $0x1c,%esp
  803f30:	5b                   	pop    %ebx
  803f31:	5e                   	pop    %esi
  803f32:	5f                   	pop    %edi
  803f33:	5d                   	pop    %ebp
  803f34:	c3                   	ret    
  803f35:	8d 76 00             	lea    0x0(%esi),%esi
  803f38:	2b 04 24             	sub    (%esp),%eax
  803f3b:	19 fa                	sbb    %edi,%edx
  803f3d:	89 d1                	mov    %edx,%ecx
  803f3f:	89 c6                	mov    %eax,%esi
  803f41:	e9 71 ff ff ff       	jmp    803eb7 <__umoddi3+0xb3>
  803f46:	66 90                	xchg   %ax,%ax
  803f48:	39 44 24 04          	cmp    %eax,0x4(%esp)
  803f4c:	72 ea                	jb     803f38 <__umoddi3+0x134>
  803f4e:	89 d9                	mov    %ebx,%ecx
  803f50:	e9 62 ff ff ff       	jmp    803eb7 <__umoddi3+0xb3>
