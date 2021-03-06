shader_version
var_precision

layout(location = 0) inattr vec2 vertex_pos;
layout(location = 1) inattr vec2 texcoord;
outvar vec2 f_texcoord;
uniform mat4 mvp_matrix;

void main(void) {
  gl_Position = mvp_matrix * vec4(vertex_pos, 0.0, 1.0);
  f_texcoord = texcoord;
}