/*
*Hi, I'm Lin Dong,
*this shader's algorithm is from ppsspp
*this is a shader about cartoon
*maybe something wrong, welcome to contect me
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/cartoon" {
		Properties{
		_MainTex("Main", 2D) = "white" {}
		_Size("Size", range(2, 2048)) = 512
			_Bb("bb", range(0, 1)) = 0.5//边缘线条粗细、
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
			float _Bb;

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

				float3 c00 = tex2D(_MainTex, i.uv_MainTex + float2(-1, -1)*size).rgb;
				float3 c10 = tex2D(_MainTex, i.uv_MainTex + float2(0, -1)*size).rgb;
				float3 c20 = tex2D(_MainTex, i.uv_MainTex + float2(1, -1)*size).rgb;
				float3 c01 = tex2D(_MainTex, i.uv_MainTex + float2(-1, 0)*size).rgb;
				float3 c11 = tex2D(_MainTex, i.uv_MainTex).rgb;
				float3 c21 = tex2D(_MainTex, i.uv_MainTex + float2(1, 0)*size).rgb;
				float3 c02 = tex2D(_MainTex, i.uv_MainTex + float2(-1, 1)*size).rgb;
				float3 c12 = tex2D(_MainTex, i.uv_MainTex + float2(0, 1)*size).rgb;
				float3 c22 = tex2D(_MainTex, i.uv_MainTex + float2(1, 1)*size).rgb;
				float3 dt = float3(1.0, 1.0, 1.0);

				float d1 = dot(abs(c00 - c22), dt);
				float d2 = dot(abs(c20 - c02), dt);
				float hl = dot(abs(c01 - c21), dt);
				float vl = dot(abs(c10 - c12), dt);
				float d = _Bb*(d1 + d2 + hl + vl) / (dot(c11, dt) + 0.15);
	
				float lc = 4.0*length(c11);
			
				float f = frac(lc); 
				f *= f;
				lc = 0.25*(floor(lc) + f*f) + 0.05;
				//颜色总共分为四层，把颜色灰度每层段数值再加上减到最少的小数部分，产生一些过渡效果
			
				c11 = 4.0*normalize(c11);
				float3 frct = frac(c11); 
				frct *= frct;
				c11 = floor(c11) + 0.05*dt + frct*frct;
				return float4(0.25*lc*(1.1 - d*sqrt(d))*c11,1);
				//再用得出的灰度乘上原色值，保留了原来的颜色只是明暗分为四层，层之间有过度
				//通过边缘检测描边，着色道理与之前的一篇文章像似，但不完全相同，

			}
			ENDCG
		}//

		}
	}