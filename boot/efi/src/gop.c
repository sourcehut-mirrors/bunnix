#include <assert.h>
#include <efi/protocol/graphics-output.h>
#include <efi/system-table.h>
#include <efi/types.h>
#include "bprintf.h"
#include "bootctx.h"
#include "gop.h"

efi_status
init_gop(efi_boot_services *bsvc, struct context *ctx)
{
	efi_status st;
	efi_graphics_output_protocol *gop;
	st = bsvc->LocateProtocol(&GraphicsOutputProtocol, NULL, (void **)&gop);
	if (st != EFI_SUCCESS) {
		return st;
	}

	size_t info_len;
	uint32_t nmode, dmode;
	efi_graphics_output_mode_information *info;
	st = gop->QueryMode(gop, gop->Mode == NULL ? 0 : gop->Mode->Mode,
		&info_len, &info);
	if (st == EFI_NOT_STARTED) {
		bprintfln("Warning: forcing GOP to mode 0 to initialize driver");
		st = gop->SetMode(gop, 0);
	}

	if (st != EFI_SUCCESS) {
		return st;
	} else {
		nmode = gop->Mode->MaxMode;
		dmode = gop->Mode->Mode;
	}

	// Set to default mode (TODO: configurable modes)
	(void)nmode;
	st = gop->SetMode(gop, dmode);
	efi_graphics_output_mode *mode = gop->Mode;
	switch (mode->Info->PixelFormat) {
	case PixelRedGreenBlueReserved8BitPerColor:
		ctx->fb.fmt = RGBX8;
		ctx->fb.stride = 4 * mode->Info->PixelsPerScanLine;
		break;
	case PixelBlueGreenRedReserved8BitPerColor:
		ctx->fb.fmt = BGRX8;
		ctx->fb.stride = 4 * mode->Info->PixelsPerScanLine;
		break;
	default:
		bprintfln("GOP: Unsupported pixel format");
		return EFI_SUCCESS;
	}

	ctx->fb.width = mode->Info->HorizontalResolution;
	ctx->fb.height = mode->Info->VerticalResolution;
	ctx->fb.fmt = mode->Info->VerticalResolution;
	ctx->fb.fb_base = (uintptr_t)mode->FrameBufferBase;
	ctx->fb.fb_size = mode->FrameBufferSize;

	return EFI_SUCCESS;
}
