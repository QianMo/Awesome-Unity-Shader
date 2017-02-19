
Shader "ShaderPrac/Car Paint Shader"
{
	Properties
	{
		//主颜色
		_MainColor("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
		//细节颜色
		_DetailColor("Detail Color", Color) = (1.0, 1.0, 1.0, 1.0)
		//细节纹理
		_DetailTex("Detail Textrue", 2D) = "white" {}
		//细节纹理深度偏移
		_DetailTexDepthOffset("Detail Textrue Depth Offset", Float) = 1.0
		//漫反射颜色
		_DiffuseColor("Diffuse Color", Color) = (0.0, 0.0, 0.0, 0.0)
		//漫反射纹理
		_DiffuseTex("Diffuse Textrue", 2D) = "white" {}
		//Material Capture纹理
		_MatCap("MatCap", 2D) = "white" {}
		//反射颜色
		_ReflectionColor("Reflection Color", Color) = (0.2, 0.2, 0.2, 1.0)
		//反射立方体贴图
		_ReflectionMap("Reflection Cube Map", Cube) = "" {}
		//反射强度
		_ReflectionStrength("Reflection Strength", Range(0.0, 1.0)) = 0.5
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}

		Pass
		{
			Blend Off
			Cull Back
			ZWrite On

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma fragment frag
			#pragma vertex vert

			float4 _MainColor;
			float4 _DetailColor;
			sampler2D _DetailTex;
			float4 _DetailTex_ST;
			float _DetailTexDepthOffset;
			float4 _DiffuseColor;
			sampler2D _DiffuseTex;
			float4 _DiffuseTex_ST;
			sampler2D _MatCap;
			float4 _ReflectionColor;
			samplerCUBE _ReflectionMap;
			float _ReflectionStrength;

			//顶点输入结构
			struct VertexInput
			{
				float3 normal : NORMAL;
				float4 position : POSITION;
				float2 UVCoordsChannel1: TEXCOORD0;
			};

			//顶点输出(片元输入)结构
			struct VertexToFragment
			{
				float3 detailUVCoordsAndDepth : TEXCOORD0;
				float4 diffuseUVAndMatCapCoords : TEXCOORD1;
				float4 position : SV_POSITION;
				float3 worldSpaceReflectionVector : TEXCOORD2;
			};

			//------------------------------------------------------------
			// 顶点着色器
			//------------------------------------------------------------
			VertexToFragment vert(VertexInput input)
			{
				VertexToFragment output;

				//漫反射UV坐标准备：存储于TEXCOORD1的前两个坐标xy。
				output.diffuseUVAndMatCapCoords.xy = TRANSFORM_TEX(input.UVCoordsChannel1, _DiffuseTex);

				//MatCap坐标准备：将法线从模型空间转换到观察空间，存储于TEXCOORD1的后两个纹理坐标zw
				output.diffuseUVAndMatCapCoords.z = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), normalize(input.normal));
				output.diffuseUVAndMatCapCoords.w = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalize(input.normal));
				//归一化的法线值区间[-1,1]转换到适用于纹理的区间[0,1]
				output.diffuseUVAndMatCapCoords.zw = output.diffuseUVAndMatCapCoords.zw * 0.5 + 0.5;

				//坐标变换
				output.position = mul(UNITY_MATRIX_MVP, input.position);

				//细节纹理准备准备UV,存储于TEXCOORD0的前两个坐标xy
				output.detailUVCoordsAndDepth.xy = TRANSFORM_TEX(input.UVCoordsChannel1, _DetailTex);
				
				//深度信息准备,存储于TEXCOORD0的第三个坐标z
				output.detailUVCoordsAndDepth.z = output.position.z;

				//世界空间位置
				float3 worldSpacePosition = mul(unity_ObjectToWorld, input.position).xyz;

				//世界空间法线
				float3 worldSpaceNormal = normalize(mul((float3x3)unity_ObjectToWorld, input.normal));

				//世界空间反射向量
				output.worldSpaceReflectionVector = reflect(worldSpacePosition - _WorldSpaceCameraPos.xyz, worldSpaceNormal);
				
				return output;
			}

			//------------------------------------------------------------
			// 片元着色器
			//------------------------------------------------------------
			float4 frag(VertexToFragment input) : COLOR
			{
				//镜面反射颜色
				float3 reflectionColor = texCUBE(_ReflectionMap, input.worldSpaceReflectionVector).rgb * _ReflectionColor.rgb;

				//漫反射颜色
				float4 diffuseColor = tex2D(_DiffuseTex, input.diffuseUVAndMatCapCoords.xy) * _DiffuseColor;

				//主颜色
				float3 mainColor = lerp(lerp(_MainColor.rgb, diffuseColor.rgb, diffuseColor.a), reflectionColor, _ReflectionStrength);

				//细节纹理
				float3 detailMask = tex2D(_DetailTex, input.detailUVCoordsAndDepth.xy).rgb;

				//细节颜色
				float3 detailColor = lerp(_DetailColor.rgb, mainColor, detailMask);

				//细节颜色和主颜色进行插值，成为新的主颜色
				mainColor = lerp(detailColor, mainColor, saturate(input.detailUVCoordsAndDepth.z * _DetailTexDepthOffset));

				//从提供的MatCap纹理中，提取出对应光照信息
				float3 matCapColor = tex2D(_MatCap, input.diffuseUVAndMatCapCoords.zw).rgb;

				//最终颜色
				float4 finalColor=float4(mainColor * matCapColor * 2.0, _MainColor.a);

				return finalColor;
			}

			ENDCG
		}
	}

	Fallback "VertexLit"
}
