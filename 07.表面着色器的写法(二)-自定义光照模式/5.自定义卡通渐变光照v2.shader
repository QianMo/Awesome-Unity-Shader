Shader "浅墨Shader编程/Volume7/38.自定义卡通渐变光照v2" 
{  
	//--------------------------------【属性】---------------------------------------- 
	Properties   
    {  
        _MainTex ("【主纹理】Texture", 2D) = "white" {}  
		_Ramp ("【渐变纹理】Ramp Texture", 2D) = "white"{}  
        _BumpMap ("【凹凸纹理】Bumpmap", 2D) = "bump" {}  
        _Detail ("【细节纹理】Detail", 2D) = "gray" {}  
        _RimColor ("【边缘颜色】Rim Color", Color) = (0.26,0.19,0.16,0.0)  
        _RimPower ("【边缘颜色强度】Rim Power", Range(0.5,8.0)) = 3.0  
    }  

	//--------------------------------【子着色器】----------------------------------
    SubShader 
	{  
		//-----------子着色器标签----------  
        Tags { "RenderType"="Opaque" }  
        LOD 200  

        //-------------------开始CG着色器编程语言段-----------------  
        CGPROGRAM  

		//【1】光照模式声明：使用自制的卡通渐变光照模式
        #pragma surface surf QianMoCartoonShader  
        
		
		//变量声明  
        sampler2D _MainTex;  
		sampler2D _Ramp;  
        sampler2D _BumpMap;  
        sampler2D _Detail;  
        float4 _RimColor;  
        float _RimPower;  

		//【2】实现自制的卡通渐变光照模式
        inline float4 LightingQianMoCartoonShader(SurfaceOutput s, fixed3 lightDir, fixed atten)  
        {  
			//点乘反射光线法线和光线方向
            half NdotL = dot (s.Normal, lightDir); 
			//增强光强
            half diff = NdotL * 0.5 + 0.5;
			//从纹理中定义渐变效果
			half3 ramp = tex2D (_Ramp, float2(diff,diff)).rgb;
			//计算出最终结果
            half4 color;
			color.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
			color.a = s.Alpha;

			return color;
        }  

        //【3】输入结构    
        struct Input   
        {  
            //主纹理的uv值  
            float2 uv_MainTex;  
            //凹凸纹理的uv值  
            float2 uv_BumpMap;  
            //细节纹理的uv值  
            float2 uv_Detail;   
            //当前坐标的视角方向  
            float3 viewDir;  
        };  

		
		//【4】表面着色函数的编写
        void surf (Input IN, inout SurfaceOutput o)  
        {  
			 //先从主纹理获取rgb颜色值  
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;     
            //设置细节纹理  
            o.Albedo *= tex2D (_Detail, IN.uv_Detail).rgb * 2;   
            //从凹凸纹理获取法线值  
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));  
            //从_RimColor参数获取自发光颜色  
            half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));  
            o.Emission = _RimColor.rgb * pow (rim, _RimPower);  

        }  

        //-------------------结束CG着色器编程语言段------------------
        ENDCG  
    }   
    FallBack "Diffuse"  
}  