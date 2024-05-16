// TODO: User-configurable keymaps

// Loosely based on xkbcommon, only applies to US keyboard layouts
def K_ESC: u32 = 9;
def K_AE01: u32 = 10;
def K_AE02: u32 = 11;
def K_AE03: u32 = 12;
def K_AE04: u32 = 13;
def K_AE05: u32 = 14;
def K_AE06: u32 = 15;
def K_AE07: u32 = 16;
def K_AE08: u32 = 17;
def K_AE09: u32 = 18;
def K_AE10: u32 = 19;
def K_AE11: u32 = 20;
def K_AE12: u32 = 21;
def K_BKSP: u32 = 22;
def K_TAB: u32 = 23;
def K_AD01: u32 = 24;
def K_AD02: u32 = 25;
def K_AD03: u32 = 26;
def K_AD04: u32 = 27;
def K_AD05: u32 = 28;
def K_AD06: u32 = 29;
def K_AD07: u32 = 30;
def K_AD08: u32 = 31;
def K_AD09: u32 = 32;
def K_AD10: u32 = 33;
def K_AD11: u32 = 34;
def K_AD12: u32 = 35;
def K_RTRN: u32 = 36;
def K_LCTL: u32 = 37;
def K_AC01: u32 = 38;
def K_AC02: u32 = 39;
def K_AC03: u32 = 40;
def K_AC04: u32 = 41;
def K_AC05: u32 = 42;
def K_AC06: u32 = 43;
def K_AC07: u32 = 44;
def K_AC08: u32 = 45;
def K_AC09: u32 = 46;
def K_AC10: u32 = 47;
def K_AC11: u32 = 48;
def K_TLDE: u32 = 49;
def K_LFSH: u32 = 50;
def K_BKSL: u32 = 51;
def K_AB01: u32 = 52;
def K_AB02: u32 = 53;
def K_AB03: u32 = 54;
def K_AB04: u32 = 55;
def K_AB05: u32 = 56;
def K_AB06: u32 = 57;
def K_AB07: u32 = 58;
def K_AB08: u32 = 59;
def K_AB09: u32 = 60;
def K_AB10: u32 = 61;
def K_RTSH: u32 = 62;
def K_KPMU: u32 = 63;
def K_LALT: u32 = 64;
def K_SPCE: u32 = 65;
def K_CAPS: u32 = 66;
def K_FK01: u32 = 67;
def K_FK02: u32 = 68;
def K_FK03: u32 = 69;
def K_FK04: u32 = 70;
def K_FK05: u32 = 71;
def K_FK06: u32 = 72;
def K_FK07: u32 = 73;
def K_FK08: u32 = 74;
def K_FK09: u32 = 75;
def K_FK10: u32 = 76;
def K_NMLK: u32 = 77;
def K_SCLK: u32 = 78;
def K_KP7: u32 = 79;
def K_KP8: u32 = 80;
def K_KP9: u32 = 81;
def K_KPSU: u32 = 82;
def K_KP4: u32 = 83;
def K_KP5: u32 = 84;
def K_KP6: u32 = 85;
def K_KPAD: u32 = 86;
def K_KP1: u32 = 87;
def K_KP2: u32 = 88;
def K_KP3: u32 = 89;
def K_KP0: u32 = 90;

const keysyms: [_][2]rune = [
	['\0', '\0'],	// Unused
	['\0', '\0'],	// K_ESC
	['1', '!'],	// K_AE01
	['2', '@'],	// K_AE02
	['3', '#'],	// K_AE03
	['4', '$'],	// K_AE04
	['5', '%'],	// K_AE05
	['6', '^'],	// K_AE06
	['7', '&'],	// K_AE07
	['8', '*'],	// K_AE08
	['9', '('],	// K_AE09
	['0', ')'],	// K_AE10
	['-', '_'],	// K_AE11
	['=', '+'],	// K_AE12
	['\b', '\b'],	// K_BKSP
	['\t', '\t' ],	// K_TAB
	['q', 'Q'],	// K_AD01
	['w', 'W'],	// K_AD02
	['e', 'E'],	// K_AD03
	['r', 'R'],	// K_AD04
	['t', 'T'],	// K_AD05
	['y', 'Y'],	// K_AD06
	['u', 'U'],	// K_AD07
	['i', 'I'],	// K_AD08
	['o', 'O'],	// K_AD09
	['p', 'P'],	// K_AD10
	['[', '{'],	// K_AD11
	[']', '}'],	// K_AD12
	['\n', '\n'],	// K_RTRN
	['\0', '\0'],	// K_LCTL
	['a', 'A'],	// K_AC01
	['s', 'S'],	// K_AC02
	['d', 'D'],	// K_AC03
	['f', 'F'],	// K_AC04
	['g', 'G'],	// K_AC05
	['h', 'H'],	// K_AC06
	['j', 'J'],	// K_AC07
	['k', 'K'],	// K_AC08
	['l', 'L'],	// K_AC09
	[';', ':'],	// K_AC10
	['\'', '"'],	// K_AC11
	['`', '~'],	// K_TLDE
	['\0', '\0'],	// K_LFSH
	['\\', '|'],	// K_BKSL
	['z', 'Z'],	// K_AB01
	['x', 'X'],	// K_AB02
	['c', 'C'],	// K_AB03
	['v', 'V'],	// K_AB04
	['b', 'B'],	// K_AB05
	['n', 'N'],	// K_AB06
	['m', 'M'],	// K_AB07
	[',', '<'],	// K_AB08
	['.', '>'],	// K_AB09
	['/', '?'],	// K_AB10
	['\0', '\0'],	// K_RTSH
	['\0', '\0'],	// K_KPMU
	['\0', '\0'],	// K_LALT
	[' ', ' '],	// K_SPCE
];
