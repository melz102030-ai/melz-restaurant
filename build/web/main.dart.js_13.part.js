((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,D,A={
b6D(d,e,f){return new A.W1(d,e,null,f.h("W1<0>"))},
ty:function ty(){},
a1I:function a1I(d){var _=this
_.d=null
_.e=$
_.c=_.a=null
_.$ti=d},
bCR:function bCR(d){this.a=d},
bCQ:function bCQ(d,e){this.a=d
this.b=e},
bCT:function bCT(d){this.a=d},
bCO:function bCO(d,e,f){this.a=d
this.b=e
this.c=f},
bCS:function bCS(d){this.a=d},
bCP:function bCP(d){this.a=d},
W1:function W1(d,e,f,g){var _=this
_.e=d
_.c=e
_.a=f
_.$ti=g},
bQd(d,e){var x,w,v,u,t,s,r="createdAt",q="updatedAt",p=J.a6(d),o=p.i(d,"customerId")
if(o==null)o=""
x=p.i(d,"customerName")
if(x==null)x=""
w=p.i(d,"customerPhone")
if(w==null)w=""
v=p.i(d,"category")
if(v==null)v="\u0627\u0633\u062a\u0641\u0633\u0627\u0631 \u0639\u0627\u0645"
u=J.f(p.i(d,"status"),"closed")?C.mO:C.hG
t=p.i(d,r) instanceof B.hR?B.nE(y.F.a(p.i(d,r)).glM()):new B.cD(Date.now(),0,!1)
s=p.i(d,q) instanceof B.hR?B.nE(y.F.a(p.i(d,q)).glM()):new B.cD(Date.now(),0,!1)
p=y.d.a(p.i(d,"messages"))
if(p==null)p=[]
return new A.dD(e,o,x,w,v,u,t,s,J.dk(p,new A.b7i(),y.v).cM(0))},
aiY:function aiY(d,e){this.a=d
this.b=e},
aiW:function aiW(d,e){this.a=d
this.b=e},
pc:function pc(d,e,f,g){var _=this
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
b7i:function b7i(){},
b7j:function b7j(){}},C
J=c[1]
B=c[0]
D=c[2]
A=a.updateHolder(c[19],A)
C=c[32]
A.ty.prototype={
Z(){return new A.a1I(this.$ti.h("a1I<ty.T,ty.S>"))}}
A.a1I.prototype={
au(){var x,w=this
w.aH()
x=w.a
x.toString
x=B.bUz(x.$ti.c)
w.e=x
w.BM()},
aQ(d){var x,w=this
w.bs(d)
if(d.c!==w.a.c){if(w.d!=null){w.a2T()
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.xi,x.b,x.c,x.d,x.$ti)}w.BM()}},
E(d){var x,w=this.a
w.toString
x=this.e
x===$&&B.a()
return w.z1(d,x)},
m(){this.a2T()
this.ar()},
BM(){var x,w=this
w.d=w.a.c.lL(new A.bCR(w),new A.bCS(w),new A.bCT(w))
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.E5,x.b,x.c,x.d,x.$ti)},
a2T(){var x=this.d
if(x!=null){x.aC(0)
this.d=null}}}
A.W1.prototype={
z1(d,e){return this.e.$2(d,e)}}
A.aiY.prototype={
L(){return"SupportTicketStatus."+this.b}}
A.aiW.prototype={
L(){return"SupportSenderRole."+this.b}}
A.pc.prototype={
f_(){var x=this,w=x.d
return B.ag(["senderRole",x.a.b,"senderName",x.b,"text",x.c,"createdAt",B.ih(1000*w.a+w.b)],y.w,y.b)}}
A.dD.prototype={
f_(){var x,w,v,u=this,t=u.r
t=B.ih(1000*t.a+t.b)
x=u.w
x=B.ih(1000*x.a+x.b)
w=u.x
v=B.T(w).h("H<1,a5<c,@>>")
w=B.P(new B.H(w,new A.b7j(),v),v.h("ax.E"))
return B.ag(["customerId",u.b,"customerName",u.c,"customerPhone",u.d,"category",u.e,"status",u.f.b,"createdAt",t,"updatedAt",x,"messages",w],y.w,y.b)}}
var z=a.updateTypes(["pc(@)","a5<c,@>(pc)"])
A.bCR.prototype={
$1(d){var x=this.a
x.u(new A.bCQ(x,d))},
$S(){return this.a.$ti.h("~(1)")}}
A.bCQ.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fr(C.E6,this.b,null,null,w.$ti.h("fr<1>"))},
$S:0}
A.bCT.prototype={
$2(d,e){var x=this.a
x.u(new A.bCO(x,d,e))},
$S:14}
A.bCO.prototype={
$0(){var x=this.a,w=x.a
w.toString
x.e===$&&B.a()
x.e=new B.fr(C.E6,null,this.b,this.c,w.$ti.h("fr<1>"))},
$S:0}
A.bCS.prototype={
$0(){var x=this.a
x.u(new A.bCP(x))},
$S:0}
A.bCP.prototype={
$0(){var x,w=this.a
w.a.toString
x=w.e
x===$&&B.a()
w.e=new B.fr(D.lu,x.b,x.c,x.d,x.$ti)},
$S:0}
A.b7i.prototype={
$1(d){var x,w="createdAt",v=B.h_(y.B.a(d),y.w,y.b),u=J.f(v.i(0,"senderRole"),"admin")?C.kR:C.vN,t=v.i(0,"senderName")
if(t==null)t=""
x=v.i(0,"text")
if(x==null)x=""
return new A.pc(u,t,x,v.i(0,w) instanceof B.hR?B.nE(y.F.a(v.i(0,w)).glM()):new B.cD(Date.now(),0,!1))},
$S:z+0}
A.b7j.prototype={
$1(d){return d.f_()},
$S:z+1};(function inheritance(){var x=a.inherit,w=a.inheritMany
x(A.ty,B.R)
x(A.a1I,B.X)
w(B.hF,[A.bCR,A.b7i,A.b7j])
w(B.ky,[A.bCQ,A.bCO,A.bCS,A.bCP])
x(A.bCT,B.kb)
x(A.W1,A.ty)
w(B.r6,[A.aiY,A.aiW])
w(B.A,[A.pc,A.dD])})()
B.ni(b.typeUniverse,JSON.parse('{"ty":{"R":[],"d":[]},"a1I":{"X":["ty<1,2>"]},"W1":{"ty":["1","fr<1>"],"R":[],"d":[],"ty.T":"1","ty.S":"fr<1>"}}'))
var y={B:B.a7("a5<@,@>"),w:B.a7("c"),v:B.a7("pc"),F:B.a7("hR"),b:B.a7("@"),d:B.a7("n<@>?")};(function constants(){C.E6=new B.Hb(2,"active")
C.FQ=new B.ah(58737,"MaterialIcons",null,!0)
C.vN=new A.aiW(0,"customer")
C.kR=new A.aiW(1,"admin")
C.hG=new A.aiY(0,"open")
C.mO=new A.aiY(1,"closed")})();(function lazyInitializers(){var x=a.lazyFinal
x($,"cwe","NY",()=>B.qe())})()};
(a=>{a["9i6d2O9gP7wMahUKARPkgwwlFoU="]=a.current})($__dart_deferred_initializers__);