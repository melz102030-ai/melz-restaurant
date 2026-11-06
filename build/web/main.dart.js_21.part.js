((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,D={
bXm(d,e,f){var x,w,v,u,t,s,r
if(d==e)return d
if(d==null)return e.bq(0,f)
if(e==null)return d.bq(0,1-f)
x=A.bQf(d.a,d.qb(),e.a,e.qb(),f)
w=A.rl(d.d,e.d,f)
w.toString
v=A.ah(d.e,e.e,f)
v.toString
v=Math.max(0,v)
u=f<0.5
t=u?d.f:e.f
s=A.rl(d.r,e.r,f)
r=A.ah(d.w,e.w,f)
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
b_0:function b_0(d){this.a=d},
cbv(d,e,f,g,h,i,j,k){var x,w
if(f.length!==g.length)A.Z(A.bW('"colors" and "colorStops" arguments must have equal length.',null))
x=i!=null?A.wY(i):null
if(j!=null)w=j.k(0,d)&&k===0
else w=!0
if(w){$.an()
w=new A.a62(d,e,f,g,h,x)
w.He()
return w}else{$.an()
w=new A.a60(j,k,d,e,f,g,h,x)
w.He()
return w}}},C
J=c[1]
A=c[0]
B=c[2]
D=a.updateHolder(c[11],D)
C=c[29]
D.vE.prototype={
vI(d,e,f){var x=this,w=x.d.a5(f).Ge(e),v=e.ghF(),u=x.qb(),t=x.TA(e,f),s=x.r
s=s==null?null:s.a5(f).Ge(e)
return D.cbv(w,x.e*v,x.a,u,x.f,t,s,x.w*e.ghF())},
e0(d,e){return this.vI(0,e,null)},
bq(d,e){var x=this,w=x.a,v=A.T(w).h("H<1,J>")
w=A.Q(new A.H(w,new D.b_0(e),v),v.h("aw.E"))
return new D.vE(x.d,x.e,x.f,x.r,x.w,w,x.b,x.c)},
LV(d){var x=this
return new D.vE(x.d,x.e,x.f,x.r,x.w,A.bJ(x.a.length,d,!1,y.o),x.b,x.c)},
eS(d,e){if(y.a.b(d))return D.bXm(d,this,e)
return this.Pk(d,e)},
eL(d,e){if(y.a.b(d))return D.bXm(this,d,e)
return this.Pl(d,e)},
k(d,e){var x=this
if(e==null)return!1
if(x===e)return!0
if(J.ao(e)!==A.E(x))return!1
return e instanceof D.vE&&e.d.k(0,x.d)&&e.e===x.e&&e.f===x.f&&J.f(e.c,x.c)&&A.dP(e.a,x.a)&&A.dP(e.b,x.b)&&J.f(e.r,x.r)&&e.w===x.w},
gC(d){var x=this,w=A.cg(x.a),v=x.b
v=v==null?null:A.cg(v)
return A.Y(x.d,x.e,x.f,x.c,w,v,x.r,x.w,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a)},
j(d){var x=this,w=A.b(["center: "+x.d.j(0),"radius: "+A.kW(x.e),"colors: "+A.o(x.a)],y.h),v=x.b
if(v!=null)w.push("stops: "+A.o(v))
w.push("tileMode: "+x.f.j(0))
v=x.r
if(v!=null)w.push("focal: "+v.j(0))
w.push("focalRadius: "+A.kW(x.w))
v=x.c
if(v!=null)w.push("transform: "+v.j(0))
return"RadialGradient("+B.b.aO(w,", ")+")"}}
var z=a.updateTypes([])
D.b_0.prototype={
$1(d){var x=A.W(null,d,this.a)
x.toString
return x},
$S:85};(function inheritance(){var x=a.inherit
x(D.vE,A.Rf)
x(D.b_0,A.hA)})()
var y={o:A.a6("J"),h:A.a6("z<c>"),a:A.a6("vE?")};(function constants(){C.Es=new A.a4(16,0,16,16)
C.a4g=new A.J(1,1,0.9725490196078431,0.8823529411764706,B.l)
C.a5e=new A.J(1,1,0.9254901960784314,0.7019607843137254,B.l)
C.a56=new A.J(1,1,0.8784313725490196,0.5098039215686274,B.l)
C.a54=new A.J(1,1,0.8352941176470589,0.30980392156862746,B.l)
C.a5D=new A.J(1,1,0.792156862745098,0.1568627450980392,B.l)
C.a4n=new A.J(1,1,0.7568627450980392,0.027450980392156862,B.l)
C.a5C=new A.J(1,1,0.7019607843137254,0,B.l)
C.a4z=new A.J(1,1,0.6274509803921569,0,B.l)
C.a59=new A.J(1,1,0.5607843137254902,0,B.l)
C.a4D=new A.J(1,1,0.43529411764705883,0,B.l)
C.ar3=new A.cW([50,C.a4g,100,C.a5e,200,C.a56,300,C.a54,400,C.a5D,500,C.a4n,600,C.a5C,700,C.a4z,800,C.a59,900,C.a4D],A.a6("cW<k,J>"))
C.iG=new A.t9(C.ar3,1,1,0.7568627450980392,0.027450980392156862,B.l)})()};
(a=>{a["ZVcJcq51rAhuelwW0CfkL5MlKZU="]=a.current})($__dart_deferred_initializers__);