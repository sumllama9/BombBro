local s = {}

s.darken = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        float fade = 0.75;

        pixel.a = pixel.a * fade;


    return color * pixel.a;
    }
]]


return s