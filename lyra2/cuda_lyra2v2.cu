<<<<<<< HEAD
/**
 * Lyra2 (v2) CUDA Implementation
 *
 * Based on djm34/VTC sources and incredible 2x boost by Nanashi Meiyo-Meijin (May 2016)
 */
#include <stdio.h>
#include <stdint.h>
#include <memory.h>

#include "cuda_lyra2v2_sm3.cuh"

#ifdef __INTELLISENSE__
/* just for vstudio code colors */
#define __CUDA_ARCH__ 500
#endif

#define TPB 32

#if __CUDA_ARCH__ >= 500

#include "cuda_lyra2_vectors.h"

#define Nrow 4
#define Ncol 4
#define memshift 3

__device__ uint2x4 *DMatrix;

__device__ __forceinline__ uint2 LD4S(const int index)
{
	extern __shared__ uint2 shared_mem[];
	return shared_mem[(index * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x];
}

__device__ __forceinline__ void ST4S(const int index, const uint2 data)
{
	extern __shared__ uint2 shared_mem[];
	shared_mem[(index * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x] = data;
}

__device__ __forceinline__ uint2 shuffle2(uint2 a, uint32_t b, uint32_t c)
{
	return make_uint2(__shfl(a.x, b, c), __shfl(a.y, b, c));
}

__device__ __forceinline__
void Gfunc_v5(uint2 &a, uint2 &b, uint2 &c, uint2 &d)
{
	a += b; d ^= a; d = SWAPUINT2(d);
	c += d; b ^= c; b = ROR2(b, 24);
	a += b; d ^= a; d = ROR2(d, 16);
	c += d; b ^= c; b = ROR2(b, 63);
}

__device__ __forceinline__
void round_lyra_v5(uint2x4 s[4])
{
	Gfunc_v5(s[0].x, s[1].x, s[2].x, s[3].x);
	Gfunc_v5(s[0].y, s[1].y, s[2].y, s[3].y);
	Gfunc_v5(s[0].z, s[1].z, s[2].z, s[3].z);
	Gfunc_v5(s[0].w, s[1].w, s[2].w, s[3].w);

	Gfunc_v5(s[0].x, s[1].y, s[2].z, s[3].w);
	Gfunc_v5(s[0].y, s[1].z, s[2].w, s[3].x);
	Gfunc_v5(s[0].z, s[1].w, s[2].x, s[3].y);
	Gfunc_v5(s[0].w, s[1].x, s[2].y, s[3].z);
}

__device__ __forceinline__
void round_lyra_v5(uint2 s[4])
{
	Gfunc_v5(s[0], s[1], s[2], s[3]);
	s[1] = shuffle2(s[1], threadIdx.x + 1, 4);
	s[2] = shuffle2(s[2], threadIdx.x + 2, 4);
	s[3] = shuffle2(s[3], threadIdx.x + 3, 4);
	Gfunc_v5(s[0], s[1], s[2], s[3]);
	s[1] = shuffle2(s[1], threadIdx.x + 3, 4);
	s[2] = shuffle2(s[2], threadIdx.x + 2, 4);
	s[3] = shuffle2(s[3], threadIdx.x + 1, 4);
}

__device__ __forceinline__
void reduceDuplexRowSetup2(uint2 state[4])
{
	uint2 state1[Ncol][3], state0[Ncol][3], state2[3];
	int i, j;

	#pragma unroll
	for (int i = 0; i < Ncol; i++)
	{
		#pragma unroll
		for (j = 0; j < 3; j++)
			state0[Ncol - i - 1][j] = state[j];
		round_lyra_v5(state);
	}

	//#pragma unroll 4
	for (i = 0; i < Ncol; i++)
	{
		#pragma unroll
		for (j = 0; j < 3; j++)
			state[j] ^= state0[i][j];

		round_lyra_v5(state);

		#pragma unroll
		for (j = 0; j < 3; j++)
			state1[Ncol - i - 1][j] = state0[i][j];

		#pragma unroll
		for (j = 0; j < 3; j++)
			state1[Ncol - i - 1][j] ^= state[j];
	}

	for (i = 0; i < Ncol; i++)
	{
		const uint32_t s0 = memshift * Ncol * 0 + i * memshift;
		const uint32_t s2 = memshift * Ncol * 2 + memshift * (Ncol - 1) - i*memshift;

		#pragma unroll
		for (j = 0; j < 3; j++)
			state[j] ^= state1[i][j] + state0[i][j];

		round_lyra_v5(state);

		#pragma unroll
		for (j = 0; j < 3; j++)
			state2[j] = state1[i][j];

		#pragma unroll
		for (j = 0; j < 3; j++)
			state2[j] ^= state[j];

		#pragma unroll
		for (j = 0; j < 3; j++)
			ST4S(s2 + j, state2[j]);

		uint2 Data0 = shuffle2(state[0], threadIdx.x - 1, 4);
		uint2 Data1 = shuffle2(state[1], threadIdx.x - 1, 4);
		uint2 Data2 = shuffle2(state[2], threadIdx.x - 1, 4);

		if (threadIdx.x == 0) {
			state0[i][0] ^= Data2;
			state0[i][1] ^= Data0;
			state0[i][2] ^= Data1;
		} else {
			state0[i][0] ^= Data0;
			state0[i][1] ^= Data1;
			state0[i][2] ^= Data2;
		}

		#pragma unroll
		for (j = 0; j < 3; j++)
			ST4S(s0 + j, state0[i][j]);

		#pragma unroll
		for (j = 0; j < 3; j++)
			state0[i][j] = state2[j];

	}

	for (i = 0; i < Ncol; i++)
	{
		const uint32_t s1 = memshift * Ncol * 1 + i*memshift;
		const uint32_t s3 = memshift * Ncol * 3 + memshift * (Ncol - 1) - i*memshift;

		#pragma unroll
		for (j = 0; j < 3; j++)
			state[j] ^= state1[i][j] + state0[Ncol - i - 1][j];

		round_lyra_v5(state);

		#pragma unroll
		for (j = 0; j < 3; j++)
			state0[Ncol - i - 1][j] ^= state[j];

		#pragma unroll
		for (j = 0; j < 3; j++)
			ST4S(s3 + j, state0[Ncol - i - 1][j]);

		uint2 Data0 = shuffle2(state[0], threadIdx.x - 1, 4);
		uint2 Data1 = shuffle2(state[1], threadIdx.x - 1, 4);
		uint2 Data2 = shuffle2(state[2], threadIdx.x - 1, 4);

		if (threadIdx.x == 0) {
			state1[i][0] ^= Data2;
			state1[i][1] ^= Data0;
			state1[i][2] ^= Data1;
		} else  {
			state1[i][0] ^= Data0;
			state1[i][1] ^= Data1;
			state1[i][2] ^= Data2;
		}

		#pragma unroll
		for (j = 0; j < 3; j++)
			ST4S(s1 + j, state1[i][j]);
	}
}

__device__
void reduceDuplexRowt2(const int rowIn, const int rowInOut, const int rowOut, uint2 state[4])
{
	uint2 state1[3], state2[3];
	const uint32_t ps1 = memshift * Ncol * rowIn;
	const uint32_t ps2 = memshift * Ncol * rowInOut;
	const uint32_t ps3 = memshift * Ncol * rowOut;

	for (int i = 0; i < Ncol; i++)
=======


#include <stdio.h>
#include <memory.h>
#include "cuda_vector.h"
#define TPB52 256
#define TPB50 64

 
#define Nrow 4
#define Ncol 4
#define u64type uint2
#define vectype uint28
#define memshift 3
__device__ vectype  *DMatrix;

 
__device__ __forceinline__ void Gfunc_v35(uint2 & a, uint2 &b, uint2 &c, uint2 &d)
{

	a += b; d = eorswap32 (a, d);
	c += d; b ^= c; b = ROR24(b);
	a += b; d ^= a; d = ROR16(d);
	c += d; b ^= c; b = ROR2(b, 63);

}

__device__ __forceinline__ void round_lyra_v35(vectype* s)
{

	Gfunc_v35(s[0].x, s[1].x, s[2].x, s[3].x);
	Gfunc_v35(s[0].y, s[1].y, s[2].y, s[3].y);
	Gfunc_v35(s[0].z, s[1].z, s[2].z, s[3].z);
	Gfunc_v35(s[0].w, s[1].w, s[2].w, s[3].w);

	Gfunc_v35(s[0].x, s[1].y, s[2].z, s[3].w);
	Gfunc_v35(s[0].y, s[1].z, s[2].w, s[3].x);
	Gfunc_v35(s[0].z, s[1].w, s[2].x, s[3].y);
	Gfunc_v35(s[0].w, s[1].x, s[2].y, s[3].z);

}


 

__device__ __forceinline__ void reduceDuplex50(vectype state[4], uint32_t thread)
{
	const uint32_t ps1 = (Nrow * Ncol * memshift * thread);
	const uint32_t ps2 = (memshift * (Ncol - 1) + memshift * Ncol + Nrow * Ncol * memshift * thread);
	uint28 tmp[3];

//#pragma unroll 4
	for (int i = 0; i < Ncol; i++)
	{
#if __CUDA_ARCH__ == 500

		const uint32_t s1 = ps1 + i*memshift;
		const uint32_t s2 = ps2 - i*memshift;

#pragma unroll
		for (int j = 0; j < 3; j++)
			state[j] ^= __ldg4(&(DMatrix + s1)[j]);

		round_lyra_v35(state);

#pragma unroll
		for (int j = 0; j < 3; j++)
			(DMatrix + s2)[j] = __ldg4(&(DMatrix + s1)[j]) ^ state[j];
#else
		const uint32_t s1 = ps1 + i*memshift;
		const uint32_t s2 = ps2 - i*memshift;
		tmp[0] = __ldg4(&(DMatrix + s1)[0]);
		tmp[1] = __ldg4(&(DMatrix + s1)[1]);
		tmp[2] = __ldg4(&(DMatrix + s1)[2]);
		state[0] ^= tmp[0];
		state[1] ^= tmp[1];
		state[2] ^= tmp[2];

		round_lyra_v35(state);

#pragma unroll
		for (int j = 0; j < 3; j++)
			(DMatrix + s2)[j] = tmp[j] ^ state[j];
#endif

	}
}
__device__  void reduceDuplexRowSetupV2(const int rowIn, const int rowInOut, const int rowOut, vectype state[4], uint32_t thread)
{

	int i, j;
		vectype state2[3],state1[3];

		const uint32_t ps1 = (memshift * Ncol * rowIn + Nrow * Ncol * memshift * thread);
		const uint32_t ps2 = (memshift * Ncol * rowInOut + Nrow * Ncol * memshift * thread);
		const uint32_t ps3 = (memshift * (Ncol-1) + memshift * Ncol * rowOut + Nrow * Ncol * memshift * thread);
	for (i = 0; i < Ncol; i++)
	{
		const uint32_t s1 = ps1 + i*memshift;
		const uint32_t s2 = ps2 + i*memshift;
		const uint32_t s3 = ps3 - i*memshift;

		#if __CUDA_ARCH__ == 500
		#pragma unroll
		for (j = 0; j < 3; j++)
		{
			state[j] = state[j] ^ (__ldg4(&(DMatrix + s1)[j]) + __ldg4(&(DMatrix + s2)[j]));
		}
		
		round_lyra_v35(state);
#pragma unroll
		for (j = 0; j < 3; j++)
			state1[j] = __ldg4(&(DMatrix + s1)[j]);

#pragma unroll
		for (j = 0; j < 3; j++)
			state2[j] = __ldg4(&(DMatrix + s2)[j]);

#pragma unroll
		for (j = 0; j < 3; j++) 
		{
			(DMatrix + s3)[j] =state[j]^state1[j];
		}
		#else

#pragma unroll
		for (j = 0; j < 3; j++)
			state1[j] = __ldg4(&(DMatrix + s1)[j]);
#pragma unroll
		for (j = 0; j < 3; j++)
			state2[j] = __ldg4(&(DMatrix + s2)[j]);
#pragma unroll
		for (j = 0; j < 3; j++)
		{
			state[j] ^= state1[j] + state2[j];
		}

		round_lyra_v35(state);

#pragma unroll
		for (j = 0; j < 3; j++)
		{			
			(DMatrix + s3)[j] = state1[j]^ state[j];;
		}

		#endif

		   ((uint2*)state2)[0] ^= ((uint2*)state)[11];
		   #pragma unroll
		   for (j = 0; j < 11; j++)
			((uint2*)state2)[j+1] ^= ((uint2*)state)[j];


		#pragma unroll
		for (j = 0; j < 3; j++)
		    (DMatrix + s2)[j] = state2[j];
	}
}



__device__ void reduceDuplexRowtV2(const int rowIn, const int rowInOut, const int rowOut, vectype* state, uint32_t thread)
{
	int i,j;
		vectype state2[3];
		const uint32_t ps1 = (memshift * Ncol * rowIn + Nrow * Ncol * memshift * thread);
		const uint32_t ps2 = (memshift * Ncol * rowInOut + Nrow * Ncol * memshift * thread);
		const uint32_t ps3 = (memshift * Ncol * rowOut + Nrow * Ncol * memshift * thread);
	
	for (i = 0; i < Ncol; i++)
>>>>>>> 8c320ca... added xevan
	{
		const uint32_t s1 = ps1 + i*memshift;
		const uint32_t s2 = ps2 + i*memshift;
		const uint32_t s3 = ps3 + i*memshift;

<<<<<<< HEAD
		#pragma unroll
		for (int j = 0; j < 3; j++)
			state1[j] = LD4S(s1 + j);

		#pragma unroll
		for (int j = 0; j < 3; j++)
			state2[j] = LD4S(s2 + j);

		#pragma unroll
		for (int j = 0; j < 3; j++)
			state[j] ^= state1[j] + state2[j];

		round_lyra_v5(state);

		uint2 Data0 = shuffle2(state[0], threadIdx.x - 1, 4);
		uint2 Data1 = shuffle2(state[1], threadIdx.x - 1, 4);
		uint2 Data2 = shuffle2(state[2], threadIdx.x - 1, 4);

		if (threadIdx.x == 0) {
			state2[0] ^= Data2;
			state2[1] ^= Data0;
			state2[2] ^= Data1;
		} else {
			state2[0] ^= Data0;
			state2[1] ^= Data1;
			state2[2] ^= Data2;
		}

		#pragma unroll
		for (int j = 0; j < 3; j++)
			ST4S(s2 + j, state2[j]);

		#pragma unroll
		for (int j = 0; j < 3; j++)
			ST4S(s3 + j, LD4S(s3 + j) ^ state[j]);
	}
}

__device__
void reduceDuplexRowt2x4(const int rowInOut, uint2 state[4])
{
	const int rowIn = 2;
	const int rowOut = 3;

	int i, j;
	uint2 last[3];
	const uint32_t ps1 = memshift * Ncol * rowIn;
	const uint32_t ps2 = memshift * Ncol * rowInOut;

	#pragma unroll
	for (int j = 0; j < 3; j++)
		last[j] = LD4S(ps2 + j);

	#pragma unroll
	for (int j = 0; j < 3; j++)
		state[j] ^= LD4S(ps1 + j) + last[j];

	round_lyra_v5(state);

	uint2 Data0 = shuffle2(state[0], threadIdx.x - 1, 4);
	uint2 Data1 = shuffle2(state[1], threadIdx.x - 1, 4);
	uint2 Data2 = shuffle2(state[2], threadIdx.x - 1, 4);

	if (threadIdx.x == 0) {
		last[0] ^= Data2;
		last[1] ^= Data0;
		last[2] ^= Data1;
	} else {
		last[0] ^= Data0;
		last[1] ^= Data1;
		last[2] ^= Data2;
	}

	if (rowInOut == rowOut)
	{
		#pragma unroll
		for (j = 0; j < 3; j++)
			last[j] ^= state[j];
	}

	for (i = 1; i < Ncol; i++)
	{
		const uint32_t s1 = ps1 + i*memshift;
		const uint32_t s2 = ps2 + i*memshift;

		#pragma unroll
		for (j = 0; j < 3; j++)
			state[j] ^= LD4S(s1 + j) + LD4S(s2 + j);

		round_lyra_v5(state);
	}

	#pragma unroll
	for (int j = 0; j < 3; j++)
		state[j] ^= last[j];
}

__global__
__launch_bounds__(TPB, 1)
void lyra2v2_gpu_hash_32_1(uint32_t threads, uint2 *inputHash)
{
	const uint32_t thread = blockDim.x * blockIdx.x + threadIdx.x;

	const uint2x4 blake2b_IV[2] = {
		0xf3bcc908UL, 0x6a09e667UL, 0x84caa73bUL, 0xbb67ae85UL,
		0xfe94f82bUL, 0x3c6ef372UL, 0x5f1d36f1UL, 0xa54ff53aUL,
		0xade682d1UL, 0x510e527fUL, 0x2b3e6c1fUL, 0x9b05688cUL,
		0xfb41bd6bUL, 0x1f83d9abUL, 0x137e2179UL, 0x5be0cd19UL
	};

	const uint2x4 Mask[2] = {
		0x00000020UL, 0x00000000UL, 0x00000020UL, 0x00000000UL,
		0x00000020UL, 0x00000000UL, 0x00000001UL, 0x00000000UL,
		0x00000004UL, 0x00000000UL, 0x00000004UL, 0x00000000UL,
		0x00000080UL, 0x00000000UL, 0x00000000UL, 0x01000000UL
	};

	uint2x4 state[4];

	if (thread < threads)
	{
		state[0].x = state[1].x = __ldg(&inputHash[thread + threads * 0]);
		state[0].y = state[1].y = __ldg(&inputHash[thread + threads * 1]);
		state[0].z = state[1].z = __ldg(&inputHash[thread + threads * 2]);
		state[0].w = state[1].w = __ldg(&inputHash[thread + threads * 3]);
		state[2] = blake2b_IV[0];
		state[3] = blake2b_IV[1];

		for (int i = 0; i<12; i++)
			round_lyra_v5(state);

		state[0] ^= Mask[0];
		state[1] ^= Mask[1];

		for (int i = 0; i<12; i++)
			round_lyra_v5(state);

		DMatrix[blockDim.x * gridDim.x * 0 + thread] = state[0];
		DMatrix[blockDim.x * gridDim.x * 1 + thread] = state[1];
		DMatrix[blockDim.x * gridDim.x * 2 + thread] = state[2];
		DMatrix[blockDim.x * gridDim.x * 3 + thread] = state[3];
	}
}

__global__
__launch_bounds__(TPB, 1)
void lyra2v2_gpu_hash_32_2(uint32_t threads)
{
	const uint32_t thread = blockDim.y * blockIdx.x + threadIdx.y;

	if (thread < threads)
	{
		uint2 state[4];
		state[0] = ((uint2*)DMatrix)[(0 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x];
		state[1] = ((uint2*)DMatrix)[(1 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x];
		state[2] = ((uint2*)DMatrix)[(2 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x];
		state[3] = ((uint2*)DMatrix)[(3 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x];

		reduceDuplexRowSetup2(state);

		uint32_t rowa;
		int prev = 3;

		for (int i = 0; i < 3; i++)
		{
			rowa = __shfl(state[0].x, 0, 4) & 3;
			reduceDuplexRowt2(prev, rowa, i, state);
			prev = i;
		}

		rowa = __shfl(state[0].x, 0, 4) & 3;
		reduceDuplexRowt2x4(rowa, state);

		((uint2*)DMatrix)[(0 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x] = state[0];
		((uint2*)DMatrix)[(1 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x] = state[1];
		((uint2*)DMatrix)[(2 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x] = state[2];
		((uint2*)DMatrix)[(3 * gridDim.x * blockDim.y + thread) * blockDim.x + threadIdx.x] = state[3];
	}
}

__global__
__launch_bounds__(TPB, 1)
void lyra2v2_gpu_hash_32_3(uint32_t threads, uint2 *outputHash)
{
	const uint32_t thread = blockDim.x * blockIdx.x + threadIdx.x;

	uint2x4 state[4];

	if (thread < threads)
	{
		state[0] = __ldg4(&DMatrix[blockDim.x * gridDim.x * 0 + thread]);
		state[1] = __ldg4(&DMatrix[blockDim.x * gridDim.x * 1 + thread]);
		state[2] = __ldg4(&DMatrix[blockDim.x * gridDim.x * 2 + thread]);
		state[3] = __ldg4(&DMatrix[blockDim.x * gridDim.x * 3 + thread]);

		for (int i = 0; i < 12; i++)
			round_lyra_v5(state);

		outputHash[thread + threads * 0] = state[0].x;
		outputHash[thread + threads * 1] = state[0].y;
		outputHash[thread + threads * 2] = state[0].z;
		outputHash[thread + threads * 3] = state[0].w;
	}
}

#else
#include "cuda_helper.h"
#if __CUDA_ARCH__ < 200
__device__ void* DMatrix;
#endif
__global__ void lyra2v2_gpu_hash_32_1(uint32_t threads, uint2 *inputHash) {}
__global__ void lyra2v2_gpu_hash_32_2(uint32_t threads) {}
__global__ void lyra2v2_gpu_hash_32_3(uint32_t threads, uint2 *outputHash) {}
#endif


__host__
void lyra2v2_cpu_init(int thr_id, uint32_t threads, uint64_t *d_matrix)
{
	cuda_get_arch(thr_id);
	// just assign the device pointer allocated in main loop
	cudaMemcpyToSymbol(DMatrix, &d_matrix, sizeof(uint64_t*), 0, cudaMemcpyHostToDevice);
}

__host__
void lyra2v2_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *g_hash, int order)
{
	int dev_id = device_map[thr_id % MAX_GPUS];

	if (device_sm[dev_id] >= 500) {

		const uint32_t tpb = TPB;

		dim3 grid2((threads + tpb - 1) / tpb);
		dim3 block2(tpb);
		dim3 grid4((threads * 4 + tpb - 1) / tpb);
		dim3 block4(4, tpb / 4);

		lyra2v2_gpu_hash_32_1 <<< grid2, block2 >>> (threads, (uint2*)g_hash);
		lyra2v2_gpu_hash_32_2 <<< grid4, block4, 48 * sizeof(uint2) * tpb >>> (threads);
		lyra2v2_gpu_hash_32_3 <<< grid2, block2 >>> (threads, (uint2*)g_hash);

	} else {

		uint32_t tpb = 16;
		if (cuda_arch[dev_id] >= 350) tpb = TPB35;
		else if (cuda_arch[dev_id] >= 300) tpb = TPB30;
		else if (cuda_arch[dev_id] >= 200) tpb = TPB20;

		dim3 grid((threads + tpb - 1) / tpb);
		dim3 block(tpb);
		lyra2v2_gpu_hash_32_v3 <<< grid, block >>> (threads, startNounce, (uint2*)g_hash);

	}
}
=======
		#pragma unroll 
		for (j = 0; j < 3; j++)
			state2[j] = __ldg4(&(DMatrix + s2)[j]);

		#pragma unroll 
		for (j = 0; j < 3; j++)
			state[j] ^= __ldg4(&(DMatrix + s1)[j]) + state2[j];

		round_lyra_v35(state);

		((uint2*)state2)[0] ^= ((uint2*)state)[11];
		#pragma unroll 
		for (j = 0; j < 11; j++)
		((uint2*)state2)[j + 1] ^= ((uint2*)state)[j];
#if __CUDA_ARCH__ == 500
		if (rowInOut != rowOut) 
		{
			#pragma unroll 
			for ( j = 0; j < 3; j++)
				(DMatrix + s3)[j] ^= state[j];

		} 
		if (rowInOut == rowOut)
		{
			#pragma unroll 
			for (j = 0; j < 3; j++)
			state2[j] ^= state[j];
		}
#else
		if (rowInOut != rowOut)
		{
			#pragma unroll 
			for (j = 0; j < 3; j++)
				(DMatrix + s3)[j] ^= state[j];

		} else
		{
			#pragma unroll 
			for (j = 0; j < 3; j++)
				state2[j] ^= state[j];
		}
#endif

		#pragma unroll 
		for (j = 0; j < 3; j++)
			(DMatrix + s2)[j] = state2[j];
	}
}

__global__
#if __CUDA_ARCH__ > 500
__launch_bounds__(128, 1)
#endif
void lyra2v2_gpu_hash_32(uint32_t threads, uint32_t startNounce, uint2 *outputHash)
{
	const uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);



	vectype state[4];

	if (thread < threads)
	{
		const uint28 blake2b_IV[2] =
		{
			0xf3bcc908, 0x6a09e667,
			0x84caa73b, 0xbb67ae85,
			0xfe94f82b, 0x3c6ef372,
			0x5f1d36f1, 0xa54ff53a,
			0xade682d1, 0x510e527f,
			0x2b3e6c1f, 0x9b05688c,
			0xfb41bd6b, 0x1f83d9ab,
			0x137e2179, 0x5be0cd19
		};

		state[2] = ((blake2b_IV)[0]);
		state[3] = ((blake2b_IV)[1]);

		((uint2*)state)[0] = __ldg(&outputHash[thread]);
		((uint2*)state)[1] = __ldg(&outputHash[thread + threads]);
		((uint2*)state)[2] = __ldg(&outputHash[thread + 2 * threads]);
		((uint2*)state)[3] = __ldg(&outputHash[thread + 3 * threads]);

		 state[1] = state[0];

		 for (int i = 0; i<12; i++)
			 round_lyra_v35(state);
		 ((uint2*)state)[0].x ^= 0x20;
		 ((uint2*)state)[1].x ^= 0x20;
		 ((uint2*)state)[2].x ^= 0x20;
		 ((uint2*)state)[3].x ^= 0x01;
		 ((uint2*)state)[4].x ^= 0x04;
		 ((uint2*)state)[5].x ^= 0x04;
		 ((uint2*)state)[6].x ^= 0x80;
		 ((uint2*)state)[7].y ^= 0x01000000;

		 for (int i = 0; i<12; i++)
			 round_lyra_v35(state);

		const uint32_t ps1 = (memshift * (Ncol - 1) + Nrow * Ncol * memshift * thread);

#if __CUDA_ARCH__ > 500
#pragma unroll
#endif
		for (int i = 0; i < Ncol; i++)
		{
			const uint32_t s1 = ps1 - memshift * i;
			DMatrix[s1] = state[0];
			DMatrix[s1+1] = state[1];
			DMatrix[s1+2] = state[2];
			round_lyra_v35(state);
		}

		reduceDuplex50(state, thread);

		reduceDuplexRowSetupV2(1, 0, 2, state,  thread);
		reduceDuplexRowSetupV2(2, 1, 3, state,  thread);

		uint32_t rowa;
		int prev=3;

        for (int i = 0; i < 4; i++)
        {
	     rowa = ((uint2*)state)[0].x & 3;  
		 reduceDuplexRowtV2(prev, rowa, i, state, thread);
         prev=i;
        }


		const uint32_t shift = (memshift * Ncol * rowa + Nrow * Ncol * memshift * thread);

		#pragma unroll
		for (int j = 0; j < 3; j++)
			state[j] ^= __ldg4(&(DMatrix + shift)[j]);

		for (int i = 0; i < 12; i++)
        	round_lyra_v35(state);
		
		outputHash[thread] = ((uint2*)state)[0];
		outputHash[thread + threads] = ((uint2*)state)[1];
		outputHash[thread + 2 * threads] = ((uint2*)state)[2];
		outputHash[thread + 3 * threads] = ((uint2*)state)[3];
//		((vectype*)outputHash)[thread] = state[0];

	} //thread
}


__host__
void lyra2v2_cpu_init(int thr_id, uint32_t threads,uint64_t *hash)
{
	cudaMemcpyToSymbol(DMatrix, &hash, sizeof(hash), 0, cudaMemcpyHostToDevice);
}



__host__ 
void lyra2v2_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *d_outputHash, uint32_t tpb)
{
	dim3 grid((threads + tpb - 1) / tpb);
	dim3 block(tpb);

	lyra2v2_gpu_hash_32 << <grid, block >> > (threads, startNounce, (uint2*)d_outputHash);
}

  
>>>>>>> 8c320ca... added xevan
