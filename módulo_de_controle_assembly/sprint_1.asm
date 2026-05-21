section .data

	charged_msg_1 db '% de bateria -> ', 0
	charged_msg_1_len equ $ - charged_msg_1

	charged_msg_2 db '% de bateria ', 0
	charged_msg_2_len equ $ - charged_msg_2 ; 13 chars long excluding null terminator
	
	charging_msg db 'carregando... ',0      ; 14 chars long excluding null terminator
	charging_msg_len equ $ - charging_msg

	stop_msg db 'A recarga do Veiculo terminou com sucesso',0Ah, 0
	stop_msg_len equ $ - stop_msg

	error_msg_tempe db 'ERRO: a temperatura excedeu o limite permitdo',0Ah, 0
	error_msg_tempe_len equ $ - error_msg_tempe

	error_msg_corr db 'ERRO: a corrente excedeu o limite permitdo',0Ah, 0
	error_msg_corr_len equ $ - error_msg_corr


	msg db 'Por favor digite seu ID: ', 0Ah, 0
	msg_len equ $ - msg

	auth_fail_msg db 'Falha ao autenticar o usuario! Tente novamente mais tarde.', 0Ah, 0
	auth_fail_msg_len equ $ - auth_fail_msg

	wrong_id_msg db 'ID errado, por favor tente novamente!',0Ah, 0
	wrong_id_msg_len equ $ - wrong_id_msg
	
	valid_id_msg db 'ID correto, a carregar o veiculo...',0Ah, 0
	valid_id_msg_len equ $ - valid_id_msg
	
	valid_id db '1', 0

	max_tries	db  5
	;carriage_ret db 13

	; equ = basically a #define equivalent i suppose
	carriage_ret			equ 13
	limit_battery      		equ 100
	limit_temperature      	equ 45
	limit_current     		equ 32

	timeval:
	  tv_sec  dd 0
	  tv_nsec dd 0

	buffer:    times 3 db 0

section .bss

	charging_msg_buffer		resb 28

	previous_battery 		resb 1
	sensor_battery			resb 1     		
	sensor_temperature		resb 1      
	sensor_current			resb 1  		
	
	ustr	resb 2 ; to bytes cuz i want to null terminate it

section .text

; exit the program
exit: ; syscall to exit the program with exit status 0
	
	mov ebx, 0
	mov eax, 1
	int 80h
	
	ret

; sleeps the program
sleep:

	mov dword [tv_nsec], 0
	mov eax, 162
	mov ebx, timeval
	mov ecx, timeval
	int 0x80

	ret

; reads from stdin
read:

	mov eax, 3          ; <- syscall to read 
	mov ebx, 0          ; <- read from stdin
	int 80h             

	ret

; prints on screen
print:
	mov eax, 4
	mov ebx, 1
	int 80h

	ret

; check the id that the user inputed
check_id:

	check_id_loop:
		
		; call read and pass our string and lenght	
		mov edx, 2 	  				; <- maximum lenght to read from stdin
		mov ecx, ustr 				; <- ecx, where to put the contents from stdin
		call read
		mov byte [ecx + eax - 1], 0 ; <- null terminate the ustr by replacing \n with 0

		; if syscall didnt read anything, retry
		cmp eax, 0 
		jz check_id_loop

		; put valid id into a register so we can compare the user input to the valid id
		; if id is valid jmp tp valid and ret
		mov al, [valid_id]
		cmp byte [ecx], al
		jz valid 

		; if id was not valid:

		; print a message warning the user that the id was not valid
		xor al, al
		mov edx, wrong_id_msg_len ; <- copy the lenght of the str to edx
		mov ecx, wrong_id_msg 	  ; <- and pass ecx the actual string
		call print

		; decrease the counter
		mov al, [max_tries]
		dec al
		mov [max_tries], al
		
		; if counter is different than 0
		; jmp to the start of the loop and let the user try again
		cmp al, 0 
		jne check_id_loop

		; if the counter is 0, it means the user
		; has ran out of chances to try to authenticate
		; so we print a message warning the user of that, and then quit the program
		mov edx, auth_fail_msg_len
		mov ecx, auth_fail_msg
		call print

		call exit
	
	valid: 

	ret

; converts numbers to acii and prints them
convert_to_acii:

    mov bl, 10                 ; <- has to be 10 for this trick to work
    xor ah, ah                 
    xor cx, cx                 ; <- clear otherwise we blow up
    
	loop_push_stack:    
		div bl    	           ; <- divides ax by bl
		push ax    			   ; <- push the leftover into the stack
		inc cx    	           ; <- increment the counter
		xor ah, ah    	       ; <- clear previous leftover otherwise this will blow up
		cmp al, 0    	       ; <- compare the result of the division to 0
		jne loop_push_stack    ; <- if its not zero, continue
		
  
    mov ebx, buffer   		   ; <- load our buffer into ebx
    mov si, cx                 ; <- save our counte (16-bit) for printing
    
	loop_pop_stack:    
		pop ax    			   ; <- pop our data back from the stack
		mov dl, ah             ; <- remainder (digit) in AH -> DL    
		add dl, 48             ; <- convert to ascii    
		mov [ebx], dl    	   ; <- puts the converted digit into the buffer at the ebx position
		inc ebx    		       ; <- increment ebx
		dec cx                 ; <- decrement the loop counter
		jne loop_pop_stack     ; <- checks the zero flag of the instruction before it, if not equal (to zero), continue
		
	; si has the lenght of the buffer
    movzx edx, si              ; <- (movzx = move zero extended) movzx si into edx (has to be movzx cuz different sized regs)
    mov ecx, buffer    		   ; <- move our buffer to ecx so we can print it
    call print
    
    ret
	
section .text

global _start

_start:

	; prints a message prompting the user to type in their id 
	mov edx, msg_len 
	mov ecx, msg 
	call print

	; check the id that the user iputed
	call check_id

	; if valid, warns the user of so
	mov edx, valid_id_msg_len
	mov ecx, valid_id_msg
	call print

	; simulate reading the sensors once the charge is plugged in the vehicle
	setup_sensors:

		; Sensor 1: battery (0% - 100%)
		mov al, 55 ; example: 55% battery 
		mov [sensor_battery], al
		mov [previous_battery],al 
		
		; Sensor 2: temperature (0°C - 60°C)
		mov al, 35 ; example: 35°C
		mov [sensor_temperature], al

		; Sensor 3: current (0A - 40A)
		mov al, 16 ; example: 16A
		mov [sensor_current], al

		
	; check the sensors so we know when to stop
	; charging OR know when there is a problem
	check_sensors:

		; compare the vehicle's battery level to 
		; the max charging capacity of the station
		mov al, limit_battery
		cmp al, [sensor_battery]
		je stop
		jb stop

		; compare the temperature of the sensor
		; to the limit temperature
		mov al, limit_temperature
		cmp al, [sensor_temperature]
		jb error_temperature

		; compare the current of the sensor
		; to the limit current
		mov al, limit_current
		cmp al, [sensor_current]
		jb error_current

	mov edi, charging_msg_buffer

	mov esi, charged_msg_2
	mov ecx, charged_msg_2_len - 1
	rep movsb

	mov esi, charging_msg
	mov ecx, charging_msg_len - 1
	rep movsb
	
	; here edi still points to the next free byte into the buffer, so write carriage return into it
	mov byte [edi], carriage_ret ; < carriage_ret equ 13

	; simulate the station charging the user's vehicle
	charge:

		; prints the value of the battery as it is being charged
		xor ax, ax
		movzx ax, byte [sensor_battery]
		call convert_to_acii

		; prints the rest of the message, making a little charging "animation"
		mov ecx, charging_msg_buffer
		mov edx, (charging_msg_len - 1) + (charged_msg_2_len - 1) + 1 ; the -1s are for accounting for the removal of the null terminators, the + 1
		                                                              ; is to account for the addition of the carriage return char at the end
		call print
		
		; "charge" the user's vehicle
		inc [sensor_battery]
 
		; sleeps the thread to simulate the vehicle charging in a more "realistic" way
		mov dword [tv_sec], 1
		call sleep
	
		jmp check_sensors

	; handles the exit of the program if everything
	; occurred normally			
	stop:
	
		xor ax, ax
		movzx ax, byte [previous_battery]
		call convert_to_acii
		
		; print some nice message along with the previous message
		mov edx, charged_msg_1_len 
		mov ecx, charged_msg_1 
		call print

		;print the current charge along with the previous message
		xor ax, ax
		movzx ax, byte [sensor_battery]
		call convert_to_acii

		; finally the last part of our message, printed below
		mov edx, charged_msg_2_len 
		mov ecx, charged_msg_2 
		call print

		call exit

	; handles how we should behave when
	; the sensor temperature exceeds the limit	
	error_temperature:
	
		mov edx, error_msg_tempe_len 
		mov ecx, error_msg_tempe 
		call print

		call exit

	; handles how we should behave when
	; the sensor current exceeds the limit
	error_current:

		mov edx, error_msg_corr_len 
		mov ecx, error_msg_corr
		call print

		call exit
