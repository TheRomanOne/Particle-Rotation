// Experimenting with rotation matrices and a split screen.
// Use mouse to change the position of the separation line
// on the screen.
// Number of particles is gridSize³, so feel free to change it
//
// Special thanks to BigWIngs


#define PI 3.141592654



float gridSize = 8.;



struct Globals
{
    vec3 origin;
    vec3 rd;
    vec3 lookAt;
};

Globals globals;

float getDistance(vec3 point)
{
    return length(cross(point - globals.origin, globals.rd))/length(globals.rd);
}

float drawSphere(vec3 point, float radius, float y)
{
    float dis = getDistance(point);
    float scale = 1. + 0.5*cos(iTime*y * 5.5);
    return smoothstep(radius, radius - scale,dis ); 
}

void init(vec2 uv, vec3 lookAt)
{
    globals.lookAt = lookAt;
    globals.origin = vec3(0, 0, -70.);
    vec3 camZ = normalize(globals.lookAt - globals.origin);
    vec3 camX = normalize(cross(vec3(0,1,0), camZ));
    vec3 camY = cross(camZ, camX);
    vec3 newuv = vec3(uv, 0.);
    globals.rd = normalize(newuv.x * camX + newuv.y * camY + camZ);
}

mat4 rotateX(float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    
    return mat4(
        1, 0, 0, 0,
        0, c,-s, 0,
        0, s, c, 0,
        0, 0, 0, 1
    );
}

mat4 rotateY(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    
    return mat4(
        c, 0, s, 0,
        0, 1, 0, 0,
       -s, 0, c, 0,
        0, 0, 0, 1
    );
}

mat4 rotateZ(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    
    return mat4(
        c,-s, 0, 0,
        s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    );
}

mat4 translateXYZ(float x, float y, float z)
{
    return mat4(
            1, 0, 0, x,
            0, 1, 0, y,
            0, 0, 1, z,
            0, 0, 0, 1
        );
}

vec3 mat4Vec3(mat4 m, vec3 v)
{
    return (m * vec4(v, 1.)).xyz;   
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy / iResolution.xy) - 0.5;
    uv.y *= iResolution.y/iResolution.x;
    vec3 col = vec3(0.);
    float t = (iTime + 14.1)/ 3.;
    
    float interval = 20. * (1. + sin(t));
    float sphereSize = .9 - .4 * cos(t+PI/2.);
    init(uv, vec3((gridSize - 1.)* interval / 2.));
    
    vec2 mo = iMouse.xy / iResolution.xy;
    float mouse = mo.x-.5;
    if (mo.y == 0.)
        mouse = -0.0025;
    float line = 0.005;
    
    if(uv.x > mouse && uv.x < mouse + line)
        col = vec3(1., .52, 0.7);
    else
        for(float i = 0.; i < gridSize; i++)
            for(float j = 0.; j < gridSize; j++)
                for(float k = 0.; k < gridSize; k++)
                {
                    vec3 point = vec3(
                        i*interval,
                        j*interval,
                        k*interval
                    );

                    mat4 matrixStack = mat4(1);
                    float forX, forY, forZ = 0.;
                    if(uv.x < mouse)
                    {
                        forX = j + k;
                        forY = i + k;
                        forZ = j + i;
                    }
                    
                    matrixStack *= rotateX(t + forX);
                    matrixStack *= rotateY(t + forY);
                    matrixStack *= rotateZ(t + forZ);  
                    
					point -= globals.lookAt;
                    point = mat4Vec3(matrixStack, point);
                    point += globals.lookAt;

                    vec3 c = 7.*vec3(i, j, k)/gridSize;

                    col += vec3(c*drawSphere(point, sphereSize, k));   
                }
    
    fragColor = vec4(col/2.,1.0);
}
