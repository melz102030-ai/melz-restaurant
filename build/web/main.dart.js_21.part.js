((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,D={aKP:function aKP(d,e,f,g,h,i,j,k){var _=this
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
bXM(d,e,f){var x,w,v,u,t,s,r
if(d==e)return d
if(d==null)return e.bo(0,f)
if(e==null)return d.bo(0,1-f)
x=A.bQz(d.a,d.qi(),e.a,e.qi(),f)
w=A.ri(d.d,e.d,f)
w.toString
v=A.ai(d.e,e.e,f)
v.toString
v=Math.max(0,v)
u=f<0.5
t=u?d.f:e.f
s=A.ri(d.r,e.r,f)
r=A.ai(d.w,e.w,f)
r.toString
r=Math.max(0,r)
u=u?d.c:e.c
return new D.vC(w,v,t,s,r,x.a,x.b,u)},
vC:function vC(d,e,f,g,h,i,j,k){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.a=i
_.b=j
_.c=k},
b_1:function b_1(d){this.a=d}},C
J=c[1]
A=c[0]
B=c[2]
D=a.updateHolder(c[11],D)
C=c[29]
D.aKP.prototype={
gVr(){var x,w,v,u,t,s,r,q,p,o,n=this,m=null,l=n.z
if(l==null){x=A.bQq(n.e)
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
l=new A.Bn()
v=$.c1.cp().Shader
u=A.aAp(q,u)
q=A.bLw(w)
s=A.aAN(s)
r=r!=null?A.aAM(r):m
l.a=A.iG(v,"MakeRadialGradient",[u,t,x,q,s,r==null?m:r,0])
$.aB5().lv(n,l,l)
n.z=l}else{$.an()
v=l.a
l=l.b
p=new A.Bn()
o=$.c1.cp().Shader
l=A.aAp(v,l)
u=A.aAp(q,u)
q=A.bLw(w)
s=A.aAN(s)
v=r!=null?A.aAM(r):m
if(v==null)v=m
p.a=A.iG(o,"MakeTwoPointConicalGradient",[l,n.y,u,t,x,q,s,v,0])
$.aB5().lv(n,p,p)
n.z=p
l=p}}return l}}
D.vC.prototype={
vV(d,e,f){var x,w=this,v=w.d.a4(f).Gq(e),u=e.ghn(),t=w.a,s=w.qi(),r=w.TX(e,f),q=w.r
q=q==null?null:q.a4(f).Gq(e)
x=e.ghn()
A.bQP(t,s)
r=r!=null?A.wV(r):null
return new D.aKP(v,w.e*u,t,s,w.f,r,q,w.w*x)},
e1(d,e){return this.vV(0,e,null)},
bo(d,e){var x=this,w=x.a,v=A.T(w).h("J<1,I>")
w=A.Q(new A.J(w,new D.b_1(e),v),v.h("az.E"))
return new D.vC(x.d,x.e,x.f,x.r,x.w,w,x.b,x.c)},
M4(d){var x=this
return new D.vC(x.d,x.e,x.f,x.r,x.w,A.bJ(x.a.length,d,!1,y.o),x.b,x.c)},
eO(d,e){if(y.a.b(d))return D.bXM(d,this,e)
return this.PF(d,e)},
eG(d,e){if(y.a.b(d))return D.bXM(this,d,e)
return this.PG(d,e)},
k(d,e){var x=this
if(e==null)return!1
if(x===e)return!0
if(J.ar(e)!==A.E(x))return!1
return e instanceof D.vC&&e.d.k(0,x.d)&&e.e===x.e&&e.f===x.f&&J.f(e.c,x.c)&&A.dP(e.a,x.a)&&A.dP(e.b,x.b)&&J.f(e.r,x.r)&&e.w===x.w},
gD(d){var x=this,w=A.cl(x.a),v=x.b
v=v==null?null:A.cl(v)
return A.Y(x.d,x.e,x.f,x.c,w,v,x.r,x.w,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a)},
j(d){var x=this,w=A.b(["center: "+x.d.j(0),"radius: "+A.kX(x.e),"colors: "+A.o(x.a)],y.h),v=x.b
if(v!=null)w.push("stops: "+A.o(v))
w.push("tileMode: "+x.f.j(0))
v=x.r
if(v!=null)w.push("focal: "+v.j(0))
w.push("focalRadius: "+A.kX(x.w))
v=x.c
if(v!=null)w.push("transform: "+v.j(0))
return"RadialGradient("+B.b.aN(w,", ")+")"}}
var z=a.updateTypes([])
D.b_1.prototype={
$1(d){var x=A.W(null,d,this.a)
x.toString
return x},
$S:88};(function inheritance(){var x=a.inherit
x(D.aKP,A.a9o)
x(D.vC,A.Ri)
x(D.b_1,A.hE)})()
var y={o:A.a4("I"),h:A.a4("z<c>"),a:A.a4("vC?")};(function constants(){C.EA=new A.a2(16,0,16,16)
C.a4i=new A.I(1,1,0.9725490196078431,0.8823529411764706,B.m)
C.a5g=new A.I(1,1,0.9254901960784314,0.7019607843137254,B.m)
C.a58=new A.I(1,1,0.8784313725490196,0.5098039215686274,B.m)
C.a56=new A.I(1,1,0.8352941176470589,0.30980392156862746,B.m)
C.a5F=new A.I(1,1,0.792156862745098,0.1568627450980392,B.m)
C.a4p=new A.I(1,1,0.7568627450980392,0.027450980392156862,B.m)
C.a5E=new A.I(1,1,0.7019607843137254,0,B.m)
C.a4B=new A.I(1,1,0.6274509803921569,0,B.m)
C.a5b=new A.I(1,1,0.5607843137254902,0,B.m)
C.a4F=new A.I(1,1,0.43529411764705883,0,B.m)
C.arh=new A.cL([50,C.a4i,100,C.a5g,200,C.a58,300,C.a56,400,C.a5F,500,C.a4p,600,C.a5E,700,C.a4B,800,C.a5b,900,C.a4F],A.a4("cL<l,I>"))
C.iI=new A.t6(C.arh,1,1,0.7568627450980392,0.027450980392156862,B.m)})()};
(a=>{a["fFhNy391QotFw3OiE2mMnckFw2o="]=a.current})($__dart_deferred_initializers__);