#version 330

#moj_import <dokucraft:config.glsl>
#moj_import <minecraft:fog.glsl>

#ifdef ENABLE_CUSTOM_SKY
  #moj_import <minecraft:utils.glsl>
#endif

uniform vec4 ColorModulator;
uniform vec4 FogColor;

#ifdef ENABLE_CUSTOM_SKY
  uniform mat4 ModelViewMat;
  uniform mat4 ProjMat;
  uniform vec2 ScreenSize;

  in mat4 ProjInv;
  in float isSky;
  flat in int isStars;
#else
  uniform float FogStart;
  uniform float FogEnd;
#endif

in float vertexDistance;

out vec4 fragColor;

void main() {
  #ifdef ENABLE_CUSTOM_SKY
    gl_FragDepth = gl_FragCoord.z;
    int index = inControl(gl_FragCoord.xy, ScreenSize.x);
    if (index != -1) {
      gl_FragDepth = 1.0;
      if (isSky > 0.5) {
        if (index >= 5 && index <= 15) {
          int c = (index - 5) / 4;
          int r = (index - 5) - c * 4;
          c = (c == 0 && r == 1) ? c : c + 1;
          fragColor = vec4(encodeFloat(ProjMat[c][r]), 1.0);
        } else if (index >= 16 && index <= 24) {
          int c = (index - 16) / 3;
          int r = (index - 16) - c * 3;
          fragColor = vec4(encodeFloat(ModelViewMat[c][r]), 1.0);
        } else if (index >= 3 && index <= 4) {
          fragColor = vec4(encodeFloat(atan(ProjMat[index - 3][index - 3])), 1.0);
        } else if (index == 25) {
          fragColor = FogColor;
        } else if (index == 26) {
          fragColor = vec4(0);
        } else if (index == 27) {
          fragColor = vec4(ColorModulator.rgb, 1);
        } else {
          fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }
      } else {
        discard;
      }
    } else if (isStars == 1) {
      #ifdef DISABLE_CORE_STARS
        discard;
      #else
        fragColor = vec4(0.522, 0.678, 0.871, ColorModulator.a);
      #endif
    } else if (isSky > 0.5) {
      vec4 screenPos = gl_FragCoord;
      screenPos.xy = (screenPos.xy / ScreenSize - vec2(0.5)) * 2.0;
      screenPos.zw = vec2(1.0);
      vec3 view = normalize((ProjInv * screenPos).xyz);
      float ndusq = clamp(dot(view, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);
      ndusq = ndusq * ndusq;

      fragColor = linear_fog(ColorModulator, pow(1.0 - ndusq, 8.0), 0.0, 1.0, FogColor);
      fragColor.a = 0.0;
    } else {
      // if (vertexDistance < 800) { // Disables the void plane
      //   discard;
      // }
      fragColor = ColorModulator;
    }
  #else
    fragColor = linear_fog(ColorModulator, vertexDistance, FogStart, FogEnd, FogColor);
  #endif
}
