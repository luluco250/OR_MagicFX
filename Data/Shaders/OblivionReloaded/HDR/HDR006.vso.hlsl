float4 texRatio0 : register(c6);

void main(
	inout float4 position : POSITION,
	inout float2 uv       : TEXCOORD
) {
	uv = uv * texRatio0.xy + texRatio0.zw;
}
