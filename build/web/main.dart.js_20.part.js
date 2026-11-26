((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cdv(d){return new C.y5(d,null)},
y5:function y5(d,e){this.d=d
this.a=e},
Ah:function Ah(d,e){this.a=d
this.b=e
this.c=!1},
ZN:function ZN(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.eZ$=h
_.ci$=i
_.d=$
_.c=_.a=null},
bqj:function bqj(d,e){this.a=d
this.b=e},
bql:function bql(){},
bqm:function bqm(){},
bqi:function bqi(d,e){this.a=d
this.b=e},
bqk:function bqk(d){this.a=d},
bqp:function bqp(d){this.a=d},
bqq:function bqq(d,e){this.a=d
this.b=e},
bqo:function bqo(d){this.a=d},
bqn:function bqn(d,e){this.a=d
this.b=e},
aqO:function aqO(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bqr:function bqr(d,e){this.a=d
this.b=e},
Mv:function Mv(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
bv3:function bv3(d,e){this.a=d
this.b=e},
asX:function asX(d,e){this.c=d
this.a=e},
bvx:function bvx(d){this.a=d},
avC:function avC(d,e,f){this.c=d
this.d=e
this.a=f},
a12:function a12(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
awB:function awB(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a3h:function a3h(){}},D,H,F,I,G,E
J=c[1]
B=c[0]
A=c[2]
C=a.updateHolder(c[6],C)
D=c[43]
H=c[11]
F=c[30]
I=c[33]
G=c[14]
E=c[39]
C.y5.prototype={
Z(){var x=B.b([],y.W)
return new C.ZN(A.a5,x,A.wW,A.T,null,null)}}
C.Ah.prototype={}
C.ZN.prototype={
ga8P(){var x=this.gcD().cJ(0,$.h6(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aH()
w.IN()
x=w.zk(w.gaJ8())
x.uP(0)
w.w!==$&&B.bg()
w.w=x},
IN(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IN=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lw(),$async$IN)
case 3:t=e
if(u.c==null){x=1
break}u.u(new C.bqj(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IN,w)},
CR(){var x=0,w=B.u(y.H),v=this
var $async$CR=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lw(),$async$CR)
case 3:x=2
return B.i(e.m2("Int",v.ga8P(),v.ax),$async$CR)
case 2:return B.r(null,w)}})
return B.t($async$CR,w)},
aJ9(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga3(0))return
x.aFM(0,w)},
aFM(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.e.dO(0.16+o.at*0.006,0.16,0.5),m=A.e.dO(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.Ah(1.05,0.12+o.Q.aiu()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eB(x,new C.bql())
w=o.CW
s=w.a
r=w.b
w=Math.min(s,r)
for(v=x.length,w=(w*0.075+w*0.055)*0.8,u=0;u<x.length;x.length===v||(0,B.L)(x),++u){t=x[u]
q=(t.a-0.16)*s
p=(t.b-o.y)*r
if(Math.sqrt(q*q+p*p)<w){o.ch=!0
o.ay=!1
x=o.at
if(x>o.ax){o.ax=x
o.CR()}break}}if(o.c!=null)o.u(new C.bqm())},
aCc(d){var x=this
if(!x.ay||x.CW.b===0)return
x.u(new C.bqi(x,d))},
aaS(){this.u(new C.bqk(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.asy()},
E(d){var x=this,w=null,v=x.gcD(),u=$.bU7(),t=v.aY(u.$1(x.a.d),y.x),s=v.aY($.jM(),y.B)
v.u4(u.$1(x.a.d),new C.bqp(d))
u=$.fq
return B.dT(B.ff(w,!0,A.G,w,w,0,A.l,w,w,B.ag(D.akO,A.k,A.h,A.L,0,w)),u,B.vS(!0,B.ai(B.b([new C.asX(B.da(t),w),A.ak,new C.avC(x.at,x.ax,w),A.ak,B.aA(new B.aq(F.EE,B.f5(B.a5(24),B.vi(new C.bqq(x,s)),A.aC),w),1,w)],y.p),A.k,A.h,A.i,0,A.n),A.aj,!0),w,!1,w)}}
C.aqO.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga3(0))return A.au
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hM(u,A.F,new C.bqr(t,v),A.eE,v,v):t.a4u(v)
return B.h_(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a4u(d){var x=null,w=B.b([new B.bL(2,A.a4,B.S(153,D.x5.l()>>>16&255,D.x5.l()>>>8&255,D.x5.l()&255),A.o,16)],y.V)
return B.a3(x,B.aa(E.lO,A.l,x,x,d*0.6),A.j,x,x,new B.a6(x,x,x,x,w,D.auk,A.be),x,d,x,x,x,x,x,d)}}
C.Mv.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga3(0))return A.au
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hM(s,A.F,new C.bv3(r,v),A.eE,v,v):r.a4v(v)
return B.h_(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a4v(d){var x=null,w=B.bD(B.S(64,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),A.x,1.5),v=B.b([new B.bL(0,A.a4,B.S(A.e.a6(76.5),A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),A.o,8)],y.V)
return B.a3(x,B.aa(D.G3,B.S(217,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),x,x,d*0.55),A.j,x,x,new B.a6(A.DS,x,w,x,v,x,A.be),x,d,x,x,x,x,x,d)}}
C.asX.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.ayz
x=s.y
if(x===A.d2)return B.a3(t,D.a4j,A.j,t,t,new B.a6(B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),t,t,B.a5(14),t,t,A.q),t,t,t,A.dn,I.xN,t,t,t)
w=G.Tn(x)
x=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
v=B.a5(16)
s=s.CW
u=s===A.ez?A.iq:A.ip
u=B.b([new B.Am(E.FG,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iQ),new B.Am(A.dL,"\u062a\u062d\u0636\u064a\u0631",A.hz),new B.Am(u,"\u062c\u0627\u0647\u0632",A.dC)],y.K)
if(s===A.cJ)u.push(new B.Am(E.oz,"\u062a\u0648\u0635\u064a\u0644",A.f7))
u.push(new B.Am(A.e5,"\u062a\u0633\u0644\u064a\u0645",A.cd))
s=new B.dC(u,y.Q)
return B.a3(t,B.ag(s.ges(s).dI(0,new C.bvx(w),y.e).cK(0),A.k,A.dA,A.i,0,t),A.j,t,t,new B.a6(x,t,t,v,t,t,A.q),t,t,t,A.dn,A.fr,t,t,t)}}
C.avC.prototype={
E(d){var x=null
return new B.aq(A.dn,B.ag(B.b([B.aA(new C.a12("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lO,D.DT,x),1,x),A.bs,B.aA(new C.a12("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.FE,F.iL,x),1,x)],y.p),A.k,A.h,A.i,0,x),x)}}
C.a12.prototype={
E(d){var x=this,w=null,v=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),u=B.a5(14)
return B.a3(w,B.ag(B.b([B.aa(x.e,x.f,w,w,18),A.aw,B.m(""+x.d,w,w,w,w,B.v(w,w,A.l,w,w,w,w,w,w,w,w,16,w,w,A.u,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aK,B.aA(B.m(x.c,w,A.aq,w,w,B.v(w,w,A.aN,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.k,A.h,A.i,0,w),A.j,w,w,new B.a6(v,w,w,u,w,w,A.q),w,w,w,w,A.fS,w,w,w)}}
C.awB.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.e_.l()>>>16&255,A.e_.l()>>>8&255,A.e_.l()&255)
w=B.bD(A.e_,A.x,2)
v=u.d
w=B.b([B.a3(t,B.aa(D.G3,A.l,t,t,34),A.j,t,t,new B.a6(x,t,w,t,t,t,A.be),t,64,t,t,t,t,t,64),A.de,D.aGJ,A.c2,B.m("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.v(t,t,A.aN,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.aQ,B.ag(D.alt,A.k,A.h,A.L,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.aa(E.lO,B.bu(4294929309),t,t,56),A.de,D.aHb,A.c2,D.aFN],r))
q.push(A.Bb)
r=B.aa(p?A.FP:D.aeU,t,t,t,t)
q.push(B.a9t(r,B.m(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hK(t,t,A.l,t,t,t,t,t,t,$.fq,t,t,D.a8O,t,new B.ds(B.a5(14),A.H),t,t,t,t,t)))
return B.bPM(0,B.a3(t,B.cX(B.ai(q,A.k,A.h,A.L,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a3h.prototype={
m(){var x=this,w=x.ci$
if(w!=null)w.O(0,x.ghK())
x.ci$=null
x.ar()},
d_(){this.dN()
this.dw()
this.hL()}}
var z=a.updateTypes(["~(bC)","~(oF)","~()","C(Ah)","Mv(Ah)"])
C.bqj.prototype={
$0(){var x=this.a,w=B.fd(J.aF(this.b.a,x.ga8P()))
return x.ax=w==null?0:w},
$S:0}
C.bql.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bqm.prototype={
$0(){},
$S:0}
C.bqi.prototype={
$0(){var x=this.a
x.y=A.e.dO(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bqk.prototype={
$0(){var x=this.a
A.b.V(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bqp.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.da(d)
x=w==null?null:w.y}w=B.da(e)
if((w==null?null:w.y)===A.dC&&x!==A.dC)this.a.a0(y.q).f.cV(D.az3)},
$S:1080}
C.bqq.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.I(e.b,e.d)
x=B.b([$.fq,$.ew,$.ui],y.O)
w=t.z
v=this.b
w=B.P(new B.H(w,new C.bqn(t,v),B.T(w).h("H<1,d>")),y.l)
w.push(new C.aqO(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awB(t.ch,t.at,t.ax,t.gaOD(),u))
return B.d3(A.bD,B.a3(u,new B.e_(A.bu,u,A.bj,A.z,w,u),A.j,u,u,new B.a6(u,u,u,u,u,new B.cp(A.c5,A.cn,A.a6,x,u,u),A.q),u,u,u,u,u,u,u,u),A.A,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bqo(t),u,u,u,u,u,t.gaCb())},
$S:244}
C.bqo.prototype={
$0(){var x=this.a
if(!x.ay)x.aaS()},
$S:0}
C.bqn.prototype={
$1(d){return new C.Mv(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bqr.prototype={
$3(d,e,f){return this.a.a4u(this.b)},
$S:55}
C.bv3.prototype={
$3(d,e,f){return this.a.a4v(this.b)},
$S:55}
C.bvx.prototype={
$1(d){var x,w=null,v=d.b,u=this.a,t=v.c,s=u>G.Tn(t),r=u===G.Tn(t)
if(s)x=A.a1
else x=r?A.l:B.S(A.e.a6(76.5),A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
u=r?B.S(38,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255):A.G
t=B.bD(x,A.x,r?2:1)
return B.aA(B.ai(B.b([B.a3(w,B.aa(s?A.jO:v.a,x,w,w,14),A.j,w,w,new B.a6(u,w,t,w,w,w,A.be),w,28,w,w,w,w,w,28),A.kO,B.m(v.b,w,A.aq,w,w,B.v(w,w,x,w,w,w,w,w,w,w,w,9,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w)],y.p),A.k,A.h,A.L,0,A.n),1,w)},
$S:1081};(function aliases(){var x=C.a3h.prototype
x.asy=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.ZN.prototype,"gaJ8","aJ9",0)
x(v,"gaCb","aCc",1)
w(v,"gaOD","aaS",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.y5,B.uE)
w(C.Ah,B.A)
w(C.a3h,B.rB)
w(C.ZN,C.a3h)
v(B.kB,[C.bqj,C.bqm,C.bqi,C.bqk,C.bqo])
v(B.hG,[C.bql,C.bqn,C.bqr,C.bv3,C.bvx])
v(B.ke,[C.bqp,C.bqq])
v(B.a_,[C.aqO,C.Mv,C.asX,C.avC,C.a12,C.awB])
x(C.a3h,B.hi)})()
B.nj(b.typeUniverse,JSON.parse('{"Mv":{"a_":[],"d":[]},"y5":{"R":[],"d":[]},"ZN":{"X":["y5"]},"aqO":{"a_":[],"d":[]},"asX":{"a_":[],"d":[]},"avC":{"a_":[],"d":[]},"a12":{"a_":[],"d":[]},"awB":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a8
return{x:x("bv<bh?>"),e:x("iV"),V:x("z<bL>"),O:x("z<J>"),K:x("z<+icon,label,status(ah,c,eM)>"),p:x("z<d>"),W:x("z<Ah>"),Q:x("dC<+icon,label,status(ah,c,eM)>"),B:x("fn"),l:x("d"),q:x("tZ"),j:x("cY?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_p=new B.Q(!0,A.aN,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGh=new B.ar("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_p,null,null,null,null,null,null,null,null)
D.a4j=new B.iP(A.F,null,null,D.aGh,null)
D.x5=new B.J(1,1,0.26666666666666666,0.5333333333333333,A.m)
D.DT=new B.J(1,1,0.4196078431372549,0.615686274509804,A.m)
D.a8O=new B.a1(24,12,24,12)
D.FE=new B.ah(57900,"MaterialIcons",null,!1)
D.aeU=new B.ah(58571,"MaterialIcons",null,!1)
D.G3=new B.ah(63047,"MaterialIcons",null,!1)
D.agq=new B.cu(E.lO,20,null,null,null,null)
D.aHc=new B.ar("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akO=x([D.agq,A.aw,D.aHc],y.p)
D.ag9=new B.cu(D.FE,18,F.iL,null,null,null)
D.aCE=new B.Q(!0,F.iL,null,null,null,null,null,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aHd=new B.ar("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aCE,null,null,null,null,null,null,null,null)
D.alt=x([D.ag9,A.aK,D.aHd],y.p)
D.a5g=new B.J(1,0.8,0.06666666666666667,0.3333333333333333,A.m)
D.an4=x([D.DT,D.a5g],y.O)
D.auk=new H.vJ(A.F,0.5,A.a6,null,0,D.an4,null,null)
D.ayz=new B.cQ(null,64,null,null)
D.aHi=new B.ar("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.az3=new B.fa(D.aHi,A.a1,null,null,null,null,null,null,null,null,null,null,null,A.ac,!1,null,null,null,A.z,null)
D.aFN=new B.ar("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_p,null,null,null,null,null,null,null,null)
D.aC4=new B.Q(!0,A.l,null,null,null,null,22,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGJ=new B.ar("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aC4,null,null,null,null,null,null,null,null)
D.aBM=new B.Q(!0,A.l,null,null,null,null,20,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aHb=new B.ar("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aBM,null,null,null,null,null,null,null,null)})()};
(a=>{a["EmdD8X5Wa4/GlIK7QRMWZ2Isz/o="]=a.current})($__dart_deferred_initializers__);