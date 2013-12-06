//  Arduino Leonardo is receiver
#if defined(__AVR_ATmega32U4__)
#define RX
#endif


//  Arduino Uno is transmitter/sensor
#if defined(__AVR_ATmega328P__)
#define TX
#endif

//  Output types
#define READABLE 0    //  Humanly readable output with headings
#define CSV 1         //  Machine readable CSV output

//  Includes for radio communication
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>


#if defined (TX)

//  Includes for gyro - sensor only
#include <Wire.h>
#include <I2Cdev.h>
#include <MPU6050.h>

//  Control pins for gyro
#define CE_PIN   9
#define CSN_PIN 10

MPU6050 mpu;    // Create a gyro/accel

#endif


const uint64_t pipe = 0xE8E8F0F0E1LL; // Define the transmit pipe

RF24 radio(CE_PIN, CSN_PIN); // Create a Radio

//  Variables for data communication
int16_t motion[7];    //    ax, ay, az, gx, gy, gz, count
int16_t count = 0;

unsigned long time;        //  Time of last sample
const unsigned long sampletime = 500;    //  ms between samples

void setup()
{
    Wire.begin();    //  Start the Wire library for I2C
    
    Serial.begin(9600);    //  Start the serial port
    radio.begin();         //  Start the radio
    
    #if defined(TX)
    //  Prepare sensor
    radio.openWritingPipe(pipe);        //  Radio is ready for transmission
    mpu.initialize();                   //  Start the gyro
    //  Print gyro connection data
    Serial.println(mpu.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");
    #endif
    
    #if defined(RX)
    //  Prepare receiver
    radio.openReadingPipe(1,pipe);        //  Radio is ready for receiving
    radio.startListening();               //  Start listening for transmission
    #endif
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
    } else {
        //  Otherwise, there is no data available
        //Serial.println("No radio data available");
    }
    
    //  If the next packet is ready
    if (count == motion[6])
    #endif
    {
        //  Print the data
        printData(CSV);
        
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
    }
}
