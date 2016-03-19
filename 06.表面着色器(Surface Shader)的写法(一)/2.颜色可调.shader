Shader "浅墨Shader编程/Volume6/25.颜色可调的SurfaceShader"
{
	//--------------------------------【属性】---------------------------------------
	Properties 	
	{
		_Color ("【主颜色】Main Color", Color) = (0.1,0.3,0.9,1)
	}

	//--------------------------------【子着色器】----------------------------------
	SubShader 
	{
		//-----------子着色器标签----------
		Tags { "RenderType"="Opaque" }

		//-------------------开始CG着色器编程语言段----------------- 
		CGPROGRAM
			A
		//【1】光照模式声明：使用兰伯特光照模式
		#pragma surface surf Lambert

		//变量声明
		float4 _Color;

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
			o.Albedo = _Color.rgb;
			//透明值
			o.Alpha = _Color.a;
		}

		//-------------------结束CG着色器编程语言段------------------  
		ENDCG
	} 

	//“备胎”为普通漫反射  
	FallBack "Diffuse"
}
