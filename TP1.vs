//Broillet Virgile TP1

// Rotation matrix around z axis
// a : Angle
mat3 Rz(float a)
{
  float sa=sin(a);float ca=cos(a);
  return mat3(ca,sa,0.,-sa,ca,0.,0.,0.,1.);
}

// Compute the ray
//      m : Mouse position
//      p : Pixel
// ro, rd : Ray origin and direction
void Ray(vec2 m,vec2 p,out vec3 ro,out vec3 rd)
{
  float a=3.*3.14*m.x;
  float le=3.5;
  
  // Origin
  ro=vec3(60.,0.,0.);
  ro*=Rz(a);
  
  // Target point
  vec3 ta=vec3(0.,0.,0.); // modifier les coordonées pour changer la vue
  
  // Orthonormal frame
  vec3 w=normalize(ta-ro);
  vec3 u=normalize(cross(w,vec3(0.,0.,1.)));
  vec3 v=normalize(cross(u,w));
  rd=normalize(p.x*u+p.y*v+le*w);
}

// Operators

// Union
// a,b : field function of left and right sub-trees
float Union(float a,float b)
{
  return min(a,b);
}

float Inter(float a, float b){
    return max(a,b);
}

float Diff(float a, float b){
    return max(a, -b);
}

// Transformations

// Rotation
// p: point
// ax: axis
// angle: rotation angle 
vec3 Rotate(vec3 p, vec3 ax, float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    float t = 1.0 - c;
    
    // creation of a 3*3 rotation matrix
    mat3 rotationMatrix = mat3(
        t * ax.x * ax.x + c, t * ax.x * ax.y - s * ax.z, t * ax.x * ax.z + s * ax.y,
        t * ax.x * ax.y + s * ax.z, t * ax.y * ax.y + c,     t * ax.y * ax.z - s * ax.x,
        t * ax.x * ax.z - s * ax.y, t * ax.y * ax.z + s * ax.x, t * ax.z * ax.z + c
    );

    return rotationMatrix * p;
}

// Translation
// p: point
// translation: translation vector
vec3 Translate(vec3 p, vec3 translation)
{
    return p + translation;
}

// Homotethy
// p: point
// HomotethyFac: Scalling vector
vec3 Homotethy(vec3 p, vec3 HomotethyFac)
{
    return p * HomotethyFac;
}

// Primitives

// Sphere
// p : point
// c : center of skeleton
// r : radius
float Sphere(vec3 p,vec3 c,float r)
{
  return length(p-c)-r;
}

// Plan
// p : point
// c : center of skeleton
// n : normalise

float Plan(vec3 p, vec3 c, vec3 n){
    return dot(p-c,n);
}

// Half-Sphere
//p : point
//c : center of skeleton
//r : radius
//n : normalise

float HSphere(vec3 p, vec3 c, float r, vec3 n){
    return Inter(Sphere(p, c, r), Plan(p, c, n));
}

// cube 
// p : point
// c : center of skeleton
// r : radius 

float Cube(vec3 p, vec3 c, float r)
{
  vec3 p1 = c + vec3(r,0,0);
  vec3 p2 = c + vec3(-r,0,0);
  vec3 p3 = c + vec3(0,r,0);
  vec3 p4 = c + vec3(0,-r,0);
  vec3 p5 = c + vec3(0,0,r);
  vec3 p6 = c + vec3(0,0,-r);
  float plan1 = Plan(p, p1, vec3(1.0,0,0));
  float plan2 = Plan(p, p2, vec3(-1.0,0,0));
  float plan3 = Plan(p, p3, vec3(0,1.0,0));
  float plan4 = Plan(p, p4, vec3(0,-1.0,0));
  float plan5 = Plan(p, p5, vec3(0,0,1.0));
  float plan6 = Plan(p, p6, vec3(0,0,-1.0));
  
  float v = Inter(plan6,Inter(plan5,Inter(plan4,Inter(plan3,Inter(plan1,plan2)))));
 
  return v;
  
}

// Box (could be a cube orr a rectangle)
// p: point
// c: center of the box
// r: radius
// x: length of the box
// y: width of the box
// z: height of the box
float Box(vec3 p, vec3 c, float r, float x, float y, float z)
{
  vec3 p1 = c + vec3(r+x,0,0);
  vec3 p2 = c + vec3(-r-x,0,0);
  vec3 p3 = c + vec3(0,r+y,0);
  vec3 p4 = c + vec3(0,-r-y,0);
  vec3 p5 = c + vec3(0,0,r+z);
  vec3 p6 = c + vec3(0,0,-r-z);
  float plan1 = Plan(p, p1, vec3(1.,0,0));
  float plan2 = Plan(p, p2, vec3(-1.,0,0));
  float plan3 = Plan(p, p3, vec3(0,1.,0));
  float plan4 = Plan(p, p4, vec3(0,-1.,0));
  float plan5 = Plan(p, p5, vec3(0,0,1.));
  float plan6 = Plan(p, p6, vec3(0,0,-1.));
  
  float v = Inter(plan6,Inter(plan5,Inter(plan4,Inter(plan3,Inter(plan1,plan2)))));
  
  return v;
  
}

//tore
// p : point
// r : 
float Tore(vec3 p , vec2 r ){
    float x =length(p.xz)-r.x;
    return length(vec2(x,p.y))-r.y;
}

// Segment
// p : point
// a,b: points
float Segment(vec3 p, vec3 a, vec3 b) {
    vec3 ba = b - a;
    vec3 pa = p - a;
    float t = dot(pa, ba) / dot(ba, ba);
    vec3 c = ba * clamp(t, 0.0, 1.0);
    return length(pa - c);
}

// Capsule
// p : point
// a : point
// r : radius

float Capsule(vec3 p, vec3 a, vec3 b, float r) {

    return Segment(p, a, b) - r;
}

// Cylinder
// p : point
// r : radius
float Cylinder(vec3 p, vec3 a, vec3 b, float r) {

    float v = max(Capsule(p, a, b, r),
                  -dot(p-b, normalize(a-b)));

    v = max(v, -dot(p-a, normalize(b-a)));
    return v;
}

//pyramide base carre
// h : hauteur 
// 
float Pyramide (vec3 p, vec3 c, float h, float epx, float epy, float epz)
{
    float v = max(Plan(p,c, vec3(0., h, dot(h, epx))), 
              max(Plan(p,c, vec3(0., -h, dot(h, epx))),
              max(Plan(p,c, vec3(h, 0., dot(h, epy))),
              max(Plan(p,c, vec3(-h, 0., dot(h, epy))),
                  Plan(p, vec3(0, 0, epz),vec3(0, 0, -1))))));
              
    return v;
}

//Colomn creates threes colomns for the begining of the temple
//p: point
//r: radius
float Colomn(vec3 p, vec3 a, vec3 b, float r){
    float cyl0 = Cylinder(p, vec3(a.x+15., a.y, a.z), vec3(b.x+15., b.y, b.z), r);
    float cyl1 = Cylinder(p, vec3(a.x+12.5, a.y, a.z), vec3(b.x+12.5, b.y, b.z), r);
    float cyl2 = Cylinder(p, vec3(a.x+10., a.y, a.z), vec3(b.x+10., b.y, b.z), r);
    float cyl3 = Cylinder(p, vec3(a.x+7.5, a.y, a.z), vec3(b.x+7.5, b.y, b.z), r);
    float cyl4 = Cylinder(p, vec3(a.x+5., a.y, a.z), vec3(b.x+5., b.y, b.z), r);
    float cyl5 = Cylinder(p, vec3(a.x+2.5, a.y, a.z), vec3(b.x+2.5, b.y, b.z), r);
    float cyl6 = Cylinder(p, vec3(a.x, a.y, a.z), vec3(b.x, b.y, b.z), r);
    float cyl7 = Cylinder(p, vec3(a.x-2.5, a.y, a.z), vec3(b.x-2.5, b.y, b.z), r);
    float cyl8 = Cylinder(p, vec3(a.x-5., a.y, a.z), vec3(b.x-5., b.y, b.z), r);
    
    float BigColomn0 = Cylinder(p, vec3(a.x+5., a.y-5., a.z+10.), vec3(b.x+5., b.y-6., b.z+9.), r+0.2);
    float BigColomn1 = Cylinder(p, vec3(a.x+8.5, a.y-8., a.z+10.), vec3(b.x+7.5, b.y-8., b.z+9.), r+0.2);
    float BigColomn2 = Cylinder(p, vec3(a.x+1.5, a.y-8., a.z+10.), vec3(b.x+2.5, b.y-8., b.z+9.), r+0.2);
    float BigColomn3 = Cylinder(p, vec3(a.x+5., a.y-12., a.z+10.), vec3(b.x+5., b.y-11., b.z+9.), r+0.2);


   
    return Union(Union(Union(Union(Union(Union(Union(Union(Union(Union(Union(Union( BigColomn3, BigColomn2), BigColomn1), BigColomn0), cyl8), cyl6), cyl7),cyl4), cyl5) ,cyl0), cyl1), cyl2), cyl3);

}


// Create Fences on the 9 colomns building
//p :point
//cBody: center of the body
//FBar: Fisrt bar
//MBar: Middle bar
//LBar: Last Bar
//LSphere: Sphere on the left of the body
//RSphere: Sphere on the right of the body
//h :hight of the fence
float Fence(vec3 p, vec3 cBody, vec3 FBar, vec3 MBar, vec3 LBar, vec3 LSphere, vec3 RSphere, float h){
    
    vec3 PointRotate =  Rotate(vec3(p.x,p.y,p.z), vec3(0.0,0.0,1.0), 1.570796326795);
    
    float LeftSphere = Sphere(p, LSphere, 0.5);
    float RightSphere = Sphere(p, RSphere, 0.5);
    float bar0 = Box(p, FBar, 3., -2.8, -2.8, h);
    float bar1 = Box(p, MBar, 3., -2.8, -2.8, h);
    float bar2 = Box(p, LBar, 3., -2.8, -2.8, h);
    
    float bars = Union(Union(bar0, bar1), bar2);
    
    float body0 = Union(bars, Diff(Box(PointRotate, cBody, 3., -2.7, 0., h), 
                    Box(PointRotate, cBody, 2.5, 1., -0.1, h*0.9)));    
        
        
    float fence = Union(Union(body0, RightSphere), LeftSphere);
    
    return fence;
}

//Planet earth composed of continents
// p: point
// c: center of the earth
float PlanetEarth(vec3 p, vec3 c)
{
    float Planet = Sphere(vec3(p.x-4.95, p.y+8.5, p.z-20.), c, 8.);
    float NorthAM = Box(Rotate(vec3(p.x-9., p.y+8.5, p.z-24.), vec3(0.0,1.0,0.0), 0.7853981633974), c, 2.3, 0., 1., 0.);
    float Mexico = Box(Rotate(vec3(p.x-12., p.y+9.5, p.z-21.), vec3(0.0,1.0,0.25), 1.5), c, 1., 1., 0., 0.);
    float SouthAM = Box(Rotate(vec3(p.x-10.5, p.y+8.5, p.z-18.), vec3(0.0,1.0,0.10), -1.1), c, 2., 1.5, 0., 0.);
    float Europe = Box(Rotate(vec3(p.x-5., p.y+3., p.z-24.), vec3(1.0,0.0,0.10), 0.5), c, 0.2, 1.5, 1.5, 1.5);
    float AfricaPt1 = Box(Rotate(vec3(p.x-5.5, p.y+2.2, p.z-20.5), vec3(1.0,0.0,0.10), -0.1), c, 0.3, 2.5, 1.5, 1.5);
    float AfricaPt2 = Box(Rotate(vec3(p.x-4.5, p.y+2.4, p.z-18.5), vec3(1.0,0.0,0.10), -0.1), c, 0.3, 1.5, 1.5, 2.5);
    float Russia = Box(Rotate(vec3(p.x-1.5, p.y+7., p.z-25.), vec3(0.0,1.0,-0.5), 0.78), c, 0.3, 1.5, 4.5, 2.5);
    float Asia = Box(Rotate(vec3(p.x-1., p.y+7., p.z-21.), vec3(0.0,1.0,0.5), -0.), c, 0.3, 1.5, 4.5, 2.5);

    
    return Union(Union(Union(Union(Union(Union(Union(Union(Asia, Russia), AfricaPt2), AfricaPt1), Europe), SouthAM), Mexico), NorthAM), Planet);
}

// The Temple Structur
//p : point
float Temple(vec3 p){
    float colomn = Colomn(p, vec3(0.0,0.0,3.5), vec3(0.0,0.0,-6.0), 0.5);
    float BackBox = Box(p, vec3(5,-12.5,-2), 2., 8.7, 6., 3.);
    float UpBox = Box(p, vec3(5,-10.,3), 0.5, 10., 10., 0.001);
    float FloorBox = Box(p, vec3(5,-10.,-6.5), 0.5, 10., 10., 0.001);
    float LastStep = Box(p, vec3(5,-10.,-7.2), 0.5, 10., 11., 0.001);
    float MiddleStep = Box(p, vec3(5,-10.,-8.2), 0.5, 10., 12., 0.001);
    float FirstStep = Box(p, vec3(5,-10.,-9.2), 0.5, 10., 13., 0.001);
    // Using of the Rotate Function here 1.570796326795 is the radian of 90°
    float BorderSphere = Tore(Rotate(vec3(p.x-4.95, p.y+8.5, p.z-13.), vec3(1.0, 0.0, 0.0), 1.570796326795), vec2(4., 1.));
    float PlanetEarth = PlanetEarth(p, vec3(0.0,0.0,0.0));
    float fence0 = Fence(p, vec3(0,2.5,5), vec3(-1.2,0,5), vec3(-2.5,0,5), vec3(-3.8,0,5), vec3(0,0.,6.8), vec3(-5.2,0.,6.8), -1.6);
    float fence1 = Fence(p, vec3(0,-2.5,5), vec3(3.9,0,5), vec3(2.6,0,5), vec3(1.3,0,5), vec3(5,0.,6.8), vec3(-0.1,0.,6.8), -1.6);
    float fence2 = Fence(p, vec3(0,-7.5,5), vec3(9.,0,5), vec3(7.7,0,5), vec3(6.4,0,5), vec3(10,0.,6.8), vec3(5,0.,6.8), -1.6);
    float fence3 = Fence(p, vec3(0,-12.5,5), vec3(14.1,0,5), vec3(12.8,0,5), vec3(11.5,0,5), vec3(15.2,0.,6.8), vec3(0,0.,6.8), -1.6);


    float fences = Union(Union(Union(fence3, fence2), fence0), fence1);
    
    return Union(Union(Union(Union(Union(Union(Union(Union(Union(fences, PlanetEarth), BorderSphere), FirstStep), MiddleStep),LastStep), FloorBox), colomn), UpBox), BackBox);
}

// Potential field of the object
// p : point
float object(vec3 p)
{
  float cube = Cube(p, vec3(1.0,-1.0,-1.0), 4.);
  float sphere = Sphere(p, vec3(0.0,0.0,0.0), 4.);
  float plan = Plan(p,vec3(0.,0.,-9.5),vec3(0.0,0.0,1.));
  float HSphere = HSphere(p, vec3(0., 3., 3.), 2., vec3(0.0,0.0,1.));
  float tore = Tore(p, vec2(3.0, 1.0));
  float temple = Temple(p);

  float final = Union(temple, plan);
  
  return final;
}

// Analysis of the scalar field

const int Steps=200;// Number of steps
const float Epsilon=.01;// Marching epsilon

// Object normal
// p : point
vec3 ObjectNormal(vec3 p)
{
  const float eps=.001;
  vec3 n;
  float v=object(p);
  n.x=object(vec3(p.x+eps,p.y,p.z))-v;
  n.y=object(vec3(p.x,p.y+eps,p.z))-v;
  n.z=object(vec3(p.x,p.y,p.z+eps))-v;
  return normalize(n);
}

// Trace ray using ray marching
// o : ray origin
// u : ray direction
// e : Maximum distance
// h : hit
// s : Number of steps
float SphereTrace(vec3 o,vec3 u,float e,out bool h,out int s)
{
  h=false;
  
  // Start at the origin
  float t=0.;
  
  for(int i=0;i<Steps;i++)
  {
    s=i;
    vec3 p=o+t*u;
    float v=object(p);
    // Hit object
    if(v<0.)
    {
      h=true;
      break;
    }
    // Move along ray
    t+=max(Epsilon,v);
    // Escape marched too far away
    if(t>e)
    {
      break;
    }
  }
  return t;
}

// Lighting

// Background color
// d : Ray direction
vec3 background(vec3 d)
{
  return mix(vec3(.45,.55,.99),vec3(.65,.69,.99),d.z*.5+.5);
}

// Shadowing
// p : Point
// n : Normal
// l : Light direction
float Shadow(vec3 p,vec3 n,vec3 l)
{
  bool h;
  int s;
  float t=SphereTrace(p+Epsilon*n,l,100.,h,s);
  if(!h)
  {
    return 1.;
  }
  return 0.;
}

// Shading and lighting
// p : Point
// n : Normal at point
// e : Eye direction
vec3 Shade(vec3 p,vec3 n,vec3 e)
{
  // Point light
  const vec3 lp=vec3(5.,10.,25.);
  
  // Light direction to point light
  vec3 l=normalize(lp-p);
  
  // Ambient color
  vec3 ambient=.25+.25*background(n);
  
  // Shadow computation
  float shadow=Shadow(p,n,l);
  
  // Phong diffuse
  vec3 diffuse=.35*clamp(dot(n,l),0.,1.)*vec3(1.,1.,1.);
  
  // Specular
  vec3 r=reflect(e,n);
  vec3 specular=.15*pow(clamp(dot(r,l),0.,1.),35.)*vec3(1.,1.,1.);
  vec3 c=ambient+shadow*(diffuse+specular);
  return c;
}

// Shading according to the number of steps in sphere tracing
// n : Number of steps
vec3 ShadeSteps(int n)
{
  float t=float(n)/(float(Steps-1));
  return.5+mix(vec3(.05,.05,.5),vec3(.65,.39,.65),t);
}

// Picture in picture
// pixel : Pixel
// pip : Boolean, true if pixel was in sub-picture zone
vec2 Pip(in vec2 pixel,out bool pip)
{
  // Pixel coordinates
  vec2 p=(-iResolution.xy+2.*pixel)/iResolution.y;
  if(pip==true)
  {
    const float fraction=1./4.;
    // Recompute pixel coordinates in sub-picture
    if((pixel.x<iResolution.x*fraction)&&(pixel.y<iResolution.y*fraction))
    {
      p=(-iResolution.xy*fraction+2.*pixel)/(iResolution.y*fraction);
      pip=true;
    }
    else
    {
      pip=false;
    }
  }
  return p;
}

// Image
void mainImage(out vec4 color,in vec2 pxy)
{
  // Picture in picture on
  bool pip=true;
  
  // Pixel
  vec2 pixel=Pip(pxy,pip);
  
  // Mouse
  vec2 m=iMouse.xy/iResolution.xy;
  
  // Camera
  vec3 ro,rd;
  Ray(m,pixel,ro,rd);
  
  // Trace ray
  

  // Hit and number of steps
  bool hit;
  int s;
  
  float t=SphereTrace(ro,rd,100.,hit,s);
  
  // Shade background
  vec3 rgb=background(rd);
  
  if(hit)
  {
    // Position
    vec3 p=ro+t*rd;
    
    // Compute normal
    vec3 n=ObjectNormal(p);
    
    // Shade object with light
    rgb=Shade(p,n,rd);
  }
  
  // Uncomment this line to shade image with false colors representing the number of steps
  if(pip==true)
  {
    rgb=ShadeSteps(s);
  }
  
  color=vec4(rgb,1.);
 
}

