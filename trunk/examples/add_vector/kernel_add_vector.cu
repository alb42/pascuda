__global__ 
void add(int *a, int *b, int *c, int *n)
{
  int index = blockIdx.x;
  if( index < *n)
  {
    c[index] = a[index] + b[index] ;
  }
}
