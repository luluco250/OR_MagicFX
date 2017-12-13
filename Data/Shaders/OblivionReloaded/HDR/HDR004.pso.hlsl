#include "common.hlsl"
#include "ACES.hlsl"

float4 HDRParam                  : register(c1);
float4 TESR_ToneMapping          : register(c19);
float4 TESR_ReciprocalResolution : register(c20);
float4 TESR_HDRParams            : register(c21);

sampler2D ScreenSpace : register(s0);
sampler2D DestBlend   : register(s1);
sampler2D AvgLum      : register(s2);

#define ps float2(TESR_ReciprocalResolution.x, TESR_ReciprocalResolution.y)
#define ar float(TESR_ReciprocalResolution.z)
#define inv_ar (1.0 / ar)

//#define bloom_intensity TESR_HDRParams.x;
#define vignette_intensity TESR_HDRParams.z
#define vignette_hardness TESR_HDRParams.w

void Vignette(inout float4 color, float2 uv) {
	float vignette = 1.0 - pow(abs(distance(uv, 0.5) * vignette_intensity), vignette_hardness);
	color *= saturate(vignette);
}

void main(
	float4 position  : POSITION,
	float2 uv        : TEXCOORD0,
	float2 uv2       : TEXCOORD1,
	out float4 color : COLOR
) {
	color = tex2D(DestBlend, uv2);
	color = max(color, 0.0);
	//color = pow(abs(color), 2.2); // to linear color space
	color = GAMMA2LINEAR(color);

	float4 bloom = tex2D(ScreenSpace, scale_uv(uv, float2(1.0, inv_ar), 0.5));
	color += bloom * TESR_ToneMapping.y;

	//Vignette(color, uv);

	float exposure = TESR_ToneMapping.x / max(get_luma(tex2D(AvgLum, uv).rgb), 0.001);

	color *= exposure;
	color.rgb = ACESFitted(color.rgb);

	//color = pow(abs(color), 1.0 / 2.2); // to gamma color space
	color = LINEAR2GAMMA(color);

	//color.rgb = t_aces(color.rgb, exposure); // to gamma color space
}
