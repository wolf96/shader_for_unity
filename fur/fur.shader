/*
*Hi, I'm Lin Dong,
*this shader is about fur rendering in unity3d
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*/
Shader "Custom/sufaceshaderYuan" {
	Properties{
	_EdgeLength("Edge length", Range(0.04, 0.5)) = 0.3
	_Phong("Phong Strengh", Range(0, 2)) = 0.5
	_MainTex("Base (RGB)", 2D) = "white" {}
	_Color("Color", color) = (1, 1, 1, 0)

		_DispTex("Disp Texture", 2D) = "gray" {}
	_NormalMap("Normalmap", 2D) = "bump" {}
	_Displacement("Displacement", Range(0, 2)) = 0.3
		_SpecColor("Spec color", color) = (0.5, 0.5, 0.5, 0.5)
		_Route("Route", Range(0, 1)) = 0.5

		_FrontRimColor("front Rim Color", color) = (1, 1, 1, 0)
		_FrontRimPow("front Rim Power", Range(0, 3)) = 1

		_BackRimColor("Back Rim Color", color) = (1, 1, 1, 0)
		_BackRimPow("Back Rim Power", Range(0, 3)) = 1

		_GL("Gloss", Range(0, 2)) = 0.5

		_LengthCull("LengthCull", Range(0.001, 1.5)) = 0.5
}
	SubShader{
		Tags{ "Queue" = "Transparent"
		"IgnoreProjector" = "True"
		"RenderType" = "Transparent" }
		LOD 300
			Cull Back
			CGPROGRAM
#pragma target 4.0

#pragma surface surf HairShader /*alpha*/     vertex:disp tessellate:tessEdge tessphong:_Phong nolightmap 

#include "Tessellation.cginc"
#include "MyFunc.cginc"

		struct appdata {
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};


		sampler2D _DispTex;
		float _Displacement;


		float _Route;
		float _Phong;
		float _EdgeLength;

		float4 tessEdge(appdata v0, appdata v1, appdata v2)
		{
			return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		struct Input {
			float2 uv_MainTex;
			float4 tangent;
		};
		float _U;
		float _LengthCull;
		/*
		*this part is the vertex shader, displace vertex here(displacement mapping)
		*/
		void disp(inout appdata v)
		{
			float d = tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, 0)).r * _Displacement;
			v.vertex.xyz += v.normal * d;
			/*
			*this part you can change the formula to make the fur curve
			*/
			if (d >= 0.1)
				v.vertex.y -= sin(length(v.normal * d) * 2)*v.normal* _Route;

			if (length(v.normal * d) > _LengthCull)
				v.vertex.xyz -= rand(v.vertex.xz)*v.normal*(2 * _LengthCull + 1) / ((1 + d)*(3.5 - 2 * _LengthCull));
		}
		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _NormalMap;


		float4 _DC;
		uniform sampler2D _AlphaTex;
		uniform sampler2D _ShiftTex;
		uniform sampler2D _NormalTex;
		uniform sampler2D _SpecularMaskTex;
		float4 _SC1;
		float4 _SC2;
		float _SpecularExp1;
		float _SpecularExp2;
		float _SpecularShiftX;
		float _SpecularShiftY;

		float4 _FrontRimColor;
		float _FrontRimPow;

		float4 _BackRimColor;
		float _BackRimPow;

		float _GL;


		struct SurfaceOutputHair
		{
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			fixed3 Specular;
			fixed Gloss;
			fixed Alpha;
			float3 n2;

		};

		inline fixed4 LightingHairShader(SurfaceOutputHair s, fixed3 lightDir, fixed3 viewDir, fixed atten)
		{
			viewDir = normalize(viewDir);
			lightDir = normalize(lightDir);
			float3 H = normalize(lightDir + viewDir);
			float3 N = normalize(s.Normal);
			float frontRim = dot(viewDir, N) / 2;
			float BackRim = (1 - dot(viewDir, N)) / 2;

			float specBase = max(0, dot(N, H));
			float spec = pow(specBase, 10) *(_GL + 0.2);
			spec = lerp(0, 0.8, spec);

			fixed4 c = 1;
			c.rgb = (s.Albedo * _LightColor0.rgb * atten) +
				frontRim* _FrontRimColor * _FrontRimPow*atten +
				BackRim * _BackRimColor * _BackRimPow*atten +
				spec * _SpecColor;
			c.a = 1;
			return c;
		}

		void surf(Input IN, inout SurfaceOutputHair o) {
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Specular = 0.2;
			o.Gloss = 1.0;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));

			float d = tex2Dlod(_DispTex, float4(IN.uv_MainTex.xy, 0, 0)).r * _Displacement;
			o.Alpha = 1;
			o.n2 = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));
		}

		ENDCG
	}
	FallBack "Transparent/VertexLit"
}
