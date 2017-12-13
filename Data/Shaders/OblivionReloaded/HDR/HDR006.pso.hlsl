#include "common.hlsl"

float4 TimingData                : register(c0);
float4 HDRParam                  : register(c1);
float4 TESR_ToneMapping          : register(c19);

sampler2D ScreenSpace : register(s0);
sampler2D AvgLum      : register(s1);

void main(
	float4 position  : POSITION,
	float2 uv        : TEXCOORD,
	out float4 color : COLOR
) {
	color = tex2D(ScreenSpace, uv);
	color = max(color, 0.0);
	//color = pow(abs(color), 2.2);
	color = GAMMA2LINEAR(color);
	color = pow(abs(color), TESR_ToneMapping.w);

	float4 last = tex2D(AvgLum, uv);
	//last = pow(abs(last), 2.2);
	last = GAMMA2LINEAR(last);
	color = lerp(last, color, pow(abs(HDRParam.z), TimingData.z));
	color = pow(abs(color), 1.0 / TESR_ToneMapping.w);
	//color = pow(abs(color), 1.0 / 2.2);
	color = LINEAR2GAMMA(color);
}
