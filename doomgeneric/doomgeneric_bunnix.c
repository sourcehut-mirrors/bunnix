#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <unistd.h>
#include "doomkeys.h"
#include "m_argv.h"
#include "doomgeneric.h"
#include "keymap.h"

int fbdev, kbdev;
uint8_t *fb;

struct {
	unsigned int width;
	unsigned int height;
	unsigned int stride;
	unsigned int format;
} screeninfo;

enum key_state {
	PRESSED,
	RELEASED,
};

struct key_evdata {
	uint32_t scancode;
	enum key_state state;
};

void DG_Init()
{
	fbdev = open("/dev/fb0", O_RDWR);
	if (fbdev < 0) {
		perror("open /dev/fb0");
		exit(1);
	}
	ioctl(fbdev, FBIOGET_VSCREENINFO, &screeninfo);
	printf("Framebuffer details: %ux%u (stride: %u)\n",
			screeninfo.width,
			screeninfo.height,
			screeninfo.stride);

	size_t length = screeninfo.height * screeninfo.stride;
	fb = mmap(0, length,
		PROT_READ | PROT_WRITE,
		MAP_SHARED,
		fbdev,
		0);
	if (fb == MAP_FAILED) {
		perror("mmap fb0");
		exit(1);
	}

	kbdev = open("/dev/kbd", O_RDONLY | O_NONBLOCK);
	if (kbdev < 0) {
		perror("open /dev/kbd");
		exit(1);
	}
}

void DG_DrawFrame()
{
        for (int i = 0; i < DOOMGENERIC_RESY; ++i) {
		memcpy(fb + i * screeninfo.stride,
			DG_ScreenBuffer + i * DOOMGENERIC_RESX,
			DOOMGENERIC_RESX * 4);
	}
}

void DG_SleepMs(uint32_t ms)
{
	usleep(ms * 1000);
}

uint32_t DG_GetTicksMs()
{
	struct timeval  tp;
	struct timezone tzp;

	gettimeofday(&tp, &tzp);

	return (tp.tv_sec * 1000) + (tp.tv_usec / 1000); /* return milliseconds */
}

int DG_GetKey(int *pressed, unsigned char *doomKey)
{
	struct key_evdata ev = {0};
	ssize_t r = read(kbdev, &ev, sizeof(struct key_evdata));
	if (r < 0 && errno == EAGAIN) {
		return 0;
	} else if (r < 0) {
		perror("read /dev/kbd");
		exit(1);
	}

	*pressed = ev.state == PRESSED;

	uint32_t scancode = ev.scancode - 8;
	printf("scancode %u %d\n", scancode, *pressed);
	switch (scancode) {
	case K_AD05:
		*doomKey = KEY_ENTER;
		break;
	case K_AE08: // WASD
		*doomKey = KEY_UPARROW;
		break;
	case K_AD07:
		*doomKey = KEY_LEFTARROW;
		break;
	case K_AD08:
		*doomKey = KEY_DOWNARROW;
		break;
	case K_AD09:
		*doomKey = KEY_RIGHTARROW;
		break;
	case K_BKSP:
		*doomKey = KEY_BACKSPACE;
		break;
	case K_AB03: // rshift
		*doomKey = KEY_FIRE;
		break;
	case K_AB06: // space
		*doomKey = KEY_USE;
		break;
	case K_AE12: // y
		printf("quit\n");
		*doomKey = 'y';
		break;
	case K_FK01:
		*doomKey = KEY_F1;
		break;
	case K_FK02:
		*doomKey = KEY_F2;
		break;
	case K_FK03:
		*doomKey = KEY_F3;
		break;
	case K_FK04:
		*doomKey = KEY_F4;
		break;
	case K_FK05:
		*doomKey = KEY_F5;
		break;
	case K_FK06:
		*doomKey = KEY_F6;
		break;
	case K_FK07:
		*doomKey = KEY_F7;
		break;
	case K_FK08:
		*doomKey = KEY_F8;
		break;
	case K_FK09:
		*doomKey = KEY_F9;
		break;
	case K_FK10:
		*doomKey = KEY_F10;
		break;
	case 1:
		*doomKey = KEY_ESCAPE;
		break;
	}
}

void DG_SetWindowTitle(const char *title)
{
}

int main(int argc, char **argv)
{
    doomgeneric_Create(argc, argv);

    for (int i = 0; ; i++)
    {
        doomgeneric_Tick();
    }
    

    return 0;
}
