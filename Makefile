
# project name
NAME  = SumoRobot

# fuses
# internal RC osc
#LFUSE=0xe2
# External 3.0-8.0MHz xtal
#LFUSE=0xFD
#HFUSE=0xde

# m32
#LFUSE=0xa4
#HFUSE=0xd9
#EFUSE=0x01
#LOCK=0xff

# m1284p

#arduino:
LFUSE=0xFF
HFUSE=0xDE
EFUSE=0x05

LOCK=0x3f

# programmer

#arduino:
AVRDUDE  = avrdude -pm328p -c arduino -P /dev/tty.usbserial-AK05ASRD -b57600

TERMINAL = minicom -D /dev/tty.usbserial-AK05ASRD -b57600

# used processor

#arduino:
MCU  = -mmcu=atmega328p

#arduino:
FREQ = 16000000ul


# set library path, and save some typing
LIBS	= lib

# all source files
SRCS += main.c
SRCS += $(LIBS)/irsensor.c
SRCS += $(LIBS)/avr_printf.c

.PHONY: all clean install setfuse getfuse terminal upload avrdude simulate debug

# mcu selection
CFLAGS += $(MCU)

CFLAGS += -DDEBUG
# enable warnings
#CFLAGS += -Wa,--gstabs
#CFLAGS += -DSIMULATE
CFLAGS += -Wall

CFLAGS += -Wcast-align
CFLAGS += -Wcast-qual
CFLAGS += -Wimplicit
CFLAGS += -Wpointer-arith
CFLAGS += -Wswitch
CFLAGS += -Wredundant-decls
CFLAGS += -Wreturn-type
CFLAGS += -Wshadow
CFLAGS += -Wno-unused
CFLAGS += -Wstrict-prototypes
#CFLAGS += -Wmissing-declarations
#CFLAGS += -Wmissing-prototypes
CFLAGS += -Wnested-externs


# include path
CFLAGS += -I$(LIBS)

# cpu frequency
CFLAGS += -DCPU_FREQ=$(FREQ) -DF_CPU=CPU_FREQ

# linker flags
LDFLAGS = $(MCU) -Wl,-M,-u,vfprintf -lprintf_flt -lm

# compiler
CC = avr-gcc
LD = avr-gcc

# output files, derived from name
ELF = out/$(NAME).elf
HEX = out/$(NAME).hex
RAW = out/$(NAME).raw
MAP = out/$(NAME).map
LST = out/$(NAME).lst
EEP = out/$(NAME).eep

# removed sections from hex file
RS = --remove-section=.eeprom

# keep this target first!
all: obj out $(HEX) $(RAW) $(EEP) $(LST)

DEPEND = $(CC) -E -MM $(CFLAGS) $(SRCS) | sed -e 's/^\(.*\):/obj\/\1:/' > .depend

depend:
	$(DEPEND)

# check if depend exists
ifneq ($(shell ls -a | grep ^\.depend$),.depend)
 $(shell $(DEPEND))
endif

# load our dependencies
-include .depend

# fetch all DEPS from the depend file
DEPS = $(shell cut -f2 -d: .depend | sed -e "s/\\\\//g")

# create objs from srcs (../../fu/ck.c -> obj/ck.o)
OBJS = $(addprefix obj/,$(notdir $(patsubst %.S,%.o,$(SRCS:.c=.o))))

#
# rest of file is targets
#

obj:
	mkdir -p obj

out:
	mkdir -p out

obj/%.o:
	$(CC) $(CFLAGS) -c $< -o $@

$(ELF): $(OBJS)
	$(LD) $(OBJS) -o $(ELF) $(CFLAGS) $(LDFLAGS) > $(MAP)
	avr-size -A $(ELF)
	@chmod 644 $(ELF)

$(HEX): $(ELF)
	avr-objcopy $(RS) --output-target=ihex $(ELF) $(HEX)

$(RAW): $(ELF)
	avr-objcopy $(RS) --output-target=binary $(ELF) $(RAW)
	@chmod 644 $(RAW)

$(EEP): $(ELF)
	avr-objcopy --only-section=.eeprom --output-target=binary $(ELF) $(EEP)
	@chmod 644 $(EEP)

$(LST): $(ELF)
	avr-objdump -h -S $(ELF) > $(LST)

clean:
	rm -rfv obj out 

install: $(HEX)
	$(AVRDUDE) -B 10 -e -U flash:w:$(HEX) -U lock:w:$(LOCK):m

setfuse:
	$(AVRDUDE) -B 10 -e -U hfuse:w:$(HFUSE):m -U lfuse:w:$(LFUSE):m

getfuse:
	$(AVRDUDE) -B 10 -U hfuse:r:hfuse:r -U lfuse:r:lfuse:r -U lock:r:lock:r
	@echo -n hfuse:
	@hexdump -x hfuse | grep 0000000 | cut -f5 -d " " 
	@echo -n efuse:
	@hexdump -x efuse | grep 0000000 | cut -f5 -d " " 
	@echo -n lfuse:
	@hexdump -x lfuse | grep 0000000 | cut -f5 -d " "
	@echo -n lock:
	@hexdump -x lock | grep 0000000 | cut -f5 -d " "
	@rm hfuse lfuse lock

terminal:
	$(TERMINAL)

avrdude:
ifeq ($(CMD),)
	$(AVRDUDE) -t -F
else
	echo $(CMD) | $(AVRDUDE) -t -F
endif

simulate:
	make -Csimulator run

debug: $(ELF)
	echo "target remote localhost:1212" > commands.dbg
	echo "load" >> commands.dbg
	avr-gdbtui -x commands.dbg $< ; rm -f commands.dbg

