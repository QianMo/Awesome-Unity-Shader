
Shader "Learning Unity Shader/Lecture 15/RapidBlurEffect" 
{
	//-----------------------------------【属性 || Properties】------------------------------------------  
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	//-------------------------CG着色语言声明部分 || Begin CG Include Part----------------------  
	CGINCLUDE

		//【1】头文件包含 || include
		#include "UnityCG.cginc"

		//【2】变量声明 || Variable Declaration
		sampler2D _MainTex;
		uniform half4 _MainTex_TexelSize;
		uniform half4 _Parameter;

		//【3】顶点输入结构体 || Vertex Input Struct
		struct VertexInput
		{
			float4 vertex : POSITION;//1.顶点位置坐标
			half2 texcoord : TEXCOORD0;//2.一级纹理坐标
		};

		//【4】顶点输出结构体 || Vertex Input Struct
		struct VertexOutput_DownSample
		{
			float4 pos : SV_POSITION;
			half2 uv20 : TEXCOORD0;
			half2 uv21 : TEXCOORD1;
			half2 uv22 : TEXCOORD2;
			half2 uv23 : TEXCOORD3;
		};

		//【5】顶点着色函数 || Vertex Shader Function
		VertexOutput_DownSample vert_DownSample(VertexInput v )
		{
			VertexOutput_DownSample o;

			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
        	o.uv20 = v.texcoord + _MainTex_TexelSize.xy;				
			o.uv21 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h,-0.5h);	
			o.uv22 = v.texcoord + _MainTex_TexelSize.xy * half2(0.5h,-0.5h);		
			o.uv23 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h,0.5h);		

			return o; 
		}	

		//【6】片段着色函数 || Fragment Shader Function
		fixed4 frag_DownSample( VertexOutput_DownSample i ) : SV_Target
		{			
			//四个相邻像素点取平均
			fixed4 color = tex2D (_MainTex, i.uv20);
			color += tex2D (_MainTex, i.uv21);
			color += tex2D (_MainTex, i.uv22);
			color += tex2D (_MainTex, i.uv23);
			return color / 4;
		}
	
		//【7】准备高斯模糊权重矩阵参数7x4的矩阵 ||  Gauss Weight
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

		//【8】顶点输入结构体 || Vertex Input Struct
		struct VertexOutput_Blur 
		{
			float4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
			half2 offs : TEXCOORD1;
		};	
		
		//【9】顶点着色函数 || Vertex Shader Function
		VertexOutput_Blur vert_BlurHorizontal(VertexInput v)
		{
			VertexOutput_Blur o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = half4(v.texcoord.xy,1,1);
			o.offs = _MainTex_TexelSize.xy * half2(1.0, 0.0) * _Parameter.x;

			return o; 
		}

		//【10】顶点着色函数 || Vertex Shader Function
		VertexOutput_Blur vert_BlurVertical(VertexInput v)
		{
			VertexOutput_Blur o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = half4(v.texcoord.xy,1,1);
			o.offs = _MainTex_TexelSize.xy * half2(0.0, 1.0) * _Parameter.x;
			 
			return o; 
		}	

		//【11】片段着色函数 || Fragment Shader Function
		half4 frag_Blur( VertexOutput_Blur i ) : SV_Target
		{
			half2 uv = i.uv.xy; 
			half2 netFilterWidth = i.offs;  
			half2 coords = uv - netFilterWidth * 3.0;  
			
			half4 color = 0;
  			for( int l = 0; l < 7; l++ )  
  			{   
				half4 tap = tex2D(_MainTex, coords);
				color += tap * GaussWeight[l];
				coords += netFilterWidth;
  			}
			return color;
		}

	//-------------------结束CG着色语言声明部分  || End CG Programming Part------------------  			
	ENDCG
	
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
		
			#pragma vertex vert_DownSample
			#pragma fragment frag_DownSample
		
			ENDCG
		 
		}

		//---------------------------------------【通道1 || Pass 1】------------------------------------
		//通道1：垂直方向模糊处理通道 ||Pass 1: Vertical Pass
		Pass 
		{
			ZTest Always
			Cull Off
		
			CGPROGRAM 
		
			#pragma vertex vert_BlurVertical
			#pragma fragment frag_Blur
		
			ENDCG 
			}	
		
		//---------------------------------------【通道2 || Pass 2】------------------------------------
		//通道2：水平方向模糊处理通道 ||Pass 2: Horizontal Pass
		Pass {		
			ZTest Always
			Cull Off
				
			CGPROGRAM
		
			#pragma vertex vert_BlurHorizontal
			#pragma fragment frag_Blur
		
			ENDCG
			}	
	}	

	FallBack Off
}
