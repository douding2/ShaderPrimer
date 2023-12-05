using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

[ExecuteInEditMode]
public class MyProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;
    private Texture2D mGenerateTexture = null;

    [SerializeField, SetProperty("TextureWidth")]
    private int mTextureWidth = 512;

    public int TextureWidth
    {
        get { return mTextureWidth; }
        set
        {
            mTextureWidth = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("BackgroundColor")]
    private Color mBackgroundColor = Color.white;

    public Color BackgroundColor
    {
        get { return mBackgroundColor; }
        set
        {
            mBackgroundColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("CircleColor")]
    private Color mCircleColor = Color.red;

    public Color CircleColor
    {
        get { return mCircleColor; }
        set
        {
            mCircleColor = value;
            UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("BlurFactor")]
    private float mBlurFactor = 2.0f;

    public float BlurFactor
    {
        get { return mBlurFactor; }
        set
        {
            mBlurFactor = value;
            UpdateMaterial();
        }
    }


    // Start is called before the first frame update
    void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (!renderer)
            {
                Debug.LogError("没有Renderer组件");
                return;
            }

            material = renderer.sharedMaterial;
        }

        UpdateMaterial();
    }


    // Update is called once per frame
    void Update()
    {
    }

    private void UpdateMaterial()
    {
        if (material)
        {
            mGenerateTexture = GenerateProceduralTexture();
            material.SetTexture("_MainTex", mGenerateTexture);
        }
    }

    private Texture2D GenerateProceduralTexture()
    {
        Texture2D texture2D = new Texture2D(TextureWidth, TextureWidth);

        float circleInterval = TextureWidth / 4f;
        float radius = TextureWidth / 10f;
        float edgeBlur = 1f / BlurFactor;

        for (int w = 0; w < TextureWidth; w++)
        {
            for (int h = 0; h < TextureWidth; h++)
            {
                Color pixel = BackgroundColor;

                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        Color color = MixColor(CircleColor, new Color(pixel.r, pixel.g, pixel.b,0f), Mathf.SmoothStep(0, 1, dist * edgeBlur));
                        pixel = MixColor(color, pixel, color.a);
                    }
                }
                texture2D.SetPixel(w,h, pixel);
            }
        }
        texture2D.Apply();
        return texture2D;
    }

    private Color MixColor(Color A, Color B, float Alpha)
    {
        Color color = A * (1 - Alpha) + B * Alpha;
        color.a = Alpha;
        return color;
    }
}