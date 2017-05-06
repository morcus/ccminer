<<<<<<< HEAD
#include <memory.h> // memcpy()

#include "cuda_helper.h"

extern __device__ __device_builtin__ void __threadfence_block(void);

#define TPB 128

__constant__ uint32_t c_PaddedMessage80[32]; // padded message (80 bytes + padding)

#include "cuda_x11_aes.cuh"

__device__ __forceinline__
static void AES_ROUND_NOKEY(
	const uint32_t* __restrict__ sharedMemory,
	uint32_t &x0, uint32_t &x1, uint32_t &x2, uint32_t &x3)
{
	uint32_t y0, y1, y2, y3;
	aes_round(sharedMemory,
		x0, x1, x2, x3,
		y0, y1, y2, y3);

	x0 = y0;
	x1 = y1;
	x2 = y2;
	x3 = y3;
}

__device__ __forceinline__
static void KEY_EXPAND_ELT(
=======
#include "cuda_helper.h"
#include <memory.h> // memcpy()
#include "cuda_vector.h"

#if __CUDA_ARCH__ == 500
#define TPB 384
#else
#define TPB 352
#endif
__constant__ uint32_t c_PaddedMessage80[32]; // padded message (80 bytes + padding)

#include "cuda_x11_aes.cu"

__device__ __forceinline__
 void AES_ROUND_NOKEY(
	const uint32_t* __restrict__ sharedMemory,
	uint32_t &x0, uint32_t &x1, uint32_t &x2, uint32_t &x3)
{
	aes_round(sharedMemory,
		x0, x1, x2, x3,
		x0, x1, x2, x3);
}

__device__ __forceinline__
void KEY_EXPAND_ELT(
>>>>>>> 8c320ca... added xevan
	const uint32_t* __restrict__ sharedMemory,
	uint32_t &k0, uint32_t &k1, uint32_t &k2, uint32_t &k3)
{
	uint32_t y0, y1, y2, y3;
	aes_round(sharedMemory,
		k0, k1, k2, k3,
		y0, y1, y2, y3);

	k0 = y1;
	k1 = y2;
	k2 = y3;
	k3 = y0;
}
<<<<<<< HEAD

__device__ __forceinline__
static void c512(const uint32_t* sharedMemory, uint32_t *state, uint32_t *msg, const uint32_t count)
{
	uint32_t p0, p1, p2, p3, p4, p5, p6, p7;
	uint32_t p8, p9, pA, pB, pC, pD, pE, pF;
	uint32_t x0, x1, x2, x3;
	uint32_t rk00, rk01, rk02, rk03, rk04, rk05, rk06, rk07;
	uint32_t rk08, rk09, rk0A, rk0B, rk0C, rk0D, rk0E, rk0F;
	uint32_t rk10, rk11, rk12, rk13, rk14, rk15, rk16, rk17;
	uint32_t rk18, rk19, rk1A, rk1B, rk1C, rk1D, rk1E, rk1F;
	const uint32_t counter = count;

	p0 = state[0x0];
	p1 = state[0x1];
	p2 = state[0x2];
	p3 = state[0x3];
	p4 = state[0x4];
	p5 = state[0x5];
	p6 = state[0x6];
	p7 = state[0x7];
	p8 = state[0x8];
	p9 = state[0x9];
	pA = state[0xA];
	pB = state[0xB];
	pC = state[0xC];
	pD = state[0xD];
	pE = state[0xE];
	pF = state[0xF];

	/* round 0 */
	rk00 = msg[0];
	x0 = p4 ^ msg[0];
	rk01 = msg[1];
	x1 = p5 ^ msg[1];
	rk02 = msg[2];
	x2 = p6 ^ msg[2];
	rk03 = msg[3];
	x3 = p7 ^ msg[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk04 = msg[4];
	x0 ^= msg[4];
	rk05 = msg[5];
	x1 ^= msg[5];
	rk06 = msg[6];
	x2 ^= msg[6];
	rk07 = msg[7];
	x3 ^= msg[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk08 = msg[8];
	x0 ^= msg[8];
	rk09 = msg[9];
	x1 ^= msg[9];
	rk0A = msg[10];
	x2 ^= msg[10];
	rk0B = msg[11];
	x3 ^= msg[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk0C = msg[12];
	x0 ^= msg[12];
	rk0D = msg[13];
	x1 ^= msg[13];
	rk0E = msg[14];
	x2 ^= msg[14];
	rk0F = msg[15];
	x3 ^= msg[15];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
=======
__device__ __forceinline__
void shavite_gpu_init(uint32_t *sharedMemory)
{
	/* each thread startup will fill a uint32 */
	if (threadIdx.x < 256) {
		/* each thread startup will fill a uint32 */
		sharedMemory[threadIdx.x] = d_AES0[threadIdx.x];
		sharedMemory[threadIdx.x + 256] = ROL8(sharedMemory[threadIdx.x]);
		sharedMemory[threadIdx.x + 512] = ROL16(sharedMemory[threadIdx.x]);
		sharedMemory[threadIdx.x + 768] = ROL24(sharedMemory[threadIdx.x]);
		//		sharedMemory[threadIdx.x + 64 * 2 ] = d_AES0[threadIdx.x + 64 * 2];
		//		sharedMemory[threadIdx.x + 64 * 2 + 256] = d_AES1[threadIdx.x + 64 * 2];
		//		sharedMemory[threadIdx.x + 64 * 2 + 512] = d_AES2[threadIdx.x + 64 * 2];
		//		sharedMemory[threadIdx.x + 64 * 2 + 768] = d_AES3[threadIdx.x + 64 * 2];
	}
}

__device__ __forceinline__
static void c512(const uint32_t*const __restrict__ sharedMemory, uint32_t *const __restrict__  state, uint32_t *const __restrict__  msg)
{
	//	uint32_t p0, p1, p2, p3, p4, p5, p6, p7;
	//	uint32_t p8, p9, pA, pB, pC, pD, pE, pF;
	//	uint32_t x0, x1, x2, x3;
	uint32_t rk[32];
	//	uint32_t i;
	const uint32_t counter = 640;

	uint32_t p0 = state[0x0];
	uint32_t p1 = state[0x1];
	uint32_t p2 = state[0x2];
	uint32_t p3 = state[0x3];
	uint32_t p4 = state[0x4];
	uint32_t p5 = state[0x5];
	uint32_t p6 = state[0x6];
	uint32_t p7 = state[0x7];
	uint32_t p8 = state[0x8];
	uint32_t p9 = state[0x9];
	uint32_t pA = state[0xA];
	uint32_t pB = state[0xB];
	uint32_t pC = state[0xC];
	uint32_t pD = state[0xD];
	uint32_t pE = state[0xE];
	uint32_t pF = state[0xF];

	uint32_t x0 = p4;
	uint32_t x1 = p5;
	uint32_t x2 = p6;
	uint32_t x3 = p7;
#pragma nounroll
	for (int i = 0; i<16; i += 4)
	{
		rk[i] = msg[i];
		x0 ^= msg[i];
		rk[i + 1] = msg[i + 1];
		x1 ^= msg[i + 1];
		rk[i + 2] = msg[i + 2];
		x2 ^= msg[i + 2];
		rk[i + 3] = msg[i + 3];
		x3 ^= msg[i + 3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	}

>>>>>>> 8c320ca... added xevan
	p0 ^= x0;
	p1 ^= x1;
	p2 ^= x2;
	p3 ^= x3;
<<<<<<< HEAD
	if (count == 512)
	{
		rk10 = 0x80U;
		x0 = pC ^ 0x80U;
		rk11 = 0;
		x1 = pD;
		rk12 = 0;
		x2 = pE;
		rk13 = 0;
		x3 = pF;
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk14 = 0;
		rk15 = 0;
		rk16 = 0;
		rk17 = 0;
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk18 = 0;
		rk19 = 0;
		rk1A = 0;
		rk1B = 0x02000000U;
		x3 ^= 0x02000000U;
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk1C = 0;
		rk1D = 0;
		rk1E = 0;
		rk1F = 0x02000000;
		x3 ^= 0x02000000;
	}
	else
	{
		rk10 = msg[16];
		x0 = pC ^ msg[16];
		rk11 = msg[17];
		x1 = pD ^ msg[17];
		rk12 = msg[18];
		x2 = pE ^ msg[18];
		rk13 = msg[19];
		x3 = pF ^ msg[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk14 = msg[20];
		x0 ^= msg[20];
		rk15 = msg[21];
		x1 ^= msg[21];
		rk16 = msg[22];
		x2 ^= msg[22];
		rk17 = msg[23];
		x3 ^= msg[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk18 = msg[24];
		x0 ^= msg[24];
		rk19 = msg[25];
		x1 ^= msg[25];
		rk1A = msg[26];
		x2 ^= msg[26];
		rk1B = msg[27];
		x3 ^= msg[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk1C = msg[28];
		x0 ^= msg[28];
		rk1D = msg[29];
		x1 ^= msg[29];
		rk1E = msg[30];
		x2 ^= msg[30];
		rk1F = msg[31];
		x3 ^= msg[31];
	}
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
=======
	x0 = pC;
	x1 = pD;
	x2 = pE;
	x3 = pF;

#pragma nounroll
	for (int i = 16; i<32; i += 4)
	{
		rk[i] = msg[i];
		x0 ^= msg[i];
		rk[i + 1] = msg[i + 1];
		x1 ^= msg[i + 1];
		rk[i + 2] = msg[i + 2];
		x2 ^= msg[i + 2];
		rk[i + 3] = msg[i + 3];
		x3 ^= msg[i + 3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	}
>>>>>>> 8c320ca... added xevan
	p8 ^= x0;
	p9 ^= x1;
	pA ^= x2;
	pB ^= x3;

	// 1
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk00, rk01, rk02, rk03);
	rk00 ^= rk1C;
	rk01 ^= rk1D;
	rk02 ^= rk1E;
	rk03 ^= rk1F;
	rk00 ^= counter;
	rk03 ^= 0xFFFFFFFF;
	x0 = p0 ^ rk00;
	x1 = p1 ^ rk01;
	x2 = p2 ^ rk02;
	x3 = p3 ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk04, rk05, rk06, rk07);
	rk04 ^= rk00;
	rk05 ^= rk01;
	rk06 ^= rk02;
	rk07 ^= rk03;
	x0 ^= rk04;
	x1 ^= rk05;
	x2 ^= rk06;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk08, rk09, rk0A, rk0B);
	rk08 ^= rk04;
	rk09 ^= rk05;
	rk0A ^= rk06;
	rk0B ^= rk07;
	x0 ^= rk08;
	x1 ^= rk09;
	x2 ^= rk0A;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk0C, rk0D, rk0E, rk0F);
	rk0C ^= rk08;
	rk0D ^= rk09;
	rk0E ^= rk0A;
	rk0F ^= rk0B;
	x0 ^= rk0C;
	x1 ^= rk0D;
	x2 ^= rk0E;
	x3 ^= rk0F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);

	rk[0] ^= rk[28];
	rk[1] ^= rk[29];
	rk[2] ^= rk[30];
	rk[3] ^= ~rk[31];
	rk[0] ^= counter;
	//rk[3] ^= 0xFFFFFFFF;
	x0 = p0 ^ rk[0];
	x1 = p1 ^ rk[1];
	x2 = p2 ^ rk[2];
	x3 = p3 ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
	rk[4] ^= rk[0];
	rk[5] ^= rk[1];
	rk[6] ^= rk[2];
	rk[7] ^= rk[3];
	x0 ^= rk[4];
	x1 ^= rk[5];
	x2 ^= rk[6];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
	rk[8] ^= rk[4];
	rk[9] ^= rk[5];
	rk[10] ^= rk[6];
	rk[11] ^= rk[7];
	x0 ^= rk[8];
	x1 ^= rk[9];
	x2 ^= rk[10];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
	rk[12] ^= rk[8];
	rk[13] ^= rk[9];
	rk[14] ^= rk[10];
	rk[15] ^= rk[11];
	x0 ^= rk[12];
	x1 ^= rk[13];
	x2 ^= rk[14];
	x3 ^= rk[15];

>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	pC ^= x0;
	pD ^= x1;
	pE ^= x2;
	pF ^= x3;
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk10, rk11, rk12, rk13);
	rk10 ^= rk0C;
	rk11 ^= rk0D;
	rk12 ^= rk0E;
	rk13 ^= rk0F;
	x0 = p8 ^ rk10;
	x1 = p9 ^ rk11;
	x2 = pA ^ rk12;
	x3 = pB ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk14, rk15, rk16, rk17);
	rk14 ^= rk10;
	rk15 ^= rk11;
	rk16 ^= rk12;
	rk17 ^= rk13;
	x0 ^= rk14;
	x1 ^= rk15;
	x2 ^= rk16;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk18, rk19, rk1A, rk1B);
	rk18 ^= rk14;
	rk19 ^= rk15;
	rk1A ^= rk16;
	rk1B ^= rk17;
	x0 ^= rk18;
	x1 ^= rk19;
	x2 ^= rk1A;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk1C, rk1D, rk1E, rk1F);
	rk1C ^= rk18;
	rk1D ^= rk19;
	rk1E ^= rk1A;
	rk1F ^= rk1B;
	x0 ^= rk1C;
	x1 ^= rk1D;
	x2 ^= rk1E;
	x3 ^= rk1F;
=======

	KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
	rk[16] ^= rk[12];
	rk[17] ^= rk[13];
	rk[18] ^= rk[14];
	rk[19] ^= rk[15];
	x0 = p8 ^ rk[16];
	x1 = p9 ^ rk[17];
	x2 = pA ^ rk[18];
	x3 = pB ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
	rk[20] ^= rk[16];
	rk[21] ^= rk[17];
	rk[22] ^= rk[18];
	rk[23] ^= rk[19];
	x0 ^= rk[20];
	x1 ^= rk[21];
	x2 ^= rk[22];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
	rk[24] ^= rk[20];
	rk[25] ^= rk[21];
	rk[26] ^= rk[22];
	rk[27] ^= rk[23];
	x0 ^= rk[24];
	x1 ^= rk[25];
	x2 ^= rk[26];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
	rk[28] ^= rk[24];
	rk[29] ^= rk[25];
	rk[30] ^= rk[26];
	rk[31] ^= rk[27];
	x0 ^= rk[28];
	x1 ^= rk[29];
	x2 ^= rk[30];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p4 ^= x0;
	p5 ^= x1;
	p6 ^= x2;
	p7 ^= x3;

<<<<<<< HEAD
	rk00 ^= rk19;
	x0 = pC ^ rk00;
	rk01 ^= rk1A;
	x1 = pD ^ rk01;
	rk02 ^= rk1B;
	x2 = pE ^ rk02;
	rk03 ^= rk1C;
	x3 = pF ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk04 ^= rk1D;
	x0 ^= rk04;
	rk05 ^= rk1E;
	x1 ^= rk05;
	rk06 ^= rk1F;
	x2 ^= rk06;
	rk07 ^= rk00;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk08 ^= rk01;
	x0 ^= rk08;
	rk09 ^= rk02;
	x1 ^= rk09;
	rk0A ^= rk03;
	x2 ^= rk0A;
	rk0B ^= rk04;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk0C ^= rk05;
	x0 ^= rk0C;
	rk0D ^= rk06;
	x1 ^= rk0D;
	rk0E ^= rk07;
	x2 ^= rk0E;
	rk0F ^= rk08;
	x3 ^= rk0F;
=======
	rk[0] ^= rk[25];
	x0 = pC ^ rk[0];
	rk[1] ^= rk[26];
	x1 = pD ^ rk[1];
	rk[2] ^= rk[27];
	x2 = pE ^ rk[2];
	rk[3] ^= rk[28];
	x3 = pF ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[4] ^= rk[29];
	x0 ^= rk[4];
	rk[5] ^= rk[30];
	x1 ^= rk[5];
	rk[6] ^= rk[31];
	x2 ^= rk[6];
	rk[7] ^= rk[0];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[8] ^= rk[1];
	x0 ^= rk[8];
	rk[9] ^= rk[2];
	x1 ^= rk[9];
	rk[10] ^= rk[3];
	x2 ^= rk[10];
	rk[11] ^= rk[4];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[12] ^= rk[5];
	x0 ^= rk[12];
	rk[13] ^= rk[6];
	x1 ^= rk[13];
	rk[14] ^= rk[7];
	x2 ^= rk[14];
	rk[15] ^= rk[8];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p8 ^= x0;
	p9 ^= x1;
	pA ^= x2;
	pB ^= x3;
<<<<<<< HEAD
	rk10 ^= rk09;
	x0 = p4 ^ rk10;
	rk11 ^= rk0A;
	x1 = p5 ^ rk11;
	rk12 ^= rk0B;
	x2 = p6 ^ rk12;
	rk13 ^= rk0C;
	x3 = p7 ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk14 ^= rk0D;
	x0 ^= rk14;
	rk15 ^= rk0E;
	x1 ^= rk15;
	rk16 ^= rk0F;
	x2 ^= rk16;
	rk17 ^= rk10;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk18 ^= rk11;
	x0 ^= rk18;
	rk19 ^= rk12;
	x1 ^= rk19;
	rk1A ^= rk13;
	x2 ^= rk1A;
	rk1B ^= rk14;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk1C ^= rk15;
	x0 ^= rk1C;
	rk1D ^= rk16;
	x1 ^= rk1D;
	rk1E ^= rk17;
	x2 ^= rk1E;
	rk1F ^= rk18;
	x3 ^= rk1F;
=======
	rk[16] ^= rk[9];
	x0 = p4 ^ rk[16];
	rk[17] ^= rk[10];
	x1 = p5 ^ rk[17];
	rk[18] ^= rk[11];
	x2 = p6 ^ rk[18];
	rk[19] ^= rk[12];
	x3 = p7 ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[20] ^= rk[13];
	x0 ^= rk[20];
	rk[21] ^= rk[14];
	x1 ^= rk[21];
	rk[22] ^= rk[15];
	x2 ^= rk[22];
	rk[23] ^= rk[16];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[24] ^= rk[17];
	x0 ^= rk[24];
	rk[25] ^= rk[18];
	x1 ^= rk[25];
	rk[26] ^= rk[19];
	x2 ^= rk[26];
	rk[27] ^= rk[20];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[28] ^= rk[21];
	x0 ^= rk[28];
	rk[29] ^= rk[22];
	x1 ^= rk[29];
	rk[30] ^= rk[23];
	x2 ^= rk[30];
	rk[31] ^= rk[24];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p0 ^= x0;
	p1 ^= x1;
	p2 ^= x2;
	p3 ^= x3;
<<<<<<< HEAD

	/* round 3, 7, 11 */
	KEY_EXPAND_ELT(sharedMemory, rk00, rk01, rk02, rk03);
	rk00 ^= rk1C;
	rk01 ^= rk1D;
	rk02 ^= rk1E;
	rk03 ^= rk1F;
	x0 = p8 ^ rk00;
	x1 = p9 ^ rk01;
	x2 = pA ^ rk02;
	x3 = pB ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk04, rk05, rk06, rk07);
	rk04 ^= rk00;
	rk05 ^= rk01;
	rk06 ^= rk02;
	rk07 ^= rk03;
	x0 ^= rk04;
	x1 ^= rk05;
	x2 ^= rk06;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk08, rk09, rk0A, rk0B);
	rk08 ^= rk04;
	rk09 ^= rk05;
	rk0A ^= rk06;
	rk0B ^= rk07;
	x0 ^= rk08;
	x1 ^= rk09;
	x2 ^= rk0A;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk0C, rk0D, rk0E, rk0F);
	rk0C ^= rk08;
	rk0D ^= rk09;
	rk0E ^= rk0A;
	rk0F ^= rk0B;
	x0 ^= rk0C;
	x1 ^= rk0D;
	x2 ^= rk0E;
	x3 ^= rk0F;
=======
	/* round 3, 7, 11 */
	KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
	rk[0] ^= rk[28];
	rk[1] ^= rk[29];
	rk[2] ^= rk[30];
	rk[3] ^= rk[31];
	x0 = p8 ^ rk[0];
	x1 = p9 ^ rk[1];
	x2 = pA ^ rk[2];
	x3 = pB ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
	rk[4] ^= rk[0];
	rk[5] ^= rk[1];
	rk[6] ^= rk[2];
	rk[7] ^= rk[3];
	x0 ^= rk[4];
	x1 ^= rk[5];
	x2 ^= rk[6];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
	rk[8] ^= rk[4];
	rk[9] ^= rk[5];
	rk[10] ^= rk[6];
	rk[11] ^= rk[7];
	x0 ^= rk[8];
	x1 ^= rk[9];
	x2 ^= rk[10];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
	rk[12] ^= rk[8];
	rk[13] ^= rk[9];
	rk[14] ^= rk[10];
	rk[15] ^= rk[11];
	x0 ^= rk[12];
	x1 ^= rk[13];
	x2 ^= rk[14];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p4 ^= x0;
	p5 ^= x1;
	p6 ^= x2;
	p7 ^= x3;
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk10, rk11, rk12, rk13);
	rk10 ^= rk0C;
	rk11 ^= rk0D;
	rk12 ^= rk0E;
	rk13 ^= rk0F;
	x0 = p0 ^ rk10;
	x1 = p1 ^ rk11;
	x2 = p2 ^ rk12;
	x3 = p3 ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk14, rk15, rk16, rk17);
	rk14 ^= rk10;
	rk15 ^= rk11;
	rk16 ^= rk12;
	rk17 ^= rk13;
	x0 ^= rk14;
	x1 ^= rk15;
	x2 ^= rk16;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk18, rk19, rk1A, rk1B);
	rk18 ^= rk14;
	rk19 ^= rk15;
	rk1A ^= rk16;
	rk1B ^= rk17;
	x0 ^= rk18;
	x1 ^= rk19;
	x2 ^= rk1A;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk1C, rk1D, rk1E, rk1F);
	rk1C ^= rk18;
	rk1D ^= rk19;
	rk1E ^= rk1A;
	rk1F ^= rk1B;
	x0 ^= rk1C;
	x1 ^= rk1D;
	x2 ^= rk1E;
	x3 ^= rk1F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
	rk[16] ^= rk[12];
	rk[17] ^= rk[13];
	rk[18] ^= rk[14];
	rk[19] ^= rk[15];
	x0 = p0 ^ rk[16];
	x1 = p1 ^ rk[17];
	x2 = p2 ^ rk[18];
	x3 = p3 ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
	rk[20] ^= rk[16];
	rk[21] ^= rk[17];
	rk[22] ^= rk[18];
	rk[23] ^= rk[19];
	x0 ^= rk[20];
	x1 ^= rk[21];
	x2 ^= rk[22];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
	rk[24] ^= rk[20];
	rk[25] ^= rk[21];
	rk[26] ^= rk[22];
	rk[27] ^= rk[23];
	x0 ^= rk[24];
	x1 ^= rk[25];
	x2 ^= rk[26];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
	rk[28] ^= rk[24];
	rk[29] ^= rk[25];
	rk[30] ^= rk[26];
	rk[31] ^= rk[27];
	x0 ^= rk[28];
	x1 ^= rk[29];
	x2 ^= rk[30];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	pC ^= x0;
	pD ^= x1;
	pE ^= x2;
	pF ^= x3;
<<<<<<< HEAD

	/* round 4, 8, 12 */
	rk00 ^= rk19;
	x0 = p4 ^ rk00;
	rk01 ^= rk1A;
	x1 = p5 ^ rk01;
	rk02 ^= rk1B;
	x2 = p6 ^ rk02;
	rk03 ^= rk1C;
	x3 = p7 ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk04 ^= rk1D;
	x0 ^= rk04;
	rk05 ^= rk1E;
	x1 ^= rk05;
	rk06 ^= rk1F;
	x2 ^= rk06;
	rk07 ^= rk00;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk08 ^= rk01;
	x0 ^= rk08;
	rk09 ^= rk02;
	x1 ^= rk09;
	rk0A ^= rk03;
	x2 ^= rk0A;
	rk0B ^= rk04;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk0C ^= rk05;
	x0 ^= rk0C;
	rk0D ^= rk06;
	x1 ^= rk0D;
	rk0E ^= rk07;
	x2 ^= rk0E;
	rk0F ^= rk08;
	x3 ^= rk0F;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
=======
	/* round 4, 8, 12 */
	rk[0] ^= rk[25];
	x0 = p4 ^ rk[0];
	rk[1] ^= rk[26];
	x1 = p5 ^ rk[1];
	rk[2] ^= rk[27];
	x2 = p6 ^ rk[2];
	rk[3] ^= rk[28];
	x3 = p7 ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[4] ^= rk[29];
	x0 ^= rk[4];
	rk[5] ^= rk[30];
	x1 ^= rk[5];
	rk[6] ^= rk[31];
	x2 ^= rk[6];
	rk[7] ^= rk[0];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[8] ^= rk[1];
	x0 ^= rk[8];
	rk[9] ^= rk[2];
	x1 ^= rk[9];
	rk[10] ^= rk[3];
	x2 ^= rk[10];
	rk[11] ^= rk[4];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[12] ^= rk[5];
	x0 ^= rk[12];
	rk[13] ^= rk[6];
	x1 ^= rk[13];
	rk[14] ^= rk[7];
	x2 ^= rk[14];
	rk[15] ^= rk[8];
	x3 ^= rk[15];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);

>>>>>>> 8c320ca... added xevan
	p0 ^= x0;
	p1 ^= x1;
	p2 ^= x2;
	p3 ^= x3;
<<<<<<< HEAD
	rk10 ^= rk09;
	x0 = pC ^ rk10;
	rk11 ^= rk0A;
	x1 = pD ^ rk11;
	rk12 ^= rk0B;
	x2 = pE ^ rk12;
	rk13 ^= rk0C;
	x3 = pF ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk14 ^= rk0D;
	x0 ^= rk14;
	rk15 ^= rk0E;
	x1 ^= rk15;
	rk16 ^= rk0F;
	x2 ^= rk16;
	rk17 ^= rk10;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk18 ^= rk11;
	x0 ^= rk18;
	rk19 ^= rk12;
	x1 ^= rk19;
	rk1A ^= rk13;
	x2 ^= rk1A;
	rk1B ^= rk14;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk1C ^= rk15;
	x0 ^= rk1C;
	rk1D ^= rk16;
	x1 ^= rk1D;
	rk1E ^= rk17;
	x2 ^= rk1E;
	rk1F ^= rk18;
	x3 ^= rk1F;
=======
	rk[16] ^= rk[9];
	x0 = pC ^ rk[16];
	rk[17] ^= rk[10];
	x1 = pD ^ rk[17];
	rk[18] ^= rk[11];
	x2 = pE ^ rk[18];
	rk[19] ^= rk[12];
	x3 = pF ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[20] ^= rk[13];
	x0 ^= rk[20];
	rk[21] ^= rk[14];
	x1 ^= rk[21];
	rk[22] ^= rk[15];
	x2 ^= rk[22];
	rk[23] ^= rk[16];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[24] ^= rk[17];
	x0 ^= rk[24];
	rk[25] ^= rk[18];
	x1 ^= rk[25];
	rk[26] ^= rk[19];
	x2 ^= rk[26];
	rk[27] ^= rk[20];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[28] ^= rk[21];
	x0 ^= rk[28];
	rk[29] ^= rk[22];
	x1 ^= rk[29];
	rk[30] ^= rk[23];
	x2 ^= rk[30];
	rk[31] ^= rk[24];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p8 ^= x0;
	p9 ^= x1;
	pA ^= x2;
	pB ^= x3;

	// 2
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk00, rk01, rk02, rk03);
	rk00 ^= rk1C;
	rk01 ^= rk1D;
	rk02 ^= rk1E;
	rk03 ^= rk1F;
	x0 = p0 ^ rk00;
	x1 = p1 ^ rk01;
	x2 = p2 ^ rk02;
	x3 = p3 ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk04, rk05, rk06, rk07);
	rk04 ^= rk00;
	rk05 ^= rk01;
	rk06 ^= rk02;
	rk07 ^= rk03;
	rk07 ^= SPH_T32(~counter);
	x0 ^= rk04;
	x1 ^= rk05;
	x2 ^= rk06;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk08, rk09, rk0A, rk0B);
	rk08 ^= rk04;
	rk09 ^= rk05;
	rk0A ^= rk06;
	rk0B ^= rk07;
	x0 ^= rk08;
	x1 ^= rk09;
	x2 ^= rk0A;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk0C, rk0D, rk0E, rk0F);
	rk0C ^= rk08;
	rk0D ^= rk09;
	rk0E ^= rk0A;
	rk0F ^= rk0B;
	x0 ^= rk0C;
	x1 ^= rk0D;
	x2 ^= rk0E;
	x3 ^= rk0F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
	rk[0] ^= rk[28];
	rk[1] ^= rk[29];
	rk[2] ^= rk[30];
	rk[3] ^= rk[31];
	x0 = p0 ^ rk[0];
	x1 = p1 ^ rk[1];
	x2 = p2 ^ rk[2];
	x3 = p3 ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
	rk[4] ^= rk[0];
	rk[5] ^= rk[1];
	rk[6] ^= rk[2];
	rk[7] ^= rk[3];
	rk[7] ^= ~counter;
	x0 ^= rk[4];
	x1 ^= rk[5];
	x2 ^= rk[6];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
	rk[8] ^= rk[4];
	rk[9] ^= rk[5];
	rk[10] ^= rk[6];
	rk[11] ^= rk[7];
	x0 ^= rk[8];
	x1 ^= rk[9];
	x2 ^= rk[10];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
	rk[12] ^= rk[8];
	rk[13] ^= rk[9];
	rk[14] ^= rk[10];
	rk[15] ^= rk[11];
	x0 ^= rk[12];
	x1 ^= rk[13];
	x2 ^= rk[14];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	pC ^= x0;
	pD ^= x1;
	pE ^= x2;
	pF ^= x3;
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk10, rk11, rk12, rk13);
	rk10 ^= rk0C;
	rk11 ^= rk0D;
	rk12 ^= rk0E;
	rk13 ^= rk0F;
	x0 = p8 ^ rk10;
	x1 = p9 ^ rk11;
	x2 = pA ^ rk12;
	x3 = pB ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk14, rk15, rk16, rk17);
	rk14 ^= rk10;
	rk15 ^= rk11;
	rk16 ^= rk12;
	rk17 ^= rk13;
	x0 ^= rk14;
	x1 ^= rk15;
	x2 ^= rk16;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk18, rk19, rk1A, rk1B);
	rk18 ^= rk14;
	rk19 ^= rk15;
	rk1A ^= rk16;
	rk1B ^= rk17;
	x0 ^= rk18;
	x1 ^= rk19;
	x2 ^= rk1A;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk1C, rk1D, rk1E, rk1F);
	rk1C ^= rk18;
	rk1D ^= rk19;
	rk1E ^= rk1A;
	rk1F ^= rk1B;
	x0 ^= rk1C;
	x1 ^= rk1D;
	x2 ^= rk1E;
	x3 ^= rk1F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
	rk[16] ^= rk[12];
	rk[17] ^= rk[13];
	rk[18] ^= rk[14];
	rk[19] ^= rk[15];
	x0 = p8 ^ rk[16];
	x1 = p9 ^ rk[17];
	x2 = pA ^ rk[18];
	x3 = pB ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
	rk[20] ^= rk[16];
	rk[21] ^= rk[17];
	rk[22] ^= rk[18];
	rk[23] ^= rk[19];
	x0 ^= rk[20];
	x1 ^= rk[21];
	x2 ^= rk[22];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
	rk[24] ^= rk[20];
	rk[25] ^= rk[21];
	rk[26] ^= rk[22];
	rk[27] ^= rk[23];
	x0 ^= rk[24];
	x1 ^= rk[25];
	x2 ^= rk[26];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
	rk[28] ^= rk[24];
	rk[29] ^= rk[25];
	rk[30] ^= rk[26];
	rk[31] ^= rk[27];
	x0 ^= rk[28];
	x1 ^= rk[29];
	x2 ^= rk[30];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p4 ^= x0;
	p5 ^= x1;
	p6 ^= x2;
	p7 ^= x3;

<<<<<<< HEAD
	rk00 ^= rk19;
	x0 = pC ^ rk00;
	rk01 ^= rk1A;
	x1 = pD ^ rk01;
	rk02 ^= rk1B;
	x2 = pE ^ rk02;
	rk03 ^= rk1C;
	x3 = pF ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk04 ^= rk1D;
	x0 ^= rk04;
	rk05 ^= rk1E;
	x1 ^= rk05;
	rk06 ^= rk1F;
	x2 ^= rk06;
	rk07 ^= rk00;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk08 ^= rk01;
	x0 ^= rk08;
	rk09 ^= rk02;
	x1 ^= rk09;
	rk0A ^= rk03;
	x2 ^= rk0A;
	rk0B ^= rk04;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk0C ^= rk05;
	x0 ^= rk0C;
	rk0D ^= rk06;
	x1 ^= rk0D;
	rk0E ^= rk07;
	x2 ^= rk0E;
	rk0F ^= rk08;
	x3 ^= rk0F;
=======
	rk[0] ^= rk[25];
	x0 = pC ^ rk[0];
	rk[1] ^= rk[26];
	x1 = pD ^ rk[1];
	rk[2] ^= rk[27];
	x2 = pE ^ rk[2];
	rk[3] ^= rk[28];
	x3 = pF ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[4] ^= rk[29];
	x0 ^= rk[4];
	rk[5] ^= rk[30];
	x1 ^= rk[5];
	rk[6] ^= rk[31];
	x2 ^= rk[6];
	rk[7] ^= rk[0];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[8] ^= rk[1];
	x0 ^= rk[8];
	rk[9] ^= rk[2];
	x1 ^= rk[9];
	rk[10] ^= rk[3];
	x2 ^= rk[10];
	rk[11] ^= rk[4];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[12] ^= rk[5];
	x0 ^= rk[12];
	rk[13] ^= rk[6];
	x1 ^= rk[13];
	rk[14] ^= rk[7];
	x2 ^= rk[14];
	rk[15] ^= rk[8];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p8 ^= x0;
	p9 ^= x1;
	pA ^= x2;
	pB ^= x3;
<<<<<<< HEAD
	rk10 ^= rk09;
	x0 = p4 ^ rk10;
	rk11 ^= rk0A;
	x1 = p5 ^ rk11;
	rk12 ^= rk0B;
	x2 = p6 ^ rk12;
	rk13 ^= rk0C;
	x3 = p7 ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk14 ^= rk0D;
	x0 ^= rk14;
	rk15 ^= rk0E;
	x1 ^= rk15;
	rk16 ^= rk0F;
	x2 ^= rk16;
	rk17 ^= rk10;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk18 ^= rk11;
	x0 ^= rk18;
	rk19 ^= rk12;
	x1 ^= rk19;
	rk1A ^= rk13;
	x2 ^= rk1A;
	rk1B ^= rk14;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk1C ^= rk15;
	x0 ^= rk1C;
	rk1D ^= rk16;
	x1 ^= rk1D;
	rk1E ^= rk17;
	x2 ^= rk1E;
	rk1F ^= rk18;
	x3 ^= rk1F;
=======
	rk[16] ^= rk[9];
	x0 = p4 ^ rk[16];
	rk[17] ^= rk[10];
	x1 = p5 ^ rk[17];
	rk[18] ^= rk[11];
	x2 = p6 ^ rk[18];
	rk[19] ^= rk[12];
	x3 = p7 ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[20] ^= rk[13];
	x0 ^= rk[20];
	rk[21] ^= rk[14];
	x1 ^= rk[21];
	rk[22] ^= rk[15];
	x2 ^= rk[22];
	rk[23] ^= rk[16];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[24] ^= rk[17];
	x0 ^= rk[24];
	rk[25] ^= rk[18];
	x1 ^= rk[25];
	rk[26] ^= rk[19];
	x2 ^= rk[26];
	rk[27] ^= rk[20];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[28] ^= rk[21];
	x0 ^= rk[28];
	rk[29] ^= rk[22];
	x1 ^= rk[29];
	rk[30] ^= rk[23];
	x2 ^= rk[30];
	rk[31] ^= rk[24];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p0 ^= x0;
	p1 ^= x1;
	p2 ^= x2;
	p3 ^= x3;
<<<<<<< HEAD

	/* round 3, 7, 11 */
	KEY_EXPAND_ELT(sharedMemory, rk00, rk01, rk02, rk03);
	rk00 ^= rk1C;
	rk01 ^= rk1D;
	rk02 ^= rk1E;
	rk03 ^= rk1F;
	x0 = p8 ^ rk00;
	x1 = p9 ^ rk01;
	x2 = pA ^ rk02;
	x3 = pB ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk04, rk05, rk06, rk07);
	rk04 ^= rk00;
	rk05 ^= rk01;
	rk06 ^= rk02;
	rk07 ^= rk03;
	x0 ^= rk04;
	x1 ^= rk05;
	x2 ^= rk06;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk08, rk09, rk0A, rk0B);
	rk08 ^= rk04;
	rk09 ^= rk05;
	rk0A ^= rk06;
	rk0B ^= rk07;
	x0 ^= rk08;
	x1 ^= rk09;
	x2 ^= rk0A;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk0C, rk0D, rk0E, rk0F);
	rk0C ^= rk08;
	rk0D ^= rk09;
	rk0E ^= rk0A;
	rk0F ^= rk0B;
	x0 ^= rk0C;
	x1 ^= rk0D;
	x2 ^= rk0E;
	x3 ^= rk0F;
=======
	/* round 3, 7, 11 */
	KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
	rk[0] ^= rk[28];
	rk[1] ^= rk[29];
	rk[2] ^= rk[30];
	rk[3] ^= rk[31];
	x0 = p8 ^ rk[0];
	x1 = p9 ^ rk[1];
	x2 = pA ^ rk[2];
	x3 = pB ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
	rk[4] ^= rk[0];
	rk[5] ^= rk[1];
	rk[6] ^= rk[2];
	rk[7] ^= rk[3];
	x0 ^= rk[4];
	x1 ^= rk[5];
	x2 ^= rk[6];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
	rk[8] ^= rk[4];
	rk[9] ^= rk[5];
	rk[10] ^= rk[6];
	rk[11] ^= rk[7];
	x0 ^= rk[8];
	x1 ^= rk[9];
	x2 ^= rk[10];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
	rk[12] ^= rk[8];
	rk[13] ^= rk[9];
	rk[14] ^= rk[10];
	rk[15] ^= rk[11];
	x0 ^= rk[12];
	x1 ^= rk[13];
	x2 ^= rk[14];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p4 ^= x0;
	p5 ^= x1;
	p6 ^= x2;
	p7 ^= x3;
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk10, rk11, rk12, rk13);
	rk10 ^= rk0C;
	rk11 ^= rk0D;
	rk12 ^= rk0E;
	rk13 ^= rk0F;
	x0 = p0 ^ rk10;
	x1 = p1 ^ rk11;
	x2 = p2 ^ rk12;
	x3 = p3 ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk14, rk15, rk16, rk17);
	rk14 ^= rk10;
	rk15 ^= rk11;
	rk16 ^= rk12;
	rk17 ^= rk13;
	x0 ^= rk14;
	x1 ^= rk15;
	x2 ^= rk16;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk18, rk19, rk1A, rk1B);
	rk18 ^= rk14;
	rk19 ^= rk15;
	rk1A ^= rk16;
	rk1B ^= rk17;
	x0 ^= rk18;
	x1 ^= rk19;
	x2 ^= rk1A;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk1C, rk1D, rk1E, rk1F);
	rk1C ^= rk18;
	rk1D ^= rk19;
	rk1E ^= rk1A;
	rk1F ^= rk1B;
	x0 ^= rk1C;
	x1 ^= rk1D;
	x2 ^= rk1E;
	x3 ^= rk1F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
	rk[16] ^= rk[12];
	rk[17] ^= rk[13];
	rk[18] ^= rk[14];
	rk[19] ^= rk[15];
	x0 = p0 ^ rk[16];
	x1 = p1 ^ rk[17];
	x2 = p2 ^ rk[18];
	x3 = p3 ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
	rk[20] ^= rk[16];
	rk[21] ^= rk[17];
	rk[22] ^= rk[18];
	rk[23] ^= rk[19];
	x0 ^= rk[20];
	x1 ^= rk[21];
	x2 ^= rk[22];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
	rk[24] ^= rk[20];
	rk[25] ^= rk[21];
	rk[26] ^= rk[22];
	rk[27] ^= rk[23];
	x0 ^= rk[24];
	x1 ^= rk[25];
	x2 ^= rk[26];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
	rk[28] ^= rk[24];
	rk[29] ^= rk[25];
	rk[30] ^= rk[26];
	rk[31] ^= rk[27];
	x0 ^= rk[28];
	x1 ^= rk[29];
	x2 ^= rk[30];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	pC ^= x0;
	pD ^= x1;
	pE ^= x2;
	pF ^= x3;
<<<<<<< HEAD

	/* round 4, 8, 12 */
	rk00 ^= rk19;
	x0 = p4 ^ rk00;
	rk01 ^= rk1A;
	x1 = p5 ^ rk01;
	rk02 ^= rk1B;
	x2 = p6 ^ rk02;
	rk03 ^= rk1C;
	x3 = p7 ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk04 ^= rk1D;
	x0 ^= rk04;
	rk05 ^= rk1E;
	x1 ^= rk05;
	rk06 ^= rk1F;
	x2 ^= rk06;
	rk07 ^= rk00;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk08 ^= rk01;
	x0 ^= rk08;
	rk09 ^= rk02;
	x1 ^= rk09;
	rk0A ^= rk03;
	x2 ^= rk0A;
	rk0B ^= rk04;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk0C ^= rk05;
	x0 ^= rk0C;
	rk0D ^= rk06;
	x1 ^= rk0D;
	rk0E ^= rk07;
	x2 ^= rk0E;
	rk0F ^= rk08;
	x3 ^= rk0F;
=======
	/* round 4, 8, 12 */
	rk[0] ^= rk[25];
	x0 = p4 ^ rk[0];
	rk[1] ^= rk[26];
	x1 = p5 ^ rk[1];
	rk[2] ^= rk[27];
	x2 = p6 ^ rk[2];
	rk[3] ^= rk[28];
	x3 = p7 ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[4] ^= rk[29];
	x0 ^= rk[4];
	rk[5] ^= rk[30];
	x1 ^= rk[5];
	rk[6] ^= rk[31];
	x2 ^= rk[6];
	rk[7] ^= rk[0];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[8] ^= rk[1];
	x0 ^= rk[8];
	rk[9] ^= rk[2];
	x1 ^= rk[9];
	rk[10] ^= rk[3];
	x2 ^= rk[10];
	rk[11] ^= rk[4];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[12] ^= rk[5];
	x0 ^= rk[12];
	rk[13] ^= rk[6];
	x1 ^= rk[13];
	rk[14] ^= rk[7];
	x2 ^= rk[14];
	rk[15] ^= rk[8];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p0 ^= x0;
	p1 ^= x1;
	p2 ^= x2;
	p3 ^= x3;
<<<<<<< HEAD
	rk10 ^= rk09;
	x0 = pC ^ rk10;
	rk11 ^= rk0A;
	x1 = pD ^ rk11;
	rk12 ^= rk0B;
	x2 = pE ^ rk12;
	rk13 ^= rk0C;
	x3 = pF ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk14 ^= rk0D;
	x0 ^= rk14;
	rk15 ^= rk0E;
	x1 ^= rk15;
	rk16 ^= rk0F;
	x2 ^= rk16;
	rk17 ^= rk10;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk18 ^= rk11;
	x0 ^= rk18;
	rk19 ^= rk12;
	x1 ^= rk19;
	rk1A ^= rk13;
	x2 ^= rk1A;
	rk1B ^= rk14;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk1C ^= rk15;
	x0 ^= rk1C;
	rk1D ^= rk16;
	x1 ^= rk1D;
	rk1E ^= rk17;
	x2 ^= rk1E;
	rk1F ^= rk18;
	x3 ^= rk1F;
=======
	rk[16] ^= rk[9];
	x0 = pC ^ rk[16];
	rk[17] ^= rk[10];
	x1 = pD ^ rk[17];
	rk[18] ^= rk[11];
	x2 = pE ^ rk[18];
	rk[19] ^= rk[12];
	x3 = pF ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[20] ^= rk[13];
	x0 ^= rk[20];
	rk[21] ^= rk[14];
	x1 ^= rk[21];
	rk[22] ^= rk[15];
	x2 ^= rk[22];
	rk[23] ^= rk[16];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[24] ^= rk[17];
	x0 ^= rk[24];
	rk[25] ^= rk[18];
	x1 ^= rk[25];
	rk[26] ^= rk[19];
	x2 ^= rk[26];
	rk[27] ^= rk[20];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[28] ^= rk[21];
	x0 ^= rk[28];
	rk[29] ^= rk[22];
	x1 ^= rk[29];
	rk[30] ^= rk[23];
	x2 ^= rk[30];
	rk[31] ^= rk[24];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p8 ^= x0;
	p9 ^= x1;
	pA ^= x2;
	pB ^= x3;

	// 3
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk00, rk01, rk02, rk03);
	rk00 ^= rk1C;
	rk01 ^= rk1D;
	rk02 ^= rk1E;
	rk03 ^= rk1F;
	x0 = p0 ^ rk00;
	x1 = p1 ^ rk01;
	x2 = p2 ^ rk02;
	x3 = p3 ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk04, rk05, rk06, rk07);
	rk04 ^= rk00;
	rk05 ^= rk01;
	rk06 ^= rk02;
	rk07 ^= rk03;
	x0 ^= rk04;
	x1 ^= rk05;
	x2 ^= rk06;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk08, rk09, rk0A, rk0B);
	rk08 ^= rk04;
	rk09 ^= rk05;
	rk0A ^= rk06;
	rk0B ^= rk07;
	x0 ^= rk08;
	x1 ^= rk09;
	x2 ^= rk0A;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk0C, rk0D, rk0E, rk0F);
	rk0C ^= rk08;
	rk0D ^= rk09;
	rk0E ^= rk0A;
	rk0F ^= rk0B;
	x0 ^= rk0C;
	x1 ^= rk0D;
	x2 ^= rk0E;
	x3 ^= rk0F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
	rk[0] ^= rk[28];
	rk[1] ^= rk[29];
	rk[2] ^= rk[30];
	rk[3] ^= rk[31];
	x0 = p0 ^ rk[0];
	x1 = p1 ^ rk[1];
	x2 = p2 ^ rk[2];
	x3 = p3 ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
	rk[4] ^= rk[0];
	rk[5] ^= rk[1];
	rk[6] ^= rk[2];
	rk[7] ^= rk[3];
	x0 ^= rk[4];
	x1 ^= rk[5];
	x2 ^= rk[6];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
	rk[8] ^= rk[4];
	rk[9] ^= rk[5];
	rk[10] ^= rk[6];
	rk[11] ^= rk[7];
	x0 ^= rk[8];
	x1 ^= rk[9];
	x2 ^= rk[10];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
	rk[12] ^= rk[8];
	rk[13] ^= rk[9];
	rk[14] ^= rk[10];
	rk[15] ^= rk[11];
	x0 ^= rk[12];
	x1 ^= rk[13];
	x2 ^= rk[14];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	pC ^= x0;
	pD ^= x1;
	pE ^= x2;
	pF ^= x3;
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk10, rk11, rk12, rk13);
	rk10 ^= rk0C;
	rk11 ^= rk0D;
	rk12 ^= rk0E;
	rk13 ^= rk0F;
	x0 = p8 ^ rk10;
	x1 = p9 ^ rk11;
	x2 = pA ^ rk12;
	x3 = pB ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk14, rk15, rk16, rk17);
	rk14 ^= rk10;
	rk15 ^= rk11;
	rk16 ^= rk12;
	rk17 ^= rk13;
	x0 ^= rk14;
	x1 ^= rk15;
	x2 ^= rk16;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk18, rk19, rk1A, rk1B);
	rk18 ^= rk14;
	rk19 ^= rk15;
	rk1A ^= rk16;
	rk1B ^= rk17;
	x0 ^= rk18;
	x1 ^= rk19;
	x2 ^= rk1A;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk1C, rk1D, rk1E, rk1F);
	rk1C ^= rk18;
	rk1D ^= rk19;
	rk1E ^= rk1A;
	rk1F ^= rk1B;
	rk1E ^= counter;
	rk1F ^= 0xFFFFFFFF;
	x0 ^= rk1C;
	x1 ^= rk1D;
	x2 ^= rk1E;
	x3 ^= rk1F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
	rk[16] ^= rk[12];
	rk[17] ^= rk[13];
	rk[18] ^= rk[14];
	rk[19] ^= rk[15];
	x0 = p8 ^ rk[16];
	x1 = p9 ^ rk[17];
	x2 = pA ^ rk[18];
	x3 = pB ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
	rk[20] ^= rk[16];
	rk[21] ^= rk[17];
	rk[22] ^= rk[18];
	rk[23] ^= rk[19];
	x0 ^= rk[20];
	x1 ^= rk[21];
	x2 ^= rk[22];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
	rk[24] ^= rk[20];
	rk[25] ^= rk[21];
	rk[26] ^= rk[22];
	rk[27] ^= rk[23];
	x0 ^= rk[24];
	x1 ^= rk[25];
	x2 ^= rk[26];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
	rk[28] ^= rk[24];
	rk[29] ^= rk[25];
	rk[30] ^= rk[26];
	rk[31] ^= ~rk[27];
	rk[30] ^= counter;
	//rk[31] ^= 0xFFFFFFFF;
	x0 ^= rk[28];
	x1 ^= rk[29];
	x2 ^= rk[30];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p4 ^= x0;
	p5 ^= x1;
	p6 ^= x2;
	p7 ^= x3;

<<<<<<< HEAD
	rk00 ^= rk19;
	x0 = pC ^ rk00;
	rk01 ^= rk1A;
	x1 = pD ^ rk01;
	rk02 ^= rk1B;
	x2 = pE ^ rk02;
	rk03 ^= rk1C;
	x3 = pF ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk04 ^= rk1D;
	x0 ^= rk04;
	rk05 ^= rk1E;
	x1 ^= rk05;
	rk06 ^= rk1F;
	x2 ^= rk06;
	rk07 ^= rk00;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk08 ^= rk01;
	x0 ^= rk08;
	rk09 ^= rk02;
	x1 ^= rk09;
	rk0A ^= rk03;
	x2 ^= rk0A;
	rk0B ^= rk04;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk0C ^= rk05;
	x0 ^= rk0C;
	rk0D ^= rk06;
	x1 ^= rk0D;
	rk0E ^= rk07;
	x2 ^= rk0E;
	rk0F ^= rk08;
	x3 ^= rk0F;
=======
	rk[0] ^= rk[25];
	x0 = pC ^ rk[0];
	rk[1] ^= rk[26];
	x1 = pD ^ rk[1];
	rk[2] ^= rk[27];
	x2 = pE ^ rk[2];
	rk[3] ^= rk[28];
	x3 = pF ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[4] ^= rk[29];
	x0 ^= rk[4];
	rk[5] ^= rk[30];
	x1 ^= rk[5];
	rk[6] ^= rk[31];
	x2 ^= rk[6];
	rk[7] ^= rk[0];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[8] ^= rk[1];
	x0 ^= rk[8];
	rk[9] ^= rk[2];
	x1 ^= rk[9];
	rk[10] ^= rk[3];
	x2 ^= rk[10];
	rk[11] ^= rk[4];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[12] ^= rk[5];
	x0 ^= rk[12];
	rk[13] ^= rk[6];
	x1 ^= rk[13];
	rk[14] ^= rk[7];
	x2 ^= rk[14];
	rk[15] ^= rk[8];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p8 ^= x0;
	p9 ^= x1;
	pA ^= x2;
	pB ^= x3;
<<<<<<< HEAD
	rk10 ^= rk09;
	x0 = p4 ^ rk10;
	rk11 ^= rk0A;
	x1 = p5 ^ rk11;
	rk12 ^= rk0B;
	x2 = p6 ^ rk12;
	rk13 ^= rk0C;
	x3 = p7 ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk14 ^= rk0D;
	x0 ^= rk14;
	rk15 ^= rk0E;
	x1 ^= rk15;
	rk16 ^= rk0F;
	x2 ^= rk16;
	rk17 ^= rk10;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk18 ^= rk11;
	x0 ^= rk18;
	rk19 ^= rk12;
	x1 ^= rk19;
	rk1A ^= rk13;
	x2 ^= rk1A;
	rk1B ^= rk14;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk1C ^= rk15;
	x0 ^= rk1C;
	rk1D ^= rk16;
	x1 ^= rk1D;
	rk1E ^= rk17;
	x2 ^= rk1E;
	rk1F ^= rk18;
	x3 ^= rk1F;
=======
	rk[16] ^= rk[9];
	x0 = p4 ^ rk[16];
	rk[17] ^= rk[10];
	x1 = p5 ^ rk[17];
	rk[18] ^= rk[11];
	x2 = p6 ^ rk[18];
	rk[19] ^= rk[12];
	x3 = p7 ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[20] ^= rk[13];
	x0 ^= rk[20];
	rk[21] ^= rk[14];
	x1 ^= rk[21];
	rk[22] ^= rk[15];
	x2 ^= rk[22];
	rk[23] ^= rk[16];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[24] ^= rk[17];
	x0 ^= rk[24];
	rk[25] ^= rk[18];
	x1 ^= rk[25];
	rk[26] ^= rk[19];
	x2 ^= rk[26];
	rk[27] ^= rk[20];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[28] ^= rk[21];
	x0 ^= rk[28];
	rk[29] ^= rk[22];
	x1 ^= rk[29];
	rk[30] ^= rk[23];
	x2 ^= rk[30];
	rk[31] ^= rk[24];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p0 ^= x0;
	p1 ^= x1;
	p2 ^= x2;
	p3 ^= x3;

<<<<<<< HEAD
	/* round 3, 7, 11 */
	KEY_EXPAND_ELT(sharedMemory, rk00, rk01, rk02, rk03);
	rk00 ^= rk1C;
	rk01 ^= rk1D;
	rk02 ^= rk1E;
	rk03 ^= rk1F;
	x0 = p8 ^ rk00;
	x1 = p9 ^ rk01;
	x2 = pA ^ rk02;
	x3 = pB ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk04, rk05, rk06, rk07);
	rk04 ^= rk00;
	rk05 ^= rk01;
	rk06 ^= rk02;
	rk07 ^= rk03;
	x0 ^= rk04;
	x1 ^= rk05;
	x2 ^= rk06;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk08, rk09, rk0A, rk0B);
	rk08 ^= rk04;
	rk09 ^= rk05;
	rk0A ^= rk06;
	rk0B ^= rk07;
	x0 ^= rk08;
	x1 ^= rk09;
	x2 ^= rk0A;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk0C, rk0D, rk0E, rk0F);
	rk0C ^= rk08;
	rk0D ^= rk09;
	rk0E ^= rk0A;
	rk0F ^= rk0B;
	x0 ^= rk0C;
	x1 ^= rk0D;
	x2 ^= rk0E;
	x3 ^= rk0F;
=======

	/* round 3, 7, 11 */
	KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
	rk[0] ^= rk[28];
	rk[1] ^= rk[29];
	rk[2] ^= rk[30];
	rk[3] ^= rk[31];
	x0 = p8 ^ rk[0];
	x1 = p9 ^ rk[1];
	x2 = pA ^ rk[2];
	x3 = pB ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
	rk[4] ^= rk[0];
	rk[5] ^= rk[1];
	rk[6] ^= rk[2];
	rk[7] ^= rk[3];
	x0 ^= rk[4];
	x1 ^= rk[5];
	x2 ^= rk[6];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
	rk[8] ^= rk[4];
	rk[9] ^= rk[5];
	rk[10] ^= rk[6];
	rk[11] ^= rk[7];
	x0 ^= rk[8];
	x1 ^= rk[9];
	x2 ^= rk[10];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
	rk[12] ^= rk[8];
	rk[13] ^= rk[9];
	rk[14] ^= rk[10];
	rk[15] ^= rk[11];
	x0 ^= rk[12];
	x1 ^= rk[13];
	x2 ^= rk[14];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p4 ^= x0;
	p5 ^= x1;
	p6 ^= x2;
	p7 ^= x3;
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk10, rk11, rk12, rk13);
	rk10 ^= rk0C;
	rk11 ^= rk0D;
	rk12 ^= rk0E;
	rk13 ^= rk0F;
	x0 = p0 ^ rk10;
	x1 = p1 ^ rk11;
	x2 = p2 ^ rk12;
	x3 = p3 ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk14, rk15, rk16, rk17);
	rk14 ^= rk10;
	rk15 ^= rk11;
	rk16 ^= rk12;
	rk17 ^= rk13;
	x0 ^= rk14;
	x1 ^= rk15;
	x2 ^= rk16;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk18, rk19, rk1A, rk1B);
	rk18 ^= rk14;
	rk19 ^= rk15;
	rk1A ^= rk16;
	rk1B ^= rk17;
	x0 ^= rk18;
	x1 ^= rk19;
	x2 ^= rk1A;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk1C, rk1D, rk1E, rk1F);
	rk1C ^= rk18;
	rk1D ^= rk19;
	rk1E ^= rk1A;
	rk1F ^= rk1B;
	x0 ^= rk1C;
	x1 ^= rk1D;
	x2 ^= rk1E;
	x3 ^= rk1F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
	rk[16] ^= rk[12];
	rk[17] ^= rk[13];
	rk[18] ^= rk[14];
	rk[19] ^= rk[15];
	x0 = p0 ^ rk[16];
	x1 = p1 ^ rk[17];
	x2 = p2 ^ rk[18];
	x3 = p3 ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
	rk[20] ^= rk[16];
	rk[21] ^= rk[17];
	rk[22] ^= rk[18];
	rk[23] ^= rk[19];
	x0 ^= rk[20];
	x1 ^= rk[21];
	x2 ^= rk[22];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
	rk[24] ^= rk[20];
	rk[25] ^= rk[21];
	rk[26] ^= rk[22];
	rk[27] ^= rk[23];
	x0 ^= rk[24];
	x1 ^= rk[25];
	x2 ^= rk[26];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
	rk[28] ^= rk[24];
	rk[29] ^= rk[25];
	rk[30] ^= rk[26];
	rk[31] ^= rk[27];
	x0 ^= rk[28];
	x1 ^= rk[29];
	x2 ^= rk[30];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	pC ^= x0;
	pD ^= x1;
	pE ^= x2;
	pF ^= x3;
	/* round 4, 8, 12 */
<<<<<<< HEAD
	rk00 ^= rk19;
	x0 = p4 ^ rk00;
	rk01 ^= rk1A;
	x1 = p5 ^ rk01;
	rk02 ^= rk1B;
	x2 = p6 ^ rk02;
	rk03 ^= rk1C;
	x3 = p7 ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk04 ^= rk1D;
	x0 ^= rk04;
	rk05 ^= rk1E;
	x1 ^= rk05;
	rk06 ^= rk1F;
	x2 ^= rk06;
	rk07 ^= rk00;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk08 ^= rk01;
	x0 ^= rk08;
	rk09 ^= rk02;
	x1 ^= rk09;
	rk0A ^= rk03;
	x2 ^= rk0A;
	rk0B ^= rk04;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk0C ^= rk05;
	x0 ^= rk0C;
	rk0D ^= rk06;
	x1 ^= rk0D;
	rk0E ^= rk07;
	x2 ^= rk0E;
	rk0F ^= rk08;
	x3 ^= rk0F;
=======
	rk[0] ^= rk[25];
	x0 = p4 ^ rk[0];
	rk[1] ^= rk[26];
	x1 = p5 ^ rk[1];
	rk[2] ^= rk[27];
	x2 = p6 ^ rk[2];
	rk[3] ^= rk[28];
	x3 = p7 ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[4] ^= rk[29];
	x0 ^= rk[4];
	rk[5] ^= rk[30];
	x1 ^= rk[5];
	rk[6] ^= rk[31];
	x2 ^= rk[6];
	rk[7] ^= rk[0];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[8] ^= rk[1];
	x0 ^= rk[8];
	rk[9] ^= rk[2];
	x1 ^= rk[9];
	rk[10] ^= rk[3];
	x2 ^= rk[10];
	rk[11] ^= rk[4];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[12] ^= rk[5];
	x0 ^= rk[12];
	rk[13] ^= rk[6];
	x1 ^= rk[13];
	rk[14] ^= rk[7];
	x2 ^= rk[14];
	rk[15] ^= rk[8];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p0 ^= x0;
	p1 ^= x1;
	p2 ^= x2;
	p3 ^= x3;
<<<<<<< HEAD
	rk10 ^= rk09;
	x0 = pC ^ rk10;
	rk11 ^= rk0A;
	x1 = pD ^ rk11;
	rk12 ^= rk0B;
	x2 = pE ^ rk12;
	rk13 ^= rk0C;
	x3 = pF ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk14 ^= rk0D;
	x0 ^= rk14;
	rk15 ^= rk0E;
	x1 ^= rk15;
	rk16 ^= rk0F;
	x2 ^= rk16;
	rk17 ^= rk10;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk18 ^= rk11;
	x0 ^= rk18;
	rk19 ^= rk12;
	x1 ^= rk19;
	rk1A ^= rk13;
	x2 ^= rk1A;
	rk1B ^= rk14;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk1C ^= rk15;
	x0 ^= rk1C;
	rk1D ^= rk16;
	x1 ^= rk1D;
	rk1E ^= rk17;
	x2 ^= rk1E;
	rk1F ^= rk18;
	x3 ^= rk1F;
=======
	rk[16] ^= rk[9];
	x0 = pC ^ rk[16];
	rk[17] ^= rk[10];
	x1 = pD ^ rk[17];
	rk[18] ^= rk[11];
	x2 = pE ^ rk[18];
	rk[19] ^= rk[12];
	x3 = pF ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[20] ^= rk[13];
	x0 ^= rk[20];
	rk[21] ^= rk[14];
	x1 ^= rk[21];
	rk[22] ^= rk[15];
	x2 ^= rk[22];
	rk[23] ^= rk[16];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[24] ^= rk[17];
	x0 ^= rk[24];
	rk[25] ^= rk[18];
	x1 ^= rk[25];
	rk[26] ^= rk[19];
	x2 ^= rk[26];
	rk[27] ^= rk[20];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	rk[28] ^= rk[21];
	x0 ^= rk[28];
	rk[29] ^= rk[22];
	x1 ^= rk[29];
	rk[30] ^= rk[23];
	x2 ^= rk[30];
	rk[31] ^= rk[24];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p8 ^= x0;
	p9 ^= x1;
	pA ^= x2;
	pB ^= x3;

	/* round 13 */
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk00, rk01, rk02, rk03);
	rk00 ^= rk1C;
	rk01 ^= rk1D;
	rk02 ^= rk1E;
	rk03 ^= rk1F;
	x0 = p0 ^ rk00;
	x1 = p1 ^ rk01;
	x2 = p2 ^ rk02;
	x3 = p3 ^ rk03;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk04, rk05, rk06, rk07);
	rk04 ^= rk00;
	rk05 ^= rk01;
	rk06 ^= rk02;
	rk07 ^= rk03;
	x0 ^= rk04;
	x1 ^= rk05;
	x2 ^= rk06;
	x3 ^= rk07;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk08, rk09, rk0A, rk0B);
	rk08 ^= rk04;
	rk09 ^= rk05;
	rk0A ^= rk06;
	rk0B ^= rk07;
	x0 ^= rk08;
	x1 ^= rk09;
	x2 ^= rk0A;
	x3 ^= rk0B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk0C, rk0D, rk0E, rk0F);
	rk0C ^= rk08;
	rk0D ^= rk09;
	rk0E ^= rk0A;
	rk0F ^= rk0B;
	x0 ^= rk0C;
	x1 ^= rk0D;
	x2 ^= rk0E;
	x3 ^= rk0F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
	rk[0] ^= rk[28];
	rk[1] ^= rk[29];
	rk[2] ^= rk[30];
	rk[3] ^= rk[31];
	x0 = p0 ^ rk[0];
	x1 = p1 ^ rk[1];
	x2 = p2 ^ rk[2];
	x3 = p3 ^ rk[3];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
	rk[4] ^= rk[0];
	rk[5] ^= rk[1];
	rk[6] ^= rk[2];
	rk[7] ^= rk[3];
	x0 ^= rk[4];
	x1 ^= rk[5];
	x2 ^= rk[6];
	x3 ^= rk[7];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
	rk[8] ^= rk[4];
	rk[9] ^= rk[5];
	rk[10] ^= rk[6];
	rk[11] ^= rk[7];
	x0 ^= rk[8];
	x1 ^= rk[9];
	x2 ^= rk[10];
	x3 ^= rk[11];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
	rk[12] ^= rk[8];
	rk[13] ^= rk[9];
	rk[14] ^= rk[10];
	rk[15] ^= rk[11];
	x0 ^= rk[12];
	x1 ^= rk[13];
	x2 ^= rk[14];
	x3 ^= rk[15];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	pC ^= x0;
	pD ^= x1;
	pE ^= x2;
	pF ^= x3;
<<<<<<< HEAD
	KEY_EXPAND_ELT(sharedMemory, rk10, rk11, rk12, rk13);
	rk10 ^= rk0C;
	rk11 ^= rk0D;
	rk12 ^= rk0E;
	rk13 ^= rk0F;
	x0 = p8 ^ rk10;
	x1 = p9 ^ rk11;
	x2 = pA ^ rk12;
	x3 = pB ^ rk13;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk14, rk15, rk16, rk17);
	rk14 ^= rk10;
	rk15 ^= rk11;
	rk16 ^= rk12;
	rk17 ^= rk13;
	x0 ^= rk14;
	x1 ^= rk15;
	x2 ^= rk16;
	x3 ^= rk17;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk18, rk19, rk1A, rk1B);
	rk18 ^= rk14;
	rk19 ^= rk15 ^ counter;
	rk1A ^= rk16;
	rk1B ^= rk17 ^ 0xFFFFFFFF;
	x0 ^= rk18;
	x1 ^= rk19;
	x2 ^= rk1A;
	x3 ^= rk1B;
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk1C, rk1D, rk1E, rk1F);
	rk1C ^= rk18;
	rk1D ^= rk19;
	rk1E ^= rk1A;
	rk1F ^= rk1B;
	x0 ^= rk1C;
	x1 ^= rk1D;
	x2 ^= rk1E;
	x3 ^= rk1F;
=======
	KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
	rk[16] ^= rk[12];
	rk[17] ^= rk[13];
	rk[18] ^= rk[14];
	rk[19] ^= rk[15];
	x0 = p8 ^ rk[16];
	x1 = p9 ^ rk[17];
	x2 = pA ^ rk[18];
	x3 = pB ^ rk[19];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
	rk[20] ^= rk[16];
	rk[21] ^= rk[17];
	rk[22] ^= rk[18];
	rk[23] ^= rk[19];
	x0 ^= rk[20];
	x1 ^= rk[21];
	x2 ^= rk[22];
	x3 ^= rk[23];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
	rk[24] ^= rk[20];
	rk[25] ^= rk[21] ^ counter;
	rk[26] ^= rk[22];
	rk[27] ^= ~rk[23]; //^ 0xFFFFFFFF;
	x0 ^= rk[24];
	x1 ^= rk[25];
	x2 ^= rk[26];
	x3 ^= rk[27];
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
	rk[28] ^= rk[24];
	rk[29] ^= rk[25];
	rk[30] ^= rk[26];
	rk[31] ^= rk[27];
	x0 ^= rk[28];
	x1 ^= rk[29];
	x2 ^= rk[30];
	x3 ^= rk[31];
>>>>>>> 8c320ca... added xevan
	AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
	p4 ^= x0;
	p5 ^= x1;
	p6 ^= x2;
	p7 ^= x3;
	state[0x0] ^= p8;
	state[0x1] ^= p9;
	state[0x2] ^= pA;
	state[0x3] ^= pB;
	state[0x4] ^= pC;
	state[0x5] ^= pD;
	state[0x6] ^= pE;
	state[0x7] ^= pF;
	state[0x8] ^= p0;
	state[0x9] ^= p1;
	state[0xA] ^= p2;
	state[0xB] ^= p3;
	state[0xC] ^= p4;
	state[0xD] ^= p5;
	state[0xE] ^= p6;
	state[0xF] ^= p7;
}

<<<<<<< HEAD
__device__ __forceinline__
void shavite_gpu_init(uint32_t *sharedMemory)
{
	/* each thread startup will fill a uint32 */
	if (threadIdx.x < 128) {
		sharedMemory[threadIdx.x] = d_AES0[threadIdx.x];
		sharedMemory[threadIdx.x + 256] = d_AES1[threadIdx.x];
		sharedMemory[threadIdx.x + 512] = d_AES2[threadIdx.x];
		sharedMemory[threadIdx.x + 768] = d_AES3[threadIdx.x];

		sharedMemory[threadIdx.x + 64 * 2] = d_AES0[threadIdx.x + 64 * 2];
		sharedMemory[threadIdx.x + 64 * 2 + 256] = d_AES1[threadIdx.x + 64 * 2];
		sharedMemory[threadIdx.x + 64 * 2 + 512] = d_AES2[threadIdx.x + 64 * 2];
		sharedMemory[threadIdx.x + 64 * 2 + 768] = d_AES3[threadIdx.x + 64 * 2];
	}
}

// GPU Hash
__global__ __launch_bounds__(TPB, 7) /* 64 registers with 128,8 - 72 regs with 128,7 */
void x11_shavite512_gpu_hash_64(uint32_t threads, uint32_t startNounce, uint64_t *g_hash, uint32_t *g_nonceVector)
{
	__shared__ uint32_t sharedMemory[1024];

	shavite_gpu_init(sharedMemory);
	__threadfence_block();
=======
__constant__ uint32_t cstate[16] =
{
	(0x72FCCDD8), (0x79CA4727), (0x128A077B), (0x40D55AEC),
	(0xD1901A06), (0x430AE307), (0xB29F5CD1), (0xDF07FBFC),
	(0x8E45D73D), (0x681AB538), (0xBDE86578), (0xDD577E47),
	(0xE275EADE), (0x502D9FCD), (0xB9357178), (0x022A4B9A)
};

__global__ __launch_bounds__(TPB, 2)
void x11_shavite512_gpu_hash_64(uint32_t threads, uint32_t startNounce, uint64_t *const __restrict__ g_hash)
{
	__shared__  __align__(32) uint32_t sharedMemory[1024];

	shavite_gpu_init(sharedMemory);
>>>>>>> 8c320ca... added xevan

	uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
	if (thread < threads)
	{
<<<<<<< HEAD
		uint32_t nounce = (g_nonceVector != NULL) ? g_nonceVector[thread] : (startNounce + thread);

		int hashPosition = nounce - startNounce;
		uint32_t *Hash = (uint32_t*)&g_hash[hashPosition<<3];

		// kopiere init-state
		uint32_t state[16] = {
			SPH_C32(0x72FCCDD8), SPH_C32(0x79CA4727), SPH_C32(0x128A077B), SPH_C32(0x40D55AEC),
			SPH_C32(0xD1901A06), SPH_C32(0x430AE307), SPH_C32(0xB29F5CD1), SPH_C32(0xDF07FBFC),
			SPH_C32(0x8E45D73D), SPH_C32(0x681AB538), SPH_C32(0xBDE86578), SPH_C32(0xDD577E47),
			SPH_C32(0xE275EADE), SPH_C32(0x502D9FCD), SPH_C32(0xB9357178), SPH_C32(0x022A4B9A)
		};

		// nachricht laden
		uint32_t msg[32];

		// fülle die Nachricht mit 64-byte (vorheriger Hash)
		#pragma unroll 16
		for(int i=0;i<16;i++)
			msg[i] = Hash[i];

		// Nachrichtenende
		msg[16] = 0x80;
		#pragma unroll 10
		for(int i=17;i<27;i++)
			msg[i] = 0;

		msg[27] = 0x02000000;
		msg[28] = 0;
		msg[29] = 0;
		msg[30] = 0;
		msg[31] = 0x02000000;

		c512(sharedMemory, state, msg, 512);

		#pragma unroll 16
		for(int i=0;i<16;i++)
			Hash[i] = state[i];
	}
}

__global__ __launch_bounds__(TPB, 7)
=======
		uint32_t nounce = (startNounce + thread);

		int hashPosition = nounce - startNounce;
		uint32_t *Hash = (uint32_t*)&g_hash[hashPosition*8];


		// kopiere init-state

		uint32_t rk[32];
		uint32_t msg[16];
//		{
//			Hash[0], Hash[1], Hash[2], Hash[3], Hash[4], Hash[5], Hash[6], Hash[7], Hash[8], Hash[9], Hash[10], Hash[11], Hash[12], Hash[13], Hash[14], Hash[15]
//		};


		uint28 *phash = (uint28*)Hash;
		uint28 *outpt = (uint28*)msg;
		outpt[0] = phash[0];
		outpt[1] = phash[1];

		uint32_t state[16]=
		{
			cstate[0], cstate[1], cstate[2], cstate[3],
			cstate[4], cstate[5], cstate[6], cstate[7],
			cstate[8], cstate[9], cstate[10], cstate[11],
			cstate[12], cstate[13], cstate[14], cstate[15],
		};

		/*
		if (threadIdx.x == 0) 
		{

			((uint16*)state)[0] = make_uint16(
				(0x72FCCDD8), (0x79CA4727), (0x128A077B), (0x40D55AEC),
				(0xD1901A06), (0x430AE307), (0xB29F5CD1), (0xDF07FBFC),
				(0x8E45D73D), (0x681AB538), (0xBDE86578), (0xDD577E47),
				(0xE275EADE), (0x502D9FCD), (0xB9357178), (0x022A4B9A)
				);
		}

*/

/*		uint32_t p0 = state[0x0];
		uint32_t p1 = state[0x1];
		uint32_t p2 = state[0x2];
		uint32_t p3 = state[0x3];
		uint32_t state[4] = state[0x4];
		uint32_t state[5] = state[0x5];
		uint32_t state[6] = state[0x6];
		uint32_t state[7] = state[0x7];
		uint32_t state[8] = state[0x8];
		uint32_t state[9] = state[0x9];
*/
//		uint32_t pA = state[0xA];
//		uint32_t pB = state[0xB];
//		uint32_t pC = state[0xC];
//		uint32_t pD = state[0xD];
//		uint32_t pE = state[0xE];
//		uint32_t pF = state[0xF];

		uint32_t x0 = state[0x4];
		uint32_t x1 = state[0x5];
		uint32_t x2 = state[0x6];
		uint32_t x3 = state[0x7];

		for (int i = 0; i < 16; i+=4)
		{

			rk[i + 0] = msg[i + 0];
			x0 ^= msg[i + 0];
			rk[i + 1] = msg[i + 1];
			x1 ^= msg[i + 1];
			rk[i + 2] = msg[i + 2];
			x2 ^= msg[i + 2];
			rk[i + 3] = msg[i + 3];
			x3 ^= msg[i + 3];
			AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		}
		state[0] ^= x0;
		state[1] ^= x1;
		state[2] ^= x2;
		state[3] ^= x3;

		// 1
		KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);

		rk[3] ^= (0x02000000UL ^ 0xFFFFFFFFUL);	//rk[31];
		rk[0] ^= 512;
		//	rk[3] ^= 0xFFFFFFFF;

		x0 = state[0] ^ rk[0];
		x1 = state[1] ^ rk[1];
		x2 = state[2] ^ rk[2];
		x3 = state[3] ^ rk[3];


		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
		rk[4] ^= rk[0];
		rk[5] ^= rk[1];
		rk[6] ^= rk[2];
		rk[7] ^= rk[3];
		x0 ^= rk[4];
		x1 ^= rk[5];
		x2 ^= rk[6];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
		rk[8] ^= rk[4];
		rk[9] ^= rk[5];
		rk[10] ^= rk[6];
		rk[11] ^= rk[7];
		x0 ^= rk[8];
		x1 ^= rk[9];
		x2 ^= rk[10];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
		rk[12] ^= rk[8];
		rk[13] ^= rk[9];
		rk[14] ^= rk[10];
		rk[15] ^= rk[11];
		x0 ^= rk[12];
		x1 ^= rk[13];
		x2 ^= rk[14];
		x3 ^= rk[15];

		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);

		state[8] ^= 0x32be246fUL;
		state[9] ^= 0xe33ad1e5UL;
		state[10] ^= 0xd659b13eUL;
		state[11] ^= 0xb6a1a92cUL;

		state[12] ^= x0;
		state[13] ^= x1;
		state[14] ^= x2;
		state[15] ^= x3;

		rk[16] = rk[12] ^ 0x63636363UL;
		rk[17] = rk[13] ^ 0x63636363UL;
		rk[18] = rk[14] ^ 0x63636363UL;
		rk[19] = rk[15] ^ 0x8acdcd24UL;
		x0 = state[8] ^ rk[16];
		x1 = state[9] ^ rk[17];
		x2 = state[10] ^ rk[18];
		x3 = state[11] ^ rk[19];
		rk[20] = 0x63636363UL ^ rk[16];
		rk[21] = 0x63636363UL ^ rk[17];
		rk[22] = 0x63636363UL ^ rk[18];
		rk[23] = 0x63636363UL ^ rk[19];
		rk[24] = 0x63636363UL ^ rk[20];
		rk[25] = 0x63636363UL ^ rk[21];
		rk[26] = 0x63636363UL ^ rk[22];
		rk[27] = 0x4b5f7777UL ^ rk[23];

		rk[28] = 0x63636363UL ^ rk[24];
		rk[29] = 0x63636363UL ^ rk[25];
		rk[30] = 0x63636363UL ^ rk[26];
		rk[31] = 0x4b5f7777UL ^ rk[27];



		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);

		x0 ^= rk[20];
		x1 ^= rk[21];
		x2 ^= rk[22];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);


		x0 ^= rk[24];
		x1 ^= rk[25];
		x2 ^= rk[26];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);

		x0 ^= rk[28];
		x1 ^= rk[29];
		x2 ^= rk[30];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);

		state[4] ^= x0;
		state[5] ^= x1;
		state[6] ^= x2;
		state[7] ^= x3;

		rk[0] ^= rk[25];
		x0 = state[12] ^ rk[0];
		rk[1] ^= rk[26];
		x1 = state[13] ^ rk[1];
		rk[2] ^= rk[27];
		x2 = state[14] ^ rk[2];
		rk[3] ^= rk[28];
		x3 = state[15] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[4] ^= rk[29];
		x0 ^= rk[4];
		rk[5] ^= rk[30];
		x1 ^= rk[5];
		rk[6] ^= rk[31];
		x2 ^= rk[6];
		rk[7] ^= rk[0];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[8] ^= rk[1];
		x0 ^= rk[8];
		rk[9] ^= rk[2];
		x1 ^= rk[9];
		rk[10] ^= rk[3];
		x2 ^= rk[10];
		rk[11] ^= rk[4];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[12] ^= rk[5];
		x0 ^= rk[12];
		rk[13] ^= rk[6];
		x1 ^= rk[13];
		rk[14] ^= rk[7];
		x2 ^= rk[14];
		rk[15] ^= rk[8];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[8] ^= x0;
		state[9] ^= x1;
		state[10] ^= x2;
		state[11] ^= x3;
		rk[16] ^= rk[9];
		x0 = state[4] ^ rk[16];
		rk[17] ^= rk[10];
		x1 = state[5] ^ rk[17];
		rk[18] ^= rk[11];
		x2 = state[6] ^ rk[18];
		rk[19] ^= rk[12];
		x3 = state[7] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[20] ^= rk[13];
		x0 ^= rk[20];
		rk[21] ^= rk[14];
		x1 ^= rk[21];
		rk[22] ^= rk[15];
		x2 ^= rk[22];
		rk[23] ^= rk[16];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[24] ^= rk[17];
		x0 ^= rk[24];
		rk[25] ^= rk[18];
		x1 ^= rk[25];
		rk[26] ^= rk[19];
		x2 ^= rk[26];
		rk[27] ^= rk[20];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[28] ^= rk[21];
		x0 ^= rk[28];
		rk[29] ^= rk[22];
		x1 ^= rk[29];
		rk[30] ^= rk[23];
		x2 ^= rk[30];
		rk[31] ^= rk[24];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[0] ^= x0;
		state[1] ^= x1;
		state[2] ^= x2;
		state[3] ^= x3;
		/* round 3, 7, 11 */
		KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
		rk[0] ^= rk[28];
		rk[1] ^= rk[29];
		rk[2] ^= rk[30];
		rk[3] ^= rk[31];
		x0 = state[8] ^ rk[0];
		x1 = state[9] ^ rk[1];
		x2 = state[10] ^ rk[2];
		x3 = state[11] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
		rk[4] ^= rk[0];
		rk[5] ^= rk[1];
		rk[6] ^= rk[2];
		rk[7] ^= rk[3];
		x0 ^= rk[4];
		x1 ^= rk[5];
		x2 ^= rk[6];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
		rk[8] ^= rk[4];
		rk[9] ^= rk[5];
		rk[10] ^= rk[6];
		rk[11] ^= rk[7];
		x0 ^= rk[8];
		x1 ^= rk[9];
		x2 ^= rk[10];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
		rk[12] ^= rk[8];
		rk[13] ^= rk[9];
		rk[14] ^= rk[10];
		rk[15] ^= rk[11];
		x0 ^= rk[12];
		x1 ^= rk[13];
		x2 ^= rk[14];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[4] ^= x0;
		state[5] ^= x1;
		state[6] ^= x2;
		state[7] ^= x3;
		KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
		rk[16] ^= rk[12];
		rk[17] ^= rk[13];
		rk[18] ^= rk[14];
		rk[19] ^= rk[15];
		x0 = state[0] ^ rk[16];
		x1 = state[1] ^ rk[17];
		x2 = state[2] ^ rk[18];
		x3 = state[3] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
		rk[20] ^= rk[16];
		rk[21] ^= rk[17];
		rk[22] ^= rk[18];
		rk[23] ^= rk[19];
		x0 ^= rk[20];
		x1 ^= rk[21];
		x2 ^= rk[22];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
		rk[24] ^= rk[20];
		rk[25] ^= rk[21];
		rk[26] ^= rk[22];
		rk[27] ^= rk[23];
		x0 ^= rk[24];
		x1 ^= rk[25];
		x2 ^= rk[26];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
		rk[28] ^= rk[24];
		rk[29] ^= rk[25];
		rk[30] ^= rk[26];
		rk[31] ^= rk[27];
		x0 ^= rk[28];
		x1 ^= rk[29];
		x2 ^= rk[30];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[12] ^= x0;
		state[13] ^= x1;
		state[14] ^= x2;
		state[15] ^= x3;
		/* round 4, 8, 12 */
		rk[0] ^= rk[25];
		x0 = state[4] ^ rk[0];
		rk[1] ^= rk[26];
		x1 = state[5] ^ rk[1];
		rk[2] ^= rk[27];
		x2 = state[6] ^ rk[2];
		rk[3] ^= rk[28];
		x3 = state[7] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[4] ^= rk[29];
		x0 ^= rk[4];
		rk[5] ^= rk[30];
		x1 ^= rk[5];
		rk[6] ^= rk[31];
		x2 ^= rk[6];
		rk[7] ^= rk[0];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[8] ^= rk[1];
		x0 ^= rk[8];
		rk[9] ^= rk[2];
		x1 ^= rk[9];
		rk[10] ^= rk[3];
		x2 ^= rk[10];
		rk[11] ^= rk[4];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[12] ^= rk[5];
		x0 ^= rk[12];
		rk[13] ^= rk[6];
		x1 ^= rk[13];
		rk[14] ^= rk[7];
		x2 ^= rk[14];
		rk[15] ^= rk[8];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);

		state[0] ^= x0;
		state[1] ^= x1;
		state[2] ^= x2;
		state[3] ^= x3;
		rk[16] ^= rk[9];
		x0 = state[12] ^ rk[16];
		rk[17] ^= rk[10];
		x1 = state[13] ^ rk[17];
		rk[18] ^= rk[11];
		x2 = state[14] ^ rk[18];
		rk[19] ^= rk[12];
		x3 = state[15] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[20] ^= rk[13];
		x0 ^= rk[20];
		rk[21] ^= rk[14];
		x1 ^= rk[21];
		rk[22] ^= rk[15];
		x2 ^= rk[22];
		rk[23] ^= rk[16];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[24] ^= rk[17];
		x0 ^= rk[24];
		rk[25] ^= rk[18];
		x1 ^= rk[25];
		rk[26] ^= rk[19];
		x2 ^= rk[26];
		rk[27] ^= rk[20];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[28] ^= rk[21];
		x0 ^= rk[28];
		rk[29] ^= rk[22];
		x1 ^= rk[29];
		rk[30] ^= rk[23];
		x2 ^= rk[30];
		rk[31] ^= rk[24];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[8] ^= x0;
		state[9] ^= x1;
		state[10] ^= x2;
		state[11] ^= x3;

		// 2
		KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
		rk[0] ^= rk[28];
		rk[1] ^= rk[29];
		rk[2] ^= rk[30];
		rk[3] ^= rk[31];
		x0 = state[0] ^ rk[0];
		x1 = state[1] ^ rk[1];
		x2 = state[2] ^ rk[2];
		x3 = state[3] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
		rk[4] ^= rk[0];
		rk[5] ^= rk[1];
		rk[6] ^= rk[2];
		rk[7] ^= rk[3];
		rk[7] ^= ~512;
		x0 ^= rk[4];
		x1 ^= rk[5];
		x2 ^= rk[6];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
		rk[8] ^= rk[4];
		rk[9] ^= rk[5];
		rk[10] ^= rk[6];
		rk[11] ^= rk[7];
		x0 ^= rk[8];
		x1 ^= rk[9];
		x2 ^= rk[10];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
		rk[12] ^= rk[8];
		rk[13] ^= rk[9];
		rk[14] ^= rk[10];
		rk[15] ^= rk[11];
		x0 ^= rk[12];
		x1 ^= rk[13];
		x2 ^= rk[14];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[12] ^= x0;
		state[13] ^= x1;
		state[14] ^= x2;
		state[15] ^= x3;
		KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
		rk[16] ^= rk[12];
		rk[17] ^= rk[13];
		rk[18] ^= rk[14];
		rk[19] ^= rk[15];
		x0 = state[8] ^ rk[16];
		x1 = state[9] ^ rk[17];
		x2 = state[10] ^ rk[18];
		x3 = state[11] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
		rk[20] ^= rk[16];
		rk[21] ^= rk[17];
		rk[22] ^= rk[18];
		rk[23] ^= rk[19];
		x0 ^= rk[20];
		x1 ^= rk[21];
		x2 ^= rk[22];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
		rk[24] ^= rk[20];
		rk[25] ^= rk[21];
		rk[26] ^= rk[22];
		rk[27] ^= rk[23];
		x0 ^= rk[24];
		x1 ^= rk[25];
		x2 ^= rk[26];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
		rk[28] ^= rk[24];
		rk[29] ^= rk[25];
		rk[30] ^= rk[26];
		rk[31] ^= rk[27];
		x0 ^= rk[28];
		x1 ^= rk[29];
		x2 ^= rk[30];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[4] ^= x0;
		state[5] ^= x1;
		state[6] ^= x2;
		state[7] ^= x3;

		rk[0] ^= rk[25];
		x0 = state[12] ^ rk[0];
		rk[1] ^= rk[26];
		x1 = state[13] ^ rk[1];
		rk[2] ^= rk[27];
		x2 = state[14] ^ rk[2];
		rk[3] ^= rk[28];
		x3 = state[15] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[4] ^= rk[29];
		x0 ^= rk[4];
		rk[5] ^= rk[30];
		x1 ^= rk[5];
		rk[6] ^= rk[31];
		x2 ^= rk[6];
		rk[7] ^= rk[0];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[8] ^= rk[1];
		x0 ^= rk[8];
		rk[9] ^= rk[2];
		x1 ^= rk[9];
		rk[10] ^= rk[3];
		x2 ^= rk[10];
		rk[11] ^= rk[4];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[12] ^= rk[5];
		x0 ^= rk[12];
		rk[13] ^= rk[6];
		x1 ^= rk[13];
		rk[14] ^= rk[7];
		x2 ^= rk[14];
		rk[15] ^= rk[8];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[8] ^= x0;
		state[9] ^= x1;
		state[10] ^= x2;
		state[11] ^= x3;
		rk[16] ^= rk[9];
		x0 = state[4] ^ rk[16];
		rk[17] ^= rk[10];
		x1 = state[5] ^ rk[17];
		rk[18] ^= rk[11];
		x2 = state[6] ^ rk[18];
		rk[19] ^= rk[12];
		x3 = state[7] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[20] ^= rk[13];
		x0 ^= rk[20];
		rk[21] ^= rk[14];
		x1 ^= rk[21];
		rk[22] ^= rk[15];
		x2 ^= rk[22];
		rk[23] ^= rk[16];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[24] ^= rk[17];
		x0 ^= rk[24];
		rk[25] ^= rk[18];
		x1 ^= rk[25];
		rk[26] ^= rk[19];
		x2 ^= rk[26];
		rk[27] ^= rk[20];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[28] ^= rk[21];
		x0 ^= rk[28];
		rk[29] ^= rk[22];
		x1 ^= rk[29];
		rk[30] ^= rk[23];
		x2 ^= rk[30];
		rk[31] ^= rk[24];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[0] ^= x0;
		state[1] ^= x1;
		state[2] ^= x2;
		state[3] ^= x3;
		/* round 3, 7, 11 */
		KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
		rk[0] ^= rk[28];
		rk[1] ^= rk[29];
		rk[2] ^= rk[30];
		rk[3] ^= rk[31];
		x0 = state[8] ^ rk[0];
		x1 = state[9] ^ rk[1];
		x2 = state[10] ^ rk[2];
		x3 = state[11] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
		rk[4] ^= rk[0];
		rk[5] ^= rk[1];
		rk[6] ^= rk[2];
		rk[7] ^= rk[3];
		x0 ^= rk[4];
		x1 ^= rk[5];
		x2 ^= rk[6];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
		rk[8] ^= rk[4];
		rk[9] ^= rk[5];
		rk[10] ^= rk[6];
		rk[11] ^= rk[7];
		x0 ^= rk[8];
		x1 ^= rk[9];
		x2 ^= rk[10];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
		rk[12] ^= rk[8];
		rk[13] ^= rk[9];
		rk[14] ^= rk[10];
		rk[15] ^= rk[11];
		x0 ^= rk[12];
		x1 ^= rk[13];
		x2 ^= rk[14];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[4] ^= x0;
		state[5] ^= x1;
		state[6] ^= x2;
		state[7] ^= x3;
		KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
		rk[16] ^= rk[12];
		rk[17] ^= rk[13];
		rk[18] ^= rk[14];
		rk[19] ^= rk[15];
		x0 = state[0] ^ rk[16];
		x1 = state[1] ^ rk[17];
		x2 = state[2] ^ rk[18];
		x3 = state[3] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
		rk[20] ^= rk[16];
		rk[21] ^= rk[17];
		rk[22] ^= rk[18];
		rk[23] ^= rk[19];
		x0 ^= rk[20];
		x1 ^= rk[21];
		x2 ^= rk[22];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
		rk[24] ^= rk[20];
		rk[25] ^= rk[21];
		rk[26] ^= rk[22];
		rk[27] ^= rk[23];
		x0 ^= rk[24];
		x1 ^= rk[25];
		x2 ^= rk[26];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
		rk[28] ^= rk[24];
		rk[29] ^= rk[25];
		rk[30] ^= rk[26];
		rk[31] ^= rk[27];
		x0 ^= rk[28];
		x1 ^= rk[29];
		x2 ^= rk[30];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[12] ^= x0;
		state[13] ^= x1;
		state[14] ^= x2;
		state[15] ^= x3;
		/* round 4, 8, 12 */
		rk[0] ^= rk[25];
		x0 = state[4] ^ rk[0];
		rk[1] ^= rk[26];
		x1 = state[5] ^ rk[1];
		rk[2] ^= rk[27];
		x2 = state[6] ^ rk[2];
		rk[3] ^= rk[28];
		x3 = state[7] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[4] ^= rk[29];
		x0 ^= rk[4];
		rk[5] ^= rk[30];
		x1 ^= rk[5];
		rk[6] ^= rk[31];
		x2 ^= rk[6];
		rk[7] ^= rk[0];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[8] ^= rk[1];
		x0 ^= rk[8];
		rk[9] ^= rk[2];
		x1 ^= rk[9];
		rk[10] ^= rk[3];
		x2 ^= rk[10];
		rk[11] ^= rk[4];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[12] ^= rk[5];
		x0 ^= rk[12];
		rk[13] ^= rk[6];
		x1 ^= rk[13];
		rk[14] ^= rk[7];
		x2 ^= rk[14];
		rk[15] ^= rk[8];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[0] ^= x0;
		state[1] ^= x1;
		state[2] ^= x2;
		state[3] ^= x3;
		rk[16] ^= rk[9];
		x0 = state[12] ^ rk[16];
		rk[17] ^= rk[10];
		x1 = state[13] ^ rk[17];
		rk[18] ^= rk[11];
		x2 = state[14] ^ rk[18];
		rk[19] ^= rk[12];
		x3 = state[15] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[20] ^= rk[13];
		x0 ^= rk[20];
		rk[21] ^= rk[14];
		x1 ^= rk[21];
		rk[22] ^= rk[15];
		x2 ^= rk[22];
		rk[23] ^= rk[16];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[24] ^= rk[17];
		x0 ^= rk[24];
		rk[25] ^= rk[18];
		x1 ^= rk[25];
		rk[26] ^= rk[19];
		x2 ^= rk[26];
		rk[27] ^= rk[20];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[28] ^= rk[21];
		x0 ^= rk[28];
		rk[29] ^= rk[22];
		x1 ^= rk[29];
		rk[30] ^= rk[23];
		x2 ^= rk[30];
		rk[31] ^= rk[24];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[8] ^= x0;
		state[9] ^= x1;
		state[10] ^= x2;
		state[11] ^= x3;

		// 3
		KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
		rk[0] ^= rk[28];
		rk[1] ^= rk[29];
		rk[2] ^= rk[30];
		rk[3] ^= rk[31];
		x0 = state[0] ^ rk[0];
		x1 = state[1] ^ rk[1];
		x2 = state[2] ^ rk[2];
		x3 = state[3] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
		rk[4] ^= rk[0];
		rk[5] ^= rk[1];
		rk[6] ^= rk[2];
		rk[7] ^= rk[3];
		x0 ^= rk[4];
		x1 ^= rk[5];
		x2 ^= rk[6];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
		rk[8] ^= rk[4];
		rk[9] ^= rk[5];
		rk[10] ^= rk[6];
		rk[11] ^= rk[7];
		x0 ^= rk[8];
		x1 ^= rk[9];
		x2 ^= rk[10];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
		rk[12] ^= rk[8];
		rk[13] ^= rk[9];
		rk[14] ^= rk[10];
		rk[15] ^= rk[11];
		x0 ^= rk[12];
		x1 ^= rk[13];
		x2 ^= rk[14];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[12] ^= x0;
		state[13] ^= x1;
		state[14] ^= x2;
		state[15] ^= x3;
		KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
		rk[16] ^= rk[12];
		rk[17] ^= rk[13];
		rk[18] ^= rk[14];
		rk[19] ^= rk[15];
		x0 = state[8] ^ rk[16];
		x1 = state[9] ^ rk[17];
		x2 = state[10] ^ rk[18];
		x3 = state[11] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
		rk[20] ^= rk[16];
		rk[21] ^= rk[17];
		rk[22] ^= rk[18];
		rk[23] ^= rk[19];
		x0 ^= rk[20];
		x1 ^= rk[21];
		x2 ^= rk[22];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
		rk[24] ^= rk[20];
		rk[25] ^= rk[21];
		rk[26] ^= rk[22];
		rk[27] ^= rk[23];
		x0 ^= rk[24];
		x1 ^= rk[25];
		x2 ^= rk[26];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
		rk[28] ^= rk[24];
		rk[29] ^= rk[25];
		rk[30] ^= rk[26];
		rk[31] ^= ~rk[27];
		rk[30] ^= 512;
//		rk[31] ^= 0xFFFFFFFF;
		x0 ^= rk[28];
		x1 ^= rk[29];
		x2 ^= rk[30];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[4] ^= x0;
		state[5] ^= x1;
		state[6] ^= x2;
		state[7] ^= x3;

		rk[0] ^= rk[25];
		x0 = state[12] ^ rk[0];
		rk[1] ^= rk[26];
		x1 = state[13] ^ rk[1];
		rk[2] ^= rk[27];
		x2 = state[14] ^ rk[2];
		rk[3] ^= rk[28];
		x3 = state[15] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[4] ^= rk[29];
		x0 ^= rk[4];
		rk[5] ^= rk[30];
		x1 ^= rk[5];
		rk[6] ^= rk[31];
		x2 ^= rk[6];
		rk[7] ^= rk[0];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[8] ^= rk[1];
		x0 ^= rk[8];
		rk[9] ^= rk[2];
		x1 ^= rk[9];
		rk[10] ^= rk[3];
		x2 ^= rk[10];
		rk[11] ^= rk[4];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[12] ^= rk[5];
		x0 ^= rk[12];
		rk[13] ^= rk[6];
		x1 ^= rk[13];
		rk[14] ^= rk[7];
		x2 ^= rk[14];
		rk[15] ^= rk[8];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[8] ^= x0;
		state[9] ^= x1;
		state[10] ^= x2;
		state[11] ^= x3;
		rk[16] ^= rk[9];
		x0 = state[4] ^ rk[16];
		rk[17] ^= rk[10];
		x1 = state[5] ^ rk[17];
		rk[18] ^= rk[11];
		x2 = state[6] ^ rk[18];
		rk[19] ^= rk[12];
		x3 = state[7] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[20] ^= rk[13];
		x0 ^= rk[20];
		rk[21] ^= rk[14];
		x1 ^= rk[21];
		rk[22] ^= rk[15];
		x2 ^= rk[22];
		rk[23] ^= rk[16];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[24] ^= rk[17];
		x0 ^= rk[24];
		rk[25] ^= rk[18];
		x1 ^= rk[25];
		rk[26] ^= rk[19];
		x2 ^= rk[26];
		rk[27] ^= rk[20];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[28] ^= rk[21];
		x0 ^= rk[28];
		rk[29] ^= rk[22];
		x1 ^= rk[29];
		rk[30] ^= rk[23];
		x2 ^= rk[30];
		rk[31] ^= rk[24];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[0] ^= x0;
		state[1] ^= x1;
		state[2] ^= x2;
		state[3] ^= x3;

		/* round 3, 7, 11 */
		KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
		rk[0] ^= rk[28];
		rk[1] ^= rk[29];
		rk[2] ^= rk[30];
		rk[3] ^= rk[31];
		x0 = state[8] ^ rk[0];
		x1 = state[9] ^ rk[1];
		x2 = state[10] ^ rk[2];
		x3 = state[11] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
		rk[4] ^= rk[0];
		rk[5] ^= rk[1];
		rk[6] ^= rk[2];
		rk[7] ^= rk[3];
		x0 ^= rk[4];
		x1 ^= rk[5];
		x2 ^= rk[6];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
		rk[8] ^= rk[4];
		rk[9] ^= rk[5];
		rk[10] ^= rk[6];
		rk[11] ^= rk[7];
		x0 ^= rk[8];
		x1 ^= rk[9];
		x2 ^= rk[10];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
		rk[12] ^= rk[8];
		rk[13] ^= rk[9];
		rk[14] ^= rk[10];
		rk[15] ^= rk[11];
		x0 ^= rk[12];
		x1 ^= rk[13];
		x2 ^= rk[14];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[4] ^= x0;
		state[5] ^= x1;
		state[6] ^= x2;
		state[7] ^= x3;
		KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
		rk[16] ^= rk[12];
		rk[17] ^= rk[13];
		rk[18] ^= rk[14];
		rk[19] ^= rk[15];
		x0 = state[0] ^ rk[16];
		x1 = state[1] ^ rk[17];
		x2 = state[2] ^ rk[18];
		x3 = state[3] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
		rk[20] ^= rk[16];
		rk[21] ^= rk[17];
		rk[22] ^= rk[18];
		rk[23] ^= rk[19];
		x0 ^= rk[20];
		x1 ^= rk[21];
		x2 ^= rk[22];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
		rk[24] ^= rk[20];
		rk[25] ^= rk[21];
		rk[26] ^= rk[22];
		rk[27] ^= rk[23];
		x0 ^= rk[24];
		x1 ^= rk[25];
		x2 ^= rk[26];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
		rk[28] ^= rk[24];
		rk[29] ^= rk[25];
		rk[30] ^= rk[26];
		rk[31] ^= rk[27];
		x0 ^= rk[28];
		x1 ^= rk[29];
		x2 ^= rk[30];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[12] ^= x0;
		state[13] ^= x1;
		state[14] ^= x2;
		state[15] ^= x3;
		/* round 4, 8, 12 */
		rk[0] ^= rk[25];
		x0 = state[4] ^ rk[0];
		rk[1] ^= rk[26];
		x1 = state[5] ^ rk[1];
		rk[2] ^= rk[27];
		x2 = state[6] ^ rk[2];
		rk[3] ^= rk[28];
		x3 = state[7] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[4] ^= rk[29];
		x0 ^= rk[4];
		rk[5] ^= rk[30];
		x1 ^= rk[5];
		rk[6] ^= rk[31];
		x2 ^= rk[6];
		rk[7] ^= rk[0];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[8] ^= rk[1];
		x0 ^= rk[8];
		rk[9] ^= rk[2];
		x1 ^= rk[9];
		rk[10] ^= rk[3];
		x2 ^= rk[10];
		rk[11] ^= rk[4];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[12] ^= rk[5];
		x0 ^= rk[12];
		rk[13] ^= rk[6];
		x1 ^= rk[13];
		rk[14] ^= rk[7];
		x2 ^= rk[14];
		rk[15] ^= rk[8];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[0] ^= x0;
		state[1] ^= x1;
		state[2] ^= x2;
		state[3] ^= x3;
		rk[16] ^= rk[9];
		x0 = state[12] ^ rk[16];
		rk[17] ^= rk[10];
		x1 = state[13] ^ rk[17];
		rk[18] ^= rk[11];
		x2 = state[14] ^ rk[18];
		rk[19] ^= rk[12];
		x3 = state[15] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[20] ^= rk[13];
		x0 ^= rk[20];
		rk[21] ^= rk[14];
		x1 ^= rk[21];
		rk[22] ^= rk[15];
		x2 ^= rk[22];
		rk[23] ^= rk[16];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[24] ^= rk[17];
		x0 ^= rk[24];
		rk[25] ^= rk[18];
		x1 ^= rk[25];
		rk[26] ^= rk[19];
		x2 ^= rk[26];
		rk[27] ^= rk[20];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		rk[28] ^= rk[21];
		x0 ^= rk[28];
		rk[29] ^= rk[22];
		x1 ^= rk[29];
		rk[30] ^= rk[23];
		x2 ^= rk[30];
		rk[31] ^= rk[24];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[8] ^= x0;
		state[9] ^= x1;
		state[10] ^= x2;
		state[11] ^= x3;

		/* round 13 */
		KEY_EXPAND_ELT(sharedMemory, rk[0], rk[1], rk[2], rk[3]);
		rk[0] ^= rk[28];
		rk[1] ^= rk[29];
		rk[2] ^= rk[30];
		rk[3] ^= rk[31];
		x0 = state[0] ^ rk[0];
		x1 = state[1] ^ rk[1];
		x2 = state[2] ^ rk[2];
		x3 = state[3] ^ rk[3];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[4], rk[5], rk[6], rk[7]);
		rk[4] ^= rk[0];
		rk[5] ^= rk[1];
		rk[6] ^= rk[2];
		rk[7] ^= rk[3];
		x0 ^= rk[4];
		x1 ^= rk[5];
		x2 ^= rk[6];
		x3 ^= rk[7];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[8], rk[9], rk[10], rk[11]);
		rk[8] ^= rk[4];
		rk[9] ^= rk[5];
		rk[10] ^= rk[6];
		rk[11] ^= rk[7];
		x0 ^= rk[8];
		x1 ^= rk[9];
		x2 ^= rk[10];
		x3 ^= rk[11];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[12], rk[13], rk[14], rk[15]);
		rk[12] ^= rk[8];
		rk[13] ^= rk[9];
		rk[14] ^= rk[10];
		rk[15] ^= rk[11];
		x0 ^= rk[12];
		x1 ^= rk[13];
		x2 ^= rk[14];
		x3 ^= rk[15];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[12] ^= x0;
		state[13] ^= x1;
		state[14] ^= x2;
		state[15] ^= x3;
		KEY_EXPAND_ELT(sharedMemory, rk[16], rk[17], rk[18], rk[19]);
		rk[16] ^= rk[12];
		rk[17] ^= rk[13];
		rk[18] ^= rk[14];
		rk[19] ^= rk[15];
		x0 = state[8] ^ rk[16];
		x1 = state[9] ^ rk[17];
		x2 = state[10] ^ rk[18];
		x3 = state[11] ^ rk[19];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[20], rk[21], rk[22], rk[23]);
		rk[20] ^= rk[16];
		rk[21] ^= rk[17];
		rk[22] ^= rk[18];
		rk[23] ^= rk[19];
		x0 ^= rk[20];
		x1 ^= rk[21];
		x2 ^= rk[22];
		x3 ^= rk[23];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[24], rk[25], rk[26], rk[27]);
		rk[24] ^= rk[20];
		rk[25] ^= rk[21] ^ 512;
		rk[26] ^= rk[22];
		rk[27] ^= ~rk[23]; //^ 0xFFFFFFFF;
		x0 ^= rk[24];
		x1 ^= rk[25];
		x2 ^= rk[26];
		x3 ^= rk[27];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		KEY_EXPAND_ELT(sharedMemory, rk[28], rk[29], rk[30], rk[31]);
		rk[28] ^= rk[24];
		rk[29] ^= rk[25];
		rk[30] ^= rk[26];
		rk[31] ^= rk[27];
		x0 ^= rk[28];
		x1 ^= rk[29];
		x2 ^= rk[30];
		x3 ^= rk[31];
		AES_ROUND_NOKEY(sharedMemory, x0, x1, x2, x3);
		state[4] ^= x0;
		state[5] ^= x1;
		state[6] ^= x2;
		state[7] ^= x3;




		Hash[0] = cstate[0x0] ^ state[8];
		Hash[1] = cstate[0x1] ^ state[9];
		Hash[2] = cstate[0x2] ^ state[10];
		Hash[3] = cstate[0x3] ^ state[11];
		Hash[4] = cstate[0x4] ^ state[12];
		Hash[5] = cstate[0x5] ^ state[13];
		Hash[6] = cstate[0x6] ^ state[14];
		Hash[7] = cstate[0x7] ^ state[15];
		Hash[8] = cstate[0x8] ^ state[0];
		Hash[9] = cstate[0x9] ^ state[1];
		Hash[10] = cstate[0xA] ^ state[2];
		Hash[11] = cstate[0xB] ^ state[3];
		Hash[12] = cstate[0xC] ^ state[4];
		Hash[13] = cstate[0xD] ^ state[5];
		Hash[14] = cstate[0xE] ^ state[6];
		Hash[15] = cstate[0xF] ^ state[7];
	}
}


__global__ __launch_bounds__(TPB, 2)
>>>>>>> 8c320ca... added xevan
void x11_shavite512_gpu_hash_80(uint32_t threads, uint32_t startNounce, void *outputHash)
{
	__shared__ uint32_t sharedMemory[1024];

<<<<<<< HEAD
	shavite_gpu_init(sharedMemory);
	__threadfence_block();
=======
	if (threadIdx.x < 256) 
	{
		sharedMemory[threadIdx.x] = d_AES0[threadIdx.x];
		sharedMemory[threadIdx.x + 256] = ROTL32(sharedMemory[threadIdx.x], 8);
		sharedMemory[threadIdx.x + 512] = ROTL32(sharedMemory[threadIdx.x], 16);
		sharedMemory[threadIdx.x + 768] = ROTL32(sharedMemory[threadIdx.x], 24);
	}
>>>>>>> 8c320ca... added xevan

	uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);
	if (thread < threads)
	{
		const uint32_t nounce = startNounce + thread;

<<<<<<< HEAD
		// initial state
		uint32_t state[16] = {
			SPH_C32(0x72FCCDD8), SPH_C32(0x79CA4727), SPH_C32(0x128A077B), SPH_C32(0x40D55AEC),
			SPH_C32(0xD1901A06), SPH_C32(0x430AE307), SPH_C32(0xB29F5CD1), SPH_C32(0xDF07FBFC),
			SPH_C32(0x8E45D73D), SPH_C32(0x681AB538), SPH_C32(0xBDE86578), SPH_C32(0xDD577E47),
			SPH_C32(0xE275EADE), SPH_C32(0x502D9FCD), SPH_C32(0xB9357178), SPH_C32(0x022A4B9A)
=======
		// kopiere init-state
		uint32_t state[16] = {
			0x72FCCDD8, 0x79CA4727, 0x128A077B, 0x40D55AEC,
			0xD1901A06, 0x430AE307, 0xB29F5CD1, 0xDF07FBFC,
			0x8E45D73D, 0x681AB538, 0xBDE86578, 0xDD577E47,
			0xE275EADE, 0x502D9FCD, 0xB9357178, 0x022A4B9A
>>>>>>> 8c320ca... added xevan
		};

		uint32_t msg[32];

		#pragma unroll 32
		for(int i=0;i<32;i++) {
			msg[i] = c_PaddedMessage80[i];
		}
		msg[19] = cuda_swab32(nounce);
		msg[20] = 0x80;
		msg[27] = 0x2800000;
		msg[31] = 0x2000000;

<<<<<<< HEAD
		c512(sharedMemory, state, msg, 640);
=======
		c512(sharedMemory, state, msg);
>>>>>>> 8c320ca... added xevan

		uint32_t *outHash = (uint32_t *)outputHash + 16 * thread;

		#pragma unroll 16
		for(int i=0;i<16;i++)
			outHash[i] = state[i];

	} //thread < threads
}

<<<<<<< HEAD
__host__
void x11_shavite512_cpu_hash_64(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_nonceVector, uint32_t *d_hash, int order)
{
	const uint32_t threadsperblock = TPB;

	dim3 grid((threads + threadsperblock-1)/threadsperblock);
	dim3 block(threadsperblock);

	// note: 128 threads minimum are required to init the shared memory array
	x11_shavite512_gpu_hash_64<<<grid, block>>>(threads, startNounce, (uint64_t*)d_hash, d_nonceVector);
	//MyStreamSynchronize(NULL, order, thr_id);
}

__host__
void x11_shavite512_cpu_hash_80(int thr_id, uint32_t threads, uint32_t startNounce, uint32_t *d_outputHash, int order)
{
	const uint32_t threadsperblock = TPB;

	dim3 grid((threads + threadsperblock-1)/threadsperblock);
	dim3 block(threadsperblock);
=======
__host__ void x11_shavite512_cpu_hash_64(uint32_t threads, uint32_t startNounce, uint32_t *d_hash, uint32_t shavitethreads)
{
	// berechne wie viele Thread Blocks wir brauchen
	dim3 grid((threads + shavitethreads - 1) / shavitethreads);
	dim3 block(shavitethreads);

	x11_shavite512_gpu_hash_64<<<grid, block>>>(threads, startNounce, (uint64_t*)d_hash);
}

__host__ void x11_shavite512_cpu_hash_80(uint32_t threads, uint32_t startNounce, uint32_t *d_outputHash)
{

	// berechne wie viele Thread Blocks wir brauchen
	dim3 grid((threads + TPB - 1) / TPB);
	dim3 block(TPB);
>>>>>>> 8c320ca... added xevan

	x11_shavite512_gpu_hash_80<<<grid, block>>>(threads, startNounce, d_outputHash);
}

<<<<<<< HEAD
__host__
void x11_shavite512_cpu_init(int thr_id, uint32_t threads)
{
	aes_cpu_init(thr_id);
}

__host__
void x11_shavite512_setBlock_80(void *pdata)
{
	// Message with Padding
	// The nonce is at Byte 76.
=======
__host__ void x11_shavite512_setBlock_80(void *pdata)
{
	// Message mit Padding bereitstellen
	// lediglich die korrekte Nonce ist noch ab Byte 76 einzusetzen.
>>>>>>> 8c320ca... added xevan
	unsigned char PaddedMessage[128];
	memcpy(PaddedMessage, pdata, 80);
	memset(PaddedMessage+80, 0, 48);

	cudaMemcpyToSymbol(c_PaddedMessage80, PaddedMessage, 32*sizeof(uint32_t), 0, cudaMemcpyHostToDevice);
}
<<<<<<< HEAD
=======

>>>>>>> 8c320ca... added xevan
