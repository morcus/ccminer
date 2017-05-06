<<<<<<< HEAD
#include <cuda_helper.h>
#include <cuda_vectors.h>

#define CUBEHASH_ROUNDS 16 /* this is r for CubeHashr/b */
#define CUBEHASH_BLOCKBYTES 32 /* this is b for CubeHashr/b */

#if __CUDA_ARCH__ < 350
#define LROT(x,bits) ((x << bits) | (x >> (32 - bits)))
#else
#define LROT(x, bits) __funnelshift_l(x, x, bits)
#endif

#define ROTATEUPWARDS7(a)  LROT(a,7)
#define ROTATEUPWARDS11(a) LROT(a,11)

#define SWAP(a,b) { uint32_t u = a; a = b; b = u; }

__device__ __constant__
static const uint32_t c_IV_512[32] = {
	0x2AEA2A61, 0x50F494D4, 0x2D538B8B, 0x4167D83E,
	0x3FEE2313, 0xC701CF8C, 0xCC39968E, 0x50AC5695,
	0x4D42C787, 0xA647A8B3, 0x97CF0BEF, 0x825B4537,
	0xEEF864D2, 0xF22090C4, 0xD0E5CD33, 0xA23911AE,
	0xFCD398D9, 0x148FE485, 0x1B017BEF, 0xB6444532,
	0x6A536159, 0x2FF5781C, 0x91FA7934, 0x0DBADEA9,
	0xD65C8A2B, 0xA5A70E75, 0xB1C62456, 0xBC796576,
	0x1921C8F7, 0xE7989AF1, 0x7795D246, 0xD43E3B44
};

__device__ __forceinline__
static void rrounds(uint32_t x[2][2][2][2][2])
{
    int r;
    int j;
    int k;
    int l;
    int m;

//#pragma unroll 16
    for (r = 0;r < CUBEHASH_ROUNDS;++r) {

        /* "add x_0jklm into x_1jklmn modulo 2^32" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (k = 0;k < 2;++k)
#pragma unroll 2
                for (l = 0;l < 2;++l)
#pragma unroll 2
                    for (m = 0;m < 2;++m)
                        x[1][j][k][l][m] += x[0][j][k][l][m];

        /* "rotate x_0jklm upwards by 7 bits" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (k = 0;k < 2;++k)
#pragma unroll 2
                for (l = 0;l < 2;++l)
#pragma unroll 2
                    for (m = 0;m < 2;++m)
                        x[0][j][k][l][m] = ROTATEUPWARDS7(x[0][j][k][l][m]);

        /* "swap x_00klm with x_01klm" */
#pragma unroll 2
        for (k = 0;k < 2;++k)
#pragma unroll 2
            for (l = 0;l < 2;++l)
#pragma unroll 2
                for (m = 0;m < 2;++m)
                    SWAP(x[0][0][k][l][m],x[0][1][k][l][m])

        /* "xor x_1jklm into x_0jklm" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (k = 0;k < 2;++k)
#pragma unroll 2
                for (l = 0;l < 2;++l)
#pragma unroll 2
                    for (m = 0;m < 2;++m)
                        x[0][j][k][l][m] ^= x[1][j][k][l][m];

        /* "swap x_1jk0m with x_1jk1m" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (k = 0;k < 2;++k)
#pragma unroll 2
                for (m = 0;m < 2;++m)
                    SWAP(x[1][j][k][0][m],x[1][j][k][1][m])

        /* "add x_0jklm into x_1jklm modulo 2^32" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (k = 0;k < 2;++k)
#pragma unroll 2
                for (l = 0;l < 2;++l)
#pragma unroll 2
                    for (m = 0;m < 2;++m)
                        x[1][j][k][l][m] += x[0][j][k][l][m];

        /* "rotate x_0jklm upwards by 11 bits" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (k = 0;k < 2;++k)
#pragma unroll 2
                for (l = 0;l < 2;++l)
#pragma unroll 2
                    for (m = 0;m < 2;++m)
                        x[0][j][k][l][m] = ROTATEUPWARDS11(x[0][j][k][l][m]);

        /* "swap x_0j0lm with x_0j1lm" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (l = 0;l < 2;++l)
#pragma unroll 2
                for (m = 0;m < 2;++m)
                    SWAP(x[0][j][0][l][m],x[0][j][1][l][m])

        /* "xor x_1jklm into x_0jklm" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (k = 0;k < 2;++k)
#pragma unroll 2
                for (l = 0;l < 2;++l)
#pragma unroll 2
                    for (m = 0;m < 2;++m)
                        x[0][j][k][l][m] ^= x[1][j][k][l][m];

        /* "swap x_1jkl0 with x_1jkl1" */
#pragma unroll 2
        for (j = 0;j < 2;++j)
#pragma unroll 2
            for (k = 0;k < 2;++k)
#pragma unroll 2
                for (l = 0;l < 2;++l)
                    SWAP(x[1][j][k][l][0],x[1][j][k][l][1])

    }
}

__device__ __forceinline__
static void block_tox(uint32_t* const block, uint32_t x[2][2][2][2][2])
{
	// read 32 bytes input from global mem with uint2 chunks
	AS_UINT2(x[0][0][0][0]) ^= AS_UINT2(&block[0]);
	AS_UINT2(x[0][0][0][1]) ^= AS_UINT2(&block[2]);
	AS_UINT2(x[0][0][1][0]) ^= AS_UINT2(&block[4]);
	AS_UINT2(x[0][0][1][1]) ^= AS_UINT2(&block[6]);
}

__device__ __forceinline__
static void hash_fromx(uint32_t hash[16], uint32_t const x[2][2][2][2][2])
{
	// used to write final hash to global mem
	AS_UINT2(&hash[ 0]) = AS_UINT2(x[0][0][0][0]);
	AS_UINT2(&hash[ 2]) = AS_UINT2(x[0][0][0][1]);
	AS_UINT2(&hash[ 4]) = AS_UINT2(x[0][0][1][0]);
	AS_UINT2(&hash[ 6]) = AS_UINT2(x[0][0][1][1]);
	AS_UINT2(&hash[ 8]) = AS_UINT2(x[0][1][0][0]);
	AS_UINT2(&hash[10]) = AS_UINT2(x[0][1][0][1]);
	AS_UINT2(&hash[12]) = AS_UINT2(x[0][1][1][0]);
	AS_UINT2(&hash[14]) = AS_UINT2(x[0][1][1][1]);
}

#define Init(x) \
	AS_UINT2(x[0][0][0][0]) = AS_UINT2(&c_IV_512[ 0]); \
	AS_UINT2(x[0][0][0][1]) = AS_UINT2(&c_IV_512[ 2]); \
	AS_UINT2(x[0][0][1][0]) = AS_UINT2(&c_IV_512[ 4]); \
	AS_UINT2(x[0][0][1][1]) = AS_UINT2(&c_IV_512[ 6]); \
	AS_UINT2(x[0][1][0][0]) = AS_UINT2(&c_IV_512[ 8]); \
	AS_UINT2(x[0][1][0][1]) = AS_UINT2(&c_IV_512[10]); \
	AS_UINT2(x[0][1][1][0]) = AS_UINT2(&c_IV_512[12]); \
	AS_UINT2(x[0][1][1][1]) = AS_UINT2(&c_IV_512[14]); \
	AS_UINT2(x[1][0][0][0]) = AS_UINT2(&c_IV_512[16]); \
	AS_UINT2(x[1][0][0][1]) = AS_UINT2(&c_IV_512[18]); \
	AS_UINT2(x[1][0][1][0]) = AS_UINT2(&c_IV_512[20]); \
	AS_UINT2(x[1][0][1][1]) = AS_UINT2(&c_IV_512[22]); \
	AS_UINT2(x[1][1][0][0]) = AS_UINT2(&c_IV_512[24]); \
	AS_UINT2(x[1][1][0][1]) = AS_UINT2(&c_IV_512[26]); \
	AS_UINT2(x[1][1][1][0]) = AS_UINT2(&c_IV_512[28]); \
	AS_UINT2(x[1][1][1][1]) = AS_UINT2(&c_IV_512[30]);

__device__ __forceinline__
static void Update32(uint32_t x[2][2][2][2][2], uint32_t* const data)
{
	/* "xor the block into the first b bytes of the state" */
	block_tox(data, x);
	/* "and then transform the state invertibly through r identical rounds" */
	rrounds(x);
}

__device__ __forceinline__
static void Final(uint32_t x[2][2][2][2][2], uint32_t *hashval)
{
	/* "the integer 1 is xored into the last state word x_11111" */
	x[1][1][1][1][1] ^= 1;

	/* "the state is then transformed invertibly through 10r identical rounds" */
	#pragma unroll 10
	for (int i = 0; i < 10; i++) rrounds(x);

	/* "output the first h/8 bytes of the state" */
	hash_fromx(hashval, x);
}


/***************************************************/

__global__
void x11_cubehash512_gpu_hash_64(uint32_t threads, uint32_t startNounce, uint64_t *g_hash, uint32_t *g_nonceVector)
{
	uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
	if (thread < threads)
	{
		uint32_t nounce = (g_nonceVector != NULL) ? g_nonceVector[thread] : (startNounce + thread);

		int hashPosition = nounce - startNounce;
		uint32_t *Hash = (uint32_t*)&g_hash[8 * hashPosition];

		uint32_t x[2][2][2][2][2];
		Init(x);

		Update32(x, &Hash[0]);
		Update32(x, &Hash[8]);

		// Padding Block
		uint32_t last[8];
		last[0] = 0x80;
		#pragma unroll 7
		for (int i=1; i < 8; i++) last[i] = 0;
		Update32(x, last);

		Final(x, Hash);
	}
}

__host__
void x11_cubehash512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, int order)
{
	const uint32_t threadsperblock = 256;

	dim3 grid((threads + threadsperblock-1)/threadsperblock);
	dim3 block(threadsperblock);

	size_t shared_size = 0;

	x11_cubehash512_gpu_hash_64<<<grid, block, shared_size>>>(threads, startNounce, (uint64_t*)d_hash, d_nonceVector);
}

__host__
void x11_cubehash512_cpu_init(int thr_id, uint32_t threads) { }


/***************************************************/

#define WANT_CUBEHASH80
#ifdef WANT_CUBEHASH80

__constant__
static uint32_t c_PaddedMessage80[20];

__host__
void cubehash512_setBlock_80(int thr_id, uint32_t* endiandata)
{
	cudaMemcpyToSymbol(c_PaddedMessage80, endiandata, sizeof(c_PaddedMessage80), 0, cudaMemcpyHostToDevice);
}

__global__
void cubehash512_gpu_hash_80(const uint32_t threads, const uint32_t startNounce, uint64_t *g_outhash)
{
	const uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
	if (thread < threads)
	{
		const uint32_t nonce = startNounce + thread;

		uint32_t x[2][2][2][2][2];
		Init(x);

		uint32_t message[8];
		// first 32 bytes
		AS_UINT4(&message[0]) = AS_UINT4(&c_PaddedMessage80[0]);
		AS_UINT4(&message[4]) = AS_UINT4(&c_PaddedMessage80[4]);
		Update32(x, message);

		// second 32 bytes
		AS_UINT4(&message[0]) = AS_UINT4(&c_PaddedMessage80[8]);
		AS_UINT4(&message[4]) = AS_UINT4(&c_PaddedMessage80[12]);
		Update32(x, message);

		// last 16 bytes + Padding
		AS_UINT4(&message[0]) = AS_UINT4(&c_PaddedMessage80[16]);
		message[3] = cuda_swab32(nonce);
		message[4] = 0x80;
		message[5] = 0;
		message[6] = 0;
		message[7] = 0;
		Update32(x, message);

		uint32_t* output = (uint32_t*) (&g_outhash[(size_t)8 * thread]);
		Final(x, output);
	}
}

__host__
void cubehash512_cuda_hash_80(const int thr_id, const uint32_t threads, const uint32_t startNounce, uint32_t *d_hash)
{
	const uint32_t threadsperblock = 256;
	dim3 grid((threads + threadsperblock-1)/threadsperblock);
	dim3 block(threadsperblock);

	cubehash512_gpu_hash_80 <<<grid, block>>> (threads, startNounce, (uint64_t*) d_hash);
}

#endif
=======
#include "cuda_helper.h"

#define ROUND_EVEN   \
		xg = (x0 + xg); \
		x0 = ROTL32c(x0, 7); \
		xh = (x1 + xh); \
		x1 = ROTL32c(x1, 7); \
		xi = (x2 + xi); \
		x2 = ROTL32c(x2, 7); \
		xj = (x3 + xj); \
		x3 = ROTL32c(x3, 7); \
		xk = (x4 + xk); \
		x4 = ROTL32c(x4, 7); \
		xl = (x5 + xl); \
		x5 = ROTL32c(x5, 7); \
		xm = (x6 + xm); \
		x6 = ROTL32c(x6, 7); \
		xn = (x7 + xn); \
		x7 = ROTL32c(x7, 7); \
		xo = (x8 + xo); \
		x8 = ROTL32c(x8, 7); \
		xp = (x9 + xp); \
		x9 = ROTL32c(x9, 7); \
		xq = (xa + xq); \
		xa = ROTL32c(xa, 7); \
		xr = (xb + xr); \
		xb = ROTL32c(xb, 7); \
		xs = (xc + xs); \
		xc = ROTL32c(xc, 7); \
		xt = (xd + xt); \
		xd = ROTL32c(xd, 7); \
		xu = (xe + xu); \
		xe = ROTL32c(xe, 7); \
		xv = (xf + xv); \
		xf = ROTL32c(xf, 7); \
		x8 ^= xg; \
		x9 ^= xh; \
		xa ^= xi; \
		xb ^= xj; \
		xc ^= xk; \
		xd ^= xl; \
		xe ^= xm; \
		xf ^= xn; \
		x0 ^= xo; \
		x1 ^= xp; \
		x2 ^= xq; \
		x3 ^= xr; \
		x4 ^= xs; \
		x5 ^= xt; \
		x6 ^= xu; \
		x7 ^= xv; \
		xi = (x8 + xi); \
		x8 = ROTL32c(x8, 11); \
		xj = (x9 + xj); \
		x9 = ROTL32c(x9, 11); \
		xg = (xa + xg); \
		xa = ROTL32c(xa, 11); \
		xh = (xb + xh); \
		xb = ROTL32c(xb, 11); \
		xm = (xc + xm); \
		xc = ROTL32c(xc, 11); \
		xn = (xd + xn); \
		xd = ROTL32c(xd, 11); \
		xk = (xe + xk); \
		xe = ROTL32c(xe, 11); \
		xl = (xf + xl); \
		xf = ROTL32c(xf, 11); \
		xq = (x0 + xq); \
		x0 = ROTL32c(x0, 11); \
		xr = (x1 + xr); \
		x1 = ROTL32c(x1, 11); \
		xo = (x2 + xo); \
		x2 = ROTL32c(x2, 11); \
		xp = (x3 + xp); \
		x3 = ROTL32c(x3, 11); \
		xu = (x4 + xu); \
		x4 = ROTL32c(x4, 11); \
		xv = (x5 + xv); \
		x5 = ROTL32c(x5, 11); \
		xs = (x6 + xs); \
		x6 = ROTL32c(x6, 11); \
		xt = (x7 + xt); \
		x7 = ROTL32c(x7, 11); \
		xc ^= xi; \
		xd ^= xj; \
		xe ^= xg; \
		xf ^= xh; \
		x8 ^= xm; \
		x9 ^= xn; \
		xa ^= xk; \
		xb ^= xl; \
		x4 ^= xq; \
		x5 ^= xr; \
		x6 ^= xo; \
		x7 ^= xp; \
		x0 ^= xu; \
		x1 ^= xv; \
		x2 ^= xs; \
		x3 ^= xt; 

#define ROUND_ODD    \
		xj = (xc + xj); \
		xc = ROTL32c(xc, 7); \
		xi = (xd + xi); \
		xd = ROTL32c(xd, 7); \
		xh = (xe + xh); \
		xe = ROTL32c(xe, 7); \
		xg = (xf + xg); \
		xf = ROTL32c(xf, 7); \
		xn = (x8 + xn); \
		x8 = ROTL32c(x8, 7); \
		xm = (x9 + xm); \
		x9 = ROTL32c(x9, 7); \
		xl = (xa + xl); \
		xa = ROTL32c(xa, 7); \
		xk = (xb + xk); \
		xb = ROTL32c(xb, 7); \
		xr = (x4 + xr); \
		x4 = ROTL32c(x4, 7); \
		xq = (x5 + xq); \
		x5 = ROTL32c(x5, 7); \
		xp = (x6 + xp); \
		x6 = ROTL32c(x6, 7); \
		xo = (x7 + xo); \
		x7 = ROTL32c(x7, 7); \
		xv = (x0 + xv); \
		x0 = ROTL32c(x0, 7); \
		xu = (x1 + xu); \
		x1 = ROTL32c(x1, 7); \
		xt = (x2 + xt); \
		x2 = ROTL32c(x2, 7); \
		xs = (x3 + xs); \
		x3 = ROTL32c(x3, 7); \
		x4 ^= xj; \
		x5 ^= xi; \
		x6 ^= xh; \
		x7 ^= xg; \
		x0 ^= xn; \
		x1 ^= xm; \
		x2 ^= xl; \
		x3 ^= xk; \
		xc ^= xr; \
		xd ^= xq; \
		xe ^= xp; \
		xf ^= xo; \
		x8 ^= xv; \
		x9 ^= xu; \
		xa ^= xt; \
		xb ^= xs; \
		xh = (x4 + xh); \
		x4 = ROTL32c(x4, 11); \
		xg = (x5 + xg); \
		x5 = ROTL32c(x5, 11); \
		xj = (x6 + xj); \
		x6 = ROTL32c(x6, 11); \
		xi = (x7 + xi); \
		x7 = ROTL32c(x7, 11); \
		xl = (x0 + xl); \
		x0 = ROTL32c(x0, 11); \
		xk = (x1 + xk); \
		x1 = ROTL32c(x1, 11); \
		xn = (x2 + xn); \
		x2 = ROTL32c(x2, 11); \
		xm = (x3 + xm); \
		x3 = ROTL32c(x3, 11); \
		xp = (xc + xp); \
		xc = ROTL32c(xc, 11); \
		xo = (xd + xo); \
		xd = ROTL32c(xd, 11); \
		xr = (xe + xr); \
		xe = ROTL32c(xe, 11); \
		xq = (xf + xq); \
		xf = ROTL32c(xf, 11); \
		xt = (x8 + xt); \
		x8 = ROTL32c(x8, 11); \
		xs = (x9 + xs); \
		x9 = ROTL32c(x9, 11); \
		xv = (xa + xv); \
		xa = ROTL32c(xa, 11); \
		xu = (xb + xu); \
		xb = ROTL32c(xb, 11); \
		x0 ^= xh; \
		x1 ^= xg; \
		x2 ^= xj; \
		x3 ^= xi; \
		x4 ^= xl; \
		x5 ^= xk; \
		x6 ^= xn; \
		x7 ^= xm; \
		x8 ^= xp; \
		x9 ^= xo; \
		xa ^= xr; \
		xb ^= xq; \
		xc ^= xt; \
		xd ^= xs; \
		xe ^= xv; \
		xf ^= xu; 

#define SIXTEEN_ROUNDS \
		for (int j = 0; j < 8; j ++) { \
			ROUND_EVEN; \
			ROUND_ODD;}
__global__	
void x11_cubehash512_gpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *g_hash)
{
    uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
    if (thread < threads)
    {
        uint32_t nounce = (startNounce + thread);
        int hashPosition = nounce - startNounce;
		int i, j;
        uint32_t *Hash = &g_hash[16 * hashPosition];

		uint32_t x0 = 0x2AEA2A61 ^ Hash[0];
		uint32_t x1 = 0x50F494D4 ^ Hash[1];
		uint32_t x2 = 0x2D538B8B ^ Hash[2];
		uint32_t x3 = 0x4167D83E ^ Hash[3];
		uint32_t x4 = 0x3FEE2313 ^ Hash[4];
		uint32_t x5 = 0xC701CF8C ^ Hash[5];
		uint32_t x6 = 0xCC39968E ^ Hash[6];
		uint32_t x7 = 0x50AC5695 ^ Hash[7];
		uint32_t x8 = 0x4D42C787, x9 = 0xA647A8B3, xa = 0x97CF0BEF, xb = 0x825B4537;
		uint32_t xc = 0xEEF864D2, xd = 0xF22090C4, xe = 0xD0E5CD33, xf = 0xA23911AE;
		uint32_t xg = 0xFCD398D9 + x0, xh = 0x148FE485 + x1, xi = 0x1B017BEF + x2, xj = 0xB6444532 + x3;
		uint32_t xk = 0x6A536159 + x4, xl = 0x2FF5781C + x5, xm = 0x91FA7934 + x6, xn = 0x0DBADEA9 + x7;
		uint32_t xo = 0xD65C8A2B + x8, xp = 0xA5A70E75 + x9, xq = 0xB1C62456 + xa, xr = 0xBC796576 + xb;
		uint32_t xs = 0x1921C8F7 + xc, xt = 0xE7989AF1 + xd, xu = 0x7795D246 + xe, xv = 0xD43E3B44 + xf;


		x0 = ROTL32c(x0, 7);
		x1 = ROTL32c(x1, 7);
		x2 = ROTL32c(x2, 7);
		x3 = ROTL32c(x3, 7);
		x4 = ROTL32c(x4, 7);
		x5 = ROTL32c(x5, 7);
		x6 = ROTL32c(x6, 7);
		x7 = ROTL32c(x7, 7);
		x8 = ROTL32c(x8, 7);
		x9 = ROTL32c(x9, 7);
		xa = ROTL32c(xa, 7);
		xb = ROTL32c(xb, 7);
		xc = ROTL32c(xc, 7);
		xd = ROTL32c(xd, 7);
		xe = ROTL32c(xe, 7);
		xf = ROTL32c(xf, 7);
		x8 ^= xg;
		x9 ^= xh;
		xa ^= xi;
		xb ^= xj;
		xc ^= xk;
		xd ^= xl;
		xe ^= xm;
		xf ^= xn;
		x0 ^= xo;
		x1 ^= xp;
		x2 ^= xq;
		x3 ^= xr;
		x4 ^= xs;
		x5 ^= xt;
		x6 ^= xu;
		x7 ^= xv;
		xi = (x8 + xi);
		x8 = ROTL32c(x8, 11);
		xj = (x9 + xj);
		x9 = ROTL32c(x9, 11);
		xg = (xa + xg);
		xa = ROTL32c(xa, 11);
		xh = (xb + xh);
		xb = ROTL32c(xb, 11);
		xm = (xc + xm);
		xc = ROTL32c(xc, 11);
		xn = (xd + xn);
		xd = ROTL32c(xd, 11);
		xk = (xe + xk);
		xe = ROTL32c(xe, 11);
		xl = (xf + xl);
		xf = ROTL32c(xf, 11);
		xq = (x0 + xq);
		x0 = ROTL32c(x0, 11);
		xr = (x1 + xr);
		x1 = ROTL32c(x1, 11);
		xo = (x2 + xo);
		x2 = ROTL32c(x2, 11);
		xp = (x3 + xp);
		x3 = ROTL32c(x3, 11);
		xu = (x4 + xu);
		x4 = ROTL32c(x4, 11);
		xv = (x5 + xv);
		x5 = ROTL32c(x5, 11);
		xs = (x6 + xs);
		x6 = ROTL32c(x6, 11);
		xt = (x7 + xt);
		x7 = ROTL32c(x7, 11);
		xc ^= xi;
		xd ^= xj;
		xe ^= xg;
		xf ^= xh;
		x8 ^= xm;
		x9 ^= xn;
		xa ^= xk;
		xb ^= xl;
		x4 ^= xq;
		x5 ^= xr;
		x6 ^= xo;
		x7 ^= xp;
		x0 ^= xu;
		x1 ^= xv;
		x2 ^= xs;
		x3 ^= xt;

		xj = (xc + xj);
		xc = ROTL32c(xc, 7);
		xi = (xd + xi);
		xd = ROTL32c(xd, 7);
		xh = (xe + xh);
		xe = ROTL32c(xe, 7);
		xg = (xf + xg);
		xf = ROTL32c(xf, 7);
		xn = (x8 + xn);
		x8 = ROTL32c(x8, 7);
		xm = (x9 + xm);
		x9 = ROTL32c(x9, 7);
		xl = (xa + xl);
		xa = ROTL32c(xa, 7);
		xk = (xb + xk);
		xb = ROTL32c(xb, 7);
		xr = (x4 + xr);
		x4 = ROTL32c(x4, 7);
		xq = (x5 + xq);
		x5 = ROTL32c(x5, 7);
		xp = (x6 + xp);
		x6 = ROTL32c(x6, 7);
		xo = (x7 + xo);
		x7 = ROTL32c(x7, 7);
		xv = (x0 + xv);
		x0 = ROTL32c(x0, 7);
		xu = (x1 + xu);
		x1 = ROTL32c(x1, 7);
		xt = (x2 + xt);
		x2 = ROTL32c(x2, 7);
		xs = (x3 + xs);
		x3 = ROTL32c(x3, 7);
		x4 ^= xj;
		x5 ^= xi;
		x6 ^= xh;
		x7 ^= xg;
		x0 ^= xn;
		x1 ^= xm;
		x2 ^= xl;
		x3 ^= xk;
		xc ^= xr;
		xd ^= xq;
		xe ^= xp;
		xf ^= xo;
		x8 ^= xv;
		x9 ^= xu;
		xa ^= xt;
		xb ^= xs;
		xh = (x4 + xh);
		x4 = ROTL32c(x4, 11);
		xg = (x5 + xg);
		x5 = ROTL32c(x5, 11);
		xj = (x6 + xj);
		x6 = ROTL32c(x6, 11);
		xi = (x7 + xi);
		x7 = ROTL32c(x7, 11);
		xl = (x0 + xl);
		x0 = ROTL32c(x0, 11);
		xk = (x1 + xk);
		x1 = ROTL32c(x1, 11);
		xn = (x2 + xn);
		x2 = ROTL32c(x2, 11);
		xm = (x3 + xm);
		x3 = ROTL32c(x3, 11);
		xp = (xc + xp);
		xc = ROTL32c(xc, 11);
		xo = (xd + xo);
		xd = ROTL32c(xd, 11);
		xr = (xe + xr);
		xe = ROTL32c(xe, 11);
		xq = (xf + xq);
		xf = ROTL32c(xf, 11);
		xt = (x8 + xt);
		x8 = ROTL32c(x8, 11);
		xs = (x9 + xs);
		x9 = ROTL32c(x9, 11);
		xv = (xa + xv);
		xa = ROTL32c(xa, 11);
		xu = (xb + xu);
		xb = ROTL32c(xb, 11);
		x0 ^= xh;
		x1 ^= xg;
		x2 ^= xj;
		x3 ^= xi;
		x4 ^= xl;
		x5 ^= xk;
		x6 ^= xn;
		x7 ^= xm;
		x8 ^= xp;
		x9 ^= xo;
		xa ^= xr;
		xb ^= xq;
		xc ^= xt;
		xd ^= xs;
		xe ^= xv;
		xf ^= xu;

		for (j = 1; j < 8; j++)
		{
			ROUND_EVEN;
			ROUND_ODD;
		}
		x0 ^= (Hash[8]);
		x1 ^= (Hash[9]);
		x2 ^= (Hash[10]);
		x3 ^= (Hash[11]);
		x4 ^= (Hash[12]);
		x5 ^= (Hash[13]);
		x6 ^= (Hash[14]);
		x7 ^= (Hash[15]);


		#pragma unroll 1
		for (j = 0; j < 8; j++)
		{
			ROUND_EVEN;
			ROUND_ODD;
		}
		x0 ^= 0x80;

		#pragma unroll 1
		for (int j = 0; j < 8; j++)
		{
			ROUND_EVEN;
			ROUND_ODD;
		}
		xv ^= 1;

		for (i = 3; i < 12; i++)
		{
#if __CUDA_ARCH__ > 500
#pragma unroll
			for (j = 0; j < 8; j++)
#else
#pragma unroll 1
			for (j = 0; j < 8; j++)
#endif
			{
				ROUND_EVEN;
				ROUND_ODD;
			}
		}
		#pragma unroll
		for (j = 0; j < 8; j++)
		{
			ROUND_EVEN;
			ROUND_ODD;
		}

		Hash[0] = x0;
		Hash[1] = x1;
		Hash[2] = x2;
		Hash[3] = x3;
		Hash[4] = x4;
		Hash[5] = x5;
		Hash[6] = x6;
		Hash[7] = x7;
		Hash[8] = x8;
		Hash[9] = x9;
		Hash[10] = xa;
		Hash[11] = xb;
		Hash[12] = xc;
		Hash[13] = xd;
		Hash[14] = xe;
		Hash[15] = xf;
	}
}
__host__
void x11_cubehash512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash)
{
	const uint32_t threadsperblock = 256;

    // berechne wie viele Thread Blocks wir brauchen
    dim3 grid((threads + threadsperblock-1)/threadsperblock);
    dim3 block(threadsperblock);

    x11_cubehash512_gpu_hash_64<<<grid, block>>>(threads, startNounce, d_hash);
}

>>>>>>> 8c320ca... added xevan
