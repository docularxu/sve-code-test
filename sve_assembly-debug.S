/* TODO: add copyright */


/* C function prototype */
/* void bl_dtrmm_asm_sve_8x8( int     k,
                              double  *a,
                              double  *b,
                              double  *c,
                              unsigned long ldc,
                              aux_t   *data,
                              int     offset
                            )
 */


#define FUNC bl_dtrmm_asm_sve_8x8

#define origK       x0
#define origPA      x1
#define origPB      x2
#define origPC      x3
#define LDC         x4
#define auxData     x5
#define offset      x6
#define feedback    x7

#define counterL    x8
#define a_pntr      x9
#define c_pntr      x10
#define b_pntr      x11

#define tmp_counter        x15
#define tmp2        x16
// 18 must save
// 19 must save
// 20 must save
// 21 must save
// 22 must save
// 23 must save
// 24 must save
// 25 must save
// 26 must save
// 27 must save
// 28 must save
// 29 frame
// 30 link
// 31 sp

//v00 ~ v07: b ( l,0:7 ), dup
//v08 must save
//v09 must save
//v10 must save
//v11 must save
//v12 must save
//v13 must save
//v14 must save, a ( 0:3,l )
//v15 must save, a ( 4:7,l )
//v16 ~ v31: c
//v16 must save
//v17 must save

    .arch   armv8.2-a+sve
    .text
    .align  4
    .global FUNC
    .type   FUNC, %function

FUNC:

/*************************************************************
 * save registers
**************************************************************/
	add	sp, sp, #-(11 * 16)
	stp	d8, d9, [sp, #(0 * 16)]
	stp	d10, d11, [sp, #(1 * 16)]
	stp	d12, d13, [sp, #(2 * 16)]
	stp	d14, d15, [sp, #(3 * 16)]
	stp	d16, d17, [sp, #(4 * 16)]
	stp	x18, x19, [sp, #(5 * 16)]
	stp	x20, x21, [sp, #(6 * 16)]
	stp	x22, x23, [sp, #(7 * 16)]
	stp	x24, x25, [sp, #(8 * 16)]
	stp	x26, x27, [sp, #(9 * 16)]
	str	x28, [sp, #(10 * 16)]

/*************************************************************
 * code body
**************************************************************/

    mov     tmp_counter, xzr
/* code samples for testing */
/* loading C to z16 ~ z31 */
    pfalse  p1.b
    ptrue   p0.d, all

.Ldtrmm_loading_c_BEGIN:
    pnext   p1.d, p0, p1.d
    b.none  .Ldtrmm_loading_c_END
    // do something
    //
    add     tmp_counter, tmp_counter, #1    // total l loops
    b       .Ldtrmm_loading_c_BEGIN

.Ldtrmm_loading_c_END:
    // str     tmp_counter, [feedback]    // returns total l loops

    // load from packA
    ldr z0, [x1]
    ldr z1, [x1, #1, MUL VL]

    // store to C
    str z0, [x3]
    str z1, [x3, #1, MUL VL]

    ptrue   p0.d, all

    // load from packA using ld1d (scalar puls immediate)
    ld1d z2.d, p0/z, [x1]
    ld1d z3.d, p0/z, [x1, #1, MUL VL]

    // store to packB
    str z2, [x2]
    str z3, [x2, #1, MUL VL]

    // test how disassembly goes
    dup z2.d, #0

    // test wether integer 0 is ok in the instructions
//	fmov		v16.2d, #0.0  // nok
	dup  v16.2d, xzr  // ok

	fmov		z16.d, #0.0   // ok
//	fmov		d16, #0       // nok
	fmov		d16, xzr      // ok
/*************************************************************
 * restore registers
**************************************************************/
	mov	x0, #0				// set return value
	ldp	d8, d9, [sp, #(0 * 16)]
	ldp	d10, d11, [sp, #(1 * 16)]
	ldp	d12, d13, [sp, #(2 * 16)]
	ldp	d14, d15, [sp, #(3 * 16)]
	ldp	d16, d17, [sp, #(4 * 16)]
	ldp	x18, x19, [sp, #(5 * 16)]
	ldp	x20, x21, [sp, #(6 * 16)]
	ldp	x22, x23, [sp, #(7 * 16)]
	ldp	x24, x25, [sp, #(8 * 16)]
	ldp	x26, x27, [sp, #(9 * 16)]
	ldr	x28, [sp, #(10 * 16)]
	add	sp, sp, #(11*16)

    ret
