
obj/kern/kernel:     formato del fichero elf32-i386


Desensamblado de la sección .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 80 18 10 f0       	push   $0xf0101880
f0100050:	e8 95 08 00 00       	call   f01008ea <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 e5 06 00 00       	call   f0100760 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 9c 18 10 f0       	push   $0xf010189c
f0100087:	e8 5e 08 00 00       	call   f01008ea <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 22 13 00 00       	call   f01013d3 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 8f 04 00 00       	call   f0100545 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 b7 18 10 f0       	push   $0xf01018b7
f01000c3:	e8 22 08 00 00       	call   f01008ea <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 89 06 00 00       	call   f010076a <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 d2 18 10 f0       	push   $0xf01018d2
f0100110:	e8 d5 07 00 00       	call   f01008ea <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 a5 07 00 00       	call   f01008c4 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 0e 19 10 f0 	movl   $0xf010190e,(%esp)
f0100126:	e8 bf 07 00 00       	call   f01008ea <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 32 06 00 00       	call   f010076a <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 ea 18 10 f0       	push   $0xf01018ea
f0100152:	e8 93 07 00 00       	call   f01008ea <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 61 07 00 00       	call   f01008c4 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 0e 19 10 f0 	movl   $0xf010190e,(%esp)
f010016a:	e8 7b 07 00 00       	call   f01008ea <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f0 00 00 00    	je     f01002d7 <kbd_proc_data+0xfe>
f01001e7:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ec:	ec                   	in     (%dx),%al
f01001ed:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001ef:	3c e0                	cmp    $0xe0,%al
f01001f1:	75 0d                	jne    f0100200 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001f3:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001fa:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001ff:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100200:	55                   	push   %ebp
f0100201:	89 e5                	mov    %esp,%ebp
f0100203:	53                   	push   %ebx
f0100204:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100207:	84 c0                	test   %al,%al
f0100209:	79 36                	jns    f0100241 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010020b:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100211:	89 cb                	mov    %ecx,%ebx
f0100213:	83 e3 40             	and    $0x40,%ebx
f0100216:	83 e0 7f             	and    $0x7f,%eax
f0100219:	85 db                	test   %ebx,%ebx
f010021b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010021e:	0f b6 d2             	movzbl %dl,%edx
f0100221:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
f0100228:	83 c8 40             	or     $0x40,%eax
f010022b:	0f b6 c0             	movzbl %al,%eax
f010022e:	f7 d0                	not    %eax
f0100230:	21 c8                	and    %ecx,%eax
f0100232:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	e9 9e 00 00 00       	jmp    f01002df <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100241:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100247:	f6 c1 40             	test   $0x40,%cl
f010024a:	74 0e                	je     f010025a <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010024c:	83 c8 80             	or     $0xffffff80,%eax
f010024f:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100251:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100254:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010025a:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010025d:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
f0100264:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f010026a:	0f b6 8a 60 19 10 f0 	movzbl -0xfefe6a0(%edx),%ecx
f0100271:	31 c8                	xor    %ecx,%eax
f0100273:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100278:	89 c1                	mov    %eax,%ecx
f010027a:	83 e1 03             	and    $0x3,%ecx
f010027d:	8b 0c 8d 40 19 10 f0 	mov    -0xfefe6c0(,%ecx,4),%ecx
f0100284:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100288:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010028b:	a8 08                	test   $0x8,%al
f010028d:	74 1b                	je     f01002aa <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010028f:	89 da                	mov    %ebx,%edx
f0100291:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100294:	83 f9 19             	cmp    $0x19,%ecx
f0100297:	77 05                	ja     f010029e <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100299:	83 eb 20             	sub    $0x20,%ebx
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010029e:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a1:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002a4:	83 fa 19             	cmp    $0x19,%edx
f01002a7:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002aa:	f7 d0                	not    %eax
f01002ac:	a8 06                	test   $0x6,%al
f01002ae:	75 2d                	jne    f01002dd <kbd_proc_data+0x104>
f01002b0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002b6:	75 25                	jne    f01002dd <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002b8:	83 ec 0c             	sub    $0xc,%esp
f01002bb:	68 04 19 10 f0       	push   $0xf0101904
f01002c0:	e8 25 06 00 00       	call   f01008ea <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c5:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ca:	b8 03 00 00 00       	mov    $0x3,%eax
f01002cf:	ee                   	out    %al,(%dx)
f01002d0:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d3:	89 d8                	mov    %ebx,%eax
f01002d5:	eb 08                	jmp    f01002df <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002dc:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002dd:	89 d8                	mov    %ebx,%eax
}
f01002df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002e2:	c9                   	leave  
f01002e3:	c3                   	ret    

f01002e4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e4:	55                   	push   %ebp
f01002e5:	89 e5                	mov    %esp,%ebp
f01002e7:	57                   	push   %edi
f01002e8:	56                   	push   %esi
f01002e9:	53                   	push   %ebx
f01002ea:	83 ec 1c             	sub    $0x1c,%esp
f01002ed:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ef:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fe:	eb 09                	jmp    f0100309 <cons_putc+0x25>
f0100300:	89 ca                	mov    %ecx,%edx
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
f0100304:	ec                   	in     (%dx),%al
f0100305:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100306:	83 c3 01             	add    $0x1,%ebx
f0100309:	89 f2                	mov    %esi,%edx
f010030b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030c:	a8 20                	test   $0x20,%al
f010030e:	75 08                	jne    f0100318 <cons_putc+0x34>
f0100310:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100316:	7e e8                	jle    f0100300 <cons_putc+0x1c>
f0100318:	89 f8                	mov    %edi,%eax
f010031a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100322:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100323:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100328:	be 79 03 00 00       	mov    $0x379,%esi
f010032d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100332:	eb 09                	jmp    f010033d <cons_putc+0x59>
f0100334:	89 ca                	mov    %ecx,%edx
f0100336:	ec                   	in     (%dx),%al
f0100337:	ec                   	in     (%dx),%al
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	83 c3 01             	add    $0x1,%ebx
f010033d:	89 f2                	mov    %esi,%edx
f010033f:	ec                   	in     (%dx),%al
f0100340:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100346:	7f 04                	jg     f010034c <cons_putc+0x68>
f0100348:	84 c0                	test   %al,%al
f010034a:	79 e8                	jns    f0100334 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100351:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100355:	ee                   	out    %al,(%dx)
f0100356:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010035b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100360:	ee                   	out    %al,(%dx)
f0100361:	b8 08 00 00 00       	mov    $0x8,%eax
f0100366:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100367:	89 fa                	mov    %edi,%edx
f0100369:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010036f:	89 f8                	mov    %edi,%eax
f0100371:	80 cc 07             	or     $0x7,%ah
f0100374:	85 d2                	test   %edx,%edx
f0100376:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100379:	89 f8                	mov    %edi,%eax
f010037b:	0f b6 c0             	movzbl %al,%eax
f010037e:	83 f8 09             	cmp    $0x9,%eax
f0100381:	74 74                	je     f01003f7 <cons_putc+0x113>
f0100383:	83 f8 09             	cmp    $0x9,%eax
f0100386:	7f 0a                	jg     f0100392 <cons_putc+0xae>
f0100388:	83 f8 08             	cmp    $0x8,%eax
f010038b:	74 14                	je     f01003a1 <cons_putc+0xbd>
f010038d:	e9 99 00 00 00       	jmp    f010042b <cons_putc+0x147>
f0100392:	83 f8 0a             	cmp    $0xa,%eax
f0100395:	74 3a                	je     f01003d1 <cons_putc+0xed>
f0100397:	83 f8 0d             	cmp    $0xd,%eax
f010039a:	74 3d                	je     f01003d9 <cons_putc+0xf5>
f010039c:	e9 8a 00 00 00       	jmp    f010042b <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003a1:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003a8:	66 85 c0             	test   %ax,%ax
f01003ab:	0f 84 e6 00 00 00    	je     f0100497 <cons_putc+0x1b3>
			crt_pos--;
f01003b1:	83 e8 01             	sub    $0x1,%eax
f01003b4:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003ba:	0f b7 c0             	movzwl %ax,%eax
f01003bd:	66 81 e7 00 ff       	and    $0xff00,%di
f01003c2:	83 cf 20             	or     $0x20,%edi
f01003c5:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003cf:	eb 78                	jmp    f0100449 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003d1:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003d8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003d9:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003e0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e6:	c1 e8 16             	shr    $0x16,%eax
f01003e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003ec:	c1 e0 04             	shl    $0x4,%eax
f01003ef:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f01003f5:	eb 52                	jmp    f0100449 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fc:	e8 e3 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100401:	b8 20 00 00 00       	mov    $0x20,%eax
f0100406:	e8 d9 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f010040b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100410:	e8 cf fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100415:	b8 20 00 00 00       	mov    $0x20,%eax
f010041a:	e8 c5 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f010041f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100424:	e8 bb fe ff ff       	call   f01002e4 <cons_putc>
f0100429:	eb 1e                	jmp    f0100449 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010042b:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100432:	8d 50 01             	lea    0x1(%eax),%edx
f0100435:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010043c:	0f b7 c0             	movzwl %ax,%eax
f010043f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100445:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100449:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f0100450:	cf 07 
f0100452:	76 43                	jbe    f0100497 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100454:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100459:	83 ec 04             	sub    $0x4,%esp
f010045c:	68 00 0f 00 00       	push   $0xf00
f0100461:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100467:	52                   	push   %edx
f0100468:	50                   	push   %eax
f0100469:	e8 b2 0f 00 00       	call   f0101420 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010046e:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100474:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010047a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100480:	83 c4 10             	add    $0x10,%esp
f0100483:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100488:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010048b:	39 d0                	cmp    %edx,%eax
f010048d:	75 f4                	jne    f0100483 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010048f:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f0100496:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100497:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f010049d:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a2:	89 ca                	mov    %ecx,%edx
f01004a4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a5:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ac:	8d 71 01             	lea    0x1(%ecx),%esi
f01004af:	89 d8                	mov    %ebx,%eax
f01004b1:	66 c1 e8 08          	shr    $0x8,%ax
f01004b5:	89 f2                	mov    %esi,%edx
f01004b7:	ee                   	out    %al,(%dx)
f01004b8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004bd:	89 ca                	mov    %ecx,%edx
f01004bf:	ee                   	out    %al,(%dx)
f01004c0:	89 d8                	mov    %ebx,%eax
f01004c2:	89 f2                	mov    %esi,%edx
f01004c4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004c8:	5b                   	pop    %ebx
f01004c9:	5e                   	pop    %esi
f01004ca:	5f                   	pop    %edi
f01004cb:	5d                   	pop    %ebp
f01004cc:	c3                   	ret    

f01004cd <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004cd:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004d4:	74 11                	je     f01004e7 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004d6:	55                   	push   %ebp
f01004d7:	89 e5                	mov    %esp,%ebp
f01004d9:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004dc:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004e1:	e8 b0 fc ff ff       	call   f0100196 <cons_intr>
}
f01004e6:	c9                   	leave  
f01004e7:	f3 c3                	repz ret 

f01004e9 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e9:	55                   	push   %ebp
f01004ea:	89 e5                	mov    %esp,%ebp
f01004ec:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ef:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f01004f4:	e8 9d fc ff ff       	call   f0100196 <cons_intr>
}
f01004f9:	c9                   	leave  
f01004fa:	c3                   	ret    

f01004fb <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004fb:	55                   	push   %ebp
f01004fc:	89 e5                	mov    %esp,%ebp
f01004fe:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100501:	e8 c7 ff ff ff       	call   f01004cd <serial_intr>
	kbd_intr();
f0100506:	e8 de ff ff ff       	call   f01004e9 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010050b:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f0100510:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100516:	74 26                	je     f010053e <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100518:	8d 50 01             	lea    0x1(%eax),%edx
f010051b:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f0100521:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100528:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010052a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100530:	75 11                	jne    f0100543 <cons_getc+0x48>
			cons.rpos = 0;
f0100532:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100539:	00 00 00 
f010053c:	eb 05                	jmp    f0100543 <cons_getc+0x48>
		return c;
	}
	return 0;
f010053e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	57                   	push   %edi
f0100549:	56                   	push   %esi
f010054a:	53                   	push   %ebx
f010054b:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010054e:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100555:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010055c:	5a a5 
	if (*cp != 0xA55A) {
f010055e:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100565:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100569:	74 11                	je     f010057c <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010056b:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100572:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100575:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010057a:	eb 16                	jmp    f0100592 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010057c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100583:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010058a:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010058d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100592:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f0100598:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059d:	89 fa                	mov    %edi,%edx
f010059f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005a0:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a3:	89 da                	mov    %ebx,%edx
f01005a5:	ec                   	in     (%dx),%al
f01005a6:	0f b6 c8             	movzbl %al,%ecx
f01005a9:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ac:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b1:	89 fa                	mov    %edi,%edx
f01005b3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b4:	89 da                	mov    %ebx,%edx
f01005b6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005b7:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005bd:	0f b6 c0             	movzbl %al,%eax
f01005c0:	09 c8                	or     %ecx,%eax
f01005c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c8:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d2:	89 f2                	mov    %esi,%edx
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005da:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005df:	ee                   	out    %al,(%dx)
f01005e0:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005e5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005ea:	89 da                	mov    %ebx,%edx
f01005ec:	ee                   	out    %al,(%dx)
f01005ed:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005fd:	b8 03 00 00 00       	mov    $0x3,%eax
f0100602:	ee                   	out    %al,(%dx)
f0100603:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100608:	b8 00 00 00 00       	mov    $0x0,%eax
f010060d:	ee                   	out    %al,(%dx)
f010060e:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100613:	b8 01 00 00 00       	mov    $0x1,%eax
f0100618:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100619:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010061e:	ec                   	in     (%dx),%al
f010061f:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100621:	3c ff                	cmp    $0xff,%al
f0100623:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f010062a:	89 f2                	mov    %esi,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 da                	mov    %ebx,%edx
f010062f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100630:	80 f9 ff             	cmp    $0xff,%cl
f0100633:	75 10                	jne    f0100645 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100635:	83 ec 0c             	sub    $0xc,%esp
f0100638:	68 10 19 10 f0       	push   $0xf0101910
f010063d:	e8 a8 02 00 00       	call   f01008ea <cprintf>
f0100642:	83 c4 10             	add    $0x10,%esp
}
f0100645:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100648:	5b                   	pop    %ebx
f0100649:	5e                   	pop    %esi
f010064a:	5f                   	pop    %edi
f010064b:	5d                   	pop    %ebp
f010064c:	c3                   	ret    

f010064d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010064d:	55                   	push   %ebp
f010064e:	89 e5                	mov    %esp,%ebp
f0100650:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100653:	8b 45 08             	mov    0x8(%ebp),%eax
f0100656:	e8 89 fc ff ff       	call   f01002e4 <cons_putc>
}
f010065b:	c9                   	leave  
f010065c:	c3                   	ret    

f010065d <getchar>:

int
getchar(void)
{
f010065d:	55                   	push   %ebp
f010065e:	89 e5                	mov    %esp,%ebp
f0100660:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100663:	e8 93 fe ff ff       	call   f01004fb <cons_getc>
f0100668:	85 c0                	test   %eax,%eax
f010066a:	74 f7                	je     f0100663 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010066c:	c9                   	leave  
f010066d:	c3                   	ret    

f010066e <iscons>:

int
iscons(int fdnum)
{
f010066e:	55                   	push   %ebp
f010066f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100671:	b8 01 00 00 00       	mov    $0x1,%eax
f0100676:	5d                   	pop    %ebp
f0100677:	c3                   	ret    

f0100678 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100678:	55                   	push   %ebp
f0100679:	89 e5                	mov    %esp,%ebp
f010067b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010067e:	68 60 1b 10 f0       	push   $0xf0101b60
f0100683:	68 7e 1b 10 f0       	push   $0xf0101b7e
f0100688:	68 83 1b 10 f0       	push   $0xf0101b83
f010068d:	e8 58 02 00 00       	call   f01008ea <cprintf>
f0100692:	83 c4 0c             	add    $0xc,%esp
f0100695:	68 ec 1b 10 f0       	push   $0xf0101bec
f010069a:	68 8c 1b 10 f0       	push   $0xf0101b8c
f010069f:	68 83 1b 10 f0       	push   $0xf0101b83
f01006a4:	e8 41 02 00 00       	call   f01008ea <cprintf>
	return 0;
}
f01006a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ae:	c9                   	leave  
f01006af:	c3                   	ret    

f01006b0 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006b0:	55                   	push   %ebp
f01006b1:	89 e5                	mov    %esp,%ebp
f01006b3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006b6:	68 95 1b 10 f0       	push   $0xf0101b95
f01006bb:	e8 2a 02 00 00       	call   f01008ea <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006c0:	83 c4 08             	add    $0x8,%esp
f01006c3:	68 0c 00 10 00       	push   $0x10000c
f01006c8:	68 14 1c 10 f0       	push   $0xf0101c14
f01006cd:	e8 18 02 00 00       	call   f01008ea <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006d2:	83 c4 0c             	add    $0xc,%esp
f01006d5:	68 0c 00 10 00       	push   $0x10000c
f01006da:	68 0c 00 10 f0       	push   $0xf010000c
f01006df:	68 3c 1c 10 f0       	push   $0xf0101c3c
f01006e4:	e8 01 02 00 00       	call   f01008ea <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006e9:	83 c4 0c             	add    $0xc,%esp
f01006ec:	68 61 18 10 00       	push   $0x101861
f01006f1:	68 61 18 10 f0       	push   $0xf0101861
f01006f6:	68 60 1c 10 f0       	push   $0xf0101c60
f01006fb:	e8 ea 01 00 00       	call   f01008ea <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100700:	83 c4 0c             	add    $0xc,%esp
f0100703:	68 00 23 11 00       	push   $0x112300
f0100708:	68 00 23 11 f0       	push   $0xf0112300
f010070d:	68 84 1c 10 f0       	push   $0xf0101c84
f0100712:	e8 d3 01 00 00       	call   f01008ea <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100717:	83 c4 0c             	add    $0xc,%esp
f010071a:	68 44 29 11 00       	push   $0x112944
f010071f:	68 44 29 11 f0       	push   $0xf0112944
f0100724:	68 a8 1c 10 f0       	push   $0xf0101ca8
f0100729:	e8 bc 01 00 00       	call   f01008ea <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010072e:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100733:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100738:	83 c4 08             	add    $0x8,%esp
f010073b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100740:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100746:	85 c0                	test   %eax,%eax
f0100748:	0f 48 c2             	cmovs  %edx,%eax
f010074b:	c1 f8 0a             	sar    $0xa,%eax
f010074e:	50                   	push   %eax
f010074f:	68 cc 1c 10 f0       	push   $0xf0101ccc
f0100754:	e8 91 01 00 00       	call   f01008ea <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100759:	b8 00 00 00 00       	mov    $0x0,%eax
f010075e:	c9                   	leave  
f010075f:	c3                   	ret    

f0100760 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100760:	55                   	push   %ebp
f0100761:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100763:	b8 00 00 00 00       	mov    $0x0,%eax
f0100768:	5d                   	pop    %ebp
f0100769:	c3                   	ret    

f010076a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010076a:	55                   	push   %ebp
f010076b:	89 e5                	mov    %esp,%ebp
f010076d:	57                   	push   %edi
f010076e:	56                   	push   %esi
f010076f:	53                   	push   %ebx
f0100770:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100773:	68 f8 1c 10 f0       	push   $0xf0101cf8
f0100778:	e8 6d 01 00 00       	call   f01008ea <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010077d:	c7 04 24 1c 1d 10 f0 	movl   $0xf0101d1c,(%esp)
f0100784:	e8 61 01 00 00       	call   f01008ea <cprintf>
f0100789:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010078c:	83 ec 0c             	sub    $0xc,%esp
f010078f:	68 ae 1b 10 f0       	push   $0xf0101bae
f0100794:	e8 e3 09 00 00       	call   f010117c <readline>
f0100799:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010079b:	83 c4 10             	add    $0x10,%esp
f010079e:	85 c0                	test   %eax,%eax
f01007a0:	74 ea                	je     f010078c <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007a2:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007a9:	be 00 00 00 00       	mov    $0x0,%esi
f01007ae:	eb 0a                	jmp    f01007ba <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007b0:	c6 03 00             	movb   $0x0,(%ebx)
f01007b3:	89 f7                	mov    %esi,%edi
f01007b5:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007b8:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007ba:	0f b6 03             	movzbl (%ebx),%eax
f01007bd:	84 c0                	test   %al,%al
f01007bf:	74 63                	je     f0100824 <monitor+0xba>
f01007c1:	83 ec 08             	sub    $0x8,%esp
f01007c4:	0f be c0             	movsbl %al,%eax
f01007c7:	50                   	push   %eax
f01007c8:	68 b2 1b 10 f0       	push   $0xf0101bb2
f01007cd:	e8 c4 0b 00 00       	call   f0101396 <strchr>
f01007d2:	83 c4 10             	add    $0x10,%esp
f01007d5:	85 c0                	test   %eax,%eax
f01007d7:	75 d7                	jne    f01007b0 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01007d9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007dc:	74 46                	je     f0100824 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007de:	83 fe 0f             	cmp    $0xf,%esi
f01007e1:	75 14                	jne    f01007f7 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007e3:	83 ec 08             	sub    $0x8,%esp
f01007e6:	6a 10                	push   $0x10
f01007e8:	68 b7 1b 10 f0       	push   $0xf0101bb7
f01007ed:	e8 f8 00 00 00       	call   f01008ea <cprintf>
f01007f2:	83 c4 10             	add    $0x10,%esp
f01007f5:	eb 95                	jmp    f010078c <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01007f7:	8d 7e 01             	lea    0x1(%esi),%edi
f01007fa:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007fe:	eb 03                	jmp    f0100803 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100800:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100803:	0f b6 03             	movzbl (%ebx),%eax
f0100806:	84 c0                	test   %al,%al
f0100808:	74 ae                	je     f01007b8 <monitor+0x4e>
f010080a:	83 ec 08             	sub    $0x8,%esp
f010080d:	0f be c0             	movsbl %al,%eax
f0100810:	50                   	push   %eax
f0100811:	68 b2 1b 10 f0       	push   $0xf0101bb2
f0100816:	e8 7b 0b 00 00       	call   f0101396 <strchr>
f010081b:	83 c4 10             	add    $0x10,%esp
f010081e:	85 c0                	test   %eax,%eax
f0100820:	74 de                	je     f0100800 <monitor+0x96>
f0100822:	eb 94                	jmp    f01007b8 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100824:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010082b:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010082c:	85 f6                	test   %esi,%esi
f010082e:	0f 84 58 ff ff ff    	je     f010078c <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100834:	83 ec 08             	sub    $0x8,%esp
f0100837:	68 7e 1b 10 f0       	push   $0xf0101b7e
f010083c:	ff 75 a8             	pushl  -0x58(%ebp)
f010083f:	e8 f4 0a 00 00       	call   f0101338 <strcmp>
f0100844:	83 c4 10             	add    $0x10,%esp
f0100847:	85 c0                	test   %eax,%eax
f0100849:	74 1e                	je     f0100869 <monitor+0xff>
f010084b:	83 ec 08             	sub    $0x8,%esp
f010084e:	68 8c 1b 10 f0       	push   $0xf0101b8c
f0100853:	ff 75 a8             	pushl  -0x58(%ebp)
f0100856:	e8 dd 0a 00 00       	call   f0101338 <strcmp>
f010085b:	83 c4 10             	add    $0x10,%esp
f010085e:	85 c0                	test   %eax,%eax
f0100860:	75 2f                	jne    f0100891 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100862:	b8 01 00 00 00       	mov    $0x1,%eax
f0100867:	eb 05                	jmp    f010086e <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100869:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f010086e:	83 ec 04             	sub    $0x4,%esp
f0100871:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100874:	01 d0                	add    %edx,%eax
f0100876:	ff 75 08             	pushl  0x8(%ebp)
f0100879:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f010087c:	51                   	push   %ecx
f010087d:	56                   	push   %esi
f010087e:	ff 14 85 4c 1d 10 f0 	call   *-0xfefe2b4(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100885:	83 c4 10             	add    $0x10,%esp
f0100888:	85 c0                	test   %eax,%eax
f010088a:	78 1d                	js     f01008a9 <monitor+0x13f>
f010088c:	e9 fb fe ff ff       	jmp    f010078c <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100891:	83 ec 08             	sub    $0x8,%esp
f0100894:	ff 75 a8             	pushl  -0x58(%ebp)
f0100897:	68 d4 1b 10 f0       	push   $0xf0101bd4
f010089c:	e8 49 00 00 00       	call   f01008ea <cprintf>
f01008a1:	83 c4 10             	add    $0x10,%esp
f01008a4:	e9 e3 fe ff ff       	jmp    f010078c <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ac:	5b                   	pop    %ebx
f01008ad:	5e                   	pop    %esi
f01008ae:	5f                   	pop    %edi
f01008af:	5d                   	pop    %ebp
f01008b0:	c3                   	ret    

f01008b1 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008b1:	55                   	push   %ebp
f01008b2:	89 e5                	mov    %esp,%ebp
f01008b4:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01008b7:	ff 75 08             	pushl  0x8(%ebp)
f01008ba:	e8 8e fd ff ff       	call   f010064d <cputchar>
	*cnt++;
}
f01008bf:	83 c4 10             	add    $0x10,%esp
f01008c2:	c9                   	leave  
f01008c3:	c3                   	ret    

f01008c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008c4:	55                   	push   %ebp
f01008c5:	89 e5                	mov    %esp,%ebp
f01008c7:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01008ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008d1:	ff 75 0c             	pushl  0xc(%ebp)
f01008d4:	ff 75 08             	pushl  0x8(%ebp)
f01008d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008da:	50                   	push   %eax
f01008db:	68 b1 08 10 f0       	push   $0xf01008b1
f01008e0:	e8 c9 03 00 00       	call   f0100cae <vprintfmt>
	return cnt;
}
f01008e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008e8:	c9                   	leave  
f01008e9:	c3                   	ret    

f01008ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01008ea:	55                   	push   %ebp
f01008eb:	89 e5                	mov    %esp,%ebp
f01008ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01008f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01008f3:	50                   	push   %eax
f01008f4:	ff 75 08             	pushl  0x8(%ebp)
f01008f7:	e8 c8 ff ff ff       	call   f01008c4 <vcprintf>
	va_end(ap);

	return cnt;
}
f01008fc:	c9                   	leave  
f01008fd:	c3                   	ret    

f01008fe <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01008fe:	55                   	push   %ebp
f01008ff:	89 e5                	mov    %esp,%ebp
f0100901:	57                   	push   %edi
f0100902:	56                   	push   %esi
f0100903:	53                   	push   %ebx
f0100904:	83 ec 14             	sub    $0x14,%esp
f0100907:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010090a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010090d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100910:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100913:	8b 1a                	mov    (%edx),%ebx
f0100915:	8b 01                	mov    (%ecx),%eax
f0100917:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010091a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100921:	eb 7f                	jmp    f01009a2 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100923:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100926:	01 d8                	add    %ebx,%eax
f0100928:	89 c6                	mov    %eax,%esi
f010092a:	c1 ee 1f             	shr    $0x1f,%esi
f010092d:	01 c6                	add    %eax,%esi
f010092f:	d1 fe                	sar    %esi
f0100931:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100934:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100937:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010093a:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010093c:	eb 03                	jmp    f0100941 <stab_binsearch+0x43>
			m--;
f010093e:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100941:	39 c3                	cmp    %eax,%ebx
f0100943:	7f 0d                	jg     f0100952 <stab_binsearch+0x54>
f0100945:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100949:	83 ea 0c             	sub    $0xc,%edx
f010094c:	39 f9                	cmp    %edi,%ecx
f010094e:	75 ee                	jne    f010093e <stab_binsearch+0x40>
f0100950:	eb 05                	jmp    f0100957 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100952:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100955:	eb 4b                	jmp    f01009a2 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100957:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010095a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010095d:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100961:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100964:	76 11                	jbe    f0100977 <stab_binsearch+0x79>
			*region_left = m;
f0100966:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100969:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010096b:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010096e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100975:	eb 2b                	jmp    f01009a2 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100977:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010097a:	73 14                	jae    f0100990 <stab_binsearch+0x92>
			*region_right = m - 1;
f010097c:	83 e8 01             	sub    $0x1,%eax
f010097f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100982:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100985:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100987:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010098e:	eb 12                	jmp    f01009a2 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100990:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100993:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100995:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100999:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010099b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01009a2:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01009a5:	0f 8e 78 ff ff ff    	jle    f0100923 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01009ab:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01009af:	75 0f                	jne    f01009c0 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01009b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009b4:	8b 00                	mov    (%eax),%eax
f01009b6:	83 e8 01             	sub    $0x1,%eax
f01009b9:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01009bc:	89 06                	mov    %eax,(%esi)
f01009be:	eb 2c                	jmp    f01009ec <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009c3:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009c5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009c8:	8b 0e                	mov    (%esi),%ecx
f01009ca:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009cd:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01009d0:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009d3:	eb 03                	jmp    f01009d8 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01009d5:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009d8:	39 c8                	cmp    %ecx,%eax
f01009da:	7e 0b                	jle    f01009e7 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01009dc:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01009e0:	83 ea 0c             	sub    $0xc,%edx
f01009e3:	39 df                	cmp    %ebx,%edi
f01009e5:	75 ee                	jne    f01009d5 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01009e7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009ea:	89 06                	mov    %eax,(%esi)
	}
}
f01009ec:	83 c4 14             	add    $0x14,%esp
f01009ef:	5b                   	pop    %ebx
f01009f0:	5e                   	pop    %esi
f01009f1:	5f                   	pop    %edi
f01009f2:	5d                   	pop    %ebp
f01009f3:	c3                   	ret    

f01009f4 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01009f4:	55                   	push   %ebp
f01009f5:	89 e5                	mov    %esp,%ebp
f01009f7:	57                   	push   %edi
f01009f8:	56                   	push   %esi
f01009f9:	53                   	push   %ebx
f01009fa:	83 ec 1c             	sub    $0x1c,%esp
f01009fd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a00:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a03:	c7 06 5c 1d 10 f0    	movl   $0xf0101d5c,(%esi)
	info->eip_line = 0;
f0100a09:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100a10:	c7 46 08 5c 1d 10 f0 	movl   $0xf0101d5c,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100a17:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100a1e:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100a21:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a28:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100a2e:	76 11                	jbe    f0100a41 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a30:	b8 31 71 10 f0       	mov    $0xf0107131,%eax
f0100a35:	3d 69 58 10 f0       	cmp    $0xf0105869,%eax
f0100a3a:	77 19                	ja     f0100a55 <debuginfo_eip+0x61>
f0100a3c:	e9 62 01 00 00       	jmp    f0100ba3 <debuginfo_eip+0x1af>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100a41:	83 ec 04             	sub    $0x4,%esp
f0100a44:	68 66 1d 10 f0       	push   $0xf0101d66
f0100a49:	6a 7f                	push   $0x7f
f0100a4b:	68 73 1d 10 f0       	push   $0xf0101d73
f0100a50:	e8 91 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a55:	80 3d 30 71 10 f0 00 	cmpb   $0x0,0xf0107130
f0100a5c:	0f 85 48 01 00 00    	jne    f0100baa <debuginfo_eip+0x1b6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a62:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a69:	b8 68 58 10 f0       	mov    $0xf0105868,%eax
f0100a6e:	2d b0 1f 10 f0       	sub    $0xf0101fb0,%eax
f0100a73:	c1 f8 02             	sar    $0x2,%eax
f0100a76:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100a7c:	83 e8 01             	sub    $0x1,%eax
f0100a7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a82:	83 ec 08             	sub    $0x8,%esp
f0100a85:	57                   	push   %edi
f0100a86:	6a 64                	push   $0x64
f0100a88:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100a8b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100a8e:	b8 b0 1f 10 f0       	mov    $0xf0101fb0,%eax
f0100a93:	e8 66 fe ff ff       	call   f01008fe <stab_binsearch>
	if (lfile == 0)
f0100a98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a9b:	83 c4 10             	add    $0x10,%esp
f0100a9e:	85 c0                	test   %eax,%eax
f0100aa0:	0f 84 0b 01 00 00    	je     f0100bb1 <debuginfo_eip+0x1bd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100aa6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100aa9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aac:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100aaf:	83 ec 08             	sub    $0x8,%esp
f0100ab2:	57                   	push   %edi
f0100ab3:	6a 24                	push   $0x24
f0100ab5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ab8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100abb:	b8 b0 1f 10 f0       	mov    $0xf0101fb0,%eax
f0100ac0:	e8 39 fe ff ff       	call   f01008fe <stab_binsearch>

	if (lfun <= rfun) {
f0100ac5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ac8:	83 c4 10             	add    $0x10,%esp
f0100acb:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100ace:	7f 31                	jg     f0100b01 <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ad0:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ad3:	c1 e0 02             	shl    $0x2,%eax
f0100ad6:	8d 90 b0 1f 10 f0    	lea    -0xfefe050(%eax),%edx
f0100adc:	8b 88 b0 1f 10 f0    	mov    -0xfefe050(%eax),%ecx
f0100ae2:	b8 31 71 10 f0       	mov    $0xf0107131,%eax
f0100ae7:	2d 69 58 10 f0       	sub    $0xf0105869,%eax
f0100aec:	39 c1                	cmp    %eax,%ecx
f0100aee:	73 09                	jae    f0100af9 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100af0:	81 c1 69 58 10 f0    	add    $0xf0105869,%ecx
f0100af6:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100af9:	8b 42 08             	mov    0x8(%edx),%eax
f0100afc:	89 46 10             	mov    %eax,0x10(%esi)
f0100aff:	eb 06                	jmp    f0100b07 <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b01:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100b04:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b07:	83 ec 08             	sub    $0x8,%esp
f0100b0a:	6a 3a                	push   $0x3a
f0100b0c:	ff 76 08             	pushl  0x8(%esi)
f0100b0f:	e8 a3 08 00 00       	call   f01013b7 <strfind>
f0100b14:	2b 46 08             	sub    0x8(%esi),%eax
f0100b17:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b1a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b1d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b20:	8d 04 85 b0 1f 10 f0 	lea    -0xfefe050(,%eax,4),%eax
f0100b27:	83 c4 10             	add    $0x10,%esp
f0100b2a:	eb 06                	jmp    f0100b32 <debuginfo_eip+0x13e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b2c:	83 eb 01             	sub    $0x1,%ebx
f0100b2f:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b32:	39 fb                	cmp    %edi,%ebx
f0100b34:	7c 34                	jl     f0100b6a <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0100b36:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100b3a:	80 fa 84             	cmp    $0x84,%dl
f0100b3d:	74 0b                	je     f0100b4a <debuginfo_eip+0x156>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b3f:	80 fa 64             	cmp    $0x64,%dl
f0100b42:	75 e8                	jne    f0100b2c <debuginfo_eip+0x138>
f0100b44:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100b48:	74 e2                	je     f0100b2c <debuginfo_eip+0x138>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100b4a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b4d:	8b 14 85 b0 1f 10 f0 	mov    -0xfefe050(,%eax,4),%edx
f0100b54:	b8 31 71 10 f0       	mov    $0xf0107131,%eax
f0100b59:	2d 69 58 10 f0       	sub    $0xf0105869,%eax
f0100b5e:	39 c2                	cmp    %eax,%edx
f0100b60:	73 08                	jae    f0100b6a <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b62:	81 c2 69 58 10 f0    	add    $0xf0105869,%edx
f0100b68:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b6a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100b6d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b70:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b75:	39 cb                	cmp    %ecx,%ebx
f0100b77:	7d 44                	jge    f0100bbd <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
f0100b79:	8d 53 01             	lea    0x1(%ebx),%edx
f0100b7c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b7f:	8d 04 85 b0 1f 10 f0 	lea    -0xfefe050(,%eax,4),%eax
f0100b86:	eb 07                	jmp    f0100b8f <debuginfo_eip+0x19b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100b88:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100b8c:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100b8f:	39 ca                	cmp    %ecx,%edx
f0100b91:	74 25                	je     f0100bb8 <debuginfo_eip+0x1c4>
f0100b93:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100b96:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100b9a:	74 ec                	je     f0100b88 <debuginfo_eip+0x194>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba1:	eb 1a                	jmp    f0100bbd <debuginfo_eip+0x1c9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ba3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ba8:	eb 13                	jmp    f0100bbd <debuginfo_eip+0x1c9>
f0100baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100baf:	eb 0c                	jmp    f0100bbd <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100bb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bb6:	eb 05                	jmp    f0100bbd <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bc0:	5b                   	pop    %ebx
f0100bc1:	5e                   	pop    %esi
f0100bc2:	5f                   	pop    %edi
f0100bc3:	5d                   	pop    %ebp
f0100bc4:	c3                   	ret    

f0100bc5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100bc5:	55                   	push   %ebp
f0100bc6:	89 e5                	mov    %esp,%ebp
f0100bc8:	57                   	push   %edi
f0100bc9:	56                   	push   %esi
f0100bca:	53                   	push   %ebx
f0100bcb:	83 ec 1c             	sub    $0x1c,%esp
f0100bce:	89 c7                	mov    %eax,%edi
f0100bd0:	89 d6                	mov    %edx,%esi
f0100bd2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100bd8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bdb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100be1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100be6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100be9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100bec:	39 d3                	cmp    %edx,%ebx
f0100bee:	72 05                	jb     f0100bf5 <printnum+0x30>
f0100bf0:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100bf3:	77 45                	ja     f0100c3a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100bf5:	83 ec 0c             	sub    $0xc,%esp
f0100bf8:	ff 75 18             	pushl  0x18(%ebp)
f0100bfb:	8b 45 14             	mov    0x14(%ebp),%eax
f0100bfe:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100c01:	53                   	push   %ebx
f0100c02:	ff 75 10             	pushl  0x10(%ebp)
f0100c05:	83 ec 08             	sub    $0x8,%esp
f0100c08:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c0b:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c0e:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c11:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c14:	e8 c7 09 00 00       	call   f01015e0 <__udivdi3>
f0100c19:	83 c4 18             	add    $0x18,%esp
f0100c1c:	52                   	push   %edx
f0100c1d:	50                   	push   %eax
f0100c1e:	89 f2                	mov    %esi,%edx
f0100c20:	89 f8                	mov    %edi,%eax
f0100c22:	e8 9e ff ff ff       	call   f0100bc5 <printnum>
f0100c27:	83 c4 20             	add    $0x20,%esp
f0100c2a:	eb 18                	jmp    f0100c44 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c2c:	83 ec 08             	sub    $0x8,%esp
f0100c2f:	56                   	push   %esi
f0100c30:	ff 75 18             	pushl  0x18(%ebp)
f0100c33:	ff d7                	call   *%edi
f0100c35:	83 c4 10             	add    $0x10,%esp
f0100c38:	eb 03                	jmp    f0100c3d <printnum+0x78>
f0100c3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c3d:	83 eb 01             	sub    $0x1,%ebx
f0100c40:	85 db                	test   %ebx,%ebx
f0100c42:	7f e8                	jg     f0100c2c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c44:	83 ec 08             	sub    $0x8,%esp
f0100c47:	56                   	push   %esi
f0100c48:	83 ec 04             	sub    $0x4,%esp
f0100c4b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c4e:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c51:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c54:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c57:	e8 b4 0a 00 00       	call   f0101710 <__umoddi3>
f0100c5c:	83 c4 14             	add    $0x14,%esp
f0100c5f:	0f be 80 81 1d 10 f0 	movsbl -0xfefe27f(%eax),%eax
f0100c66:	50                   	push   %eax
f0100c67:	ff d7                	call   *%edi
}
f0100c69:	83 c4 10             	add    $0x10,%esp
f0100c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c6f:	5b                   	pop    %ebx
f0100c70:	5e                   	pop    %esi
f0100c71:	5f                   	pop    %edi
f0100c72:	5d                   	pop    %ebp
f0100c73:	c3                   	ret    

f0100c74 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100c74:	55                   	push   %ebp
f0100c75:	89 e5                	mov    %esp,%ebp
f0100c77:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100c7a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100c7e:	8b 10                	mov    (%eax),%edx
f0100c80:	3b 50 04             	cmp    0x4(%eax),%edx
f0100c83:	73 0a                	jae    f0100c8f <sprintputch+0x1b>
		*b->buf++ = ch;
f0100c85:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100c88:	89 08                	mov    %ecx,(%eax)
f0100c8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c8d:	88 02                	mov    %al,(%edx)
}
f0100c8f:	5d                   	pop    %ebp
f0100c90:	c3                   	ret    

f0100c91 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100c91:	55                   	push   %ebp
f0100c92:	89 e5                	mov    %esp,%ebp
f0100c94:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100c97:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100c9a:	50                   	push   %eax
f0100c9b:	ff 75 10             	pushl  0x10(%ebp)
f0100c9e:	ff 75 0c             	pushl  0xc(%ebp)
f0100ca1:	ff 75 08             	pushl  0x8(%ebp)
f0100ca4:	e8 05 00 00 00       	call   f0100cae <vprintfmt>
	va_end(ap);
}
f0100ca9:	83 c4 10             	add    $0x10,%esp
f0100cac:	c9                   	leave  
f0100cad:	c3                   	ret    

f0100cae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100cae:	55                   	push   %ebp
f0100caf:	89 e5                	mov    %esp,%ebp
f0100cb1:	57                   	push   %edi
f0100cb2:	56                   	push   %esi
f0100cb3:	53                   	push   %ebx
f0100cb4:	83 ec 2c             	sub    $0x2c,%esp
f0100cb7:	8b 75 08             	mov    0x8(%ebp),%esi
f0100cba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100cbd:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100cc0:	eb 12                	jmp    f0100cd4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100cc2:	85 c0                	test   %eax,%eax
f0100cc4:	0f 84 42 04 00 00    	je     f010110c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0100cca:	83 ec 08             	sub    $0x8,%esp
f0100ccd:	53                   	push   %ebx
f0100cce:	50                   	push   %eax
f0100ccf:	ff d6                	call   *%esi
f0100cd1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100cd4:	83 c7 01             	add    $0x1,%edi
f0100cd7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100cdb:	83 f8 25             	cmp    $0x25,%eax
f0100cde:	75 e2                	jne    f0100cc2 <vprintfmt+0x14>
f0100ce0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100ce4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100ceb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100cf2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100cfe:	eb 07                	jmp    f0100d07 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d00:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100d03:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d07:	8d 47 01             	lea    0x1(%edi),%eax
f0100d0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d0d:	0f b6 07             	movzbl (%edi),%eax
f0100d10:	0f b6 d0             	movzbl %al,%edx
f0100d13:	83 e8 23             	sub    $0x23,%eax
f0100d16:	3c 55                	cmp    $0x55,%al
f0100d18:	0f 87 d3 03 00 00    	ja     f01010f1 <vprintfmt+0x443>
f0100d1e:	0f b6 c0             	movzbl %al,%eax
f0100d21:	ff 24 85 20 1e 10 f0 	jmp    *-0xfefe1e0(,%eax,4)
f0100d28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100d2b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100d2f:	eb d6                	jmp    f0100d07 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d31:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d34:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d39:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100d3c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100d3f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100d43:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100d46:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100d49:	83 f9 09             	cmp    $0x9,%ecx
f0100d4c:	77 3f                	ja     f0100d8d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100d4e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100d51:	eb e9                	jmp    f0100d3c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100d53:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d56:	8b 00                	mov    (%eax),%eax
f0100d58:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d5e:	8d 40 04             	lea    0x4(%eax),%eax
f0100d61:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100d67:	eb 2a                	jmp    f0100d93 <vprintfmt+0xe5>
f0100d69:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d6c:	85 c0                	test   %eax,%eax
f0100d6e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d73:	0f 49 d0             	cmovns %eax,%edx
f0100d76:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d7c:	eb 89                	jmp    f0100d07 <vprintfmt+0x59>
f0100d7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100d81:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100d88:	e9 7a ff ff ff       	jmp    f0100d07 <vprintfmt+0x59>
f0100d8d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d90:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100d93:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100d97:	0f 89 6a ff ff ff    	jns    f0100d07 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100d9d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100da0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100da3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100daa:	e9 58 ff ff ff       	jmp    f0100d07 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100daf:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100db2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100db5:	e9 4d ff ff ff       	jmp    f0100d07 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100dba:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dbd:	8d 78 04             	lea    0x4(%eax),%edi
f0100dc0:	83 ec 08             	sub    $0x8,%esp
f0100dc3:	53                   	push   %ebx
f0100dc4:	ff 30                	pushl  (%eax)
f0100dc6:	ff d6                	call   *%esi
			break;
f0100dc8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100dcb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100dd1:	e9 fe fe ff ff       	jmp    f0100cd4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100dd6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dd9:	8d 78 04             	lea    0x4(%eax),%edi
f0100ddc:	8b 00                	mov    (%eax),%eax
f0100dde:	99                   	cltd   
f0100ddf:	31 d0                	xor    %edx,%eax
f0100de1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100de3:	83 f8 07             	cmp    $0x7,%eax
f0100de6:	7f 0b                	jg     f0100df3 <vprintfmt+0x145>
f0100de8:	8b 14 85 80 1f 10 f0 	mov    -0xfefe080(,%eax,4),%edx
f0100def:	85 d2                	test   %edx,%edx
f0100df1:	75 1b                	jne    f0100e0e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0100df3:	50                   	push   %eax
f0100df4:	68 99 1d 10 f0       	push   $0xf0101d99
f0100df9:	53                   	push   %ebx
f0100dfa:	56                   	push   %esi
f0100dfb:	e8 91 fe ff ff       	call   f0100c91 <printfmt>
f0100e00:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e03:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100e09:	e9 c6 fe ff ff       	jmp    f0100cd4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100e0e:	52                   	push   %edx
f0100e0f:	68 a2 1d 10 f0       	push   $0xf0101da2
f0100e14:	53                   	push   %ebx
f0100e15:	56                   	push   %esi
f0100e16:	e8 76 fe ff ff       	call   f0100c91 <printfmt>
f0100e1b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e1e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e21:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e24:	e9 ab fe ff ff       	jmp    f0100cd4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100e29:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e2c:	83 c0 04             	add    $0x4,%eax
f0100e2f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100e32:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e35:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100e37:	85 ff                	test   %edi,%edi
f0100e39:	b8 92 1d 10 f0       	mov    $0xf0101d92,%eax
f0100e3e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100e41:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e45:	0f 8e 94 00 00 00    	jle    f0100edf <vprintfmt+0x231>
f0100e4b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100e4f:	0f 84 98 00 00 00    	je     f0100eed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e55:	83 ec 08             	sub    $0x8,%esp
f0100e58:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e5b:	57                   	push   %edi
f0100e5c:	e8 0c 04 00 00       	call   f010126d <strnlen>
f0100e61:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100e64:	29 c1                	sub    %eax,%ecx
f0100e66:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100e69:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100e6c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100e70:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e73:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e76:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e78:	eb 0f                	jmp    f0100e89 <vprintfmt+0x1db>
					putch(padc, putdat);
f0100e7a:	83 ec 08             	sub    $0x8,%esp
f0100e7d:	53                   	push   %ebx
f0100e7e:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e81:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e83:	83 ef 01             	sub    $0x1,%edi
f0100e86:	83 c4 10             	add    $0x10,%esp
f0100e89:	85 ff                	test   %edi,%edi
f0100e8b:	7f ed                	jg     f0100e7a <vprintfmt+0x1cc>
f0100e8d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100e90:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100e93:	85 c9                	test   %ecx,%ecx
f0100e95:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e9a:	0f 49 c1             	cmovns %ecx,%eax
f0100e9d:	29 c1                	sub    %eax,%ecx
f0100e9f:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ea2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ea5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ea8:	89 cb                	mov    %ecx,%ebx
f0100eaa:	eb 4d                	jmp    f0100ef9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100eac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100eb0:	74 1b                	je     f0100ecd <vprintfmt+0x21f>
f0100eb2:	0f be c0             	movsbl %al,%eax
f0100eb5:	83 e8 20             	sub    $0x20,%eax
f0100eb8:	83 f8 5e             	cmp    $0x5e,%eax
f0100ebb:	76 10                	jbe    f0100ecd <vprintfmt+0x21f>
					putch('?', putdat);
f0100ebd:	83 ec 08             	sub    $0x8,%esp
f0100ec0:	ff 75 0c             	pushl  0xc(%ebp)
f0100ec3:	6a 3f                	push   $0x3f
f0100ec5:	ff 55 08             	call   *0x8(%ebp)
f0100ec8:	83 c4 10             	add    $0x10,%esp
f0100ecb:	eb 0d                	jmp    f0100eda <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0100ecd:	83 ec 08             	sub    $0x8,%esp
f0100ed0:	ff 75 0c             	pushl  0xc(%ebp)
f0100ed3:	52                   	push   %edx
f0100ed4:	ff 55 08             	call   *0x8(%ebp)
f0100ed7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100eda:	83 eb 01             	sub    $0x1,%ebx
f0100edd:	eb 1a                	jmp    f0100ef9 <vprintfmt+0x24b>
f0100edf:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ee2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ee5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ee8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100eeb:	eb 0c                	jmp    f0100ef9 <vprintfmt+0x24b>
f0100eed:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ef0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ef3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ef6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100ef9:	83 c7 01             	add    $0x1,%edi
f0100efc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100f00:	0f be d0             	movsbl %al,%edx
f0100f03:	85 d2                	test   %edx,%edx
f0100f05:	74 23                	je     f0100f2a <vprintfmt+0x27c>
f0100f07:	85 f6                	test   %esi,%esi
f0100f09:	78 a1                	js     f0100eac <vprintfmt+0x1fe>
f0100f0b:	83 ee 01             	sub    $0x1,%esi
f0100f0e:	79 9c                	jns    f0100eac <vprintfmt+0x1fe>
f0100f10:	89 df                	mov    %ebx,%edi
f0100f12:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f18:	eb 18                	jmp    f0100f32 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100f1a:	83 ec 08             	sub    $0x8,%esp
f0100f1d:	53                   	push   %ebx
f0100f1e:	6a 20                	push   $0x20
f0100f20:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100f22:	83 ef 01             	sub    $0x1,%edi
f0100f25:	83 c4 10             	add    $0x10,%esp
f0100f28:	eb 08                	jmp    f0100f32 <vprintfmt+0x284>
f0100f2a:	89 df                	mov    %ebx,%edi
f0100f2c:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f32:	85 ff                	test   %edi,%edi
f0100f34:	7f e4                	jg     f0100f1a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f36:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f39:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f3f:	e9 90 fd ff ff       	jmp    f0100cd4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100f44:	83 f9 01             	cmp    $0x1,%ecx
f0100f47:	7e 19                	jle    f0100f62 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0100f49:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f4c:	8b 50 04             	mov    0x4(%eax),%edx
f0100f4f:	8b 00                	mov    (%eax),%eax
f0100f51:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f54:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100f57:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f5a:	8d 40 08             	lea    0x8(%eax),%eax
f0100f5d:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f60:	eb 38                	jmp    f0100f9a <vprintfmt+0x2ec>
	else if (lflag)
f0100f62:	85 c9                	test   %ecx,%ecx
f0100f64:	74 1b                	je     f0100f81 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0100f66:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f69:	8b 00                	mov    (%eax),%eax
f0100f6b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f6e:	89 c1                	mov    %eax,%ecx
f0100f70:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f73:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f76:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f79:	8d 40 04             	lea    0x4(%eax),%eax
f0100f7c:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f7f:	eb 19                	jmp    f0100f9a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0100f81:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f84:	8b 00                	mov    (%eax),%eax
f0100f86:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f89:	89 c1                	mov    %eax,%ecx
f0100f8b:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f8e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f91:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f94:	8d 40 04             	lea    0x4(%eax),%eax
f0100f97:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100f9a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100f9d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0100fa0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0100fa5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100fa9:	0f 89 0e 01 00 00    	jns    f01010bd <vprintfmt+0x40f>
				putch('-', putdat);
f0100faf:	83 ec 08             	sub    $0x8,%esp
f0100fb2:	53                   	push   %ebx
f0100fb3:	6a 2d                	push   $0x2d
f0100fb5:	ff d6                	call   *%esi
				num = -(long long) num;
f0100fb7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100fba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100fbd:	f7 da                	neg    %edx
f0100fbf:	83 d1 00             	adc    $0x0,%ecx
f0100fc2:	f7 d9                	neg    %ecx
f0100fc4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0100fc7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fcc:	e9 ec 00 00 00       	jmp    f01010bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100fd1:	83 f9 01             	cmp    $0x1,%ecx
f0100fd4:	7e 18                	jle    f0100fee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0100fd6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fd9:	8b 10                	mov    (%eax),%edx
f0100fdb:	8b 48 04             	mov    0x4(%eax),%ecx
f0100fde:	8d 40 08             	lea    0x8(%eax),%eax
f0100fe1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0100fe4:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fe9:	e9 cf 00 00 00       	jmp    f01010bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0100fee:	85 c9                	test   %ecx,%ecx
f0100ff0:	74 1a                	je     f010100c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0100ff2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ff5:	8b 10                	mov    (%eax),%edx
f0100ff7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ffc:	8d 40 04             	lea    0x4(%eax),%eax
f0100fff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101002:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101007:	e9 b1 00 00 00       	jmp    f01010bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f010100c:	8b 45 14             	mov    0x14(%ebp),%eax
f010100f:	8b 10                	mov    (%eax),%edx
f0101011:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101016:	8d 40 04             	lea    0x4(%eax),%eax
f0101019:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010101c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101021:	e9 97 00 00 00       	jmp    f01010bd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101026:	83 ec 08             	sub    $0x8,%esp
f0101029:	53                   	push   %ebx
f010102a:	6a 58                	push   $0x58
f010102c:	ff d6                	call   *%esi
			putch('X', putdat);
f010102e:	83 c4 08             	add    $0x8,%esp
f0101031:	53                   	push   %ebx
f0101032:	6a 58                	push   $0x58
f0101034:	ff d6                	call   *%esi
			putch('X', putdat);
f0101036:	83 c4 08             	add    $0x8,%esp
f0101039:	53                   	push   %ebx
f010103a:	6a 58                	push   $0x58
f010103c:	ff d6                	call   *%esi
			break;
f010103e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101041:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101044:	e9 8b fc ff ff       	jmp    f0100cd4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0101049:	83 ec 08             	sub    $0x8,%esp
f010104c:	53                   	push   %ebx
f010104d:	6a 30                	push   $0x30
f010104f:	ff d6                	call   *%esi
			putch('x', putdat);
f0101051:	83 c4 08             	add    $0x8,%esp
f0101054:	53                   	push   %ebx
f0101055:	6a 78                	push   $0x78
f0101057:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101059:	8b 45 14             	mov    0x14(%ebp),%eax
f010105c:	8b 10                	mov    (%eax),%edx
f010105e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101063:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101066:	8d 40 04             	lea    0x4(%eax),%eax
f0101069:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010106c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0101071:	eb 4a                	jmp    f01010bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101073:	83 f9 01             	cmp    $0x1,%ecx
f0101076:	7e 15                	jle    f010108d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0101078:	8b 45 14             	mov    0x14(%ebp),%eax
f010107b:	8b 10                	mov    (%eax),%edx
f010107d:	8b 48 04             	mov    0x4(%eax),%ecx
f0101080:	8d 40 08             	lea    0x8(%eax),%eax
f0101083:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0101086:	b8 10 00 00 00       	mov    $0x10,%eax
f010108b:	eb 30                	jmp    f01010bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010108d:	85 c9                	test   %ecx,%ecx
f010108f:	74 17                	je     f01010a8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f0101091:	8b 45 14             	mov    0x14(%ebp),%eax
f0101094:	8b 10                	mov    (%eax),%edx
f0101096:	b9 00 00 00 00       	mov    $0x0,%ecx
f010109b:	8d 40 04             	lea    0x4(%eax),%eax
f010109e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01010a1:	b8 10 00 00 00       	mov    $0x10,%eax
f01010a6:	eb 15                	jmp    f01010bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01010a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ab:	8b 10                	mov    (%eax),%edx
f01010ad:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010b2:	8d 40 04             	lea    0x4(%eax),%eax
f01010b5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01010b8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010bd:	83 ec 0c             	sub    $0xc,%esp
f01010c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01010c4:	57                   	push   %edi
f01010c5:	ff 75 e0             	pushl  -0x20(%ebp)
f01010c8:	50                   	push   %eax
f01010c9:	51                   	push   %ecx
f01010ca:	52                   	push   %edx
f01010cb:	89 da                	mov    %ebx,%edx
f01010cd:	89 f0                	mov    %esi,%eax
f01010cf:	e8 f1 fa ff ff       	call   f0100bc5 <printnum>
			break;
f01010d4:	83 c4 20             	add    $0x20,%esp
f01010d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010da:	e9 f5 fb ff ff       	jmp    f0100cd4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01010df:	83 ec 08             	sub    $0x8,%esp
f01010e2:	53                   	push   %ebx
f01010e3:	52                   	push   %edx
f01010e4:	ff d6                	call   *%esi
			break;
f01010e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01010ec:	e9 e3 fb ff ff       	jmp    f0100cd4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01010f1:	83 ec 08             	sub    $0x8,%esp
f01010f4:	53                   	push   %ebx
f01010f5:	6a 25                	push   $0x25
f01010f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01010f9:	83 c4 10             	add    $0x10,%esp
f01010fc:	eb 03                	jmp    f0101101 <vprintfmt+0x453>
f01010fe:	83 ef 01             	sub    $0x1,%edi
f0101101:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101105:	75 f7                	jne    f01010fe <vprintfmt+0x450>
f0101107:	e9 c8 fb ff ff       	jmp    f0100cd4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010110c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010110f:	5b                   	pop    %ebx
f0101110:	5e                   	pop    %esi
f0101111:	5f                   	pop    %edi
f0101112:	5d                   	pop    %ebp
f0101113:	c3                   	ret    

f0101114 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101114:	55                   	push   %ebp
f0101115:	89 e5                	mov    %esp,%ebp
f0101117:	83 ec 18             	sub    $0x18,%esp
f010111a:	8b 45 08             	mov    0x8(%ebp),%eax
f010111d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101120:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101123:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101127:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010112a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101131:	85 c0                	test   %eax,%eax
f0101133:	74 26                	je     f010115b <vsnprintf+0x47>
f0101135:	85 d2                	test   %edx,%edx
f0101137:	7e 22                	jle    f010115b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101139:	ff 75 14             	pushl  0x14(%ebp)
f010113c:	ff 75 10             	pushl  0x10(%ebp)
f010113f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101142:	50                   	push   %eax
f0101143:	68 74 0c 10 f0       	push   $0xf0100c74
f0101148:	e8 61 fb ff ff       	call   f0100cae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010114d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101150:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101153:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101156:	83 c4 10             	add    $0x10,%esp
f0101159:	eb 05                	jmp    f0101160 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010115b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101160:	c9                   	leave  
f0101161:	c3                   	ret    

f0101162 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101162:	55                   	push   %ebp
f0101163:	89 e5                	mov    %esp,%ebp
f0101165:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101168:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010116b:	50                   	push   %eax
f010116c:	ff 75 10             	pushl  0x10(%ebp)
f010116f:	ff 75 0c             	pushl  0xc(%ebp)
f0101172:	ff 75 08             	pushl  0x8(%ebp)
f0101175:	e8 9a ff ff ff       	call   f0101114 <vsnprintf>
	va_end(ap);

	return rc;
}
f010117a:	c9                   	leave  
f010117b:	c3                   	ret    

f010117c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010117c:	55                   	push   %ebp
f010117d:	89 e5                	mov    %esp,%ebp
f010117f:	57                   	push   %edi
f0101180:	56                   	push   %esi
f0101181:	53                   	push   %ebx
f0101182:	83 ec 0c             	sub    $0xc,%esp
f0101185:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101188:	85 c0                	test   %eax,%eax
f010118a:	74 11                	je     f010119d <readline+0x21>
		cprintf("%s", prompt);
f010118c:	83 ec 08             	sub    $0x8,%esp
f010118f:	50                   	push   %eax
f0101190:	68 a2 1d 10 f0       	push   $0xf0101da2
f0101195:	e8 50 f7 ff ff       	call   f01008ea <cprintf>
f010119a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010119d:	83 ec 0c             	sub    $0xc,%esp
f01011a0:	6a 00                	push   $0x0
f01011a2:	e8 c7 f4 ff ff       	call   f010066e <iscons>
f01011a7:	89 c7                	mov    %eax,%edi
f01011a9:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01011ac:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01011b1:	e8 a7 f4 ff ff       	call   f010065d <getchar>
f01011b6:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01011b8:	85 c0                	test   %eax,%eax
f01011ba:	79 18                	jns    f01011d4 <readline+0x58>
			cprintf("read error: %e\n", c);
f01011bc:	83 ec 08             	sub    $0x8,%esp
f01011bf:	50                   	push   %eax
f01011c0:	68 a0 1f 10 f0       	push   $0xf0101fa0
f01011c5:	e8 20 f7 ff ff       	call   f01008ea <cprintf>
			return NULL;
f01011ca:	83 c4 10             	add    $0x10,%esp
f01011cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d2:	eb 79                	jmp    f010124d <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01011d4:	83 f8 08             	cmp    $0x8,%eax
f01011d7:	0f 94 c2             	sete   %dl
f01011da:	83 f8 7f             	cmp    $0x7f,%eax
f01011dd:	0f 94 c0             	sete   %al
f01011e0:	08 c2                	or     %al,%dl
f01011e2:	74 1a                	je     f01011fe <readline+0x82>
f01011e4:	85 f6                	test   %esi,%esi
f01011e6:	7e 16                	jle    f01011fe <readline+0x82>
			if (echoing)
f01011e8:	85 ff                	test   %edi,%edi
f01011ea:	74 0d                	je     f01011f9 <readline+0x7d>
				cputchar('\b');
f01011ec:	83 ec 0c             	sub    $0xc,%esp
f01011ef:	6a 08                	push   $0x8
f01011f1:	e8 57 f4 ff ff       	call   f010064d <cputchar>
f01011f6:	83 c4 10             	add    $0x10,%esp
			i--;
f01011f9:	83 ee 01             	sub    $0x1,%esi
f01011fc:	eb b3                	jmp    f01011b1 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01011fe:	83 fb 1f             	cmp    $0x1f,%ebx
f0101201:	7e 23                	jle    f0101226 <readline+0xaa>
f0101203:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101209:	7f 1b                	jg     f0101226 <readline+0xaa>
			if (echoing)
f010120b:	85 ff                	test   %edi,%edi
f010120d:	74 0c                	je     f010121b <readline+0x9f>
				cputchar(c);
f010120f:	83 ec 0c             	sub    $0xc,%esp
f0101212:	53                   	push   %ebx
f0101213:	e8 35 f4 ff ff       	call   f010064d <cputchar>
f0101218:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010121b:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f0101221:	8d 76 01             	lea    0x1(%esi),%esi
f0101224:	eb 8b                	jmp    f01011b1 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101226:	83 fb 0a             	cmp    $0xa,%ebx
f0101229:	74 05                	je     f0101230 <readline+0xb4>
f010122b:	83 fb 0d             	cmp    $0xd,%ebx
f010122e:	75 81                	jne    f01011b1 <readline+0x35>
			if (echoing)
f0101230:	85 ff                	test   %edi,%edi
f0101232:	74 0d                	je     f0101241 <readline+0xc5>
				cputchar('\n');
f0101234:	83 ec 0c             	sub    $0xc,%esp
f0101237:	6a 0a                	push   $0xa
f0101239:	e8 0f f4 ff ff       	call   f010064d <cputchar>
f010123e:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0101241:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101248:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f010124d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101250:	5b                   	pop    %ebx
f0101251:	5e                   	pop    %esi
f0101252:	5f                   	pop    %edi
f0101253:	5d                   	pop    %ebp
f0101254:	c3                   	ret    

f0101255 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101255:	55                   	push   %ebp
f0101256:	89 e5                	mov    %esp,%ebp
f0101258:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010125b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101260:	eb 03                	jmp    f0101265 <strlen+0x10>
		n++;
f0101262:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101265:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101269:	75 f7                	jne    f0101262 <strlen+0xd>
		n++;
	return n;
}
f010126b:	5d                   	pop    %ebp
f010126c:	c3                   	ret    

f010126d <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010126d:	55                   	push   %ebp
f010126e:	89 e5                	mov    %esp,%ebp
f0101270:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101273:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101276:	ba 00 00 00 00       	mov    $0x0,%edx
f010127b:	eb 03                	jmp    f0101280 <strnlen+0x13>
		n++;
f010127d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101280:	39 c2                	cmp    %eax,%edx
f0101282:	74 08                	je     f010128c <strnlen+0x1f>
f0101284:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101288:	75 f3                	jne    f010127d <strnlen+0x10>
f010128a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010128c:	5d                   	pop    %ebp
f010128d:	c3                   	ret    

f010128e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010128e:	55                   	push   %ebp
f010128f:	89 e5                	mov    %esp,%ebp
f0101291:	53                   	push   %ebx
f0101292:	8b 45 08             	mov    0x8(%ebp),%eax
f0101295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101298:	89 c2                	mov    %eax,%edx
f010129a:	83 c2 01             	add    $0x1,%edx
f010129d:	83 c1 01             	add    $0x1,%ecx
f01012a0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01012a4:	88 5a ff             	mov    %bl,-0x1(%edx)
f01012a7:	84 db                	test   %bl,%bl
f01012a9:	75 ef                	jne    f010129a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01012ab:	5b                   	pop    %ebx
f01012ac:	5d                   	pop    %ebp
f01012ad:	c3                   	ret    

f01012ae <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012ae:	55                   	push   %ebp
f01012af:	89 e5                	mov    %esp,%ebp
f01012b1:	53                   	push   %ebx
f01012b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012b5:	53                   	push   %ebx
f01012b6:	e8 9a ff ff ff       	call   f0101255 <strlen>
f01012bb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01012be:	ff 75 0c             	pushl  0xc(%ebp)
f01012c1:	01 d8                	add    %ebx,%eax
f01012c3:	50                   	push   %eax
f01012c4:	e8 c5 ff ff ff       	call   f010128e <strcpy>
	return dst;
}
f01012c9:	89 d8                	mov    %ebx,%eax
f01012cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012ce:	c9                   	leave  
f01012cf:	c3                   	ret    

f01012d0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01012d0:	55                   	push   %ebp
f01012d1:	89 e5                	mov    %esp,%ebp
f01012d3:	56                   	push   %esi
f01012d4:	53                   	push   %ebx
f01012d5:	8b 75 08             	mov    0x8(%ebp),%esi
f01012d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01012db:	89 f3                	mov    %esi,%ebx
f01012dd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012e0:	89 f2                	mov    %esi,%edx
f01012e2:	eb 0f                	jmp    f01012f3 <strncpy+0x23>
		*dst++ = *src;
f01012e4:	83 c2 01             	add    $0x1,%edx
f01012e7:	0f b6 01             	movzbl (%ecx),%eax
f01012ea:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01012ed:	80 39 01             	cmpb   $0x1,(%ecx)
f01012f0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012f3:	39 da                	cmp    %ebx,%edx
f01012f5:	75 ed                	jne    f01012e4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01012f7:	89 f0                	mov    %esi,%eax
f01012f9:	5b                   	pop    %ebx
f01012fa:	5e                   	pop    %esi
f01012fb:	5d                   	pop    %ebp
f01012fc:	c3                   	ret    

f01012fd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01012fd:	55                   	push   %ebp
f01012fe:	89 e5                	mov    %esp,%ebp
f0101300:	56                   	push   %esi
f0101301:	53                   	push   %ebx
f0101302:	8b 75 08             	mov    0x8(%ebp),%esi
f0101305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101308:	8b 55 10             	mov    0x10(%ebp),%edx
f010130b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010130d:	85 d2                	test   %edx,%edx
f010130f:	74 21                	je     f0101332 <strlcpy+0x35>
f0101311:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101315:	89 f2                	mov    %esi,%edx
f0101317:	eb 09                	jmp    f0101322 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101319:	83 c2 01             	add    $0x1,%edx
f010131c:	83 c1 01             	add    $0x1,%ecx
f010131f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101322:	39 c2                	cmp    %eax,%edx
f0101324:	74 09                	je     f010132f <strlcpy+0x32>
f0101326:	0f b6 19             	movzbl (%ecx),%ebx
f0101329:	84 db                	test   %bl,%bl
f010132b:	75 ec                	jne    f0101319 <strlcpy+0x1c>
f010132d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010132f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101332:	29 f0                	sub    %esi,%eax
}
f0101334:	5b                   	pop    %ebx
f0101335:	5e                   	pop    %esi
f0101336:	5d                   	pop    %ebp
f0101337:	c3                   	ret    

f0101338 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101338:	55                   	push   %ebp
f0101339:	89 e5                	mov    %esp,%ebp
f010133b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010133e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101341:	eb 06                	jmp    f0101349 <strcmp+0x11>
		p++, q++;
f0101343:	83 c1 01             	add    $0x1,%ecx
f0101346:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101349:	0f b6 01             	movzbl (%ecx),%eax
f010134c:	84 c0                	test   %al,%al
f010134e:	74 04                	je     f0101354 <strcmp+0x1c>
f0101350:	3a 02                	cmp    (%edx),%al
f0101352:	74 ef                	je     f0101343 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101354:	0f b6 c0             	movzbl %al,%eax
f0101357:	0f b6 12             	movzbl (%edx),%edx
f010135a:	29 d0                	sub    %edx,%eax
}
f010135c:	5d                   	pop    %ebp
f010135d:	c3                   	ret    

f010135e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010135e:	55                   	push   %ebp
f010135f:	89 e5                	mov    %esp,%ebp
f0101361:	53                   	push   %ebx
f0101362:	8b 45 08             	mov    0x8(%ebp),%eax
f0101365:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101368:	89 c3                	mov    %eax,%ebx
f010136a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010136d:	eb 06                	jmp    f0101375 <strncmp+0x17>
		n--, p++, q++;
f010136f:	83 c0 01             	add    $0x1,%eax
f0101372:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101375:	39 d8                	cmp    %ebx,%eax
f0101377:	74 15                	je     f010138e <strncmp+0x30>
f0101379:	0f b6 08             	movzbl (%eax),%ecx
f010137c:	84 c9                	test   %cl,%cl
f010137e:	74 04                	je     f0101384 <strncmp+0x26>
f0101380:	3a 0a                	cmp    (%edx),%cl
f0101382:	74 eb                	je     f010136f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101384:	0f b6 00             	movzbl (%eax),%eax
f0101387:	0f b6 12             	movzbl (%edx),%edx
f010138a:	29 d0                	sub    %edx,%eax
f010138c:	eb 05                	jmp    f0101393 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010138e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101393:	5b                   	pop    %ebx
f0101394:	5d                   	pop    %ebp
f0101395:	c3                   	ret    

f0101396 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101396:	55                   	push   %ebp
f0101397:	89 e5                	mov    %esp,%ebp
f0101399:	8b 45 08             	mov    0x8(%ebp),%eax
f010139c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013a0:	eb 07                	jmp    f01013a9 <strchr+0x13>
		if (*s == c)
f01013a2:	38 ca                	cmp    %cl,%dl
f01013a4:	74 0f                	je     f01013b5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013a6:	83 c0 01             	add    $0x1,%eax
f01013a9:	0f b6 10             	movzbl (%eax),%edx
f01013ac:	84 d2                	test   %dl,%dl
f01013ae:	75 f2                	jne    f01013a2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01013b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013b5:	5d                   	pop    %ebp
f01013b6:	c3                   	ret    

f01013b7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013b7:	55                   	push   %ebp
f01013b8:	89 e5                	mov    %esp,%ebp
f01013ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01013bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013c1:	eb 03                	jmp    f01013c6 <strfind+0xf>
f01013c3:	83 c0 01             	add    $0x1,%eax
f01013c6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01013c9:	38 ca                	cmp    %cl,%dl
f01013cb:	74 04                	je     f01013d1 <strfind+0x1a>
f01013cd:	84 d2                	test   %dl,%dl
f01013cf:	75 f2                	jne    f01013c3 <strfind+0xc>
			break;
	return (char *) s;
}
f01013d1:	5d                   	pop    %ebp
f01013d2:	c3                   	ret    

f01013d3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013d3:	55                   	push   %ebp
f01013d4:	89 e5                	mov    %esp,%ebp
f01013d6:	57                   	push   %edi
f01013d7:	56                   	push   %esi
f01013d8:	53                   	push   %ebx
f01013d9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013df:	85 c9                	test   %ecx,%ecx
f01013e1:	74 36                	je     f0101419 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01013e3:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01013e9:	75 28                	jne    f0101413 <memset+0x40>
f01013eb:	f6 c1 03             	test   $0x3,%cl
f01013ee:	75 23                	jne    f0101413 <memset+0x40>
		c &= 0xFF;
f01013f0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01013f4:	89 d3                	mov    %edx,%ebx
f01013f6:	c1 e3 08             	shl    $0x8,%ebx
f01013f9:	89 d6                	mov    %edx,%esi
f01013fb:	c1 e6 18             	shl    $0x18,%esi
f01013fe:	89 d0                	mov    %edx,%eax
f0101400:	c1 e0 10             	shl    $0x10,%eax
f0101403:	09 f0                	or     %esi,%eax
f0101405:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101407:	89 d8                	mov    %ebx,%eax
f0101409:	09 d0                	or     %edx,%eax
f010140b:	c1 e9 02             	shr    $0x2,%ecx
f010140e:	fc                   	cld    
f010140f:	f3 ab                	rep stos %eax,%es:(%edi)
f0101411:	eb 06                	jmp    f0101419 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101413:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101416:	fc                   	cld    
f0101417:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101419:	89 f8                	mov    %edi,%eax
f010141b:	5b                   	pop    %ebx
f010141c:	5e                   	pop    %esi
f010141d:	5f                   	pop    %edi
f010141e:	5d                   	pop    %ebp
f010141f:	c3                   	ret    

f0101420 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101420:	55                   	push   %ebp
f0101421:	89 e5                	mov    %esp,%ebp
f0101423:	57                   	push   %edi
f0101424:	56                   	push   %esi
f0101425:	8b 45 08             	mov    0x8(%ebp),%eax
f0101428:	8b 75 0c             	mov    0xc(%ebp),%esi
f010142b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010142e:	39 c6                	cmp    %eax,%esi
f0101430:	73 35                	jae    f0101467 <memmove+0x47>
f0101432:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101435:	39 d0                	cmp    %edx,%eax
f0101437:	73 2e                	jae    f0101467 <memmove+0x47>
		s += n;
		d += n;
f0101439:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010143c:	89 d6                	mov    %edx,%esi
f010143e:	09 fe                	or     %edi,%esi
f0101440:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101446:	75 13                	jne    f010145b <memmove+0x3b>
f0101448:	f6 c1 03             	test   $0x3,%cl
f010144b:	75 0e                	jne    f010145b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010144d:	83 ef 04             	sub    $0x4,%edi
f0101450:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101453:	c1 e9 02             	shr    $0x2,%ecx
f0101456:	fd                   	std    
f0101457:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101459:	eb 09                	jmp    f0101464 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010145b:	83 ef 01             	sub    $0x1,%edi
f010145e:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101461:	fd                   	std    
f0101462:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101464:	fc                   	cld    
f0101465:	eb 1d                	jmp    f0101484 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101467:	89 f2                	mov    %esi,%edx
f0101469:	09 c2                	or     %eax,%edx
f010146b:	f6 c2 03             	test   $0x3,%dl
f010146e:	75 0f                	jne    f010147f <memmove+0x5f>
f0101470:	f6 c1 03             	test   $0x3,%cl
f0101473:	75 0a                	jne    f010147f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101475:	c1 e9 02             	shr    $0x2,%ecx
f0101478:	89 c7                	mov    %eax,%edi
f010147a:	fc                   	cld    
f010147b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010147d:	eb 05                	jmp    f0101484 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010147f:	89 c7                	mov    %eax,%edi
f0101481:	fc                   	cld    
f0101482:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101484:	5e                   	pop    %esi
f0101485:	5f                   	pop    %edi
f0101486:	5d                   	pop    %ebp
f0101487:	c3                   	ret    

f0101488 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101488:	55                   	push   %ebp
f0101489:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010148b:	ff 75 10             	pushl  0x10(%ebp)
f010148e:	ff 75 0c             	pushl  0xc(%ebp)
f0101491:	ff 75 08             	pushl  0x8(%ebp)
f0101494:	e8 87 ff ff ff       	call   f0101420 <memmove>
}
f0101499:	c9                   	leave  
f010149a:	c3                   	ret    

f010149b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010149b:	55                   	push   %ebp
f010149c:	89 e5                	mov    %esp,%ebp
f010149e:	56                   	push   %esi
f010149f:	53                   	push   %ebx
f01014a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01014a3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014a6:	89 c6                	mov    %eax,%esi
f01014a8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014ab:	eb 1a                	jmp    f01014c7 <memcmp+0x2c>
		if (*s1 != *s2)
f01014ad:	0f b6 08             	movzbl (%eax),%ecx
f01014b0:	0f b6 1a             	movzbl (%edx),%ebx
f01014b3:	38 d9                	cmp    %bl,%cl
f01014b5:	74 0a                	je     f01014c1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01014b7:	0f b6 c1             	movzbl %cl,%eax
f01014ba:	0f b6 db             	movzbl %bl,%ebx
f01014bd:	29 d8                	sub    %ebx,%eax
f01014bf:	eb 0f                	jmp    f01014d0 <memcmp+0x35>
		s1++, s2++;
f01014c1:	83 c0 01             	add    $0x1,%eax
f01014c4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014c7:	39 f0                	cmp    %esi,%eax
f01014c9:	75 e2                	jne    f01014ad <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01014cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014d0:	5b                   	pop    %ebx
f01014d1:	5e                   	pop    %esi
f01014d2:	5d                   	pop    %ebp
f01014d3:	c3                   	ret    

f01014d4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01014d4:	55                   	push   %ebp
f01014d5:	89 e5                	mov    %esp,%ebp
f01014d7:	53                   	push   %ebx
f01014d8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01014db:	89 c1                	mov    %eax,%ecx
f01014dd:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01014e0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01014e4:	eb 0a                	jmp    f01014f0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01014e6:	0f b6 10             	movzbl (%eax),%edx
f01014e9:	39 da                	cmp    %ebx,%edx
f01014eb:	74 07                	je     f01014f4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01014ed:	83 c0 01             	add    $0x1,%eax
f01014f0:	39 c8                	cmp    %ecx,%eax
f01014f2:	72 f2                	jb     f01014e6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01014f4:	5b                   	pop    %ebx
f01014f5:	5d                   	pop    %ebp
f01014f6:	c3                   	ret    

f01014f7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01014f7:	55                   	push   %ebp
f01014f8:	89 e5                	mov    %esp,%ebp
f01014fa:	57                   	push   %edi
f01014fb:	56                   	push   %esi
f01014fc:	53                   	push   %ebx
f01014fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101500:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101503:	eb 03                	jmp    f0101508 <strtol+0x11>
		s++;
f0101505:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101508:	0f b6 01             	movzbl (%ecx),%eax
f010150b:	3c 20                	cmp    $0x20,%al
f010150d:	74 f6                	je     f0101505 <strtol+0xe>
f010150f:	3c 09                	cmp    $0x9,%al
f0101511:	74 f2                	je     f0101505 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101513:	3c 2b                	cmp    $0x2b,%al
f0101515:	75 0a                	jne    f0101521 <strtol+0x2a>
		s++;
f0101517:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010151a:	bf 00 00 00 00       	mov    $0x0,%edi
f010151f:	eb 11                	jmp    f0101532 <strtol+0x3b>
f0101521:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101526:	3c 2d                	cmp    $0x2d,%al
f0101528:	75 08                	jne    f0101532 <strtol+0x3b>
		s++, neg = 1;
f010152a:	83 c1 01             	add    $0x1,%ecx
f010152d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101532:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101538:	75 15                	jne    f010154f <strtol+0x58>
f010153a:	80 39 30             	cmpb   $0x30,(%ecx)
f010153d:	75 10                	jne    f010154f <strtol+0x58>
f010153f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101543:	75 7c                	jne    f01015c1 <strtol+0xca>
		s += 2, base = 16;
f0101545:	83 c1 02             	add    $0x2,%ecx
f0101548:	bb 10 00 00 00       	mov    $0x10,%ebx
f010154d:	eb 16                	jmp    f0101565 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010154f:	85 db                	test   %ebx,%ebx
f0101551:	75 12                	jne    f0101565 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101553:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101558:	80 39 30             	cmpb   $0x30,(%ecx)
f010155b:	75 08                	jne    f0101565 <strtol+0x6e>
		s++, base = 8;
f010155d:	83 c1 01             	add    $0x1,%ecx
f0101560:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101565:	b8 00 00 00 00       	mov    $0x0,%eax
f010156a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010156d:	0f b6 11             	movzbl (%ecx),%edx
f0101570:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101573:	89 f3                	mov    %esi,%ebx
f0101575:	80 fb 09             	cmp    $0x9,%bl
f0101578:	77 08                	ja     f0101582 <strtol+0x8b>
			dig = *s - '0';
f010157a:	0f be d2             	movsbl %dl,%edx
f010157d:	83 ea 30             	sub    $0x30,%edx
f0101580:	eb 22                	jmp    f01015a4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101582:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101585:	89 f3                	mov    %esi,%ebx
f0101587:	80 fb 19             	cmp    $0x19,%bl
f010158a:	77 08                	ja     f0101594 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010158c:	0f be d2             	movsbl %dl,%edx
f010158f:	83 ea 57             	sub    $0x57,%edx
f0101592:	eb 10                	jmp    f01015a4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101594:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101597:	89 f3                	mov    %esi,%ebx
f0101599:	80 fb 19             	cmp    $0x19,%bl
f010159c:	77 16                	ja     f01015b4 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010159e:	0f be d2             	movsbl %dl,%edx
f01015a1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01015a4:	3b 55 10             	cmp    0x10(%ebp),%edx
f01015a7:	7d 0b                	jge    f01015b4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01015a9:	83 c1 01             	add    $0x1,%ecx
f01015ac:	0f af 45 10          	imul   0x10(%ebp),%eax
f01015b0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01015b2:	eb b9                	jmp    f010156d <strtol+0x76>

	if (endptr)
f01015b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015b8:	74 0d                	je     f01015c7 <strtol+0xd0>
		*endptr = (char *) s;
f01015ba:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015bd:	89 0e                	mov    %ecx,(%esi)
f01015bf:	eb 06                	jmp    f01015c7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015c1:	85 db                	test   %ebx,%ebx
f01015c3:	74 98                	je     f010155d <strtol+0x66>
f01015c5:	eb 9e                	jmp    f0101565 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01015c7:	89 c2                	mov    %eax,%edx
f01015c9:	f7 da                	neg    %edx
f01015cb:	85 ff                	test   %edi,%edi
f01015cd:	0f 45 c2             	cmovne %edx,%eax
}
f01015d0:	5b                   	pop    %ebx
f01015d1:	5e                   	pop    %esi
f01015d2:	5f                   	pop    %edi
f01015d3:	5d                   	pop    %ebp
f01015d4:	c3                   	ret    
f01015d5:	66 90                	xchg   %ax,%ax
f01015d7:	66 90                	xchg   %ax,%ax
f01015d9:	66 90                	xchg   %ax,%ax
f01015db:	66 90                	xchg   %ax,%ax
f01015dd:	66 90                	xchg   %ax,%ax
f01015df:	90                   	nop

f01015e0 <__udivdi3>:
f01015e0:	55                   	push   %ebp
f01015e1:	57                   	push   %edi
f01015e2:	56                   	push   %esi
f01015e3:	53                   	push   %ebx
f01015e4:	83 ec 1c             	sub    $0x1c,%esp
f01015e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01015eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01015ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01015f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01015f7:	85 f6                	test   %esi,%esi
f01015f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01015fd:	89 ca                	mov    %ecx,%edx
f01015ff:	89 f8                	mov    %edi,%eax
f0101601:	75 3d                	jne    f0101640 <__udivdi3+0x60>
f0101603:	39 cf                	cmp    %ecx,%edi
f0101605:	0f 87 c5 00 00 00    	ja     f01016d0 <__udivdi3+0xf0>
f010160b:	85 ff                	test   %edi,%edi
f010160d:	89 fd                	mov    %edi,%ebp
f010160f:	75 0b                	jne    f010161c <__udivdi3+0x3c>
f0101611:	b8 01 00 00 00       	mov    $0x1,%eax
f0101616:	31 d2                	xor    %edx,%edx
f0101618:	f7 f7                	div    %edi
f010161a:	89 c5                	mov    %eax,%ebp
f010161c:	89 c8                	mov    %ecx,%eax
f010161e:	31 d2                	xor    %edx,%edx
f0101620:	f7 f5                	div    %ebp
f0101622:	89 c1                	mov    %eax,%ecx
f0101624:	89 d8                	mov    %ebx,%eax
f0101626:	89 cf                	mov    %ecx,%edi
f0101628:	f7 f5                	div    %ebp
f010162a:	89 c3                	mov    %eax,%ebx
f010162c:	89 d8                	mov    %ebx,%eax
f010162e:	89 fa                	mov    %edi,%edx
f0101630:	83 c4 1c             	add    $0x1c,%esp
f0101633:	5b                   	pop    %ebx
f0101634:	5e                   	pop    %esi
f0101635:	5f                   	pop    %edi
f0101636:	5d                   	pop    %ebp
f0101637:	c3                   	ret    
f0101638:	90                   	nop
f0101639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101640:	39 ce                	cmp    %ecx,%esi
f0101642:	77 74                	ja     f01016b8 <__udivdi3+0xd8>
f0101644:	0f bd fe             	bsr    %esi,%edi
f0101647:	83 f7 1f             	xor    $0x1f,%edi
f010164a:	0f 84 98 00 00 00    	je     f01016e8 <__udivdi3+0x108>
f0101650:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101655:	89 f9                	mov    %edi,%ecx
f0101657:	89 c5                	mov    %eax,%ebp
f0101659:	29 fb                	sub    %edi,%ebx
f010165b:	d3 e6                	shl    %cl,%esi
f010165d:	89 d9                	mov    %ebx,%ecx
f010165f:	d3 ed                	shr    %cl,%ebp
f0101661:	89 f9                	mov    %edi,%ecx
f0101663:	d3 e0                	shl    %cl,%eax
f0101665:	09 ee                	or     %ebp,%esi
f0101667:	89 d9                	mov    %ebx,%ecx
f0101669:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010166d:	89 d5                	mov    %edx,%ebp
f010166f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101673:	d3 ed                	shr    %cl,%ebp
f0101675:	89 f9                	mov    %edi,%ecx
f0101677:	d3 e2                	shl    %cl,%edx
f0101679:	89 d9                	mov    %ebx,%ecx
f010167b:	d3 e8                	shr    %cl,%eax
f010167d:	09 c2                	or     %eax,%edx
f010167f:	89 d0                	mov    %edx,%eax
f0101681:	89 ea                	mov    %ebp,%edx
f0101683:	f7 f6                	div    %esi
f0101685:	89 d5                	mov    %edx,%ebp
f0101687:	89 c3                	mov    %eax,%ebx
f0101689:	f7 64 24 0c          	mull   0xc(%esp)
f010168d:	39 d5                	cmp    %edx,%ebp
f010168f:	72 10                	jb     f01016a1 <__udivdi3+0xc1>
f0101691:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101695:	89 f9                	mov    %edi,%ecx
f0101697:	d3 e6                	shl    %cl,%esi
f0101699:	39 c6                	cmp    %eax,%esi
f010169b:	73 07                	jae    f01016a4 <__udivdi3+0xc4>
f010169d:	39 d5                	cmp    %edx,%ebp
f010169f:	75 03                	jne    f01016a4 <__udivdi3+0xc4>
f01016a1:	83 eb 01             	sub    $0x1,%ebx
f01016a4:	31 ff                	xor    %edi,%edi
f01016a6:	89 d8                	mov    %ebx,%eax
f01016a8:	89 fa                	mov    %edi,%edx
f01016aa:	83 c4 1c             	add    $0x1c,%esp
f01016ad:	5b                   	pop    %ebx
f01016ae:	5e                   	pop    %esi
f01016af:	5f                   	pop    %edi
f01016b0:	5d                   	pop    %ebp
f01016b1:	c3                   	ret    
f01016b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01016b8:	31 ff                	xor    %edi,%edi
f01016ba:	31 db                	xor    %ebx,%ebx
f01016bc:	89 d8                	mov    %ebx,%eax
f01016be:	89 fa                	mov    %edi,%edx
f01016c0:	83 c4 1c             	add    $0x1c,%esp
f01016c3:	5b                   	pop    %ebx
f01016c4:	5e                   	pop    %esi
f01016c5:	5f                   	pop    %edi
f01016c6:	5d                   	pop    %ebp
f01016c7:	c3                   	ret    
f01016c8:	90                   	nop
f01016c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016d0:	89 d8                	mov    %ebx,%eax
f01016d2:	f7 f7                	div    %edi
f01016d4:	31 ff                	xor    %edi,%edi
f01016d6:	89 c3                	mov    %eax,%ebx
f01016d8:	89 d8                	mov    %ebx,%eax
f01016da:	89 fa                	mov    %edi,%edx
f01016dc:	83 c4 1c             	add    $0x1c,%esp
f01016df:	5b                   	pop    %ebx
f01016e0:	5e                   	pop    %esi
f01016e1:	5f                   	pop    %edi
f01016e2:	5d                   	pop    %ebp
f01016e3:	c3                   	ret    
f01016e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016e8:	39 ce                	cmp    %ecx,%esi
f01016ea:	72 0c                	jb     f01016f8 <__udivdi3+0x118>
f01016ec:	31 db                	xor    %ebx,%ebx
f01016ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01016f2:	0f 87 34 ff ff ff    	ja     f010162c <__udivdi3+0x4c>
f01016f8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01016fd:	e9 2a ff ff ff       	jmp    f010162c <__udivdi3+0x4c>
f0101702:	66 90                	xchg   %ax,%ax
f0101704:	66 90                	xchg   %ax,%ax
f0101706:	66 90                	xchg   %ax,%ax
f0101708:	66 90                	xchg   %ax,%ax
f010170a:	66 90                	xchg   %ax,%ax
f010170c:	66 90                	xchg   %ax,%ax
f010170e:	66 90                	xchg   %ax,%ax

f0101710 <__umoddi3>:
f0101710:	55                   	push   %ebp
f0101711:	57                   	push   %edi
f0101712:	56                   	push   %esi
f0101713:	53                   	push   %ebx
f0101714:	83 ec 1c             	sub    $0x1c,%esp
f0101717:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010171b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010171f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101723:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101727:	85 d2                	test   %edx,%edx
f0101729:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010172d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101731:	89 f3                	mov    %esi,%ebx
f0101733:	89 3c 24             	mov    %edi,(%esp)
f0101736:	89 74 24 04          	mov    %esi,0x4(%esp)
f010173a:	75 1c                	jne    f0101758 <__umoddi3+0x48>
f010173c:	39 f7                	cmp    %esi,%edi
f010173e:	76 50                	jbe    f0101790 <__umoddi3+0x80>
f0101740:	89 c8                	mov    %ecx,%eax
f0101742:	89 f2                	mov    %esi,%edx
f0101744:	f7 f7                	div    %edi
f0101746:	89 d0                	mov    %edx,%eax
f0101748:	31 d2                	xor    %edx,%edx
f010174a:	83 c4 1c             	add    $0x1c,%esp
f010174d:	5b                   	pop    %ebx
f010174e:	5e                   	pop    %esi
f010174f:	5f                   	pop    %edi
f0101750:	5d                   	pop    %ebp
f0101751:	c3                   	ret    
f0101752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101758:	39 f2                	cmp    %esi,%edx
f010175a:	89 d0                	mov    %edx,%eax
f010175c:	77 52                	ja     f01017b0 <__umoddi3+0xa0>
f010175e:	0f bd ea             	bsr    %edx,%ebp
f0101761:	83 f5 1f             	xor    $0x1f,%ebp
f0101764:	75 5a                	jne    f01017c0 <__umoddi3+0xb0>
f0101766:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010176a:	0f 82 e0 00 00 00    	jb     f0101850 <__umoddi3+0x140>
f0101770:	39 0c 24             	cmp    %ecx,(%esp)
f0101773:	0f 86 d7 00 00 00    	jbe    f0101850 <__umoddi3+0x140>
f0101779:	8b 44 24 08          	mov    0x8(%esp),%eax
f010177d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101781:	83 c4 1c             	add    $0x1c,%esp
f0101784:	5b                   	pop    %ebx
f0101785:	5e                   	pop    %esi
f0101786:	5f                   	pop    %edi
f0101787:	5d                   	pop    %ebp
f0101788:	c3                   	ret    
f0101789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101790:	85 ff                	test   %edi,%edi
f0101792:	89 fd                	mov    %edi,%ebp
f0101794:	75 0b                	jne    f01017a1 <__umoddi3+0x91>
f0101796:	b8 01 00 00 00       	mov    $0x1,%eax
f010179b:	31 d2                	xor    %edx,%edx
f010179d:	f7 f7                	div    %edi
f010179f:	89 c5                	mov    %eax,%ebp
f01017a1:	89 f0                	mov    %esi,%eax
f01017a3:	31 d2                	xor    %edx,%edx
f01017a5:	f7 f5                	div    %ebp
f01017a7:	89 c8                	mov    %ecx,%eax
f01017a9:	f7 f5                	div    %ebp
f01017ab:	89 d0                	mov    %edx,%eax
f01017ad:	eb 99                	jmp    f0101748 <__umoddi3+0x38>
f01017af:	90                   	nop
f01017b0:	89 c8                	mov    %ecx,%eax
f01017b2:	89 f2                	mov    %esi,%edx
f01017b4:	83 c4 1c             	add    $0x1c,%esp
f01017b7:	5b                   	pop    %ebx
f01017b8:	5e                   	pop    %esi
f01017b9:	5f                   	pop    %edi
f01017ba:	5d                   	pop    %ebp
f01017bb:	c3                   	ret    
f01017bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017c0:	8b 34 24             	mov    (%esp),%esi
f01017c3:	bf 20 00 00 00       	mov    $0x20,%edi
f01017c8:	89 e9                	mov    %ebp,%ecx
f01017ca:	29 ef                	sub    %ebp,%edi
f01017cc:	d3 e0                	shl    %cl,%eax
f01017ce:	89 f9                	mov    %edi,%ecx
f01017d0:	89 f2                	mov    %esi,%edx
f01017d2:	d3 ea                	shr    %cl,%edx
f01017d4:	89 e9                	mov    %ebp,%ecx
f01017d6:	09 c2                	or     %eax,%edx
f01017d8:	89 d8                	mov    %ebx,%eax
f01017da:	89 14 24             	mov    %edx,(%esp)
f01017dd:	89 f2                	mov    %esi,%edx
f01017df:	d3 e2                	shl    %cl,%edx
f01017e1:	89 f9                	mov    %edi,%ecx
f01017e3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01017e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01017eb:	d3 e8                	shr    %cl,%eax
f01017ed:	89 e9                	mov    %ebp,%ecx
f01017ef:	89 c6                	mov    %eax,%esi
f01017f1:	d3 e3                	shl    %cl,%ebx
f01017f3:	89 f9                	mov    %edi,%ecx
f01017f5:	89 d0                	mov    %edx,%eax
f01017f7:	d3 e8                	shr    %cl,%eax
f01017f9:	89 e9                	mov    %ebp,%ecx
f01017fb:	09 d8                	or     %ebx,%eax
f01017fd:	89 d3                	mov    %edx,%ebx
f01017ff:	89 f2                	mov    %esi,%edx
f0101801:	f7 34 24             	divl   (%esp)
f0101804:	89 d6                	mov    %edx,%esi
f0101806:	d3 e3                	shl    %cl,%ebx
f0101808:	f7 64 24 04          	mull   0x4(%esp)
f010180c:	39 d6                	cmp    %edx,%esi
f010180e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101812:	89 d1                	mov    %edx,%ecx
f0101814:	89 c3                	mov    %eax,%ebx
f0101816:	72 08                	jb     f0101820 <__umoddi3+0x110>
f0101818:	75 11                	jne    f010182b <__umoddi3+0x11b>
f010181a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010181e:	73 0b                	jae    f010182b <__umoddi3+0x11b>
f0101820:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101824:	1b 14 24             	sbb    (%esp),%edx
f0101827:	89 d1                	mov    %edx,%ecx
f0101829:	89 c3                	mov    %eax,%ebx
f010182b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010182f:	29 da                	sub    %ebx,%edx
f0101831:	19 ce                	sbb    %ecx,%esi
f0101833:	89 f9                	mov    %edi,%ecx
f0101835:	89 f0                	mov    %esi,%eax
f0101837:	d3 e0                	shl    %cl,%eax
f0101839:	89 e9                	mov    %ebp,%ecx
f010183b:	d3 ea                	shr    %cl,%edx
f010183d:	89 e9                	mov    %ebp,%ecx
f010183f:	d3 ee                	shr    %cl,%esi
f0101841:	09 d0                	or     %edx,%eax
f0101843:	89 f2                	mov    %esi,%edx
f0101845:	83 c4 1c             	add    $0x1c,%esp
f0101848:	5b                   	pop    %ebx
f0101849:	5e                   	pop    %esi
f010184a:	5f                   	pop    %edi
f010184b:	5d                   	pop    %ebp
f010184c:	c3                   	ret    
f010184d:	8d 76 00             	lea    0x0(%esi),%esi
f0101850:	29 f9                	sub    %edi,%ecx
f0101852:	19 d6                	sbb    %edx,%esi
f0101854:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101858:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010185c:	e9 18 ff ff ff       	jmp    f0101779 <__umoddi3+0x69>
