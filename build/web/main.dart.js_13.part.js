((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b6K(d,e,f){return new A.W3(d,e,null,f.h("W3<0>"))},
tz:function tz(){},
a1K:function a1K(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bCY:function bCY(d){this.a=d},
bCX:function bCX(d,e){this.a=d
this.b=e},
bD_:function bD_(d){this.a=d},
bCV:function bCV(d,e,f){this.a=d
this.b=e
this.c=f},
bCZ:function bCZ(d){this.a=d},
bCW:function bCW(d){this.a=d},
W3:function W3(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bQj(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a7(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mO:C.hG
t=p.i(d,r) instanceof B.i_?B.nF(y.F.a(p.i(d,r)).glM()):new B.cD(Date.now(),0,!1)
s=p.i(d,q) instanceof B.i_?B.nF(y.F.a(p.i(d,q)).glM()):new B.cD(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dD(e,o,x,w,v,u,t,s,J.dk(p,new A.b7p(),y.v).cM(0))},
aj0:function aj0(d,e){this.a=d
this.b=e},
aiZ:function aiZ(d,e){this.a=d
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
b7p:function b7p(){},
b7q:function b7q(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[32]
A.tz.prototype={
Z(){return new A.a1K(this.$ti.h("a1K<tz.T,tz.S>"))}}
A.a1K.prototype={
au(){var x,w=this
w.aH()
x=w.a
x.toString
x=B.bUF(x.$ti.c)
w.e=x
w.BM()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2T()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.xj,x.b,x.c,x.d,x.$ti)}w.BM()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.z1(d,x)},
m(){this.a2T()
this.ar()},
BM(){var x,w=this
w.d=w.a.c.lL(new A.bCY(w),new A.bCZ(w),new A.bD_(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.E5,x.b,x.c,x.d,x.$ti)},
a2T(){var x=this.d
if(x!=null){x.aC(0)
this.d=null}}}
A.W3.prototype={
z1(d,e){return this.e.$2(d,e)}}
A.aj0.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiZ.prototype={
L(){return"SupportSenderRole."+this.b}}
A.pd.prototype={
eR(){var x=this,w=x.d
return B.ag(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ih(1000*w.a+w.b)],y.w,y.b)}}
A.dD.prototype={
eR(){var x,w,v,u=this,t=u.r
t=B.ih(1000*t.a+t.b)
x=u.w
x=B.ih(1000*x.a+x.b)
w=u.x
v=B.T(w).h("H<1,a5<c,@>>")
w=B.P(new B.H(w,new A.b7q(),v),v.h("ax.E"))
return B.ag(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["pd(@)","a5<c,@>(pd)"])
A.bCY.prototype={
$1(d){var x=this.a
x.u(new A.bCX(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bCX.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fr(C.E6,this.b,null,null,w.$ti.h("fr<1>"))},
$S:0}
A.bD_.prototype={
$2(d,e){var x=this.a
x.u(new A.bCV(x,d,e))},
$S:14}
A.bCV.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fr(C.E6,null,this.b,this.c,w.$ti.h("fr<1>"))},
$S:0}
A.bCZ.prototype={
$0(){var x=this.a
x.u(new A.bCW(x))},
$S:0}
A.bCW.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.lu,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b7p.prototype={
$1(d){var x,w="createdAt",v=B.h_(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kR:C.vN,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.pd(u,t,x,v.i(0,w) instanceof B.i_?B.nF(y.F.a(v.i(0,w)).glM()):new B.cD(Date.now(),0,!1))},
$S:z+0}
A.b7q.prototype={
$1(d){return d.eR()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tz,B.R)
x(A.a1K,B.X)
w(B.hG,[A.bCY,A.b7p,A.b7q])
w(B.kB,[A.bCX,A.bCV,A.bCZ,A.bCW])
x(A.bD_,B.kd)
x(A.W3,A.tz)
w(B.r7,[A.aj0,A.aiZ])
w(B.A,[A.pd,A.dD])})()
B.nj(b.typeUniverse,JSON.parse('{"tz":{"R":[],"d":[]},"a1K":{"X":["tz<1,2>"]},"W3":{"tz":["1","fr<1>"],"R":[],"d":[],"tz.T":"1","tz.S":"fr<1>"}}'))
var y={B:B.a6("a5<@,@>"),w:B.a6("c"),v:B.a6("pd"),F:B.a6("i_"),b:B.a6("@"),d:B.a6("n<@>?")};(function constants(){C.E6=new B.Hc(2,"active")
C.FQ=new B.ah(58737,"MaterialIcons",null,!0)
C.vN=new A.aiZ(0,"customer")
C.kR=new A.aiZ(1,"admin")
C.hG=new A.aj0(0,"open")
C.mO=new A.aj0(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"cwq","NZ",()=>B.qf())})()};
(a=>{a["qjxs9F6d0RFNhGjcMmnSIzNN8yA="]=a.current})($__dart_deferred_initializers__);