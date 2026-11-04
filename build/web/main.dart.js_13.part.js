((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b5w(d,e,f){return new A.VG(d,e,null,f.h("VG<0>"))},
ty:function ty(){},
a1m:function a1m(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bAS:function bAS(d){this.a=d},
bAR:function bAR(d,e){this.a=d
this.b=e},
bAU:function bAU(d){this.a=d},
bAP:function bAP(d,e,f){this.a=d
this.b=e
this.c=f},
bAT:function bAT(d){this.a=d},
bAQ:function bAQ(d){this.a=d},
VG:function VG(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bNZ(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a5(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mJ:C.hB
t=p.i(d,r) instanceof B.i9?B.ow(y.F.a(p.i(d,r)).gmq()):new B.cy(Date.now(),0,!1)
s=p.i(d,q) instanceof B.i9?B.ow(y.F.a(p.i(d,q)).gmq()):new B.cy(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dB(e,o,x,w,v,u,t,s,J.dG(p,new A.b6b(),y.v).cK(0))},
aiA:function aiA(d,e){this.a=d
this.b=e},
aiy:function aiy(d,e){this.a=d
this.b=e},
p4:function p4(d,e,f,g){var _=this
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
b6b:function b6b(){},
b6c:function b6c(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[31]
A.ty.prototype={
a_(){return new A.a1m(this.$ti.h("a1m<ty.T,ty.S>"))}}
A.a1m.prototype={
au(){var x,w=this
w.aI()
x=w.a
x.toString
x=B.bSd(x.$ti.c)
w.e=x
w.Bp()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2j()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fk(D.xc,x.b,x.c,x.d,x.$ti)}w.Bp()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.yA(d,x)},
m(){this.a2j()
this.ar()},
Bp(){var x,w=this
w.d=w.a.c.lH(new A.bAS(w),new A.bAT(w),new A.bAU(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fk(D.DL,x.b,x.c,x.d,x.$ti)},
a2j(){var x=this.d
if(x!=null){x.aK(0)
this.d=null}}}
A.VG.prototype={
yA(d,e){return this.e.$2(d,e)}}
A.aiA.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiy.prototype={
L(){return"SupportSenderRole."+this.b}}
A.p4.prototype={
e8(){var x=this,w=x.d
return B.ak(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ia(1000*w.a+w.b)],y.w,y.b)}}
A.dB.prototype={
e8(){var x,w,v,u=this,t=u.r
t=B.ia(1000*t.a+t.b)
x=u.w
x=B.ia(1000*x.a+x.b)
w=u.x
v=B.T(w).h("G<1,a3<c,@>>")
w=B.Q(new B.G(w,new A.b6c(),v),v.h("aw.E"))
return B.ak(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["p4(@)","a3<c,@>(p4)"])
A.bAS.prototype={
$1(d){var x=this.a
x.C(new A.bAR(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bAR.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fk(C.DM,this.b,null,null,w.$ti.h("fk<1>"))},
$S:0}
A.bAU.prototype={
$2(d,e){var x=this.a
x.C(new A.bAP(x,d,e))},
$S:14}
A.bAP.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fk(C.DM,null,this.b,this.c,w.$ti.h("fk<1>"))},
$S:0}
A.bAT.prototype={
$0(){var x=this.a
x.C(new A.bAQ(x))},
$S:0}
A.bAQ.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fk(D.lr,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b6b.prototype={
$1(d){var x,w="createdAt",v=B.hE(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kK:C.vI,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.p4(u,t,x,v.i(0,w) instanceof B.i9?B.ow(y.F.a(v.i(0,w)).gmq()):new B.cy(Date.now(),0,!1))},
$S:z+0}
A.b6c.prototype={
$1(d){return d.e8()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.ty,B.R)
x(A.a1m,B.X)
w(B.hy,[A.bAS,A.b6b,A.b6c])
w(B.ku,[A.bAR,A.bAP,A.bAT,A.bAQ])
x(A.bAU,B.k0)
x(A.VG,A.ty)
w(B.r1,[A.aiA,A.aiy])
w(B.A,[A.p4,A.dB])})()
B.n4(b.typeUniverse,JSON.parse('{"ty":{"R":[],"d":[]},"a1m":{"X":["ty<1,2>"]},"VG":{"ty":["1","fk<1>"],"R":[],"d":[],"ty.T":"1","ty.S":"fk<1>"}}'))
var y={B:B.a6("a3<@,@>"),w:B.a6("c"),v:B.a6("p4"),F:B.a6("i9"),b:B.a6("@"),d:B.a6("m<@>?")};(function constants(){C.DM=new B.GU(2,"active")
C.FC=new B.ai(58737,"MaterialIcons",null,!0)
C.vI=new A.aiy(0,"customer")
C.kK=new A.aiy(1,"admin")
C.hB=new A.aiA(0,"open")
C.mJ=new A.aiA(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"ctb","NC",()=>B.rK())})()};
(a=>{a["9y5hFRhwi0a+YnXkv31Cn/9IuUE="]=a.current})($__dart_deferred_initializers__);