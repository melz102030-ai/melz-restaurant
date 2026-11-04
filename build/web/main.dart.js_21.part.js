((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,D={
bWp(d,e,f){var x,w,v,u,t,s,r
if(d==e)return d
if(d==null)return e.br(0,f)
if(e==null)return d.br(0,1-f)
x=A.bPm(d.a,d.qa(),e.a,e.qa(),f)
w=A.rh(d.d,e.d,f)
w.toString
v=A.ah(d.e,e.e,f)
v.toString
v=Math.max(0,v)
u=f<0.5
t=u?d.f:e.f
s=A.rh(d.r,e.r,f)
r=A.ah(d.w,e.w,f)
r.toString
r=Math.max(0,r)
u=u?d.c:e.c
return new D.vA(w,v,t,s,r,x.a,x.b,u)},
vA:function vA(d,e,f,g,h,i,j,k){var _=this
_.d=d
_.e=e
_.f=f
_.r=g
_.w=h
_.a=i
_.b=j
_.c=k},
aZz:function aZz(d){this.a=d},
cay(d,e,f,g,h,i,j,k){var x,w
if(f.length!==g.length)A.Z(A.bW('"colors" and "colorStops" arguments must have equal length.',null))
x=i!=null?A.wU(i):null
if(j!=null)w=j.k(0,d)&&k===0
else w=!0
if(w){$.an()
w=new A.a5O(d,e,f,g,h,x)
w.Ha()
return w}else{$.an()
w=new A.a5M(j,k,d,e,f,g,h,x)
w.Ha()
return w}}},C
J=c[1]
A=c[0]
B=c[2]
D=a.updateHolder(c[11],D)
C=c[29]
D.vA.prototype={
vG(d,e,f){var x=this,w=x.d.a6(f).Ga(e),v=e.ghE(),u=x.qa(),t=x.Ts(e,f),s=x.r
s=s==null?null:s.a6(f).Ga(e)
return D.cay(w,x.e*v,x.a,u,x.f,t,s,x.w*e.ghE())},
e0(d,e){return this.vG(0,e,null)},
br(d,e){var x=this,w=x.a,v=A.T(w).h("G<1,J>")
w=A.Q(new A.G(w,new D.aZz(e),v),v.h("aw.E"))
return new D.vA(x.d,x.e,x.f,x.r,x.w,w,x.b,x.c)},
LP(d){var x=this
return new D.vA(x.d,x.e,x.f,x.r,x.w,A.bI(x.a.length,d,!1,y.o),x.b,x.c)},
eS(d,e){if(y.a.b(d))return D.bWp(d,this,e)
return this.Pe(d,e)},
eL(d,e){if(y.a.b(d))return D.bWp(this,d,e)
return this.Pf(d,e)},
k(d,e){var x=this
if(e==null)return!1
if(x===e)return!0
if(J.ao(e)!==A.E(x))return!1
return e instanceof D.vA&&e.d.k(0,x.d)&&e.e===x.e&&e.f===x.f&&J.f(e.c,x.c)&&A.dO(e.a,x.a)&&A.dO(e.b,x.b)&&J.f(e.r,x.r)&&e.w===x.w},
gB(d){var x=this,w=A.cg(x.a),v=x.b
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
return"RadialGradient("+B.b.aN(w,", ")+")"}}
var z=a.updateTypes([])
D.aZz.prototype={
$1(d){var x=A.W(null,d,this.a)
x.toString
return x},
$S:85};(function inheritance(){var x=a.inherit
x(D.vA,A.R3)
x(D.aZz,A.hy)})()
var y={o:A.a6("J"),h:A.a6("z<c>"),a:A.a6("vA?")};(function constants(){C.Ep=new A.a4(16,0,16,16)
C.a4d=new A.J(1,1,0.9725490196078431,0.8823529411764706,B.l)
C.a5b=new A.J(1,1,0.9254901960784314,0.7019607843137254,B.l)
C.a53=new A.J(1,1,0.8784313725490196,0.5098039215686274,B.l)
C.a51=new A.J(1,1,0.8352941176470589,0.30980392156862746,B.l)
C.a5A=new A.J(1,1,0.792156862745098,0.1568627450980392,B.l)
C.a4k=new A.J(1,1,0.7568627450980392,0.027450980392156862,B.l)
C.a5z=new A.J(1,1,0.7019607843137254,0,B.l)
C.a4w=new A.J(1,1,0.6274509803921569,0,B.l)
C.a56=new A.J(1,1,0.5607843137254902,0,B.l)
C.a4A=new A.J(1,1,0.43529411764705883,0,B.l)
C.aqR=new A.cW([50,C.a4d,100,C.a5b,200,C.a53,300,C.a51,400,C.a5A,500,C.a4k,600,C.a5z,700,C.a4w,800,C.a56,900,C.a4A],A.a6("cW<l,J>"))
C.iH=new A.t8(C.aqR,1,1,0.7568627450980392,0.027450980392156862,B.l)})()};
(a=>{a["CVkP6iPy78mcW2oqzVjjLMHFP5Q="]=a.current})($__dart_deferred_initializers__);