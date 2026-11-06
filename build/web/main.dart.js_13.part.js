((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5N(d,e,f){return new A.VO(d,e,null,f.h("VO<0>"))},
tA:function tA(){},
a1u:function a1u(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bBl:function bBl(d){this.a=d},
bBk:function bBk(d,e){this.a=d
this.b=e},
bBn:function bBn(d){this.a=d},
bBi:function bBi(d,e,f){this.a=d
this.b=e
this.c=f},
bBm:function bBm(d){this.a=d},
bBj:function bBj(d){this.a=d},
VO:function VO(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bOu(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a4(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mJ:C.hB
t=p.i(d,r) instanceof B.i9?B.oy(y.F.a(p.i(d,r)).gmr()):new B.cz(Date.now(),0,!1)
s=p.i(d,q) instanceof B.i9?B.oy(y.F.a(p.i(d,q)).gmr()):new B.cz(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dB(e,o,x,w,v,u,t,s,J.dG(p,new A.b6s(),y.v).cK(0))},
aiI:function aiI(d,e){this.a=d
this.b=e},
aiG:function aiG(d,e){this.a=d
this.b=e},
p7:function p7(d,e,f,g){var _=this
_.a=d
_.b=e
_.c=f
_.d=g},
dB:function dB(d,e,f,g,h,i,j,k,l){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h
_.f=i
_.r=j
_.w=k
_.x=l},
b6s:function b6s(){},
b6t:function b6t(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tA.prototype={
a_(){return new A.a1u(this.$ti.h("a1u<tA.T,tA.S>"))}}
A.a1u.prototype={
au(){var x,w=this
w.aH()
x=w.a
x.toString
x=B.bSN(x.$ti.c)
w.e=x
w.Bs()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2s()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fl(D.xf,x.b,x.c,x.d,x.$ti)}w.Bs()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yC(d,x)},
m(){this.a2s()
this.ar()},
Bs(){var x,w=this
w.d=w.a.c.lJ(new A.bBl(w),new A.bBm(w),new A.bBn(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fl(D.DR,x.b,x.c,x.d,x.$ti)},
a2s(){var x=this.d
if(x!=null){x.aK(0)
this.d=null}}}
A.VO.prototype={
yC(d,e){return this.e.$2(d,e)}}
A.aiI.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiG.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p7.prototype={
e8(){var x=this,w=x.d
return B.ak(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ia(1000*w.a+w.b)],y.w,y.b)}}
A.dB.prototype={
e8(){var x,w,v,u=this,t=u.r
t=B.ia(1000*t.a+t.b)
x=u.w
x=B.ia(1000*x.a+x.b)
w=u.x
v=B.T(w).h("G<1,a3<c,@>>")
w=B.Q(new B.G(w,new A.b6t(),v),v.h("aw.E"))
return B.ak(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p7(@)","a3<c,@>(p7)"])
A.bBl.prototype={
$1(d){var x=this.a
x.A(new A.bBk(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bBk.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fl(C.DS,this.b,null,null,w.$ti.h("fl<1>"))},
$S:0}
A.bBn.prototype={
$2(d,e){var x=this.a
x.A(new A.bBi(x,d,e))},
$S:14}
A.bBi.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fl(C.DS,null,this.b,this.c,w.$ti.h("fl<1>"))},
$S:0}
A.bBm.prototype={
$0(){var x=this.a
x.A(new A.bBj(x))},
$S:0}
A.bBj.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fl(D.lt,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6s.prototype={
$1(d){var x,w="createdAt",v=B.hm(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kM:C.vK,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p7(u,t,x,v.i(0,w) instanceof B.i9?B.oy(y.F.a(v.i(0,w)).gmr()):new B.cz(Date.now(),0,!1))},
$S:z+0}
A.b6t.prototype={
$1(d){return d.e8()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tA,B.R)
x(A.a1u,B.X)
w(B.hz,[A.bBl,A.b6s,A.b6t])
w(B.kw,[A.bBk,A.bBi,A.bBm,A.bBj])
x(A.bBn,B.k1)
x(A.VO,A.tA)
w(B.r3,[A.aiI,A.aiG])
w(B.A,[A.p7,A.dB])})()
B.n7(b.typeUniverse,JSON.parse('{"tA":{"R":[],"d":[]},"a1u":{"X":["tA<1,2>"]},"VO":{"tA":["1","fl<1>"],"R":[],"d":[],"tA.T":"1","tA.S":"fl<1>"}}'))
var y={B:B.a6("a3<@,@>"),w:B.a6("c"),v:B.a6("p7"),F:B.a6("i9"),b:B.a6("@"),d:B.a6("m<@>?")};(function constants(){C.DS=new B.GX(2,"active")
C.FG=new B.ag(58737,"MaterialIcons",null,!0)
C.vK=new A.aiG(0,"customer")
C.kM=new A.aiG(1,"admin")
C.hB=new A.aiI(0,"open")
C.mJ=new A.aiI(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"ctQ","NH",()=>B.q4())})()};
(a=>{a["+BmrgWFOyLIT3G3JsR7xDLgUwI4="]=a.current})($__dart_deferred_initializers__);