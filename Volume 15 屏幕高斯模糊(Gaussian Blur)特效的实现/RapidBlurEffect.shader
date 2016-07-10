Shader "Learning Unity Shader/Lecture 15/RapidBlurEffect"
{
	//-----------------------------------【属性 || Properties】------------------------------------------  
	Properties
	{
		//主纹理
		_MainTex("Base (RGB)", 2D) = "white" {}
	}

	//----------------------------------【子着色器 || SubShader】---------------------------------------  
	SubShader
	{
		ZWrite Off
		Blend Off

		//---------------------------------------【通道0 || Pass 0】------------------------------------
		//通道0：降采样通道 ||Pass 0: Down Sample Pass
		Pass
		{
			ZTest Off
			Cull Off

			CGPROGRAM

			//指定此通道的顶点着色器为vert_DownSmpl
			#pragma vertex vert_DownSmpl
			//指定此通道的像素着色器为frag_DownSmpl
			#pragma fragment frag_DownSmpl

			ENDCG

		}

		//---------------------------------------【通道1 || Pass 1】------------------------------------
		//通道1：垂直方向模糊处理通道 ||Pass 1: Vertical Pass
		Pass
		{
			ZTest Always
			Cull Off

			CGPROGRAM

			//指定此通道的顶点着色器为vert_BlurVertical
			#pragma vertex vert_BlurVertical
			//指定此通道的像素着色器为frag_Blur
			#pragma fragment frag_Blur

			ENDCG
		}

		//---------------------------------------【通道2 || Pass 2】------------------------------------
		//通道2：水平方向模糊处理通道 ||Pass 2: Horizontal Pass
		Pass
		{
			ZTest Always
			Cull Off

			CGPROGRAM

			//指定此通道的顶点着色器为vert_BlurHorizontal
			#pragma vertex vert_BlurHorizontal
			//指定此通道的像素着色器为frag_Blur
			#pragma fragment frag_Blur

			ENDCG
		}
	}


	//-------------------------CG着色语言声明部分 || Begin CG Include Part----------------------  
	CGINCLUDE

	//【1】头文件包含 || include
	#include "UnityCG.cginc"

	//【2】变量声明 || Variable Declaration
	sampler2D _MainTex;
	//UnityCG.cginc中内置的变量，纹理中的单像素尺寸|| it is the size of a texel of the texture
	uniform half4 _MainTex_TexelSize;
	//C#脚本控制的变量 || Parameter
	uniform half _DownSampleValue;

	//【3】顶点输入结构体 || Vertex Input Struct
	struct VertexInput
	{
		//顶点位置坐标
		float4 vertex : POSITION;
		//一级纹理坐标
		half2 texcoord : TEXCOORD0;
	};

	//【4】降采样输出结构体 || Vertex Input Struct
	struct VertexOutput_DownSmpl
	{
		//像素位置坐标
		float4 pos : SV_POSITION;
		//一级纹理坐标（右上）
		half2 uv20 : TEXCOORD0;
		//二级纹理坐标（左下）
		half2 uv21 : TEXCOORD1;
		//三级纹理坐标（右下）
		half2 uv22 : TEXCOORD2;
		//四级纹理坐标（左上）
		half2 uv23 : TEXCOORD3;
	};


	//【5】准备高斯模糊权重矩阵参数7x4的矩阵 ||  Gauss Weight
	static const half4 GaussWeight[7] =
	{
		half4(0.0205,0.0205,0.0205,0),
		half4(0.0855,0.0855,0.0855,0),
		half4(0.232,0.232,0.232,0),
		half4(0.324,0.324,0.324,1),
		half4(0.232,0.232,0.232,0),
		half4(0.0855,0.0855,0.0855,0),
		half4(0.0205,0.0205,0.0205,0)
	};


	//【6】顶点着色函数 || Vertex Shader Function
	VertexOutput_DownSmpl vert_DownSmpl(VertexInput v)
	{
		//【6.1】实例化一个降采样输出结构
		VertexOutput_DownSmpl o;

		//【6.2】填充输出结构
		//将三维空间中的坐标投影到二维窗口  
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		//对图像的降采样：取像素上下左右周围的点，分别存于四级纹理坐标中
		o.uv20 = v.texcoord + _MainTex_TexelSize.xy* half2(0.5h, 0.5h);;
		o.uv21 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h, -0.5h);
		o.uv22 = v.texcoord + _MainTex_TexelSize.xy * half2(0.5h, -0.5h);
		o.uv23 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h, 0.5h);

		//【6.3】返回最终的输出结果
		return o;
	}

	//【7】片段着色函数 || Fragment Shader Function
	fixed4 frag_DownSmpl(VertexOutput_DownSmpl i) : SV_Target
	{
		//【7.1】定义一个临时的颜色值
		fixed4 color = (0,0,0,0);

	//【7.2】四个相邻像素点处的纹理值相加
	color += tex2D(_MainTex, i.uv20);
	color += tex2D(_MainTex, i.uv21);
	color += tex2D(_MainTex, i.uv22);
	color += tex2D(_MainTex, i.uv23);

	//【7.3】返回最终的平均值
	return color / 4;
	}

		//【8】顶点输入结构体 || Vertex Input Struct
	struct VertexOutput_Blur
	{
		//像素坐标
		float4 pos : SV_POSITION;
		//一级纹理（纹理坐标）
		half4 uv : TEXCOORD0;
		//二级纹理（偏移量）
		half2 offset : TEXCOORD1;
	};

	//【9】顶点着色函数 || Vertex Shader Function
	VertexOutput_Blur vert_BlurHorizontal(VertexInput v)
	{
		//【9.1】实例化一个输出结构
		VertexOutput_Blur o;

		//【9.2】填充输出结构
		//将三维空间中的坐标投影到二维窗口  
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		//纹理坐标
		o.uv = half4(v.texcoord.xy, 1, 1);
		//计算X方向的偏移量
		o.offset = _MainTex_TexelSize.xy * half2(1.0, 0.0) * _DownSampleValue;

		//【9.3】返回最终的输出结果
		return o;
	}

	//【10】顶点着色函数 || Vertex Shader Function
	VertexOutput_Blur vert_BlurVertical(VertexInput v)
	{
		//【10.1】实例化一个输出结构
		VertexOutput_Blur o;

		//【10.2】填充输出结构
		//将三维空间中的坐标投影到二维窗口  
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		//纹理坐标
		o.uv = half4(v.texcoord.xy, 1, 1);
		//计算Y方向的偏移量
		o.offset = _MainTex_TexelSize.xy * half2(0.0, 1.0) * _DownSampleValue;

		//【10.3】返回最终的输出结果
		return o;
	}

	//【11】片段着色函数 || Fragment Shader Function
	half4 frag_Blur(VertexOutput_Blur i) : SV_Target
	{
		//【11.1】获取原始的uv坐标
		half2 uv = i.uv.xy;

		//【11.2】获取偏移量
		half2 OffsetWidth = i.offset;
		//从中心点偏移3个间隔，从最左或最上开始加权累加
		half2 uv_withOffset = uv - OffsetWidth * 3.0;

		//【11.3】循环获取加权后的颜色值
		half4 color = 0;
		for (int j = 0; j< 7; j++)
		{
			//偏移后的像素纹理值
			half4 texCol = tex2D(_MainTex, uv_withOffset);
			//待输出颜色值+=偏移后的像素纹理值 x 高斯权重
			color += texCol * GaussWeight[j];
			//移到下一个像素处，准备下一次循环加权
			uv_withOffset += OffsetWidth;
		}

		//【11.4】返回最终的颜色值
		return color;
	}

	//-------------------结束CG着色语言声明部分  || End CG Programming Part------------------  			
	ENDCG

	FallBack Off
}