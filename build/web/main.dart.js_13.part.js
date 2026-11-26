((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b6z(d,e,f){return new A.W3(d,e,null,f.h("W3<0>"))},
tx:function tx(){},
a1M:function a1M(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bCZ:function bCZ(d){this.a=d},
bCY:function bCY(d,e){this.a=d
this.b=e},
bD0:function bD0(d){this.a=d},
bCW:function bCW(d,e,f){this.a=d
this.b=e
this.c=f},
bD_:function bD_(d){this.a=d},
bCX:function bCX(d){this.a=d},
W3:function W3(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bQh(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a9(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mQ:C.hH
t=p.i(d,r) instanceof B.i_?B.nG(y.F.a(p.i(d,r)).glL()):new B.cz(Date.now(),0,!1)
s=p.i(d,q) instanceof B.i_?B.nG(y.F.a(p.i(d,q)).glL()):new B.cz(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dD(e,o,x,w,v,u,t,s,J.dk(p,new A.b7e(),y.v).cK(0))},
aj1:function aj1(d,e){this.a=d
this.b=e},
aj_:function aj_(d,e){this.a=d
this.b=e},
pd:function pd(d,e,f,g){var _=this
_.a=d
_.b=e
_.c=f
_.d=g},
dD:function dD(d,e,f,g,h,i,j,k,l){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h
_.f=i
_.r=j
_.w=k
_.x=l},
b7e:function b7e(){},
b7f:function b7f(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[32]
A.tx.prototype={
Z(){return new A.a1M(this.$ti.h("a1M<tx.T,tx.S>"))}}
A.a1M.prototype={
au(){var x,w=this
w.aH()
x=w.a
x.toString
x=B.bUF(x.$ti.c)
w.e=x
w.BJ()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2P()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.xk,x.b,x.c,x.d,x.$ti)}w.BJ()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.z_(d,x)},
m(){this.a2P()
this.ar()},
BJ(){var x,w=this
w.d=w.a.c.lK(new A.bCZ(w),new A.bD_(w),new A.bD0(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.E4,x.b,x.c,x.d,x.$ti)},
a2P(){var x=this.d
if(x!=null){x.aC(0)
this.d=null}}}
A.W3.prototype={
z_(d,e){return this.e.$2(d,e)}}
A.aj1.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aj_.prototype={
L(){return"SupportSenderRole."+this.b}}
A.pd.prototype={
ev(){var x=this,w=x.d
return B.ak(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ih(1000*w.a+w.b)],y.w,y.b)}}
A.dD.prototype={
ev(){var x,w,v,u=this,t=u.r
t=B.ih(1000*t.a+t.b)
x=u.w
x=B.ih(1000*x.a+x.b)
w=u.x
v=B.T(w).h("H<1,a7<c,@>>")
w=B.P(new B.H(w,new A.b7f(),v),v.h("ax.E"))
return B.ak(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["pd(@)","a7<c,@>(pd)"])
A.bCZ.prototype={
$1(d){var x=this.a
x.u(new A.bCY(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bCY.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fr(C.E5,this.b,null,null,w.$ti.h("fr<1>"))},
$S:0}
A.bD0.prototype={
$2(d,e){var x=this.a
x.u(new A.bCW(x,d,e))},
$S:13}
A.bCW.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fr(C.E5,null,this.b,this.c,w.$ti.h("fr<1>"))},
$S:0}
A.bD_.prototype={
$0(){var x=this.a
x.u(new A.bCX(x))},
$S:0}
A.bCX.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.lw,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b7e.prototype={
$1(d){var x,w="createdAt",v=B.fZ(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kT:C.vO,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.pd(u,t,x,v.i(0,w) instanceof B.i_?B.nG(y.F.a(v.i(0,w)).glL()):new B.cz(Date.now(),0,!1))},
$S:z+0}
A.b7f.prototype={
$1(d){return d.ev()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tx,B.R)
x(A.a1M,B.X)
w(B.hG,[A.bCZ,A.b7e,A.b7f])
w(B.kB,[A.bCY,A.bCW,A.bD_,A.bCX])
x(A.bD0,B.ke)
x(A.W3,A.tx)
w(B.r4,[A.aj1,A.aj_])
w(B.A,[A.pd,A.dD])})()
B.nj(b.typeUniverse,JSON.parse('{"tx":{"R":[],"d":[]},"a1M":{"X":["tx<1,2>"]},"W3":{"tx":["1","fr<1>"],"R":[],"d":[],"tx.T":"1","tx.S":"fr<1>"}}'))
var y={B:B.a8("a7<@,@>"),w:B.a8("c"),v:B.a8("pd"),F:B.a8("i_"),b:B.a8("@"),d:B.a8("n<@>?")};(function constants(){C.E5=new B.Hc(2,"active")
C.FR=new B.ah(58737,"MaterialIcons",null,!0)
C.vO=new A.aj_(0,"customer")
C.kT=new A.aj_(1,"admin")
C.hH=new A.aj1(0,"open")
C.mQ=new A.aj1(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"cwq","NV",()=>B.qb())})()};
(a=>{a["PlTcZB3+SCJEMKTJSNeMSA8Qs5c="]=a.current})($__dart_deferred_initializers__);