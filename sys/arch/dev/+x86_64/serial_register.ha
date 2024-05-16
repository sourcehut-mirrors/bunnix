// COM1 port
def COM1: u16 = 0x3F8;

// COM2 port
def COM2: u16 = 0x2F8;

// Receive buffer register
def RBR: u16 = 0;

// Transmit holding regiser
def THR: u16 = 0;

// Interrupt enable register
def IER: u16 = 1;

// Divisor latch (LSB)
def DL_LSB: u16 = 0;

// Divisor latch (MSB)
def DL_MSB: u16 = 1;

// Interrupt identification register
def IIR: u16 = 2;

// FIFO control register
def FCR: u16 = 2;

// Line control register
def LCR: u16 = 3;

// Modem control register
def MCR: u16 = 4;

// Line status register
def LSR: u16 = 5;

// Modem status register
def MSR: u16 = 6;

// Scratch register
def SCR: u16 = 7;

// Receive buffer full
def RBF: u8 = 1 << 0;

// Overflow error
def OE: u8 = 1 << 1;

// Parity error
def PE: u8 = 1 << 2;

// Framing error
def FE: u8 = 1 << 3;

// Break
def BRK: u8 = 1 << 4;

// Transmitter holding register empty
def THRE: u8 = 1 << 5;

// Transmitter empty
def TEMT: u8 = 1 << 6;

// An error is pending in the RX FIFO chain
def FIFOERR: u8 = 1 << 7;

// Enable Receiver Buffer Full Interrupt
def ERBFI: u8 = 1 << 0;

// Enable Transmitter Buffer Empty Interrupt
def ETBEI: u8 = 1 << 1;

// Enable Line Status Interrupt
def ELSI: u8 = 1 << 2;

// Enable Delta Status Signals Interrupt
def EDSSI: u8 = 1 << 3;
