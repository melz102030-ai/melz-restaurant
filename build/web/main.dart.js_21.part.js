((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,B,D={
bWN(d,e,f){var x,w,v,u,t,s,r
if(d==e)return d
if(d==null)return e.bo(0,f)
if(e==null)return d.bo(0,1-f)
x=A.bPG(d.a,d.qa(),e.a,e.qa(),f)
w=A.rj(d.d,e.d,f)
w.toString
v=A.af(d.e,e.e,f)
v.toString
v=Math.max(0,v)
u=f<0.5
t=u?d.f:e.f
s=A.rj(d.r,e.r,f)
r=A.af(d.w,e.w,f)
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
aZM:function aZM(d){this.a=d},
caW(d,e,f,g,h,i,j,k){var x,w
if(f.length!==g.length)A.Z(A.bV('"colors" and "colorStops" arguments must have equal length.',null))
x=i!=null?A.wU(i):null
if(j!=null)w=j.k(0,d)&&k===0
else w=!0
if(w){$.am()
w=new A.a5W(d,e,f,g,h,x)
w.Hf()
return w}else{$.am()
w=new A.a5U(j,k,d,e,f,g,h,x)
w.Hf()
return w}}},C
J=c[1]
A=c[0]
B=c[2]
D=a.updateHolder(c[11],D)
C=c[29]
D.vA.prototype={
vI(d,e,f){var x=this,w=x.d.a5(f).Gf(e),v=e.ghE(),u=x.qa(),t=x.Tx(e,f),s=x.r
s=s==null?null:s.a5(f).Gf(e)
return D.caW(w,x.e*v,x.a,u,x.f,t,s,x.w*e.ghE())},
e1(d,e){return this.vI(0,e,null)},
bo(d,e){var x=this,w=x.a,v=A.U(w).h("I<1,J>")
w=A.Q(new A.I(w,new D.aZM(e),v),v.h("az.E"))
return new D.vA(x.d,x.e,x.f,x.r,x.w,w,x.b,x.c)},
LV(d){var x=this
return new D.vA(x.d,x.e,x.f,x.r,x.w,A.bJ(x.a.length,d,!1,y.o),x.b,x.c)},
eV(d,e){if(y.a.b(d))return D.bWN(d,this,e)
return this.Pi(d,e)},
eL(d,e){if(y.a.b(d))return D.bWN(this,d,e)
return this.Pj(d,e)},
k(d,e){var x=this
if(e==null)return!1
if(x===e)return!0
if(J.an(e)!==A.E(x))return!1
return e instanceof D.vA&&e.d.k(0,x.d)&&e.e===x.e&&e.f===x.f&&J.f(e.c,x.c)&&A.dP(e.a,x.a)&&A.dP(e.b,x.b)&&J.f(e.r,x.r)&&e.w===x.w},
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
D.aZM.prototype={
$1(d){var x=A.W(null,d,this.a)
x.toString
return x},
$S:92};(function inheritance(){var x=a.inherit
x(D.vA,A.Ra)
x(D.aZM,A.hA)})()
var y={o:A.a5("J"),h:A.a5("z<c>"),a:A.a5("vA?")};(function constants(){C.Et=new A.a3(16,0,16,16)
C.a47=new A.J(1,1,0.9725490196078431,0.8823529411764706,B.l)
C.a55=new A.J(1,1,0.9254901960784314,0.7019607843137254,B.l)
C.a4Y=new A.J(1,1,0.8784313725490196,0.5098039215686274,B.l)
C.a4W=new A.J(1,1,0.8352941176470589,0.30980392156862746,B.l)
C.a5u=new A.J(1,1,0.792156862745098,0.1568627450980392,B.l)
C.a4e=new A.J(1,1,0.7568627450980392,0.027450980392156862,B.l)
C.a5t=new A.J(1,1,0.7019607843137254,0,B.l)
C.a4q=new A.J(1,1,0.6274509803921569,0,B.l)
C.a50=new A.J(1,1,0.5607843137254902,0,B.l)
C.a4u=new A.J(1,1,0.43529411764705883,0,B.l)
C.aqS=new A.cW([50,C.a47,100,C.a55,200,C.a4Y,300,C.a4W,400,C.a5u,500,C.a4e,600,C.a5t,700,C.a4q,800,C.a50,900,C.a4u],A.a5("cW<l,J>"))
C.iD=new A.t8(C.aqS,1,1,0.7568627450980392,0.027450980392156862,B.l)})()};
(a=>{a["MIuGwDalwSAFAsfb1FoBOuhQkxg="]=a.current})($__dart_deferred_initializers__);