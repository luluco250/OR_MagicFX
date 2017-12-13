// MagicFX by luluco250 for Oblivion Reloaded

sampler2D TESR_SourceBuffer : register(s0) = sampler_state {
	ADDRESSU = CLAMP;
	ADDRESSV = CLAMP;
	MAGFILTER = LINEAR;
	MINFILTER = LINEAR;
	MIPFILTER = LINEAR;
};

float4 TESR_ReciprocalResolution;

static const float2 res = 1.0 / TESR_ReciprocalResolution.xy;
static const float2 ps = TESR_ReciprocalResolution.xy;
static const float2 ar = TESR_ReciprocalResolution.z;

float4 TESR_MagicFX_ParamsA;

static const float fChromaticAberration_Scale = TESR_MagicFX_ParamsA.x;
static const float fVignette_Opacity = TESR_MagicFX_ParamsA.y;
static const float fVignette_Start = TESR_MagicFX_ParamsA.z;
static const float fVignette_End = TESR_MagicFX_ParamsA.w;

float2 scale_uv(float2 uv, float2 scale, float2 center) {
	return (uv - center) * scale + center;
}

float2 scale_uv(float2 uv, float2 scale) {
	return scale_uv(uv, scale, 0.5);
}

float2 fisheye(float2 uv, float2 w) {
	float2 uv2 = (uv - 0.5) * 2.0; // 0.0<->1.0 to -1.0<->1.0
	return uv - float2(
		(1.0 - uv2.y * uv2.y) * w.y * uv2.x,
		(1.0 - uv2.x * uv2.x) * w.x * uv2.y
	);
}

void ChromaticAberration(out float4 color, float2 uv) {
	/*color = float4(
		tex2D(TESR_SourceBuffer, uv).r,
		tex2D(TESR_SourceBuffer, scale_uv(uv, 1.0 - fChromaticAberration_Scale * 0.5)).g,
		tex2D(TESR_SourceBuffer, scale_uv(uv, 1.0 - fChromaticAberration_Scale)).b,
		1.0
	);*/
	color = tex2D(TESR_SourceBuffer, fisheye(uv, 0.05 * ar));
}

void Vignette(inout float4 color, float2 uv) {
	float vignette = 1.0 - smoothstep(fVignette_Start, fVignette_End, distance(uv, 0.5)) * fVignette_Opacity;
	color *= saturate(vignette);
}

void Border(inout float4 color, float2 uv) {

}

void VS_PostProcess(
	inout float4 position : POSITION,
	inout float2 uv       : TEXCOORD
) {}

void PS_Main(
	float4 position  : POSITION,
	float2 uv        : TEXCOORD,
	out float4 color : COLOR
) {
	ChromaticAberration(color, uv);
	Vignette(color, uv);
	Border(color, uv);
}

technique {
	pass {
		VertexShader = compile vs_3_0 VS_PostProcess();
		PixelShader = compile ps_3_0 PS_Main();
	}
}
