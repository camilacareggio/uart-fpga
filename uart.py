import serial
import serial.tools.list_ports

BAUDRATE = 19200  # Set baud rate for this communication

OPCODES = {
    'ADD': 0x20,
    'SUB': 0x22,
    'AND': 0x24,
    'OR': 0x25,
    'XOR': 0x26,
    'NOR': 0x27,
    'SRA': 0x03,
    'SRL': 0x02
}

class SerialPortControl:
    def __init__(self, port):
        self.serial_port = serial.Serial(port, BAUDRATE, timeout=1)

    def send_serial_data(self):
        operation = input('Operation code (ADD, SUB, AND, OR, XOR, NOR, SRA, SRL): ')

        if operation not in OPCODES:
            print('Operación no válida')
            return
        data_a_hex = input('Data A (Hex): ')
        data_b_hex = input('Data B (Hex): ')

        data_a = int(data_a_hex, 16)
        data_b = int(data_b_hex, 16)
        op_code = OPCODES[operation]

        data_to_send = bytes([op_code, data_a, data_b])
        self.serial_port.write(data_to_send)

        received_data = self.serial_port.read(2)
        if len(received_data) == 1:
            result = int.from_bytes(received_data, byteorder='big')
            print('Result:', hex(result))
        else:
            print('ERROR: data not received')

if __name__ == "__main__":
    com_port = 'COM18'
    uart_communication = SerialPortControl(com_port)
    while True:
        uart_communication.send_serial_data()
