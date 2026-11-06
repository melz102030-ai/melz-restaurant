((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cbK(d){return new C.y0(d,null)},
y0:function y0(d,e){this.d=d
this.a=e},
Aa:function Aa(d,e){this.a=d
this.b=e
this.c=!1},
ZA:function ZA(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.f0$=h
_.cl$=i
_.d=$
_.c=_.a=null},
bpq:function bpq(d,e){this.a=d
this.b=e},
bps:function bps(){},
bpt:function bpt(){},
bpp:function bpp(d,e){this.a=d
this.b=e},
bpr:function bpr(d){this.a=d},
bpw:function bpw(d){this.a=d},
bpx:function bpx(d,e){this.a=d
this.b=e},
bpv:function bpv(d){this.a=d},
bpu:function bpu(d,e){this.a=d
this.b=e},
aqG:function aqG(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bpy:function bpy(d,e){this.a=d
this.b=e},
Mg:function Mg(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
bu0:function bu0(d,e){this.a=d
this.b=e},
asR:function asR(d,e){this.c=d
this.a=e},
bux:function bux(d){this.a=d},
avu:function avu(d,e,f){this.c=d
this.d=e
this.a=f},
a0P:function a0P(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
awp:function awp(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a36:function a36(){}},D,G,F,H,I,E
J=c[1]
B=c[0]
A=c[2]
C=a.updateHolder(c[6],C)
D=c[42]
G=c[11]
F=c[29]
H=c[32]
I=c[14]
E=c[38]
C.y0.prototype={
Z(){var x=B.b([],y.W)
return new C.ZA(A.a7,x,A.x2,A.U,null,null)}}
C.Aa.prototype={}
C.ZA.prototype={
ga8w(){var x=this.gd1().d4(0,$.h1(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
ar(){var x,w=this
w.aG()
w.IT()
x=w.zb(w.gaIV())
x.uW(0)
w.w!==$&&B.bg()
w.w=x},
IT(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IT=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lm(),$async$IT)
case 3:t=e
if(u.c==null){x=1
break}u.A(new C.bpq(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IT,w)},
CR(){var x=0,w=B.u(y.H),v=this
var $async$CR=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lm(),$async$CR)
case 3:x=2
return B.i(e.m6("Int",v.ga8w(),v.ax),$async$CR)
case 2:return B.r(null,w)}})
return B.t($async$CR,w)},
aIW(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga5(0))return
x.aFH(0,w)},
aFH(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.d.dQ(0.16+o.at*0.006,0.16,0.5),m=A.d.dQ(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.Aa(1.05,0.12+o.Q.aid()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eO(x,new C.bps())
w=o.CW
s=w.a
r=w.b
w=Math.min(s,r)
for(v=x.length,w=(w*0.075+w*0.055)*0.8,u=0;u<x.length;x.length===v||(0,B.M)(x),++u){t=x[u]
q=(t.a-0.16)*s
p=(t.b-o.y)*r
if(Math.sqrt(q*q+p*p)<w){o.ch=!0
o.ay=!1
x=o.at
if(x>o.ax){o.ax=x
o.CR()}break}}if(o.c!=null)o.A(new C.bpt())},
aC_(d){var x=this
if(!x.ay||x.CW.b===0)return
x.A(new C.bpp(x,d))},
aaw(){this.A(new C.bpr(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.asq()},
E(d){var x=this,w=null,v=x.gd1(),u=$.bSK(),t=v.bj(u.$1(x.a.d),y.x),s=v.bj($.k_(),y.B)
v.wL(u.$1(x.a.d),new C.bpw(d))
u=$.fl
return B.e2(B.fw(w,!0,A.E,w,w,0,A.k,w,w,B.ae(D.akG,A.i,A.f,A.P,0,w)),u,B.z5(!0,B.al(B.b([new C.asR(B.dx(t),w),A.ar,new C.avu(x.at,x.ax,w),A.ar,B.aD(new B.aq(F.EI,B.fb(B.ac(24),B.ve(new C.bpx(x,s)),A.aC),w),1,w)],y.p),A.i,A.f,A.h,0,A.o),A.ak,!0),w,!1,w)}}
C.aqG.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga5(0))return A.aq
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hU(u,A.F,new C.bpy(t,v),A.eA,v,v):t.a4j(v)
return B.fU(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a4j(d){var x=null,w=B.b([new B.bN(2,A.a6,B.S(153,D.xa.l()>>>16&255,D.xa.l()>>>8&255,D.xa.l()&255),A.m,16)],y.V)
return B.a7(x,B.ab(E.lR,A.k,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.aud,A.bk),x,d,x,x,x,x,x,d)}}
C.Mg.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga5(0))return A.aq
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hU(s,A.F,new C.bu0(r,v),A.eA,v,v):r.a4k(v)
return B.fU(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a4k(d){var x=null,w=B.bC(B.S(64,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),A.t,1.5),v=B.b([new B.bN(0,A.a6,B.S(A.d.a3(76.5),A.n.l()>>>16&255,A.n.l()>>>8&255,A.n.l()&255),A.m,8)],y.V)
return B.a7(x,B.ab(D.G9,B.S(217,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.DT,x,w,x,v,x,A.bk),x,d,x,x,x,x,x,d)}}
C.asR.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.ay6
x=s.y
if(x===A.d9)return B.a7(t,D.a4g,A.j,t,t,new B.a9(B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),t,t,B.ac(14),t,t,A.p),t,t,t,A.d5,H.xQ,t,t,t)
w=I.bWK(x)
x=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
v=B.ac(16)
s=s.CW
u=s===A.f5?A.ir:A.iq
u=B.b([new B.wE(E.FJ,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iQ),new B.wE(E.FX,"\u062a\u0623\u0643\u064a\u062f",A.iR),new B.wE(A.e0,"\u062a\u062d\u0636\u064a\u0631",A.hx),new B.wE(u,"\u062c\u0627\u0647\u0632",A.dw)],y.K)
if(s===A.cX)u.push(new B.wE(E.oz,"\u062a\u0648\u0635\u064a\u0644",A.f4))
u.push(new B.wE(A.eL,"\u062a\u0633\u0644\u064a\u0645",A.cd))
s=new B.dA(u,y.Q)
return B.a7(t,B.ae(s.gev(s).dK(0,new C.bux(w),y.e).cN(0),A.i,A.du,A.h,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.p),t,t,t,A.d5,A.fm,t,t,t)}}
C.avu.prototype={
E(d){var x=null
return new B.aq(A.d5,B.ae(B.b([B.aD(new C.a0P("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lR,D.DU,x),1,x),A.br,B.aD(new C.a0P("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.FH,F.iL,x),1,x)],y.p),A.i,A.f,A.h,0,x),x)}}
C.a0P.prototype={
E(d){var x=this,w=null,v=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),u=B.ac(14)
return B.a7(w,B.ae(B.b([B.ab(x.e,x.f,w,w,18),A.ay,B.n(""+x.d,w,w,w,w,B.w(w,w,A.k,w,w,w,w,w,w,w,w,16,w,w,A.u,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aG,B.aD(B.n(x.c,w,A.as,w,w,B.w(w,w,A.aO,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.i,A.f,A.h,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.p),w,w,w,w,A.fS,w,w,w)}}
C.awp.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.n.l()>>>16&255,A.n.l()>>>8&255,A.n.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dU.l()>>>16&255,A.dU.l()>>>8&255,A.dU.l()&255)
w=B.bC(A.dU,A.t,2)
v=u.d
w=B.b([B.a7(t,B.ab(D.G9,A.k,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.bk),t,64,t,t,t,t,t,64),A.dz,D.aGb,A.c_,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aO,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.aY,B.ae(D.alk,A.i,A.f,A.P,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ab(E.lR,B.bs(4294929309),t,t,56),A.dz,D.aGD,A.c_,D.aFc],r))
q.push(A.ZF)
r=B.ab(p?A.FT:D.aeH,t,t,t,t)
q.push(B.a9p(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hE(t,t,A.k,t,t,t,t,t,t,$.fl,t,t,D.a8G,t,new B.dF(B.ac(14),A.J),t,t,t,t,t)))
return B.bOv(0,B.a7(t,B.dv(B.al(q,A.i,A.f,A.P,0,A.o),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a36.prototype={
m(){var x=this,w=x.cl$
if(w!=null)w.O(0,x.gi0())
x.cl$=null
x.av()},
cV(){this.dF()
this.dt()
this.i1()}}
var z=a.updateTypes(["~(bF)","~(oD)","~()","C(Aa)","Mg(Aa)"])
C.bpq.prototype={
$0(){var x=this.a,w=B.f6(J.aL(this.b.a,x.ga8w()))
return x.ax=w==null?0:w},
$S:0}
C.bps.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bpt.prototype={
$0(){},
$S:0}
C.bpp.prototype={
$0(){var x=this.a
x.y=A.d.dQ(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bpr.prototype={
$0(){var x=this.a
A.b.X(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bpw.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.dx(d)
x=w==null?null:w.y}w=B.dx(e)
if((w==null?null:w.y)===A.dw&&x!==A.dw)this.a.a4(y.q).f.dc(D.ayA)},
$S:1055}
C.bpx.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.I(e.b,e.d)
x=B.b([$.fl,$.et,$.ui],y.O)
w=t.z
v=this.b
w=B.Q(new B.G(w,new C.bpu(t,v),B.T(w).h("G<1,d>")),y.l)
w.push(new C.aqG(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awp(t.ch,t.at,t.ax,t.gaOk(),u))
return B.d9(A.bC,B.a7(u,new B.e4(A.bs,u,A.bg,A.y,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.cm(A.c0,A.ch,A.a3,x,u,u),A.p),u,u,u,u,u,u,u,u),A.z,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bpv(t),u,u,u,u,u,t.gaBZ())},
$S:343}
C.bpv.prototype={
$0(){var x=this.a
if(!x.ay)x.aaw()},
$S:0}
C.bpu.prototype={
$1(d){return new C.Mg(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bpy.prototype={
$3(d,e,f){return this.a.a4j(this.b)},
$S:54}
C.bu0.prototype={
$3(d,e,f){return this.a.a4k(this.b)},
$S:54}
C.bux.prototype={
$1(d){var x,w,v=null,u=d.a,t=d.b,s=this.a,r=s>u,q=s===u
if(r)x=A.a1
else x=q?A.k:B.S(A.d.a3(76.5),A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
s=q?B.S(38,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255):A.E
w=B.bC(x,A.t,q?2:1)
return B.aD(B.al(B.b([B.a7(v,B.ab(r?A.jR:t.a,x,v,v,14),A.j,v,v,new B.a9(s,v,w,v,v,v,A.bk),v,28,v,v,v,v,v,28),A.kN,B.n(t.b,v,A.as,v,v,B.w(v,v,x,v,v,v,v,v,v,v,v,9,v,v,v,v,v,!0,v,v,v,v,v,v,v,v),v,v,v)],y.p),A.i,A.f,A.P,0,A.o),1,v)},
$S:1056};(function aliases(){var x=C.a36.prototype
x.asq=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.ZA.prototype,"gaIV","aIW",0)
x(v,"gaBZ","aC_",1)
w(v,"gaOk","aaw",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.y0,B.uE)
w(C.Aa,B.A)
w(C.a36,B.rD)
w(C.ZA,C.a36)
v(B.kx,[C.bpq,C.bpt,C.bpp,C.bpr,C.bpv])
v(B.hA,[C.bps,C.bpu,C.bpy,C.bu0,C.bux])
v(B.k1,[C.bpw,C.bpx])
v(B.a_,[C.aqG,C.Mg,C.asR,C.avu,C.a0P,C.awp])
x(C.a36,B.ht)})()
B.n8(b.typeUniverse,JSON.parse('{"Mg":{"a_":[],"d":[]},"y0":{"R":[],"d":[]},"ZA":{"X":["y0"]},"aqG":{"a_":[],"d":[]},"asR":{"a_":[],"d":[]},"avu":{"a_":[],"d":[]},"a0P":{"a_":[],"d":[]},"awp":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a4
return{x:x("bI<bo?>"),e:x("iP"),V:x("z<bN>"),O:x("z<J>"),K:x("z<+icon,label,status(ag,c,eE)>"),p:x("z<d>"),W:x("z<Aa>"),Q:x("dA<+icon,label,status(ag,c,eE)>"),B:x("fj"),l:x("d"),q:x("u2"),j:x("cY?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_j=new B.P(!0,A.aO,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFJ=new B.at("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_j,null,null,null,null,null,null,null,null)
D.a4g=new B.l1(A.F,null,null,D.aFJ,null)
D.xa=new B.J(1,1,0.26666666666666666,0.5333333333333333,A.l)
D.DU=new B.J(1,1,0.4196078431372549,0.615686274509804,A.l)
D.a8G=new B.a6(24,12,24,12)
D.FH=new B.ag(57900,"MaterialIcons",null,!1)
D.aeH=new B.ag(58571,"MaterialIcons",null,!1)
D.G9=new B.ag(63047,"MaterialIcons",null,!1)
D.age=new B.cq(E.lR,20,null,null,null,null)
D.aGE=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akG=x([D.age,A.ay,D.aGE],y.p)
D.afX=new B.cq(D.FH,18,F.iL,null,null,null)
D.aC5=new B.P(!0,F.iL,null,null,null,null,null,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGG=new B.at("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aC5,null,null,null,null,null,null,null,null)
D.alk=x([D.afX,A.aG,D.aGG],y.p)
D.a5d=new B.J(1,0.8,0.06666666666666667,0.3333333333333333,A.l)
D.amY=x([D.DU,D.a5d],y.O)
D.aud=new G.vE(A.F,0.5,A.a3,null,0,D.amY,null,null)
D.ay6=new B.cQ(null,64,null,null)
D.aGL=new B.at("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.ayA=new B.fW(D.aGL,A.a1,null,null,null,null,null,null,null,null,null,null,null,A.ag,!1,null,null,null,A.y,null)
D.aFc=new B.at("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_j,null,null,null,null,null,null,null,null)
D.aBw=new B.P(!0,A.k,null,null,null,null,22,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGb=new B.at("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aBw,null,null,null,null,null,null,null,null)
D.aBd=new B.P(!0,A.k,null,null,null,null,20,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGD=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aBd,null,null,null,null,null,null,null,null)})()};
(a=>{a["AEyKfikpJbvHvRiU91ZSfi6ga/M="]=a.current})($__dart_deferred_initializers__);