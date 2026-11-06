((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5I(d,e,f){return new A.VM(d,e,null,f.h("VM<0>"))},
tz:function tz(){},
a1u:function a1u(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bBj:function bBj(d){this.a=d},
bBi:function bBi(d,e){this.a=d
this.b=e},
bBl:function bBl(d){this.a=d},
bBg:function bBg(d,e,f){this.a=d
this.b=e
this.c=f},
bBk:function bBk(d){this.a=d},
bBh:function bBh(d){this.a=d},
VM:function VM(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bOj(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a4(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mI:C.hz
t=p.i(d,r) instanceof B.ia?B.ow(y.F.a(p.i(d,r)).gmt()):new B.cy(Date.now(),0,!1)
s=p.i(d,q) instanceof B.ia?B.ow(y.F.a(p.i(d,q)).gmt()):new B.cy(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dD(e,o,x,w,v,u,t,s,J.du(p,new A.b6n(),y.v).cS(0))},
aiG:function aiG(d,e){this.a=d
this.b=e},
aiE:function aiE(d,e){this.a=d
this.b=e},
p3:function p3(d,e,f,g){var _=this
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
b6n:function b6n(){},
b6o:function b6o(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tz.prototype={
a_(){return new A.a1u(this.$ti.h("a1u<tz.T,tz.S>"))}}
A.a1u.prototype={
au(){var x,w=this
w.aG()
x=w.a
x.toString
x=B.bSC(x.$ti.c)
w.e=x
w.Bu()},
aP(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2n()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.xe,x.b,x.c,x.d,x.$ti)}w.Bu()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yE(d,x)},
m(){this.a2n()
this.ar()},
Bu(){var x,w=this
w.d=w.a.c.lI(new A.bBj(w),new A.bBk(w),new A.bBl(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.DS,x.b,x.c,x.d,x.$ti)},
a2n(){var x=this.d
if(x!=null){x.aK(0)
this.d=null}}}
A.VM.prototype={
yE(d,e){return this.e.$2(d,e)}}
A.aiG.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiE.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p3.prototype={
eN(){var x=this,w=x.d
return B.ak(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ib(1000*w.a+w.b)],y.w,y.b)}}
A.dD.prototype={
eN(){var x,w,v,u=this,t=u.r
t=B.ib(1000*t.a+t.b)
x=u.w
x=B.ib(1000*x.a+x.b)
w=u.x
v=B.T(w).h("I<1,a6<c,@>>")
w=B.Q(new B.I(w,new A.b6o(),v),v.h("az.E"))
return B.ak(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p3(@)","a6<c,@>(p3)"])
A.bBj.prototype={
$1(d){var x=this.a
x.C(new A.bBi(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bBi.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fm(C.DT,this.b,null,null,w.$ti.h("fm<1>"))},
$S:0}
A.bBl.prototype={
$2(d,e){var x=this.a
x.C(new A.bBg(x,d,e))},
$S:14}
A.bBg.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fm(C.DT,null,this.b,this.c,w.$ti.h("fm<1>"))},
$S:0}
A.bBk.prototype={
$0(){var x=this.a
x.C(new A.bBh(x))},
$S:0}
A.bBh.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.lr,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6n.prototype={
$1(d){var x,w="createdAt",v=B.h6(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kL:C.vL,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p3(u,t,x,v.i(0,w) instanceof B.ia?B.ow(y.F.a(v.i(0,w)).gmt()):new B.cy(Date.now(),0,!1))},
$S:z+0}
A.b6o.prototype={
$1(d){return d.eN()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tz,B.R)
x(A.a1u,B.X)
w(B.hA,[A.bBj,A.b6n,A.b6o])
w(B.ks,[A.bBi,A.bBg,A.bBk,A.bBh])
x(A.bBl,B.k3)
x(A.VM,A.tz)
w(B.r1,[A.aiG,A.aiE])
w(B.A,[A.p3,A.dD])})()
B.n6(b.typeUniverse,JSON.parse('{"tz":{"R":[],"d":[]},"a1u":{"X":["tz<1,2>"]},"VM":{"tz":["1","fm<1>"],"R":[],"d":[],"tz.T":"1","tz.S":"fm<1>"}}'))
var y={B:B.a5("a6<@,@>"),w:B.a5("c"),v:B.a5("p3"),F:B.a5("ia"),b:B.a5("@"),d:B.a5("m<@>?")};(function constants(){C.DT=new B.GX(2,"active")
C.FD=new B.ai(58737,"MaterialIcons",null,!0)
C.vL=new A.aiE(0,"customer")
C.kL=new A.aiE(1,"admin")
C.hz=new A.aiG(0,"open")
C.mI=new A.aiG(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"ctI","NC",()=>B.q3())})()};
(a=>{a["ZiuP+gKXFv1kun9MBQjAfVfFka8="]=a.current})($__dart_deferred_initializers__);