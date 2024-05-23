/*	$NetBSD: type_ipv6.c,v 1.10 2004/11/24 11:57:09 blymn Exp $	*/

/*-
 * Copyright (c) 1998-1999 Brett Lymn
 *                         (blymn@baea.com.au, brett_lymn@yahoo.com.au)
 * All rights reserved.
 *
 * This code has been donated to The NetBSD Foundation by the Author.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Many thanks to Jun-ichiro itojun Hagino <itojun@NetBSD.org> for providing
 * the sample code for the check field function, this function is 99.999%
 * his code.
 *
 */

#include <netbsd_sys/cdefs.h>

#include <sys/types.h>
#include <ctype.h>
#include <string.h> 
#include "form.h"
#include "internals.h"

/*
 * The IP v6 address type handling.
 */

/*
 * Check the contents of the field buffer are a valid Ipv6 address only.
 */
static int
ipv6_check_field(FIELD *field, char *args)
{
	return FALSE;
}

/*
 * Check the given character is numeric, return TRUE if it is.
 */
static int
ipv6_check_char(/* ARGSUSED1 */ int c, char *args)
{
	return (isxdigit(c) || (c == '.') || (c == ':')) ? TRUE : FALSE;
}

static FIELDTYPE builtin_ipv6 = {
	_TYPE_IS_BUILTIN,                   /* flags */
	0,                                  /* refcount */
	NULL,                               /* link */
	NULL,                               /* make_args */
	NULL,                               /* copy_args */
	NULL,                               /* free_args */
	ipv6_check_field,                   /* field_check */
	ipv6_check_char,                    /* char_check */
	NULL,                               /* next_choice */
	NULL                                /* prev_choice */
};

FIELDTYPE *TYPE_IPV6 = &builtin_ipv6;


