//-----------------------------------------------【Shader说明】---------------------------------------------------
//		 Unity5.2.1 Built-in Standard Shader
//      2015年10月  Commented by  浅墨    
//      更多内容或交流，请访问浅墨的博客：http://blog.csdn.net/poem_qianmo
//---------------------------------------------------------------------------------------------------------------------

Shader "Standard"
{
	//------------------------------------【属性值】------------------------------------
	Properties
	{
		//主颜色
		_Color("Color", Color) = (1,1,1,1)
		//主纹理
		_MainTex("Albedo", 2D) = "white" {}

		//Alpha剔除值
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
		//平滑、光泽度
		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5

		//金属性
		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		//金属光泽纹理图
		_MetallicGlossMap("Metallic", 2D) = "white" {}

		//凹凸的尺度
		_BumpScale("Scale", Float) = 1.0
		//法线贴图
		_BumpMap("Normal Map", 2D) = "bump" {}

		//高度缩放尺度
		_Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
		//高度纹理图
		_ParallaxMap ("Height Map", 2D) = "black" {}

		//遮挡强度
		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		//遮挡纹理图
		_OcclusionMap("Occlusion", 2D) = "white" {}

		//自发光颜色
		_EmissionColor("Color", Color) = (0,0,0)
		//自发光纹理图
		_EmissionMap("Emission", 2D) = "white" {}
		
		//细节掩膜图
		_DetailMask("Detail Mask", 2D) = "white" {}

		//细节纹理图
		_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
		//细节法线贴图尺度
		_DetailNormalMapScale("Scale", Float) = 1.0
		//细节法线贴图
		_DetailNormalMap("Normal Map", 2D) = "bump" {}

		//二级纹理的UV设置
		[Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0

		//混合状态的定义
		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
	}

	//===========开始CG着色器语言编写模块===========
	CGINCLUDE
		//BRDF相关的一个宏
		#define UNITY_SETUP_BRDF_INPUT MetallicSetup
	//===========结束CG着色器语言编写模块===========
	ENDCG


	//------------------------------------【子着色器1】------------------------------------
	// 此子着色器用于Shader Model 3.0
	//----------------------------------------------------------------------------------------
	SubShader
	{
		//渲染类型设置：不透明
		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }

		//细节层次设为：300
		LOD 300
		
		//--------------------------------通道1-------------------------------
		// 正向基础渲染通道（Base forward pass）
		// 处理方向光，自发光，光照贴图等 ...
		Pass
		{
			//设置通道名称
			Name "FORWARD" 

			//于通道标签中设置光照模型为ForwardBase，正向渲染基础通道
			Tags { "LightMode" = "ForwardBase" }

			//混合操作：源混合乘以目标混合
			Blend [_SrcBlend] [_DstBlend]
			// 根据_ZWrite参数，设置深度写入模式开关与否
			ZWrite [_ZWrite]

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//着色器编译目标：Model 3.0
			#pragma target 3.0

			//编译指令：不使用GLES渲染器编译
			#pragma exclude_renderers gles
			
			// ---------编译指令：着色器编译多样化--------
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP 
			#pragma shader_feature ___ _DETAIL_MULX2
			#pragma shader_feature _PARALLAXMAP
			
			//--------着色器编译多样化快捷指令------------
			//编译指令：编译正向渲染基础通道（用于正向渲染中，应用环境光照、主方向光照和顶点/球面调和光照）所需的所有变体。
			//这些变体用于处理不同的光照贴图类型、主要方向光源的阴影选项的开关与否
			#pragma multi_compile_fwdbase
			//编译指令：编译几个不同变种来处理不同类型的雾效(关闭/线性/指数/二阶指数/)
			#pragma multi_compile_fog
			
			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vertForwardBase
			#pragma fragment fragForwardBase

			//包含辅助CG头文件
			#include "UnityStandardCore.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}
		//--------------------------------通道2-------------------------------
		// 正向附加渲染通道（Additive forward pass）
		// 以每个光照一个通道的方式应用附加的逐像素光照
		Pass
		{
			//设置通道名称
			Name "FORWARD_DELTA"

			//于通道标签中设置光照模型为ForwardAdd，正向渲染附加通道
			Tags { "LightMode" = "ForwardAdd" }

			//混合操作：源混合乘以1
			Blend [_SrcBlend] One

			//附加通道中的雾效应该为黑色
			Fog { Color (0,0,0,0) } 

			//关闭深度写入模式
			ZWrite Off
			//设置深度测试模式：小于等于
			ZTest LEqual

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//着色器编译目标：Model 3.0
			#pragma target 3.0
			//编译指令：不使用GLES渲染器编译
			#pragma exclude_renderers gles

			// ---------编译指令：着色器编译多样化--------
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature ___ _DETAIL_MULX2
			#pragma shader_feature _PARALLAXMAP
			
			//--------使用Unity内置的着色器编译多样化快捷指令------------
			//编译指令：编译正向渲染基础通道所需的所有变体，但同时为上述通道的处理赋予了光照实时阴影的能力。
			#pragma multi_compile_fwdadd_fullshadows
			//编译指令：编译几个不同变种来处理不同类型的雾效(关闭/线性/指数/二阶指数/)
			#pragma multi_compile_fog

			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vertForwardAdd
			#pragma fragment fragForwardAdd

			//包含辅助CG头文件
			#include "UnityStandardCore.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}

		// --------------------------------通道3-------------------------------
		//  阴影渲染通道（Shadow Caster pass）
		//  将将物体的深度渲染到阴影贴图或深度纹理中
		Pass 
		{
			//设置通道名称
			Name "ShadowCaster"
			//于通道标签中设置光照模型为ShadowCaster。
			//此光照模型代表着将物体的深度渲染到阴影贴图或深度纹理。
			Tags { "LightMode" = "ShadowCaster" }

			//开启深入写入模式
			ZWrite On 
			//设置深度测试模式：小于等于
			ZTest LEqual

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//着色器编译目标：Model 3.0
			#pragma target 3.0

			//编译指令：不使用GLES渲染器编译
			#pragma exclude_renderers gles
			

			// ---------编译指令：着色器编译多样化--------
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			
			//--------着色器编译多样化快捷指令------------
			//进行阴影投射相关的多着色器变体的编译
			#pragma multi_compile_shadowcaster

			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			
			//包含辅助CG头文件
			#include "UnityStandardShadow.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}

		// --------------------------------通道4-------------------------------
		//  延迟渲染通道（Deferred Render Pass）
		Pass
		{
			//设置通道名称
			Name "DEFERRED"
			//于通道标签中设置光照模型为Deferred，延迟渲染通道
			Tags { "LightMode" = "Deferred" }

			CGPROGRAM
			#pragma target 3.0
			// TEMPORARY: GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
			#pragma exclude_renderers nomrt gles
			

			//---------编译指令：着色器编译多样化（shader_feature）--------
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature ___ _DETAIL_MULX2
			#pragma shader_feature _PARALLAXMAP

			//---------编译指令：着色器编译多样化（multi_compile）--------
			#pragma multi_compile ___ UNITY_HDR_ON
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
			#pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
			
			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vertDeferred
			#pragma fragment fragDeferred

			//包含辅助CG头文件
			#include "UnityStandardCore.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}

		// --------------------------------通道5-------------------------------
		//元通道（Meta Pass）
		//为全局光照（GI），光照贴图等技术提取相关参数，如（emission, albedo等参数值）
		//此通道并不在常规的渲染过程中使用
		Pass
		{
			//设置通道名称
			Name "META" 

			//于通道标签中设置光照模型为Meta
			//（截止2015年10月22日，Unity 5.2.1的官方文档中并没有收录此光照模型，应该是Unity官方的疏漏）
			Tags { "LightMode"="Meta" }
			//关闭剔除操作
			Cull Off

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vert_meta
			#pragma fragment frag_meta

			//---------编译指令：着色器编译多样化--------
			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature ___ _DETAIL_MULX2

			//包含辅助CG头文件
			#include "UnityStandardMeta.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}
	}

	//------------------------------------【子着色器2】-----------------------------------
	// 此子着色器用于Shader Model 2.0
	//----------------------------------------------------------------------------------------
	SubShader
	{
		//渲染类型设置：不透明
		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
		//细节层次设为：150
		LOD 150

		//--------------------------------通道1-------------------------------
		// 正向基础渲染通道（Base forward pass）
		// 处理方向光，自发光，光照贴图等 ...
		Pass
		{
			//设置通道名称
			Name "FORWARD" 
			//于通道标签中设置光照模型为ForwardBase，正向渲染基础通道
			Tags { "LightMode" = "ForwardBase" }
			//混合操作：源混合乘以目标混合，即结果为两者的混合
			Blend [_SrcBlend] [_DstBlend]
			// 根据_ZWrite参数，设置深度写入模式开关与否
			ZWrite [_ZWrite]

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM
			//着色器编译目标：Model 2.0
			#pragma target 2.0

			// ---------编译指令：着色器编译多样化--------
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION 
			#pragma shader_feature _METALLICGLOSSMAP 
			#pragma shader_feature ___ _DETAIL_MULX2
			// SM2.0: NOT SUPPORTED shader_feature _PARALLAXMAP

			//跳过如下变体的编译，简化编译过程
			#pragma skip_variants SHADOWS_SOFT DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
			
			//--------着色器编译多样化快捷指令------------
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vertForwardBase
			#pragma fragment fragForwardBase

			//包含辅助CG头文件
			#include "UnityStandardCore.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}

		//--------------------------------通道2-------------------------------
		// 正向附加渲染通道（Additive forward pass）
		// 以每个光照一个通道的方式应用附加的逐像素光照
		Pass
		{
			//设置通道名称
			Name "FORWARD_DELTA"

			//于通道标签中设置光照模型为ForwardAdd，正向渲染附加通道
			Tags { "LightMode" = "ForwardAdd" }

			//混合操作：源混合乘以1
			Blend [_SrcBlend] One

			//附加通道中的雾效应该为黑色
			Fog { Color (0,0,0,0) } 

			//关闭深度写入模式
			ZWrite Off

			//设置深度测试模式：小于等于
			ZTest LEqual

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM
			//着色器编译目标：Model 2.0
			#pragma target 2.0

			// ---------编译指令：着色器编译多样化--------
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature ___ _DETAIL_MULX2

			//跳过一些变体的编译
			// SM2.0: NOT SUPPORTED shader_feature _PARALLAXMAP
			#pragma skip_variants SHADOWS_SOFT

			//--------使用Unity内置的着色器编译多样化快捷指令------------
			//编译指令：编译正向渲染基础通道所需的所有变体，但同时为上述通道的处理赋予了光照实时阴影的能力。
			#pragma multi_compile_fwdadd_fullshadows
			//编译指令：编译几个不同变种来处理不同类型的雾效(关闭/线性/指数/二阶指数/)
			#pragma multi_compile_fog

			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vertForwardAdd
			#pragma fragment fragForwardAdd

			//包含辅助CG头文件
			#include "UnityStandardCore.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}

		// --------------------------------通道3-------------------------------
		//  阴影渲染通道（Shadow Caster pass）
		//  将将物体的深度渲染到阴影贴图或深度纹理中
		Pass 
		{
			//设置通道名称
			Name "ShadowCaster"

			//于通道标签中设置光照模型为ShadowCaster。
			//此光照模型代表着将物体的深度渲染到阴影贴图或深度纹理。
			Tags { "LightMode" = "ShadowCaster" }

			//开启深入写入模式
			ZWrite On

			//设置深度测试模式：小于等于
			ZTest LEqual

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM
			//着色器编译目标：Model 2.0
			#pragma target 2.0

			//---------编译指令：着色器编译多样化（shader_feature）--------
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			
			//编译指令：跳过某些变体的编译
			#pragma skip_variants SHADOWS_SOFT

			//快捷编译指令：进行阴影投射相关的多着色器变体的编译
			#pragma multi_compile_shadowcaster

			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster

			//包含辅助CG头文件
			#include "UnityStandardShadow.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}

		// --------------------------------通道4-------------------------------
		//元通道（Meta Pass）
		//为全局光照（GI），光照贴图等技术提取相关参数，如（emission, albedo等参数值）
		//此通道并不在常规的渲染过程中使用
		Pass
		{
			//设置通道名称
			Name "META" 

			//于通道标签中设置光照模型为Meta
			//（截止2015年10月22日，Unity 5.2.1的官方文档中并没有收录此光照模型，应该是Unity官方的疏漏）
			Tags { "LightMode"="Meta" }
			//关闭剔除操作
			Cull Off

			//===========开启CG着色器语言编写模块===========
			CGPROGRAM

			//编译指令：告知编译器顶点和片段着色函数的名称
			#pragma vertex vert_meta
			#pragma fragment frag_meta

			//---------编译指令：着色器编译多样化--------
			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature ___ _DETAIL_MULX2

			//包含辅助CG头文件
			#include "UnityStandardMeta.cginc"

			//===========结束CG着色器语言编写模块===========
			ENDCG
		}
	}

	//回退Shader为顶点光照Shader
	FallBack "VertexLit"
	//使用特定的自定义编辑器UI界面
	CustomEditor "StandardShaderGUI"
}
