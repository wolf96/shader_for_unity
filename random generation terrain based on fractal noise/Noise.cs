/*
*Hi, I'm Lin Dong,
*this is about noise(value perlin fractal)
*if you want to get more detail please enter my blog http://blog.csdn.net/wolf96
*my email: wolf_crixus@sina.cn 
*/
using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class Noise : MonoBehaviour
{
    public Texture2D texture;
    public int resolution = 126;
    // Use this for initialization
    int TABSIZE = 200;
    static bool initialized = false;
    /* Coefficients of basis matrix. */



    void Start()
    {

    }
    private void OnEnable()
    {
        texture = new Texture2D(resolution, resolution, TextureFormat.RGB24, false);
        texture.name = "Procedural Texture";
        texture.wrapMode = TextureWrapMode.Clamp;
        texture.filterMode = FilterMode.Bilinear;
        GetComponent<MeshRenderer>().material.mainTexture = texture;
        FillTexture();
    }
    /* public void FillTexture()//random
     {
         if (texture.width != resolution)
         {
             texture.Resize(resolution, resolution);
         }

         Vector3 point00 = new Vector3(-0.5f, -0.5f);
         Vector3 point10 = new Vector3(0.5f, -0.5f);
         Vector3 point01 = new Vector3(-0.5f, 0.5f);
         Vector3 point11 = new Vector3(0.5f, 0.5f);

      
         float stepSize = 1f / resolution;
         Random.seed = 42;
         for (int y = 0; y < resolution; y++)
         {
             Vector3 point0 = Vector3.Lerp(point00, point01, (y + 0.5f) * stepSize);
             Vector3 point1 = Vector3.Lerp(point10, point11, (y + 0.5f) * stepSize);
             for (int x = 0; x < resolution; x++)
             {
                 Vector3 point = Vector3.Lerp(point0, point1, (x + 0.5f) * stepSize);
                 texture.SetPixel(x, y, Color.white * Random.value);
             }
         }
         texture.Apply();
     }*/

  public void FillTexture()//value//perlin
      {
          if (texture.width != resolution)
          {
              texture.Resize(resolution, resolution);
          }

          Vector3 point00 = new Vector3(-0.5f, -0.5f);
          Vector3 point10 = new Vector3(0.5f, -0.5f);
          Vector3 point01 = new Vector3(-0.5f, 0.5f);
          Vector3 point11 = new Vector3(0.5f, 0.5f);


          float stepSize = 1f / resolution;
          for (int y = 0; y < resolution; y++)
          {
              Vector3 point0 = Vector3.Lerp(point00, point01, (y + 0.5f) * stepSize);
              Vector3 point1 = Vector3.Lerp(point10, point11, (y + 0.5f) * stepSize);
              for (int x = 0; x < resolution; x++)
              {
                  Vector3 point = Vector3.Lerp(point0, point1, (x + 0.5f) * stepSize);
                  texture.SetPixel(x, y, Color.white * NoiseMethod.Value3D(point, 22));//
              }
          }

          texture.Apply();
      }


  /*  public void FillTexture()//Fractal Noise
    {
        if (texture.width != resolution)
        {
            texture.Resize(resolution, resolution);
        }

        float frequency = 22;

        //[Range(1, 8)]
        int octaves = 6;//1普通，8烟雾状

        //	[Range(1f, 4f)]
        float lacunarity = 2f;

        //	[Range(0f, 1f)]
        float persistence = 0.5f;

        Vector3 point00 = new Vector3(-0.5f, -0.5f);
        Vector3 point10 = new Vector3(0.5f, -0.5f);
        Vector3 point01 = new Vector3(-0.5f, 0.5f);
        Vector3 point11 = new Vector3(0.5f, 0.5f);


        float stepSize = 1f / resolution;
        for (int y = 0; y < resolution; y++)
        {
            Vector3 point0 = Vector3.Lerp(point00, point01, (y + 0.5f) * stepSize);
            Vector3 point1 = Vector3.Lerp(point10, point11, (y + 0.5f) * stepSize);
            for (int x = 0; x < resolution; x++)
            {
                Vector3 point = Vector3.Lerp(point0, point1, (x + 0.5f) * stepSize);
                float sample = NoiseMethod.Sum(1, point, frequency, octaves, lacunarity, persistence);
        //      if (type != NoiseMethodType.Value)
        //        {
        //            sample = sample * 0.5f + 0.5f;
        //        }
         
                texture.SetPixel(x, y, Color.white * sample);
            }
        }




        texture.Apply();
    }

*/



    // Update is called once per frame
    void Update()
    {
        OnEnable();
        FillTexture();
    }
}
