#line 1 "C:/Users/EstChristianRafaelMa/Desktop/Examen_DSP/Examen.c"
sbit Chip_Select at LATF0_bit;
sbit Chip_Select_Direction at TRISF0_bit;
int M=16;
unsigned int datos[16];
unsigned int dato;
float prom;
int i;
int cont;
int pos;
unsigned int suma;

unsigned map(unsigned x, unsigned in_min, unsigned in_max, unsigned out_min, unsigned out_max)
{
 return (unsigned)((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
}
void configuracion_incial(){
 PORTB = 0x0000;
 TRISB.F1 = 1;
 Chip_Select = 1;
 Chip_Select_Direction = 0;
 SPI1_Init();

 pos=M-1;
 cont=0;
}
void DAC_Output(unsigned int valueDAC) {
 char temp;

 Chip_Select = 0;


 temp = (valueDAC >> 8) & 0x0F;
 temp |= 0x30;
 SPI1_Write(temp);


 temp = valueDAC;
 SPI1_Write(temp);

 Chip_Select = 1;
}
void main() {
 configuracion_incial();
 while (1) {


 if (cont >= M-1){

 datos[M-1]=ADC1_Read(1);
 suma=0;
 for(i=0;i<=M-1;i++){
 suma=suma+datos[i];
 if(i>=1){
 datos[i-1]=datos[i];
 }
 }
 prom=(float)(suma/M);
 }
 else{

 datos[cont]=ADC1_Read(1);
 cont=cont+1;
 }
 DAC_Output(prom);

 }
}
