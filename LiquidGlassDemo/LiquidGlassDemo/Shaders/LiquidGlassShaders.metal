//
//  LiquidGlassShaders.metal
//  LiquidGlassDemo
//
//  Metal shaders for Liquid Glass effects
//  Includes noise, blur, and refraction shaders
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// MARK: - Noise Functions

float hash(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(float2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    
    return value;
}

// MARK: - Liquid Glass Noise Shader
// Creates subtle animated noise texture for glass surface

[[ stitchable ]] half4 liquidGlassNoise(
    float2 position,
    half4 color,
    float time,
    float2 size
) {
    float2 uv = position / size;
    
    // Multi-layer noise for organic look
    float n1 = fbm(uv * 8.0 + time * 0.1, 4);
    float n2 = fbm(uv * 16.0 - time * 0.15, 3);
    float n3 = fbm(uv * 32.0 + time * 0.05, 2);
    
    float combined = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;
    
    // Subtle grain effect
    half grain = half(combined * 0.15 + 0.85);
    
    return half4(grain, grain, grain, 1.0);
}

// MARK: - Metaball Distance Field Shader
// Renders smooth metaball blobs

[[ stitchable ]] half4 metaballField(
    float2 position,
    half4 color,
    float2 size,
    float4 ball1,  // x, y, radius, _
    float4 ball2,
    float4 ball3,
    float4 ball4,
    float4 colors1,  // r, g, b, a for ball 1
    float4 colors2,
    float4 colors3,
    float4 colors4,
    float threshold
) {
    float2 uv = position;
    
    // Calculate field value from each metaball
    float field = 0.0;
    float4 blendedColor = float4(0.0);
    
    // Ball 1
    float2 d1 = uv - ball1.xy;
    float dist1 = dot(d1, d1);
    float contrib1 = (ball1.z * ball1.z) / max(dist1, 0.0001);
    field += contrib1;
    blendedColor += colors1 * contrib1;
    
    // Ball 2
    float2 d2 = uv - ball2.xy;
    float dist2 = dot(d2, d2);
    float contrib2 = (ball2.z * ball2.z) / max(dist2, 0.0001);
    field += contrib2;
    blendedColor += colors2 * contrib2;
    
    // Ball 3
    float2 d3 = uv - ball3.xy;
    float dist3 = dot(d3, d3);
    float contrib3 = (ball3.z * ball3.z) / max(dist3, 0.0001);
    field += contrib3;
    blendedColor += colors3 * contrib3;
    
    // Ball 4
    float2 d4 = uv - ball4.xy;
    float dist4 = dot(d4, d4);
    float contrib4 = (ball4.z * ball4.z) / max(dist4, 0.0001);
    field += contrib4;
    blendedColor += colors4 * contrib4;
    
    // Normalize color
    if (field > 0.0) {
        blendedColor /= field;
    }
    
    // Smooth threshold with anti-aliasing
    float alpha = smoothstep(threshold * 0.8, threshold * 1.2, field);
    
    return half4(half3(blendedColor.rgb), half(alpha * blendedColor.a));
}

// MARK: - Glass Refraction Shader
// Simulates light refraction through glass

[[ stitchable ]] half4 glassRefraction(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float time,
    float refractionStrength
) {
    float2 uv = position / size;
    
    // Animated distortion
    float distortX = sin(uv.y * 10.0 + time) * refractionStrength;
    float distortY = cos(uv.x * 10.0 + time * 0.7) * refractionStrength;
    
    float2 distortedUV = position + float2(distortX, distortY);
    
    // Sample the layer with distortion
    half4 sampledColor = layer.sample(distortedUV);
    
    // Add subtle chromatic aberration
    float2 redOffset = distortedUV + float2(refractionStrength * 0.5, 0);
    float2 blueOffset = distortedUV - float2(refractionStrength * 0.5, 0);
    
    half4 redSample = layer.sample(redOffset);
    half4 blueSample = layer.sample(blueOffset);
    
    return half4(
        redSample.r,
        sampledColor.g,
        blueSample.b,
        sampledColor.a
    );
}

// MARK: - Specular Highlight Shader
// Dynamic specular highlights based on touch position

[[ stitchable ]] half4 specularHighlight(
    float2 position,
    half4 color,
    float2 size,
    float2 lightPosition,
    float intensity
) {
    float2 uv = position / size;
    float2 lightUV = lightPosition / size;
    
    // Calculate distance to light
    float dist = distance(uv, lightUV);
    
    // Specular falloff
    float specular = pow(max(0.0, 1.0 - dist * 2.0), 3.0) * intensity;
    
    // Add rim lighting effect
    float rim = pow(1.0 - abs(uv.y - 0.5) * 2.0, 2.0) * 0.3;
    
    half highlight = half(specular + rim);
    
    return color + half4(highlight, highlight, highlight, 0.0);
}

// MARK: - Gaussian Blur Approximation
// Fast blur for glass background

[[ stitchable ]] half4 fastBlur(
    float2 position,
    SwiftUI::Layer layer,
    float radius
) {
    half4 color = half4(0.0);
    float total = 0.0;
    
    // 9-tap blur kernel
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            float2 offset = float2(float(x), float(y)) * radius;
            float weight = 1.0 / (1.0 + length(offset));
            color += layer.sample(position + offset) * weight;
            total += weight;
        }
    }
    
    return color / total;
}
