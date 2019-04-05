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
  TRISB.F1 = 1;       // set pin as input - needed for ADC to work
  Chip_Select = 1;                       // Deselect DAC
  Chip_Select_Direction = 0;             // Set CS# pin as Output
  SPI1_Init();                           // Initialize SPI module
  //ADC1_Init();
  pos=M-1;
  cont=0;
}
void DAC_Output(unsigned int valueDAC) {
  char temp;

  Chip_Select = 0;                       // Select DAC chip

  // Send High Byte
  temp = (valueDAC >> 8) & 0x0F;         // Store valueDAC[11..8] to temp[3..0]
  temp |= 0x30;                          // Define DAC setting, see MCP4921 datasheet
  SPI1_Write(temp);                      // Send high byte via SPI

  // Send Low Byte
  temp = valueDAC;                       // Store valueDAC[7..0] to temp[7..0]
  SPI1_Write(temp);                      // Send low byte via SPI

  Chip_Select = 1;                       // Deselect DAC chip
}
void main() {
  configuracion_incial();
  while (1) {
    //dato=ADC1_Get_Sample(1);
    //datos[M-1]=ADC1_Get_Sample(1);
    if (cont >= M-1){
      //datos[M-1]=ADC1_Get_Sample(1);
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
          //datos[cont]=ADC1_Get_Sample(1);
          datos[cont]=ADC1_Read(1);
          cont=cont+1;
     }
      DAC_Output(prom);
    //delay_ms(1);
  }
}