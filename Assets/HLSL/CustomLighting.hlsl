#ifndef ADDITIONAL_LIGHT_INCLUDED
#define ADDITIONAL_LIGHT_INCLUDED

void MainLight_float(float3 WorldPos, out float3 Direction, out float3 Color, out float Attenuation)
{
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(float3(1.0f, 1.0f, 0.0f));
    Color = 1.0f;
    Attenuation = 1.0f;
#else
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    Light mainLight = GetMainLight(shadowCoord);
   
    Direction = mainLight.direction;
    Color = mainLight.color;
    float DistanceAtten = mainLight.distanceAttenuation;
    float ShadowAtten = mainLight.shadowAttenuation;
    Attenuation = DistanceAtten * ShadowAtten;
#endif
}

void MainLight_half(half3 WorldPos, out half3 Direction, out half3 Color, out half Attenuation)
{
#ifdef SHADERGRAPH_PREVIEW
    Direction = normalize(half3(1.0f, 1.0f, 0.0f));
    Color = 1.0f;
    Attenuation = 1.0f;
#else
    Light mainLight = GetMainLight();
    Direction = mainLight.direction;
    Color = mainLight.color;
    Attenuation = mainLight.distanceAttenuation;
#endif
}

void AdditionalLight_float(float3 WorldPos, int lightID, out float3 Direction, out float3 Color, out
float Attenuation )
{
    Direction = normalize(float3(1.0f, 1.0f, 0.0f));
    Color = float3(0.0f, 0.0f, 0.0f);
    Attenuation = 0.0f;

#ifndef SHADERGRAPH_PREVIEW
    int lightCount = GetAdditionalLightsCount();
    if (lightID >= 0 && lightID < lightCount)
    {
        Light light = GetAdditionalLight(lightID, WorldPos);
        Direction = light.direction;
        Color = light.color;
        float DistanceAtten = light.distanceAttenuation;
        float ShadowAtten = light.shadowAttenuation;
        Attenuation = DistanceAtten * ShadowAtten;
    }
#endif
}

void AdditionalLight_half(half3 WorldPos, int lightID, out half3 Direction, out half3 Color, out half Attenuation)
{
    Direction = normalize(half3(1.0f, 1.0f, 0.0f));
    Color = half3(0.0f, 0.0f, 0.0f);
    Attenuation = 0.0f;

#ifndef SHADERGRAPH_PREVIEW
    int lightCount = GetAdditionalLightsCount();
    if(lightID < lightCount)
    {
        Light light = GetAdditionalLight(lightID, WorldPos);
        Direction = light.direction;
        Color = light.color;
        Attenuation = light.distanceAttenuation;
    }
#endif
}

void AllAdditionalLights_float(float3 WorldPos, float3 WorldNormal, float2 CutoffThresholds, out float3 LightColor)
{
    LightColor = float3(0.0f, 0.0f, 0.0f);

#ifndef SHADERGRAPH_PREVIEW
    int lightCount = GetAdditionalLightsCount();

    for(int i = 0; i < lightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPos);

        float3 color = dot(light.direction, WorldNormal);
        color = smoothstep(CutoffThresholds.x, CutoffThresholds.y, color);
        color *= light.color;
        color *= light.distanceAttenuation;

        LightColor += color;
    } 
#endif
}

void AllAdditionalLights_half(half3 WorldPos, half3 WorldNormal, half2 CutoffThresholds, out half3 LightColor)
{
    LightColor = half3(0.0f, 0.0f, 0.0f);

#ifndef SHADERGRAPH_PREVIEW
    int lightCount = GetAdditionalLightsCount();

    for(int i = 0; i < lightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPos);
        
        float3 color = dot(light.direction, WorldNormal);
        color = smoothstep(CutoffThresholds.x, CutoffThresholds.y, color);
        color *= light.color;
        color *= light.distanceAttenuation;

        LightColor += color;
    } 
#endif
}

void AllAdditionalLightsNoCuttOff_float(float3 WorldPos, float3 WorldNormal, out float3 LightColor)
{
    LightColor = float3(0.0f, 0.0f, 0.0f);

#ifndef SHADERGRAPH_PREVIEW
    int lightCount = GetAdditionalLightsCount();

    for (int i = 0; i < lightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPos);

        float3 color = dot(light.direction, WorldNormal);
        color *= light.color;
        color *= light.distanceAttenuation;

        LightColor += color;
    }
#endif
}

void TotalDiffuse_float(float3 WorldPos, float3 WorldNormal, out float3 TotalDiffuse)
{
    TotalDiffuse = float3(0.0f, 0.0f, 0.0f);

    #ifndef SHADERGRAPH_PREVIEW
    
    //Main Light
    Light mainLight = GetMainLight();
    float3 L0 = normalize(mainLight.direction);
    float NdotL0 = saturate(dot(WorldNormal, L0));
    TotalDiffuse += mainLight.color * NdotL0 * mainLight.shadowAttenuation;
    
    // Additional Lights
    int additionalLightsCount = GetAdditionalLightsCount();
    for (int i = 0; i < additionalLightsCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPos);
        float3 L = normalize(light.direction);
        float NdotL = saturate(dot(WorldNormal, L));
        float attenuation = light.distanceAttenuation * light.shadowAttenuation;
        TotalDiffuse += light.color * NdotL * attenuation;
    }
    #endif

}

void TotalDiffuseNoColor_float(float3 WorldPos, float3 WorldNormal, out float3 TotalDiffuse)
{
    TotalDiffuse = float3(0.0f, 0.0f, 0.0f);

#ifndef SHADERGRAPH_PREVIEW
    
    //Main Light
    Light mainLight = GetMainLight();
    float3 L0 = normalize(mainLight.direction);
    float NdotL0 = saturate(dot(WorldNormal, L0));
    TotalDiffuse += NdotL0;
    
    // Additional Lights
    int additionalLightsCount = GetAdditionalLightsCount();
    for (int i = 0; i < additionalLightsCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPos);
        float3 L = normalize(light.direction);
        float NdotL = saturate(dot(WorldNormal, L));
        float attenuation = light.distanceAttenuation * light.shadowAttenuation;
        TotalDiffuse += NdotL;
    }
#endif

}

void IsLightDirectionFromSide_float(float3 lightDir, float3 sideDir, float threshold, out float match, out float dotVal)
{
    match = 0.0f;
    dotVal = 0.0f;
 #ifndef SHADERGRAPH_PREVIEW
    float2 ld = normalize(lightDir);
    float2 sd = normalize(sideDir);
    
    dotVal = dot(ld, sd);
  
    match = (dotVal >= threshold) ? 1.0 : 0.0;
    
#endif
}

void ShadowAttenuation_float(float3 WorldPos, out float Attenuation)
{
#if defined(SHADERGRAPH_PREVIEW)
        Attenuation = 1.0;
#else
    float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    Attenuation = MainLightRealtimeShadow(shadowCoord);
#endif
}

void ShadowBlend_float(
    float ShadowAtten,
    float3 EdgeColor, 
    float3 ShadowColor,
    float Sharpness,
    out float3 ResultColor
)
{
#if defined(SHADERGRAPH_PREVIEW)
    ResultColor = float3(0.0f, 0.0f, 0.0f);
#else
    float shadowMask = 1.0 - ShadowAtten;

    float edgeCenter = 1.0 - abs(ShadowAtten - 0.8) * 2.0;
    float edgeMask = saturate(pow(edgeCenter, Sharpness));
    
    float coreShadow = max(shadowMask - edgeMask, 0.0);
    
    ResultColor = ShadowColor * coreShadow + EdgeColor * edgeMask;
    
#endif
}

#endif // ADDITIONAL_LIGHT_INCLUDED
