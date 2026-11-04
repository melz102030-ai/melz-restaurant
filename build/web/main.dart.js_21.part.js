((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,D={
bW7(d,e,f){var x,w,v,u,t,s,r
if(d==e)return d
if(d==null)return e.br(0,f)
if(e==null)return d.br(0,1-f)
x=A.bP3(d.a,d.q8(),e.a,e.q8(),f)
w=A.rf(d.d,e.d,f)
w.toString
v=A.ag(d.e,e.e,f)
v.toString
v=Math.max(0,v)
u=f<0.5
t=u?d.f:e.f
s=A.rf(d.r,e.r,f)
r=A.ag(d.w,e.w,f)
r.toString
r=Math.max(0,r)
u=u?d.c:e.c
return new D.vw(w,v,t,s,r,x.a,x.b,u)},
vw:function vw(d,e,f,g,h,i,j,k){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.a=i
_.b=j
_.c=k},
aZk:function aZk(d){this.a=d},
cac(d,e,f,g,h,i,j,k){var x,w
if(f.length!==g.length)A.Z(A.bV('"colors" and "colorStops" arguments must have equal length.',null))
x=i!=null?A.wQ(i):null
if(j!=null)w=j.k(0,d)&&k===0
else w=!0
if(w){$.an()
w=new A.a5J(d,e,f,g,h,x)
w.H7()
return w}else{$.an()
w=new A.a5H(j,k,d,e,f,g,h,x)
w.H7()
return w}}},C
J=c[1]
A=c[0]
B=c[2]
D=a.updateHolder(c[11],D)
C=c[29]
D.vw.prototype={
vG(d,e,f){var x=this,w=x.d.a6(f).G7(e),v=e.ghE(),u=x.q8(),t=x.Tq(e,f),s=x.r
s=s==null?null:s.a6(f).G7(e)
return D.cac(w,x.e*v,x.a,u,x.f,t,s,x.w*e.ghE())},
e0(d,e){return this.vG(0,e,null)},
br(d,e){var x=this,w=x.a,v=A.T(w).h("G<1,J>")
w=A.Q(new A.G(w,new D.aZk(e),v),v.h("aw.E"))
return new D.vw(x.d,x.e,x.f,x.r,x.w,w,x.b,x.c)},
LN(d){var x=this
return new D.vw(x.d,x.e,x.f,x.r,x.w,A.bH(x.a.length,d,!1,y.o),x.b,x.c)},
eS(d,e){if(y.a.b(d))return D.bW7(d,this,e)
return this.Pc(d,e)},
eL(d,e){if(y.a.b(d))return D.bW7(this,d,e)
return this.Pd(d,e)},
k(d,e){var x=this
if(e==null)return!1
if(x===e)return!0
if(J.ao(e)!==A.F(x))return!1
return e instanceof D.vw&&e.d.k(0,x.d)&&e.e===x.e&&e.f===x.f&&J.f(e.c,x.c)&&A.dO(e.a,x.a)&&A.dO(e.b,x.b)&&J.f(e.r,x.r)&&e.w===x.w},
gB(d){var x=this,w=A.cg(x.a),v=x.b
v=v==null?null:A.cg(v)
return A.Y(x.d,x.e,x.f,x.c,w,v,x.r,x.w,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a)},
j(d){var x=this,w=A.b(["center: "+x.d.j(0),"radius: "+A.kR(x.e),"colors: "+A.o(x.a)],y.h),v=x.b
if(v!=null)w.push("stops: "+A.o(v))
w.push("tileMode: "+x.f.j(0))
v=x.r
if(v!=null)w.push("focal: "+v.j(0))
w.push("focalRadius: "+A.kR(x.w))
v=x.c
if(v!=null)w.push("transform: "+v.j(0))
return"RadialGradient("+B.b.aN(w,", ")+")"}}
var z=a.updateTypes([])
D.aZk.prototype={
$1(d){var x=A.W(null,d,this.a)
x.toString
return x},
$S:85};(function inheritance(){var x=a.inherit
x(D.vw,A.R0)
x(D.aZk,A.hv)})()
var y={o:A.a6("J"),h:A.a6("z<c>"),a:A.a6("vw?")};(function constants(){C.Ep=new A.a3(16,0,16,16)
C.a4c=new A.J(1,1,0.9725490196078431,0.8823529411764706,B.l)
C.a5a=new A.J(1,1,0.9254901960784314,0.7019607843137254,B.l)
C.a52=new A.J(1,1,0.8784313725490196,0.5098039215686274,B.l)
C.a50=new A.J(1,1,0.8352941176470589,0.30980392156862746,B.l)
C.a5z=new A.J(1,1,0.792156862745098,0.1568627450980392,B.l)
C.a4j=new A.J(1,1,0.7568627450980392,0.027450980392156862,B.l)
C.a5y=new A.J(1,1,0.7019607843137254,0,B.l)
C.a4v=new A.J(1,1,0.6274509803921569,0,B.l)
C.a55=new A.J(1,1,0.5607843137254902,0,B.l)
C.a4z=new A.J(1,1,0.43529411764705883,0,B.l)
C.aqM=new A.cV([50,C.a4c,100,C.a5a,200,C.a52,300,C.a50,400,C.a5z,500,C.a4j,600,C.a5y,700,C.a4v,800,C.a55,900,C.a4z],A.a6("cV<l,J>"))
C.iG=new A.t7(C.aqM,1,1,0.7568627450980392,0.027450980392156862,B.l)})()};
(a=>{a["XxT+4nBoOr9Lb4bBzyMAd9gDwsE="]=a.current})($__dart_deferred_initializers__);