__global__ 
void add(float2 *in, float2 *out, float2 *out2)
{
  int index = blockIdx.x;
  float2 a = in[index];
  out[index] = a;
 //(float2)
  in->x = 0.0;
  in->y = 0.0;
  
  out->x = 0.0;
  out->y = 0.0;
 //*(float2)a.x =  index;
}
