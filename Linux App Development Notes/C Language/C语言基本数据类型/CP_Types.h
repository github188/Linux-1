/*
 * CopyRight:   HangZhou Hikvision System Technology Co., Ltd. All  Right Reserved.
 * FileName:    CP_Types.h
 * Desc:        define CC Types files.
 * Author:      schina
 * Date:        2009-03-02
 * Contact:     zhaoyiji@hikvision.com.cn
 * History:     Created By Zhaoyiji 2009-03-02
 *
 */

#ifndef __CP_TYPES_H__
#define __CP_TYPES_H__

	typedef /*signed*/ char     CP_INT8;
	typedef unsigned char   	CP_UINT8;
	typedef /*signed*/ short    CP_INT16;
	typedef unsigned short  	CP_UINT16;
	typedef /*signed*/ int      CP_INT32;
	typedef unsigned int    	CP_UINT32;
	typedef void*           	CP_VOIDPTR;
	typedef /*signed*/ long     CP_LONG;
	typedef unsigned long   	CP_ULONG;
	typedef double				CP_DOUBLE;
	
    #define CP_VOID void

#if defined(_MSC_VER)
    typedef /*signed*/ __int64  CP_INT64;
    typedef unsigned __int64 	CP_UINT64;
    typedef HANDLE          	CP_HANDLE;

#if (_MSC_VER >= 1310)
    #if defined _WIN32_WCE
        #include <crtdefs.h>
    #else
        #include <stddef.h>
    #endif
    typedef uintptr_t      	CP_UINT;
    typedef intptr_t        CP_INT;
#endif

    #ifndef socklen_t
        typedef int socklen_t;
    #endif

    typedef int (CALLBACK *CP_PROC)();

#elif defined(__GNUC__) || defined(__SYMBIAN32__)
    #if defined(__LP64__)
        typedef /*signed*/ long 		CP_INT64;
        typedef unsigned long 			CP_UINT64;
    #else
        typedef /*signed*/ long long 	CP_INT64;
        typedef unsigned long long 		CP_UINT64;
    #endif  //defined(__LP64__)
    typedef void*           			CP_HANDLE;

    #include <ctype.h>

/*	
	typedef uintptr_t CP_UINT;
    typedef intptr_t CP_INT;
*/

    typedef void*   CP_PROC;
    
#endif      // #if defined(_MSC_VER)

#define CP_SUPPORT_INT64 1

#ifndef  CP_BOOL
    #define CP_BOOL 	CP_INT32
    #define CP_TRUE  	1
    #define CP_FALSE 	0
#endif

#ifdef MEGAEYES_DSP_VER
    #define CP_STATUS 	CP_INT32
#endif

#define CP_INVALID_HANDLE 	NULL

#endif      // #ifndef __CP_TYPES_H__

