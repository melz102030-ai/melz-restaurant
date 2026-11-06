((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,D={
bX8(d,e,f){var x,w,v,u,t,s,r
if(d==e)return d
if(d==null)return e.bq(0,f)
if(e==null)return d.bq(0,1-f)
x=A.bQ0(d.a,d.qb(),e.a,e.qb(),f)
w=A.rm(d.d,e.d,f)
w.toString
v=A.ah(d.e,e.e,f)
v.toString
v=Math.max(0,v)
u=f<0.5
t=u?d.f:e.f
s=A.rm(d.r,e.r,f)
r=A.ah(d.w,e.w,f)
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
aZV:function aZV(d){this.a=d},
cbh(d,e,f,g,h,i,j,k){var x,w
if(f.length!==g.length)A.Z(A.bW('"colors" and "colorStops" arguments must have equal length.',null))
x=i!=null?A.wW(i):null
if(j!=null)w=j.k(0,d)&&k===0
else w=!0
if(w){$.an()
w=new A.a5Z(d,e,f,g,h,x)
w.Hd()
return w}else{$.an()
w=new A.a5X(j,k,d,e,f,g,h,x)
w.Hd()
return w}}},C
J=c[1]
A=c[0]
B=c[2]
D=a.updateHolder(c[11],D)
C=c[29]
D.vC.prototype={
vH(d,e,f){var x=this,w=x.d.a5(f).Gd(e),v=e.ghF(),u=x.qb(),t=x.Tz(e,f),s=x.r
s=s==null?null:s.a5(f).Gd(e)
return D.cbh(w,x.e*v,x.a,u,x.f,t,s,x.w*e.ghF())},
e0(d,e){return this.vH(0,e,null)},
bq(d,e){var x=this,w=x.a,v=A.T(w).h("G<1,J>")
w=A.Q(new A.G(w,new D.aZV(e),v),v.h("aw.E"))
return new D.vC(x.d,x.e,x.f,x.r,x.w,w,x.b,x.c)},
LU(d){var x=this
return new D.vC(x.d,x.e,x.f,x.r,x.w,A.bJ(x.a.length,d,!1,y.o),x.b,x.c)},
eS(d,e){if(y.a.b(d))return D.bX8(d,this,e)
return this.Pj(d,e)},
eL(d,e){if(y.a.b(d))return D.bX8(this,d,e)
return this.Pk(d,e)},
k(d,e){var x=this
if(e==null)return!1
if(x===e)return!0
if(J.ao(e)!==A.E(x))return!1
return e instanceof D.vC&&e.d.k(0,x.d)&&e.e===x.e&&e.f===x.f&&J.f(e.c,x.c)&&A.dP(e.a,x.a)&&A.dP(e.b,x.b)&&J.f(e.r,x.r)&&e.w===x.w},
gC(d){var x=this,w=A.cg(x.a),v=x.b
v=v==null?null:A.cg(v)
return A.Y(x.d,x.e,x.f,x.c,w,v,x.r,x.w,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a,B.a)},
j(d){var x=this,w=A.b(["center: "+x.d.j(0),"radius: "+A.kU(x.e),"colors: "+A.o(x.a)],y.h),v=x.b
if(v!=null)w.push("stops: "+A.o(v))
w.push("tileMode: "+x.f.j(0))
v=x.r
if(v!=null)w.push("focal: "+v.j(0))
w.push("focalRadius: "+A.kU(x.w))
v=x.c
if(v!=null)w.push("transform: "+v.j(0))
return"RadialGradient("+B.b.aM(w,", ")+")"}}
var z=a.updateTypes([])
D.aZV.prototype={
$1(d){var x=A.W(null,d,this.a)
x.toString
return x},
$S:86};(function inheritance(){var x=a.inherit
x(D.vC,A.Rd)
x(D.aZV,A.hz)})()
var y={o:A.a6("J"),h:A.a6("z<c>"),a:A.a6("vC?")};(function constants(){C.Et=new A.a5(16,0,16,16)
C.a4h=new A.J(1,1,0.9725490196078431,0.8823529411764706,B.l)
C.a5f=new A.J(1,1,0.9254901960784314,0.7019607843137254,B.l)
C.a57=new A.J(1,1,0.8784313725490196,0.5098039215686274,B.l)
C.a55=new A.J(1,1,0.8352941176470589,0.30980392156862746,B.l)
C.a5E=new A.J(1,1,0.792156862745098,0.1568627450980392,B.l)
C.a4o=new A.J(1,1,0.7568627450980392,0.027450980392156862,B.l)
C.a5D=new A.J(1,1,0.7019607843137254,0,B.l)
C.a4A=new A.J(1,1,0.6274509803921569,0,B.l)
C.a5a=new A.J(1,1,0.5607843137254902,0,B.l)
C.a4E=new A.J(1,1,0.43529411764705883,0,B.l)
C.ar0=new A.cW([50,C.a4h,100,C.a5f,200,C.a57,300,C.a55,400,C.a5E,500,C.a4o,600,C.a5D,700,C.a4A,800,C.a5a,900,C.a4E],A.a6("cW<k,J>"))
C.iG=new A.tb(C.ar0,1,1,0.7568627450980392,0.027450980392156862,B.l)})()};
(a=>{a["wuS6sJtnAwd7HfwDlKIVc+glMJM="]=a.current})($__dart_deferred_initializers__);