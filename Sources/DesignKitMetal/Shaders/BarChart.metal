#include <metal_stdlib>
using namespace metal;

// ========================================
// Data Structures
// ========================================

struct BarInstance {
    float2 position;           // Base position (x, y)
    float2 size;              // Width and height
    float4 color;             // RGBA color
    float animationProgress;  // 0.0 to 1.0
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 texCoord;
};

struct Uniforms {
    float4x4 projectionMatrix;
    float2 viewportSize;
    float time;
    float cornerRadius;
};

// ========================================
// Vertex Shader
// ========================================

vertex VertexOut barVertexShader(
    uint vertexID [[vertex_id]],
    uint instanceID [[instance_id]],
    constant BarInstance* instances [[buffer(0)]],
    constant Uniforms& uniforms [[buffer(1)]]
) {
    VertexOut out;
    
    // Get bar instance data
    BarInstance bar = instances[instanceID];
    
    // Apply animation progress to height
    float2 animatedSize = bar.size;
    animatedSize.y *= bar.animationProgress;
    
    // Quad vertices (triangle strip: 0=bottom-left, 1=top-left, 2=bottom-right, 3=top-right)
    float2 quadPositions[4] = {
        float2(0.0, 0.0),              // bottom-left
        float2(0.0, 1.0),              // top-left
        float2(1.0, 0.0),              // bottom-right
        float2(1.0, 1.0)               // top-right
    };
    
    float2 quadPos = quadPositions[vertexID];
    
    // Calculate vertex position in viewport space
    float2 vertexPosition = bar.position + quadPos * animatedSize;
    
    // Convert to NDC (Normalized Device Coordinates)
    float2 ndc = (vertexPosition / uniforms.viewportSize) * 2.0 - 1.0;
    ndc.y = -ndc.y; // Flip Y for screen coordinates
    
    out.position = float4(ndc, 0.0, 1.0);
    out.color = bar.color;
    out.texCoord = quadPos;
    
    return out;
}

// ========================================
// Fragment Shader
// ========================================

fragment float4 barFragmentShader(
    VertexOut in [[stage_in]],
    constant Uniforms& uniforms [[buffer(0)]]
) {
    // Basic anti-aliased rounded corners
    float2 coord = in.texCoord;
    // Note: cornerRadius could be used for rounded corners with SDF
    (void)uniforms.cornerRadius;
    
    // Simple corner rounding (can be improved with SDF)
    float4 color = in.color;
    
    // Optional: Add subtle gradient
    float gradientFactor = mix(1.0, 0.9, coord.y);
    color.rgb *= gradientFactor;
    
    return color;
}

// ========================================
// Line Chart Shaders
// ========================================

struct LineVertexInput {
    float2 position;
    float4 color;
    float thickness;
};

struct LineVertexOutput {
    float4 position [[position]];
    float4 color;
    float2 uv;
    float thickness;
};

vertex LineVertexOutput lineVertexShader(
    uint vertexID [[vertex_id]],
    constant LineVertexInput* vertices [[buffer(0)]],
    constant Uniforms& uniforms [[buffer(1)]]
) {
    LineVertexOutput out;
    
    LineVertexInput vert = vertices[vertexID];
    
    // Convert to NDC
    float2 ndc = (vert.position / uniforms.viewportSize) * 2.0 - 1.0;
    ndc.y = -ndc.y;
    
    out.position = float4(ndc, 0.0, 1.0);
    out.color = vert.color;
    out.thickness = vert.thickness;
    
    return out;
}

fragment float4 lineFragmentShader(
    LineVertexOutput in [[stage_in]]
) {
    return in.color;
}

// ========================================
// Compute Shader for Line Smoothing
// ========================================

struct Point2D {
    float2 position;
};

kernel void smoothLinePoints(
    constant Point2D* inputPoints [[buffer(0)]],
    device Point2D* outputPoints [[buffer(1)]],
    constant uint& pointCount [[buffer(2)]],
    constant float& tension [[buffer(3)]],
    uint gid [[thread_position_in_grid]]
) {
    // Catmull-Rom spline interpolation
    if (gid >= pointCount - 1) return;
    
    uint i = gid;
    
    // Get control points
    float2 p0 = (i > 0) ? inputPoints[i - 1].position : inputPoints[i].position;
    float2 p1 = inputPoints[i].position;
    float2 p2 = inputPoints[i + 1].position;
    float2 p3 = (i < pointCount - 2) ? inputPoints[i + 2].position : inputPoints[i + 1].position;
    
    // Catmull-Rom calculation (t = 0.5 for midpoint)
    float t = 0.5;
    float t2 = t * t;
    float t3 = t2 * t;
    
    float2 result = 0.5 * (
        (2.0 * p1) +
        (-p0 + p2) * t +
        (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
        (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
    );
    
    outputPoints[gid].position = mix(p1, result, tension);
}

// ========================================
// Gradient Shader for Area Charts
// ========================================

struct GradientVertexInput {
    float2 position;
    float gradientPosition; // 0.0 = top, 1.0 = bottom
};

struct GradientVertexOutput {
    float4 position [[position]];
    float gradientPosition;
};

vertex GradientVertexOutput gradientVertexShader(
    uint vertexID [[vertex_id]],
    constant GradientVertexInput* vertices [[buffer(0)]],
    constant Uniforms& uniforms [[buffer(1)]]
) {
    GradientVertexOutput out;
    
    GradientVertexInput vert = vertices[vertexID];
    
    float2 ndc = (vert.position / uniforms.viewportSize) * 2.0 - 1.0;
    ndc.y = -ndc.y;
    
    out.position = float4(ndc, 0.0, 1.0);
    out.gradientPosition = vert.gradientPosition;
    
    return out;
}

fragment float4 gradientFragmentShader(
    GradientVertexOutput in [[stage_in]],
    constant float4& topColor [[buffer(0)]],
    constant float4& bottomColor [[buffer(1)]]
) {
    // Linear gradient from top to bottom
    float4 color = mix(topColor, bottomColor, in.gradientPosition);
    return color;
}

// ========================================
// Shimmer Shader
// ========================================

struct ShimmerRect {
    float2 position;
    float2 size;
    float shimmerOffset; // 0.0 to 1.0
};

vertex VertexOut shimmerVertexShader(
    uint vertexID [[vertex_id]],
    uint instanceID [[instance_id]],
    constant ShimmerRect* rects [[buffer(0)]],
    constant Uniforms& uniforms [[buffer(1)]]
) {
    VertexOut out;
    
    ShimmerRect rect = rects[instanceID];
    
    float2 quadPositions[4] = {
        float2(0.0, 0.0),
        float2(0.0, 1.0),
        float2(1.0, 0.0),
        float2(1.0, 1.0)
    };
    
    float2 quadPos = quadPositions[vertexID];
    float2 vertexPosition = rect.position + quadPos * rect.size;
    
    float2 ndc = (vertexPosition / uniforms.viewportSize) * 2.0 - 1.0;
    ndc.y = -ndc.y;
    
    out.position = float4(ndc, 0.0, 1.0);
    out.texCoord = quadPos;
    out.color = float4(rect.shimmerOffset, 0.0, 0.0, 0.0); // Pass shimmer offset in color.r
    
    return out;
}

fragment float4 shimmerFragmentShader(
    VertexOut in [[stage_in]],
    constant float4& baseColor [[buffer(0)]],
    constant float4& shimmerColor [[buffer(1)]]
) {
    float2 uv = in.texCoord;
    float shimmerOffset = in.color.r;
    
    // Create shimmer gradient
    float shimmerWidth = 0.3;
    float shimmerPos = shimmerOffset * (1.0 + shimmerWidth) - shimmerWidth * 0.5;
    
    float dist = abs(uv.x - shimmerPos);
    float shimmer = smoothstep(shimmerWidth, 0.0, dist);
    
    float4 color = mix(baseColor, shimmerColor, shimmer * 0.5);
    
    return color;
}

