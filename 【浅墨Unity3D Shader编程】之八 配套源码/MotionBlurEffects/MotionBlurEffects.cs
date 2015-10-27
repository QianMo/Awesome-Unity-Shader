using UnityEngine;
using System.Collections;

[ExecuteInEditMode]

public class MotionBlurEffects : MonoBehaviour
{

    //-------------------变量声明部分-------------------
    #region Variables
    public Shader CurShader;//着色器实例
    private Vector4 ScreenResolution;//屏幕分辨率
    private Material CurMaterial;//当前的材质

    [Range(5, 50)]
    public float IterationNumber = 15;
    [Range(-0.5f, 0.5f)]
    public float Intensity = 0.125f;
    [Range(-2f, 2f)]
    public float OffsetX = 0.5f;
    [Range(-2f, 2f)]
    public float OffsetY = 0.5f;


    public static float ChangeValue;
    public static float ChangeValue2;
    public static float ChangeValue3;
    public static float ChangeValue4;
    #endregion


    //-------------------------材质的get&set----------------------------
    #region MaterialGetAndSet
    Material material
    {
        get
        {
            if (CurMaterial == null)
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
    void Start()
    {
        //依此赋值
        ChangeValue = Intensity;
        ChangeValue2 = OffsetX;
        ChangeValue3 = OffsetY;
        ChangeValue4 = IterationNumber;

        //找到当前的Shader文件
        CurShader = Shader.Find("浅墨Shader编程/Volume8/运动模糊特效标准版");

        //判断是否支持屏幕特效
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }
    }

    //-------------------------------------【OnRenderImage()函数】------------------------------------  
    // 说明：此函数在当完成所有渲染图片后被调用，用来渲染图片后期效果
    //--------------------------------------------------------------------------------------------------------
    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        //着色器实例不为空，就进行参数设置
        if (CurShader != null)
        {
            //设置Shader中的外部变量
            material.SetFloat("_IterationNumber", IterationNumber);
            material.SetFloat("_Value", Intensity);
            material.SetFloat("_Value2", OffsetX);
            material.SetFloat("_Value3", OffsetY);
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
        ChangeValue4 = IterationNumber;
        ChangeValue = Intensity;
        ChangeValue2 = OffsetX;
        ChangeValue3 = OffsetY;

    }

    //-----------------------------------------【Update()函数】------------------------------------------  
    // 说明：此函数在每一帧中都会被调用
    //-------------------------------------------------------------------------------------------------------- 
    void Update()
    {
        if (Application.isPlaying)
        {
            //赋值
            IterationNumber = ChangeValue4;
            Intensity = ChangeValue;
            OffsetX = ChangeValue2;
            OffsetY = ChangeValue3;

        }

        //找到对应的Shader文件
#if UNITY_EDITOR
        if (Application.isPlaying != true)
        {
            CurShader = Shader.Find("浅墨Shader编程/Volume8/运动模糊特效标准版");

        }
#endif
    }


    //-----------------------------------------【OnDisable()函数】---------------------------------------  
    // 说明：当对象变为不可用或非激活状态时此函数便被调用  
    //--------------------------------------------------------------------------------------------------------
    void OnDisable()
    {
        if (CurMaterial)
        {
            DestroyImmediate(CurMaterial);
        }
    }
}
