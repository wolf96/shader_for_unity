/*
*Hi, I'm Lin Dong,
*this shader is about Barrel distortion in unity3d
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/Barrel" {
		Properties{
		_MainTex("MainTex", 2D) = "white" {}
		_distortion("distortion", range(-3, 3)) = -0.7
			_cubicDistortion("cubicDistortion", range(0, 3)) = 0.4
			_scale("scale", range(0, 3)) = 1
	}
		SubShader{
			pass{
			Tags{ "LightMode" = "ForwardBase" }
			Cull off
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma target 4.0 
#include "UnityCG.cginc"
				float 	_Intensity_x;
			float 	_Intensity_y;
			float _P_x;
			float _P_y;
			float _distortion;
			float _cubicDistortion;
			float _scale;

			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			struct v2f {
				fixed4 pos : SV_POSITION;
				fixed2 uv_MainTex : TEXCOORD0;

			};

			v2f vert(appdata_full v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			float2 barrel(float2 uv)
			{ 

				float2 h = uv.xy - float2(0.5, 0.5);
				float r2 = h.x * h.x + h.y * h.y;
				float f = 1.0 + r2 * (_distortion + _cubicDistortion * sqrt(r2));

				return f * _scale * h + 0.5;
			}
			fixed4 frag(v2f i) :COLOR
			{

				return tex2D(_MainTex, barrel(i.uv_MainTex));
			}
			ENDCG
		}//

		}
	}
