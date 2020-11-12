#ifdef __ARM_FEATURE_SVE
#include <arm_sve.h>
#else
#error "No Arm SVE intrinsics support in compiler"
#endif /* __ARM_FEATURE_SVE */

#include <stdio.h>

#define __START_TRACE() {asm volatile (".inst 0x2520e020");}
#define __STOP_TRACE() {asm volatile (".inst 0x2520e040");}

extern void bl_dtrmm_asm_sve_8x8 ( int k,
        float *a,
        double *b,
        double *c,
        unsigned long long ldc,
        void   *data,
        int    offset );


/* vectorize testing */
int a[256], b[256], c[256];
void vect_foo () {
  int i;

  for (i=0; i<256; i++){
    a[i] = b[i] + c[i];
  }
}

void testSVE()
{
	int n = 10;
	svfloat32_t C3;
	svbool_t pred = svwhilelt_b32_u32(0, n);
	C3 = svdup_n_f32(0.2);
	return;
}

void example_sum_squares( int N, int * sum)
{
	svbool_t pred_N;
	svint32_t svN_tmp;
	svbool_t p_all = svptrue_b32();
	svint32_t acc = svdup_s32(0);

	if (N > 0) {
		svN_tmp = svindex_s32(N, -1);
		pred_N = svcmpgt( p_all, svN_tmp, 0);

		do {
			acc = svmla_m( pred_N, acc, svN_tmp, svN_tmp);
			svN_tmp = svsub_x( p_all, svN_tmp, svcntw());
			pred_N = svcmpgt( p_all, svN_tmp, 0);
		} while (svptest_first( p_all, pred_N));
	}
	*sum = (int) svaddv( p_all, acc);
}


void test_svld1_f64( void )
{
	int          inca = 1;
	svfloat64_t  z_a0;
        svfloat64_t  z_a4;
	const  svbool_t all_active = svptrue_b64();
	double pi1[16];
	double alpha1[16] = { 1.0, 1.1, 1.2, 1.3,
                             2.01, 2.12, 2.23, 2.34 };

	// load
#if 1
	z_a0 = svld1_f64( all_active, alpha1 );
	z_a4 = svld1_vnum_f64( all_active, alpha1, 1);
#else
        double* restrict alpha1_4   = alpha1 + 4 * inca;
	svuint64_t   z_index = svindex_u64( 0, inca * sizeof( double) );
	z_a0 = svld1_gather_u64offset_f64( all_active, alpha1, z_index );
        z_a4 = svld1_gather_u64offset_f64( all_active, alpha1_4, z_index );
#endif

        // store them into *p
        svst1_f64( all_active, pi1, z_a0 );
        svst1_vnum_f64( all_active, pi1, 1, z_a4 );

	printf("Loaded by svld1_f64:\n");
        printf("%f, %f, %f, %f\n", pi1[0], pi1[1], pi1[2], pi1[3]);
	printf("Loaded by svld1_vnum_f64:\n");
        printf("%f, %f, %f, %f\n", pi1[4], pi1[5], pi1[6], pi1[7]);
	return;
}

void test_divide_12 ( int a )
{
	long register b;
	long int c;
	scanf("Input: %ld\n", &c);
	b = c / 12;
	printf("Result: %ld\n", b);
	return;
}


void main()
{
	int sum;

	testSVE();
	printf("hello world \n");
	printf("vector length (bytes): %d\n", svcntb());
	example_sum_squares(1000, &sum);
	printf("sum %d\n", sum);

	float packA[16] = { 1.07, 1.142, 1.2034, 1.3005,
                             2.06787, 2.10234, 2.234, 2.303345 };
        double packB[16] = { -0.1, -0.2, -0.3, -0.4,
                             -2.0, -2.1, -2.2, -2.3 };
        double C[64];
        int    k = 8;

	printf("size of each element in A: %d\n", sizeof(packA[0]));
	printf("Original A is:\n");
        printf("%f, %f, %f, %f\n", packA[0], packA[1], packA[2], packA[3]);
        printf("%f, %f, %f, %f\n", packA[4], packA[5], packA[6], packA[7]);

        printf("call assembly routines\n");
	// input: packA
	// output: packB, C
	// __START_TRACE();
        bl_dtrmm_asm_sve_8x8( k, packA, packB, C, 0, NULL, 0 );
	// __STOP_TRACE();

	// converted to double:
	printf("size of each element in B: %d\n", sizeof(packB[0]));
	printf("Converted B is:\n");
        printf("%f, %f, %f, %f\n", packB[0], packB[1], packB[2], packB[3]);
        printf("%f, %f, %f, %f\n", packB[4], packB[5], packB[6], packB[7]);
	// test svld1_f64();
	// test_svld1_f64();
	// how assembly divide
	// test_divide_12( sum );
	// vectorize test
	vect_foo();
	// parallel with OpenMP
	#pragma omp parallel for
	for ( int j = 0; j < 4; j++ )
	{
		printf("j = %d, ThreadId = %d\n", j, omp_get_thread_num());
	}
	#pragma omp parallel sections
	{
	#pragma omp section
	printf("section 1 ThreadId = %d\n", omp_get_thread_num());
	#pragma omp section
	printf("section 2 ThreadId = %d\n", omp_get_thread_num());
	#pragma omp section
	printf("section 3 ThreadId = %d\n", omp_get_thread_num());
	#pragma omp section
	printf("section 4 ThreadId = %d\n", omp_get_thread_num());
	}
}
