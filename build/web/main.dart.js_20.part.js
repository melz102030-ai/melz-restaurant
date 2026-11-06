((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cbx(d){return new C.y0(d,null)},
y0:function y0(d,e){this.d=d
this.a=e},
Ab:function Ab(d,e){this.a=d
this.b=e
this.c=!1},
Zz:function Zz(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.f_$=h
_.cm$=i
_.d=$
_.c=_.a=null},
bp6:function bp6(d,e){this.a=d
this.b=e},
bp8:function bp8(){},
bp9:function bp9(){},
bp5:function bp5(d,e){this.a=d
this.b=e},
bp7:function bp7(d){this.a=d},
bpc:function bpc(d){this.a=d},
bpd:function bpd(d,e){this.a=d
this.b=e},
bpb:function bpb(d){this.a=d},
bpa:function bpa(d,e){this.a=d
this.b=e},
aqw:function aqw(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bpe:function bpe(d,e){this.a=d
this.b=e},
Md:function Md(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
btP:function btP(d,e){this.a=d
this.b=e},
asH:function asH(d,e){this.c=d
this.a=e},
bul:function bul(d){this.a=d},
avk:function avk(d,e,f){this.c=d
this.d=e
this.a=f},
a0O:function a0O(d,e,f,g,h){var _=this
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
a31:function a31(){}},D,G,F,H,I,E
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
a_(){var x=B.b([],y.W)
return new C.Zz(A.a6,x,A.wW,A.S,null,null)}}
C.Ab.prototype={}
C.Zz.prototype={
ga8d(){var x=this.gcL().cT(0,$.h1(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aH()
w.IE()
x=w.yZ(w.gaIg())
x.uE(0)
w.w!==$&&B.bg()
w.w=x},
IE(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IE=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.ln(),$async$IE)
case 3:t=e
if(u.c==null){x=1
break}u.A(new C.bp6(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IE,w)},
CD(){var x=0,w=B.u(y.H),v=this
var $async$CD=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.ln(),$async$CD)
case 3:x=2
return B.i(e.m2("Int",v.ga8d(),v.ax),$async$CD)
case 2:return B.r(null,w)}})
return B.t($async$CD,w)},
aIh(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga2(0))return
x.aF2(0,w)},
aF2(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.d.dP(0.16+o.at*0.006,0.16,0.5),m=A.d.dP(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.Ab(1.05,0.12+o.Q.ahP()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eM(x,new C.bp8())
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
o.CD()}break}}if(o.c!=null)o.A(new C.bp9())},
aBn(d){var x=this
if(!x.ay||x.CW.b===0)return
x.A(new C.bp5(x,d))},
aae(){this.A(new C.bp7(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.arQ()},
E(d){var x=this,w=null,v=x.gcL(),u=$.bSy(),t=v.ba(u.$1(x.a.d),y.x),s=v.ba($.k1(),y.B)
v.wx(u.$1(x.a.d),new C.bpc(d))
u=$.fl
return B.e3(B.fx(w,!0,A.F,w,w,0,A.k,w,w,B.ae(D.akp,A.i,A.f,A.N,0,w)),u,B.z5(!0,B.al(B.b([new C.asH(B.ds(t),w),A.aq,new C.avk(x.at,x.ax,w),A.aq,B.aB(new B.aq(F.Es,B.fb(B.ac(24),B.vd(new C.bpd(x,s)),A.aB),w),1,w)],y.p),A.i,A.f,A.h,0,A.n),A.ak,!0),w,!1,w)}}
C.aqw.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga2(0))return A.ap
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hU(u,A.E,new C.bpe(t,v),A.ez,v,v):t.a40(v)
return B.fU(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a40(d){var x=null,w=B.b([new B.bL(2,A.a4,B.S(153,D.x3.l()>>>16&255,D.x3.l()>>>8&255,D.x3.l()&255),A.m,16)],y.V)
return B.a7(x,B.ab(E.lL,A.k,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.atO,A.bk),x,d,x,x,x,x,x,d)}}
C.Md.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga2(0))return A.ap
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hU(s,A.E,new C.btP(r,v),A.ez,v,v):r.a41(v)
return B.fU(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a41(d){var x=null,w=B.bD(B.S(64,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),A.w,1.5),v=B.b([new B.bL(0,A.a4,B.S(A.d.a6(76.5),A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),A.m,8)],y.V)
return B.a7(x,B.ab(D.FU,B.S(217,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.DE,x,w,x,v,x,A.bk),x,d,x,x,x,x,x,d)}}
C.asH.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.axD
x=s.y
if(x===A.d9)return B.a7(t,D.a3Z,A.j,t,t,new B.a9(B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),t,t,B.ac(14),t,t,A.p),t,t,t,A.d4,H.xK,t,t,t)
w=I.bWy(x)
x=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
v=B.ac(16)
s=s.CW
u=s===A.f3?A.il:A.ik
u=B.b([new B.wE(E.Fu,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iM),new B.wE(E.FI,"\u062a\u0623\u0643\u064a\u062f",A.iN),new B.wE(A.e_,"\u062a\u062d\u0636\u064a\u0631",A.hs),new B.wE(u,"\u062c\u0627\u0647\u0632",A.dw)],y.K)
if(s===A.cW)u.push(new B.wE(E.or,"\u062a\u0648\u0635\u064a\u0644",A.f2))
u.push(new B.wE(A.dZ,"\u062a\u0633\u0644\u064a\u0645",A.cc))
s=new B.dB(u,y.Q)
return B.a7(t,B.ae(s.gev(s).dG(0,new C.bul(w),y.e).cJ(0),A.i,A.du,A.h,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.p),t,t,t,A.d4,A.fk,t,t,t)}}
C.avk.prototype={
E(d){var x=null
return new B.aq(A.d4,B.ae(B.b([B.aB(new C.a0O("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lL,D.DF,x),1,x),A.br,B.aB(new C.a0O("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.Fs,F.iG,x),1,x)],y.p),A.i,A.f,A.h,0,x),x)}}
C.a0O.prototype={
E(d){var x=this,w=null,v=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),u=B.ac(14)
return B.a7(w,B.ae(B.b([B.ab(x.e,x.f,w,w,18),A.aw,B.n(""+x.d,w,w,w,w,B.w(w,w,A.k,w,w,w,w,w,w,w,w,16,w,w,A.u,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aG,B.aB(B.n(x.c,w,A.ax,w,w,B.w(w,w,A.aO,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.i,A.f,A.h,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.p),w,w,w,w,A.fO,w,w,w)}}
C.awf.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dS.l()>>>16&255,A.dS.l()>>>8&255,A.dS.l()&255)
w=B.bD(A.dS,A.w,2)
v=u.d
w=B.b([B.a7(t,B.ab(D.FU,A.k,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.bk),t,64,t,t,t,t,t,64),A.dI,D.aFH,A.c5,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aO,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.aX,B.ae(D.al4,A.i,A.f,A.N,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ab(E.lL,B.bt(4294929309),t,t,56),A.dI,D.aG7,A.c5,D.aEJ],r))
q.push(A.Zn)
r=B.ab(p?A.FE:D.aeo,t,t,t,t)
q.push(B.a9m(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hF(t,t,A.k,t,t,t,t,t,t,$.fl,t,t,D.a8n,t,new B.dC(B.ac(14),A.J),t,t,t,t,t)))
return B.bOk(0,B.a7(t,B.dx(B.al(q,A.i,A.f,A.N,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a31.prototype={
m(){var x=this,w=x.cm$
if(w!=null)w.O(0,x.ghX())
x.cm$=null
x.ar()},
cZ(){this.dM()
this.dC()
this.hY()}}
var z=a.updateTypes(["~(bF)","~(oB)","~()","C(Ab)","Md(Ab)"])
C.bp6.prototype={
$0(){var x=this.a,w=B.f6(J.aK(this.b.a,x.ga8d()))
return x.ax=w==null?0:w},
$S:0}
C.bp8.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bp9.prototype={
$0(){},
$S:0}
C.bp5.prototype={
$0(){var x=this.a
x.y=A.d.dP(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bp7.prototype={
$0(){var x=this.a
A.b.X(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bpc.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.ds(d)
x=w==null?null:w.y}w=B.ds(e)
if((w==null?null:w.y)===A.dw&&x!==A.dw)this.a.a3(y.q).f.d9(D.ay6)},
$S:1056}
C.bpd.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.I(e.b,e.d)
x=B.b([$.fl,$.er,$.ui],y.O)
w=t.z
v=this.b
w=B.Q(new B.H(w,new C.bpa(t,v),B.T(w).h("H<1,d>")),y.l)
w.push(new C.aqw(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awf(t.ch,t.at,t.ax,t.gaNJ(),u))
return B.d8(A.bC,B.a7(u,new B.e5(A.bt,u,A.bg,A.y,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.co(A.c_,A.cg,A.a2,x,u,u),A.p),u,u,u,u,u,u,u,u),A.z,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bpb(t),u,u,u,u,u,t.gaBm())},
$S:345}
C.bpb.prototype={
$0(){var x=this.a
if(!x.ay)x.aae()},
$S:0}
C.bpa.prototype={
$1(d){return new C.Md(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bpe.prototype={
$3(d,e,f){return this.a.a40(this.b)},
$S:55}
C.btP.prototype={
$3(d,e,f){return this.a.a41(this.b)},
$S:55}
C.bul.prototype={
$1(d){var x,w,v=null,u=d.a,t=d.b,s=this.a,r=s>u,q=s===u
if(r)x=A.a0
else x=q?A.k:B.S(A.d.a6(76.5),A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
s=q?B.S(38,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255):A.F
w=B.bD(x,A.w,q?2:1)
return B.aB(B.al(B.b([B.a7(v,B.ab(r?A.jM:t.a,x,v,v,14),A.j,v,v,new B.a9(s,v,w,v,v,v,A.bk),v,28,v,v,v,v,v,28),A.kI,B.n(t.b,v,A.ax,v,v,B.w(v,v,x,v,v,v,v,v,v,v,v,9,v,v,v,v,v,!0,v,v,v,v,v,v,v,v),v,v,v)],y.p),A.i,A.f,A.N,0,A.n),1,v)},
$S:1057};(function aliases(){var x=C.a31.prototype
x.arQ=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.Zz.prototype,"gaIg","aIh",0)
x(v,"gaBm","aBn",1)
w(v,"gaNJ","aae",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.y0,B.uE)
w(C.Ab,B.A)
w(C.a31,B.rB)
w(C.Zz,C.a31)
v(B.kz,[C.bp6,C.bp9,C.bp5,C.bp7,C.bpb])
v(B.hA,[C.bp8,C.bpa,C.bpe,C.btP,C.bul])
v(B.k3,[C.bpc,C.bpd])
v(B.a_,[C.aqw,C.Md,C.asH,C.avk,C.a0O,C.awf])
x(C.a31,B.ht)})()
B.n9(b.typeUniverse,JSON.parse('{"Md":{"a_":[],"d":[]},"y0":{"R":[],"d":[]},"Zz":{"X":["y0"]},"aqw":{"a_":[],"d":[]},"asH":{"a_":[],"d":[]},"avk":{"a_":[],"d":[]},"a0O":{"a_":[],"d":[]},"awf":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a6
return{x:x("bC<bn?>"),e:x("iP"),V:x("z<bL>"),O:x("z<J>"),K:x("z<+icon,label,status(ag,c,eE)>"),p:x("z<d>"),W:x("z<Ab>"),Q:x("dB<+icon,label,status(ag,c,eE)>"),B:x("fj"),l:x("d"),q:x("u0"),j:x("cX?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_1=new B.P(!0,A.aO,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFf=new B.at("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_1,null,null,null,null,null,null,null,null)
D.a3Z=new B.l1(A.E,null,null,D.aFf,null)
D.x3=new B.J(1,1,0.26666666666666666,0.5333333333333333,A.l)
D.DF=new B.J(1,1,0.4196078431372549,0.615686274509804,A.l)
D.a8n=new B.a4(24,12,24,12)
D.Fs=new B.ag(57900,"MaterialIcons",null,!1)
D.aeo=new B.ag(58571,"MaterialIcons",null,!1)
D.FU=new B.ag(63047,"MaterialIcons",null,!1)
D.afY=new B.cn(E.lL,20,null,null,null,null)
D.aG8=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akp=x([D.afY,A.aw,D.aG8],y.p)
D.afG=new B.cn(D.Fs,18,F.iG,null,null,null)
D.aBC=new B.P(!0,F.iG,null,null,null,null,null,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGa=new B.at("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aBC,null,null,null,null,null,null,null,null)
D.al4=x([D.afG,A.aG,D.aGa],y.p)
D.a4W=new B.J(1,0.8,0.06666666666666667,0.3333333333333333,A.l)
D.amE=x([D.DF,D.a4W],y.O)
D.atO=new G.vD(A.E,0.5,A.a2,null,0,D.amE,null,null)
D.axD=new B.cO(null,64,null,null)
D.aGf=new B.at("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.ay6=new B.fW(D.aGf,A.a0,null,null,null,null,null,null,null,null,null,null,null,A.ah,!1,null,null,null,A.y,null)
D.aEJ=new B.at("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_1,null,null,null,null,null,null,null,null)
D.aB2=new B.P(!0,A.k,null,null,null,null,22,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFH=new B.at("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aB2,null,null,null,null,null,null,null,null)
D.aAK=new B.P(!0,A.k,null,null,null,null,20,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aG7=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aAK,null,null,null,null,null,null,null,null)})()};
(a=>{a["5OnGklppyKY/qs9u/1aH3tKyX3c="]=a.current})($__dart_deferred_initializers__);