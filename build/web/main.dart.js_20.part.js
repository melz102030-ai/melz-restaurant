((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cdv(d){return new C.y5(d,null)},
y5:function y5(d,e){this.d=d
this.a=e},
Ai:function Ai(d,e){this.a=d
this.b=e
this.c=!1},
ZM:function ZM(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.eY$=h
_.ci$=i
_.d=$
_.c=_.a=null},
bqy:function bqy(d,e){this.a=d
this.b=e},
bqA:function bqA(){},
bqB:function bqB(){},
bqx:function bqx(d,e){this.a=d
this.b=e},
bqz:function bqz(d){this.a=d},
bqE:function bqE(d){this.a=d},
bqF:function bqF(d,e){this.a=d
this.b=e},
bqD:function bqD(d){this.a=d},
bqC:function bqC(d,e){this.a=d
this.b=e},
aqO:function aqO(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bqG:function bqG(d,e){this.a=d
this.b=e},
MB:function MB(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
bvi:function bvi(d,e){this.a=d
this.b=e},
asX:function asX(d,e){this.c=d
this.a=e},
bvL:function bvL(d){this.a=d},
avB:function avB(d,e,f){this.c=d
this.d=e
this.a=f},
a10:function a10(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
awA:function awA(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a3f:function a3f(){}},D,H,F,I,G,E
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
return new C.ZM(A.a5,x,A.wV,A.T,null,null)}}
C.Ai.prototype={}
C.ZM.prototype={
ga8T(){var x=this.gcJ().cH(0,$.fU(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aH()
w.IR()
x=w.zm(w.gaJi())
x.uS(0)
w.w!==$&&B.bg()
w.w=x},
IR(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IR=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lw(),$async$IR)
case 3:t=e
if(u.c==null){x=1
break}u.u(new C.bqy(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IR,w)},
CX(){var x=0,w=B.u(y.H),v=this
var $async$CX=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lw(),$async$CX)
case 3:x=2
return B.i(e.m3("Int",v.ga8T(),v.ax),$async$CX)
case 2:return B.r(null,w)}})
return B.t($async$CX,w)},
aJj(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga5(0))return
x.aFV(0,w)},
aFV(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.e.dM(0.16+o.at*0.006,0.16,0.5),m=A.e.dM(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.Ai(1.05,0.12+o.Q.aiy()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eB(x,new C.bqA())
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
o.CX()}break}}if(o.c!=null)o.u(new C.bqB())},
aCl(d){var x=this
if(!x.ay||x.CW.b===0)return
x.u(new C.bqx(x,d))},
aaW(){this.u(new C.bqz(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.asH()},
E(d){var x=this,w=null,v=x.gcJ(),u=$.bU7(),t=v.aZ(u.$1(x.a.d),y.x),s=v.aZ($.jL(),y.B)
v.u7(u.$1(x.a.d),new C.bqE(d))
u=$.fq
return B.dZ(B.ff(w,!0,A.G,w,w,0,A.l,w,w,B.aj(D.akQ,A.k,A.h,A.L,0,w)),u,B.vR(!0,B.al(B.b([new C.asX(B.de(t),w),A.al,new C.avB(x.at,x.ax,w),A.al,B.aC(new B.ap(F.EF,B.f5(B.a8(24),B.vi(new C.bqF(x,s)),A.aB),w),1,w)],y.p),A.k,A.h,A.i,0,A.n),A.ai,!0),w,!1,w)}}
C.aqO.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga5(0))return A.au
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hM(u,A.F,new C.bqG(t,v),A.eB,v,v):t.a4y(v)
return B.h0(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a4y(d){var x=null,w=B.b([new B.bL(2,A.a4,B.S(153,D.x4.l()>>>16&255,D.x4.l()>>>8&255,D.x4.l()&255),A.o,16)],y.V)
return B.a4(x,B.ac(E.lN,A.l,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.aum,A.be),x,d,x,x,x,x,x,d)}}
C.MB.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga5(0))return A.au
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hM(s,A.F,new C.bvi(r,v),A.eB,v,v):r.a4z(v)
return B.h0(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a4z(d){var x=null,w=B.bH(B.S(64,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),A.x,1.5),v=B.b([new B.bL(0,A.a4,B.S(A.e.a7(76.5),A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),A.o,8)],y.V)
return B.a4(x,B.ac(D.G2,B.S(217,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.DT,x,w,x,v,x,A.be),x,d,x,x,x,x,x,d)}}
C.asX.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.ayA
x=s.y
if(x===A.d2)return B.a4(t,D.a4h,A.j,t,t,new B.a9(B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),t,t,B.a8(14),t,t,A.q),t,t,t,A.dn,I.xM,t,t,t)
w=G.Tp(x)
x=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
v=B.a8(16)
s=s.CW
u=s===A.ev?A.iq:A.ip
u=B.b([new B.An(E.FE,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iQ),new B.An(A.dL,"\u062a\u062d\u0636\u064a\u0631",A.hy),new B.An(u,"\u062c\u0627\u0647\u0632",A.dC)],y.K)
if(s===A.cJ)u.push(new B.An(E.oy,"\u062a\u0648\u0635\u064a\u0644",A.f7))
u.push(new B.An(A.el,"\u062a\u0633\u0644\u064a\u0645",A.cz))
s=new B.dC(u,y.Q)
return B.a4(t,B.aj(s.geu(s).dO(0,new C.bvL(w),y.e).cM(0),A.k,A.dA,A.i,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.q),t,t,t,A.dn,A.fR,t,t,t)}}
C.avB.prototype={
E(d){var x=null
return new B.ap(A.dn,B.aj(B.b([B.aC(new C.a10("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lN,D.DU,x),1,x),A.bx,B.aC(new C.a10("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.FC,F.iL,x),1,x)],y.p),A.k,A.h,A.i,0,x),x)}}
C.a10.prototype={
E(d){var x=this,w=null,v=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),u=B.a8(14)
return B.a4(w,B.aj(B.b([B.ac(x.e,x.f,w,w,18),A.aw,B.m(""+x.d,w,w,w,w,B.v(w,w,A.l,w,w,w,w,w,w,w,w,16,w,w,A.v,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aI,B.aC(B.m(x.c,w,A.aq,w,w,B.v(w,w,A.aK,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.k,A.h,A.i,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.q),w,w,w,w,A.fS,w,w,w)}}
C.awA.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.e_.l()>>>16&255,A.e_.l()>>>8&255,A.e_.l()&255)
w=B.bH(A.e_,A.x,2)
v=u.d
w=B.b([B.a4(t,B.ac(D.G2,A.l,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.be),t,64,t,t,t,t,t,64),A.de,D.aGL,A.c0,B.m("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.v(t,t,A.aK,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.b_,B.aj(D.alv,A.k,A.h,A.L,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ac(E.lN,B.bu(4294929309),t,t,56),A.de,D.aHd,A.c0,D.aFO],r))
q.push(A.Bc)
r=B.ac(p?A.FO:D.aeX,t,t,t,t)
q.push(B.a9q(r,B.m(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hK(t,t,A.l,t,t,t,t,t,t,$.fq,t,t,D.a8Q,t,new B.ds(B.a8(14),A.H),t,t,t,t,t)))
return B.bPO(0,B.a4(t,B.cX(B.al(q,A.k,A.h,A.L,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a3f.prototype={
m(){var x=this,w=x.ci$
if(w!=null)w.O(0,x.ghJ())
x.ci$=null
x.ar()},
d_(){this.dL()
this.dw()
this.hK()}}
var z=a.updateTypes(["~(bC)","~(oF)","~()","C(Ai)","MB(Ai)"])
C.bqy.prototype={
$0(){var x=this.a,w=B.fd(J.aE(this.b.a,x.ga8T()))
return x.ax=w==null?0:w},
$S:0}
C.bqA.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bqB.prototype={
$0(){},
$S:0}
C.bqx.prototype={
$0(){var x=this.a
x.y=A.e.dM(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bqz.prototype={
$0(){var x=this.a
A.b.V(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bqE.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.de(d)
x=w==null?null:w.y}w=B.de(e)
if((w==null?null:w.y)===A.dC&&x!==A.dC)this.a.a0(y.q).f.cV(D.az4)},
$S:1077}
C.bqF.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.I(e.b,e.d)
x=B.b([$.fq,$.eD,$.ui],y.O)
w=t.z
v=this.b
w=B.P(new B.H(w,new C.bqC(t,v),B.T(w).h("H<1,d>")),y.l)
w.push(new C.aqO(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awA(t.ch,t.at,t.ax,t.gaOO(),u))
return B.d8(A.bD,B.a4(u,new B.e_(A.bt,u,A.bj,A.z,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.co(A.c3,A.cl,A.a6,x,u,u),A.q),u,u,u,u,u,u,u,u),A.A,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bqD(t),u,u,u,u,u,t.gaCk())},
$S:249}
C.bqD.prototype={
$0(){var x=this.a
if(!x.ay)x.aaW()},
$S:0}
C.bqC.prototype={
$1(d){return new C.MB(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bqG.prototype={
$3(d,e,f){return this.a.a4y(this.b)},
$S:55}
C.bvi.prototype={
$3(d,e,f){return this.a.a4z(this.b)},
$S:55}
C.bvL.prototype={
$1(d){var x,w=null,v=d.b,u=this.a,t=v.c,s=u>G.Tp(t),r=u===G.Tp(t)
if(s)x=A.a2
else x=r?A.l:B.S(A.e.a7(76.5),A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
u=r?B.S(38,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255):A.G
t=B.bH(x,A.x,r?2:1)
return B.aC(B.al(B.b([B.a4(w,B.ac(s?A.jL:v.a,x,w,w,14),A.j,w,w,new B.a9(u,w,t,w,w,w,A.be),w,28,w,w,w,w,w,28),A.kM,B.m(v.b,w,A.aq,w,w,B.v(w,w,x,w,w,w,w,w,w,w,w,9,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w)],y.p),A.k,A.h,A.L,0,A.n),1,w)},
$S:1078};(function aliases(){var x=C.a3f.prototype
x.asH=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.ZM.prototype,"gaJi","aJj",0)
x(v,"gaCk","aCl",1)
w(v,"gaOO","aaW",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.y5,B.uE)
w(C.Ai,B.A)
w(C.a3f,B.rE)
w(C.ZM,C.a3f)
v(B.kB,[C.bqy,C.bqB,C.bqx,C.bqz,C.bqD])
v(B.hG,[C.bqA,C.bqC,C.bqG,C.bvi,C.bvL])
v(B.kd,[C.bqE,C.bqF])
v(B.a_,[C.aqO,C.MB,C.asX,C.avB,C.a10,C.awA])
x(C.a3f,B.hi)})()
B.nj(b.typeUniverse,JSON.parse('{"MB":{"a_":[],"d":[]},"y5":{"R":[],"d":[]},"ZM":{"X":["y5"]},"aqO":{"a_":[],"d":[]},"asX":{"a_":[],"d":[]},"avB":{"a_":[],"d":[]},"a10":{"a_":[],"d":[]},"awA":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a6
return{x:x("bw<bn?>"),e:x("iU"),V:x("z<bL>"),O:x("z<J>"),K:x("z<+icon,label,status(ah,c,eN)>"),p:x("z<d>"),W:x("z<Ai>"),Q:x("dC<+icon,label,status(ah,c,eN)>"),B:x("fn"),l:x("d"),q:x("u0"),j:x("cZ?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_o=new B.Q(!0,A.aK,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGi=new B.ar("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_o,null,null,null,null,null,null,null,null)
D.a4h=new B.iO(A.F,null,null,D.aGi,null)
D.x4=new B.J(1,1,0.26666666666666666,0.5333333333333333,A.m)
D.DU=new B.J(1,1,0.4196078431372549,0.615686274509804,A.m)
D.a8Q=new B.a1(24,12,24,12)
D.FC=new B.ah(57900,"MaterialIcons",null,!1)
D.aeX=new B.ah(58571,"MaterialIcons",null,!1)
D.G2=new B.ah(63047,"MaterialIcons",null,!1)
D.agt=new B.cu(E.lN,20,null,null,null,null)
D.aHe=new B.ar("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akQ=x([D.agt,A.aw,D.aHe],y.p)
D.agc=new B.cu(D.FC,18,F.iL,null,null,null)
D.aCF=new B.Q(!0,F.iL,null,null,null,null,null,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aHf=new B.ar("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aCF,null,null,null,null,null,null,null,null)
D.alv=x([D.agc,A.aI,D.aHf],y.p)
D.a5e=new B.J(1,0.8,0.06666666666666667,0.3333333333333333,A.m)
D.an6=x([D.DU,D.a5e],y.O)
D.aum=new H.vI(A.F,0.5,A.a6,null,0,D.an6,null,null)
D.ayA=new B.cQ(null,64,null,null)
D.aHl=new B.ar("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.az4=new B.fa(D.aHl,A.a2,null,null,null,null,null,null,null,null,null,null,null,A.ac,!1,null,null,null,A.z,null)
D.aFO=new B.ar("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_o,null,null,null,null,null,null,null,null)
D.aC5=new B.Q(!0,A.l,null,null,null,null,22,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGL=new B.ar("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aC5,null,null,null,null,null,null,null,null)
D.aBN=new B.Q(!0,A.l,null,null,null,null,20,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aHd=new B.ar("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aBN,null,null,null,null,null,null,null,null)})()};
(a=>{a["0Gxc5VPIN0l15MbSs2zl0+B+q70="]=a.current})($__dart_deferred_initializers__);