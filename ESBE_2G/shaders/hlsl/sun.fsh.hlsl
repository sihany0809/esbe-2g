#include "ShaderConstants.fxh"
#include "snoise.fxh"

struct PS_Input
{
	float4 position : SV_Position;
	float2 uv : TEXCOORD_0_FB_MSAA;
	float2 uv_ : uv_;
	float4 fsh : fsh;
};

struct PS_Output
{
	float4 color : SV_Target;
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
	float2x2 p = PSInput.fsh;
	float l = length(p[0]);
	float s;
	if(TEXTURE_0.Sample(TextureSampler0,float2(.5,.5)).r>.5)
		s = max(cos(min(l*12.,1.58)),.5-l*.7);
	else{
		float mp = (floor(PSInput.uv_.x*4.)*.25+step(PSInput.uv_.y,.5))*3.1415;//[0~2pi]
		float r =.13;//月半径
		float3 n = normalize(float3(p[0],sqrt(r*r-l*l)));
		s = dot(-float3(sin(mp),0.,cos(mp)),n);
		s = smoothstep(-r,0.,s)*(s*.2+.8)*smoothstep(r,r-r*.15,l);
		s *= 1.-smoothstep(1.5,0.,snoise(p[0]+n.xy+5.)*.5+snoise((p[0]+n.xy)*3.)*.25+.75)*.15;
		s = max(s,cos(min(l*2.,1.58))*sin(mp*.5)*.6);//拡散光
	}
	PSOutput.color = float4(1.,.95,.81,smoothstep(.7,1.,FOG_CONTROL.y))*s;
}
