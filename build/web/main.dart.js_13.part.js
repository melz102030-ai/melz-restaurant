((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5i(d,e,f){return new A.VD(d,e,null,f.h("VD<0>"))},
tw:function tw(){},
a1h:function a1h(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bAC:function bAC(d){this.a=d},
bAB:function bAB(d,e){this.a=d
this.b=e},
bAE:function bAE(d){this.a=d},
bAz:function bAz(d,e,f){this.a=d
this.b=e
this.c=f},
bAD:function bAD(d){this.a=d},
bAA:function bAA(d){this.a=d},
VD:function VD(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bNF(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a5(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mK:C.hA
t=p.i(d,r) instanceof B.is?B.pU(y.F.a(p.i(d,r)).gne()):new B.cG(Date.now(),0,!1)
s=p.i(d,q) instanceof B.is?B.pU(y.F.a(p.i(d,q)).gne()):new B.cG(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dz(e,o,x,w,v,u,t,s,J.dG(p,new A.b5Y(),y.v).cK(0))},
ait:function ait(d,e){this.a=d
this.b=e},
air:function air(d,e){this.a=d
this.b=e},
p0:function p0(d,e,f,g){var _=this
_.a=d
_.b=e
_.c=f
_.d=g},
dz:function dz(d,e,f,g,h,i,j,k,l){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h
_.f=i
_.r=j
_.w=k
_.x=l},
b5Y:function b5Y(){},
b5Z:function b5Z(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tw.prototype={
a_(){return new A.a1h(this.$ti.h("a1h<tw.T,tw.S>"))}}
A.a1h.prototype={
au(){var x,w=this
w.aI()
x=w.a
x.toString
x=B.bRW(x.$ti.c)
w.e=x
w.Bl()},
aP(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2h()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fh(D.xc,x.b,x.c,x.d,x.$ti)}w.Bl()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yz(d,x)},
m(){this.a2h()
this.ar()},
Bl(){var x,w=this
w.d=w.a.c.lH(new A.bAC(w),new A.bAD(w),new A.bAE(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fh(D.DL,x.b,x.c,x.d,x.$ti)},
a2h(){var x=this.d
if(x!=null){x.aK(0)
this.d=null}}}
A.VD.prototype={
yz(d,e){return this.e.$2(d,e)}}
A.ait.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.air.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p0.prototype={
en(){var x=this,w=x.d
return B.al(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.it(1000*w.a+w.b)],y.w,y.b)}}
A.dz.prototype={
en(){var x,w,v,u=this,t=u.r
t=B.it(1000*t.a+t.b)
x=u.w
x=B.it(1000*x.a+x.b)
w=u.x
v=B.T(w).h("G<1,a4<c,@>>")
w=B.Q(new B.G(w,new A.b5Z(),v),v.h("aw.E"))
return B.al(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p0(@)","a4<c,@>(p0)"])
A.bAC.prototype={
$1(d){var x=this.a
x.C(new A.bAB(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bAB.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fh(C.DM,this.b,null,null,w.$ti.h("fh<1>"))},
$S:0}
A.bAE.prototype={
$2(d,e){var x=this.a
x.C(new A.bAz(x,d,e))},
$S:14}
A.bAz.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fh(C.DM,null,this.b,this.c,w.$ti.h("fh<1>"))},
$S:0}
A.bAD.prototype={
$0(){var x=this.a
x.C(new A.bAA(x))},
$S:0}
A.bAA.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fh(D.ls,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b5Y.prototype={
$1(d){var x,w="createdAt",v=B.im(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kK:C.vH,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p0(u,t,x,v.i(0,w) instanceof B.is?B.pU(y.F.a(v.i(0,w)).gne()):new B.cG(Date.now(),0,!1))},
$S:z+0}
A.b5Z.prototype={
$1(d){return d.en()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tw,B.R)
x(A.a1h,B.X)
w(B.hv,[A.bAC,A.b5Y,A.b5Z])
w(B.ks,[A.bAB,A.bAz,A.bAD,A.bAA])
x(A.bAE,B.jW)
x(A.VD,A.tw)
w(B.qZ,[A.ait,A.air])
w(B.A,[A.p0,A.dz])})()
B.n_(b.typeUniverse,JSON.parse('{"tw":{"R":[],"d":[]},"a1h":{"X":["tw<1,2>"]},"VD":{"tw":["1","fh<1>"],"R":[],"d":[],"tw.T":"1","tw.S":"fh<1>"}}'))
var y={B:B.a6("a4<@,@>"),w:B.a6("c"),v:B.a6("p0"),F:B.a6("is"),b:B.a6("@"),d:B.a6("m<@>?")};(function constants(){C.DM=new B.GS(2,"active")
C.FC=new B.aj(58737,"MaterialIcons",null,!0)
C.vH=new A.air(0,"customer")
C.kK=new A.air(1,"admin")
C.hA=new A.ait(0,"open")
C.mK=new A.ait(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"csQ","Nz",()=>B.rJ())})()};
(a=>{a["rABHkP9NG5MEF7iZw1vU9ADG23I="]=a.current})($__dart_deferred_initializers__);