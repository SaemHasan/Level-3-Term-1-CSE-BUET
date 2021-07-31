/*
 * Offline1.c
 *
 * Created: 06-Apr-21 10:50:59 PM
 * Author : sayim
 */ 
#define F_CPU 1000000
#include <stdio.h>
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

unsigned char mode = 0;
unsigned char i=0;
unsigned char n=8;

char column[] = {1,2,4,8,16,32,64,128};

//char row[] = {0x3C,0x42,0xA1,0x91,0x89,0x85,0x42,0x3C};
char row[] = {0x3C, 0x7E, 0xA1, 0x91, 0x89, 0x85, 0x7E, 0x3C};
//char row[] = {0x3C, 0x7E, 0xE3, 0xD3, 0xCB, 0xC7, 0x7E, 0x3C};


ISR(INT2_vect)
{
	mode = mode ^ 1;
}

void ArrayRightShift(){
	char temp,j;
	temp=column[n-1];
	for(j=n-1;j>0;j--)
	{
		column[j]=column[j-1];
	}
	column[0]=temp;
}

void ArrayLeftShift(){
	char temp,j;
	temp=column[0];
	for(j=0;j<n-1;j++)
	{
		column[j]=column[j+1];
	}
	column[n-1]=temp;
}


int main(void)
{
	
	DDRA = 0xFF;
	DDRD = 0xFF;
	
	GICR = (1<<INT2);
	MCUCSR = (1<<ISC2);
	sei();
	
	unsigned char d=2,k;
	
    /* Replace with your application code */
    while (1) 
    {
		if (mode==0)
		{
			for (i=0;i<=7;i++)
			{
				PORTA = column[i];
				PORTD = ~ (row[i]);
				_delay_ms(2);
				
			}
		}
		
		if(mode==1){
			for (k=1;k<=30;k++)
			{
				for (i=0;i<=7;i++)
				{
					PORTA = column[i];
					PORTD = ~ (row[i]);
					_delay_ms(2);
					
				}
			}
			//ArrayRightShift();
			ArrayLeftShift();
		}
		
    }
}

