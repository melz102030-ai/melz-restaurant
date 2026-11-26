((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
ccn(d){return new C.y_(d,null)},
y_:function y_(d,e){this.d=d
this.a=e},
Ab:function Ab(d,e){this.a=d
this.b=e
this.c=!1},
ZD:function ZD(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.f2$=h
_.cl$=i
_.d=$
_.c=_.a=null},
bpl:function bpl(d,e){this.a=d
this.b=e},
bpn:function bpn(){},
bpo:function bpo(){},
bpk:function bpk(d,e){this.a=d
this.b=e},
bpm:function bpm(d){this.a=d},
bpr:function bpr(d){this.a=d},
bps:function bps(d,e){this.a=d
this.b=e},
bpq:function bpq(d){this.a=d},
bpp:function bpp(d,e){this.a=d
this.b=e},
aqy:function aqy(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bpt:function bpt(d,e){this.a=d
this.b=e},
Mi:function Mi(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
bu5:function bu5(d,e){this.a=d
this.b=e},
asH:function asH(d,e){this.c=d
this.a=e},
buz:function buz(d){this.a=d},
avm:function avm(d,e,f){this.c=d
this.d=e
this.a=f},
a0S:function a0S(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
awj:function awj(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a35:function a35(){}},D,H,F,I,G,E
J=c[1]
B=c[0]
A=c[2]
C=a.updateHolder(c[6],C)
D=c[42]
H=c[11]
F=c[29]
I=c[32]
G=c[14]
E=c[38]
C.y_.prototype={
Z(){var x=B.b([],y.W)
return new C.ZD(A.a5,x,A.wV,A.T,null,null)}}
C.Ab.prototype={}
C.ZD.prototype={
ga8L(){var x=this.gcD().cI(0,$.fV(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aI()
w.IL()
x=w.zj(w.gaJ_())
x.uP(0)
w.w!==$&&B.bf()
w.w=x},
IL(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IL=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.kO(),$async$IL)
case 3:t=e
if(u.c==null){x=1
break}u.A(new C.bpl(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IL,w)},
CR(){var x=0,w=B.u(y.H),v=this
var $async$CR=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.kO(),$async$CR)
case 3:x=2
return B.i(e.lp("Int",v.ga8L(),v.ax),$async$CR)
case 2:return B.r(null,w)}})
return B.t($async$CR,w)},
aJ0(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga3(0))return
x.aFE(0,w)},
aFE(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.e.dM(0.16+o.at*0.006,0.16,0.5),m=A.e.dM(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.Ab(1.05,0.12+o.Q.aiq()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eA(x,new C.bpn())
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
o.CR()}break}}if(o.c!=null)o.A(new C.bpo())},
aC4(d){var x=this
if(!x.ay||x.CW.b===0)return
x.A(new C.bpk(x,d))},
aaO(){this.A(new C.bpm(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.ast()},
E(d){var x=this,w=null,v=x.gcD(),u=$.bT5(),t=v.b4(u.$1(x.a.d),y.x),s=v.b4($.jH(),y.B)
v.u4(u.$1(x.a.d),new C.bpr(d))
u=$.fn
return B.e1(B.fA(w,!0,A.G,w,w,0,A.l,w,w,B.ag(D.akC,A.k,A.h,A.N,0,w)),u,B.vL(!0,B.al(B.b([new C.asH(B.d8(t),w),A.am,new C.avm(x.at,x.ax,w),A.am,B.aB(new B.aq(F.EB,B.f4(B.a8(24),B.vb(new C.bps(x,s)),A.aB),w),1,w)],y.p),A.k,A.h,A.i,0,A.n),A.ai,!0),w,!1,w)}}
C.aqy.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga3(0))return A.au
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hL(u,A.F,new C.bpt(t,v),A.eD,v,v):t.a4p(v)
return B.h_(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a4p(d){var x=null,w=B.b([new B.bL(2,A.a4,B.S(153,D.x3.l()>>>16&255,D.x3.l()>>>8&255,D.x3.l()&255),A.o,16)],y.V)
return B.a4(x,B.ab(E.lK,A.l,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.au8,A.be),x,d,x,x,x,x,x,d)}}
C.Mi.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga3(0))return A.au
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hL(s,A.F,new C.bu5(r,v),A.eD,v,v):r.a4q(v)
return B.h_(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a4q(d){var x=null,w=B.bD(B.S(64,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),A.x,1.5),v=B.b([new B.bL(0,A.a4,B.S(A.e.a6(76.5),A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),A.o,8)],y.V)
return B.a4(x,B.ab(D.FW,B.S(217,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.DP,x,w,x,v,x,A.be),x,d,x,x,x,x,x,d)}}
C.asH.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.ayn
x=s.y
if(x===A.d0)return B.a4(t,D.a42,A.j,t,t,new B.a9(B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),t,t,B.a8(14),t,t,A.q),t,t,t,A.dl,I.xK,t,t,t)
w=G.Tg(x)
x=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
v=B.a8(16)
s=s.CW
u=s===A.ey?A.im:A.ik
u=B.b([new B.Ag(E.FA,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iO),new B.Ag(A.dK,"\u062a\u062d\u0636\u064a\u0631",A.hw),new B.Ag(u,"\u062c\u0627\u0647\u0632",A.dA)],y.K)
if(s===A.cG)u.push(new B.Ag(E.ov,"\u062a\u0648\u0635\u064a\u0644",A.f6))
u.push(new B.Ag(A.e4,"\u062a\u0633\u0644\u064a\u0645",A.cc))
s=new B.dB(u,y.Q)
return B.a4(t,B.ag(s.ges(s).dH(0,new C.buz(w),y.e).cM(0),A.k,A.dy,A.i,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.q),t,t,t,A.dl,A.fp,t,t,t)}}
C.avm.prototype={
E(d){var x=null
return new B.aq(A.dl,B.ag(B.b([B.aB(new C.a0S("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lK,D.DQ,x),1,x),A.bx,B.aB(new C.a0S("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.Fy,F.iI,x),1,x)],y.p),A.k,A.h,A.i,0,x),x)}}
C.a0S.prototype={
E(d){var x=this,w=null,v=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),u=B.a8(14)
return B.a4(w,B.ag(B.b([B.ab(x.e,x.f,w,w,18),A.az,B.n(""+x.d,w,w,w,w,B.w(w,w,A.l,w,w,w,w,w,w,w,w,16,w,w,A.v,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aG,B.aB(B.n(x.c,w,A.ap,w,w,B.w(w,w,A.aI,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.k,A.h,A.i,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.q),w,w,w,w,A.fR,w,w,w)}}
C.awj.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dZ.l()>>>16&255,A.dZ.l()>>>8&255,A.dZ.l()&255)
w=B.bD(A.dZ,A.x,2)
v=u.d
w=B.b([B.a4(t,B.ab(D.FW,A.l,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.be),t,64,t,t,t,t,t,64),A.dD,D.aGx,A.c0,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aI,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.aZ,B.ag(D.ali,A.k,A.h,A.N,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ab(E.lK,B.bu(4294929309),t,t,56),A.dD,D.aGY,A.c0,D.aFy],r))
q.push(A.B6)
r=B.ab(p?A.FJ:D.aeF,t,t,t,t)
q.push(B.a9g(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hJ(t,t,A.l,t,t,t,t,t,t,$.fn,t,t,D.a8y,t,new B.dw(B.a8(14),A.I),t,t,t,t,t)))
return B.bOJ(0,B.a4(t,B.dt(B.al(q,A.k,A.h,A.N,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a35.prototype={
m(){var x=this,w=x.cl$
if(w!=null)w.O(0,x.ghZ())
x.cl$=null
x.ar()},
d1(){this.dQ()
this.dA()
this.i_()}}
var z=a.updateTypes(["~(bB)","~(oC)","~()","C(Ab)","Mi(Ab)"])
C.bpl.prototype={
$0(){var x=this.a,w=B.fc(J.aH(this.b.a,x.ga8L()))
return x.ax=w==null?0:w},
$S:0}
C.bpn.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bpo.prototype={
$0(){},
$S:0}
C.bpk.prototype={
$0(){var x=this.a
x.y=A.e.dM(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bpm.prototype={
$0(){var x=this.a
A.b.V(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bpr.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.d8(d)
x=w==null?null:w.y}w=B.d8(e)
if((w==null?null:w.y)===A.dA&&x!==A.dA)this.a.a2(y.q).f.d5(D.ayR)},
$S:1068}
C.bps.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.H(e.b,e.d)
x=B.b([$.fn,$.eu,$.uc],y.O)
w=t.z
v=this.b
w=B.Q(new B.J(w,new C.bpp(t,v),B.T(w).h("J<1,d>")),y.l)
w.push(new C.aqy(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awj(t.ch,t.at,t.ax,t.gaOq(),u))
return B.da(A.bD,B.a4(u,new B.dW(A.bt,u,A.bj,A.z,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.cp(A.c3,A.ck,A.a6,x,u,u),A.q),u,u,u,u,u,u,u,u),A.A,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bpq(t),u,u,u,u,u,t.gaC3())},
$S:339}
C.bpq.prototype={
$0(){var x=this.a
if(!x.ay)x.aaO()},
$S:0}
C.bpp.prototype={
$1(d){return new C.Mi(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bpt.prototype={
$3(d,e,f){return this.a.a4p(this.b)},
$S:61}
C.bu5.prototype={
$3(d,e,f){return this.a.a4q(this.b)},
$S:61}
C.buz.prototype={
$1(d){var x,w=null,v=d.b,u=this.a,t=v.c,s=u>G.Tg(t),r=u===G.Tg(t)
if(s)x=A.a0
else x=r?A.l:B.S(A.e.a6(76.5),A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
u=r?B.S(38,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255):A.G
t=B.bD(x,A.x,r?2:1)
return B.aB(B.al(B.b([B.a4(w,B.ab(s?A.jP:v.a,x,w,w,14),A.j,w,w,new B.a9(u,w,t,w,w,w,A.be),w,28,w,w,w,w,w,28),A.kL,B.n(v.b,w,A.ap,w,w,B.w(w,w,x,w,w,w,w,w,w,w,w,9,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w)],y.p),A.k,A.h,A.N,0,A.n),1,w)},
$S:1069};(function aliases(){var x=C.a35.prototype
x.ast=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.ZD.prototype,"gaJ_","aJ0",0)
x(v,"gaC3","aC4",1)
w(v,"gaOq","aaO",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.y_,B.uy)
w(C.Ab,B.A)
w(C.a35,B.ry)
w(C.ZD,C.a35)
v(B.ku,[C.bpl,C.bpo,C.bpk,C.bpm,C.bpq])
v(B.hF,[C.bpn,C.bpp,C.bpt,C.bu5,C.buz])
v(B.k6,[C.bpr,C.bps])
v(B.a_,[C.aqy,C.Mi,C.asH,C.avm,C.a0S,C.awj])
x(C.a35,B.hx)})()
B.nf(b.typeUniverse,JSON.parse('{"Mi":{"a_":[],"d":[]},"y_":{"R":[],"d":[]},"ZD":{"X":["y_"]},"aqy":{"a_":[],"d":[]},"asH":{"a_":[],"d":[]},"avm":{"a_":[],"d":[]},"a0S":{"a_":[],"d":[]},"awj":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a6
return{x:x("bw<bg?>"),e:x("iT"),V:x("z<bL>"),O:x("z<I>"),K:x("z<+icon,label,status(ai,c,eK)>"),p:x("z<d>"),W:x("z<Ab>"),Q:x("dB<+icon,label,status(ai,c,eK)>"),B:x("fk"),l:x("d"),q:x("tW"),j:x("cX?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_b=new B.P(!0,A.aI,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aG4=new B.as("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_b,null,null,null,null,null,null,null,null)
D.a42=new B.l3(A.F,null,null,D.aG4,null)
D.x3=new B.I(1,1,0.26666666666666666,0.5333333333333333,A.m)
D.DQ=new B.I(1,1,0.4196078431372549,0.615686274509804,A.m)
D.a8y=new B.a2(24,12,24,12)
D.Fy=new B.ai(57900,"MaterialIcons",null,!1)
D.aeF=new B.ai(58571,"MaterialIcons",null,!1)
D.FW=new B.ai(63047,"MaterialIcons",null,!1)
D.age=new B.cv(E.lK,20,null,null,null,null)
D.aGZ=new B.as("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akC=x([D.age,A.az,D.aGZ],y.p)
D.afX=new B.cv(D.Fy,18,F.iI,null,null,null)
D.aCo=new B.P(!0,F.iI,null,null,null,null,null,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aH0=new B.as("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aCo,null,null,null,null,null,null,null,null)
D.ali=x([D.afX,A.aG,D.aH0],y.p)
D.a5_=new B.I(1,0.8,0.06666666666666667,0.3333333333333333,A.m)
D.amT=x([D.DQ,D.a5_],y.O)
D.au8=new H.vC(A.F,0.5,A.a6,null,0,D.amT,null,null)
D.ayn=new B.cQ(null,64,null,null)
D.aH4=new B.as("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.ayR=new B.ft(D.aH4,A.a0,null,null,null,null,null,null,null,null,null,null,null,A.af,!1,null,null,null,A.z,null)
D.aFy=new B.as("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_b,null,null,null,null,null,null,null,null)
D.aBP=new B.P(!0,A.l,null,null,null,null,22,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGx=new B.as("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aBP,null,null,null,null,null,null,null,null)
D.aBw=new B.P(!0,A.l,null,null,null,null,20,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGY=new B.as("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aBw,null,null,null,null,null,null,null,null)})()};
(a=>{a["Yuc2ZhDm5JLyNk0vC0uFAjInQk8="]=a.current})($__dart_deferred_initializers__);