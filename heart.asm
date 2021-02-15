	;
	; Draw a heart using a heart curve equation
	; (uses only integer arithmetic)
	;
	; by Oscar Toledo G.
	; http://nanochess.org/
	;
	; Creation date: Feb/14/2021.
	;

	cpu 8086

    %ifdef com_file
	org 0x0100s
    %else
	org 0x7c00
    %endif

	;
	; Start of the program
	;
start:
	mov ax,0x0013	; Graphics mode 320x200x256 colors
	int 0x10	; Setup video mode
	mov ax,0xa000	; Point to video memory
	mov ds,ax
animate:
	mov cx,0x007f	; t = 127 (where pi * 2 is 128)
main_loop:
	mov ax,cx	; sin(t)
	call get_sin
	mov bx,ax
	imul bx		; ^2
	call defrac
	imul bx		; ^3
	call defrac
	mov bx,40	; Expand to fill screen horizontally
	imul bx
	call defrac
	add ax,160	; Center horizontally
	push ax		; Save x-coord in stack.

	mov al,4	; cos(4 * t)
	mul cl
	call get_cos
	push ax
	mov al,3	; cos(3 * t)
	mul cl
	call get_cos
	shl ax,1	; * 2
	push ax
	mov al,2	; cos(2 * t)
	mul cl
	call get_cos
	mov bx,5	; * 5
	imul bx
	push ax
	mov ax,cx
	call get_cos	; cos(t) * 13
	mov bx,13
	imul bx
	pop bx
	sub ax,bx	; 13*cos(t) - 5*cos(2*t)
	pop bx
	sub ax,bx	; 13*cos(t) - 5*cos(2*t) - 2*cos(3*t)
	pop bx
	sub ax,bx	; 13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t)
	neg ax
	mov bx,3	; Expand to fill screen vertically
	imul bx
	call defrac
	add ax,100	; Center vertically
	mov bx,320	; Get row pixel address
	mul bx
	pop bx
	add bx,ax	; Add column pixel address
	mov byte [bx],0x0c	; Paint a red pixel

	loop main_loop

	mov ah,0x00	; Wait for a key
	int 0x16
	mov ax,0x0002	; Restore text mode
	int 0x10
	int 0x20	; Exit

	;
	; Remove fraction
	;
defrac:
	mov al,ah
	mov ah,dl
	ret

	;
	; Get cosine
	; Input: al = angle (0-127)
	; Output: ax = 8.8 fraction
	;
get_cos:
        add al,32       ; Add 90 degrees to get cosine
	;
	; Get sine
	; Input: al = angle (0-127)
	; Output: ax = 8.8 fraction
	;
get_sin:
        test al,64      ; Angle >= 180 degrees?
        pushf
        test al,32      ; Angle 90-179 or 270-359 degrees?
        je .2
        xor al,31       ; Invert bits (reduces table)
.2:
        and ax,31       ; Only 90 degrees in table
        mov bx,sin_table
        cs xlat         ; Get fraction
        popf
        je .1           ; Jump if angle less than 180
        neg ax          ; Else negate result
.1:
        ret

	;
	; Sine table (0.8 format)
	;
	; 32 bytes are 90 degrees.
	;
sin_table:
	db 0x00,0x09,0x16,0x24,0x31,0x3e,0x47,0x53
	db 0x60,0x6c,0x78,0x80,0x8b,0x96,0xa1,0xab
	db 0xb5,0xbb,0xc4,0xcc,0xd4,0xdb,0xe0,0xe6
	db 0xec,0xf1,0xf5,0xf7,0xfa,0xfd,0xff,0xff

    %ifdef com_file
    %else
	times 510-($-$$) db 0x4f
	db 0x55,0xaa	; Make it a bootable sector
    %endif
