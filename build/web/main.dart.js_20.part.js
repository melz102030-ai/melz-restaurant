((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
cbP(d){return new C.y0(d,null)},
y0:function y0(d,e){this.d=d
this.a=e},
Ab:function Ab(d,e){this.a=d
this.b=e
this.c=!1},
ZB:function ZB(d,e,f,g,h,i){var _=this
_.w=$
_.x=d
_.y=0.5
_.z=e
_.Q=f
_.ax=_.at=_.as=0
_.ch=_.ay=!1
_.CW=g
_.f0$=h
_.cn$=i
_.d=$
_.c=_.a=null},
bpc:function bpc(d,e){this.a=d
this.b=e},
bpe:function bpe(){},
bpf:function bpf(){},
bpb:function bpb(d,e){this.a=d
this.b=e},
bpd:function bpd(d){this.a=d},
bpi:function bpi(d){this.a=d},
bpj:function bpj(d,e){this.a=d
this.b=e},
bph:function bph(d){this.a=d},
bpg:function bpg(d,e){this.a=d
this.b=e},
aqx:function aqx(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bpk:function bpk(d,e){this.a=d
this.b=e},
Md:function Md(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
btV:function btV(d,e){this.a=d
this.b=e},
asI:function asI(d,e){this.c=d
this.a=e},
bum:function bum(d){this.a=d},
avl:function avl(d,e,f){this.c=d
this.d=e
this.a=f},
a0Q:function a0Q(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
awg:function awg(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a34:function a34(){}},D,G,F,H,I,E
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
return new C.ZB(A.a6,x,A.wX,A.S,null,null)}}
C.Ab.prototype={}
C.ZB.prototype={
ga8f(){var x=this.gcF().cJ(0,$.fP(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aH()
w.IF()
x=w.yZ(w.gaIi())
x.uG(0)
w.w!==$&&B.bg()
w.w=x},
IF(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IF=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.ln(),$async$IF)
case 3:t=e
if(u.c==null){x=1
break}u.A(new C.bpc(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IF,w)},
CE(){var x=0,w=B.u(y.H),v=this
var $async$CE=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.ln(),$async$CE)
case 3:x=2
return B.i(e.m2("Int",v.ga8f(),v.ax),$async$CE)
case 2:return B.r(null,w)}})
return B.t($async$CE,w)},
aIj(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga3(0))return
x.aF3(0,w)},
aF3(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.d.dP(0.16+o.at*0.006,0.16,0.5),m=A.d.dP(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.Ab(1.05,0.12+o.Q.ahP()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eM(x,new C.bpe())
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
o.CE()}break}}if(o.c!=null)o.A(new C.bpf())},
aBo(d){var x=this
if(!x.ay||x.CW.b===0)return
x.A(new C.bpb(x,d))},
aae(){this.A(new C.bpd(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.arQ()},
E(d){var x=this,w=null,v=x.gcF(),u=$.bSP(),t=v.ba(u.$1(x.a.d),y.x),s=v.ba($.k1(),y.B)
v.tX(u.$1(x.a.d),new C.bpi(d))
u=$.fl
return B.e3(B.fy(w,!0,A.F,w,w,0,A.k,w,w,B.ae(D.akr,A.i,A.f,A.N,0,w)),u,B.z5(!0,B.al(B.b([new C.asI(B.dd(t),w),A.aq,new C.avl(x.at,x.ax,w),A.aq,B.aB(new B.aq(F.Et,B.fb(B.ac(24),B.ve(new C.bpj(x,s)),A.aB),w),1,w)],y.p),A.i,A.f,A.h,0,A.n),A.ak,!0),w,!1,w)}}
C.aqx.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga3(0))return A.ap
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hV(u,A.E,new C.bpk(t,v),A.ez,v,v):t.a41(v)
return B.fV(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a41(d){var x=null,w=B.b([new B.bL(2,A.a4,B.T(153,D.x4.l()>>>16&255,D.x4.l()>>>8&255,D.x4.l()&255),A.m,16)],y.V)
return B.a7(x,B.ab(E.lL,A.k,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.atQ,A.bk),x,d,x,x,x,x,x,d)}}
C.Md.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga3(0))return A.ap
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hV(s,A.E,new C.btV(r,v),A.ez,v,v):r.a42(v)
return B.fV(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a42(d){var x=null,w=B.bD(B.T(64,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),A.w,1.5),v=B.b([new B.bL(0,A.a4,B.T(A.d.a6(76.5),A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),A.m,8)],y.V)
return B.a7(x,B.ab(D.FV,B.T(217,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.DF,x,w,x,v,x,A.bk),x,d,x,x,x,x,x,d)}}
C.asI.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.axE
x=s.y
if(x===A.cV)return B.a7(t,D.a4_,A.j,t,t,new B.a9(B.T(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),t,t,B.ac(14),t,t,A.p),t,t,t,A.d4,H.xL,t,t,t)
w=I.bWP(x)
x=B.T(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
v=B.ac(16)
s=s.CW
u=s===A.f3?A.il:A.ik
u=B.b([new B.wE(E.Fv,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iM),new B.wE(E.FJ,"\u062a\u0623\u0643\u064a\u062f",A.iN),new B.wE(A.e_,"\u062a\u062d\u0636\u064a\u0631",A.hs),new B.wE(u,"\u062c\u0627\u0647\u0632",A.dw)],y.K)
if(s===A.cW)u.push(new B.wE(E.os,"\u062a\u0648\u0635\u064a\u0644",A.f2))
u.push(new B.wE(A.dZ,"\u062a\u0633\u0644\u064a\u0645",A.cb))
s=new B.dC(u,y.Q)
return B.a7(t,B.ae(s.gev(s).dG(0,new C.bum(w),y.e).cL(0),A.i,A.du,A.h,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.p),t,t,t,A.d4,A.fk,t,t,t)}}
C.avl.prototype={
E(d){var x=null
return new B.aq(A.d4,B.ae(B.b([B.aB(new C.a0Q("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lL,D.DG,x),1,x),A.br,B.aB(new C.a0Q("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.Ft,F.iG,x),1,x)],y.p),A.i,A.f,A.h,0,x),x)}}
C.a0Q.prototype={
E(d){var x=this,w=null,v=B.T(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),u=B.ac(14)
return B.a7(w,B.ae(B.b([B.ab(x.e,x.f,w,w,18),A.aw,B.n(""+x.d,w,w,w,w,B.w(w,w,A.k,w,w,w,w,w,w,w,w,16,w,w,A.u,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aG,B.aB(B.n(x.c,w,A.ax,w,w,B.w(w,w,A.aO,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.i,A.f,A.h,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.p),w,w,w,w,A.fO,w,w,w)}}
C.awg.prototype={
E(d){var x,w,v,u=this,t=null,s=B.T(140,A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.T(51,A.dS.l()>>>16&255,A.dS.l()>>>8&255,A.dS.l()&255)
w=B.bD(A.dS,A.w,2)
v=u.d
w=B.b([B.a7(t,B.ab(D.FV,A.k,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.bk),t,64,t,t,t,t,t,64),A.dI,D.aFM,A.c5,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aO,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.aX,B.ae(D.al6,A.i,A.f,A.N,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ab(E.lL,B.bt(4294929309),t,t,56),A.dI,D.aGc,A.c5,D.aEN],r))
q.push(A.Zo)
r=B.ab(p?A.FF:D.aeq,t,t,t,t)
q.push(B.a9m(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hG(t,t,A.k,t,t,t,t,t,t,$.fl,t,t,D.a8p,t,new B.dD(B.ac(14),A.J),t,t,t,t,t)))
return B.bOB(0,B.a7(t,B.dy(B.al(q,A.i,A.f,A.N,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a34.prototype={
m(){var x=this,w=x.cn$
if(w!=null)w.O(0,x.ghX())
x.cn$=null
x.ar()},
cZ(){this.dM()
this.dC()
this.hY()}}
var z=a.updateTypes(["~(bE)","~(oC)","~()","C(Ab)","Md(Ab)"])
C.bpc.prototype={
$0(){var x=this.a,w=B.f6(J.aL(this.b.a,x.ga8f()))
return x.ax=w==null?0:w},
$S:0}
C.bpe.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bpf.prototype={
$0(){},
$S:0}
C.bpb.prototype={
$0(){var x=this.a
x.y=A.d.dP(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bpd.prototype={
$0(){var x=this.a
A.b.X(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bpi.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.dd(d)
x=w==null?null:w.y}w=B.dd(e)
if((w==null?null:w.y)===A.dw&&x!==A.dw)this.a.a1(y.q).f.d1(D.ay7)},
$S:1057}
C.bpj.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.I(e.b,e.d)
x=B.b([$.fl,$.er,$.uj],y.O)
w=t.z
v=this.b
w=B.Q(new B.G(w,new C.bpg(t,v),B.S(w).h("G<1,d>")),y.l)
w.push(new C.aqx(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awg(t.ch,t.at,t.ax,t.gaNL(),u))
return B.d8(A.bC,B.a7(u,new B.e5(A.bt,u,A.bg,A.y,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.co(A.c_,A.cg,A.a2,x,u,u),A.p),u,u,u,u,u,u,u,u),A.z,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bph(t),u,u,u,u,u,t.gaBn())},
$S:335}
C.bph.prototype={
$0(){var x=this.a
if(!x.ay)x.aae()},
$S:0}
C.bpg.prototype={
$1(d){return new C.Md(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bpk.prototype={
$3(d,e,f){return this.a.a41(this.b)},
$S:57}
C.btV.prototype={
$3(d,e,f){return this.a.a42(this.b)},
$S:57}
C.bum.prototype={
$1(d){var x,w,v=null,u=d.a,t=d.b,s=this.a,r=s>u,q=s===u
if(r)x=A.a0
else x=q?A.k:B.T(A.d.a6(76.5),A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
s=q?B.T(38,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255):A.F
w=B.bD(x,A.w,q?2:1)
return B.aB(B.al(B.b([B.a7(v,B.ab(r?A.jM:t.a,x,v,v,14),A.j,v,v,new B.a9(s,v,w,v,v,v,A.bk),v,28,v,v,v,v,v,28),A.kI,B.n(t.b,v,A.ax,v,v,B.w(v,v,x,v,v,v,v,v,v,v,v,9,v,v,v,v,v,!0,v,v,v,v,v,v,v,v),v,v,v)],y.p),A.i,A.f,A.N,0,A.n),1,v)},
$S:1058};(function aliases(){var x=C.a34.prototype
x.arQ=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.ZB.prototype,"gaIi","aIj",0)
x(v,"gaBn","aBo",1)
w(v,"gaNL","aae",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.y0,B.uF)
w(C.Ab,B.A)
w(C.a34,B.rC)
w(C.ZB,C.a34)
v(B.kz,[C.bpc,C.bpf,C.bpb,C.bpd,C.bph])
v(B.hC,[C.bpe,C.bpg,C.bpk,C.btV,C.bum])
v(B.k3,[C.bpi,C.bpj])
v(B.a_,[C.aqx,C.Md,C.asI,C.avl,C.a0Q,C.awg])
x(C.a34,B.hu)})()
B.nb(b.typeUniverse,JSON.parse('{"Md":{"a_":[],"d":[]},"y0":{"R":[],"d":[]},"ZB":{"X":["y0"]},"aqx":{"a_":[],"d":[]},"asI":{"a_":[],"d":[]},"avl":{"a_":[],"d":[]},"a0Q":{"a_":[],"d":[]},"awg":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a6
return{x:x("bw<bi?>"),e:x("iQ"),V:x("z<bL>"),O:x("z<J>"),K:x("z<+icon,label,status(ag,c,eE)>"),p:x("z<d>"),W:x("z<Ab>"),Q:x("dC<+icon,label,status(ag,c,eE)>"),B:x("fj"),l:x("d"),q:x("u2"),j:x("cX?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_2=new B.P(!0,A.aO,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFj=new B.at("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_2,null,null,null,null,null,null,null,null)
D.a4_=new B.l1(A.E,null,null,D.aFj,null)
D.x4=new B.J(1,1,0.26666666666666666,0.5333333333333333,A.l)
D.DG=new B.J(1,1,0.4196078431372549,0.615686274509804,A.l)
D.a8p=new B.a4(24,12,24,12)
D.Ft=new B.ag(57900,"MaterialIcons",null,!1)
D.aeq=new B.ag(58571,"MaterialIcons",null,!1)
D.FV=new B.ag(63047,"MaterialIcons",null,!1)
D.ag_=new B.cn(E.lL,20,null,null,null,null)
D.aGd=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akr=x([D.ag_,A.aw,D.aGd],y.p)
D.afI=new B.cn(D.Ft,18,F.iG,null,null,null)
D.aBF=new B.P(!0,F.iG,null,null,null,null,null,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGf=new B.at("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aBF,null,null,null,null,null,null,null,null)
D.al6=x([D.afI,A.aG,D.aGf],y.p)
D.a4X=new B.J(1,0.8,0.06666666666666667,0.3333333333333333,A.l)
D.amG=x([D.DG,D.a4X],y.O)
D.atQ=new G.vE(A.E,0.5,A.a2,null,0,D.amG,null,null)
D.axE=new B.cP(null,64,null,null)
D.aGk=new B.at("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.ay7=new B.fq(D.aGk,A.a0,null,null,null,null,null,null,null,null,null,null,null,A.af,!1,null,null,null,A.y,null)
D.aEN=new B.at("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_2,null,null,null,null,null,null,null,null)
D.aB5=new B.P(!0,A.k,null,null,null,null,22,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFM=new B.at("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aB5,null,null,null,null,null,null,null,null)
D.aAN=new B.P(!0,A.k,null,null,null,null,20,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGc=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aAN,null,null,null,null,null,null,null,null)})()};
(a=>{a["UWt1TMa/H+8rHDY1Zy8MqVlhSCs="]=a.current})($__dart_deferred_initializers__);