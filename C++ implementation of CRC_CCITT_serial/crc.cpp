#include <iostream>
#include <cstdint>
#include <string>
#include <bitset>  // For binary representation

using namespace std;

uint16_t crc16(uint16_t Data) {
    uint8_t i;
    uint16_t o_Crc = 0xffff;
    o_Crc ^= Data << 8;
    
    for (i = 0; i < 8; i++) {
        // check if the shifted bit is set or not
        if (o_Crc & 0x8000) {
            o_Crc = (o_Crc << 1) ^ 0x1021;
        } else {
            o_Crc <<= 1;
        }
    }
    return o_Crc & 0xffff;
}

int main() {
    string input_data;
    cout << "Enter the input data in 8-bit hexadecimal : ";
    cin >> input_data;

    // Convert the hexadecimal string to uint16_t using 'stoi' with base 16
    uint16_t numeric_data = static_cast<uint16_t>(stoi(input_data, nullptr, 16));
    cout << "Numeric data (binary): " << bitset<16>(numeric_data) << endl;
    
    // Calculate CRC
    uint16_t CRC = crc16(numeric_data);
    
    // Output the CRC value in hexadecimal and binary forms
    cout << "The CRC value (hex): " << hex << CRC << endl;
    cout << "The CRC value (binary): " << bitset<16>(CRC) << endl;

    return 0;
}