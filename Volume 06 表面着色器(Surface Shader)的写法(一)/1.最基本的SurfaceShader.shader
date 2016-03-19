Shader "浅墨Shader编程/Volume6/24.最基本的SurfaceShader"
{
	//--------------------------------【子着色器】----------------------------------
	SubShader 
	{
		//-----------子着色器标签----------
		Tags { "RenderType" = "Opaque" }

		//-------------------开始CG着色器编程语言段-----------------  
		CGPROGRAM
		
		//【1】光照模式声明：使用兰伯特光照模式  
		#pragma surface surf Lambert

		//【2】输入结构  
		struct Input 
		{
			//四元素的颜色值（RGBA）
			float4 color : COLOR;
		};

		//【3】表面着色函数的编写
		void surf (Input IN, inout SurfaceOutput o) 
		{
			//反射率
			o.Albedo = float3(0.5,0.8,0.3);//(0.5,0.8,0.3)分别对应于RGB分量
			//而o.Albedo = 0.6;等效于写o.Albedo = float3(0.6,0.6,0.6);
		}

		//-------------------结束CG着色器编程语言段------------------  
		ENDCG
	}

	//“备胎”为普通漫反射  
	Fallback "Diffuse"
}