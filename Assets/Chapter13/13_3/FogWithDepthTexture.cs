using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTexture : PostEffectsBase
{
    public Shader shader;
    private Material fogMaterial = null;

    public Material material
    {
        get
        {
            if (fogMaterial == null)
            {
                fogMaterial = CheckShaderAndCreateMaterial(shader, fogMaterial);
            }
            return fogMaterial;
        }
    }

    private Camera myCamera;
    public new Camera camera
    {
        get
        {
            if (myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }

    private Transform myCameraTransform;
    private Transform cameraTransform
    {
        get
        {
            if (myCameraTransform == null)
            {
                myCameraTransform = GetComponent<Transform>();
            }

            return myCameraTransform;
        }
    }

    [Range(0.0f, 3.0f)]
    public float fogDensity = 1.0f;

    public Color fogColor = Color.white;

    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material == null)
        {
            Graphics.Blit(src, dest);
        }
        else
        {
            var frustumCorners = Matrix4x4.identity;

            var fov = camera.fieldOfView;
            var near = camera.nearClipPlane;
            var far = camera.farClipPlane;
            var aspect = camera.aspect;

            var halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            var toRight = cameraTransform.right * halfHeight * aspect;
            var toTop = cameraTransform.up * halfHeight;

            var topLeft = cameraTransform.forward * near + toTop - toRight;
            var scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            var topRight = cameraTransform.forward * near + toTop + toRight;
            topRight.Normalize();
            topRight *= scale;

            var bottomLeft = cameraTransform.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            var bottomRight = cameraTransform.forward * near - toTop + toRight;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);
            material.SetMatrix(
                "_ViewProjectionInverseMatrix",
                (camera.projectionMatrix * camera.worldToCameraMatrix).inverse
            );

            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(src, dest, material);
        }
    }

    void Start() { }

    // Update is called once per frame
    void Update() { }
}
