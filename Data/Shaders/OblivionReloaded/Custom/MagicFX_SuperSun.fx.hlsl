// MagicFX by luluco250 for Oblivion Reloaded

sampler2D TESR_SourceBuffer : register(s0) = sampler_state {
	ADDRESSU = CLAMP;
	ADDRESSV = CLAMP;
	MAGFILTER = LINEAR;
	MINFILTER = LINEAR;
	MIPFILTER = LINEAR;
};

sampler2D TESR_DepthBuffer : register(s1) = sampler_state {
	ADDRESSU = CLAMP;
	ADDRESSV = CLAMP;
	MAGFILTER = LINEAR;
	MINFILTER = LINEAR;
	MIPFILTER = LINEAR;
};

float4 TESR_ReciprocalResolution;
float4x4 TESR_WorldTransform;
float4x4 TESR_ViewTransform;
float4x4 TESR_ProjectionTransform;
float4 TESR_CameraForward;
float4 TESR_CameraPosition;

static const float2 res = 1.0 / TESR_ReciprocalResolution.xy;
static const float2 ps = TESR_ReciprocalResolution.xy;
static const float ar = TESR_ReciprocalResolution.z;
static const float4x4 mat_world = TESR_WorldTransform;
static const float4x4 mat_view = TESR_ViewTransform;
static const float4x4 mat_proj = TESR_ProjectionTransform;
static const float nearZ = mat_proj._43 / mat_proj._33;
static const float farZ = (mat_proj._33 * nearZ) / (mat_proj._33 - 1.0);
static const float4 cam_fwd = TESR_CameraForward;
static const float4 cam_pos = TESR_CameraPosition;

float get_depth(float2 uv) {
	float depth = tex2D(TESR_DepthBuffer, uv).x;
	return (2.0 * nearZ) / (nearZ + farZ - depth * (farZ - nearZ));
}

float2 scale_uv(float2 uv, float2 scale, float2 center) {
	return (uv - center) * scale + center;
}

float2 scale_uv(float2 uv, float2 scale) {
	return scale_uv(uv, scale, 0.5);
}

float4x4 inverse(float4x4 input){
	#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
	//determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))
	
	float4x4 cofactors = float4x4(
		minor(_22_23_24, _32_33_34, _42_43_44), 
		-minor(_21_23_24, _31_33_34, _41_43_44),
		minor(_21_22_24, _31_32_34, _41_42_44),
		-minor(_21_22_23, _31_32_33, _41_42_43),
		
		-minor(_12_13_14, _32_33_34, _42_43_44),
		minor(_11_13_14, _31_33_34, _41_43_44),
		-minor(_11_12_14, _31_32_34, _41_42_44),
		minor(_11_12_13, _31_32_33, _41_42_43),
		
		minor(_12_13_14, _22_23_24, _42_43_44),
		-minor(_11_13_14, _21_23_24, _41_43_44),
		minor(_11_12_14, _21_22_24, _41_42_44),
		-minor(_11_12_13, _21_22_23, _41_42_43),
		
		-minor(_12_13_14, _22_23_24, _32_33_34),
		minor(_11_13_14, _21_23_24, _31_33_34),
		-minor(_11_12_14, _21_22_24, _31_32_34),
		minor(_11_12_13, _21_22_23, _31_32_33)
	);
	#undef minor
	return transpose(cofactors) / determinant(input);
}

void VS_PostProcess(
	inout float4 position : POSITION,
	inout float2 uv       : TEXCOORD
) {}

void PS_SuperSun(
	float4 position  : POSITION,
	float2 uv        : TEXCOORD,
	out float4 color : COLOR
) {
	static const float4x4 inv_world = inverse(mat_world);
	static const float4x4 inv_view = inverse(mat_view);
	static const float4x4 inv_proj = inverse(mat_proj);

	float depth = get_depth(uv);
	float4 pos = float4(uv, depth, 1.0);

	pos = pos * 2.0 - 1.0;

	pos = mul(pos, inv_proj);
	pos /= pos.w;
	/*pos = mul(pos, inv_view);
	pos /= cam_fwd;
	pos += cam_pos;*/

	if (uv.x < 0.5)
		color = tex2D(TESR_SourceBuffer, uv);
	else
		color = pos;

	/*float4x4 inv_proj = inverse(mat_proj);
	float4x4 inv_view = inverse(mat_view);

	float4 pos = float4(uv, get_depth(uv), 1.0);
	pos.xyz = pos.xyz * 2.0 - 1.0;

	pos = mul(pos, inv_proj);
	pos = mul(pos, inv_view);

	color = pos;*/
}

technique {
	pass {
		VertexShader = compile vs_3_0 VS_PostProcess();
		PixelShader = compile ps_3_0 PS_SuperSun();
	}
}
