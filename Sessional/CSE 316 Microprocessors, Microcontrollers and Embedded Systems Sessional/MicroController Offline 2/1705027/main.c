#ifndef F_CPU
#define F_CPU 16000000UL // 16 MHz clock speed
#endif
#define D4 eS_PORTD4
#define D5 eS_PORTD5
#define D6 eS_PORTD6
#define D7 eS_PORTD7
#define RS eS_PORTC6
#define EN eS_PORTC7

#include <avr/io.h>
#include <util/delay.h>
#include "lcd.h" //Can be download from the bottom of this article

#include <math.h>
#include <stdio.h>



int main(void)
{
	unsigned short result;
	float final_result;
	char output[100];
	DDRD = 0xFF;
	DDRC = 0xFF;
	
	ADMUX = 0b00000011;
	ADCSRA = 0b10000001;
	
	Lcd4_Init();
	
	Lcd4_Clear();
	Lcd4_Set_Cursor(1,0);
	Lcd4_Write_String("Voltage : ");
	while (1)
	{
				
				ADCSRA |= (1<<ADSC);
				
				while (ADCSRA & (1<<ADSC)){}
				
				result = ADCL;
				result |= (ADCH<<8);
				
				final_result = result*(4.5/1024);
				
				//sprintf(output, "%0.2f", final_result);
				dtostrf(final_result, 3, 2, output);
				
				
				Lcd4_Set_Cursor(1,10);
				Lcd4_Write_String(output);
				_delay_ms(50);
	}
}