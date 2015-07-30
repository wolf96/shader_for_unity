/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about FXAA
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/FXAA" {
		Properties{
		_MainTex("Main", 2D) = "white" {}
		_Size("Size", range(2, 2048)) = 512
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

			float4 frag(v2f i) :COLOR
			{

				float	u_texelDelta = 1 / _Size;



				float FXAA_SPAN_MAX = 8.0;
				float FXAA_REDUCE_MUL = 1.0 / 8.0;
				float FXAA_REDUCE_MIN = (1.0 / 128.0);

				float3 rgbNW = tex2D(_MainTex, i.uv_MainTex + (float2(-1.0, -1.0) * u_texelDelta)).xyz;
				float3 rgbNE = tex2D(_MainTex, i.uv_MainTex + (float2(+1.0, -1.0) * u_texelDelta)).xyz;
				float3 rgbSW = tex2D(_MainTex, i.uv_MainTex + (float2(-1.0, +1.0) * u_texelDelta)).xyz;
				float3 rgbSE = tex2D(_MainTex, i.uv_MainTex + (float2(+1.0, +1.0) * u_texelDelta)).xyz;
				float3 rgbM = tex2D(_MainTex, i.uv_MainTex).xyz;

				float3 luma = float3(0.299, 0.587, 0.114);
				float lumaNW = dot(rgbNW, luma);
				float lumaNE = dot(rgbNE, luma);
				float lumaSW = dot(rgbSW, luma);
				float lumaSE = dot(rgbSE, luma);
				float lumaM = dot(rgbM, luma);

				float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
				float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

				float2 dir;
				dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
				dir.y = ((lumaNW + lumaSW) - (lumaNE + lumaSE));

				float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
				
				float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
			
				dir = min(float2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
					max(float2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX), dir * rcpDirMin)) * u_texelDelta;
		
				float3 rgbA = (1.0 / 2.0) * (
					tex2D(_MainTex, i.uv_MainTex + dir * (1.0 / 3.0 - 0.5)).xyz +
					tex2D(_MainTex, i.uv_MainTex + dir * (2.0 / 3.0 - 0.5)).xyz);
				float3 rgbB = rgbA * (1.0 / 2.0) + (1.0 / 4.0) * (
					tex2D(_MainTex, i.uv_MainTex + dir * (0.0 / 3.0 - 0.5)).xyz +
					tex2D(_MainTex, i.uv_MainTex + dir * (3.0 / 3.0 - 0.5)).xyz);

				float lumaB = dot(rgbB, luma);

				if ((lumaB < lumaMin) || (lumaB > lumaMax)){
					return float4( rgbA,1);
				}
				else {
					return float4(rgbB, 1);
				}
				//整体上是一个边缘检测，在边缘处进行采样模糊
	
			}
			ENDCG
		}//

		}
	}