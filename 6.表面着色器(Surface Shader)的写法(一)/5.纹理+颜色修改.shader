Shader "浅墨Shader编程/Volume6/28.纹理+颜色修改"
{
	//--------------------------------【属性】----------------------------------------
	Properties
	{
		_MainTex ("【主纹理】Texture", 2D) = "white" {}
		_ColorTint ("【色泽】Tint", Color) = (0.6, 0.3, 0.6, 0.3)
	}

	//--------------------------------【子着色器】----------------------------------
	SubShader 
	{
		//-----------子着色器标签----------
		Tags { "RenderType" = "Opaque" }

		//-------------------开始CG着色器编程语言段----------------- 
		CGPROGRAM

		//【1】光照模式声明：使用兰伯特光照模式+自定义颜色函数
		#pragma surface surf Lambert finalcolor:setcolor

		//【2】输入结构  
			struct Input 
			{
			//纹理的uv值
			float2 uv_MainTex;
			};

		//变量声明
		fixed4 _ColorTint;
		sampler2D _MainTex;

		//【3】自定义颜色函数setcolor的编写
			void setcolor (Input IN, SurfaceOutput o, inout fixed4 color)
			{
			//将自选的颜色值乘给color
			color *= _ColorTint;
			}

		//【4】表面着色函数的编写
		void surf (Input IN, inout SurfaceOutput o) 
		{
			//从主纹理获取rgb颜色值
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
		}

		//-------------------结束CG着色器编程语言段------------------  
		ENDCG
	} 

	//“备胎”为普通漫反射  
	Fallback "Diffuse"
}