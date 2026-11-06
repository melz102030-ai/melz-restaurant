((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5U(d,e,f){return new A.VQ(d,e,null,f.h("VQ<0>"))},
tz:function tz(){},
a1x:function a1x(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bBE:function bBE(d){this.a=d},
bBD:function bBD(d,e){this.a=d
this.b=e},
bBG:function bBG(d){this.a=d},
bBB:function bBB(d,e,f){this.a=d
this.b=e
this.c=f},
bBF:function bBF(d){this.a=d},
bBC:function bBC(d){this.a=d},
VQ:function VQ(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bOP(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a3(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mJ:C.hA
t=p.i(d,r) instanceof B.ia?B.oy(y.F.a(p.i(d,r)).gmt()):new B.cz(Date.now(),0,!1)
s=p.i(d,q) instanceof B.ia?B.oy(y.F.a(p.i(d,q)).gmt()):new B.cz(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dD(e,o,x,w,v,u,t,s,J.dw(p,new A.b6z(),y.v).cJ(0))},
aiO:function aiO(d,e){this.a=d
this.b=e},
aiM:function aiM(d,e){this.a=d
this.b=e},
p7:function p7(d,e,f,g){var _=this
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
b6z:function b6z(){},
b6A:function b6A(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tz.prototype={
a_(){return new A.a1x(this.$ti.h("a1x<tz.T,tz.S>"))}}
A.a1x.prototype={
au(){var x,w=this
w.aH()
x=w.a
x.toString
x=B.bT6(x.$ti.c)
w.e=x
w.Bu()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2s()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.xi,x.b,x.c,x.d,x.$ti)}w.Bu()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yE(d,x)},
m(){this.a2s()
this.ar()},
Bu(){var x,w=this
w.d=w.a.c.lK(new A.bBE(w),new A.bBF(w),new A.bBG(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.DR,x.b,x.c,x.d,x.$ti)},
a2s(){var x=this.d
if(x!=null){x.aK(0)
this.d=null}}}
A.VQ.prototype={
yE(d,e){return this.e.$2(d,e)}}
A.aiO.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiM.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p7.prototype={
e8(){var x=this,w=x.d
return B.ak(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ib(1000*w.a+w.b)],y.w,y.b)}}
A.dD.prototype={
e8(){var x,w,v,u=this,t=u.r
t=B.ib(1000*t.a+t.b)
x=u.w
x=B.ib(1000*x.a+x.b)
w=u.x
v=B.T(w).h("H<1,a5<c,@>>")
w=B.Q(new B.H(w,new A.b6A(),v),v.h("aw.E"))
return B.ak(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p7(@)","a5<c,@>(p7)"])
A.bBE.prototype={
$1(d){var x=this.a
x.A(new A.bBD(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bBD.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fm(C.DS,this.b,null,null,w.$ti.h("fm<1>"))},
$S:0}
A.bBG.prototype={
$2(d,e){var x=this.a
x.A(new A.bBB(x,d,e))},
$S:14}
A.bBB.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fm(C.DS,null,this.b,this.c,w.$ti.h("fm<1>"))},
$S:0}
A.bBF.prototype={
$0(){var x=this.a
x.A(new A.bBC(x))},
$S:0}
A.bBC.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.lt,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6z.prototype={
$1(d){var x,w="createdAt",v=B.h8(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kN:C.vN,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p7(u,t,x,v.i(0,w) instanceof B.ia?B.oy(y.F.a(v.i(0,w)).gmt()):new B.cz(Date.now(),0,!1))},
$S:z+0}
A.b6A.prototype={
$1(d){return d.e8()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tz,B.R)
x(A.a1x,B.X)
w(B.hA,[A.bBE,A.b6z,A.b6A])
w(B.kz,[A.bBD,A.bBB,A.bBF,A.bBC])
x(A.bBG,B.k3)
x(A.VQ,A.tz)
w(B.r3,[A.aiO,A.aiM])
w(B.A,[A.p7,A.dD])})()
B.n9(b.typeUniverse,JSON.parse('{"tz":{"R":[],"d":[]},"a1x":{"X":["tz<1,2>"]},"VQ":{"tz":["1","fm<1>"],"R":[],"d":[],"tz.T":"1","tz.S":"fm<1>"}}'))
var y={B:B.a6("a5<@,@>"),w:B.a6("c"),v:B.a6("p7"),F:B.a6("ia"),b:B.a6("@"),d:B.a6("m<@>?")};(function constants(){C.DS=new B.GX(2,"active")
C.FG=new B.ag(58737,"MaterialIcons",null,!0)
C.vN=new A.aiM(0,"customer")
C.kN=new A.aiM(1,"admin")
C.hA=new A.aiO(0,"open")
C.mJ=new A.aiO(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"cub","NI",()=>B.q5())})()};
(a=>{a["ze05vS/AUpkNlKLcTjVzt8iag2Q="]=a.current})($__dart_deferred_initializers__);