((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b65(d,e,f){return new A.VW(d,e,null,f.h("VW<0>"))},
tu:function tu(){},
a1B:function a1B(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bC3:function bC3(d){this.a=d},
bC2:function bC2(d,e){this.a=d
this.b=e},
bC5:function bC5(d){this.a=d},
bC0:function bC0(d,e,f){this.a=d
this.b=e
this.c=f},
bC4:function bC4(d){this.a=d},
bC1:function bC1(d){this.a=d},
VW:function VW(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bPe(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a5(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mM:C.hE
t=p.i(d,r) instanceof B.ie?B.oz(y.F.a(p.i(d,r)).gmr()):new B.cz(Date.now(),0,!1)
s=p.i(d,q) instanceof B.ie?B.oz(y.F.a(p.i(d,q)).gmr()):new B.cz(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dC(e,o,x,w,v,u,t,s,J.ds(p,new A.b6L(),y.v).cM(0))},
aiP:function aiP(d,e){this.a=d
this.b=e},
aiN:function aiN(d,e){this.a=d
this.b=e},
pa:function pa(d,e,f,g){var _=this
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
b6L:function b6L(){},
b6M:function b6M(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tu.prototype={
Z(){return new A.a1B(this.$ti.h("a1B<tu.T,tu.S>"))}}
A.a1B.prototype={
au(){var x,w=this
w.aI()
x=w.a
x.toString
x=B.bTD(x.$ti.c)
w.e=x
w.BJ()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2L()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.xi,x.b,x.c,x.d,x.$ti)}w.BJ()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yZ(d,x)},
m(){this.a2L()
this.ar()},
BJ(){var x,w=this
w.d=w.a.c.lK(new A.bC3(w),new A.bC4(w),new A.bC5(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.E1,x.b,x.c,x.d,x.$ti)},
a2L(){var x=this.d
if(x!=null){x.aC(0)
this.d=null}}}
A.VW.prototype={
yZ(d,e){return this.e.$2(d,e)}}
A.aiP.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiN.prototype={
L(){return"SupportSenderRole."+this.b}}
A.pa.prototype={
eQ(){var x=this,w=x.d
return B.am(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ig(1000*w.a+w.b)],y.w,y.b)}}
A.dC.prototype={
eQ(){var x,w,v,u=this,t=u.r
t=B.ig(1000*t.a+t.b)
x=u.w
x=B.ig(1000*x.a+x.b)
w=u.x
v=B.T(w).h("J<1,a7<c,@>>")
w=B.Q(new B.J(w,new A.b6M(),v),v.h("az.E"))
return B.am(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["pa(@)","a7<c,@>(pa)"])
A.bC3.prototype={
$1(d){var x=this.a
x.A(new A.bC2(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bC2.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fo(C.E2,this.b,null,null,w.$ti.h("fo<1>"))},
$S:0}
A.bC5.prototype={
$2(d,e){var x=this.a
x.A(new A.bC0(x,d,e))},
$S:14}
A.bC0.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fo(C.E2,null,this.b,this.c,w.$ti.h("fo<1>"))},
$S:0}
A.bC4.prototype={
$0(){var x=this.a
x.A(new A.bC1(x))},
$S:0}
A.bC1.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.lt,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6L.prototype={
$1(d){var x,w="createdAt",v=B.hd(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kQ:C.vN,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.pa(u,t,x,v.i(0,w) instanceof B.ie?B.oz(y.F.a(v.i(0,w)).gmr()):new B.cz(Date.now(),0,!1))},
$S:z+0}
A.b6M.prototype={
$1(d){return d.eQ()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tu,B.R)
x(A.a1B,B.X)
w(B.hF,[A.bC3,A.b6L,A.b6M])
w(B.ku,[A.bC2,A.bC0,A.bC4,A.bC1])
x(A.bC5,B.k6)
x(A.VW,A.tu)
w(B.r1,[A.aiP,A.aiN])
w(B.A,[A.pa,A.dC])})()
B.nf(b.typeUniverse,JSON.parse('{"tu":{"R":[],"d":[]},"a1B":{"X":["tu<1,2>"]},"VW":{"tu":["1","fo<1>"],"R":[],"d":[],"tu.T":"1","tu.S":"fo<1>"}}'))
var y={B:B.a6("a7<@,@>"),w:B.a6("c"),v:B.a6("pa"),F:B.a6("ie"),b:B.a6("@"),d:B.a6("m<@>?")};(function constants(){C.E2=new B.H3(2,"active")
C.FL=new B.ai(58737,"MaterialIcons",null,!0)
C.vN=new A.aiN(0,"customer")
C.kQ=new A.aiN(1,"admin")
C.hE=new A.aiP(0,"open")
C.mM=new A.aiP(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"cvd","NK",()=>B.q8())})()};
(a=>{a["d7C7/DC8XPPFxrwMLhgZOzYVftc="]=a.current})($__dart_deferred_initializers__);