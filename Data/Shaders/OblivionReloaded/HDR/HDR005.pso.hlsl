#include "common.hlsl"

float4 HDRParam                  : register(c1);
float4 TESR_ToneMapping          : register(c19);
float4 TESR_ReciprocalResolution : register(c20);

sampler2D ScreenSpace : register(s0);

#define ps float2(TESR_ReciprocalResolution.x, TESR_ReciprocalResolution.y)
#define ar float(TESR_ReciprocalResolution.z)
#define inv_ar (1.0 / ar)

static const int bloom_max_steps = 8;
static const float2 pad = 0.0;

static const float2 offsets[bloom_max_steps] = {
	float2(0.05, 0.05),
	float2(0.05, 0.8),
	float2(0.375, 0.675),
	float2(0.525, 0.625),
	float2(0.6, 0.6),
	float2(0.575, 0.5),
	float2(0.575, 0.425),
	float2(0.575, 0.35)
};

void draw_lod(inout float4 color, sampler2D sp, float2 uv, int lod, float2 center) {
	float scale = pow(2.0, lod);
	uv = scale_uv(uv, float2(scale, scale * ar), center);

	if (uv.x >= -pad.x * scale && uv.x <= 1.0 + pad.x * scale
	 && uv.y >= -pad.y * scale && uv.y <= 1.0 + pad.y * scale) {
		
		color += tex2D(sp, uv);
		float accum = 1.0;
		
		[unroll]
		for (int x = -lod / 2; x <= lod / 2; ++x) {
			for (int y = -lod / 2; y <= lod / 2; ++y) {
				color += _tex2D(sp, uv + ps * float2(x, y) * scale);
				++accum;
			}
		}
		color /= accum;
	 }
}

float4 get_lod(sampler2D sp, float2 uv, int lod, float2 center) {
	float scale = 1.0 / pow(2.0, lod);
	uv = scale_uv(uv, float2(scale, scale * inv_ar), center);
	return tex2D(sp, uv);
}

void main(
	float4 position  : POSITION,
	float2 uv        : TEXCOORD,
	out float4 color : COLOR
) {
	color = tex2D(ScreenSpace, scale_uv(uv, float2(1.0, ar), 0.5));
	color = max(color, 0.0);
	color = GAMMA2LINEAR(color);

	color = pow(abs(color), TESR_ToneMapping.z);
}
