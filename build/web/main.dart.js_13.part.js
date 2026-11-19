((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5Z(d,e,f){return new A.VT(d,e,null,f.h("VT<0>"))},
tv:function tv(){},
a1z:function a1z(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bBY:function bBY(d){this.a=d},
bBX:function bBX(d,e){this.a=d
this.b=e},
bC_:function bC_(d){this.a=d},
bBV:function bBV(d,e,f){this.a=d
this.b=e
this.c=f},
bBZ:function bBZ(d){this.a=d},
bBW:function bBW(d){this.a=d},
VT:function VT(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bP7(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a4(d),o=p.i(d,"customerId")
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
return new A.dD(e,o,x,w,v,u,t,s,J.ds(p,new A.b6E(),y.v).cM(0))},
aiN:function aiN(d,e){this.a=d
this.b=e},
aiL:function aiL(d,e){this.a=d
this.b=e},
pa:function pa(d,e,f,g){var _=this
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
b6E:function b6E(){},
b6F:function b6F(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.tv.prototype={
Z(){return new A.a1z(this.$ti.h("a1z<tv.T,tv.S>"))}}
A.a1z.prototype={
au(){var x,w=this
w.aI()
x=w.a
x.toString
x=B.bTx(x.$ti.c)
w.e=x
w.BJ()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2M()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.xh,x.b,x.c,x.d,x.$ti)}w.BJ()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yZ(d,x)},
m(){this.a2M()
this.ar()},
BJ(){var x,w=this
w.d=w.a.c.lK(new A.bBY(w),new A.bBZ(w),new A.bC_(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.E0,x.b,x.c,x.d,x.$ti)},
a2M(){var x=this.d
if(x!=null){x.aC(0)
this.d=null}}}
A.VT.prototype={
yZ(d,e){return this.e.$2(d,e)}}
A.aiN.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiL.prototype={
L(){return"SupportSenderRole."+this.b}}
A.pa.prototype={
eQ(){var x=this,w=x.d
return B.al(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ig(1000*w.a+w.b)],y.w,y.b)}}
A.dD.prototype={
eQ(){var x,w,v,u=this,t=u.r
t=B.ig(1000*t.a+t.b)
x=u.w
x=B.ig(1000*x.a+x.b)
w=u.x
v=B.T(w).h("J<1,a6<c,@>>")
w=B.Q(new B.J(w,new A.b6F(),v),v.h("az.E"))
return B.al(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["pa(@)","a6<c,@>(pa)"])
A.bBY.prototype={
$1(d){var x=this.a
x.A(new A.bBX(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bBX.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fo(C.E1,this.b,null,null,w.$ti.h("fo<1>"))},
$S:0}
A.bC_.prototype={
$2(d,e){var x=this.a
x.A(new A.bBV(x,d,e))},
$S:14}
A.bBV.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fo(C.E1,null,this.b,this.c,w.$ti.h("fo<1>"))},
$S:0}
A.bBZ.prototype={
$0(){var x=this.a
x.A(new A.bBW(x))},
$S:0}
A.bBW.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fo(D.ls,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6E.prototype={
$1(d){var x,w="createdAt",v=B.hc(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kP:C.vM,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.pa(u,t,x,v.i(0,w) instanceof B.ie?B.oz(y.F.a(v.i(0,w)).gmr()):new B.cz(Date.now(),0,!1))},
$S:z+0}
A.b6F.prototype={
$1(d){return d.eQ()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.tv,B.R)
x(A.a1z,B.X)
w(B.hE,[A.bBY,A.b6E,A.b6F])
w(B.ku,[A.bBX,A.bBV,A.bBZ,A.bBW])
x(A.bC_,B.k6)
x(A.VT,A.tv)
w(B.r1,[A.aiN,A.aiL])
w(B.A,[A.pa,A.dD])})()
B.ne(b.typeUniverse,JSON.parse('{"tv":{"R":[],"d":[]},"a1z":{"X":["tv<1,2>"]},"VT":{"tv":["1","fo<1>"],"R":[],"d":[],"tv.T":"1","tv.S":"fo<1>"}}'))
var y={B:B.a5("a6<@,@>"),w:B.a5("c"),v:B.a5("pa"),F:B.a5("ie"),b:B.a5("@"),d:B.a5("m<@>?")};(function constants(){C.E1=new B.H2(2,"active")
C.FJ=new B.ah(58737,"MaterialIcons",null,!0)
C.vM=new A.aiL(0,"customer")
C.kP=new A.aiL(1,"admin")
C.hE=new A.aiN(0,"open")
C.mM=new A.aiN(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"cv6","NI",()=>B.q8())})()};
(a=>{a["XX11zVO4ep0AWcgZoIbizJT+vHA="]=a.current})($__dart_deferred_initializers__);