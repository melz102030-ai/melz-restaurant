((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5S(d,e,f){return new A.VP(d,e,null,f.h("VP<0>"))},
tA:function tA(){},
a1w:function a1w(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bBu:function bBu(d){this.a=d},
bBt:function bBt(d,e){this.a=d
this.b=e},
bBw:function bBw(d){this.a=d},
bBr:function bBr(d,e,f){this.a=d
this.b=e
this.c=f},
bBv:function bBv(d){this.a=d},
bBs:function bBs(d){this.a=d},
VP:function VP(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bOD(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a4(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mJ:C.hB
t=p.i(d,r) instanceof B.ia?B.oy(y.F.a(p.i(d,r)).gmt()):new B.cz(Date.now(),0,!1)
s=p.i(d,q) instanceof B.ia?B.oy(y.F.a(p.i(d,q)).gmt()):new B.cz(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dC(e,o,x,w,v,u,t,s,J.dG(p,new A.b6x(),y.v).cK(0))},
aiL:function aiL(d,e){this.a=d
this.b=e},
aiJ:function aiJ(d,e){this.a=d
this.b=e},
p7:function p7(d,e,f,g){var _=this
_.a=d
_.b=e
_.c=f
_.d=g},
dC:function dC(d,e,f,g,h,i,j,k,l){var _=this
_.a=d
_.b=e
_.c=f
_.d=g
_.e=h
_.f=i
_.r=j
_.w=k
_.x=l},
b6x:function b6x(){},
b6y:function b6y(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tA.prototype={
a_(){return new A.a1w(this.$ti.h("a1w<tA.T,tA.S>"))}}
A.a1w.prototype={
au(){var x,w=this
w.aH()
x=w.a
x.toString
x=B.bSW(x.$ti.c)
w.e=x
w.Bt()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2s()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fl(D.xf,x.b,x.c,x.d,x.$ti)}w.Bt()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yD(d,x)},
m(){this.a2s()
this.ar()},
Bt(){var x,w=this
w.d=w.a.c.lK(new A.bBu(w),new A.bBv(w),new A.bBw(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fl(D.DQ,x.b,x.c,x.d,x.$ti)},
a2s(){var x=this.d
if(x!=null){x.aK(0)
this.d=null}}}
A.VP.prototype={
yD(d,e){return this.e.$2(d,e)}}
A.aiL.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiJ.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p7.prototype={
e8(){var x=this,w=x.d
return B.ak(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ib(1000*w.a+w.b)],y.w,y.b)}}
A.dC.prototype={
e8(){var x,w,v,u=this,t=u.r
t=B.ib(1000*t.a+t.b)
x=u.w
x=B.ib(1000*x.a+x.b)
w=u.x
v=B.T(w).h("G<1,a3<c,@>>")
w=B.Q(new B.G(w,new A.b6y(),v),v.h("aw.E"))
return B.ak(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p7(@)","a3<c,@>(p7)"])
A.bBu.prototype={
$1(d){var x=this.a
x.A(new A.bBt(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bBt.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fl(C.DR,this.b,null,null,w.$ti.h("fl<1>"))},
$S:0}
A.bBw.prototype={
$2(d,e){var x=this.a
x.A(new A.bBr(x,d,e))},
$S:14}
A.bBr.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fl(C.DR,null,this.b,this.c,w.$ti.h("fl<1>"))},
$S:0}
A.bBv.prototype={
$0(){var x=this.a
x.A(new A.bBs(x))},
$S:0}
A.bBs.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fl(D.lt,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6x.prototype={
$1(d){var x,w="createdAt",v=B.hm(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kM:C.vK,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p7(u,t,x,v.i(0,w) instanceof B.ia?B.oy(y.F.a(v.i(0,w)).gmt()):new B.cz(Date.now(),0,!1))},
$S:z+0}
A.b6y.prototype={
$1(d){return d.e8()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tA,B.R)
x(A.a1w,B.X)
w(B.hz,[A.bBu,A.b6x,A.b6y])
w(B.kx,[A.bBt,A.bBr,A.bBv,A.bBs])
x(A.bBw,B.k1)
x(A.VP,A.tA)
w(B.r3,[A.aiL,A.aiJ])
w(B.A,[A.p7,A.dC])})()
B.n8(b.typeUniverse,JSON.parse('{"tA":{"R":[],"d":[]},"a1w":{"X":["tA<1,2>"]},"VP":{"tA":["1","fl<1>"],"R":[],"d":[],"tA.T":"1","tA.S":"fl<1>"}}'))
var y={B:B.a6("a3<@,@>"),w:B.a6("c"),v:B.a6("p7"),F:B.a6("ia"),b:B.a6("@"),d:B.a6("m<@>?")};(function constants(){C.DR=new B.GX(2,"active")
C.FH=new B.ag(58737,"MaterialIcons",null,!0)
C.vK=new A.aiJ(0,"customer")
C.kM=new A.aiJ(1,"admin")
C.hB=new A.aiL(0,"open")
C.mJ=new A.aiL(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"ctZ","NI",()=>B.q5())})()};
(a=>{a["cBek8ptevO7GBCczevQZIrY3iq8="]=a.current})($__dart_deferred_initializers__);