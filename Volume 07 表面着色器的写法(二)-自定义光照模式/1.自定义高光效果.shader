Shader "浅墨Shader编程/Volume7/34.自定义高光" 
{

	//--------------------------------【属性】---------------------------------- 
	Properties 
	{
		_MainTex ("【主纹理】Texture", 2D) = "white" {}
	}

	//--------------------------------【子着色器】----------------------------------
	SubShader 
	{
		//-----------子着色器标签----------  
		Tags { "RenderType" = "Opaque" }

		//-------------------开始CG着色器编程语言段-----------------   
		CGPROGRAM

		//【1】光照模式声明：使用自定义的光照模式
		#pragma surface surf SimpleSpecular

		//【2】实现自定义的光照模式SimpleSpecular
		half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) 
		{
			half3 h = normalize (lightDir + viewDir);

			half diff = max (0, dot (s.Normal, lightDir));

			float nh = max (0, dot (s.Normal, h));
			float spec = pow (nh, 48.0);

			half4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten * 2);
			c.a = s.Alpha;
			return c;
		}

		//【3】输入结构
		struct Input 
		{
			float2 uv_MainTex;
		};
        
		//变量声明       
		sampler2D _MainTex;

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