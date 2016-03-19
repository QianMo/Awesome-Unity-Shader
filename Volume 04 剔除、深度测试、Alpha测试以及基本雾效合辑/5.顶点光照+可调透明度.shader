
Shader "浅墨Shader编程/Volume4/16.顶点光照+可调透明度" 
{
	//-------------------------------【属性】-----------------------------------------
    Properties 
	{
        _Color ("主颜色", Color) = (1,1,1,0)
        _SpecColor ("高光颜色", Color) = (1,1,1,1)
        _Emission ("光泽颜色", Color) = (0,0,0,0)
        _Shininess ("光泽度", Range (0.01, 1)) = 0.7
        _MainTex ("基础纹理 (RGB)-透明度(A)", 2D) = "white" { }
        _Cutoff ("Alpha透明度阈值", Range (0,1)) = 0.5
    }

	//--------------------------------【子着色器】--------------------------------
    SubShader 
	{
        Pass
		{
			// 【1】使用Cutoff参数定义能被渲染的透明度阈值
            AlphaTest Greater [_Cutoff]

			//【2】设置顶点光照参数值
            Material 
			{
				Diffuse [_Color]
				Ambient [_Color]
				Shininess [_Shininess]
				Specular [_SpecColor]
				Emission [_Emission]
            }

			//【3】开启光照
            Lighting On

			// 【4】进行纹理混合
            SetTexture [_MainTex] { combine texture * primary }
        }
    }
}
