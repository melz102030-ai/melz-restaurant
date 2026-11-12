((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5M(d,e,f){return new A.VN(d,e,null,f.h("VN<0>"))},
tu:function tu(){},
a1o:function a1o(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bBs:function bBs(d){this.a=d},
bBr:function bBr(d,e){this.a=d
this.b=e},
bBu:function bBu(d){this.a=d},
bBp:function bBp(d,e,f){this.a=d
this.b=e
this.c=f},
bBt:function bBt(d){this.a=d},
bBq:function bBq(d){this.a=d},
VN:function VN(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bOA(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a5(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mM:C.hC
t=p.i(d,r) instanceof B.ie?B.ow(y.F.a(p.i(d,r)).gmq()):new B.cz(Date.now(),0,!1)
s=p.i(d,q) instanceof B.ie?B.ow(y.F.a(p.i(d,q)).gmq()):new B.cz(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dD(e,o,x,w,v,u,t,s,J.ds(p,new A.b6r(),y.v).cM(0))},
aiC:function aiC(d,e){this.a=d
this.b=e},
aiA:function aiA(d,e){this.a=d
this.b=e},
p8:function p8(d,e,f,g){var _=this
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
b6r:function b6r(){},
b6s:function b6s(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tu.prototype={
a_(){return new A.a1o(this.$ti.h("a1o<tu.T,tu.S>"))}}
A.a1o.prototype={
au(){var x,w=this
w.aH()
x=w.a
x.toString
x=B.bSZ(x.$ti.c)
w.e=x
w.BE()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2H()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.xg,x.b,x.c,x.d,x.$ti)}w.BE()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yU(d,x)},
m(){this.a2H()
this.ar()},
BE(){var x,w=this
w.d=w.a.c.lJ(new A.bBs(w),new A.bBt(w),new A.bBu(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.E_,x.b,x.c,x.d,x.$ti)},
a2H(){var x=this.d
if(x!=null){x.aE(0)
this.d=null}}}
A.VN.prototype={
yU(d,e){return this.e.$2(d,e)}}
A.aiC.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiA.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p8.prototype={
eP(){var x=this,w=x.d
return B.an(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ig(1000*w.a+w.b)],y.w,y.b)}}
A.dD.prototype={
eP(){var x,w,v,u=this,t=u.r
t=B.ig(1000*t.a+t.b)
x=u.w
x=B.ig(1000*x.a+x.b)
w=u.x
v=B.U(w).h("J<1,a6<c,@>>")
w=B.Q(new B.J(w,new A.b6s(),v),v.h("az.E"))
return B.an(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p8(@)","a6<c,@>(p8)"])
A.bBs.prototype={
$1(d){var x=this.a
x.A(new A.bBr(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bBr.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fo(C.E0,this.b,null,null,w.$ti.h("fo<1>"))},
$S:0}
A.bBu.prototype={
$2(d,e){var x=this.a
x.A(new A.bBp(x,d,e))},
$S:14}
A.bBp.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fo(C.E0,null,this.b,this.c,w.$ti.h("fo<1>"))},
$S:0}
A.bBt.prototype={
$0(){var x=this.a
x.A(new A.bBq(x))},
$S:0}
A.bBq.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.ls,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6r.prototype={
$1(d){var x,w="createdAt",v=B.hb(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kO:C.vM,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p8(u,t,x,v.i(0,w) instanceof B.ie?B.ow(y.F.a(v.i(0,w)).gmq()):new B.cz(Date.now(),0,!1))},
$S:z+0}
A.b6s.prototype={
$1(d){return d.eP()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tu,B.R)
x(A.a1o,B.X)
w(B.hE,[A.bBs,A.b6r,A.b6s])
w(B.ku,[A.bBr,A.bBp,A.bBt,A.bBq])
x(A.bBu,B.k6)
x(A.VN,A.tu)
w(B.r1,[A.aiC,A.aiA])
w(B.A,[A.p8,A.dD])})()
B.nd(b.typeUniverse,JSON.parse('{"tu":{"R":[],"d":[]},"a1o":{"X":["tu<1,2>"]},"VN":{"tu":["1","fo<1>"],"R":[],"d":[],"tu.T":"1","tu.S":"fo<1>"}}'))
var y={B:B.a4("a6<@,@>"),w:B.a4("c"),v:B.a4("p8"),F:B.a4("ie"),b:B.a4("@"),d:B.a4("m<@>?")};(function constants(){C.E0=new B.GZ(2,"active")
C.FI=new B.ai(58737,"MaterialIcons",null,!0)
C.vM=new A.aiA(0,"customer")
C.kO=new A.aiA(1,"admin")
C.hC=new A.aiC(0,"open")
C.mM=new A.aiC(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"cuv","NF",()=>B.q6())})()};
(a=>{a["W0ckAY3l+9B64Wp8fl88zKvxe3w="]=a.current})($__dart_deferred_initializers__);