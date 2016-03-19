
Shader "浅墨Shader编程/Volume4/14.用剔除实现玻璃效果" 
{
	//-------------------------------【属性】---------------------------------------
    Properties 
	{
        _Color ("主颜色", Color) = (1,1,1,0)
        _SpecColor ("高光颜色", Color) = (1,1,1,1)
        _Emission ("光泽颜色", Color) = (0,0,0,0)
        _Shininess ("光泽度", Range (0.01, 1)) = 0.7
        _MainTex ("基础纹理 (RGB)-透明度(A)", 2D) = "white" {}
    }

	//--------------------------------【子着色器】--------------------------------
    SubShader 
	{
		//【1】定义材质
        Material 
		{
            Diffuse [_Color]
            Ambient [_Color]
            Shininess [_Shininess]
            Specular [_SpecColor]
            Emission [_Emission]
        }
		//【2】开启光照
        Lighting On
		//【3】开启独立镜面反射
        SeparateSpecular On

		//【4】开启透明度混合（alpha blending）
        Blend SrcAlpha OneMinusSrcAlpha

		//--------------------------【通道一】-------------------------------
		//		说明：渲染对象的背面部分
		//----------------------------------------------------------------------
        Pass
		{
			// 如果对象是凸型, 那么总是离镜头离得比前面更远
            Cull Front	//不绘制面向观察者的几何面
            SetTexture [_MainTex] 
			{
                Combine Primary * Texture
            }
        }

		//----------------------------【通道二】-----------------------------
		//		说明：渲染对象背对我们的部分
		//----------------------------------------------------------------------
        Pass 
		{
			// 如果对象是凸型,那么总是离镜头离得比背面更远
            Cull Back //不绘制背离观察者的几何面
            SetTexture [_MainTex] 
			{
                Combine Primary * Texture
            }
        }
    }
}