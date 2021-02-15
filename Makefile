# Makefile contributed by jtsiomb

src = heart.asm

.PHONY: all
all: heart.img heart.com

heart.img: $(src)
	nasm -f bin -o $@ $(src)

heart.com: $(src)
	nasm -f bin -o $@ -Dcom_file=1 $(src)

.PHONY: clean
clean:
	$(RM) heart.img heart.com

.PHONY: rundosbox
rundosbox: heart.com
	dosbox $<

.PHONY: runqemu
runqemu: heart.img
	qemu-system-i386 -fda heart.img
