((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,D={aKV:function aKV(d,e,f,g,h,i,j,k){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.r=h
_.w=i
_.x=j
_.y=k
_.z=null
_.a=!1},
bY3(d,e,f){var x,w,v,u,t,s,r
if(d==e)return d
if(d==null)return e.bo(0,f)
if(e==null)return d.bo(0,1-f)
x=A.bQS(d.a,d.qk(),e.a,e.qk(),f)
w=A.ri(d.d,e.d,f)
w.toString
v=A.aj(d.e,e.e,f)
v.toString
v=Math.max(0,v)
u=f<0.5
t=u?d.f:e.f
s=A.ri(d.r,e.r,f)
r=A.aj(d.w,e.w,f)
r.toString
r=Math.max(0,r)
u=u?d.c:e.c
return new D.vE(w,v,t,s,r,x.a,x.b,u)},
vE:function vE(d,e,f,g,h,i,j,k){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.a=i
_.b=j
_.c=k},
b_b:function b_b(d){this.a=d}},C
J=c[1]
A=c[0]
B=c[2]
D=a.updateHolder(c[11],D)
C=c[29]
D.aKV.prototype={
gVr(){var x,w,v,u,t,s,r,q,p,o,n=this,m=null,l=n.z
if(l==null){x=A.bQJ(n.e)
w=new Float32Array(A.ik(n.f))
l=n.x
if(l!=null)v=l.k(0,n.c)&&n.y===0
else v=!0
u=n.c
t=n.d
s=n.r
r=n.w
q=u.a
u=u.b
if(v){$.an()
l=new A.Bm()
v=$.c1.cp().Shader
u=A.aAu(q,u)
q=A.bLO(w)
s=A.aAR(s)
r=r!=null?A.aAQ(r):m
l.a=A.iG(v,"MakeRadialGradient",[u,t,x,q,s,r==null?m:r,0])
$.aB9().lv(n,l,l)
n.z=l}else{$.an()
v=l.a
l=l.b
p=new A.Bm()
o=$.c1.cp().Shader
l=A.aAu(v,l)
u=A.aAu(q,u)
q=A.bLO(w)
s=A.aAR(s)
v=r!=null?A.aAQ(r):m
if(v==null)v=m
p.a=A.iG(o,"MakeTwoPointConicalGradient",[l,n.y,u,t,x,q,s,v,0])
$.aB9().lv(n,p,p)
n.z=p
l=p}}return l}}
D.vE.prototype={
vV(d,e,f){var x,w=this,v=w.d.a4(f).Gr(e),u=e.ghn(),t=w.a,s=w.qk(),r=w.TX(e,f),q=w.r
q=q==null?null:q.a4(f).Gr(e)
x=e.ghn()
A.bR7(t,s)
r=r!=null?A.wY(r):null
return new D.aKV(v,w.e*u,t,s,w.f,r,q,w.w*x)},
e1(d,e){return this.vV(0,e,null)},
bo(d,e){var x=this,w=x.a,v=A.T(w).h("J<1,I>")
w=A.Q(new A.J(w,new D.b_b(e),v),v.h("az.E"))
return new D.vE(x.d,x.e,x.f,x.r,x.w,w,x.b,x.c)},
M6(d){var x=this
return new D.vE(x.d,x.e,x.f,x.r,x.w,A.bJ(x.a.length,d,!1,y.o),x.b,x.c)},
eP(d,e){if(y.a.b(d))return D.bY3(d,this,e)
return this.PG(d,e)},
eH(d,e){if(y.a.b(d))return D.bY3(this,d,e)
return this.PH(d,e)},
k(d,e){var x=this
if(e==null)return!1
if(x===e)return!0
if(J.ar(e)!==A.F(x))return!1
return e instanceof D.vE&&e.d.k(0,x.d)&&e.e===x.e&&e.f===x.f&&J.f(e.c,x.c)&&A.dR(e.a,x.a)&&A.dR(e.b,x.b)&&J.f(e.r,x.r)&&e.w===x.w},
gD(d){var x=this,w=A.cl(x.a),v=x.b
v=v==null?null:A.cl(v)
return A.Y(x.d,x.e,x.f,x.c,w,v,x.r,x.w,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a)},
j(d){var x=this,w=A.b(["center: "+x.d.j(0),"radius: "+A.kW(x.e),"colors: "+A.o(x.a)],y.h),v=x.b
if(v!=null)w.push("stops: "+A.o(v))
w.push("tileMode: "+x.f.j(0))
v=x.r
if(v!=null)w.push("focal: "+v.j(0))
w.push("focalRadius: "+A.kW(x.w))
v=x.c
if(v!=null)w.push("transform: "+v.j(0))
return"RadialGradient("+B.b.aN(w,", ")+")"}}
var z=a.updateTypes([])
D.b_b.prototype={
$1(d){var x=A.W(null,d,this.a)
x.toString
return x},
$S:82};(function inheritance(){var x=a.inherit
x(D.aKV,A.a9s)
x(D.vE,A.Rk)
x(D.b_b,A.hE)})()
var y={o:A.a6("I"),h:A.a6("z<c>"),a:A.a6("vE?")};(function constants(){C.ED=new A.a2(16,0,16,16)
C.a4r=new A.I(1,1,0.9725490196078431,0.8823529411764706,B.m)
C.a5p=new A.I(1,1,0.9254901960784314,0.7019607843137254,B.m)
C.a5h=new A.I(1,1,0.8784313725490196,0.5098039215686274,B.m)
C.a5f=new A.I(1,1,0.8352941176470589,0.30980392156862746,B.m)
C.a5O=new A.I(1,1,0.792156862745098,0.1568627450980392,B.m)
C.a4y=new A.I(1,1,0.7568627450980392,0.027450980392156862,B.m)
C.a5N=new A.I(1,1,0.7019607843137254,0,B.m)
C.a4K=new A.I(1,1,0.6274509803921569,0,B.m)
C.a5k=new A.I(1,1,0.5607843137254902,0,B.m)
C.a4O=new A.I(1,1,0.43529411764705883,0,B.m)
C.arl=new A.cL([50,C.a4r,100,C.a5p,200,C.a5h,300,C.a5f,400,C.a5O,500,C.a4y,600,C.a5N,700,C.a4K,800,C.a5k,900,C.a4O],A.a6("cL<l,I>"))
C.iH=new A.t6(C.arl,1,1,0.7568627450980392,0.027450980392156862,B.m)})()};
(a=>{a["haEHP4VrIdXZHAQgz3CI6iiDAbQ="]=a.current})($__dart_deferred_initializers__);