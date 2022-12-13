using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MultiplePointPtLights : MonoBehaviour
{
    public GameObject currModel;
    //public Light mainSpotLight;
    public Light directLight;
    public Light[] secondaryLights;  // multiple lights
    public Camera mainCamera;

    // available textures
    public Texture[] gammaTex;
    public Texture[] linearTex;
    public Texture[] diagnal45Tex;
    public Texture[] diagnal30Tex;
    public int textureOption;

    public float specIndex;

    private Renderer currRenderer;

    //public bool hatchMaxDiff;

    //public List<Vector4> _spotLights;
    //public Vector4 _spotLight;

    // Start is called before the first frame update
    void Start()
    {
        //Renderer currRenderer = this.gameObject.GetComponent<Renderer>();
        currRenderer = GetComponent<Renderer>();
        //Renderer currRenderer = currModel.GetComponent<Renderer>();
    }

    // Update is called once per fram
    void Update()
    {
        //Vector4 _spotLightPos = mainSpotLight.transform.position;
        ////Debug.Log(_spotLightPos);
        //float _sptIntensity = mainSpotLight.intensity; // intensity = intensity * color
        //Color _sptColor = mainSpotLight.color;
        ////Debug.Log(_spotLightPos);

        ////Debug.Log(_sptColor);

        //Shader.SetGlobalVector("_spotLightPos", _spotLightPos);
        //Shader.SetGlobalFloat("_sptIntensity", _sptIntensity);
        //Shader.SetGlobalColor("_sptColor", _sptColor);
        ////Shader.SetGlobalVector("_sptColor", _sptColor);

        // directional light


        // multiple lights
        Shader.SetGlobalFloat("_specIndex", specIndex);

        // Create arrays of the varibles of the lights for shader
        Vector4[] _secLightsPos = new Vector4[secondaryLights.Length];
        for(int i = 0; i < secondaryLights.Length; ++i)
        {
            _secLightsPos[i] = secondaryLights[i].transform.position;
        }

        int _secLightNum = secondaryLights.Length;
        Shader.SetGlobalInt("_secLightNum", _secLightNum);
        Shader.SetGlobalVectorArray("_secLightsPos", _secLightsPos);

        float[] _secLightsIntensity = new float[_secLightNum];
        for (int i = 0; i < _secLightNum; ++i)
        {
            _secLightsIntensity[i] = secondaryLights[i].intensity;
        }

        Shader.SetGlobalFloatArray("_secLightsIntensity", _secLightsIntensity);

        Vector4[] _secLightsColorVec = new Vector4[_secLightNum];
        for (int i = 0; i < _secLightNum; ++i)
        {
            _secLightsColorVec[i] = secondaryLights[i].color;
        }
        //Debug.Log("color: " + secondaryLights[0].color);
        //Debug.Log("vector4: " + _secLightsColorVec[0]);  // set color to vector4 will loose a little information
        Shader.SetGlobalVectorArray("_secLightsColorVec", _secLightsColorVec);

        // pass light direction (for directional light)
        Vector4 _dLightDir = directLight.transform.forward;
        //Debug.Log("DL.transform.forward = " + _lightsDir);
        Shader.SetGlobalVector("_dLightDir", _dLightDir);
        float _dLightIntensity = directLight.intensity;
        Shader.SetGlobalFloat("_dLightIntensity", _dLightIntensity);
        Color _dLightColor = directLight.color;
        Shader.SetGlobalColor("_dLightColor", _dLightColor);

        // pass light near and far distance to shader
        float[] _farDisArray = new float[_secLightNum];
        for(int i = 0; i < _secLightNum; ++i)
        {
            _farDisArray[i] = secondaryLights[i].range;
        }
        Shader.SetGlobalFloatArray("_farDisArray", _farDisArray);

        float[] _nearDisArray = new float[_secLightNum];
        for (int i = 0; i < _secLightNum; ++i)
        {
            _nearDisArray[i] = secondaryLights[i].range * 0.4f;
        }
        Shader.SetGlobalFloatArray("_nearDisArray", _nearDisArray);

        // 
        Vector4 _cameraPos = mainCamera.transform.position;
        Shader.SetGlobalVector("_cameraPos", _cameraPos);


        // texture switch at run time
        if (textureOption == 0)  // linear tone textures
        {
            for (int i = 0; i < linearTex.Length; ++i)
            {
                string textureName = "_Hatch" + i;
                currRenderer.material.SetTexture(textureName, linearTex[i]);
            }
        }
        if (textureOption == 1)  // gamma corrected tone textures
        {
            for (int i = 0; i < linearTex.Length; ++i)
            {
                string textureName = "_Hatch" + i;
                currRenderer.material.SetTexture(textureName, gammaTex[i]);
            }
        }
        if (textureOption == 2)  // gamma corrected tone textures for 45 dgree diagnal cross hatching
        {
            for (int i = 0; i < linearTex.Length; ++i)
            {
                string textureName = "_Hatch" + i;
                currRenderer.material.SetTexture(textureName, diagnal45Tex[i]);
            }
        }
        if (textureOption == 3)  // gamma corrected tone textures for 30 dgree diagnal cross hatching
        {
            for (int i = 0; i < linearTex.Length; ++i)
            {
                string textureName = "_Hatch" + i;
                currRenderer.material.SetTexture(textureName, diagnal30Tex[i]);
            }
        }
    }
}
