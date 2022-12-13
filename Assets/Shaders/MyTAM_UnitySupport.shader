 
/*
Reference:
Praun E, Hoppe H, Webb M, et al. Real-time hatching[C]
Proceedings of the 28th annual conference on Computer graphics and interactive techniques. ACM, 2001: 581.

L.L. Feng, Unity Shader Refined Introduction. Beijing, China: Posts & Telecom Press Co., Ltd. 2017.
*/

Shader "Luyao/MyTAM_UnitySupport"
{
    Properties
    {
        /*_MainTex ("Texture", 2D) = "white" {}*/

		// in inspector
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _TileFactor("Tile Factor", Float) = 1
		// textures
        _Hatch0("Hatch 0", 2D) = "white" {}
        _Hatch1("Hatch 1", 2D) = "white" {}
        _Hatch2("Hatch 2", 2D) = "white" {}
        _Hatch3("Hatch 3", 2D) = "white" {}
        _Hatch4("Hatch 4", 2D) = "white" {}
        _Hatch5("Hatch 5", 2D) = "white" {}
		_Hatch6("Hatch 6", 2D) = "white" {}
        _Hatch7("Hatch 7", 2D) = "white" {}
		
		// *** render outline ***
		_Outline ("Outline", Range(0, 1)) = 0.02

		// pass in lights
		//spotLight;
		//_spotLight1("SpotLight1", SpotLight) = {}
    }
    SubShader
    {
		// outliner pass
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass {
			NAME "OUTLINE"
			
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			float _Outline;
			fixed4 _OutlineColor;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			}; 
			
			struct v2f {
			    float4 pos : SV_POSITION;
			};
			
			v2f vert (a2v v) {
				v2f o;
				
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
				normal.z = -0.5;
				pos = pos + float4(normalize(normal), 0) * _Outline;
				o.pos = mul(UNITY_MATRIX_P, pos);
				
				return o;
			}
			
			float4 frag(v2f i) : SV_Target { 
				return float4(_OutlineColor.rgb, 1);               
			}
			
			ENDCG
		}

		Pass {
			Tags { "LightMode" = "ForwardAdd" }

			// Unity supplied blending multiple light effects (otherwise is overwrites)
			Blend One One  // if vertexshader is gone through twice????????????

			CGPROGRAM
			// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
			// ??? if excluded, then shader not working ???
			//#pragma exclude_renderers d3d11 gles

			#pragma vertex vert
			#pragma fragment frag 

			#pragma multi_compile_fwdadd

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"

			// ********* Variable passed in from C# script ********
			float4 _spotLightPos;
			float _sptIntensity;
			fixed4 _sptColor;

			fixed4 _Color;
			float _TileFactor;
			sampler2D _Hatch0;
			sampler2D _Hatch1;
			sampler2D _Hatch2;
			sampler2D _Hatch3;
			sampler2D _Hatch4;
			sampler2D _Hatch5;
			sampler2D _Hatch6;
			sampler2D _Hatch7;

			struct a2v {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				//fixed3 hatchWeights0 : TEXCOORD1;
				//fixed3 hatchWeights1 : TEXCOORD2; // in total stores 6 weights

				fixed4 hatchWeights0 : TEXCOORD1;
				fixed4 hatchWeights1 : TEXCOORD2; // in total stores 8 weights

				float3 worldPos : TEXCOORD3; //texcoord upto 7
				SHADOW_COORDS(4) // coords for sampling shadow map
			};

			v2f vert(a2v v) {
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv = v.texcoord.xy * _TileFactor;

				// directional light
				//fixed3 worldLightDir = normalize(WorldSpaceLightDir(v.vertex)); // world space direction to light, given object space vertex position.
				//fixed3 worldNormal = UnityObjectToWorldNormal(v.normal); // world space normal direction
				//fixed diff = max(0, dot(worldLightDir, worldNormal)); // diffuse reflection number

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal); // world space normal direction
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // vertex's world position
				
				// ******** Unity supplied variable *********
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - o.worldPos.xyz);

				// diffuse reflection number - but actually is the cos of the angle between WorldLightDir and WorldNormal
				fixed diff = max(0, dot(worldLightDir, worldNormal));

				//o.hatchWeights0 = fixed3(0, 0, 0);
				//o.hatchWeights1 = fixed3(0, 0, 0);

				o.hatchWeights0 = fixed4(0, 0, 0, 0);
				o.hatchWeights1 = fixed4(0, 0, 0, 0);

				//float hatchFactor = diff * 7.0;
				
				//if (hatchFactor > 6.0) {
				//	// Pure white, do nothing
				//}
				//else if (hatchFactor > 5.0) {
				//	o.hatchWeights0.x = hatchFactor - 5.0;
				//}
				//else if (hatchFactor > 4.0) {
				//	o.hatchWeights0.x = hatchFactor - 4.0;
				//	o.hatchWeights0.y = 1.0 - o.hatchWeights0.x;
				//}
				//else if (hatchFactor > 3.0) {
				//	o.hatchWeights0.y = hatchFactor - 3.0;
				//	o.hatchWeights0.z = 1.0 - o.hatchWeights0.y;
				//}
				//else if (hatchFactor > 2.0) {
				//	o.hatchWeights0.z = hatchFactor - 2.0;
				//	o.hatchWeights1.x = 1.0 - o.hatchWeights0.z;
				//}
				//else if (hatchFactor > 1.0) {
				//	o.hatchWeights1.x = hatchFactor - 1.0;
				//	o.hatchWeights1.y = 1.0 - o.hatchWeights1.x;
				//}
				//else {
				//	o.hatchWeights1.y = hatchFactor;
				//	o.hatchWeights1.z = 1.0 - o.hatchWeights1.y;
				//}

				// 8 textures
				float hatchFactor = diff * 9.0;
				if (hatchFactor > 8.0) {
					// Pure white, do nothing
				}
				else if (hatchFactor > 7.0) {  // hatchWeights0.x
					o.hatchWeights0.x = 1 - (hatchFactor - 7.0);
				}
				else if (hatchFactor > 6.0) {  // hatchWeights0.x & y
					o.hatchWeights0.x = hatchFactor - 6.0;
					o.hatchWeights0.y = 1.0 - o.hatchWeights0.x;
				}
				else if (hatchFactor > 5.0) {  // hatchWeights0.y & z
					o.hatchWeights0.y = hatchFactor - 5.0;
					o.hatchWeights0.z = 1.0 - o.hatchWeights0.y;
				}
				else if (hatchFactor > 4.0) {  // hatchWeights0.z & w
					o.hatchWeights0.z = hatchFactor - 4.0;
					o.hatchWeights0.w = 1.0 - o.hatchWeights0.z;
				}
				else if (hatchFactor > 3.0) { // hatchWeights0.w & hatchWeights1.x
					o.hatchWeights0.w = hatchFactor - 3.0;
					o.hatchWeights1.x = 1.0 - o.hatchWeights0.w;
				}
				else if (hatchFactor > 2.0) {  // hatchWeights1.x & y
					o.hatchWeights1.x = hatchFactor - 2.0;
					o.hatchWeights1.y = 1.0 - o.hatchWeights1.x;
				}
				else if (hatchFactor > 1.0) {  // hatchWeights1.y & z
					o.hatchWeights1.y = hatchFactor - 1.0;
					o.hatchWeights1.z = 1.0 - o.hatchWeights1.y;
				}
				else {  // hatchWeights1.z & w
					o.hatchWeights1.z = hatchFactor;
					o.hatchWeights1.w = 1.0 - o.hatchWeights1.z;
				}

				//o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				// compute and pass shadow coordinates to fragment shader
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed4 hatchTex0 = tex2D(_Hatch0, i.uv) * i.hatchWeights0.x;
				fixed4 hatchTex1 = tex2D(_Hatch1, i.uv) * i.hatchWeights0.y;
				fixed4 hatchTex2 = tex2D(_Hatch2, i.uv) * i.hatchWeights0.z;
				fixed4 hatchTex3 = tex2D(_Hatch3, i.uv) * i.hatchWeights0.w;
				fixed4 hatchTex4 = tex2D(_Hatch4, i.uv) * i.hatchWeights1.x;
				fixed4 hatchTex5 = tex2D(_Hatch5, i.uv) * i.hatchWeights1.y;
				fixed4 hatchTex6 = tex2D(_Hatch6, i.uv) * i.hatchWeights1.z;
				fixed4 hatchTex7 = tex2D(_Hatch7, i.uv) * i.hatchWeights1.w;

				fixed4 whiteColor = fixed4(1, 1, 1, 1) * (1 - i.hatchWeights0.x - i.hatchWeights0.y - i.hatchWeights0.z - i.hatchWeights0.w -
							i.hatchWeights1.x - i.hatchWeights1.y - i.hatchWeights1.z - i.hatchWeights1.w); // consider white color

				fixed4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5 + hatchTex6 + hatchTex7 + whiteColor;
				//fixed4 hatchColor = hatchTex0 + hatchTex1 + hatchTex2 + hatchTex3 + hatchTex4 + hatchTex5;

				// compute light attenuation & shadow
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos); 
				// This macro declares "atten" and it stores light attenuation * shadow val
				// i is passed to SHADOW_ATTENUATION for computing shadow

				// *********** include light intensity (Unity supply): * _LightColor0.rgb = LightColor * LightIntensity *********
				return fixed4(hatchColor.rgb * _LightColor0.rgb * _Color.rgb * atten, 1.0);
				//return fixed4(hatchColor.rgb * _LightColor0.rgb * _Color.rgb, 1.0);
			}

			ENDCG
		}
    }
	//FallBack "Diffuse"
}