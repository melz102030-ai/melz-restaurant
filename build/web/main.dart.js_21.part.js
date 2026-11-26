((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,D={aLf:function aLf(d,e,f,g,h,i,j,k){var _=this
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
bZ0(d,e,f){var x,w,v,u,t,s,r
if(d==e)return d
if(d==null)return e.bo(0,f)
if(e==null)return d.bo(0,1-f)
x=A.bRM(d.a,d.qm(),e.a,e.qm(),f)
w=A.rn(d.d,e.d,f)
w.toString
v=A.al(d.e,e.e,f)
v.toString
v=Math.max(0,v)
u=f<0.5
t=u?d.f:e.f
s=A.rn(d.r,e.r,f)
r=A.al(d.w,e.w,f)
r.toString
r=Math.max(0,r)
u=u?d.c:e.c
return new D.vJ(w,v,t,s,r,x.a,x.b,u)},
vJ:function vJ(d,e,f,g,h,i,j,k){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.a=i
_.b=j
_.c=k},
b_G:function b_G(d){this.a=d}},C
J=c[1]
A=c[0]
B=c[2]
D=a.updateHolder(c[11],D)
C=c[30]
D.aLf.prototype={
gVt(){var x,w,v,u,t,s,r,q,p,o,n=this,m=null,l=n.z
if(l==null){x=A.bRD(n.e)
w=new Float32Array(A.il(n.f))
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
l=new A.Bu()
v=$.c5.cp().Shader
u=A.aAM(q,u)
q=A.bMK(w)
s=A.aB8(s)
r=r!=null?A.aB7(r):m
l.a=A.iJ(v,"MakeRadialGradient",[u,t,x,q,s,r==null?m:r,0])
$.aBr().lw(n,l,l)
n.z=l}else{$.an()
v=l.a
l=l.b
p=new A.Bu()
o=$.c5.cp().Shader
l=A.aAM(v,l)
u=A.aAM(q,u)
q=A.bMK(w)
s=A.aB8(s)
v=r!=null?A.aB7(r):m
if(v==null)v=m
p.a=A.iJ(o,"MakeTwoPointConicalGradient",[l,n.y,u,t,x,q,s,v,0])
$.aBr().lw(n,p,p)
n.z=p
l=p}}return l}}
D.vJ.prototype={
vV(d,e,f){var x,w=this,v=w.d.a4(f).Gr(e),u=e.ghn(),t=w.a,s=w.qm(),r=w.TZ(e,f),q=w.r
q=q==null?null:q.a4(f).Gr(e)
x=e.ghn()
A.bS1(t,s)
r=r!=null?A.x2(r):null
return new D.aLf(v,w.e*u,t,s,w.f,r,q,w.w*x)},
e1(d,e){return this.vV(0,e,null)},
bo(d,e){var x=this,w=x.a,v=A.T(w).h("H<1,J>")
w=A.P(new A.H(w,new D.b_G(e),v),v.h("ax.E"))
return new D.vJ(x.d,x.e,x.f,x.r,x.w,w,x.b,x.c)},
M7(d){var x=this
return new D.vJ(x.d,x.e,x.f,x.r,x.w,A.bJ(x.a.length,d,!1,y.o),x.b,x.c)},
eR(d,e){if(y.a.b(d))return D.bZ0(d,this,e)
return this.PH(d,e)},
eJ(d,e){if(y.a.b(d))return D.bZ0(this,d,e)
return this.PI(d,e)},
k(d,e){var x=this
if(e==null)return!1
if(x===e)return!0
if(J.at(e)!==A.G(x))return!1
return e instanceof D.vJ&&e.d.k(0,x.d)&&e.e===x.e&&e.f===x.f&&J.f(e.c,x.c)&&A.dU(e.a,x.a)&&A.dU(e.b,x.b)&&J.f(e.r,x.r)&&e.w===x.w},
gD(d){var x=this,w=A.cm(x.a),v=x.b
v=v==null?null:A.cm(v)
return A.Y(x.d,x.e,x.f,x.c,w,v,x.r,x.w,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a)},
j(d){var x=this,w=A.b(["center: "+x.d.j(0),"radius: "+A.l1(x.e),"colors: "+A.o(x.a)],y.h),v=x.b
if(v!=null)w.push("stops: "+A.o(v))
w.push("tileMode: "+x.f.j(0))
v=x.r
if(v!=null)w.push("focal: "+v.j(0))
w.push("focalRadius: "+A.l1(x.w))
v=x.c
if(v!=null)w.push("transform: "+v.j(0))
return"RadialGradient("+B.b.aN(w,", ")+")"}}
var z=a.updateTypes([])
D.b_G.prototype={
$1(d){var x=A.W(null,d,this.a)
x.toString
return x},
$S:82};(function inheritance(){var x=a.inherit
x(D.aLf,A.a9E)
x(D.vJ,A.Rs)
x(D.b_G,A.hG)})()
var y={o:A.a8("J"),h:A.a8("z<c>"),a:A.a8("vJ?")};(function constants(){C.EF=new A.a1(16,0,16,16)
C.a4D=new A.J(1,1,0.9725490196078431,0.8823529411764706,B.m)
C.a5B=new A.J(1,1,0.9254901960784314,0.7019607843137254,B.m)
C.a5t=new A.J(1,1,0.8784313725490196,0.5098039215686274,B.m)
C.a5r=new A.J(1,1,0.8352941176470589,0.30980392156862746,B.m)
C.a6_=new A.J(1,1,0.792156862745098,0.1568627450980392,B.m)
C.a4K=new A.J(1,1,0.7568627450980392,0.027450980392156862,B.m)
C.a5Z=new A.J(1,1,0.7019607843137254,0,B.m)
C.a4W=new A.J(1,1,0.6274509803921569,0,B.m)
C.a5w=new A.J(1,1,0.5607843137254902,0,B.m)
C.a5_=new A.J(1,1,0.43529411764705883,0,B.m)
C.arw=new A.cM([50,C.a4D,100,C.a5B,200,C.a5t,300,C.a5r,400,C.a6_,500,C.a4K,600,C.a5Z,700,C.a4W,800,C.a5w,900,C.a5_],A.a8("cM<l,J>"))
C.iL=new A.tb(C.arw,1,1,0.7568627450980392,0.027450980392156862,B.m)})()};
(a=>{a["rlAuM+7R2CMLpsMdyWad61bxRs8="]=a.current})($__dart_deferred_initializers__);