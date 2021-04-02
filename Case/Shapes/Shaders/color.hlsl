//***************************************************************************************
// color.hlsl by Frank Luna (C) 2015 All Rights Reserved.
//
// Transforms and colors geometry.
//***************************************************************************************

cbuffer cbPerObject : register( b0 )
{
    float4x4 gWorld;
    float gSpecularPower;
};

cbuffer cbPass : register( b1 )
{
    float4x4 gView;
    float4x4 gInvView;
    float4x4 gProj;
    float4x4 gInvProj;
    float4x4 gViewProj;
    float4x4 gInvViewProj;
    float3 gEyePosW;
    float cbPerObjectPad1;
    float2 gRenderTargetSize;
    float2 gInvRenderTargetSize;
    float gNearZ;
    float gFarZ;
    float gTotalTime;
    float gDeltaTime;
};

struct VertexIn
{
    float3 PosL    : POSITION;
    float3 NormalL : NORMAL;
    float4 Color   : COLOR;
};

struct VertexOut
{
    float4 PosH    : SV_POSITION;
    float4 PosW    : POSITION;
    float4 NormalW : NORMAL;
    float4 Color   : COLOR;
};

VertexOut VS( VertexIn vin )
{
    VertexOut vout;

    // Transform to homogeneous clip space.
    vout.PosW = mul( float4( vin.PosL, 1.0f ), gWorld );
    vout.PosH = mul( vout.PosW, gViewProj );

    // Transform normal to world space.
    vout.NormalW = mul( float4( vin.NormalL, 0.0f ), gWorld );
    vout.NormalW = normalize( vout.NormalW );

    // Just pass vertex color into the pixel shader.
    vout.Color = vin.Color;

    return vout;
}

float4 PS( VertexOut pin ) : SV_Target
{
    // Static directional light.
    float3 lightDir = - normalize( float3( 1.0f, -0.5f, 0.2f ) );
    float3 lightColor = float3( 0.6f, 0.85f, 0.92f );
    // Static ambient light.
    float3 ambient = float3( 0.05f, 0.05f, 0.1f );
    // Surface material.
    float3 diffuse = pin.Color.rgb;
    // Lambert Diffuse.
    float lambert = clamp( dot( lightDir, pin.NormalW.xyz ), 0.0f, 1.0f );
    // Blinn-Phong Specular.
    float3 viewDir = normalize( gEyePosW.xyz - pin.PosW.xyz );
    float3 halfway = normalize( viewDir + lightDir );
    float blinnphong = pow( clamp( dot( halfway, pin.NormalW.xyz ), 0.0f, 1.0f ), 20.0f );
    // Final color.
    float4 finalColor = float4( 0.0f, 0.0f, 0.0f, pin.Color.a );
    finalColor.rgb = ambient + diffuse * lambert * lightColor + diffuse * 0.8f * blinnphong * lightColor * gSpecularPower;
    return finalColor;
}


