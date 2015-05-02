/*
*Hi, I'm Lin Dong,
*this shader is about Super Sampling Anti-Aliasing in unity3d
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/SSAA1" {
	Properties{
	_MainTex("MainTex", 2D) = "white" {}
	_Size("Size", range(1, 2048)) = 512

}
	SubShader{
		pass{
		Tags{ "LightMode" = "ForwardBase" }
		Cull off
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

			float _Size;
		sampler2D _MainTex;
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
		float4 frag(v2f i) :COLOR
		{
			/*
			*this part is about edge detection algorithms used Sobel operator
			*/
			float3 lum = float3(0.2125, 0.7154, 0.0721);
			float mc00 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(1, 1) / _Size).rgb, lum);
			float mc10 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(0, 1) / _Size).rgb, lum);
			float mc20 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(-1, 1) / _Size).rgb, lum);
			float mc01 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(1, 0) / _Size).rgb, lum);
			float mc11mc = dot(tex2D(_MainTex, i.uv_MainTex).rgb, lum);
			float mc21 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(-1, 0) / _Size).rgb, lum);
			float mc02 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(1, -1) / _Size).rgb, lum);
			float mc12 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(0, -1) / _Size).rgb, lum);
			float mc22 = dot(tex2D(_MainTex, i.uv_MainTex - fixed2(-1, -1) / _Size).rgb, lum);
			float GX = -1 * mc00 + mc20 + -2 * mc01 + 2 * mc21 - mc02 + mc22;
			float GY = mc00 + 2 * mc10 + mc20 - mc02 - 2 * mc12 - mc22;
			float G = abs(GX) + abs(GY);
			float4 c = 0;
			c = length(float2(GX, GY));
			/*
			*this part is about blur edge
			*/
			float4 cc = tex2D(_MainTex, i.uv_MainTex);
			if (c.x < 0.2)
			{
				return cc;
			}
			else
			{
				float2 n = float2(GX, GY);
				n *= 1 / _Size / c.x;
				//roated
				float4 c0 = tex2D(_MainTex, i.uv_MainTex + fixed2(0.2 / 2, 0.8) / _Size);
				float4 c1 = tex2D(_MainTex, i.uv_MainTex + fixed2(0.8 / 2, -0.2) / _Size);
				float4 c2 = tex2D(_MainTex, i.uv_MainTex + fixed2(-0.2 / 2, -0.8) / _Size);
				float4 c3 = tex2D(_MainTex, i.uv_MainTex + fixed2(-0.8 / 2, 0.2) / _Size);

				//random
				float2 randUV = 0;
				randUV = rand(float2(n.x, n.y));
				float4 c0 = tex2D(_MainTex, i.uv_MainTex + float2(randUV.x / 2, randUV.y) / _Size);
				randUV = rand(float2(-n.x, n.y));
				float4 c1 = tex2D(_MainTex, i.uv_MainTex + float2(randUV.x / 2, randUV.y) / _Size);
				randUV = rand(float2(n.x, -n.y));
				float4 c2 = tex2D(_MainTex, i.uv_MainTex + float2(randUV.x / 2, randUV.y) / _Size);
				randUV = rand(float2(-n.x, -n.y));
				float4 c3 = tex2D(_MainTex, i.uv_MainTex + float2(randUV.x / 2, randUV.y) / _Size);

				//Gird

				float4 c0 = tex2D(_MainTex, i.uv_MainTex + fixed2(0.5, 1) / _Size);
				float4 c1 = tex2D(_MainTex, i.uv_MainTex + fixed2(-0.5, 1) / _Size);
				float4 c2 = tex2D(_MainTex, i.uv_MainTex + fixed2(0.5, -1) / _Size);
				float4 c3 = tex2D(_MainTex, i.uv_MainTex + fixed2(-0.5, -1) / _Size);
				cc = (cc + c0 + c1 + c2 + c3) *0.2;
				return cc;
			}

		}
		ENDCG
	}

	}
}
