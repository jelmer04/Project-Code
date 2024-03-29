//  Arduino Uno is receiver
#if defined(__AVR_ATmega328P__)
#define RX
#define LED 2
#endif


//  Arduino Leo is transmitter/sensor
#if defined(__AVR_ATmega32U4__)
#define TX
#define LED 13
#endif

//  Output types
#define READABLE 0    //  Humanly readable output with headings
#define CSV 1         //  Machine readable CSV output
#define TIME 2      //  Output with time value

//  Includes for radio communication
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

//  Control pins for radio
#define CE_PIN   9
#define CSN_PIN 10




#if defined (TX)

//  Includes for gyro - sensor only
#include <Wire.h>
#include <I2Cdev.h>
#include <MPU6050.h>


MPU6050 mpu;    // Create a gyro/accel

#endif


const uint64_t pipe = 0xE8E8F0F0E1LL; // Define the transmit pipe

RF24 radio(CE_PIN, CSN_PIN); // Create a Radio

//  Variables for data communication
int16_t motion[7];    //    ax, ay, az, gx, gy, gz, count
int16_t count = 0;

unsigned long time;        //  Time of last sample
const unsigned long sampletime = 100;    //  ms between samples

int LEDState = 0;        // State of LED

void printData (int mode);
void toggleLED ();


void setup()
{
    pinMode(LED, OUTPUT);
    
    Serial.begin(38400);    //  Start the serial port
    radio.begin();          //  Start the radio
    
    #if defined(TX)
    Wire.begin();    //  Start the Wire library for I2C
    //  Prepare sensor
    radio.openWritingPipe(pipe);        //  Radio is ready for transmission
    mpu.initialize();                   //  Start the gyro
    
    mpu.setFullScaleAccelRange(0);        //  ±1g
    
    //while (!Serial) {};
      //    Wait for serial connection
      
    //  Print gyro connection data
    Serial.println(mpu.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");
    #endif
    
    #if defined(RX)
    digitalWrite(LED, HIGH);
    
    //while (!Serial) {};
      //    Wait for serial connection
    
    digitalWrite(LED, LOW);
    
    //  Prepare receiver
    radio.openReadingPipe(1,pipe);        //  Radio is ready for receiving
    radio.startListening();               //  Start listening for transmission
    #endif

    Serial.println(radio.get_status());
}


void loop()
{
    #if defined(TX)
    //  Wait for the sample time to elapse
    while (millis() < time + sampletime)
    {
    }
    
    
    //  Save the sample time
    time = millis();
    
    //  Acquire data from the gyro
    mpu.getMotion6(&motion[0], &motion[1], &motion[2], &motion[3], &motion[4], &motion[5]);
    motion[6] = count;        //  Set the 6th element to the counter value
    
    radio.write(motion, sizeof(motion));    //  Transmit the data
    
    #endif
    
    #if defined(RX)
    //  Wait for data to be available
    if (radio.available())
    {
        
        bool done = false;
        //  Read all the data from the radio
        while (!done)
        {
            done = radio.read(motion, sizeof(motion));
        }
        time = millis();
    } else {
        //  Otherwise, there is no data available
        //Serial.println("No radio data available");
    }
        
    //  If the next packet is ready
    if (count == motion[6])
    #endif
    {
        //  Print the data
        printData(TIME);
        
        toggleLED();
        
    }
    count = motion[6]+1;    //  Increase the packet counter
    
    
    
}

void printData (int mode) {
    switch (mode) {
        case READABLE:
            Serial.print("\nax\tay\taz\tgx\tgy\tgz\tcount\n");
            Serial.print(motion[0]);    Serial.print('\t');
            Serial.print(motion[1]);    Serial.print('\t');
            Serial.print(motion[2]);    Serial.print('\t');
            Serial.print(motion[3]);    Serial.print('\t');
            Serial.print(motion[4]);    Serial.print('\t');
            Serial.print(motion[5]);    Serial.print('\t');
            Serial.println(motion[6]);
            break;
            
        case CSV:
            Serial.print(motion[0]);    Serial.print(", ");
            Serial.print(motion[1]);    Serial.print(", ");
            Serial.print(motion[2]);    Serial.print(", ");
            Serial.print(motion[3]);    Serial.print(", ");
            Serial.print(motion[4]);    Serial.print(", ");
            Serial.print(motion[5]);    Serial.print(", ");
            Serial.println(motion[6]);
            break;
            
        case TIME:
            Serial.print(motion[0]);    Serial.print(", ");
            Serial.print(motion[1]);    Serial.print(", ");
            Serial.print(motion[2]);    Serial.print(", ");
            Serial.print(motion[3]);    Serial.print(", ");
            Serial.print(motion[4]);    Serial.print(", ");
            Serial.print(motion[5]);    Serial.print(", ");
            Serial.println(time);
            break;
    }
}


void toggleLED()
{
    if (LEDState==1) {
        LEDState = 0;
        digitalWrite(LED, LOW);
    } else {
        LEDState = 1;
        digitalWrite(LED, HIGH);
    }
}
