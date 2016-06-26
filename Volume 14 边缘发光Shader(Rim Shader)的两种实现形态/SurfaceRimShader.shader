

Shader "Learning Unity Shader/Lecture 14/Surface Rim Shader"
{
	//-----------------------------------【属性 || Properties】------------------------------------------  
	Properties
	{
		//主颜色 || Main Color
		_MainColor("【主颜色】Main Color", Color) = (0.5,0.5,0.5,1)
		//漫反射纹理 || Diffuse Texture
		_MainTex("【纹理】Texture", 2D) = "white" {}
		//凹凸纹理 || Bump Texture
		_BumpMap("【凹凸纹理】Bumpmap", 2D) = "bump" {}
		//边缘发光颜色 || Rim Color
		_RimColor("【边缘发光颜色】Rim Color", Color) = (0.17,0.36,0.81,0.0)
		//边缘发光强度 ||Rim Power
		_RimPower("【边缘颜色强度】Rim Power", Range(0.6,36.0)) = 8.0
		//边缘发光强度系数 || Rim Intensity Factor
		_RimIntensity("【边缘颜色强度系数】Rim Intensity", Range(0.0,100.0)) = 1.0
	}

	//----------------------------------【子着色器 || SubShader】---------------------------------------  
	SubShader
	{
		//渲染类型为Opaque，不透明 || RenderType Opaque
		Tags
		{
			"RenderType" = "Opaque" 
		}

		//-------------------------开启CG着色器编程语言段 || Begin CG Programming Part---------------------- 
		CGPROGRAM

			//【1】声明使用兰伯特光照模式 ||Using the Lambert light mode
			#pragma surface surf Lambert  

			//【2】定义输入结构 ||  Input Struct
			struct Input
			{
				//纹理贴图 || Texture
				float2 uv_MainTex;
				//法线贴图 || Bump Texture
				float2 uv_BumpMap;
				//观察方向 || Observation direction
				float3 viewDir;  
			};

			//【3】变量声明 || Variable Declaration
			//边缘颜色
			float4 _MainColor;
			//主纹理
			sampler2D _MainTex;  
			//凹凸纹理  
			sampler2D _BumpMap;
			//边缘颜色
			float4 _RimColor;
			//边缘颜色强度
			float _RimPower;
			//边缘颜色强度
			float _RimIntensity;

			//【4】表面着色函数的编写 || Writing the surface shader function
			void surf(Input IN, inout SurfaceOutput o)
			{
				//表面反射颜色为纹理颜色  
				o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb*_MainColor.rgb;
				//表面法线为凹凸纹理的颜色  
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
				//边缘颜色  
				half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
				//计算出边缘颜色强度系数  
				o.Emission = _RimColor.rgb * pow(rim, _RimPower)*_RimIntensity;
			}

		//-------------------结束CG着色器编程语言段 || End CG Programming Part------------------  
		ENDCG
	}

		//后备着色器为普通漫反射 || Fallback use Diffuse
		Fallback "Diffuse"
}