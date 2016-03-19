
Shader "浅墨Shader编程/Volume4/17.简单的植被Shader" 
{
	//-------------------------------【属性】-----------------------------------------
   Properties 
   {
        _Color ("主颜色", Color) = (.5, .5, .5, .5)
        _MainTex ("基础纹理 (RGB)-透明度(A)", 2D) = "white" {}
        _Cutoff ("Alpha透明度阈值", Range (0,.9)) = .5
    }

    //--------------------------------【子着色器】--------------------------------
    SubShader 
	{
        //【1】定义材质
        Material 
		{
            Diffuse [_Color]
            Ambient [_Color]
        }

		//【2】开启光照
        Lighting On

		//【3】关闭裁剪，渲染所有面，用于接下来渲染几何体的两面
        Cull Off

		//--------------------------【通道一】-------------------------------
		//		说明：渲染所有超过[_Cutoff] 不透明的像素
		//----------------------------------------------------------------------
        Pass 
		{
            AlphaTest Greater [_Cutoff]
            SetTexture [_MainTex] {
                combine texture * primary, texture
            }
        }

		//----------------------------【通道二】-----------------------------
		//		说明：渲染半透明的细节
		//----------------------------------------------------------------------
        Pass 
		{
			// 不写到深度缓冲中
            ZWrite off

			// 不写已经写过的像素
            ZTest Less

			// 深度测试中，只渲染小于或等于的像素值
            AlphaTest LEqual [_Cutoff]

			// 设置透明度混合
            Blend SrcAlpha OneMinusSrcAlpha
			
			// 进行纹理混合
            SetTexture [_MainTex] 
			{
                combine texture * primary, texture
            }
        }
    }
}
