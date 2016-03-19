Shader "浅墨Shader编程/Volume6/30.凹凸纹理+颜色可调+边缘光照"
{
	//--------------------------------【属性】----------------------------------------
	Properties 
	{
		_MainTex ("【主纹理】Texture", 2D) = "white" {}
		_BumpMap ("【凹凸纹理】Bumpmap", 2D) = "bump" {}
		_ColorTint ("【色泽】Tint", Color) = (0.6, 0.3, 0.6, 0.3)
		_RimColor ("【边缘颜色】Rim Color", Color) = (0.26,0.19,0.16,0.0)
		_RimPower ("【边缘颜色强度】Rim Power", Range(0.5,8.0)) = 3.0
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
			//主纹理的uv值
			float2 uv_MainTex;
			//凹凸纹理的uv值
			float2 uv_BumpMap;
			//当前坐标的视角方向
			float3 viewDir;
		};

		//变量声明
		sampler2D _MainTex;
		sampler2D _BumpMap;
		fixed4 _ColorTint;
		float4 _RimColor;
		float _RimPower;

		//【3】自定义颜色函数setcolor的编写
		void setcolor (Input IN, SurfaceOutput o, inout fixed4 color)
			{
			color *= _ColorTint;
			}

		//【4】表面着色函数的编写
		void surf (Input IN, inout SurfaceOutput o) 
		{
			//从主纹理获取rgb颜色值
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
			//从凹凸纹理获取法线值
			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			//从_RimColor参数获取自发光颜色
			half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			o.Emission = _RimColor.rgb * pow (rim, _RimPower);
		}

		//-------------------结束CG着色器编程语言段------------------
		ENDCG
	} 

	//“备胎”为普通漫反射  
	Fallback "Diffuse"
}