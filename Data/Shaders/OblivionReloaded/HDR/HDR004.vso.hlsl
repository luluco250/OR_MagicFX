float4 texRatio0 : register(c6);
float4 texRatio1 : register(c7);

void main(
	inout float4 position : POSITION,
	inout float2 uv       : TEXCOORD0,
	out float2 uv2        : TEXCOORD1
) {
	uv2 = uv * texRatio1.xy + texRatio1.zw;
	uv  = uv * texRatio0.xy + texRatio0.zw;
}
