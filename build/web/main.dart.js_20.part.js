((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cah(d){return new C.xT(d,null)},
xT:function xT(d,e){this.d=d
this.a=e},
A1:function A1(d,e){this.a=d
this.b=e
this.c=!1},
Zj:function Zj(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.eZ$=h
_.cl$=i
_.d=$
_.c=_.a=null},
boe:function boe(d,e){this.a=d
this.b=e},
bog:function bog(){},
boh:function boh(){},
bod:function bod(d,e){this.a=d
this.b=e},
bof:function bof(d){this.a=d},
bok:function bok(d){this.a=d},
bol:function bol(d,e){this.a=d
this.b=e},
boj:function boj(d){this.a=d},
boi:function boi(d,e){this.a=d
this.b=e},
aqc:function aqc(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bom:function bom(d,e){this.a=d
this.b=e},
M4:function M4(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
bsP:function bsP(d,e){this.a=d
this.b=e},
asn:function asn(d,e){this.c=d
this.a=e},
btl:function btl(d){this.a=d},
av0:function av0(d,e,f){this.c=d
this.d=e
this.a=f},
a0y:function a0y(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
avW:function avW(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a2M:function a2M(){}},D,G,F,H,I,E
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
C.xT.prototype={
a_(){var x=B.b([],y.W)
return new C.Zj(A.a5,x,A.wQ,A.S,null,null)}}
C.A1.prototype={}
C.Zj.prototype={
ga83(){var x=this.gd6().d8(0,$.he(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aI()
w.Ix()
x=w.yR(w.gaHY())
x.uD(0)
w.w!==$&&B.bg()
w.w=x},
Ix(){var x=0,w=B.v(y.H),v,u=this,t
var $async$Ix=B.p(function(d,e){if(d===1)return B.r(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lh(),$async$Ix)
case 3:t=e
if(u.c==null){x=1
break}u.C(new C.boe(u,t))
case 1:return B.t(v,w)}})
return B.u($async$Ix,w)},
Ct(){var x=0,w=B.v(y.H),v=this
var $async$Ct=B.p(function(d,e){if(d===1)return B.r(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lh(),$async$Ct)
case 3:x=2
return B.i(e.m_("Int",v.ga83(),v.ax),$async$Ct)
case 2:return B.t(null,w)}})
return B.u($async$Ct,w)},
aHZ(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga2(0))return
x.aEK(0,w)},
aEK(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.d.dT(0.16+o.at*0.006,0.16,0.5),m=A.d.dT(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.A1(1.05,0.12+o.Q.ahB()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eM(x,new C.bog())
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
o.Ct()}break}}if(o.c!=null)o.C(new C.boh())},
aB4(d){var x=this
if(!x.ay||x.CW.b===0)return
x.C(new C.bod(x,d))},
aa3(){this.C(new C.bof(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.arB()},
E(d){var x=this,w=null,v=x.gd6(),u=$.bRm(),t=v.bn(u.$1(x.a.d),y.x),s=v.bn($.kl(),y.B)
v.wt(u.$1(x.a.d),new C.bok(d))
u=$.fg
return B.eb(B.fJ(w,!0,A.F,w,w,0,A.k,w,w,B.ae(D.ak9,A.i,A.f,A.N,0,w)),u,B.yY(!0,B.am(B.b([new C.asn(B.dB(t),w),A.aq,new C.av0(x.at,x.ax,w),A.aq,B.aB(new B.aq(F.Ep,B.f7(B.ac(24),B.v7(new C.bol(x,s)),A.aB),w),1,w)],y.p),A.i,A.f,A.h,0,A.n),A.ak,!0),w,!1,w)}}
C.aqc.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga2(0))return A.ap
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hQ(u,A.E,new C.bom(t,v),A.ez,v,v):t.a3R(v)
return B.fO(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a3R(d){var x=null,w=B.b([new B.bK(2,A.a4,B.S(153,D.wY.l()>>>16&255,D.wY.l()>>>8&255,D.wY.l()&255),A.m,16)],y.V)
return B.a7(x,B.aa(E.lM,A.k,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.atx,A.bj),x,d,x,x,x,x,x,d)}}
C.M4.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga2(0))return A.ap
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hQ(s,A.E,new C.bsP(r,v),A.ez,v,v):r.a3S(v)
return B.fO(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a3S(d){var x=null,w=B.bC(B.S(64,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),A.w,1.5),v=B.b([new B.bK(0,A.a4,B.S(A.d.a4(76.5),A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),A.m,8)],y.V)
return B.a7(x,B.aa(D.FQ,B.S(217,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.Dy,x,w,x,v,x,A.bj),x,d,x,x,x,x,x,d)}}
C.asn.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.axl
x=s.y
if(x===A.d6)return B.a7(t,D.a3V,A.j,t,t,new B.a9(B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),t,t,B.ac(14),t,t,A.p),t,t,t,A.d2,H.xC,t,t,t)
w=I.bVm(x)
x=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
v=B.ac(16)
s=s.CW
u=s===A.f4?A.il:A.ik
u=B.b([new B.ww(E.Fq,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iM),new B.ww(E.FE,"\u062a\u0623\u0643\u064a\u062f",A.iN),new B.ww(A.dW,"\u062a\u062d\u0636\u064a\u0631",A.ht),new B.ww(u,"\u062c\u0627\u0647\u0632",A.du)],y.K)
if(s===A.cW)u.push(new B.ww(E.oo,"\u062a\u0648\u0635\u064a\u0644",A.f3))
u.push(new B.ww(A.eK,"\u062a\u0633\u0644\u064a\u0645",A.cc))
s=new B.dy(u,y.Q)
return B.a7(t,B.ae(s.ges(s).dF(0,new C.btl(w),y.e).cK(0),A.i,A.ds,A.h,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.p),t,t,t,A.d2,A.fk,t,t,t)}}
C.av0.prototype={
E(d){var x=null
return new B.aq(A.d2,B.ae(B.b([B.aB(new C.a0y("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lM,D.Dz,x),1,x),A.by,B.aB(new C.a0y("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.Fo,F.iG,x),1,x)],y.p),A.i,A.f,A.h,0,x),x)}}
C.a0y.prototype={
E(d){var x=this,w=null,v=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),u=B.ac(14)
return B.a7(w,B.ae(B.b([B.aa(x.e,x.f,w,w,18),A.ax,B.n(""+x.d,w,w,w,w,B.w(w,w,A.k,w,w,w,w,w,w,w,w,16,w,w,A.t,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aE,B.aB(B.n(x.c,w,A.as,w,w,B.w(w,w,A.aN,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.i,A.f,A.h,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.p),w,w,w,w,A.fP,w,w,w)}}
C.avW.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dQ.l()>>>16&255,A.dQ.l()>>>8&255,A.dQ.l()&255)
w=B.bC(A.dQ,A.w,2)
v=u.d
w=B.b([B.a7(t,B.aa(D.FQ,A.k,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.bj),t,64,t,t,t,t,t,64),A.dx,D.aFn,A.bZ,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aN,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.aW,B.ae(D.akO,A.i,A.f,A.N,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.aa(E.lM,B.bs(4294929309),t,t,56),A.dx,D.aFN,A.bZ,D.aEp],r))
q.push(A.Zi)
r=B.aa(p?A.FA:D.aef,t,t,t,t)
q.push(B.a93(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hz(t,t,A.k,t,t,t,t,t,t,$.fg,t,t,D.a8g,t,new B.dC(B.ac(14),A.J),t,t,t,t,t)))
return B.bNa(0,B.a7(t,B.dv(B.am(q,A.i,A.f,A.N,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a2M.prototype={
m(){var x=this,w=x.cl$
if(w!=null)w.O(0,x.ghV())
x.cl$=null
x.ar()},
cW(){this.dL()
this.dB()
this.hW()}}
var z=a.updateTypes(["~(bD)","~(ou)","~()","B(A1)","M4(A1)"])
C.boe.prototype={
$0(){var x=this.a,w=B.f2(J.aL(this.b.a,x.ga83()))
return x.ax=w==null?0:w},
$S:0}
C.bog.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.boh.prototype={
$0(){},
$S:0}
C.bod.prototype={
$0(){var x=this.a
x.y=A.d.dT(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bof.prototype={
$0(){var x=this.a
A.b.W(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bok.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.dB(d)
x=w==null?null:w.y}w=B.dB(e)
if((w==null?null:w.y)===A.du&&x!==A.du)this.a.a3(y.q).f.d9(D.axP)},
$S:1050}
C.bol.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.I(e.b,e.d)
x=B.b([$.fg,$.eq,$.ud],y.O)
w=t.z
v=this.b
w=B.Q(new B.G(w,new C.boi(t,v),B.T(w).h("G<1,d>")),y.l)
w.push(new C.aqc(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.avW(t.ch,t.at,t.ax,t.gaNp(),u))
return B.d7(A.bB,B.a7(u,new B.e3(A.br,u,A.bg,A.y,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.cm(A.c0,A.cf,A.a2,x,u,u),A.p),u,u,u,u,u,u,u,u),A.z,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.boj(t),u,u,u,u,u,t.gaB3())},
$S:341}
C.boj.prototype={
$0(){var x=this.a
if(!x.ay)x.aa3()},
$S:0}
C.boi.prototype={
$1(d){return new C.M4(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bom.prototype={
$3(d,e,f){return this.a.a3R(this.b)},
$S:60}
C.bsP.prototype={
$3(d,e,f){return this.a.a3S(this.b)},
$S:60}
C.btl.prototype={
$1(d){var x,w,v=null,u=d.a,t=d.b,s=this.a,r=s>u,q=s===u
if(r)x=A.a0
else x=q?A.k:B.S(A.d.a4(76.5),A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
s=q?B.S(38,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255):A.F
w=B.bC(x,A.w,q?2:1)
return B.aB(B.am(B.b([B.a7(v,B.aa(r?A.jK:t.a,x,v,v,14),A.j,v,v,new B.a9(s,v,w,v,v,v,A.bj),v,28,v,v,v,v,v,28),A.kF,B.n(t.b,v,A.as,v,v,B.w(v,v,x,v,v,v,v,v,v,v,v,9,v,v,v,v,v,!0,v,v,v,v,v,v,v,v),v,v,v)],y.p),A.i,A.f,A.N,0,A.n),1,v)},
$S:1051};(function aliases(){var x=C.a2M.prototype
x.arB=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.Zj.prototype,"gaHY","aHZ",0)
x(v,"gaB3","aB4",1)
w(v,"gaNp","aa3",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.xT,B.uz)
w(C.A1,B.A)
w(C.a2M,B.rw)
w(C.Zj,C.a2M)
v(B.ks,[C.boe,C.boh,C.bod,C.bof,C.boj])
v(B.hv,[C.bog,C.boi,C.bom,C.bsP,C.btl])
v(B.jW,[C.bok,C.bol])
v(B.a_,[C.aqc,C.M4,C.asn,C.av0,C.a0y,C.avW])
x(C.a2M,B.hn)})()
B.n_(b.typeUniverse,JSON.parse('{"M4":{"a_":[],"d":[]},"xT":{"R":[],"d":[]},"Zj":{"X":["xT"]},"aqc":{"a_":[],"d":[]},"asn":{"a_":[],"d":[]},"av0":{"a_":[],"d":[]},"a0y":{"a_":[],"d":[]},"avW":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a6
return{x:x("bQ<bt?>"),e:x("j9"),V:x("z<bK>"),O:x("z<J>"),K:x("z<+icon,label,status(aj,c,eE)>"),p:x("z<d>"),W:x("z<A1>"),Q:x("dy<+icon,label,status(aj,c,eE)>"),B:x("fk"),l:x("d"),q:x("tZ"),j:x("cW?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.ZX=new B.P(!0,A.aN,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aEW=new B.at("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.ZX,null,null,null,null,null,null,null,null)
D.a3V=new B.kY(A.E,null,null,D.aEW,null)
D.wY=new B.J(1,1,0.26666666666666666,0.5333333333333333,A.l)
D.Dz=new B.J(1,1,0.4196078431372549,0.615686274509804,A.l)
D.a8g=new B.a3(24,12,24,12)
D.Fo=new B.aj(57900,"MaterialIcons",null,!1)
D.aef=new B.aj(58571,"MaterialIcons",null,!1)
D.FQ=new B.aj(63047,"MaterialIcons",null,!1)
D.afJ=new B.cx(E.lM,20,null,null,null,null)
D.aFO=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.ak9=x([D.afJ,A.ax,D.aFO],y.p)
D.aft=new B.cx(D.Fo,18,F.iG,null,null,null)
D.aBk=new B.P(!0,F.iG,null,null,null,null,null,A.t,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFQ=new B.at("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aBk,null,null,null,null,null,null,null,null)
D.akO=x([D.aft,A.aE,D.aFQ],y.p)
D.a4S=new B.J(1,0.8,0.06666666666666667,0.3333333333333333,A.l)
D.amn=x([D.Dz,D.a4S],y.O)
D.atx=new G.vw(A.E,0.5,A.a2,null,0,D.amn,null,null)
D.axl=new B.cL(null,64,null,null)
D.aFV=new B.at("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.axP=new B.fQ(D.aFV,A.a0,null,null,null,null,null,null,null,null,null,null,null,A.ah,!1,null,null,null,A.y,null)
D.aEp=new B.at("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.ZX,null,null,null,null,null,null,null,null)
D.aAL=new B.P(!0,A.k,null,null,null,null,22,A.t,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFn=new B.at("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aAL,null,null,null,null,null,null,null,null)
D.aAs=new B.P(!0,A.k,null,null,null,null,20,A.t,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFN=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aAs,null,null,null,null,null,null,null,null)})()};
(a=>{a["VW+T8+G7RfZ/afDTgkJd8jCBbrM="]=a.current})($__dart_deferred_initializers__);