((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cb2(d){return new C.xX(d,null)},
xX:function xX(d,e){this.d=d
this.a=e},
A8:function A8(d,e){this.a=d
this.b=e
this.c=!1},
Zx:function Zx(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.f1$=h
_.cl$=i
_.d=$
_.c=_.a=null},
boU:function boU(d,e){this.a=d
this.b=e},
boW:function boW(){},
boX:function boX(){},
boT:function boT(d,e){this.a=d
this.b=e},
boV:function boV(d){this.a=d},
bp_:function bp_(d){this.a=d},
bp0:function bp0(d,e){this.a=d
this.b=e},
boZ:function boZ(d){this.a=d},
boY:function boY(d,e){this.a=d
this.b=e},
aqr:function aqr(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bp1:function bp1(d,e){this.a=d
this.b=e},
Ma:function Ma(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
btE:function btE(d,e){this.a=d
this.b=e},
asC:function asC(d,e){this.c=d
this.a=e},
bu5:function bu5(d){this.a=d},
avf:function avf(d,e,f){this.c=d
this.d=e
this.a=f},
a0M:function a0M(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
awa:function awa(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a3_:function a3_(){}},D,H,F,I,G,E
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
C.xX.prototype={
a_(){var x=B.b([],y.W)
return new C.Zx(A.a6,x,A.wS,A.S,null,null)}}
C.A8.prototype={}
C.Zx.prototype={
ga89(){var x=this.gcD().cG(0,$.fO(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aG()
w.ID()
x=w.z_(w.gaI9())
x.uF(0)
w.w!==$&&B.bg()
w.w=x},
ID(){var x=0,w=B.u(y.H),v,u=this,t
var $async$ID=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lj(),$async$ID)
case 3:t=e
if(u.c==null){x=1
break}u.C(new C.boU(u,t))
case 1:return B.r(v,w)}})
return B.t($async$ID,w)},
CE(){var x=0,w=B.u(y.H),v=this
var $async$CE=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lj(),$async$CE)
case 3:x=2
return B.i(e.m1("Int",v.ga89(),v.ax),$async$CE)
case 2:return B.r(null,w)}})
return B.t($async$CE,w)},
aIa(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga3(0))return
x.aEU(0,w)},
aEU(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.d.dP(0.16+o.at*0.006,0.16,0.5),m=A.d.dP(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.A8(1.05,0.12+o.Q.ahI()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eM(x,new C.boW())
w=o.CW
s=w.a
r=w.b
w=Math.min(s,r)
for(v=x.length,w=(w*0.075+w*0.055)*0.8,u=0;u<x.length;x.length===v||(0,B.N)(x),++u){t=x[u]
q=(t.a-0.16)*s
p=(t.b-o.y)*r
if(Math.sqrt(q*q+p*p)<w){o.ch=!0
o.ay=!1
x=o.at
if(x>o.ax){o.ax=x
o.CE()}break}}if(o.c!=null)o.C(new C.boX())},
aBe(d){var x=this
if(!x.ay||x.CW.b===0)return
x.C(new C.boT(x,d))},
aa8(){this.C(new C.boV(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.arI()},
E(d){var x=this,w=null,v=x.gcD(),u=$.bS3(),t=v.bh(u.$1(x.a.d),y.x),s=v.bh($.k0(),y.B)
v.tU(u.$1(x.a.d),new C.bp_(d))
u=$.fl
return B.e9(B.fx(w,!0,A.F,w,w,0,A.k,w,w,B.ah(D.akd,A.j,A.f,A.P,0,w)),u,B.z2(!0,B.al(B.b([new C.asC(B.de(t),w),A.aq,new C.avf(x.at,x.ax,w),A.aq,B.aC(new B.aq(F.Et,B.fa(B.ab(24),B.va(new C.bp0(x,s)),A.aA),w),1,w)],y.p),A.j,A.f,A.h,0,A.n),A.ak,!0),w,!1,w)}}
C.aqr.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga3(0))return A.ap
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hV(u,A.E,new C.bp1(t,v),A.ez,v,v):t.a3W(v)
return B.fU(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a3W(d){var x=null,w=B.b([new B.bL(2,A.a4,B.S(153,D.x_.l()>>>16&255,D.x_.l()>>>8&255,D.x_.l()&255),A.m,16)],y.V)
return B.a7(x,B.ac(E.lI,A.k,x,x,d*0.6),A.i,x,x,new B.aa(x,x,x,x,w,D.atD,A.bj),x,d,x,x,x,x,x,d)}}
C.Ma.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga3(0))return A.ap
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hV(s,A.E,new C.btE(r,v),A.ez,v,v):r.a3X(v)
return B.fU(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a3X(d){var x=null,w=B.bF(B.S(64,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),A.w,1.5),v=B.b([new B.bL(0,A.a4,B.S(A.d.a4(76.5),A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),A.m,8)],y.V)
return B.a7(x,B.ac(D.FP,B.S(217,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),x,x,d*0.55),A.i,x,x,new B.aa(A.DF,x,w,x,v,x,A.bj),x,d,x,x,x,x,x,d)}}
C.asC.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.axr
x=s.y
if(x===A.cV)return B.a7(t,D.a3P,A.i,t,t,new B.aa(B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),t,t,B.ab(14),t,t,A.q),t,t,t,A.dh,I.xG,t,t,t)
w=G.T7(x)
x=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
v=B.ab(16)
s=s.CW
u=s===A.f3?A.ih:A.ie
u=B.b([new B.Ad(E.Fs,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iI),new B.Ad(A.e_,"\u062a\u062d\u0636\u064a\u0631",A.hs),new B.Ad(u,"\u062c\u0627\u0647\u0632",A.dx)],y.K)
if(s===A.cW)u.push(new B.Ad(E.op,"\u062a\u0648\u0635\u064a\u0644",A.f2))
u.push(new B.Ad(A.dZ,"\u062a\u0633\u0644\u064a\u0645",A.ca))
s=new B.dB(u,y.Q)
return B.a7(t,B.ah(s.geu(s).dF(0,new C.bu5(w),y.e).cM(0),A.j,A.du,A.h,0,t),A.i,t,t,new B.aa(x,t,t,v,t,t,A.q),t,t,t,A.dh,A.fk,t,t,t)}}
C.avf.prototype={
E(d){var x=null
return new B.aq(A.dh,B.ah(B.b([B.aC(new C.a0M("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lI,D.DG,x),1,x),A.bs,B.aC(new C.a0M("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.Fq,F.iC,x),1,x)],y.p),A.j,A.f,A.h,0,x),x)}}
C.a0M.prototype={
E(d){var x=this,w=null,v=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),u=B.ab(14)
return B.a7(w,B.ah(B.b([B.ac(x.e,x.f,w,w,18),A.ax,B.n(""+x.d,w,w,w,w,B.w(w,w,A.k,w,w,w,w,w,w,w,w,16,w,w,A.v,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aI,B.aC(B.n(x.c,w,A.as,w,w,B.w(w,w,A.aP,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.j,A.f,A.h,0,w),A.i,w,w,new B.aa(v,w,w,u,w,w,A.q),w,w,w,w,A.fN,w,w,w)}}
C.awa.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dS.l()>>>16&255,A.dS.l()>>>8&255,A.dS.l()&255)
w=B.bF(A.dS,A.w,2)
v=u.d
w=B.b([B.a7(t,B.ac(D.FP,A.k,t,t,34),A.i,t,t,new B.aa(x,t,w,t,t,t,A.bj),t,64,t,t,t,t,t,64),A.dJ,D.aFy,A.c4,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aP,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.b_,B.ah(D.akU,A.j,A.f,A.P,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ac(E.lI,B.bt(4294929309),t,t,56),A.dJ,D.aFZ,A.c4,D.aEz],r))
q.push(A.Zh)
r=B.ac(p?A.FB:D.aeg,t,t,t,t)
q.push(B.a9i(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hT(t,t,A.k,t,t,t,t,t,t,$.fl,t,t,D.a8g,t,new B.dC(B.ab(14),A.J),t,t,t,t,t)))
return B.bNP(0,B.a7(t,B.dy(B.al(q,A.j,A.f,A.P,0,A.n),t,t),A.i,s,t,t,t,t,t,t,t,t,t,t))}}
C.a3_.prototype={
m(){var x=this,w=x.cl$
if(w!=null)w.O(0,x.ghW())
x.cl$=null
x.ar()},
cZ(){this.dM()
this.dB()
this.hX()}}
var z=a.updateTypes(["~(bD)","~(oz)","~()","C(A8)","Ma(A8)"])
C.boU.prototype={
$0(){var x=this.a,w=B.f7(J.aL(this.b.a,x.ga89()))
return x.ax=w==null?0:w},
$S:0}
C.boW.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.boX.prototype={
$0(){},
$S:0}
C.boT.prototype={
$0(){var x=this.a
x.y=A.d.dP(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.boV.prototype={
$0(){var x=this.a
A.b.W(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bp_.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.de(d)
x=w==null?null:w.y}w=B.de(e)
if((w==null?null:w.y)===A.dx&&x!==A.dx)this.a.a1(y.q).f.d1(D.axV)},
$S:1054}
C.bp0.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.H(e.b,e.d)
x=B.b([$.fl,$.er,$.uf],y.O)
w=t.z
v=this.b
w=B.Q(new B.I(w,new C.boY(t,v),B.U(w).h("I<1,d>")),y.l)
w.push(new C.aqr(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awa(t.ch,t.at,t.ax,t.gaNB(),u))
return B.d8(A.bB,B.a7(u,new B.e1(A.bt,u,A.bg,A.y,w,u),A.i,u,u,new B.aa(u,u,u,u,u,new B.cm(A.c_,A.cf,A.a2,x,u,u),A.q),u,u,u,u,u,u,u,u),A.z,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.boZ(t),u,u,u,u,u,t.gaBd())},
$S:349}
C.boZ.prototype={
$0(){var x=this.a
if(!x.ay)x.aa8()},
$S:0}
C.boY.prototype={
$1(d){return new C.Ma(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bp1.prototype={
$3(d,e,f){return this.a.a3W(this.b)},
$S:52}
C.btE.prototype={
$3(d,e,f){return this.a.a3X(this.b)},
$S:52}
C.bu5.prototype={
$1(d){var x,w=null,v=d.b,u=this.a,t=v.c,s=u>G.T7(t),r=u===G.T7(t)
if(s)x=A.a0
else x=r?A.k:B.S(A.d.a4(76.5),A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
u=r?B.S(38,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255):A.F
t=B.bF(x,A.w,r?2:1)
return B.aC(B.al(B.b([B.a7(w,B.ac(s?A.jM:v.a,x,w,w,14),A.i,w,w,new B.aa(u,w,t,w,w,w,A.bj),w,28,w,w,w,w,w,28),A.kG,B.n(v.b,w,A.as,w,w,B.w(w,w,x,w,w,w,w,w,w,w,w,9,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w)],y.p),A.j,A.f,A.P,0,A.n),1,w)},
$S:1055};(function aliases(){var x=C.a3_.prototype
x.arI=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.Zx.prototype,"gaI9","aIa",0)
x(v,"gaBd","aBe",1)
w(v,"gaNB","aa8",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.xX,B.uB)
w(C.A8,B.A)
w(C.a3_,B.ry)
w(C.Zx,C.a3_)
v(B.ks,[C.boU,C.boX,C.boT,C.boV,C.boZ])
v(B.hA,[C.boW,C.boY,C.bp1,C.btE,C.bu5])
v(B.k3,[C.bp_,C.bp0])
v(B.a0,[C.aqr,C.Ma,C.asC,C.avf,C.a0M,C.awa])
x(C.a3_,B.hr)})()
B.n6(b.typeUniverse,JSON.parse('{"Ma":{"a0":[],"d":[]},"xX":{"R":[],"d":[]},"Zx":{"X":["xX"]},"aqr":{"a0":[],"d":[]},"asC":{"a0":[],"d":[]},"avf":{"a0":[],"d":[]},"a0M":{"a0":[],"d":[]},"awa":{"a0":[],"d":[]}}'))
var y=(function rtii(){var x=B.a5
return{x:x("bx<bi?>"),e:x("iO"),V:x("z<bL>"),O:x("z<J>"),K:x("z<+icon,label,status(ai,c,eF)>"),p:x("z<d>"),W:x("z<A8>"),Q:x("dB<+icon,label,status(ai,c,eF)>"),B:x("fh"),l:x("d"),q:x("tZ"),j:x("cX?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.ZW=new B.P(!0,A.aP,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aF5=new B.at("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.ZW,null,null,null,null,null,null,null,null)
D.a3P=new B.kX(A.E,null,null,D.aF5,null)
D.x_=new B.J(1,1,0.26666666666666666,0.5333333333333333,A.l)
D.DG=new B.J(1,1,0.4196078431372549,0.615686274509804,A.l)
D.a8g=new B.a3(24,12,24,12)
D.Fq=new B.ai(57900,"MaterialIcons",null,!1)
D.aeg=new B.ai(58571,"MaterialIcons",null,!1)
D.FP=new B.ai(63047,"MaterialIcons",null,!1)
D.afP=new B.cp(E.lI,20,null,null,null,null)
D.aG_=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akd=x([D.afP,A.ax,D.aG_],y.p)
D.afx=new B.cp(D.Fq,18,F.iC,null,null,null)
D.aBq=new B.P(!0,F.iC,null,null,null,null,null,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aG1=new B.at("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aBq,null,null,null,null,null,null,null,null)
D.akU=x([D.afx,A.aI,D.aG1],y.p)
D.a4M=new B.J(1,0.8,0.06666666666666667,0.3333333333333333,A.l)
D.amt=x([D.DG,D.a4M],y.O)
D.atD=new H.vA(A.E,0.5,A.a2,null,0,D.amt,null,null)
D.axr=new B.cP(null,64,null,null)
D.aG5=new B.at("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.axV=new B.fq(D.aG5,A.a0,null,null,null,null,null,null,null,null,null,null,null,A.ae,!1,null,null,null,A.y,null)
D.aEz=new B.at("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.ZW,null,null,null,null,null,null,null,null)
D.aAR=new B.P(!0,A.k,null,null,null,null,22,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFy=new B.at("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aAR,null,null,null,null,null,null,null,null)
D.aAy=new B.P(!0,A.k,null,null,null,null,20,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFZ=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aAy,null,null,null,null,null,null,null,null)})()};
(a=>{a["uh7dvEXpVP7WKtzvPxf4IgC+vDQ="]=a.current})($__dart_deferred_initializers__);