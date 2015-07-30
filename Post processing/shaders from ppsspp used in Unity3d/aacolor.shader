/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about aacolor
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/aacolor" {
	Properties{
	_MainTex("Main", 2D) = "white" {}
	_Size("Size", range(2, 2048)) = 1024
	_A("saturation", range(0.1, 2)) = 1.20//  saturation 
		_B("brightness", range(0.1, 2)) = 1.00 //  brightness 
		_C("contrast", range(0.1, 2)) = 1.25 //  contrast 
		_C_ch("color channel intensity", Vector) = (1, 1, 1, 1)//  rgb color channel intensity
  
}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" }
		Cull off
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "MyFunc.cginc"
			float _Size;
			float   _A;
		float   _B;
		float   _C;
		float3 _C_ch;

		float4 _LightColor0;
		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		float4 _MainTex_ST;
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;

		};

		v2f vert(appdata_full v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}


		float contrast0(float x)
		{
			return x;
		}

		float contrast1(float x)
		{
			x = x*1.1547 - 1.0;
			return sign(x)*pow(abs(x), 1.0 / _C)*0.86 + 0.86;
		}

		float contrast2(float x)
		{
			return normalize(float2(pow(x, _C), pow(0.86, _C))).x*1.72;
		}

		float contrast3(float x)
		{
			return 1.73*pow(0.57735*x, _C);
		}

		float contrast4(float x)
		{
			return clamp(0.866 + _C*(x - 0.866), 0.05, 1.73);
		}

		float4 frag(v2f i) :COLOR
		{


			float size = 1 / _Size;

			float3 c10 = tex2D(_MainTex, i.uv_MainTex + float2(0, -1)*size).rgb;
			float3 c01 = tex2D(_MainTex, i.uv_MainTex + float2(-1, 0)*size).rgb;
			float3 c11 = tex2D(_MainTex, i.uv_MainTex).rgb;
			float3 c21 = tex2D(_MainTex, i.uv_MainTex + float2(1, 0)*size).rgb;
			float3 c12 = tex2D(_MainTex, i.uv_MainTex + float2(0, 1)*size).rgb;

			float3 dt = float3(1.0, 1.0, 1.0);
			float k1 = dot(abs(c01 - c21), dt);
			float k2 = dot(abs(c10 - c12), dt);

			float3 color = (k1*(c10 + c12) + k2*(c01 + c21) + 0.001*c11) / (2.0*(k1 + k2) + 0.001);

			float x = sqrt(dot(color, color));

			color.r = pow(color.r + 0.001, _A);
			color.g = pow(color.g + 0.001, _A);
			color.b = pow(color.b + 0.001, _A);

			//饱和度，亮度，对比度，色调映射
			return float4(contrast4(x)*normalize(color*_C_ch)*_B,1);

		}
		ENDCG
	}//

	}
}