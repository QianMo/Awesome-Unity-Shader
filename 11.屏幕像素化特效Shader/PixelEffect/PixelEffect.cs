
using UnityEngine;
using System.Collections;

//设置在编辑模式下也执行该脚本
[ExecuteInEditMode]
//添加选项到菜单中
[AddComponentMenu("浅墨Shader编程/Volume11/PixelEffect")]
public class PixelEffect : MonoBehaviour 
{
    //-----------------------------变量声明部分---------------------------
	#region Variables

    //着色器和材质实例
	public Shader CurShader;
	private Material CurMaterial;

    //三个可调节的自定义参数
    [Range(1f, 1024f), Tooltip("屏幕每行将被均分为多少个像素块")]
    public float PixelNumPerRow = 580.0f;

    [Tooltip("自动计算正方形像素所需的长宽比与否")]
    public bool AutoCalulateRatio = true;

    [Range(0f, 24f), Tooltip("此参数用于自定义长宽比")]
    public float Ratio = 1.0f;

	#endregion


    //-------------------------材质的get&set----------------------------
    #region MaterialGetAndSet
    Material material
	{
		get
		{
			if(CurMaterial == null)
			{
				CurMaterial = new Material(CurShader);
				CurMaterial.hideFlags = HideFlags.HideAndDontSave;	
			}
			return CurMaterial;
		}
	}
	#endregion

    //-----------------------------------------【Start()函数】---------------------------------------------  
    // 说明：此函数仅在Update函数第一次被调用前被调用
    //--------------------------------------------------------------------------------------------------------
	void Start () 
	{
        //找到当前的Shader文件
        CurShader = Shader.Find("浅墨Shader编程/Volume11/PixelEffect");

        //判断当前设备是否支持屏幕特效
		if(!SystemInfo.supportsImageEffects)
		{
			enabled = false;
			return;
		}
	}

    //-------------------------------------【OnRenderImage()函数】------------------------------------  
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    //--------------------------------------------------------------------------------------------------------
	void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture)
	{
        //着色器实例不为空，就进行参数设置
        if(CurShader != null)
		{
            float pixelNumPerRow = PixelNumPerRow;
            //给Shader中的外部变量赋值
            material.SetVector("_Params", new Vector2(pixelNumPerRow, 
                AutoCalulateRatio ? ((float)sourceTexture.width / (float)sourceTexture.height) : Ratio ));

			Graphics.Blit(sourceTexture, destTexture, material);
		}

        //着色器实例为空，直接拷贝屏幕上的效果。此情况下是没有实现屏幕特效的
        else
        {
            //直接拷贝源纹理到目标渲染纹理
            Graphics.Blit(sourceTexture, destTexture);
        }
	}

    //-----------------------------------------【Update()函数】----------------------------------------
    // 说明：此函数在每一帧中都会被调用  
    //------------------------------------------------------------------------------------------------------
    void Update()
    {
        //若程序在运行，进行赋值
        if (Application.isPlaying)
        {
         #if UNITY_EDITOR
            if (Application.isPlaying != true)
            {
                CurShader = Shader.Find("浅墨Shader编程/Volume11/PixelEffect");
            }
        #endif
        }
    }
    //-----------------------------------------【OnDisable()函数】---------------------------------------  
    // 说明：当对象变为不可用或非激活状态时此函数便被调用  
    //--------------------------------------------------------------------------------------------------------
	void OnDisable ()
	{
		if(CurMaterial)
		{
            //立即销毁材质实例
			DestroyImmediate(CurMaterial);	
		}		
	}
}

