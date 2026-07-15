void GrainNoise_float(float2 UV, float GrainScale, out float Noise)
{
    Noise = 0.0f;
    
    float2 gridUV = floor(UV * GrainScale);
    
    float2 p = frac(gridUV * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    Noise = frac(p.x * p.y);
            
}

