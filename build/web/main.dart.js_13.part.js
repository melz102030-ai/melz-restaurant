((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5J(d,e,f){return new A.VN(d,e,null,f.h("VN<0>"))},
tx:function tx(){},
a1v:function a1v(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bBo:function bBo(d){this.a=d},
bBn:function bBn(d,e){this.a=d
this.b=e},
bBq:function bBq(d){this.a=d},
bBl:function bBl(d,e,f){this.a=d
this.b=e
this.c=f},
bBp:function bBp(d){this.a=d},
bBm:function bBm(d){this.a=d},
VN:function VN(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bOq(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a5(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mH:C.hA
t=p.i(d,r) instanceof B.ia?B.oy(y.F.a(p.i(d,r)).gmt()):new B.cz(Date.now(),0,!1)
s=p.i(d,q) instanceof B.ia?B.oy(y.F.a(p.i(d,q)).gmt()):new B.cz(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dD(e,o,x,w,v,u,t,s,J.ds(p,new A.b6o(),y.v).cM(0))},
aiH:function aiH(d,e){this.a=d
this.b=e},
aiF:function aiF(d,e){this.a=d
this.b=e},
p5:function p5(d,e,f,g){var _=this
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
b6o:function b6o(){},
b6p:function b6p(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tx.prototype={
a_(){return new A.a1v(this.$ti.h("a1v<tx.T,tx.S>"))}}
A.a1v.prototype={
au(){var x,w=this
w.aG()
x=w.a
x.toString
x=B.bSJ(x.$ti.c)
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
return w.yF(d,x)},
m(){this.a2n()
this.ar()},
Bu(){var x,w=this
w.d=w.a.c.lJ(new A.bBo(w),new A.bBp(w),new A.bBq(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.DS,x.b,x.c,x.d,x.$ti)},
a2n(){var x=this.d
if(x!=null){x.aK(0)
this.d=null}}}
A.VN.prototype={
yF(d,e){return this.e.$2(d,e)}}
A.aiH.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiF.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p5.prototype={
eN(){var x=this,w=x.d
return B.al(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ib(1000*w.a+w.b)],y.w,y.b)}}
A.dD.prototype={
eN(){var x,w,v,u=this,t=u.r
t=B.ib(1000*t.a+t.b)
x=u.w
x=B.ib(1000*x.a+x.b)
w=u.x
v=B.U(w).h("I<1,a4<c,@>>")
w=B.Q(new B.I(w,new A.b6p(),v),v.h("az.E"))
return B.al(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p5(@)","a4<c,@>(p5)"])
A.bBo.prototype={
$1(d){var x=this.a
x.B(new A.bBn(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bBn.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fm(C.DT,this.b,null,null,w.$ti.h("fm<1>"))},
$S:0}
A.bBq.prototype={
$2(d,e){var x=this.a
x.B(new A.bBl(x,d,e))},
$S:14}
A.bBl.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fm(C.DT,null,this.b,this.c,w.$ti.h("fm<1>"))},
$S:0}
A.bBp.prototype={
$0(){var x=this.a
x.B(new A.bBm(x))},
$S:0}
A.bBm.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fm(D.lq,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6o.prototype={
$1(d){var x,w="createdAt",v=B.h7(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kL:C.vL,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p5(u,t,x,v.i(0,w) instanceof B.ia?B.oy(y.F.a(v.i(0,w)).gmt()):new B.cz(Date.now(),0,!1))},
$S:z+0}
A.b6p.prototype={
$1(d){return d.eN()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tx,B.R)
x(A.a1v,B.X)
w(B.hA,[A.bBo,A.b6o,A.b6p])
w(B.ks,[A.bBn,A.bBl,A.bBp,A.bBm])
x(A.bBq,B.k3)
x(A.VN,A.tx)
w(B.r2,[A.aiH,A.aiF])
w(B.A,[A.p5,A.dD])})()
B.n7(b.typeUniverse,JSON.parse('{"tx":{"R":[],"d":[]},"a1v":{"X":["tx<1,2>"]},"VN":{"tx":["1","fm<1>"],"R":[],"d":[],"tx.T":"1","tx.S":"fm<1>"}}'))
var y={B:B.a6("a4<@,@>"),w:B.a6("c"),v:B.a6("p5"),F:B.a6("ia"),b:B.a6("@"),d:B.a6("m<@>?")};(function constants(){C.DT=new B.GW(2,"active")
C.FD=new B.ai(58737,"MaterialIcons",null,!0)
C.vL=new A.aiF(0,"customer")
C.kL=new A.aiF(1,"admin")
C.hA=new A.aiH(0,"open")
C.mH=new A.aiH(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"ctR","NC",()=>B.q4())})()};
(a=>{a["tCwvQk/HP+9DbJ50KWKWETcQvjA="]=a.current})($__dart_deferred_initializers__);