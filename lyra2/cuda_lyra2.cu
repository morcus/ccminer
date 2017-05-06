<<<<<<< HEAD
/**
 * Lyra2 (v1) cuda implementation based on djm34 work
 * tpruvot@github 2015, Nanashi 08/2016 (from 1.8-r2)
 */

#include <stdio.h>
#include <memory.h>

#define TPB52 32

#include "cuda_lyra2_sm2.cuh"
#include "cuda_lyra2_sm5.cuh"

#ifdef __INTELLISENSE__
/* just for vstudio code colors */
#define __CUDA_ARCH__ 520
#endif

#if !defined(__CUDA_ARCH__) ||  __CUDA_ARCH__ > 500

#include "cuda_lyra2_vectors.h"

#ifdef __INTELLISENSE__
/* just for vstudio code colors */
__device__ uint32_t __shfl(uint32_t a, uint32_t b, uint32_t c);
#endif

#define Nrow 8
#define Ncol 8
#define memshift 3

#define BUF_COUNT 0

__device__ uint2 *DMatrix;

__device__ __forceinline__ void LD4S(uint2 res[3], const int row, const int col, const int thread, const int threads)
{
#if BUF_COUNT != 8
	extern __shared__ uint2 shared_mem[];
	const int s0 = (Ncol * (row - BUF_COUNT) + col) * memshift;
#endif
#if BUF_COUNT != 0
	const int d0 = (memshift *(Ncol * row + col) * threads + thread)*blockDim.x + threadIdx.x;
#endif

#if BUF_COUNT == 8
	#pragma unroll
	for (int j = 0; j < 3; j++)
		res[j] = *(DMatrix + d0 + j * threads * blockDim.x);
#elif BUF_COUNT == 0
	#pragma unroll
	for (int j = 0; j < 3; j++)
		res[j] = shared_mem[((s0 + j) * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x];
#else
	if (row < BUF_COUNT)
	{
		#pragma unroll
		for (int j = 0; j < 3; j++)
			res[j] = *(DMatrix + d0 + j * threads * blockDim.x);
	}
	else
	{
	#pragma unroll
		for (int j = 0; j < 3; j++)
			res[j] = shared_mem[((s0 + j) * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x];
	}
#endif
}

__device__ __forceinline__ void ST4S(const int row, const int col, const uint2 data[3], const int thread, const int threads)
{
#if BUF_COUNT != 8
	extern __shared__ uint2 shared_mem[];
	const int s0 = (Ncol * (row - BUF_COUNT) + col) * memshift;
#endif
#if BUF_COUNT != 0
	const int d0 = (memshift *(Ncol * row + col) * threads + thread)*blockDim.x + threadIdx.x;
#endif

#if BUF_COUNT == 8
	#pragma unroll
	for (int j = 0; j < 3; j++)
		*(DMatrix + d0 + j * threads * blockDim.x) = data[j];

#elif BUF_COUNT == 0
	#pragma unroll
	for (int j = 0; j < 3; j++)
		shared_mem[((s0 + j) * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x] = data[j];

#else
	if (row < BUF_COUNT)
	{
	#pragma unroll
		for (int j = 0; j < 3; j++)
			*(DMatrix + d0 + j * threads * blockDim.x) = data[j];
	}
	else
	{
	#pragma unroll
		for (int j = 0; j < 3; j++)
			shared_mem[((s0 + j) * blockDim.y + threadIdx.y) * blockDim.x + threadIdx.x] = data[j];
	}
#endif
}

#if __CUDA_ARCH__ >= 300
__device__ __forceinline__ uint32_t WarpShuffle(uint32_t a, uint32_t b, uint32_t c)
{
	return __shfl(a, b, c);
}

__device__ __forceinline__ uint2 WarpShuffle(uint2 a, uint32_t b, uint32_t c)
{
	return make_uint2(__shfl(a.x, b, c), __shfl(a.y, b, c));
}

__device__ __forceinline__ void WarpShuffle3(uint2 &a1, uint2 &a2, uint2 &a3, uint32_t b1, uint32_t b2, uint32_t b3, uint32_t c)
{
	a1 = WarpShuffle(a1, b1, c);
	a2 = WarpShuffle(a2, b2, c);
	a3 = WarpShuffle(a3, b3, c);
}

#else
__device__ __forceinline__ uint32_t WarpShuffle(uint32_t a, uint32_t b, uint32_t c)
{
	extern __shared__ uint2 shared_mem[];

	const uint32_t thread = blockDim.x * threadIdx.y + threadIdx.x;
	uint32_t *_ptr = (uint32_t*)shared_mem;

	__threadfence_block();
	uint32_t buf = _ptr[thread];

	_ptr[thread] = a;
	__threadfence_block();
	uint32_t result = _ptr[(thread&~(c - 1)) + (b&(c - 1))];

	__threadfence_block();
	_ptr[thread] = buf;

	__threadfence_block();
	return result;
}

__device__ __forceinline__ uint2 WarpShuffle(uint2 a, uint32_t b, uint32_t c)
{
	extern __shared__ uint2 shared_mem[];

	const uint32_t thread = blockDim.x * threadIdx.y + threadIdx.x;

	__threadfence_block();
	uint2 buf = shared_mem[thread];

	shared_mem[thread] = a;
	__threadfence_block();
	uint2 result = shared_mem[(thread&~(c - 1)) + (b&(c - 1))];

	__threadfence_block();
	shared_mem[thread] = buf;

	__threadfence_block();
	return result;
}

__device__ __forceinline__ void WarpShuffle3(uint2 &a1, uint2 &a2, uint2 &a3, uint32_t b1, uint32_t b2, uint32_t b3, uint32_t c)
{
	extern __shared__ uint2 shared_mem[];

	const uint32_t thread = blockDim.x * threadIdx.y + threadIdx.x;

	__threadfence_block();
	uint2 buf = shared_mem[thread];

	shared_mem[thread] = a1;
	__threadfence_block();
	a1 = shared_mem[(thread&~(c - 1)) + (b1&(c - 1))];
	__threadfence_block();
	shared_mem[thread] = a2;
	__threadfence_block();
	a2 = shared_mem[(thread&~(c - 1)) + (b2&(c - 1))];
	__threadfence_block();
	shared_mem[thread] = a3;
	__threadfence_block();
	a3 = shared_mem[(thread&~(c - 1)) + (b3&(c - 1))];

	__threadfence_block();
	shared_mem[thread] = buf;
	__threadfence_block();
}

#endif

#if __CUDA_ARCH__ > 500 || !defined(__CUDA_ARCH)
static __device__ __forceinline__
void Gfunc(uint2 &a, uint2 &b, uint2 &c, uint2 &d)
{
	a += b; uint2 tmp = d; d.y = a.x ^ tmp.x; d.x = a.y ^ tmp.y;
	c += d; b ^= c; b = ROR24(b);
	a += b; d ^= a; d = ROR16(d);
	c += d; b ^= c; b = ROR2(b, 63);
}
#endif

__device__ __forceinline__ void round_lyra(uint2 s[4])
{
	Gfunc(s[0], s[1], s[2], s[3]);
	WarpShuffle3(s[1], s[2], s[3], threadIdx.x + 1, threadIdx.x + 2, threadIdx.x + 3, 4);
	Gfunc(s[0], s[1], s[2], s[3]);
	WarpShuffle3(s[1], s[2], s[3], threadIdx.x + 3, threadIdx.x + 2, threadIdx.x + 1, 4);
}

static __device__ __forceinline__
void round_lyra(uint2x4* s)
{
	Gfunc(s[0].x, s[1].x, s[2].x, s[3].x);
	Gfunc(s[0].y, s[1].y, s[2].y, s[3].y);
	Gfunc(s[0].z, s[1].z, s[2].z, s[3].z);
	Gfunc(s[0].w, s[1].w, s[2].w, s[3].w);
	Gfunc(s[0].x, s[1].y, s[2].z, s[3].w);
	Gfunc(s[0].y, s[1].z, s[2].w, s[3].x);
	Gfunc(s[0].z, s[1].w, s[2].x, s[3].y);
	Gfunc(s[0].w, s[1].x, s[2].y, s[3].z);
}

static __device__ __forceinline__
void reduceDuplex(uint2 state[4], uint32_t thread, const uint32_t threads)
{
	uint2 state1[3];

#if __CUDA_ARCH__ > 500
#pragma unroll
#endif
	for (int i = 0; i < Nrow; i++)
	{
		ST4S(0, Ncol - i - 1, state, thread, threads);

		round_lyra(state);
	}

	#pragma unroll 4
	for (int i = 0; i < Nrow; i++)
	{
		LD4S(state1, 0, i, thread, threads);
		for (int j = 0; j < 3; j++)
			state[j] ^= state1[j];

		round_lyra(state);

		for (int j = 0; j < 3; j++)
			state1[j] ^= state[j];
		ST4S(1, Ncol - i - 1, state1, thread, threads);
	}
}

static __device__ __forceinline__
void reduceDuplexRowSetup(const int rowIn, const int rowInOut, const int rowOut, uint2 state[4], uint32_t thread, const uint32_t threads)
{
	uint2 state1[3], state2[3];

	#pragma unroll 1
	for (int i = 0; i < Nrow; i++)
	{
		LD4S(state1, rowIn, i, thread, threads);
		LD4S(state2, rowInOut, i, thread, threads);
		for (int j = 0; j < 3; j++)
			state[j] ^= state1[j] + state2[j];

		round_lyra(state);

		#pragma unroll
		for (int j = 0; j < 3; j++)
			state1[j] ^= state[j];

		ST4S(rowOut, Ncol - i - 1, state1, thread, threads);

		//一個手前のスレッドからデータを貰う(同時に一個先のスレッドにデータを送る)
		uint2 Data0 = state[0];
		uint2 Data1 = state[1];
		uint2 Data2 = state[2];
		WarpShuffle3(Data0, Data1, Data2, threadIdx.x - 1, threadIdx.x - 1, threadIdx.x - 1, 4);

		if (threadIdx.x == 0)
		{
			state2[0] ^= Data2;
			state2[1] ^= Data0;
			state2[2] ^= Data1;
		} else {
			state2[0] ^= Data0;
			state2[1] ^= Data1;
			state2[2] ^= Data2;
		}

		ST4S(rowInOut, i, state2, thread, threads);
	}
}

static __device__ __forceinline__
void reduceDuplexRowt(const int rowIn, const int rowInOut, const int rowOut, uint2 state[4], const uint32_t thread, const uint32_t threads)
{
	for (int i = 0; i < Nrow; i++)
	{
		uint2 state1[3], state2[3];

		LD4S(state1, rowIn, i, thread, threads);
		LD4S(state2, rowInOut, i, thread, threads);

#pragma unroll
		for (int j = 0; j < 3; j++)
			state[j] ^= state1[j] + state2[j];

		round_lyra(state);

		//一個手前のスレッドからデータを貰う(同時に一個先のスレッドにデータを送る)
		uint2 Data0 = state[0];
		uint2 Data1 = state[1];
		uint2 Data2 = state[2];
		WarpShuffle3(Data0, Data1, Data2, threadIdx.x - 1, threadIdx.x - 1, threadIdx.x - 1, 4);

		if (threadIdx.x == 0)
		{
			state2[0] ^= Data2;
			state2[1] ^= Data0;
			state2[2] ^= Data1;
		}
		else
		{
			state2[0] ^= Data0;
			state2[1] ^= Data1;
			state2[2] ^= Data2;
		}

		ST4S(rowInOut, i, state2, thread, threads);

		LD4S(state1, rowOut, i, thread, threads);

#pragma unroll
		for (int j = 0; j < 3; j++)
			state1[j] ^= state[j];

		ST4S(rowOut, i, state1, thread, threads);
	}
}

static __device__ __forceinline__
void reduceDuplexRowt_8(const int rowInOut, uint2* state, const uint32_t thread, const uint32_t threads)
{
	uint2 state1[3], state2[3], last[3];

	LD4S(state1, 2, 0, thread, threads);
	LD4S(last, rowInOut, 0, thread, threads);

	#pragma unroll
	for (int j = 0; j < 3; j++)
		state[j] ^= state1[j] + last[j];

	round_lyra(state);

	//一個手前のスレッドからデータを貰う(同時に一個先のスレッドにデータを送る)
	uint2 Data0 = state[0];
	uint2 Data1 = state[1];
	uint2 Data2 = state[2];
	WarpShuffle3(Data0, Data1, Data2, threadIdx.x - 1, threadIdx.x - 1, threadIdx.x - 1, 4);

	if (threadIdx.x == 0)
	{
		last[0] ^= Data2;
		last[1] ^= Data0;
		last[2] ^= Data1;
	} else {
		last[0] ^= Data0;
		last[1] ^= Data1;
		last[2] ^= Data2;
	}

	if (rowInOut == 5)
	{
		#pragma unroll
		for (int j = 0; j < 3; j++)
			last[j] ^= state[j];
	}

	for (int i = 1; i < Nrow; i++)
	{
		LD4S(state1, 2, i, thread, threads);
		LD4S(state2, rowInOut, i, thread, threads);

		#pragma unroll
		for (int j = 0; j < 3; j++)
			state[j] ^= state1[j] + state2[j];

		round_lyra(state);
	}

	#pragma unroll
	for (int j = 0; j < 3; j++)
		state[j] ^= last[j];
}

__constant__ uint2x4 blake2b_IV[2] = {
	0xf3bcc908lu, 0x6a09e667lu,
	0x84caa73blu, 0xbb67ae85lu,
	0xfe94f82blu, 0x3c6ef372lu,
	0x5f1d36f1lu, 0xa54ff53alu,
	0xade682d1lu, 0x510e527flu,
	0x2b3e6c1flu, 0x9b05688clu,
	0xfb41bd6blu, 0x1f83d9ablu,
	0x137e2179lu, 0x5be0cd19lu
};

__global__ __launch_bounds__(64, 1)
void lyra2_gpu_hash_32_1(uint32_t threads, uint32_t startNounce, uint2 *g_hash)
{
	const uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);

	if (thread < threads)
	{
		uint2x4 state[4];

		state[0].x = state[1].x = __ldg(&g_hash[thread + threads * 0]);
		state[0].y = state[1].y = __ldg(&g_hash[thread + threads * 1]);
		state[0].z = state[1].z = __ldg(&g_hash[thread + threads * 2]);
		state[0].w = state[1].w = __ldg(&g_hash[thread + threads * 3]);
		state[2] = blake2b_IV[0];
		state[3] = blake2b_IV[1];

		for (int i = 0; i<24; i++)
			round_lyra(state); //because 12 is not enough

		((uint2x4*)DMatrix)[threads * 0 + thread] = state[0];
		((uint2x4*)DMatrix)[threads * 1 + thread] = state[1];
		((uint2x4*)DMatrix)[threads * 2 + thread] = state[2];
		((uint2x4*)DMatrix)[threads * 3 + thread] = state[3];
	}
}

__global__
__launch_bounds__(TPB52, 1)
void lyra2_gpu_hash_32_2(uint32_t threads, uint32_t startNounce, uint64_t *g_hash)
{
	const uint32_t thread = blockDim.y * blockIdx.x + threadIdx.y;

	if (thread < threads)
	{
		uint2 state[4];
		state[0] = __ldg(&DMatrix[(0 * threads + thread) * blockDim.x + threadIdx.x]);
		state[1] = __ldg(&DMatrix[(1 * threads + thread) * blockDim.x + threadIdx.x]);
		state[2] = __ldg(&DMatrix[(2 * threads + thread) * blockDim.x + threadIdx.x]);
		state[3] = __ldg(&DMatrix[(3 * threads + thread) * blockDim.x + threadIdx.x]);

		reduceDuplex(state, thread, threads);
		reduceDuplexRowSetup(1, 0, 2, state, thread, threads);
		reduceDuplexRowSetup(2, 1, 3, state, thread, threads);
		reduceDuplexRowSetup(3, 0, 4, state, thread, threads);
		reduceDuplexRowSetup(4, 3, 5, state, thread, threads);
		reduceDuplexRowSetup(5, 2, 6, state, thread, threads);
		reduceDuplexRowSetup(6, 1, 7, state, thread, threads);

		uint32_t rowa = WarpShuffle(state[0].x, 0, 4) & 7;
		reduceDuplexRowt(7, rowa, 0, state, thread, threads);
		rowa = WarpShuffle(state[0].x, 0, 4) & 7;
		reduceDuplexRowt(0, rowa, 3, state, thread, threads);
		rowa = WarpShuffle(state[0].x, 0, 4) & 7;
		reduceDuplexRowt(3, rowa, 6, state, thread, threads);
		rowa = WarpShuffle(state[0].x, 0, 4) & 7;
		reduceDuplexRowt(6, rowa, 1, state, thread, threads);
		rowa = WarpShuffle(state[0].x, 0, 4) & 7;
		reduceDuplexRowt(1, rowa, 4, state, thread, threads);
		rowa = WarpShuffle(state[0].x, 0, 4) & 7;
		reduceDuplexRowt(4, rowa, 7, state, thread, threads);
		rowa = WarpShuffle(state[0].x, 0, 4) & 7;
		reduceDuplexRowt(7, rowa, 2, state, thread, threads);
		rowa = WarpShuffle(state[0].x, 0, 4) & 7;
		reduceDuplexRowt_8(rowa, state, thread, threads);

		DMatrix[(0 * threads + thread) * blockDim.x + threadIdx.x] = state[0];
		DMatrix[(1 * threads + thread) * blockDim.x + threadIdx.x] = state[1];
		DMatrix[(2 * threads + thread) * blockDim.x + threadIdx.x] = state[2];
		DMatrix[(3 * threads + thread) * blockDim.x + threadIdx.x] = state[3];
	}
}

__global__ __launch_bounds__(64, 1)
void lyra2_gpu_hash_32_3(uint32_t threads, uint32_t startNounce, uint2 *g_hash)
{
	const uint32_t thread = blockDim.x * blockIdx.x + threadIdx.x;

	uint28 state[4];

	if (thread < threads)
	{
		state[0] = __ldg4(&((uint2x4*)DMatrix)[threads * 0 + thread]);
		state[1] = __ldg4(&((uint2x4*)DMatrix)[threads * 1 + thread]);
		state[2] = __ldg4(&((uint2x4*)DMatrix)[threads * 2 + thread]);
		state[3] = __ldg4(&((uint2x4*)DMatrix)[threads * 3 + thread]);

		for (int i = 0; i < 12; i++)
			round_lyra(state);

		g_hash[thread + threads * 0] = state[0].x;
		g_hash[thread + threads * 1] = state[0].y;
		g_hash[thread + threads * 2] = state[0].z;
		g_hash[thread + threads * 3] = state[0].w;

	} //thread
}
#else
#if __CUDA_ARCH__ < 500

/* for unsupported SM arch */
__device__ void* DMatrix;
#endif
__global__ void lyra2_gpu_hash_32_1(uint32_t threads, uint32_t startNounce, uint2 *g_hash) {}
__global__ void lyra2_gpu_hash_32_2(uint32_t threads, uint32_t startNounce, uint64_t *g_hash) {}
__global__ void lyra2_gpu_hash_32_3(uint32_t threads, uint32_t startNounce, uint2 *g_hash) {}
#endif

__host__
void lyra2_cpu_init(int thr_id, uint32_t threads, uint64_t *d_matrix)
{
	// just assign the device pointer allocated in main loop
	cudaMemcpyToSymbol(DMatrix, &d_matrix, sizeof(uint64_t*), 0, cudaMemcpyHostToDevice);
}

__host__
void lyra2_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *d_hash, bool gtx750ti)
{
	int dev_id = device_map[thr_id % MAX_GPUS];

	uint32_t tpb = TPB52;

	if (cuda_arch[dev_id] >= 520) tpb = TPB52;
	else if (cuda_arch[dev_id] >= 500) tpb = TPB50;
	else if (cuda_arch[dev_id] >= 200) tpb = TPB20;

	dim3 grid1((threads * 4 + tpb - 1) / tpb);
	dim3 block1(4, tpb >> 2);

	dim3 grid2((threads + 64 - 1) / 64);
	dim3 block2(64);

	dim3 grid3((threads + tpb - 1) / tpb);
	dim3 block3(tpb);

	if (cuda_arch[dev_id] >= 520)
	{
		lyra2_gpu_hash_32_1 <<< grid2, block2 >>> (threads, startNounce, (uint2*)d_hash);

		lyra2_gpu_hash_32_2 <<< grid1, block1, 24 * (8 - 0) * sizeof(uint2) * tpb >>> (threads, startNounce, d_hash);

		lyra2_gpu_hash_32_3 <<< grid2, block2 >>> (threads, startNounce, (uint2*)d_hash);
	}
	else if (cuda_arch[dev_id] >= 500)
	{
		size_t shared_mem = 0;

		if (gtx750ti)
			// 8Warpに調整のため、8192バイト確保する
			shared_mem = 8192;
		else
			// 10Warpに調整のため、6144バイト確保する
			shared_mem = 6144;

		lyra2_gpu_hash_32_1_sm5 <<< grid2, block2 >>> (threads, startNounce, (uint2*)d_hash);

		lyra2_gpu_hash_32_2_sm5 <<< grid1, block1, shared_mem >>> (threads, startNounce, (uint2*)d_hash);

		lyra2_gpu_hash_32_3_sm5 <<< grid2, block2 >>> (threads, startNounce, (uint2*)d_hash);
	}
	else
		lyra2_gpu_hash_32_sm2 <<< grid3, block3 >>> (threads, startNounce, d_hash);
}
=======


#include <stdio.h>
#include <memory.h>
#include "cuda_vector.h"
#define TPB 8
//



#if __CUDA_ARCH__ == 500
#define u64type uint2
#define vectype uint28
#define memshift 3
#else 
#define u64type uint2
#define vectype uint28
#define memshift 4   
#endif
__device__ vectype  *DMatrix;

 
static __device__ __forceinline__ void Gfunc_v35(uint2 & a, uint2 &b, uint2 &c, uint2 &d)
{

	a += b; d = eorswap32(a, d);
	c += d; b ^= c; b = ROR24(b);
	a += b; d ^= a; d = ROR16(d);
	c += d; b ^= c; b = ROR2(b, 63);

}

static __device__ __forceinline__ void round_lyra_v35(vectype* s)
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



static __device__ __forceinline__ void reduceDuplex(vectype state[4], uint32_t thread)
{


	    vectype state1[3]; 
		uint32_t ps1 = (256 * thread);
		uint32_t ps2 = (memshift * 7 + memshift * 8 + 256 * thread);

#pragma unroll 4
	for (int i = 0; i < 8; i++)
	{
        uint32_t s1 = ps1 + i*memshift;
        uint32_t s2 = ps2 - i*memshift;  
		
		for (int j = 0; j < 3; j++)
			state1[j] = __ldg4(&(DMatrix+s1)[j]); 
 
		for (int j = 0; j < 3; j++)
			state[j] ^= state1[j];
		round_lyra_v35(state); 
		for (int j = 0; j < 3; j++)
			state1[j] ^= state[j];

		for (int j = 0; j < 3; j++)
			(DMatrix + s2)[j] = state1[j];

	}

}

static __device__ __forceinline__ void reduceDuplexV3(vectype state[4], uint32_t thread)
{


	vectype state1[3];
	uint32_t ps1 = (256 * thread);
//                     colomn             row
	uint32_t ps2 = (memshift * 7 * 8 + memshift * 1 + 64 * memshift * thread);

#pragma unroll 4
	for (int i = 0; i < 8; i++)
	{
		uint32_t s1 = ps1 + 8 * i *memshift;
		uint32_t s2 = ps2 - 8 * i *memshift;

		for (int j = 0; j < 3; j++)
			state1[j] = __ldg4(&(DMatrix + s1)[j]);

		for (int j = 0; j < 3; j++)
			state[j] ^= state1[j];
		round_lyra_v35(state);

		for (int j = 0; j < 3; j++)
			state1[j] ^= state[j];


		for (int j = 0; j < 3; j++)
			(DMatrix + s2)[j] = state1[j];

	}

}

static __device__ __forceinline__ void reduceDuplexRowSetupV2(const int rowIn, const int rowInOut, const int rowOut, vectype state[4], uint32_t thread)
{


		vectype state2[3],state1[3];

		uint32_t ps1 = (              memshift * 8 * rowIn    + 256 * thread);
		uint32_t ps2 = (              memshift * 8 * rowInOut + 256 * thread);
		uint32_t ps3 = (memshift*7  + memshift * 8 * rowOut   + 256 * thread);


#pragma unroll 1
	for (int i = 0; i < 8; i++)
	{
		uint32_t s1 = ps1 + i*memshift;
		uint32_t s2 = ps2 + i*memshift;
		uint32_t s3 = ps3 - i*memshift;

		for (int j = 0; j < 3; j++) 
			state1[j]= __ldg4(&(DMatrix + s1)[j]);
		for (int j = 0; j < 3; j++)
			state2[j]= __ldg4(&(DMatrix + s2)[j]);
		for (int j = 0; j < 3; j++) {
			vectype tmp = state1[j] + state2[j];
			state[j] ^= tmp;
		}
		

		round_lyra_v35(state);

		for (int j = 0; j < 3; j++) {
			state1[j] ^= state[j];
			(DMatrix + s3)[j] = state1[j];
		}
 
		   ((uint2*)state2)[0] ^= ((uint2*)state)[11];
		for (int j = 0; j < 11; j++) 
			((uint2*)state2)[j+1] ^= ((uint2*)state)[j];



		for (int j = 0; j < 3; j++)
		    (DMatrix + s2)[j] = state2[j];
		
	}


}

static __device__ __forceinline__ void reduceDuplexRowSetupV3(const int rowIn, const int rowInOut, const int rowOut, vectype state[4], uint32_t thread)
{


	vectype state2[3], state1[3];
	
	uint32_t ps1 = (                  memshift *  rowIn    + 64 * memshift * thread);
	uint32_t ps2 = (memshift * rowInOut +                    64 * memshift* thread);
	uint32_t ps3 = (8 * memshift * 7 + memshift *  rowOut +  64 * memshift * thread);
	/*
	uint32_t ps1 = (256 * thread);
	uint32_t ps2 = (256 * thread);
	uint32_t ps3 = (256 * thread);
    */
#pragma nounroll 
	for (int i = 0; i < 8; i++)
	{
		uint32_t s1 = ps1 + 8*i*memshift;
		uint32_t s2 = ps2 + 8*i*memshift;
		uint32_t s3 = ps3 - 8*i*memshift;

		for (int j = 0; j < 3; j++)
			state1[j] = __ldg4(&(DMatrix + s1 )[j]);
		for (int j = 0; j < 3; j++)
			state2[j] = __ldg4(&(DMatrix + s2 )[j]);
		for (int j = 0; j < 3; j++) {
			vectype tmp = state1[j] + state2[j];
			state[j] ^= tmp;
		}


		round_lyra_v35(state);

		for (int j = 0; j < 3; j++) {
			state1[j] ^= state[j];
			(DMatrix + s3)[j] = state1[j];
		}

		((uint2*)state2)[0] ^= ((uint2*)state)[11];
		for (int j = 0; j < 11; j++)
			((uint2*)state2)[j + 1] ^= ((uint2*)state)[j];



		for (int j = 0; j < 3; j++)
			(DMatrix + s2)[j] = state2[j];

	}


}


static __device__ __forceinline__ void reduceDuplexRowtV2(const int rowIn, const int rowInOut, const int rowOut, vectype* state, uint32_t thread)
{

		vectype state1[3],state2[3];
		uint32_t ps1 = (memshift * 8 * rowIn + 256 * thread);
		uint32_t ps2 = (memshift * 8 * rowInOut + 256 * thread);
		uint32_t ps3 = (memshift * 8 * rowOut + 256 * thread);

#pragma unroll 1
	for (int i = 0; i < 8; i++)
	{
		uint32_t s1 = ps1 + i*memshift;
		uint32_t s2 = ps2 + i*memshift;
		uint32_t s3 = ps3 + i*memshift;


		for (int j = 0; j < 3; j++)  
			state1[j] = __ldg4(&(DMatrix + s1)[j]);


		for (int j = 0; j < 3; j++)
			state2[j] = __ldg4(&(DMatrix + s2)[j]);


		for (int j = 0; j < 3; j++)
			          state1[j] += state2[j];

		for (int j = 0; j < 3; j++)
			          state[j] ^= state1[j];


		round_lyra_v35(state);

		((uint2*)state2)[0] ^= ((uint2*)state)[11];
		for (int j = 0; j < 11; j++)
		((uint2*)state2)[j + 1] ^= ((uint2*)state)[j];

if (rowInOut != rowOut) {

	for (int j = 0; j < 3; j++)
		(DMatrix + s2)[j] = state2[j];

	for (int j = 0; j < 3; j++)
		(DMatrix + s3)[j] ^= state[j];

} else {

	for (int j = 0; j < 3; j++)
		state2[j] ^= state[j];

	for (int j = 0; j < 3; j++)
		(DMatrix + s2)[j]=state2[j];
}






	}
}

static __device__ __forceinline__ void reduceDuplexRowtV3(const int rowIn, const int rowInOut, const int rowOut, vectype* state, uint32_t thread)
{

	vectype state1[3], state2[3];
	uint32_t ps1 = (memshift * rowIn + 64 * memshift * thread);
	uint32_t ps2 = (memshift * rowInOut + 64 * memshift * thread);
	uint32_t ps3 = (memshift * rowOut + 64 *memshift * thread);

#pragma nounroll 
	for (int i = 0; i < 8; i++)
	{
		uint32_t s1 = ps1 + 8 * i*memshift;
		uint32_t s2 = ps2 + 8 * i*memshift;
		uint32_t s3 = ps3 + 8 * i*memshift;


		for (int j = 0; j < 3; j++)
			state1[j] = __ldg4(&(DMatrix + s1)[j]);


		for (int j = 0; j < 3; j++)
			state2[j] = __ldg4(&(DMatrix + s2)[j]);


		for (int j = 0; j < 3; j++)
			state1[j] += state2[j];

		for (int j = 0; j < 3; j++)
			state[j] ^= state1[j];


		round_lyra_v35(state);

		((uint2*)state2)[0] ^= ((uint2*)state)[11];
		for (int j = 0; j < 11; j++)
			((uint2*)state2)[j + 1] ^= ((uint2*)state)[j];

		if (rowInOut != rowOut) {

			for (int j = 0; j < 3; j++)
				(DMatrix + s2)[j] = state2[j];

			for (int j = 0; j < 3; j++)
				(DMatrix + s3)[j] ^= state[j];

		}
		else {

			for (int j = 0; j < 3; j++)
				state2[j] ^= state[j];

			for (int j = 0; j < 3; j++)
				(DMatrix + s2)[j] = state2[j];
		}






	}
}



#if __CUDA_ARCH__ < 500
__global__	__launch_bounds__(48, 1)
#elif __CUDA_ARCH__ == 500
__global__	__launch_bounds__(16, 1)
#else
__global__	__launch_bounds__(TPB, 1)
#endif
void lyra2_gpu_hash_32(uint32_t threads, uint32_t startNounce, uint2 *outputHash)
{
	uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);

	   vectype state[4];
#if __CUDA_ARCH__ > 350
	const uint28 blake2b_IV[2] = {
		{{ 0xf3bcc908, 0x6a09e667 },
		{ 0x84caa73b, 0xbb67ae85 },
		{ 0xfe94f82b, 0x3c6ef372 },
		{ 0x5f1d36f1, 0xa54ff53a }},
		{{ 0xade682d1, 0x510e527f },
		{ 0x2b3e6c1f, 0x9b05688c },
		{ 0xfb41bd6b, 0x1f83d9ab },
		{ 0x137e2179, 0x5be0cd19 }}};
#else 
		const ulonglong4 blake2b_IV[2] = {
			{ 0x6a09e667f3bcc908,  
			  0xbb67ae8584caa73b,  
			  0x3c6ef372fe94f82b,  
			  0xa54ff53a5f1d36f1   },
			{ 0x510e527fade682d1,  
			  0x9b05688c2b3e6c1f,  
			  0x1f83d9abfb41bd6b,  
			  0x5be0cd19137e2179  } };
#endif
	
#if __CUDA_ARCH__ == 350
	if (thread < threads)
#endif
	{
 
		 ((uint2*)state)[0] = __ldg(&outputHash[thread]);
		 ((uint2*)state)[1] = __ldg(&outputHash[thread + threads]);
		 ((uint2*)state)[2] = __ldg(&outputHash[thread + 2 * threads]);
		 ((uint2*)state)[3] = __ldg(&outputHash[thread + 3 * threads]);
//		 state[0] = __ldg4(&((vectype*)outputHash)[thread]);
		 state[1] = state[0];
		 state[2] = ((vectype*)blake2b_IV)[0];
		 state[3] = ((vectype*)blake2b_IV)[1];

 
		for (int i = 0; i<24; i++) { round_lyra_v35(state); } //because 12 is not enough

             uint32_t ps1 = (memshift * 7  + 256 * thread);

		for (int i = 0; i < 8; i++)
		{
			uint32_t s1 = ps1 - memshift * i;
			for (int j = 0; j < 3; j++)
			    (DMatrix + s1)[j] = (state)[j];

			round_lyra_v35(state);
		}


		reduceDuplex(state, thread);

		reduceDuplexRowSetupV2(1, 0, 2, state,  thread);
		reduceDuplexRowSetupV2(2, 1, 3, state,  thread);
		reduceDuplexRowSetupV2(3, 0, 4, state,  thread);
		reduceDuplexRowSetupV2(4, 3, 5, state,  thread);
		reduceDuplexRowSetupV2(5, 2, 6, state,  thread);
		reduceDuplexRowSetupV2(6, 1, 7, state,  thread);
		uint32_t rowa = ((uint2*)state)[0].x & 7;

		reduceDuplexRowtV2(7, rowa, 0, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV2(0, rowa, 3, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV2(3, rowa, 6, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV2(6, rowa, 1, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV2(1, rowa, 4, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV2(4, rowa, 7, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV2(7, rowa, 2, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV2(2, rowa, 5, state, thread);

		uint32_t shift = (memshift * 8 * rowa + 256 * thread);

		for (int j = 0; j < 3; j++)
			state[j] ^= __ldg4(&(DMatrix + shift)[j]);

		for (int i = 0; i < 12; i++)
        			round_lyra_v35(state);
		

		outputHash[thread]=            ((uint2*)state)[0];
		outputHash[thread + threads] = ((uint2*)state)[1];
		outputHash[thread + 2 * threads] = ((uint2*)state)[2]; 
		outputHash[thread + 3 * threads] = ((uint2*)state)[3];
//		((vectype*)outputHash)[thread] = state[0];

	} //thread
}

#if __CUDA_ARCH__ < 500
__global__	__launch_bounds__(48, 1)
#elif __CUDA_ARCH__ == 500
__global__	__launch_bounds__(16, 1)
#else
__global__	__launch_bounds__(TPB, 1)
#endif
void lyra2_gpu_hash_32_v3(uint32_t threads, uint32_t startNounce, uint2 *outputHash)
{
	uint32_t thread = (blockDim.x * blockIdx.x + threadIdx.x);

	vectype state[4];

#if __CUDA_ARCH__ > 350
	const uint28 blake2b_IV[2] = {
		{ { 0xf3bcc908, 0x6a09e667 },
		{ 0x84caa73b, 0xbb67ae85 },
		{ 0xfe94f82b, 0x3c6ef372 },
		{ 0x5f1d36f1, 0xa54ff53a } },
		{ { 0xade682d1, 0x510e527f },
		{ 0x2b3e6c1f, 0x9b05688c },
		{ 0xfb41bd6b, 0x1f83d9ab },
		{ 0x137e2179, 0x5be0cd19 } } };
#else 
	const ulonglong4 blake2b_IV[2] = {
		{ 0x6a09e667f3bcc908,
		0xbb67ae8584caa73b,
		0x3c6ef372fe94f82b,
		0xa54ff53a5f1d36f1 },
		{ 0x510e527fade682d1,
		0x9b05688c2b3e6c1f,
		0x1f83d9abfb41bd6b,
		0x5be0cd19137e2179 } };
#endif


#if __CUDA_ARCH__ == 350
	if (thread < threads)
#endif
	{

		((uint2*)state)[0] = __ldg(&outputHash[thread]);
		((uint2*)state)[1] = __ldg(&outputHash[thread + threads]);
		((uint2*)state)[2] = __ldg(&outputHash[thread + 2 * threads]);
		((uint2*)state)[3] = __ldg(&outputHash[thread + 3 * threads]);
		
		state[1] = state[0];

		state[2] = ((vectype*)blake2b_IV)[0];
		state[3] = ((vectype*)blake2b_IV)[1];

		for (int i = 0; i<24; i++) 
                round_lyra_v35(state);  //because 12 is not enough

		uint32_t ps1 = (8 * memshift * 7 + 64 * memshift * thread);


		for (int i = 0; i < 8; i++)
		{
			uint32_t s1 = ps1 - 8 * memshift * i;
			for (int j = 0; j < 3; j++)
				(DMatrix + s1)[j] = (state)[j];

			round_lyra_v35(state);
		}


		reduceDuplexV3(state, thread);

		reduceDuplexRowSetupV3(1, 0, 2, state, thread);
		reduceDuplexRowSetupV3(2, 1, 3, state, thread);
		reduceDuplexRowSetupV3(3, 0, 4, state, thread);
		reduceDuplexRowSetupV3(4, 3, 5, state, thread);
		reduceDuplexRowSetupV3(5, 2, 6, state, thread);
		reduceDuplexRowSetupV3(6, 1, 7, state, thread);
		uint32_t rowa = ((uint2*)state)[0].x & 7;

		reduceDuplexRowtV3(7, rowa, 0, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV3(0, rowa, 3, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV3(3, rowa, 6, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV3(6, rowa, 1, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV3(1, rowa, 4, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV3(4, rowa, 7, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV3(7, rowa, 2, state, thread);
		rowa = ((uint2*)state)[0].x & 7;
		reduceDuplexRowtV3(2, rowa, 5, state, thread);

		uint32_t shift = (memshift * rowa + 64 * memshift * thread);

		for (int j = 0; j < 3; j++)
			state[j] ^= __ldg4(&(DMatrix + shift)[j]);

		for (int i = 0; i < 12; i++)
			round_lyra_v35(state);


		outputHash[thread] = ((uint2*)state)[0];
		outputHash[thread + threads] = ((uint2*)state)[1];
		outputHash[thread + 2 * threads] = ((uint2*)state)[2];
		outputHash[thread + 3 * threads] = ((uint2*)state)[3];
		
	} //thread
}




__host__
void lyra2_cpu_init(int thr_id, uint32_t threads,uint64_t *hash)
{
	cudaMemcpyToSymbol(DMatrix, &hash, sizeof(hash), 0, cudaMemcpyHostToDevice);
}



__host__ 
void lyra2_cpu_hash_32(int thr_id, uint32_t threads, uint32_t startNounce, uint64_t *d_outputHash)
{
uint32_t tpb;
	if (device_sm[device_map[thr_id]]==500)
      tpb = 16; 
    else 
      tpb = TPB;
	dim3 grid((threads + tpb - 1) / tpb);
	dim3 block(tpb);

	if (device_sm[device_map[thr_id]] == 500)
		lyra2_gpu_hash_32 << <grid, block >> > (threads, startNounce, (uint2*)d_outputHash);
    else 
    	lyra2_gpu_hash_32_v3 <<<grid, block>>> (threads, startNounce,(uint2*) d_outputHash);


}

  
>>>>>>> 8c320ca... added xevan
