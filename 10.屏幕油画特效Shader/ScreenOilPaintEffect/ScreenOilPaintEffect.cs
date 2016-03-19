using UnityEngine;
using System.Collections;

//设置在编辑模式下也执行该脚本
[ExecuteInEditMode]
//添加选项到菜单中
[AddComponentMenu("浅墨Shader编程/Volume10/ScreenOilPaintEffect")]
public class ScreenOilPaintEffect : MonoBehaviour 
{
    //-------------------变量声明部分-------------------
	#region Variables

    //着色器和材质实例
	public Shader CurShader;
	private Material CurMaterial;

    //两个参数值
	[Range(0, 5),Tooltip("分辨率比例值")]
    public float ResolutionValue = 0.9f;
    [Range(1, 30),Tooltip("半径的值，决定了迭代的次数")]
    public int RadiusValue = 5;

    //两个用于调节参数的中间变量
	public static float ChangeValue;
    public static int ChangeValue2;
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
        //依次赋值
        ChangeValue = ResolutionValue;
        ChangeValue2 = RadiusValue;

        //找到当前的Shader文件
        CurShader = Shader.Find("浅墨Shader编程/Volume10/ScreenOilPaintEffect");

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
            //给Shader中的外部变量赋值
            material.SetFloat("_ResolutionValue", ResolutionValue);
            material.SetInt("_Radius", RadiusValue);
            material.SetVector("_ScreenResolution", new Vector4(sourceTexture.width, sourceTexture.height, 0.0f, 0.0f));

            //拷贝源纹理到目标渲染纹理，加上我们的材质效果
			Graphics.Blit(sourceTexture, destTexture, material);
		}

        //着色器实例为空，直接拷贝屏幕上的效果。此情况下是没有实现屏幕特效的
        else
        {
            //直接拷贝源纹理到目标渲染纹理
            Graphics.Blit(sourceTexture, destTexture);
        }
		
		
	}


    //-----------------------------------------【OnValidate()函数】--------------------------------------  
    // 说明：此函数在编辑器中该脚本的某个值发生了改变后被调用
    //--------------------------------------------------------------------------------------------------------
    void OnValidate()
    {
        //将编辑器中的值赋值回来，确保在编辑器中值的改变立刻让结果生效
       ChangeValue = ResolutionValue;
       ChangeValue2 = RadiusValue;
    }
	// Update is called once per frame
	void Update () 
	{
        //若程序在运行，进行赋值
		if (Application.isPlaying)
		{
            //赋值
            ResolutionValue = ChangeValue;
            RadiusValue=ChangeValue2;
		}
        //若程序没有在运行，去寻找对应的Shader文件
		#if UNITY_EDITOR
		if (Application.isPlaying!=true)
		{
            CurShader = Shader.Find("浅墨Shader编程/Volume10/ScreenOilPaintEffect");
		}
		#endif

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
