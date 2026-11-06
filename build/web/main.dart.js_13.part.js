((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b6_(d,e,f){return new A.VT(d,e,null,f.h("VT<0>"))},
tB:function tB(){},
a1y:function a1y(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bBQ:function bBQ(d){this.a=d},
bBP:function bBP(d,e){this.a=d
this.b=e},
bBS:function bBS(d){this.a=d},
bBN:function bBN(d,e,f){this.a=d
this.b=e
this.c=f},
bBR:function bBR(d){this.a=d},
bBO:function bBO(d){this.a=d},
VT:function VT(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bP_(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a5(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mP:C.hE
t=p.i(d,r) instanceof B.ia?B.oA(y.F.a(p.i(d,r)).gmw()):new B.cA(Date.now(),0,!1)
s=p.i(d,q) instanceof B.ia?B.oA(y.F.a(p.i(d,q)).gmw()):new B.cA(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dB(e,o,x,w,v,u,t,s,J.dH(p,new A.b6F(),y.v).cN(0))},
aiS:function aiS(d,e){this.a=d
this.b=e},
aiQ:function aiQ(d,e){this.a=d
this.b=e},
p9:function p9(d,e,f,g){var _=this
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
b6F:function b6F(){},
b6G:function b6G(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tB.prototype={
Z(){return new A.a1y(this.$ti.h("a1y<tB.T,tB.S>"))}}
A.a1y.prototype={
ar(){var x,w=this
w.aG()
x=w.a
x.toString
x=B.bTi(x.$ti.c)
w.e=x
w.BI()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2I()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.xp,x.b,x.c,x.d,x.$ti)}w.BI()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yS(d,x)},
m(){this.a2I()
this.av()},
BI(){var x,w=this
w.d=w.a.c.lP(new A.bBQ(w),new A.bBR(w),new A.bBS(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.E5,x.b,x.c,x.d,x.$ti)},
a2I(){var x=this.d
if(x!=null){x.aM(0)
this.d=null}}}
A.VT.prototype={
yS(d,e){return this.e.$2(d,e)}}
A.aiS.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiQ.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p9.prototype={
ea(){var x=this,w=x.d
return B.ak(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ib(1000*w.a+w.b)],y.w,y.b)}}
A.dB.prototype={
ea(){var x,w,v,u=this,t=u.r
t=B.ib(1000*t.a+t.b)
x=u.w
x=B.ib(1000*x.a+x.b)
w=u.x
v=B.T(w).h("G<1,a3<c,@>>")
w=B.Q(new B.G(w,new A.b6G(),v),v.h("aw.E"))
return B.ak(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p9(@)","a3<c,@>(p9)"])
A.bBQ.prototype={
$1(d){var x=this.a
x.A(new A.bBP(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bBP.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fm(C.E6,this.b,null,null,w.$ti.h("fm<1>"))},
$S:0}
A.bBS.prototype={
$2(d,e){var x=this.a
x.A(new A.bBN(x,d,e))},
$S:14}
A.bBN.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fm(C.E6,null,this.b,this.c,w.$ti.h("fm<1>"))},
$S:0}
A.bBR.prototype={
$0(){var x=this.a
x.A(new A.bBO(x))},
$S:0}
A.bBO.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.lz,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6F.prototype={
$1(d){var x,w="createdAt",v=B.hm(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kR:C.vU,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p9(u,t,x,v.i(0,w) instanceof B.ia?B.oA(y.F.a(v.i(0,w)).gmw()):new B.cA(Date.now(),0,!1))},
$S:z+0}
A.b6G.prototype={
$1(d){return d.ea()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tB,B.R)
x(A.a1y,B.X)
w(B.hA,[A.bBQ,A.b6F,A.b6G])
w(B.kx,[A.bBP,A.bBN,A.bBR,A.bBO])
x(A.bBS,B.k1)
x(A.VT,A.tB)
w(B.r4,[A.aiS,A.aiQ])
w(B.A,[A.p9,A.dB])})()
B.n8(b.typeUniverse,JSON.parse('{"tB":{"R":[],"d":[]},"a1y":{"X":["tB<1,2>"]},"VT":{"tB":["1","fm<1>"],"R":[],"d":[],"tB.T":"1","tB.S":"fm<1>"}}'))
var y={B:B.a4("a3<@,@>"),w:B.a4("c"),v:B.a4("p9"),F:B.a4("ia"),b:B.a4("@"),d:B.a4("m<@>?")};(function constants(){C.E6=new B.H0(2,"active")
C.FV=new B.ag(58737,"MaterialIcons",null,!0)
C.vU=new A.aiQ(0,"customer")
C.kR=new A.aiQ(1,"admin")
C.hE=new A.aiS(0,"open")
C.mP=new A.aiS(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"cum","NM",()=>B.q5())})()};
(a=>{a["ADHN9IBnRqwPQE+TdPqLtRPQ0co="]=a.current})($__dart_deferred_initializers__);