//
//  Shaders.metal
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// some common indices of refraction
constant float kEtaAir = 1.000277;
//constant float kEtaWater = 1.333;
constant float kEtaGlass = 1.5;

constant float kEtaRatio = kEtaAir / kEtaGlass;

struct Vertex
{
    packed_float4 position [[attribute(0)]];
    packed_float4 normal [[attribute(1)]];
};

struct ButtonVertex
{
    packed_float3 position;
//    packed_float4 color;
    packed_float2 st;
};

struct VertexOut {
    float4 position [[position]];
//    float4 color;
    float2 st;
};

struct ProjectedVertex
{
    float4 position [[position]];
    float4 texCoords;
};

struct Uniforms
{
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
    float4x4 normalMatrix;
    float4x4 modelViewProjectionMatrix;
    float4 worldCameraPosition;
};

// 将纹理坐标设置为立方角的模型空间位置
vertex ProjectedVertex vertex_skybox(device Vertex *vertices     [[buffer(0)]],
                                     constant Uniforms &uniforms [[buffer(1)]],
                                     uint vid                    [[vertex_id]])
{
    float4 position = vertices[vid].position;
    
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * position;
    outVert.texCoords = position;
    return outVert;
}


// 添加纹理顶点坐标
vertex VertexOut texture_vertex(uint vid[[vertex_id]],
                                const device ButtonVertex *vertex_array[[buffer(0)]],
                                constant Uniforms &uniforms [[buffer(1)]])
{
    VertexOut outVertex;
    ButtonVertex vertexIn = vertex_array[vid];
    outVertex.position = uniforms.modelViewProjectionMatrix * float4(vertexIn.position, 1.0);
    outVertex.st = vertexIn.st;
//    outVertex.color = vertexIn.color;
    return outVertex;
};


fragment float4 texture_fragment(VertexOut inFrag[[stage_in]], texture2d<float> texas[[texture(0)]])
{
    constexpr sampler defaultSampler;
    float4 rgba = texas.sample(defaultSampler, inFrag.st).rgba;
    return rgba;
};

//fragment half4 color_fragment(VertexOut frag [[stage_in]]) {  //1
//    return half4(frag.color[0], frag.color[1], frag.color[2], frag.color[3]); //2
//}


vertex ProjectedVertex vertex_reflect(device Vertex *vertices     [[buffer(0)]],
                                      constant Uniforms &uniforms [[buffer(1)]],
                                      uint vid                    [[vertex_id]])
{
    float4 modelPosition = vertices[vid].position;
    float4 modelNormal = vertices[vid].normal;
    
    float4 worldCameraPosition = uniforms.worldCameraPosition;
    float4 worldPosition = uniforms.modelMatrix * modelPosition;
    float4 worldNormal = normalize(uniforms.normalMatrix * modelNormal);
    float4 worldEyeDirection = normalize(worldPosition - worldCameraPosition);
    
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * modelPosition;
    outVert.texCoords = reflect(worldEyeDirection, worldNormal);
    
    return outVert;
}

vertex ProjectedVertex vertex_refract(device Vertex *vertices     [[buffer(0)]],
                                      constant Uniforms &uniforms [[buffer(1)]],
                                      uint vid                    [[vertex_id]])
{
    float4 modelPosition = vertices[vid].position;
    float4 modelNormal = vertices[vid].normal;
    
    float4 worldCameraPosition = uniforms.worldCameraPosition;
    float4 worldPosition = uniforms.modelMatrix * modelPosition;
    float4 worldNormal = normalize(uniforms.normalMatrix * modelNormal);
    float4 worldEyeDirection = normalize(worldPosition - worldCameraPosition);
    
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * modelPosition;
    outVert.texCoords = refract(worldEyeDirection, worldNormal, kEtaRatio);
    
    return outVert;
}

fragment half4 fragment_cube_lookup(ProjectedVertex vert          [[stage_in]],
                                    constant Uniforms &uniforms   [[buffer(0)]],
                                    texturecube<half> cubeTexture [[texture(0)]],
                                    sampler cubeSampler           [[sampler(0)]])
{
    float3 texCoords = float3(vert.texCoords.x, vert.texCoords.y, -vert.texCoords.z);
    return cubeTexture.sample(cubeSampler, texCoords);
}

