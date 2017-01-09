//
//  MetalMatrixUtilities.h
//  MetalSkybox
//
//  Created by cfq on 2016/12/5.
//  Copyright © 2016年 Dlodlo. All rights reserved.
//


matrix_float4x4 translation(vector_float4 t);

/// Returns random float between min and max，返回最大值和最小值之间的随机浮点数
float random_float(float min, float max);

/// Returns a vector that is orthogonal to the input vector，返回正交向量
vector_float3 vector_orthogonal(vector_float3 v);

/// Returns the identity matrix，返回单位矩阵
matrix_float4x4 matrix_identity();

/// Returns the matrix that rotates by `angle` radians about `axis`，绕(x,y,z)旋转角度的矩阵
matrix_float4x4 matrix_rotation(vector_float3 axis, float angle);

/// Returns the matrix that translates by translation vector `t` in 3D space，平移
matrix_float4x4 matrix_translation(vector_float3 t) __attribute((overloadable));

/// Returns the matrix that scales by scale vector `s` about the origin，缩放
matrix_float4x4 matrix_scale(vector_float3 s) __attribute((overloadable));

/// Returns the matrix that uniformly scales about the origin along each axis by scale factor `s`
matrix_float4x4 matrix_uniform_scale(float s);

/// Returns the matrix that performs a symmetric perspective projection with the specified
/// aspect ratio, vertical field of view (in radians), and near and far clipping planes
/**
 *  透视投影矩阵
 *
 *  @param aspect 纵横比
 *  @param fovy 垂直视场
 *  @param near 近平面
 *  @param far  远裁平面
 *  @return 透视投影矩阵
 */
matrix_float4x4 matrix_perspective_projection(float aspect, float fovy, float near, float far);

/// Returns the matrix that performs an off-centered orthographic projection with the specified
/// left, right, top and bottom clipping planes
matrix_float4x4 matrix_orthographic_projection(float left, float right, float top, float bottom);

/// Extracts the linear (upper left 3x3) portion of a matrix. The returned matrix has its
/// right-most column and row = [ 0 0 0 1 ].
matrix_float4x4 matrix_extract_linear(const matrix_float4x4 mat4x4);
