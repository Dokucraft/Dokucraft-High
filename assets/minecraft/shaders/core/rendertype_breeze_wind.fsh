#version 150

#moj_import <fog.glsl>
#moj_import <utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 glpos;

out vec4 fragColor;

void main() {
  discardControlGLPos(gl_FragCoord.xy, glpos);
  vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
  if (color.a < 0.1) {
    discard;
  }
  fragColor = color * linear_fog_fade(vertexDistance, FogStart, FogEnd);
}
