#ifndef TESR_HDR_SHADER_COMMON_HEADER
#define TESR_HDR_SHADER_COMMON_HEADER

#define GAMMA2LINEAR(X) pow(abs(X), 2.2)
#define LINEAR2GAMMA(X) pow(abs(X), 1.0 / 2.2)

float2 scale_uv(float2 uv, float2 scale, float2 center) {
	return (uv - center) * scale + center;
}

float4 _tex2D(sampler2D sp, float2 uv) {
	return tex2Dlod(sp, float4(uv, 0.0, 0.0));
}

float3 screen(float3 a, float3 b, float w) {
	return lerp(a, 1.0 - (1.0 - a) * (1.0 - b), w);
}

float get_average(float3 col) {
	return dot(col, 0.333);
}

float get_luminosity(float3 col) {
	return max(col.r, max(col.g, col.b));
}

float get_luma(float3 col) {
	return dot(col, float3(0.299, 0.587, 0.114));
}

float get_luma_linear(float3 col) {
	return dot(col, float3(0.2126, 0.7152, 0.0722));
}

float3 i_reinhard(float3 col) {
	return (col / max(1.0 - col, 0.001));
}

float3 t_reinhard(float3 col, float exposure) {
	col *= exposure;
	col /= 1.0 + col;
	return pow(abs(col), 2.2);
}

float3 t_aces(float3 col, float exposure) {
	static const float a = 2.51;
    static const float b = 0.03;
    static const float c = 2.43;
    static const float d = 0.59;
    static const float e = 0.14;
	
	col *= exposure;
    col = saturate((col * (a * col + b)) / (col * (c * col + d) + e));
	
	return pow(abs(col), 1.0 / 2.2);
}

float3 t_uncharted2(float3 col, float exposure) {
	static const float A = 0.15;
	static const float B = 0.50;
	static const float C = 0.10;
	static const float D = 0.20;
	static const float E = 0.02;
	static const float F = 0.30;
	static const float W = 11.2;
	
	col *= exposure;
	col = ((col * (A * col + C * B) + D * E) / (col * (A * col + B) + D * F)) - E / F;
	
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	col /= white;

	return pow(abs(col), 1.0 / 2.2);
}

#endif