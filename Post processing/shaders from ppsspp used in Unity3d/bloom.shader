/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about bloom
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/bloom " {
		Properties{
		_MainTex("Main", 2D) = "white" {}
		_Size("Size", range(2, 2048)) = 512
			_Amount("amount", range(0, 1)) = 0.6
			_Power("_Power", range(0, 1)) = 0.5
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
			float _Amount;
			float _Power;


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
				float size = 1 / _Size;
				float2 uv = i.uv_MainTex;


				float3 color = tex2D(_MainTex, i.uv_MainTex);
				float4 sum = 0;
				float3 bloom;


				for (int i = -3; i < 3; i++)
				{
					sum += tex2D(_MainTex, uv + float2(-1, i)*size) * _Amount;
					sum += tex2D(_MainTex, uv + float2(0, i)*size) * _Amount;
					sum += tex2D(_MainTex, uv + float2(1, i)*size) * _Amount;
				}

				if (color.r < 0.3 && color.g < 0.3 && color.b < 0.3)
				{
					bloom = sum.rgb*sum.rgb*0.012 + color;
				}
				else
				{
					if (color.r < 0.5 && color.g < 0.5 && color.b < 0.5)
					{
						bloom = sum.xyz*sum.xyz*0.009 + color;
					}
					else
					{
						bloom = sum.xyz*sum.xyz*0.0075 + color;
					}
				}

				bloom = mix(color, bloom, _Power);

				return float4(bloom, 1);
			}
			ENDCG
		}//

		}
	}