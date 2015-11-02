
# ARMGNU = /opt/gnuarm/bin/arm-none-eabi
# ARMGNU = /usr/local/gcc-arm-none-eabi-4_9-2014q4/bin/arm-none-eabi
# ARMGNU = /usr/local/gcc-arm-none-eabi-4_8-2014q3/bin/arm-none-eabi
ARMGNU = /usr/local/gcc-arm-none-eabi-4_7-2013q2/bin/arm-none-eabi
# ARMGNU = /Users/yuri/yagarto/yagarto-4.7.2/bin/arm-none-eabi

#AOPS = --warn --fatal-warnings -mcpu=arm1176jzf-s -march=armv6  -mfpu=vfp
AOPS = --warn --fatal-warnings -mcpu=arm1176jzf-s

COPS = -Wall -nostartfiles -ffreestanding

#CFLAGS = -mcpu=arm1176jzf-s -mtune=arm1176jzf-s -mhard-float -mfpu=vfp -O0 -ggdb -g
#CFLAGS = -O2 -g3 -mfpu=vfp -mfloat-abi=hard -march=armv6zk -mtune=arm1176jzf-s -fno-exceptions -fno-builtin
#CFLAGS = -O2 -g3 -mfloat-abi=softfp -march=armv6zk -mtune=arm1176jzf-s -fno-exceptions -ffreestanding
#CFLAGS = -O2 -g3 -mfpu=vfp -mfloat-abi=hard -march=armv6zk -mtune=arm1176jzf-s -fno-exceptions -ffreestanding
#CFLAGS = -O0 -ggdb -g -mfloat-abi=softfp -mtune=arm1176jzf-s -mcpu=arm1176jzf-s
CFLAGS = -O0 -ggdb -g -mfloat-abi=soft -mtune=arm1176jzf-s -mcpu=arm1176jzf-s

INCDIR = /Users/yuri/git/mruby/include/
ULIBDIR = /Users/yuri/git/mruby/build/rs/lib

#LIB = -L /opt/gnuarm/arm-none-eabi/lib/fpu/ -L/opt/gnuarm/lib/gcc/arm-none-eabi/4.8.1/fpu/
#LIB = -L /usr/local/gcc-arm-none-eabi-4_9-2014q4/lib/gcc/arm-none-eabi/4.9.3/fpu -L/usr/local/gcc-arm-none-eabi-4_9-2014q4/arm-none-eabi/lib/fpu
#LIB = -L /usr/local/gcc-arm-none-eabi-4_8-2014q3/lib/gcc/arm-none-eabi/4.8.4/fpu -L/usr/local/gcc-arm-none-eabi-4_8-2014q3/arm-none-eabi/lib/fpu
#LIB = -L /usr/local/gcc-arm-none-eabi-4_7-2013q2/lib/gcc/arm-none-eabi/4.7.4/fpu -L/usr/local/gcc-arm-none-eabi-4_7-2013q2/arm-none-eabi/lib/fpu
LIB = -L /usr/local/gcc-arm-none-eabi-4_7-2013q2/lib/gcc/arm-none-eabi/4.7.4 -L/usr/local/gcc-arm-none-eabi-4_7-2013q2/arm-none-eabi/lib
#LIB = -L /Users/yuri/yagarto/yagarto-4.7.2/lib/gcc/arm-none-eabi/4.7.2 -L/Users/yuri/yagarto/yagarto-4.7.2/arm-none-eabi/lib
#LIB = -L /Users/yuri/yagarto/yagarto-4.7.2/lib/gcc/arm-none-eabi/4.7.2 -L/Users/yuri/yagarto/yagarto-4.7.2/arm-none-eabi/lib

ULIBS = -lmruby

gcc : kernel.img demo.hex demo.bin demo.elf

all : gcc

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.bc
	rm -f *.map

vectors.o : vectors.s
	$(ARMGNU)-as $(AOPS) vectors.s -o vectors.o

demo.o : demo.c
	$(ARMGNU)-gcc $(COPS) $(CFLAGS) -I $(INCDIR) -c demo.c -o demo.o

syscalls.o : syscalls.c
	$(ARMGNU)-gcc $(COPS) $(CFLAGS) -c syscalls.c -o syscalls.o
	
demo.elf : memmap vectors.o demo.o syscalls.o
	$(ARMGNU)-ld vectors.o demo.o syscalls.o -Map=demo.map -T memmap -o demo.elf -L $(ULIBDIR) $(ULIBS) $(LIB) -lc -lm -lgcc 
#	$(ARMGNU)-gcc $(COPS) $(CFLAGS) vectors.o demo.o syscalls.o -T memmap -o demo.elf -L $(ULIBDIR) $(ULIBS) $(LIB) -lc -lm -lgcc 
	$(ARMGNU)-objdump -D demo.elf > demo.list

demo.bin : demo.elf
	$(ARMGNU)-objcopy demo.elf -O binary demo.bin

demo.hex : demo.elf
	$(ARMGNU)-objcopy demo.elf -O ihex demo.hex

kernel.img : demo.bin
	cp demo.bin kernel.img

