
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <math.h>
#include <stdio.h>

__global__ void GetMaxNum_kernel(int *num, int *max)
{
	//__shared__ int MAX;
	int tid = blockDim.x*blockIdx.x + threadIdx.x;
	int tid_idx = 2;
	for (int i = 1; i <= 8; i *= 2)
	{
		if (tid < (20 / tid_idx))
		{
			num[tid*tid_idx] = (num[tid*tid_idx] >= num[tid*tid_idx + i]) ? num[tid*tid_idx] : num[tid*tid_idx + i];
		}
		tid_idx *= 2;
		__syncthreads();
	}
	tid_idx /= 2;
	if (20 != tid_idx)
	{
		if (tid == tid_idx)
		{
			num[0] = (num[0] >= num[tid]) ? num[0] : num[tid];
		}
	}
	*max = num[0];
}

int main()
{
	int *a = new int[20];
	int *num, *b, *max=new int(0);
	for (int  i = 0; i < 20; i++)
	{
		a[i] = i*i;
	}
	cudaMalloc(&num, sizeof(int)* 20);
	cudaMalloc(&b, sizeof(int));
	cudaMemcpy(num, a, sizeof(int)* 20, cudaMemcpyHostToDevice);

	GetMaxNum_kernel << <1, 20 >> >(num, b);

	cudaMemcpy(max, b, sizeof(int), cudaMemcpyDeviceToHost);

	cudaFree(&num);
	cudaFree(&b);

	printf("the MAX num is: %d\n", *max);

	getchar();
	return 0;
}