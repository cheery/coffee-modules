include /catalog/classicnoise4D.glsl
generic
    varying vec2 vposition;
VERTEX_SHADER
    attribute vec2 position;

    void main() {
        vposition   = position;
        gl_Position = vec4(position, 0.0, 1.0);
    }
FRAGMENT_SHADER
    uniform float time;
    uniform vec2 resolution;
    uniform vec2 scroll;
    void main() {
        vec2 vp = ((vposition-vec2(-1.0, 1.0))*resolution*0.5 - scroll)*0.001;
        float a = cnoise(vec4(vp*2.0, 0.0, time/1000.0));
        float b = cnoise(vec4(vp*3.0, 0.0, time/800.0));
        float c = cnoise(vec4(vp*400.0, 0.0, time/8.0));
        float d = cnoise(vec4(vp*200.0, 0.0, time/2.0));
        gl_FragColor = vec4(a+b, a/(b-c*0.01), b*b/(a-d*0.02), 1.0);
    }
