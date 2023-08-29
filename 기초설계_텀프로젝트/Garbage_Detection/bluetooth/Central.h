#include <ArduinoBLE.h>

namespace CENTRAL {
  const char* deviceServiceUuid = "19b10000-e8f2-537e-4f6c-d104768a1214";
  const char* deviceServiceCharacteristicUuid = "19b10001-e8f2-537e-4f6c-d104768a1214";

  uint8_t gesture = -1;
  uint8_t oldGesture = -1; 

  BLEDevice peripheral;
  BLECharacteristic gestureCharacteristic;

  int begin();
  int sendGesture(uint8_t command);
}

int CENTRAL::begin() {
  // BLE setup
  if (!BLE.begin()) return EXIT_FAILURE;  // exit(1)
  BLE.setLocalName("Nano 33 BLE Central");
  BLE.advertise();
  
  // connectToPeripheral
  do {
    BLE.scanForUuid(deviceServiceUuid);
    peripheral = BLE.available();
  } while(!peripheral);

  if (peripheral) {
    BLE.stopScan();
    
    // controlPeripheral
    if (!peripheral.connect()) return EXIT_FAILURE;
    if (!peripheral.discoverAttributes()) {
      peripheral.disconnect();
      return EXIT_FAILURE;
    }
    gestureCharacteristic = peripheral.characteristic(deviceServiceCharacteristicUuid);
    if (!gestureCharacteristic) {
      peripheral.disconnect();
      return EXIT_FAILURE;
    } else if (!gestureCharacteristic.canWrite()) {
      peripheral.disconnect();
      return EXIT_FAILURE;
    }
  }
}

int CENTRAL::sendGesture(uint8_t command) {
  gesture = command;
  if (!peripheral.connected()) return EXIT_FAILURE;
  if (oldGesture != gesture) {
    oldGesture = gesture;
    gestureCharacteristic.writeValue(gesture);
  }
}
