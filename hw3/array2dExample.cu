
#include <stdio.h>
#include <iostream>

using namespace std;

__global__ void 
reduce(float *g, float *o, const int dimx, const int dimy) {

	//extern __shared__ float sdata[];

	unsigned int tid_x = threadIdx.x;
	unsigned int tid_y = threadIdx.y;

	unsigned int i = blockDim.x * blockIdx.x + threadIdx.x;
	unsigned int j = blockDim.y * blockIdx.y + threadIdx.y; 

	if (i >= dimx || j >= dimy)
	    return;

	o[i*dimy + j] = g[i*dimy + j] + 1;

	/*sdata[tid_x*blockDim.y + tid_y] = g[i*dimy + j];

	__syncthreads();

	for(unsigned int s_y = blockDim.y/2; s_y > 0; s_y >>= 1)
	{
	    if (tid_y < s_y)
	    {
	        sdata[tid_x * dimy + tid_y] += sdata[tid_x * dimy + tid_y + s_y];
	    }
	    __syncthreads();
	}

	for(unsigned int s_x = blockDim.x/2; s_x > 0; s_x >>= 1 )
	{

	    if(tid_x < s_x)
	    {
	        sdata[tid_x * dimy] += sdata[(tid_x + s_x) * dimy];
	    }
	    __syncthreads();
	}

	float sum;

	if( tid_x == 0 && tid_y == 0)
	{ 
	    sum = sdata[0];
	    atomicAdd (o, sum);   // The result should be the sum of all pixel values. But the program produce 0
	}

//if(tid_x==0 && tid__y == 0 ) 
    //o[blockIdx.x] = sdata[0];

    */
}



int
main()
{   
	int dimx = 320;
	int dimy = 160;
	int num_bytes = dimx*dimy*sizeof(float);

	float *d_a, *h_a, // device and host pointers
	            *d_o=0, *h_o=0;

	h_a = (float*)malloc(num_bytes);
	h_o = (float*)malloc(sizeof(float));

	for (int i=0; i < dimx; i++){   
	    for (int j=0; j < dimy; j++){
	        h_a[i*dimy + j] = 1;
	    }
	}

	cudaMalloc( (void**)&d_a, num_bytes );
	cudaMalloc( (void**)&d_o, sizeof(int) );

	cudaMemcpy( d_a, h_a, num_bytes, cudaMemcpyHostToDevice);
	cudaMemcpy( d_o, h_o, sizeof(int), cudaMemcpyHostToDevice); 

	dim3 grid, block;
	block.x = 4;
	block.y = 4;
	grid.x = dimx / block.x;
	grid.y = dimy / block.y;

	reduce<<<grid, block>>> (d_a, d_o, block.x, block.y);

	std::cout << block.x << " " << block.y << std::endl;
	std::cout << grid.x << " " << grid.y << std::endl;
	std::cout << dimx <<  " " << dimy << " " << dimx*dimy << std::endl;

	cudaMemcpy( h_a, d_a, num_bytes, cudaMemcpyDeviceToHost );
	cudaMemcpy( h_o, d_o, sizeof(int), cudaMemcpyDeviceToHost );

	cudaFree(d_a);
	cudaFree(d_o);

	for(int i = 0 ; i < dimx ; i++){
		for(int j = 0 ; j < dimy ; j++){
		  cout << "h_a[" << (i*dimy) + j << "]=" << h_a[(i*dimy) + j] << endl;
		}
	}

	for(int i = 0 ; i < dimx ; i++){
		for(int j = 0 ; j < dimy ; j++){
		  cout << "h_o[" << (i*dimy) + j << "]=" << h_o[(i*dimy) + j] << endl;
		}
	}

	
	free(h_a);
	free(h_o);
}
