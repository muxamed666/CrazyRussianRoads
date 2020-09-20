
/*

 Tests a single pixel that is currently rendering
 
*/

half getLightLevel(vec2 pixelCoord, vec2 carCoord, half offset, half rotation)
{
    //re-positioning of car headlights coords
    //calculates new light point position from polar coordinates
    carCoord.x += offset * cos(-1.0 * rotation);
    carCoord.y += offset * sin(-1.0 * rotation);
    
    //calculates an angle between current rendering-pixel and light source
    vec2 point = pixelCoord.xy - carCoord.xy;
    half a = atan(point.y, point.x); // a = arctg(y/x)
    
    //rotating light
    a = a + rotation;
    a = mod(a, 6.2830);
    
    //light intensity in current pixel
    half b = (sin((a)*9.0));
    
    //cut negative intensity, so dark is just dark
    if(b < 0.0) { b = 0.0; }
    
    //return intensity
    return b;
}


/*

 Darkness test. Returns true if its absolute dark

*/

bool testForDarkness(vec2 pixelCoord, vec2 carCoord, half rotation)
{
    //re-positioning of car headlights coords
    //calculates new light point position from polar coordinates
    carCoord.x += 150.0 * cos(-1.55 - rotation);
    carCoord.y += 150.0 * sin(-1.55 - rotation);
    
    //calculates an angle between current rendering-pixel and light source
    vec2 point = pixelCoord.xy - carCoord.xy;
    half a = atan(point.y, point.x); // a = arctg(y/x)
    
    //rotating light
    a = a + rotation;
    a = mod(a, 6.2830);
    
    //set up filter borders
    half angle = 1.368;
    half angle2 =  3.1415 - angle;
    
    //return false if pixel are in borders
    //otherwise return true
    if(a > angle && a < angle2)
    {
        return false;
    }
    else
    {
        return true;
    }
}


/*

 Main func of fragment shader
 
*/

void main()
{
    //v_tex_coord - current pixel coordinates in [0 .. 1]
    //tSize - viewport resolution (in pixels)
    //carPosition - car coords (xy)
    //carRotation - rotation
    
    // Normalized pixel coordinates
    vec2 currentPixel = v_tex_coord;
    
    //RGBA of texture pixel
    vec4 originalColor = texture2D(u_texture, currentPixel);
    vec4 newColor = originalColor;
    
    //coords convert from [0 .. 1] to number of pixels
    vec2 coords_xy = v_tex_coord * tSize;
    
    //test for darkness
    if (testForDarkness(coords_xy, carPosition, carRotation))
    {
        //its dark, so no more calculations
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.86);
        return 0;
    }
    
    //get light for two sources (headlights)
    half l = getLightLevel(coords_xy, carPosition, -30.0, carRotation);
    half r = getLightLevel(coords_xy, carPosition, 30.0, carRotation);
    
    //change intense and sum
    l *= 0.9;
    r *= 0.8;
    half n = l+r; //sum it
   
    //get new pixel value
    newColor = newColor * vec4(n/4.0, n/4.0, n/5.0, (0.86-n)); //yellow + alpha
    
    //some alpha cut to 0.0-1.0
    if (newColor.w > 1.0) { newColor.w = 1.0; }
    if (newColor.w < 0.0) { newColor.w = 0.0; }
    
    //Set attenuation
    if (newColor.w < 0.85) { newColor.w += (v_tex_coord.y * 0.86); }
    if (newColor.w > 0.86) { newColor.w = 0.86; }
    
    // Output to screen
    gl_FragColor = newColor;
}

