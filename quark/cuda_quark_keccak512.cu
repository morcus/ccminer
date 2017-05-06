#include <stdio.h>
#include <memory.h>
<<<<<<< HEAD
#include <sys/types.h> // off_t

#include "cuda_helper.h"

#define U32TO64_LE(p) \
	(((uint64_t)(*p)) | (((uint64_t)(*(p + 1))) << 32))

#define U64TO32_LE(p, v) \
	*p = (uint32_t)((v)); *(p+1) = (uint32_t)((v) >> 32);

static const uint64_t host_keccak_round_constants[24] = {
	0x0000000000000001ull, 0x0000000000008082ull,
	0x800000000000808aull, 0x8000000080008000ull,
	0x000000000000808bull, 0x0000000080000001ull,
	0x8000000080008081ull, 0x8000000000008009ull,
	0x000000000000008aull, 0x0000000000000088ull,
	0x0000000080008009ull, 0x000000008000000aull,
	0x000000008000808bull, 0x800000000000008bull,
	0x8000000000008089ull, 0x8000000000008003ull,
	0x8000000000008002ull, 0x8000000000000080ull,
	0x000000000000800aull, 0x800000008000000aull,
	0x8000000080008081ull, 0x8000000000008080ull,
	0x0000000080000001ull, 0x8000000080008008ull
};

__constant__ uint64_t d_keccak_round_constants[24];

__device__ __forceinline__
static void keccak_block(uint2 *s)
{
	size_t i;
	uint2 t[5], u[5], v, w;

	for (i = 0; i < 24; i++) {
		/* theta: c = a[0,i] ^ a[1,i] ^ .. a[4,i] */
		t[0] = s[0] ^ s[5] ^ s[10] ^ s[15] ^ s[20];
		t[1] = s[1] ^ s[6] ^ s[11] ^ s[16] ^ s[21];
		t[2] = s[2] ^ s[7] ^ s[12] ^ s[17] ^ s[22];
		t[3] = s[3] ^ s[8] ^ s[13] ^ s[18] ^ s[23];
		t[4] = s[4] ^ s[9] ^ s[14] ^ s[19] ^ s[24];

		/* theta: d[i] = c[i+4] ^ rotl(c[i+1],1) */
		u[0] = t[4] ^ ROL2(t[1], 1);
		u[1] = t[0] ^ ROL2(t[2], 1);
		u[2] = t[1] ^ ROL2(t[3], 1);
		u[3] = t[2] ^ ROL2(t[4], 1);
		u[4] = t[3] ^ ROL2(t[0], 1);

		/* theta: a[0,i], a[1,i], .. a[4,i] ^= d[i] */
		s[0] ^= u[0]; s[5] ^= u[0]; s[10] ^= u[0]; s[15] ^= u[0]; s[20] ^= u[0];
		s[1] ^= u[1]; s[6] ^= u[1]; s[11] ^= u[1]; s[16] ^= u[1]; s[21] ^= u[1];
		s[2] ^= u[2]; s[7] ^= u[2]; s[12] ^= u[2]; s[17] ^= u[2]; s[22] ^= u[2];
		s[3] ^= u[3]; s[8] ^= u[3]; s[13] ^= u[3]; s[18] ^= u[3]; s[23] ^= u[3];
		s[4] ^= u[4]; s[9] ^= u[4]; s[14] ^= u[4]; s[19] ^= u[4]; s[24] ^= u[4];

		/* rho pi: b[..] = rotl(a[..], ..) */
		v = s[1];
		s[1]  = ROL2(s[6], 44);
		s[6]  = ROL2(s[9], 20);
		s[9]  = ROL2(s[22], 61);
		s[22] = ROL2(s[14], 39);
		s[14] = ROL2(s[20], 18);
		s[20] = ROL2(s[2], 62);
		s[2]  = ROL2(s[12], 43);
		s[12] = ROL2(s[13], 25);
		s[13] = ROL2(s[19], 8);
		s[19] = ROL2(s[23], 56);
		s[23] = ROL2(s[15], 41);
		s[15] = ROL2(s[4], 27);
		s[4]  = ROL2(s[24], 14);
		s[24] = ROL2(s[21], 2);
		s[21] = ROL2(s[8], 55);
		s[8]  = ROL2(s[16], 45);
		s[16] = ROL2(s[5], 36);
		s[5]  = ROL2(s[3], 28);
		s[3]  = ROL2(s[18], 21);
		s[18] = ROL2(s[17], 15);
		s[17] = ROL2(s[11], 10);
		s[11] = ROL2(s[7], 6);
		s[7]  = ROL2(s[10], 3);
		s[10] = ROL2(v, 1);

		/* chi: a[i,j] ^= ~b[i,j+1] & b[i,j+2] */
		v = s[0]; w = s[1]; s[0] ^= (~w) & s[2]; s[1] ^= (~s[2]) & s[3]; s[2] ^= (~s[3]) & s[4]; s[3] ^= (~s[4]) & v; s[4] ^= (~v) & w;
		v = s[5]; w = s[6]; s[5] ^= (~w) & s[7]; s[6] ^= (~s[7]) & s[8]; s[7] ^= (~s[8]) & s[9]; s[8] ^= (~s[9]) & v; s[9] ^= (~v) & w;
		v = s[10]; w = s[11]; s[10] ^= (~w) & s[12]; s[11] ^= (~s[12]) & s[13]; s[12] ^= (~s[13]) & s[14]; s[13] ^= (~s[14]) & v; s[14] ^= (~v) & w;
		v = s[15]; w = s[16]; s[15] ^= (~w) & s[17]; s[16] ^= (~s[17]) & s[18]; s[17] ^= (~s[18]) & s[19]; s[18] ^= (~s[19]) & v; s[19] ^= (~v) & w;
		v = s[20]; w = s[21]; s[20] ^= (~w) & s[22]; s[21] ^= (~s[22]) & s[23]; s[22] ^= (~s[23]) & s[24]; s[23] ^= (~s[24]) & v; s[24] ^= (~v) & w;

		/* iota: a[0,0] ^= round constant */
		s[0] ^= vectorize(d_keccak_round_constants[i]);
	}
}

__global__
void quark_keccak512_gpu_hash_64(uint32_t threads, uint32_t startNounce, uint64_t *g_hash, uint32_t *g_nonceVector)
=======

#include "cuda_helper.h"
#include "cuda_vector.h"

#ifdef _MSC_VER
#define UINT2(x,y) { x, y }
#else
#define UINT2(x,y) (uint2) { x, y }
#endif
static uint32_t *d_found[MAX_GPUS];

__constant__ uint2 c_keccak_round_constants35[24] = {
		{ 0x00000001ul, 0x00000000 }, { 0x00008082ul, 0x00000000 },
		{ 0x0000808aul, 0x80000000 }, { 0x80008000ul, 0x80000000 },
		{ 0x0000808bul, 0x00000000 }, { 0x80000001ul, 0x00000000 },
		{ 0x80008081ul, 0x80000000 }, { 0x00008009ul, 0x80000000 },
		{ 0x0000008aul, 0x00000000 }, { 0x00000088ul, 0x00000000 },
		{ 0x80008009ul, 0x00000000 }, { 0x8000000aul, 0x00000000 },
		{ 0x8000808bul, 0x00000000 }, { 0x0000008bul, 0x80000000 },
		{ 0x00008089ul, 0x80000000 }, { 0x00008003ul, 0x80000000 },
		{ 0x00008002ul, 0x80000000 }, { 0x00000080ul, 0x80000000 },
		{ 0x0000800aul, 0x00000000 }, { 0x8000000aul, 0x80000000 },
		{ 0x80008081ul, 0x80000000 }, { 0x00008080ul, 0x80000000 },
		{ 0x80000001ul, 0x00000000 }, { 0x80008008ul, 0x80000000 }
};
#define bitselect(a, b, c) ((a) ^ ((c) & ((b) ^ (a))))

__global__  __launch_bounds__(128, 7)
void quark_keccak512_gpu_hash_64(uint32_t threads, uint32_t startNounce, uint2 *g_hash, uint32_t *g_nonceVector)
{
    uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
    if (thread < threads)
    {
        uint32_t nounce = (g_nonceVector != NULL) ? g_nonceVector[thread] : (startNounce + thread);

        int hashPosition = nounce - startNounce;
        uint2 *inpHash = &g_hash[8 * hashPosition];


		uint2 msg[8];

		uint28 *phash = (uint28*)inpHash;
		uint28 *outpt = (uint28*)msg;
		outpt[0] = phash[0];
		outpt[1] = phash[1];

        uint2 s[25];
		uint2 bc[5], tmpxor[5], tmp1, tmp2;

		tmpxor[0] = msg[0] ^ msg[5];
		tmpxor[1] = msg[1] ^ msg[6];
		tmpxor[2] = msg[2] ^ msg[7];
		tmpxor[3] = msg[3] ^ make_uint2(0x1, 0x80000000);
		tmpxor[4] = msg[4];

		bc[0] = tmpxor[0] ^ ROL2(tmpxor[2], 1);
		bc[1] = tmpxor[1] ^ ROL2(tmpxor[3], 1);
		bc[2] = tmpxor[2] ^ ROL2(tmpxor[4], 1);
		bc[3] = tmpxor[3] ^ ROL2(tmpxor[0], 1);
		bc[4] = tmpxor[4] ^ ROL2(tmpxor[1], 1);

		s[0] = msg[0] ^ bc[4];
		s[1] = ROL2(msg[6] ^ bc[0], 44);
		s[6] = ROL2(bc[3], 20);
		s[9] = ROL2(bc[1], 61);
		s[22] = ROL2(bc[3], 39);
		s[14] = ROL2(bc[4], 18);
		s[20] = ROL2(msg[2] ^ bc[1], 62);
		s[2] = ROL2(bc[1], 43);
		s[12] = ROL2(bc[2], 25);
		s[13] = ROL8(bc[3]);
		s[19] = ROR8(bc[2]);
		s[23] = ROL2(bc[4], 41);
		s[15] = ROL2(msg[4] ^ bc[3], 27);
		s[4] = ROL2(bc[3], 14);
		s[24] = ROL2(bc[0], 2);
		s[21] = ROL2(make_uint2(0x1, 0x80000000) ^ bc[2], 55);
		s[8] = ROL2(bc[0], 45);
		s[16] = ROL2(msg[5] ^ bc[4], 36);
		s[5] = ROL2(msg[3] ^ bc[2], 28);
		s[3] = ROL2(bc[2], 21);
		s[18] = ROL2(bc[1], 15);
		s[17] = ROL2(bc[0], 10);
		s[11] = ROL2(msg[7] ^ bc[1], 6);
		s[7] = ROL2(bc[4], 3);
		s[10] = ROL2(msg[1] ^ bc[0], 1);

		tmp1 = s[0]; tmp2 = s[1]; s[0] = bitselect(s[0] ^ s[2], s[0], s[1]); s[1] = bitselect(s[1] ^ s[3], s[1], s[2]); s[2] = bitselect(s[2] ^ s[4], s[2], s[3]); s[3] = bitselect(s[3] ^ tmp1, s[3], s[4]); s[4] = bitselect(s[4] ^ tmp2, s[4], tmp1);
		tmp1 = s[5]; tmp2 = s[6]; s[5] = bitselect(s[5] ^ s[7], s[5], s[6]); s[6] = bitselect(s[6] ^ s[8], s[6], s[7]); s[7] = bitselect(s[7] ^ s[9], s[7], s[8]); s[8] = bitselect(s[8] ^ tmp1, s[8], s[9]); s[9] = bitselect(s[9] ^ tmp2, s[9], tmp1);
		tmp1 = s[10]; tmp2 = s[11]; s[10] = bitselect(s[10] ^ s[12], s[10], s[11]); s[11] = bitselect(s[11] ^ s[13], s[11], s[12]); s[12] = bitselect(s[12] ^ s[14], s[12], s[13]); s[13] = bitselect(s[13] ^ tmp1, s[13], s[14]); s[14] = bitselect(s[14] ^ tmp2, s[14], tmp1);
		tmp1 = s[15]; tmp2 = s[16]; s[15] = bitselect(s[15] ^ s[17], s[15], s[16]); s[16] = bitselect(s[16] ^ s[18], s[16], s[17]); s[17] = bitselect(s[17] ^ s[19], s[17], s[18]); s[18] = bitselect(s[18] ^ tmp1, s[18], s[19]); s[19] = bitselect(s[19] ^ tmp2, s[19], tmp1);
		tmp1 = s[20]; tmp2 = s[21]; s[20] = bitselect(s[20] ^ s[22], s[20], s[21]); s[21] = bitselect(s[21] ^ s[23], s[21], s[22]); s[22] = bitselect(s[22] ^ s[24], s[22], s[23]); s[23] = bitselect(s[23] ^ tmp1, s[23], s[24]); s[24] = bitselect(s[24] ^ tmp2, s[24], tmp1);
		s[0].x ^= 1;

#pragma unroll 2
		for (int i = 1; i < 24; ++i)
		{

#pragma unroll
			for (int x = 0; x < 5; x++)
				tmpxor[x] = s[x] ^ s[x + 5] ^ s[x + 10] ^ s[x + 15] ^ s[x + 20];

			bc[0] = tmpxor[0] ^ ROL2(tmpxor[2], 1);
			bc[1] = tmpxor[1] ^ ROL2(tmpxor[3], 1);
			bc[2] = tmpxor[2] ^ ROL2(tmpxor[4], 1);
			bc[3] = tmpxor[3] ^ ROL2(tmpxor[0], 1);
			bc[4] = tmpxor[4] ^ ROL2(tmpxor[1], 1);

			tmp1 = s[1] ^ bc[0];

			s[0] ^= bc[4];
			s[1] = ROL2(s[6] ^ bc[0], 44);
			s[6] = ROL2(s[9] ^ bc[3], 20);
			s[9] = ROL2(s[22] ^ bc[1], 61);
			s[22] = ROL2(s[14] ^ bc[3], 39);
			s[14] = ROL2(s[20] ^ bc[4], 18);
			s[20] = ROL2(s[2] ^ bc[1], 62);
			s[2] = ROL2(s[12] ^ bc[1], 43);
			s[12] = ROL2(s[13] ^ bc[2], 25);
			s[13] = ROL8(s[19] ^ bc[3]);
			s[19] = ROR8(s[23] ^ bc[2]);
			s[23] = ROL2(s[15] ^ bc[4], 41);
			s[15] = ROL2(s[4] ^ bc[3], 27);
			s[4] = ROL2(s[24] ^ bc[3], 14);
			s[24] = ROL2(s[21] ^ bc[0], 2);
			s[21] = ROL2(s[8] ^ bc[2], 55);
			s[8] = ROL2(s[16] ^ bc[0], 45);
			s[16] = ROL2(s[5] ^ bc[4], 36);
			s[5] = ROL2(s[3] ^ bc[2], 28);
			s[3] = ROL2(s[18] ^ bc[2], 21);
			s[18] = ROL2(s[17] ^ bc[1], 15);
			s[17] = ROL2(s[11] ^ bc[0], 10);
			s[11] = ROL2(s[7] ^ bc[1], 6);
			s[7] = ROL2(s[10] ^ bc[4], 3);
			s[10] = ROL2(tmp1, 1);

			tmp1 = s[0]; tmp2 = s[1]; s[0] = bitselect(s[0] ^ s[2], s[0], s[1]); s[1] = bitselect(s[1] ^ s[3], s[1], s[2]); s[2] = bitselect(s[2] ^ s[4], s[2], s[3]); s[3] = bitselect(s[3] ^ tmp1, s[3], s[4]); s[4] = bitselect(s[4] ^ tmp2, s[4], tmp1);
			tmp1 = s[5]; tmp2 = s[6]; s[5] = bitselect(s[5] ^ s[7], s[5], s[6]); s[6] = bitselect(s[6] ^ s[8], s[6], s[7]); s[7] = bitselect(s[7] ^ s[9], s[7], s[8]); s[8] = bitselect(s[8] ^ tmp1, s[8], s[9]); s[9] = bitselect(s[9] ^ tmp2, s[9], tmp1);
			tmp1 = s[10]; tmp2 = s[11]; s[10] = bitselect(s[10] ^ s[12], s[10], s[11]); s[11] = bitselect(s[11] ^ s[13], s[11], s[12]); s[12] = bitselect(s[12] ^ s[14], s[12], s[13]); s[13] = bitselect(s[13] ^ tmp1, s[13], s[14]); s[14] = bitselect(s[14] ^ tmp2, s[14], tmp1);
			tmp1 = s[15]; tmp2 = s[16]; s[15] = bitselect(s[15] ^ s[17], s[15], s[16]); s[16] = bitselect(s[16] ^ s[18], s[16], s[17]); s[17] = bitselect(s[17] ^ s[19], s[17], s[18]); s[18] = bitselect(s[18] ^ tmp1, s[18], s[19]); s[19] = bitselect(s[19] ^ tmp2, s[19], tmp1);
			tmp1 = s[20]; tmp2 = s[21]; s[20] = bitselect(s[20] ^ s[22], s[20], s[21]); s[21] = bitselect(s[21] ^ s[23], s[21], s[22]); s[22] = bitselect(s[22] ^ s[24], s[22], s[23]); s[23] = bitselect(s[23] ^ tmp1, s[23], s[24]); s[24] = bitselect(s[24] ^ tmp2, s[24], tmp1);
			s[0] ^= c_keccak_round_constants35[i];
		}

#pragma unroll
        for(int i=0;i<8;i++)
			inpHash[i] = s[i];
    }
}


__global__  __launch_bounds__(128, 7)
void quark_keccakskein512_gpu_hash_64(uint32_t threads, uint32_t startNounce, uint2 *g_hash, uint32_t *g_nonceVector)
>>>>>>> 8c320ca... added xevan
{
	uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
	if (thread < threads)
	{
		uint32_t nounce = (g_nonceVector != NULL) ? g_nonceVector[thread] : (startNounce + thread);

<<<<<<< HEAD
		off_t hashPosition = nounce - startNounce;
		uint64_t *inpHash = &g_hash[hashPosition * 8];
		uint2 keccak_gpu_state[25];

		for (int i = 0; i<8; i++) {
			keccak_gpu_state[i] = vectorize(inpHash[i]);
		}
		keccak_gpu_state[8] = vectorize(0x8000000000000001ULL);

		for (int i=9; i<25; i++) {
			keccak_gpu_state[i] = make_uint2(0, 0);
		}
		keccak_block(keccak_gpu_state);

		for(int i=0; i<8; i++) {
			inpHash[i] = devectorize(keccak_gpu_state[i]);
		}
	}
}

__device__ __forceinline__
static void keccak_block_v30(uint64_t *s, const uint32_t *in)
{
	size_t i;
	uint64_t t[5], u[5], v, w;

	#pragma unroll 9
	for (i = 0; i < 72 / 8; i++, in += 2)
		s[i] ^= U32TO64_LE(in);

	for (i = 0; i < 24; i++) {
		/* theta: c = a[0,i] ^ a[1,i] ^ .. a[4,i] */
		t[0] = s[0] ^ s[5] ^ s[10] ^ s[15] ^ s[20];
		t[1] = s[1] ^ s[6] ^ s[11] ^ s[16] ^ s[21];
		t[2] = s[2] ^ s[7] ^ s[12] ^ s[17] ^ s[22];
		t[3] = s[3] ^ s[8] ^ s[13] ^ s[18] ^ s[23];
		t[4] = s[4] ^ s[9] ^ s[14] ^ s[19] ^ s[24];

		/* theta: d[i] = c[i+4] ^ rotl(c[i+1],1) */
		u[0] = t[4] ^ ROTL64(t[1], 1);
		u[1] = t[0] ^ ROTL64(t[2], 1);
		u[2] = t[1] ^ ROTL64(t[3], 1);
		u[3] = t[2] ^ ROTL64(t[4], 1);
		u[4] = t[3] ^ ROTL64(t[0], 1);

		/* theta: a[0,i], a[1,i], .. a[4,i] ^= d[i] */
		s[0] ^= u[0]; s[5] ^= u[0]; s[10] ^= u[0]; s[15] ^= u[0]; s[20] ^= u[0];
		s[1] ^= u[1]; s[6] ^= u[1]; s[11] ^= u[1]; s[16] ^= u[1]; s[21] ^= u[1];
		s[2] ^= u[2]; s[7] ^= u[2]; s[12] ^= u[2]; s[17] ^= u[2]; s[22] ^= u[2];
		s[3] ^= u[3]; s[8] ^= u[3]; s[13] ^= u[3]; s[18] ^= u[3]; s[23] ^= u[3];
		s[4] ^= u[4]; s[9] ^= u[4]; s[14] ^= u[4]; s[19] ^= u[4]; s[24] ^= u[4];

		/* rho pi: b[..] = rotl(a[..], ..) */
		v = s[ 1];
		s[ 1] = ROTL64(s[ 6], 44);
		s[ 6] = ROTL64(s[ 9], 20);
		s[ 9] = ROTL64(s[22], 61);
		s[22] = ROTL64(s[14], 39);
		s[14] = ROTL64(s[20], 18);
		s[20] = ROTL64(s[ 2], 62);
		s[ 2] = ROTL64(s[12], 43);
		s[12] = ROTL64(s[13], 25);
		s[13] = ROTL64(s[19],  8);
		s[19] = ROTL64(s[23], 56);
		s[23] = ROTL64(s[15], 41);
		s[15] = ROTL64(s[ 4], 27);
		s[ 4] = ROTL64(s[24], 14);
		s[24] = ROTL64(s[21],  2);
		s[21] = ROTL64(s[ 8], 55);
		s[ 8] = ROTL64(s[16], 45);
		s[16] = ROTL64(s[ 5], 36);
		s[ 5] = ROTL64(s[ 3], 28);
		s[ 3] = ROTL64(s[18], 21);
		s[18] = ROTL64(s[17], 15);
		s[17] = ROTL64(s[11], 10);
		s[11] = ROTL64(s[ 7],  6);
		s[ 7] = ROTL64(s[10],  3);
		s[10] = ROTL64(    v,  1);

		/* chi: a[i,j] ^= ~b[i,j+1] & b[i,j+2] */
		v = s[ 0]; w = s[ 1]; s[ 0] ^= (~w) & s[ 2]; s[ 1] ^= (~s[ 2]) & s[ 3]; s[ 2] ^= (~s[ 3]) & s[ 4]; s[ 3] ^= (~s[ 4]) & v; s[ 4] ^= (~v) & w;
		v = s[ 5]; w = s[ 6]; s[ 5] ^= (~w) & s[ 7]; s[ 6] ^= (~s[ 7]) & s[ 8]; s[ 7] ^= (~s[ 8]) & s[ 9]; s[ 8] ^= (~s[ 9]) & v; s[ 9] ^= (~v) & w;
		v = s[10]; w = s[11]; s[10] ^= (~w) & s[12]; s[11] ^= (~s[12]) & s[13]; s[12] ^= (~s[13]) & s[14]; s[13] ^= (~s[14]) & v; s[14] ^= (~v) & w;
		v = s[15]; w = s[16]; s[15] ^= (~w) & s[17]; s[16] ^= (~s[17]) & s[18]; s[17] ^= (~s[18]) & s[19]; s[18] ^= (~s[19]) & v; s[19] ^= (~v) & w;
		v = s[20]; w = s[21]; s[20] ^= (~w) & s[22]; s[21] ^= (~s[22]) & s[23]; s[22] ^= (~s[23]) & s[24]; s[23] ^= (~s[24]) & v; s[24] ^= (~v) & w;

		/* iota: a[0,0] ^= round constant */
		s[0] ^= d_keccak_round_constants[i];
	}
}

__global__
void quark_keccak512_gpu_hash_64_v30(uint32_t threads, uint32_t startNounce, uint64_t *g_hash, uint32_t *g_nonceVector)
{
	uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
=======
		int hashPosition = nounce - startNounce;
		uint2 *inpHash = &g_hash[8 * hashPosition];

		uint2 s[25];
		uint2 bc[5], tmpxor[5], tmp1, tmp2;

		uint2 msg[8];

		uint28 *phash = (uint28*)inpHash;
		uint28 *outpt = (uint28*)msg;
		outpt[0] = phash[0];
		outpt[1] = phash[1];

		tmpxor[0] = msg[0] ^ msg[5];
		tmpxor[1] = msg[1] ^ msg[6];
		tmpxor[2] = msg[2] ^ msg[7];
//		tmpxor[3] = msg[3] ^ make_uint2(0x1, 0x80000000);
		tmpxor[3].x = msg[3].x ^ 0x1;
		tmpxor[3].y = msg[3].y ^ 0x80000000;
		tmpxor[4] = msg[4];
		
		bc[0] = tmpxor[0] ^ ROL2(tmpxor[2], 1);
		bc[1] = tmpxor[1] ^ ROL2(tmpxor[3], 1);
		bc[2] = tmpxor[2] ^ ROL2(tmpxor[4], 1);
		bc[3] = tmpxor[3] ^ ROL2(tmpxor[0], 1);
		bc[4] = tmpxor[4] ^ ROL2(tmpxor[1], 1);

		s[0] = inpHash[0] ^ bc[4];
		s[1] = ROL2(inpHash[6] ^ bc[0], 44);
		s[6] = ROL2(bc[3], 20);
		s[9] = ROL2(bc[1], 61);
		s[22] = ROL2(bc[3], 39);
		s[14] = ROL2(bc[4], 18);
		s[20] = ROL2(inpHash[2] ^ bc[1], 62);
		s[2] = ROL2(bc[1], 43);
		s[12] = ROL2(bc[2], 25);
		s[13] = ROL8(bc[3]);
		s[19] = ROR8(bc[2]);
		s[23] = ROL2(bc[4], 41);
		s[15] = ROL2(inpHash[4] ^ bc[3], 27);
		s[4] = ROL2(bc[3], 14);
		s[24] = ROL2(bc[0], 2);
		s[21] = ROL2(make_uint2(0x1, 0x80000000) ^ bc[2], 55);
		s[8] = ROL2(bc[0], 45);
		s[16] = ROL2(inpHash[5] ^ bc[4], 36);
		s[5] = ROL2(inpHash[3] ^ bc[2], 28);
		s[3] = ROL2(bc[2], 21);
		s[18] = ROL2(bc[1], 15);
		s[17] = ROL2(bc[0], 10);
		s[11] = ROL2(inpHash[7] ^ bc[1], 6);
		s[7] = ROL2(bc[4], 3);
		s[10] = ROL2(inpHash[1] ^ bc[0], 1);

		tmp1 = s[0]; tmp2 = s[1]; s[0] = bitselect(s[0] ^ s[2], s[0], s[1]); s[1] = bitselect(s[1] ^ s[3], s[1], s[2]); s[2] = bitselect(s[2] ^ s[4], s[2], s[3]); s[3] = bitselect(s[3] ^ tmp1, s[3], s[4]); s[4] = bitselect(s[4] ^ tmp2, s[4], tmp1);
		tmp1 = s[5]; tmp2 = s[6]; s[5] = bitselect(s[5] ^ s[7], s[5], s[6]); s[6] = bitselect(s[6] ^ s[8], s[6], s[7]); s[7] = bitselect(s[7] ^ s[9], s[7], s[8]); s[8] = bitselect(s[8] ^ tmp1, s[8], s[9]); s[9] = bitselect(s[9] ^ tmp2, s[9], tmp1);
		tmp1 = s[10]; tmp2 = s[11]; s[10] = bitselect(s[10] ^ s[12], s[10], s[11]); s[11] = bitselect(s[11] ^ s[13], s[11], s[12]); s[12] = bitselect(s[12] ^ s[14], s[12], s[13]); s[13] = bitselect(s[13] ^ tmp1, s[13], s[14]); s[14] = bitselect(s[14] ^ tmp2, s[14], tmp1);
		tmp1 = s[15]; tmp2 = s[16]; s[15] = bitselect(s[15] ^ s[17], s[15], s[16]); s[16] = bitselect(s[16] ^ s[18], s[16], s[17]); s[17] = bitselect(s[17] ^ s[19], s[17], s[18]); s[18] = bitselect(s[18] ^ tmp1, s[18], s[19]); s[19] = bitselect(s[19] ^ tmp2, s[19], tmp1);
		tmp1 = s[20]; tmp2 = s[21]; s[20] = bitselect(s[20] ^ s[22], s[20], s[21]); s[21] = bitselect(s[21] ^ s[23], s[21], s[22]); s[22] = bitselect(s[22] ^ s[24], s[22], s[23]); s[23] = bitselect(s[23] ^ tmp1, s[23], s[24]); s[24] = bitselect(s[24] ^ tmp2, s[24], tmp1);
		s[0].x ^= 1;

#pragma nounroll 
		for (int i = 1; i < 23; ++i)
		{

#pragma unroll
			for (int x = 0; x < 5; x++)
				tmpxor[x] = s[x] ^ s[x + 5] ^ s[x + 10] ^ s[x + 15] ^ s[x + 20];

			bc[0] = tmpxor[0] ^ ROL2(tmpxor[2], 1);
			bc[1] = tmpxor[1] ^ ROL2(tmpxor[3], 1);
			bc[2] = tmpxor[2] ^ ROL2(tmpxor[4], 1);
			bc[3] = tmpxor[3] ^ ROL2(tmpxor[0], 1);
			bc[4] = tmpxor[4] ^ ROL2(tmpxor[1], 1);

			tmp1 = s[1] ^ bc[0];

			s[0] ^= bc[4];
			s[1] = ROL2(s[6] ^ bc[0], 44);
			s[6] = ROL2(s[9] ^ bc[3], 20);
			s[9] = ROL2(s[22] ^ bc[1], 61);
			s[22] = ROL2(s[14] ^ bc[3], 39);
			s[14] = ROL2(s[20] ^ bc[4], 18);
			s[20] = ROL2(s[2] ^ bc[1], 62);
			s[2] = ROL2(s[12] ^ bc[1], 43);
			s[12] = ROL2(s[13] ^ bc[2], 25);
			s[13] = ROL8(s[19] ^ bc[3]);
			s[19] = ROR8(s[23] ^ bc[2]);
			s[23] = ROL2(s[15] ^ bc[4], 41);
			s[15] = ROL2(s[4] ^ bc[3], 27);
			s[4] = ROL2(s[24] ^ bc[3], 14);
			s[24] = ROL2(s[21] ^ bc[0], 2);
			s[21] = ROL2(s[8] ^ bc[2], 55);
			s[8] = ROL2(s[16] ^ bc[0], 45);
			s[16] = ROL2(s[5] ^ bc[4], 36);
			s[5] = ROL2(s[3] ^ bc[2], 28);
			s[3] = ROL2(s[18] ^ bc[2], 21);
			s[18] = ROL2(s[17] ^ bc[1], 15);
			s[17] = ROL2(s[11] ^ bc[0], 10);
			s[11] = ROL2(s[7] ^ bc[1], 6);
			s[7] = ROL2(s[10] ^ bc[4], 3);
			s[10] = ROL2(tmp1, 1);

			tmp1 = s[0]; tmp2 = s[1]; s[0] = bitselect(s[0] ^ s[2], s[0], s[1]); 
			s[0] ^= c_keccak_round_constants35[i];
			s[1] = bitselect(s[1] ^ s[3], s[1], s[2]); s[2] = bitselect(s[2] ^ s[4], s[2], s[3]); s[3] = bitselect(s[3] ^ tmp1, s[3], s[4]); s[4] = bitselect(s[4] ^ tmp2, s[4], tmp1);
			tmp1 = s[5]; tmp2 = s[6]; s[5] = bitselect(s[5] ^ s[7], s[5], s[6]); s[6] = bitselect(s[6] ^ s[8], s[6], s[7]); s[7] = bitselect(s[7] ^ s[9], s[7], s[8]); s[8] = bitselect(s[8] ^ tmp1, s[8], s[9]); s[9] = bitselect(s[9] ^ tmp2, s[9], tmp1);
			tmp1 = s[10]; tmp2 = s[11]; s[10] = bitselect(s[10] ^ s[12], s[10], s[11]); s[11] = bitselect(s[11] ^ s[13], s[11], s[12]); s[12] = bitselect(s[12] ^ s[14], s[12], s[13]); s[13] = bitselect(s[13] ^ tmp1, s[13], s[14]); s[14] = bitselect(s[14] ^ tmp2, s[14], tmp1);
			tmp1 = s[15]; tmp2 = s[16]; s[15] = bitselect(s[15] ^ s[17], s[15], s[16]); s[16] = bitselect(s[16] ^ s[18], s[16], s[17]); s[17] = bitselect(s[17] ^ s[19], s[17], s[18]); s[18] = bitselect(s[18] ^ tmp1, s[18], s[19]); s[19] = bitselect(s[19] ^ tmp2, s[19], tmp1);
			tmp1 = s[20]; tmp2 = s[21]; s[20] = bitselect(s[20] ^ s[22], s[20], s[21]); s[21] = bitselect(s[21] ^ s[23], s[21], s[22]); s[22] = bitselect(s[22] ^ s[24], s[22], s[23]); s[23] = bitselect(s[23] ^ tmp1, s[23], s[24]); s[24] = bitselect(s[24] ^ tmp2, s[24], tmp1);
		}

#pragma unroll
		for (uint32_t x = 0; x < 5; x++)
			tmpxor[x] = s[x] ^ s[x + 5] ^ s[x + 10] ^ s[x + 15] ^ s[x + 20];

		bc[0] = tmpxor[0] ^ ROL2(tmpxor[2], 1);
		bc[1] = tmpxor[1] ^ ROL2(tmpxor[3], 1);
		bc[2] = tmpxor[2] ^ ROL2(tmpxor[4], 1);
		bc[3] = tmpxor[3] ^ ROL2(tmpxor[0], 1);
		bc[4] = tmpxor[4] ^ ROL2(tmpxor[1], 1);

		tmp1 = s[1] ^ bc[0];

		s[0] ^= bc[4];
		s[1] = ROL2(s[6] ^ bc[0], 44);
		s[6] = ROL2(s[9] ^ bc[3], 20);
		s[9] = ROL2(s[22] ^ bc[1], 61);
		s[22] = ROL2(s[14] ^ bc[3], 39);
		s[14] = ROL2(s[20] ^ bc[4], 18);
		s[20] = ROL2(s[2] ^ bc[1], 62);
		s[2] = ROL2(s[12] ^ bc[1], 43);
		s[12] = ROL2(s[13] ^ bc[2], 25);
		s[13] = ROL8(s[19] ^ bc[3]);
		s[19] = ROR8(s[23] ^ bc[2]);
		s[23] = ROL2(s[15] ^ bc[4], 41);
		s[15] = ROL2(s[4] ^ bc[3], 27);
		s[4] = ROL2(s[24] ^ bc[3], 14);
		s[24] = ROL2(s[21] ^ bc[0], 2);
		s[21] = ROL2(s[8] ^ bc[2], 55);
		s[8] = ROL2(s[16] ^ bc[0], 45);
		s[16] = ROL2(s[5] ^ bc[4], 36);
		s[5] = ROL2(s[3] ^ bc[2], 28);
		s[3] = ROL2(s[18] ^ bc[2], 21);
		s[18] = ROL2(s[17] ^ bc[1], 15);
		s[17] = ROL2(s[11] ^ bc[0], 10);
		s[11] = ROL2(s[7] ^ bc[1], 6);
		s[7] = ROL2(s[10] ^ bc[4], 3);
		s[10] = ROL2(tmp1, 1);
		tmp1 = s[0];
		tmp2 = s[1];

		uint2 skein_p[8], h[9];


		s[0] = bitselect(s[0] ^ s[2], s[0], s[1]);
		s[0].x ^= 0x80008008ul;
		s[0].y ^= 0x80000000;
		s[1] = bitselect(s[1] ^ s[3], s[1], s[2]);
		s[2] = bitselect(s[2] ^ s[4], s[2], s[3]);
		s[3] = bitselect(s[3] ^ tmp1, s[3], s[4]);
		s[4] = bitselect(s[4] ^ tmp2, s[4], tmp1);
		//		tmp1 = s[5]; tmp2 = s[6];
		s[5] = bitselect(s[5] ^ s[7], s[5], s[6]);
		s[6] = bitselect(s[6] ^ s[8], s[6], s[7]);
		s[7] = bitselect(s[7] ^ s[9], s[7], s[8]); 
		

	h[0] = skein_p[0] = (s[0]);
	h[1] = skein_p[1] = (s[1]);
	h[2] = skein_p[2] = (s[2]);
	h[3] = skein_p[3] = (s[3]);
	h[4] = skein_p[4] = (s[4]);
	h[5] = skein_p[5] = (s[5]);
	h[6] = skein_p[6] = (s[6]);
	h[7] = skein_p[7] = (s[7]);

	skein_p[0] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[1] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[2] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[3] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[4] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[5] += vectorize(0xEABE394CA9D5C434ULL);
	skein_p[6] += vectorize(0x891112C71A75B523ULL);
	skein_p[7] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[1] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[2] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[3] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[4] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[5] += vectorize(0x891112C71A75B523ULL);
	skein_p[6] += vectorize(0x9E18A40B660FCC73ULL);
	skein_p[7] += vectorize(0xcab2076d98173ec4ULL + 1);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[1] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[2] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[3] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[4] += vectorize(0x991112C71A75B523ULL);
	skein_p[5] += vectorize(0x9E18A40B660FCC73ULL);
	skein_p[6] += vectorize(0xCAB2076D98173F04ULL);
	skein_p[7] += vectorize(0x4903ADFF749C51D0ULL);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[1] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[2] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[3] += vectorize(0x991112C71A75B523ULL);
	skein_p[4] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[5] += vectorize(0xcab2076d98173f04ULL);
	skein_p[6] += vectorize(0x3903ADFF749C51CEULL);
	skein_p[7] += vectorize(0x0D95DE399746DF03ULL + 3);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[1] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[2] += vectorize(0x991112C71A75B523ULL);
	skein_p[3] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[4] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[5] += vectorize(0x3903ADFF749C51CEULL);
	skein_p[6] += vectorize(0xFD95DE399746DF43ULL);
	skein_p[7] += vectorize(0x8FD1934127C79BD2ULL);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[1] += vectorize(0x991112C71A75B523ULL);
	skein_p[2] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[3] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[4] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[5] += vectorize(0x0D95DE399746DF03ULL + 0xf000000000000040ULL);
	skein_p[6] += vectorize(0x8FD1934127C79BCEULL + 0x0000000000000040ULL);
	skein_p[7] += vectorize(0x9A255629FF352CB1ULL + 5);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0x991112C71A75B523ULL);
	skein_p[1] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[2] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[3] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[4] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[5] += vectorize(0x8FD1934127C79BCEULL + 0x0000000000000040ULL);
	skein_p[6] += vectorize(0x8A255629FF352CB1ULL);
	skein_p[7] += vectorize(0x5DB62599DF6CA7B0ULL + 6);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[1] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[2] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[3] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[4] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[5] += vectorize(0x8A255629FF352CB1ULL);
	skein_p[6] += vectorize(0x4DB62599DF6CA7F0ULL);
	skein_p[7] += vectorize(0xEABE394CA9D5C3F4ULL + 7);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[1] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[2] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[3] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[4] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[5] += vectorize(0x4DB62599DF6CA7F0ULL);
	skein_p[6] += vectorize(0xEABE394CA9D5C434ULL);
	skein_p[7] += vectorize(0x991112C71A75B52BULL);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[1] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[2] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[3] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[4] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[5] += vectorize(0xEABE394CA9D5C434ULL);
	skein_p[6] += vectorize(0x891112C71A75B523ULL);
	skein_p[7] += vectorize(0xAE18A40B660FCC33ULL + 9);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[1] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[2] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[3] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[4] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[5] += vectorize(0x891112C71A75B523ULL);
	skein_p[6] += vectorize(0x9E18A40B660FCC73ULL);
	skein_p[7] += vectorize(0xcab2076d98173eceULL);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[1] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[2] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[3] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[4] += vectorize(0x991112C71A75B523ULL);
	skein_p[5] += vectorize(0x9E18A40B660FCC73ULL);
	skein_p[6] += vectorize(0xcab2076d98173ec4ULL + 0x0000000000000040ULL);
	skein_p[7] += vectorize(0x4903ADFF749C51CEULL + 11);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[1] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[2] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[3] += vectorize(0x991112C71A75B523ULL);
	skein_p[4] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[5] += vectorize(0xcab2076d98173ec4ULL + 0x0000000000000040ULL);
	skein_p[6] += vectorize(0x3903ADFF749C51CEULL);
	skein_p[7] += vectorize(0x0D95DE399746DF03ULL + 12);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[1] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[2] += vectorize(0x991112C71A75B523ULL);
	skein_p[3] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[4] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[5] += vectorize(0x3903ADFF749C51CEULL);
	skein_p[6] += vectorize(0x0D95DE399746DF03ULL + 0xf000000000000040ULL);
	skein_p[7] += vectorize(0x8FD1934127C79BCEULL + 13);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0xEABE394CA9D5C3F4ULL);
	skein_p[1] += vectorize(0x991112C71A75B523ULL);
	skein_p[2] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[3] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[4] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[5] += vectorize(0x0D95DE399746DF03ULL + 0xf000000000000040ULL);
	skein_p[6] += vectorize(0x8FD1934127C79BCEULL + 0x0000000000000040ULL);
	skein_p[7] += vectorize(0x9A255629FF352CB1ULL + 14);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0x991112C71A75B523ULL);
	skein_p[1] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[2] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[3] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[4] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[5] += vectorize(0x8FD1934127C79BCEULL + 0x0000000000000040ULL);
	skein_p[6] += vectorize(0x8A255629FF352CB1ULL);
	skein_p[7] += vectorize(0x5DB62599DF6CA7B0ULL + 15);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0xAE18A40B660FCC33ULL);
	skein_p[1] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[2] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[3] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[4] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[5] += vectorize(0x8A255629FF352CB1ULL);
	skein_p[6] += vectorize(0x4DB62599DF6CA7F0ULL);
	skein_p[7] += vectorize(0xEABE394CA9D5C3F4ULL + 16ULL);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 46) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 36) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 19) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 37) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 33) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 27) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 14) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 42) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 17) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 49) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 36) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 39) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 44) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 9) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 54) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROR8(skein_p[3]) ^ skein_p[4];
	skein_p[0] += vectorize(0xcab2076d98173ec4ULL);
	skein_p[1] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[2] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[3] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[4] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[5] += vectorize(0x4DB62599DF6CA7F0ULL);
	skein_p[6] += vectorize(0xEABE394CA9D5C3F4ULL + 0x0000000000000040ULL);
	skein_p[7] += vectorize(0x991112C71A75B523ULL + 17);
	skein_p[0] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 39) ^ skein_p[0];
	skein_p[2] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 30) ^ skein_p[2];
	skein_p[4] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 34) ^ skein_p[4];
	skein_p[6] += skein_p[7];
	skein_p[7] = ROL24(skein_p[7]) ^ skein_p[6];
	skein_p[2] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 13) ^ skein_p[2];
	skein_p[4] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 50) ^ skein_p[4];
	skein_p[6] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 10) ^ skein_p[6];
	skein_p[0] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 17) ^ skein_p[0];
	skein_p[4] += skein_p[1];
	skein_p[1] = ROL2(skein_p[1], 25) ^ skein_p[4];
	skein_p[6] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 29) ^ skein_p[6];
	skein_p[0] += skein_p[5];
	skein_p[5] = ROL2(skein_p[5], 39) ^ skein_p[0];
	skein_p[2] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 43) ^ skein_p[2];
	skein_p[6] += skein_p[1];
	skein_p[1] = ROL8(skein_p[1]) ^ skein_p[6];
	skein_p[0] += skein_p[7];
	skein_p[7] = ROL2(skein_p[7], 35) ^ skein_p[0];
	skein_p[2] += skein_p[5];
	skein_p[5] = ROR8(skein_p[5]) ^ skein_p[2];
	skein_p[4] += skein_p[3];
	skein_p[3] = ROL2(skein_p[3], 22) ^ skein_p[4];
	skein_p[0] += vectorize(0x4903ADFF749C51CEULL);
	skein_p[1] += vectorize(0x0D95DE399746DF03ULL);
	skein_p[2] += vectorize(0x8FD1934127C79BCEULL);
	skein_p[3] += vectorize(0x9A255629FF352CB1ULL);
	skein_p[4] += vectorize(0x5DB62599DF6CA7B0ULL);
	skein_p[5] += vectorize(0xEABE394CA9D5C3F4ULL + 0x0000000000000040ULL);
	skein_p[6] += vectorize(0x891112C71A75B523ULL);
	skein_p[7] += vectorize(0xAE18A40B660FCC33ULL + 18);

#define h0 skein_p[0]
#define h1 skein_p[1]
#define h2 skein_p[2]
#define h3 skein_p[3]
#define h4 skein_p[4]
#define h5 skein_p[5]
#define h6 skein_p[6]
#define h7 skein_p[7]
	h0 ^= h[0];
	h1 ^= h[1];
	h2 ^= h[2];
	h3 ^= h[3];
	h4 ^= h[4];
	h5 ^= h[5];
	h6 ^= h[6];
	h7 ^= h[7];

	uint2 skein_h8 = h0 ^ h1 ^ h2 ^ h3 ^ h4 ^ h5 ^ h6 ^ h7 ^ vectorize(0x1BD11BDAA9FC1A22ULL);

	uint2 hash64[8];

	hash64[0] = (h0);
	//		hash64[1] = (h1);
	hash64[2] = (h2);
	//		hash64[3] = (h3);
	hash64[4] = (h4);
	hash64[5] = (h5 + vectorizelow(8ULL));
	hash64[6] = (h6 + vectorizehigh(0xff000000UL));
	//		hash64[7] = (h7);

	hash64[0] += h1;
	hash64[1] = ROL2(h1, 46) ^ hash64[0];
	hash64[2] += h3;
	hash64[3] = ROL2(h3, 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += h7;
	hash64[7] = ROL2(h7, 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + h1);
	hash64[1] = (hash64[1] + h2);
	hash64[2] = (hash64[2] + h3);
	hash64[3] = (hash64[3] + h4);
	hash64[4] = (hash64[4] + h5);
	hash64[5] = (hash64[5] + h6 + vectorizehigh(0xff000000UL));
	hash64[6] = (hash64[6] + h7 + vectorize(0xff00000000000008ULL));
	hash64[7] = (hash64[7] + skein_h8 + vectorizelow(1));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];
	hash64[0] = (hash64[0] + h2);
	hash64[1] = (hash64[1] + h3);
	hash64[2] = (hash64[2] + h4);
	hash64[3] = (hash64[3] + h5);
	hash64[4] = (hash64[4] + h6);
	hash64[5] = (hash64[5] + h7 + vectorize(0xff00000000000008ULL));
	hash64[6] = (hash64[6] + skein_h8 + vectorizelow(8ULL));
	hash64[7] = (hash64[7] + h0 + vectorize(2));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 46) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL2(hash64[7], 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + h3);
	hash64[1] = (hash64[1] + h4);
	hash64[2] = (hash64[2] + h5);
	hash64[3] = (hash64[3] + h6);
	hash64[4] = (hash64[4] + h7);
	hash64[5] = (hash64[5] + skein_h8 + vectorizelow(8));
	hash64[6] = (hash64[6] + h0 + vectorizehigh(0xff000000UL));
	hash64[7] = (hash64[7] + h1 + vectorizelow(3));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];
	hash64[0] = (hash64[0] + h4);
	hash64[1] = (hash64[1] + h5);
	hash64[2] = (hash64[2] + h6);
	hash64[3] = (hash64[3] + h7);
	hash64[4] = (hash64[4] + skein_h8);
	hash64[5] = (hash64[5] + h0 + vectorizehigh(0xff000000UL));
	hash64[6] = (hash64[6] + h1 + vectorize(0xff00000000000008ULL));
	hash64[7] = (hash64[7] + h2 + vectorizelow(4));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 46) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL2(hash64[7], 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + h5);
	hash64[1] = (hash64[1] + h6);
	hash64[2] = (hash64[2] + h7);
	hash64[3] = (hash64[3] + skein_h8);
	hash64[4] = (hash64[4] + h0);
	hash64[5] = (hash64[5] + h1 + vectorize(0xff00000000000008ULL));
	hash64[6] = (hash64[6] + h2 + vectorizelow(8ULL));
	hash64[7] = (hash64[7] + h3 + vectorizelow(5));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];
	hash64[0] = (hash64[0] + h6);
	hash64[1] = (hash64[1] + h7);
	hash64[2] = (hash64[2] + skein_h8);
	hash64[3] = (hash64[3] + h0);
	hash64[4] = (hash64[4] + h1);
	hash64[5] = (hash64[5] + h2 + vectorizelow(8ULL));
	hash64[6] = (hash64[6] + h3 + vectorizehigh(0xff000000UL));
	hash64[7] = (hash64[7] + h4 + vectorizelow(6));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 46) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL2(hash64[7], 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + h7);
	hash64[1] = (hash64[1] + skein_h8);
	hash64[2] = (hash64[2] + h0);
	hash64[3] = (hash64[3] + h1);
	hash64[4] = (hash64[4] + h2);
	hash64[5] = (hash64[5] + h3 + vectorizehigh(0xff000000UL));
	hash64[6] = (hash64[6] + h4 + vectorize(0xff00000000000008ULL));
	hash64[7] = (hash64[7] + h5 + vectorizelow(7));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];
	hash64[0] = (hash64[0] + skein_h8);
	hash64[1] = (hash64[1] + h0);
	hash64[2] = (hash64[2] + h1);
	hash64[3] = (hash64[3] + h2);
	hash64[4] = (hash64[4] + h3);
	hash64[5] = (hash64[5] + h4 + vectorize(0xff00000000000008ULL));
	hash64[6] = (hash64[6] + h5 + vectorizelow(8));
	hash64[7] = (hash64[7] + h6 + vectorizelow(8));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 46) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL2(hash64[7], 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + h0);
	hash64[1] = (hash64[1] + h1);
	hash64[2] = (hash64[2] + h2);
	hash64[3] = (hash64[3] + h3);
	hash64[4] = (hash64[4] + h4);
	hash64[5] = (hash64[5] + h5 + vectorizelow(8));
	hash64[6] = (hash64[6] + h6 + vectorizehigh(0xff000000UL));
	hash64[7] = (hash64[7] + h7 + vectorizelow(9));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];

	hash64[0] = (hash64[0] + h1);
	hash64[1] = (hash64[1] + h2);
	hash64[2] = (hash64[2] + h3);
	hash64[3] = (hash64[3] + h4);
	hash64[4] = (hash64[4] + h5);
	hash64[5] = (hash64[5] + h6 + vectorizehigh(0xff000000UL));
	hash64[6] = (hash64[6] + h7 + vectorize(0xff00000000000008ULL));
	hash64[7] = (hash64[7] + skein_h8 + (vectorizelow(10)));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 46) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL2(hash64[7], 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + h2);
	hash64[1] = (hash64[1] + h3);
	hash64[2] = (hash64[2] + h4);
	hash64[3] = (hash64[3] + h5);
	hash64[4] = (hash64[4] + h6);
	hash64[5] = (hash64[5] + h7 + vectorize(0xff00000000000008ULL));
	hash64[6] = (hash64[6] + skein_h8 + vectorizelow(8ULL));
	hash64[7] = (hash64[7] + h0 + vectorizelow(11));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];
	hash64[0] = (hash64[0] + h3);
	hash64[1] = (hash64[1] + h4);
	hash64[2] = (hash64[2] + h5);
	hash64[3] = (hash64[3] + h6);
	hash64[4] = (hash64[4] + h7);
	hash64[5] = (hash64[5] + skein_h8 + vectorizelow(8));
	hash64[6] = (hash64[6] + h0 + vectorizehigh(0xff000000UL));
	hash64[7] = (hash64[7] + h1 + vectorizelow(12));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 46) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL2(hash64[7], 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + h4);
	hash64[1] = (hash64[1] + h5);
	hash64[2] = (hash64[2] + h6);
	hash64[3] = (hash64[3] + h7);
	hash64[4] = (hash64[4] + skein_h8);
	hash64[5] = (hash64[5] + h0 + vectorizehigh(0xff000000UL));
	hash64[6] = (hash64[6] + h1 + vectorize(0xff00000000000008ULL));
	hash64[7] = (hash64[7] + h2 + vectorizelow(13));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];
	hash64[0] = (hash64[0] + h5);
	hash64[1] = (hash64[1] + h6);
	hash64[2] = (hash64[2] + h7);
	hash64[3] = (hash64[3] + skein_h8);
	hash64[4] = (hash64[4] + h0);
	hash64[5] = (hash64[5] + h1 + vectorize(0xff00000000000008ULL));
	hash64[6] = (hash64[6] + h2 + vectorizelow(8ULL));
	hash64[7] = (hash64[7] + h3 + vectorizelow(14));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 46) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL2(hash64[7], 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + h6);
	hash64[1] = (hash64[1] + h7);
	hash64[2] = (hash64[2] + skein_h8);
	hash64[3] = (hash64[3] + h0);
	hash64[4] = (hash64[4] + h1);
	hash64[5] = (hash64[5] + h2 + vectorizelow(8ULL));
	hash64[6] = (hash64[6] + h3 + vectorizehigh(0xff000000UL));
	hash64[7] = (hash64[7] + h4 + vectorizelow(15));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];
	hash64[0] = (hash64[0] + h7);
	hash64[1] = (hash64[1] + skein_h8);
	hash64[2] = (hash64[2] + h0);
	hash64[3] = (hash64[3] + h1);
	hash64[4] = (hash64[4] + h2);
	hash64[5] = (hash64[5] + h3 + vectorizehigh(0xff000000UL));
	hash64[6] = (hash64[6] + h4 + vectorize(0xff00000000000008ULL));
	hash64[7] = (hash64[7] + h5 + vectorizelow(16));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 46) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 36) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 19) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL2(hash64[7], 37) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 33) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 27) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 14) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 42) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 17) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 49) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 36) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 39) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL2(hash64[1], 44) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 9) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROL2(hash64[5], 54) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROR8(hash64[3]) ^ hash64[4];
	hash64[0] = (hash64[0] + skein_h8);
	hash64[1] = (hash64[1] + h0);
	hash64[2] = (hash64[2] + h1);
	hash64[3] = (hash64[3] + h2);
	hash64[4] = (hash64[4] + h3);
	hash64[5] = (hash64[5] + h4 + vectorize(0xff00000000000008ULL));
	hash64[6] = (hash64[6] + h5 + vectorizelow(8ULL));
	hash64[7] = (hash64[7] + h6 + vectorizelow(17));
	hash64[0] += hash64[1];
	hash64[1] = ROL2(hash64[1], 39) ^ hash64[0];
	hash64[2] += hash64[3];
	hash64[3] = ROL2(hash64[3], 30) ^ hash64[2];
	hash64[4] += hash64[5];
	hash64[5] = ROL2(hash64[5], 34) ^ hash64[4];
	hash64[6] += hash64[7];
	hash64[7] = ROL24(hash64[7]) ^ hash64[6];
	hash64[2] += hash64[1];
	hash64[1] = ROL2(hash64[1], 13) ^ hash64[2];
	hash64[4] += hash64[7];
	hash64[7] = ROL2(hash64[7], 50) ^ hash64[4];
	hash64[6] += hash64[5];
	hash64[5] = ROL2(hash64[5], 10) ^ hash64[6];
	hash64[0] += hash64[3];
	hash64[3] = ROL2(hash64[3], 17) ^ hash64[0];
	hash64[4] += hash64[1];
	hash64[1] = ROL2(hash64[1], 25) ^ hash64[4];
	hash64[6] += hash64[3];
	hash64[3] = ROL2(hash64[3], 29) ^ hash64[6];
	hash64[0] += hash64[5];
	hash64[5] = ROL2(hash64[5], 39) ^ hash64[0];
	hash64[2] += hash64[7];
	hash64[7] = ROL2(hash64[7], 43) ^ hash64[2];
	hash64[6] += hash64[1];
	hash64[1] = ROL8(hash64[1]) ^ hash64[6];
	hash64[0] += hash64[7];
	hash64[7] = ROL2(hash64[7], 35) ^ hash64[0];
	hash64[2] += hash64[5];
	hash64[5] = ROR8(hash64[5]) ^ hash64[2];
	hash64[4] += hash64[3];
	hash64[3] = ROL2(hash64[3], 22) ^ hash64[4];

	//#pragma unroll
	//		for (int i = 0; i<8; i++)
	//			inpHash[i] = s[i];
	uint64_t *outHash = (uint64_t *)&g_hash[8 * hashPosition];


	outHash[0] = devectorize(hash64[0] + h0);
	outHash[1] = devectorize(hash64[1] + h1);
	outHash[2] = devectorize(hash64[2] + h2);
	outHash[3] = devectorize(hash64[3] + h3);
	outHash[4] = devectorize(hash64[4] + h4);
	outHash[5] = devectorize(hash64[5] + h5) + 8;
	outHash[6] = devectorize(hash64[6] + h6) + 0xff00000000000000ULL;
	outHash[7] = devectorize(hash64[7] + h7) + 18;
	}

#undef h0
#undef h1
#undef h2
#undef h3
#undef h4
#undef h5
#undef h6
#undef h7
}

__global__ 
void quark_keccak512_gpu_hash_64_final(uint32_t threads, uint32_t startNounce, const uint2 *g_hash, uint32_t *g_nonceVector, uint32_t *const __restrict__ d_found, uint32_t target)
{
    const uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
>>>>>>> 8c320ca... added xevan
	if (thread < threads)
	{
		uint32_t nounce = (g_nonceVector != NULL) ? g_nonceVector[thread] : (startNounce + thread);

<<<<<<< HEAD
		off_t hashPosition = nounce - startNounce;
		uint32_t *inpHash = (uint32_t*)&g_hash[hashPosition * 8];

		uint32_t message[18];
		#pragma unroll 16
		for(int i=0;i<16;i++)
			message[i] = inpHash[i];

		message[16] = 0x01;
		message[17] = 0x80000000;

		uint64_t keccak_gpu_state[25];
		#pragma unroll 25
		for (int i=0; i<25; i++)
			keccak_gpu_state[i] = 0;

		keccak_block_v30(keccak_gpu_state, message);

		uint32_t hash[16];
		#pragma unroll 8
		for (size_t i = 0; i < 64; i += 8) {
			U64TO32_LE((&hash[i/4]), keccak_gpu_state[i / 8]);
		}

		uint32_t *outpHash = (uint32_t*)&g_hash[hashPosition * 8];
		#pragma unroll 16
		for(int i=0; i<16; i++)
			outpHash[i] = hash[i];
	}
}

__host__
void quark_keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, int order)
{
	const uint32_t threadsperblock = 256;

	dim3 grid((threads + threadsperblock-1)/threadsperblock);
	dim3 block(threadsperblock);

	int dev_id = device_map[thr_id];

	if (device_sm[dev_id] >= 320)
		quark_keccak512_gpu_hash_64<<<grid, block>>>(threads, startNounce, (uint64_t*)d_hash, d_nonceVector);
	else
		quark_keccak512_gpu_hash_64_v30<<<grid, block>>>(threads, startNounce, (uint64_t*)d_hash, d_nonceVector);

	MyStreamSynchronize(NULL, order, thr_id);
}

void jackpot_keccak512_cpu_init(int thr_id, uint32_t threads);
void jackpot_keccak512_cpu_setBlock(void *pdata, size_t inlen);
void jackpot_keccak512_cpu_hash(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_hash, int order);

__host__
void quark_keccak512_cpu_init(int thr_id, uint32_t threads)
{
	// required for the 64 bytes one
	cudaMemcpyToSymbol(d_keccak_round_constants, host_keccak_round_constants,
			sizeof(host_keccak_round_constants), 0, cudaMemcpyHostToDevice);

	jackpot_keccak512_cpu_init(thr_id, threads);
}

__host__
void keccak512_setBlock_80(int thr_id, uint32_t *endiandata)
{
	jackpot_keccak512_cpu_setBlock((void*)endiandata, 80);
}

__host__
void keccak512_cuda_hash_80(const int thr_id, const uint32_t threads, const uint32_t startNounce, uint32_t *d_hash)
{
	jackpot_keccak512_cpu_hash(thr_id, threads, startNounce, d_hash, 0);
}
=======
		int hashPosition = nounce - startNounce;
		const uint2 *inpHash = &g_hash[8 * hashPosition];

		uint2 msg[8];

		uint28 *phash = (uint28*)inpHash;
		uint28 *outpt = (uint28*)msg;
		outpt[0] = phash[0];
		outpt[1] = phash[1];

		uint2 s[25];
		uint2 bc[5], tmpxor[5], tmp1, tmp2;

		tmpxor[0] = msg[0] ^ msg[5];
		tmpxor[1] = msg[1] ^ msg[6];
		tmpxor[2] = msg[2] ^ msg[7];
		tmpxor[3] = msg[3] ^ make_uint2(0x1, 0x80000000);
		tmpxor[4] = msg[4];

		bc[0] = tmpxor[0] ^ ROL2(tmpxor[2], 1);
		bc[1] = tmpxor[1] ^ ROL2(tmpxor[3], 1);
		bc[2] = tmpxor[2] ^ ROL2(tmpxor[4], 1);
		bc[3] = tmpxor[3] ^ ROL2(tmpxor[0], 1);
		bc[4] = tmpxor[4] ^ ROL2(tmpxor[1], 1);

		s[0] = inpHash[0] ^ bc[4];
		s[1] = ROL2(inpHash[6] ^ bc[0], 44);
		s[6] = ROL2(bc[3], 20);
		s[9] = ROL2(bc[1], 61);
		s[22] = ROL2(bc[3], 39);
		s[14] = ROL2(bc[4], 18);
		s[20] = ROL2(inpHash[2] ^ bc[1], 62);
		s[2] = ROL2(bc[1], 43);
		s[12] = ROL2(bc[2], 25);
		s[13] = ROL8(bc[3]);
		s[19] = ROR8(bc[2]);
		s[23] = ROL2(bc[4], 41);
		s[15] = ROL2(inpHash[4] ^ bc[3], 27);
		s[4] = ROL2(bc[3], 14);
		s[24] = ROL2(bc[0], 2);
		s[21] = ROL2(make_uint2(0x1, 0x80000000) ^ bc[2], 55);
		s[8] = ROL2(bc[0], 45);
		s[16] = ROL2(inpHash[5] ^ bc[4], 36);
		s[5] = ROL2(inpHash[3] ^ bc[2], 28);
		s[3] = ROL2(bc[2], 21);
		s[18] = ROL2(bc[1], 15);
		s[17] = ROL2(bc[0], 10);
		s[11] = ROL2(inpHash[7] ^ bc[1], 6);
		s[7] = ROL2(bc[4], 3);
		s[10] = ROL2(inpHash[1] ^ bc[0], 1);

		tmp1 = s[0]; tmp2 = s[1]; s[0] = bitselect(s[0] ^ s[2], s[0], s[1]); s[1] = bitselect(s[1] ^ s[3], s[1], s[2]); s[2] = bitselect(s[2] ^ s[4], s[2], s[3]); s[3] = bitselect(s[3] ^ tmp1, s[3], s[4]); s[4] = bitselect(s[4] ^ tmp2, s[4], tmp1);
		tmp1 = s[5]; tmp2 = s[6]; s[5] = bitselect(s[5] ^ s[7], s[5], s[6]); s[6] = bitselect(s[6] ^ s[8], s[6], s[7]); s[7] = bitselect(s[7] ^ s[9], s[7], s[8]); s[8] = bitselect(s[8] ^ tmp1, s[8], s[9]); s[9] = bitselect(s[9] ^ tmp2, s[9], tmp1);
		tmp1 = s[10]; tmp2 = s[11]; s[10] = bitselect(s[10] ^ s[12], s[10], s[11]); s[11] = bitselect(s[11] ^ s[13], s[11], s[12]); s[12] = bitselect(s[12] ^ s[14], s[12], s[13]); s[13] = bitselect(s[13] ^ tmp1, s[13], s[14]); s[14] = bitselect(s[14] ^ tmp2, s[14], tmp1);
		tmp1 = s[15]; tmp2 = s[16]; s[15] = bitselect(s[15] ^ s[17], s[15], s[16]); s[16] = bitselect(s[16] ^ s[18], s[16], s[17]); s[17] = bitselect(s[17] ^ s[19], s[17], s[18]); s[18] = bitselect(s[18] ^ tmp1, s[18], s[19]); s[19] = bitselect(s[19] ^ tmp2, s[19], tmp1);
		tmp1 = s[20]; tmp2 = s[21]; s[20] = bitselect(s[20] ^ s[22], s[20], s[21]); s[21] = bitselect(s[21] ^ s[23], s[21], s[22]); s[22] = bitselect(s[22] ^ s[24], s[22], s[23]); s[23] = bitselect(s[23] ^ tmp1, s[23], s[24]); s[24] = bitselect(s[24] ^ tmp2, s[24], tmp1);
		s[0].x ^= 1;

#pragma nounroll
		for (int i = 1; i < 23; i++)
		{

#pragma unroll
			for (int x = 0; x < 5; x++)
				tmpxor[x] = s[x] ^ s[x + 5] ^ s[x + 10] ^ s[x + 15] ^ s[x + 20];

			bc[0] = tmpxor[0] ^ ROL2(tmpxor[2], 1);
			bc[1] = tmpxor[1] ^ ROL2(tmpxor[3], 1);
			bc[2] = tmpxor[2] ^ ROL2(tmpxor[4], 1);
			bc[3] = tmpxor[3] ^ ROL2(tmpxor[0], 1);
			bc[4] = tmpxor[4] ^ ROL2(tmpxor[1], 1);

			tmp1 = s[1] ^ bc[0];

			s[0] ^= bc[4];
			s[1] = ROL2(s[6] ^ bc[0], 44);
			s[6] = ROL2(s[9] ^ bc[3], 20);
			s[9] = ROL2(s[22] ^ bc[1], 61);
			s[22] = ROL2(s[14] ^ bc[3], 39);
			s[14] = ROL2(s[20] ^ bc[4], 18);
			s[20] = ROL2(s[2] ^ bc[1], 62);
			s[2] = ROL2(s[12] ^ bc[1], 43);
			s[12] = ROL2(s[13] ^ bc[2], 25);
			s[13] = ROL8(s[19] ^ bc[3]);
			s[19] = ROR8(s[23] ^ bc[2]);
			s[23] = ROL2(s[15] ^ bc[4], 41);
			s[15] = ROL2(s[4] ^ bc[3], 27);
			s[4] = ROL2(s[24] ^ bc[3], 14);
			s[24] = ROL2(s[21] ^ bc[0], 2);
			s[21] = ROL2(s[8] ^ bc[2], 55);
			s[8] = ROL2(s[16] ^ bc[0], 45);
			s[16] = ROL2(s[5] ^ bc[4], 36);
			s[5] = ROL2(s[3] ^ bc[2], 28);
			s[3] = ROL2(s[18] ^ bc[2], 21);
			s[18] = ROL2(s[17] ^ bc[1], 15);
			s[17] = ROL2(s[11] ^ bc[0], 10);
			s[11] = ROL2(s[7] ^ bc[1], 6);
			s[7] = ROL2(s[10] ^ bc[4], 3);
			s[10] = ROL2(tmp1, 1);

			tmp1 = s[0]; tmp2 = s[1]; s[0] = bitselect(s[0] ^ s[2], s[0], s[1]);
			s[0] ^= c_keccak_round_constants35[i];
			s[1] = bitselect(s[1] ^ s[3], s[1], s[2]); s[2] = bitselect(s[2] ^ s[4], s[2], s[3]); s[3] = bitselect(s[3] ^ tmp1, s[3], s[4]); s[4] = bitselect(s[4] ^ tmp2, s[4], tmp1);
			tmp1 = s[5]; tmp2 = s[6]; s[5] = bitselect(s[5] ^ s[7], s[5], s[6]); s[6] = bitselect(s[6] ^ s[8], s[6], s[7]); s[7] = bitselect(s[7] ^ s[9], s[7], s[8]); s[8] = bitselect(s[8] ^ tmp1, s[8], s[9]); s[9] = bitselect(s[9] ^ tmp2, s[9], tmp1);
			tmp1 = s[10]; tmp2 = s[11]; s[10] = bitselect(s[10] ^ s[12], s[10], s[11]); s[11] = bitselect(s[11] ^ s[13], s[11], s[12]); s[12] = bitselect(s[12] ^ s[14], s[12], s[13]); s[13] = bitselect(s[13] ^ tmp1, s[13], s[14]); s[14] = bitselect(s[14] ^ tmp2, s[14], tmp1);
			tmp1 = s[15]; tmp2 = s[16]; s[15] = bitselect(s[15] ^ s[17], s[15], s[16]); s[16] = bitselect(s[16] ^ s[18], s[16], s[17]); s[17] = bitselect(s[17] ^ s[19], s[17], s[18]); s[18] = bitselect(s[18] ^ tmp1, s[18], s[19]); s[19] = bitselect(s[19] ^ tmp2, s[19], tmp1);
			tmp1 = s[20]; tmp2 = s[21]; s[20] = bitselect(s[20] ^ s[22], s[20], s[21]); s[21] = bitselect(s[21] ^ s[23], s[21], s[22]); s[22] = bitselect(s[22] ^ s[24], s[22], s[23]); s[23] = bitselect(s[23] ^ tmp1, s[23], s[24]); s[24] = bitselect(s[24] ^ tmp2, s[24], tmp1);
		}
		uint2 t[5];
		t[0] = s[0] ^ s[5] ^ s[10] ^ s[15] ^ s[20];
		t[1] = s[1] ^ s[6] ^ s[11] ^ s[16] ^ s[21];
		t[2] = s[2] ^ s[7] ^ s[12] ^ s[17] ^ s[22];
		t[3] = s[3] ^ s[8] ^ s[13] ^ s[18] ^ s[23];
		t[4] = s[4] ^ s[9] ^ s[14] ^ s[19] ^ s[24];

		s[0] ^= t[4] ^ ROL2(t[1], 1);
		s[18] ^= t[2] ^ ROL2(t[4], 1);
		s[24] ^= t[3] ^ ROL2(t[0], 1);

		s[3] = ROL2(s[18], 21) ^ ((~ROL2(s[24], 14)) & s[0]);

		if (s[3].y <= target)
		{
			uint32_t tmp = atomicCAS(d_found, 0xffffffff, nounce);
			if (tmp != 0xffffffff)
				d_found[1] = nounce;
		}

	}
}

__host__ void quark_keccak512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash)
{
    const uint32_t threadsperblock = 128;

    // berechne wie viele Thread Blocks wir brauchen
    dim3 grid((threads + threadsperblock-1)/threadsperblock);
    dim3 block(threadsperblock);

    quark_keccak512_gpu_hash_64<<<grid, block>>>(threads, startNounce, (uint2 *)d_hash, d_nonceVector);
}

__host__ void quark_keccak512_cpu_init(int thr_id)
{
	CUDA_SAFE_CALL(cudaMalloc(&(d_found[thr_id]), 2 * sizeof(uint32_t)));
}



__host__ void quark_keccak512_cpu_hash_64_final(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, uint32_t target, uint32_t *h_found)
{
	const uint32_t threadsperblock = 256;

	// berechne wie viele Thread Blocks wir brauchen
	dim3 grid((threads + threadsperblock - 1) / threadsperblock);
	dim3 block(threadsperblock);
	cudaMemset(d_found[thr_id], 0xffffffff, 2 * sizeof(uint32_t));
	quark_keccak512_gpu_hash_64_final << <grid, block >> >(threads, startNounce, (uint2 *)d_hash, d_nonceVector, d_found[thr_id],target);
	cudaMemcpy(h_found, d_found[thr_id], 2 * sizeof(uint32_t), cudaMemcpyDeviceToHost);
}

__host__ void quark_keccakskein512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash)
{
	const uint32_t threadsperblock = 128;

	// berechne wie viele Thread Blocks wir brauchen
	dim3 grid((threads + threadsperblock - 1) / threadsperblock);
	dim3 block(threadsperblock);

	quark_keccakskein512_gpu_hash_64 << <grid, block >> >(threads, startNounce, (uint2 *)d_hash, d_nonceVector);
}

>>>>>>> 8c320ca... added xevan
