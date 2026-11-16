((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cce(d){return new C.xX(d,null)},
xX:function xX(d,e){this.d=d
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
_.f2$=h
_.cl$=i
_.d=$
_.c=_.a=null},
bpd:function bpd(d,e){this.a=d
this.b=e},
bpf:function bpf(){},
bpg:function bpg(){},
bpc:function bpc(d,e){this.a=d
this.b=e},
bpe:function bpe(d){this.a=d},
bpj:function bpj(d){this.a=d},
bpk:function bpk(d,e){this.a=d
this.b=e},
bpi:function bpi(d){this.a=d},
bph:function bph(d,e){this.a=d
this.b=e},
aqu:function aqu(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bpl:function bpl(d,e){this.a=d
this.b=e},
Mg:function Mg(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
btY:function btY(d,e){this.a=d
this.b=e},
asD:function asD(d,e){this.c=d
this.a=e},
bur:function bur(d){this.a=d},
avi:function avi(d,e,f){this.c=d
this.d=e
this.a=f},
a0P:function a0P(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
awf:function awf(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a31:function a31(){}},D,H,F,I,G,E
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
return new C.ZA(A.a4,x,A.wU,A.T,null,null)}}
C.Aa.prototype={}
C.ZA.prototype={
ga8M(){var x=this.gcD().cJ(0,$.fT(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aI()
w.IL()
x=w.zj(w.gaJ0())
x.uP(0)
w.w!==$&&B.bf()
w.w=x},
IL(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IL=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.kO(),$async$IL)
case 3:t=e
if(u.c==null){x=1
break}u.A(new C.bpd(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IL,w)},
CR(){var x=0,w=B.u(y.H),v=this
var $async$CR=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.kO(),$async$CR)
case 3:x=2
return B.i(e.lp("Int",v.ga8M(),v.ax),$async$CR)
case 2:return B.r(null,w)}})
return B.t($async$CR,w)},
aJ1(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga3(0))return
x.aFF(0,w)},
aFF(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.e.dM(0.16+o.at*0.006,0.16,0.5),m=A.e.dM(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.Aa(1.05,0.12+o.Q.air()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eA(x,new C.bpf())
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
o.CR()}break}}if(o.c!=null)o.A(new C.bpg())},
aC5(d){var x=this
if(!x.ay||x.CW.b===0)return
x.A(new C.bpc(x,d))},
aaP(){this.A(new C.bpe(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.asu()},
E(d){var x=this,w=null,v=x.gcD(),u=$.bSY(),t=v.bi(u.$1(x.a.d),y.x),s=v.bi($.k4(),y.B)
v.u4(u.$1(x.a.d),new C.bpj(d))
u=$.fn
return B.ea(B.fz(w,!0,A.G,w,w,0,A.l,w,w,B.af(D.akB,A.k,A.h,A.N,0,w)),u,B.z4(!0,B.am(B.b([new C.asD(B.dd(t),w),A.am,new C.avi(x.at,x.ax,w),A.am,B.aC(new B.ap(F.EA,B.fd(B.aa(24),B.vc(new C.bpk(x,s)),A.aE),w),1,w)],y.p),A.k,A.h,A.i,0,A.n),A.al,!0),w,!1,w)}}
C.aqu.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga3(0))return A.au
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hY(u,A.F,new C.bpl(t,v),A.eC,v,v):t.a4q(v)
return B.hf(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a4q(d){var x=null,w=B.b([new B.bL(2,A.a6,B.S(153,D.x2.l()>>>16&255,D.x2.l()>>>8&255,D.x2.l()&255),A.o,16)],y.V)
return B.a7(x,B.ac(E.lK,A.l,x,x,d*0.6),A.j,x,x,new B.a8(x,x,x,x,w,D.au6,A.bd),x,d,x,x,x,x,x,d)}}
C.Mg.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga3(0))return A.au
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hY(s,A.F,new C.btY(r,v),A.eC,v,v):r.a4r(v)
return B.hf(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a4r(d){var x=null,w=B.bG(B.S(64,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),A.x,1.5),v=B.b([new B.bL(0,A.a6,B.S(A.e.a6(76.5),A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),A.o,8)],y.V)
return B.a7(x,B.ac(D.FU,B.S(217,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),x,x,d*0.55),A.j,x,x,new B.a8(A.DO,x,w,x,v,x,A.bd),x,d,x,x,x,x,x,d)}}
C.asD.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.ayj
x=s.y
if(x===A.d_)return B.a7(t,D.a40,A.j,t,t,new B.a8(B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),t,t,B.aa(14),t,t,A.q),t,t,t,A.dl,I.xJ,t,t,t)
w=G.Td(x)
x=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
v=B.aa(16)
s=s.CW
u=s===A.f6?A.im:A.ik
u=B.b([new B.Af(E.Fy,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iO),new B.Af(A.e4,"\u062a\u062d\u0636\u064a\u0631",A.hw),new B.Af(u,"\u062c\u0627\u0647\u0632",A.dB)],y.K)
if(s===A.d0)u.push(new B.Af(E.ow,"\u062a\u0648\u0635\u064a\u0644",A.f5))
u.push(new B.Af(A.e3,"\u062a\u0633\u0644\u064a\u0645",A.cc))
s=new B.dC(u,y.Q)
return B.a7(t,B.af(s.ges(s).dH(0,new C.bur(w),y.e).cM(0),A.k,A.dy,A.i,0,t),A.j,t,t,new B.a8(x,t,t,v,t,t,A.q),t,t,t,A.dl,A.fp,t,t,t)}}
C.avi.prototype={
E(d){var x=null
return new B.ap(A.dl,B.af(B.b([B.aC(new C.a0P("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lK,D.DP,x),1,x),A.bw,B.aC(new C.a0P("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.Fw,F.iI,x),1,x)],y.p),A.k,A.h,A.i,0,x),x)}}
C.a0P.prototype={
E(d){var x=this,w=null,v=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),u=B.aa(14)
return B.a7(w,B.af(B.b([B.ac(x.e,x.f,w,w,18),A.az,B.n(""+x.d,w,w,w,w,B.w(w,w,A.l,w,w,w,w,w,w,w,w,16,w,w,A.v,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aG,B.aC(B.n(x.c,w,A.ap,w,w,B.w(w,w,A.aI,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.k,A.h,A.i,0,w),A.j,w,w,new B.a8(v,w,w,u,w,w,A.q),w,w,w,w,A.fQ,w,w,w)}}
C.awf.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dY.l()>>>16&255,A.dY.l()>>>8&255,A.dY.l()&255)
w=B.bG(A.dY,A.x,2)
v=u.d
w=B.b([B.a7(t,B.ac(D.FU,A.l,t,t,34),A.j,t,t,new B.a8(x,t,w,t,t,t,A.bd),t,64,t,t,t,t,t,64),A.dc,D.aGt,A.c_,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aI,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.b0,B.af(D.alh,A.k,A.h,A.N,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ac(E.lK,B.bu(4294929309),t,t,56),A.dc,D.aGU,A.c_,D.aFu],r))
q.push(A.B6)
r=B.ac(p?A.FH:D.aeC,t,t,t,t)
q.push(B.a9d(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hI(t,t,A.l,t,t,t,t,t,t,$.fn,t,t,D.a8w,t,new B.dv(B.aa(14),A.I),t,t,t,t,t)))
return B.bOA(0,B.a7(t,B.dx(B.am(q,A.k,A.h,A.N,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a31.prototype={
m(){var x=this,w=x.cl$
if(w!=null)w.O(0,x.ghZ())
x.cl$=null
x.ar()},
d1(){this.dQ()
this.dA()
this.i_()}}
var z=a.updateTypes(["~(bA)","~(oC)","~()","C(Aa)","Mg(Aa)"])
C.bpd.prototype={
$0(){var x=this.a,w=B.fa(J.aH(this.b.a,x.ga8M()))
return x.ax=w==null?0:w},
$S:0}
C.bpf.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bpg.prototype={
$0(){},
$S:0}
C.bpc.prototype={
$0(){var x=this.a
x.y=A.e.dM(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bpe.prototype={
$0(){var x=this.a
A.b.V(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bpj.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.dd(d)
x=w==null?null:w.y}w=B.dd(e)
if((w==null?null:w.y)===A.dB&&x!==A.dB)this.a.a2(y.q).f.d4(D.ayN)},
$S:1066}
C.bpk.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.H(e.b,e.d)
x=B.b([$.fn,$.es,$.uc],y.O)
w=t.z
v=this.b
w=B.Q(new B.J(w,new C.bph(t,v),B.T(w).h("J<1,d>")),y.l)
w.push(new C.aqu(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awf(t.ch,t.at,t.ax,t.gaOr(),u))
return B.d9(A.bD,B.a7(u,new B.e1(A.bx,u,A.bm,A.z,w,u),A.j,u,u,new B.a8(u,u,u,u,u,new B.co(A.c2,A.cj,A.a5,x,u,u),A.q),u,u,u,u,u,u,u,u),A.A,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bpi(t),u,u,u,u,u,t.gaC4())},
$S:349}
C.bpi.prototype={
$0(){var x=this.a
if(!x.ay)x.aaP()},
$S:0}
C.bph.prototype={
$1(d){return new C.Mg(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bpl.prototype={
$3(d,e,f){return this.a.a4q(this.b)},
$S:54}
C.btY.prototype={
$3(d,e,f){return this.a.a4r(this.b)},
$S:54}
C.bur.prototype={
$1(d){var x,w=null,v=d.b,u=this.a,t=v.c,s=u>G.Td(t),r=u===G.Td(t)
if(s)x=A.a1
else x=r?A.l:B.S(A.e.a6(76.5),A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
u=r?B.S(38,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255):A.G
t=B.bG(x,A.x,r?2:1)
return B.aC(B.am(B.b([B.a7(w,B.ac(s?A.jO:v.a,x,w,w,14),A.j,w,w,new B.a8(u,w,t,w,w,w,A.bd),w,28,w,w,w,w,w,28),A.kK,B.n(v.b,w,A.ap,w,w,B.w(w,w,x,w,w,w,w,w,w,w,w,9,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w)],y.p),A.k,A.h,A.N,0,A.n),1,w)},
$S:1067};(function aliases(){var x=C.a31.prototype
x.asu=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.ZA.prototype,"gaJ0","aJ1",0)
x(v,"gaC4","aC5",1)
w(v,"gaOr","aaP",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.xX,B.uy)
w(C.Aa,B.A)
w(C.a31,B.ry)
w(C.ZA,C.a31)
v(B.ku,[C.bpd,C.bpg,C.bpc,C.bpe,C.bpi])
v(B.hE,[C.bpf,C.bph,C.bpl,C.btY,C.bur])
v(B.k6,[C.bpj,C.bpk])
v(B.a_,[C.aqu,C.Mg,C.asD,C.avi,C.a0P,C.awf])
x(C.a31,B.hw)})()
B.ne(b.typeUniverse,JSON.parse('{"Mg":{"a_":[],"d":[]},"xX":{"R":[],"d":[]},"ZA":{"X":["xX"]},"aqu":{"a_":[],"d":[]},"asD":{"a_":[],"d":[]},"avi":{"a_":[],"d":[]},"a0P":{"a_":[],"d":[]},"awf":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a4
return{x:x("bw<bg?>"),e:x("iT"),V:x("z<bL>"),O:x("z<I>"),K:x("z<+icon,label,status(ah,c,eJ)>"),p:x("z<d>"),W:x("z<Aa>"),Q:x("dC<+icon,label,status(ah,c,eJ)>"),B:x("fk"),l:x("d"),q:x("tW"),j:x("cX?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_a=new B.P(!0,A.aI,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aG0=new B.at("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_a,null,null,null,null,null,null,null,null)
D.a40=new B.l3(A.F,null,null,D.aG0,null)
D.x2=new B.I(1,1,0.26666666666666666,0.5333333333333333,A.m)
D.DP=new B.I(1,1,0.4196078431372549,0.615686274509804,A.m)
D.a8w=new B.a2(24,12,24,12)
D.Fw=new B.ah(57900,"MaterialIcons",null,!1)
D.aeC=new B.ah(58571,"MaterialIcons",null,!1)
D.FU=new B.ah(63047,"MaterialIcons",null,!1)
D.agc=new B.ct(E.lK,20,null,null,null,null)
D.aGV=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akB=x([D.agc,A.az,D.aGV],y.p)
D.afV=new B.ct(D.Fw,18,F.iI,null,null,null)
D.aCk=new B.P(!0,F.iI,null,null,null,null,null,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGX=new B.at("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aCk,null,null,null,null,null,null,null,null)
D.alh=x([D.afV,A.aG,D.aGX],y.p)
D.a4Y=new B.I(1,0.8,0.06666666666666667,0.3333333333333333,A.m)
D.amS=x([D.DP,D.a4Y],y.O)
D.au6=new H.vC(A.F,0.5,A.a5,null,0,D.amS,null,null)
D.ayj=new B.cU(null,64,null,null)
D.aH0=new B.at("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.ayN=new B.ft(D.aH0,A.a1,null,null,null,null,null,null,null,null,null,null,null,A.af,!1,null,null,null,A.z,null)
D.aFu=new B.at("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_a,null,null,null,null,null,null,null,null)
D.aBL=new B.P(!0,A.l,null,null,null,null,22,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGt=new B.at("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aBL,null,null,null,null,null,null,null,null)
D.aBs=new B.P(!0,A.l,null,null,null,null,20,A.v,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGU=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aBs,null,null,null,null,null,null,null,null)})()};
(a=>{a["9EvNqoDQGqd74f5V0rw+RuTtIyE="]=a.current})($__dart_deferred_initializers__);