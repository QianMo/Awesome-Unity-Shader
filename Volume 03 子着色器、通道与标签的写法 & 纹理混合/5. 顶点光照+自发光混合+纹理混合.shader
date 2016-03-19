

Shader "浅墨Shader编程/Volume3/11.顶点光照+自发光混合+纹理混合" 
{
	//-------------------------------【属性】-----------------------------------------
    Properties 
	{
		_IlluminCol ("自发光色", Color) = (0,0,0,0)
        _Color ("主颜色", Color) = (1,1,1,0)
        _SpecColor ("高光颜色", Color) = (1,1,1,1)
        _Emission ("光泽颜色", Color) = (0,0,0,0)
        _Shininess ("光泽度", Range (0.01, 1)) = 0.7
        _MainTex ("基础纹理 (RGB)-自发光(A)", 2D) = "white" {}
		_BlendTex ("混合纹理(RGBA) ", 2D) = "white" {}
    }

	//--------------------------------【子着色器】--------------------------------
    SubShader
	{
		//----------------通道---------------
        Pass
		{
			//【1】设置顶点光照值
            Material
			{
				//可调节的漫反射光和环境光反射颜色
                Diffuse [_Color]
                Ambient [_Color]
				//光泽度
                Shininess [_Shininess]
				//高光颜色
                Specular [_SpecColor]
				//自发光颜色
                Emission [_Emission]
            }

			//【2】开启光照
            Lighting On
			//【3】--------------开启独立镜面反射--------------
            SeparateSpecular On


            //【4】将自发光颜色混合上纹理
            SetTexture [_MainTex] 
			{
				// 使颜色属性进入混合器
                constantColor [_IlluminCol]
				// 使用纹理的alpha通道插值混合顶点颜色
                combine constant lerp(texture) previous
            }

            //【5】乘上基本纹理
            SetTexture [_MainTex] { combine previous * texture  }

			//【6】使用差值操作混合Alpha纹理
            SetTexture [_BlendTex] { combine previous*texture }

			//【7】乘以顶点纹理
			SetTexture [_MainTex] {Combine previous * primary DOUBLE, previous * primary }

        }
    }
} 