// TODO: We could define these to match fs::

export def SEEK_SET: u32 = 0;
export def SEEK_CUR: u32 = 1;
export def SEEK_END: u32 = 2;

export def O_RDONLY: int = 0o0;
export def O_WRONLY: int = 0o1;
export def O_RDWR: int = 0o2;
export def O_CREAT: int = 0o100;
export def O_EXCL: int = 0o200;
export def O_TRUNC: int = 0o1000;
export def O_APPEND: int = 0o2000;
