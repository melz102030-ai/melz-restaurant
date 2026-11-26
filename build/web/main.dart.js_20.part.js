((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
ccx(d){return new C.y_(d,null)},
y_:function y_(d,e){this.d=d
this.a=e},
Ab:function Ab(d,e){this.a=d
this.b=e
this.c=!1},
ZE:function ZE(d,e,f,g,h,i){var _=this
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
bpy:function bpy(d,e){this.a=d
this.b=e},
bpA:function bpA(){},
bpB:function bpB(){},
bpx:function bpx(d,e){this.a=d
this.b=e},
bpz:function bpz(d){this.a=d},
bpE:function bpE(d){this.a=d},
bpF:function bpF(d,e){this.a=d
this.b=e},
bpD:function bpD(d){this.a=d},
bpC:function bpC(d,e){this.a=d
this.b=e},
aqz:function aqz(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
bpG:function bpG(d,e){this.a=d
this.b=e},
Ml:function Ml(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
bui:function bui(d,e){this.a=d
this.b=e},
asI:function asI(d,e){this.c=d
this.a=e},
buM:function buM(d){this.a=d},
avn:function avn(d,e,f){this.c=d
this.d=e
this.a=f},
a0T:function a0T(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
awk:function awk(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a36:function a36(){}},D,H,F,I,G,E
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
return new C.ZE(A.a5,x,A.wU,A.T,null,null)}}
C.Ab.prototype={}
C.ZE.prototype={
ga8M(){var x=this.gcI().cJ(0,$.h5(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aI()
w.IM()
x=w.zj(w.gaJ0())
x.uP(0)
w.w!==$&&B.bf()
w.w=x},
IM(){var x=0,w=B.u(y.H),v,u=this,t
var $async$IM=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lq(),$async$IM)
case 3:t=e
if(u.c==null){x=1
break}u.v(new C.bpy(u,t))
case 1:return B.r(v,w)}})
return B.t($async$IM,w)},
CR(){var x=0,w=B.u(y.H),v=this
var $async$CR=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lq(),$async$CR)
case 3:x=2
return B.i(e.m0("Int",v.ga8M(),v.ax),$async$CR)
case 2:return B.r(null,w)}})
return B.t($async$CR,w)},
aJ1(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga3(0))return
x.aFF(0,w)},
aFF(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.e.dM(0.16+o.at*0.006,0.16,0.5),m=A.e.dM(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.Ab(1.05,0.12+o.Q.air()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eA(x,new C.bpA())
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
o.CR()}break}}if(o.c!=null)o.v(new C.bpB())},
aC5(d){var x=this
if(!x.ay||x.CW.b===0)return
x.v(new C.bpx(x,d))},
aaP(){this.v(new C.bpz(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.asu()},
E(d){var x=this,w=null,v=x.gcI(),u=$.bTg(),t=v.b5(u.$1(x.a.d),y.x),s=v.b5($.jH(),y.B)
v.u4(u.$1(x.a.d),new C.bpE(d))
u=$.fo
return B.e3(B.fA(w,!0,A.G,w,w,0,A.l,w,w,B.ai(D.akF,A.k,A.h,A.N,0,w)),u,B.vN(!0,B.ak(B.b([new C.asI(B.d8(t),w),A.al,new C.avn(x.at,x.ax,w),A.al,B.aC(new B.aq(F.ED,B.f4(B.a8(24),B.vd(new C.bpF(x,s)),A.aC),w),1,w)],y.p),A.k,A.h,A.i,0,A.n),A.aj,!0),w,!1,w)}}
C.aqz.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga3(0))return A.au
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hK(u,A.F,new C.bpG(t,v),A.eD,v,v):t.a4q(v)
return B.fZ(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a4q(d){var x=null,w=B.b([new B.bL(2,A.a4,B.S(153,D.x2.l()>>>16&255,D.x2.l()>>>8&255,D.x2.l()&255),A.o,16)],y.V)
return B.a4(x,B.ac(E.lM,A.l,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.auc,A.be),x,d,x,x,x,x,x,d)}}
C.Ml.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga3(0))return A.au
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hK(s,A.F,new C.bui(r,v),A.eD,v,v):r.a4r(v)
return B.fZ(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a4r(d){var x=null,w=B.bD(B.S(64,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),A.x,1.5),v=B.b([new B.bL(0,A.a4,B.S(A.e.a6(76.5),A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),A.o,8)],y.V)
return B.a4(x,B.ac(D.FZ,B.S(217,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.DQ,x,w,x,v,x,A.be),x,d,x,x,x,x,x,d)}}
C.asI.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.ayr
x=s.y
if(x===A.d0)return B.a4(t,D.a49,A.j,t,t,new B.a9(B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),t,t,B.a8(14),t,t,A.q),t,t,t,A.dl,I.xJ,t,t,t)
w=G.Tf(x)
x=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
v=B.a8(16)
s=s.CW
u=s===A.ey?A.il:A.ik
u=B.b([new B.Ag(E.FD,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iN),new B.Ag(A.dK,"\u062a\u062d\u0636\u064a\u0631",A.hw),new B.Ag(u,"\u062c\u0627\u0647\u0632",A.dA)],y.K)
if(s===A.cH)u.push(new B.Ag(E.oy,"\u062a\u0648\u0635\u064a\u0644",A.f6))
u.push(new B.Ag(A.e4,"\u062a\u0633\u0644\u064a\u0645",A.cb))
s=new B.dB(u,y.Q)
return B.a4(t,B.ai(s.ges(s).dH(0,new C.buM(w),y.e).cM(0),A.k,A.dy,A.i,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.q),t,t,t,A.dl,A.fq,t,t,t)}}
C.avn.prototype={
E(d){var x=null
return new B.aq(A.dl,B.ai(B.b([B.aC(new C.a0T("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lM,D.DR,x),1,x),A.bx,B.aC(new C.a0T("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.FB,F.iH,x),1,x)],y.p),A.k,A.h,A.i,0,x),x)}}
C.a0T.prototype={
E(d){var x=this,w=null,v=B.S(20,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255),u=B.a8(14)
return B.a4(w,B.ai(B.b([B.ac(x.e,x.f,w,w,18),A.az,B.n(""+x.d,w,w,w,w,B.w(w,w,A.l,w,w,w,w,w,w,w,w,16,w,w,A.u,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aH,B.aC(B.n(x.c,w,A.aq,w,w,B.w(w,w,A.aK,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.k,A.h,A.i,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.q),w,w,w,w,A.fR,w,w,w)}}
C.awk.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.p.l()>>>16&255,A.p.l()>>>8&255,A.p.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dZ.l()>>>16&255,A.dZ.l()>>>8&255,A.dZ.l()&255)
w=B.bD(A.dZ,A.x,2)
v=u.d
w=B.b([B.a4(t,B.ac(D.FZ,A.l,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.be),t,64,t,t,t,t,t,64),A.dD,D.aGy,A.c0,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aK,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.aT,B.ai(D.all,A.k,A.h,A.N,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ac(E.lM,B.bu(4294929309),t,t,56),A.dD,D.aGZ,A.c0,D.aFC],r))
q.push(A.B7)
r=B.ac(p?A.FM:D.aeK,t,t,t,t)
q.push(B.a9h(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hI(t,t,A.l,t,t,t,t,t,t,$.fo,t,t,D.a8D,t,new B.dw(B.a8(14),A.I),t,t,t,t,t)))
return B.bOT(0,B.a4(t,B.de(B.ak(q,A.k,A.h,A.N,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a36.prototype={
m(){var x=this,w=x.cl$
if(w!=null)w.O(0,x.ghZ())
x.cl$=null
x.ar()},
d2(){this.dQ()
this.dA()
this.i_()}}
var z=a.updateTypes(["~(bB)","~(oC)","~()","C(Ab)","Ml(Ab)"])
C.bpy.prototype={
$0(){var x=this.a,w=B.fc(J.aF(this.b.a,x.ga8M()))
return x.ax=w==null?0:w},
$S:0}
C.bpA.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bpB.prototype={
$0(){},
$S:0}
C.bpx.prototype={
$0(){var x=this.a
x.y=A.e.dM(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bpz.prototype={
$0(){var x=this.a
A.b.V(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.bpE.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.d8(d)
x=w==null?null:w.y}w=B.d8(e)
if((w==null?null:w.y)===A.dA&&x!==A.dA)this.a.a1(y.q).f.d0(D.ayV)},
$S:1069}
C.bpF.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.H(e.b,e.d)
x=B.b([$.fo,$.eu,$.ue],y.O)
w=t.z
v=this.b
w=B.Q(new B.J(w,new C.bpC(t,v),B.T(w).h("J<1,d>")),y.l)
w.push(new C.aqz(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.awk(t.ch,t.at,t.ax,t.gaOt(),u))
return B.da(A.bD,B.a4(u,new B.dX(A.bt,u,A.bj,A.z,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.cp(A.c3,A.cl,A.a6,x,u,u),A.q),u,u,u,u,u,u,u,u),A.A,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.bpD(t),u,u,u,u,u,t.gaC4())},
$S:339}
C.bpD.prototype={
$0(){var x=this.a
if(!x.ay)x.aaP()},
$S:0}
C.bpC.prototype={
$1(d){return new C.Ml(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.bpG.prototype={
$3(d,e,f){return this.a.a4q(this.b)},
$S:61}
C.bui.prototype={
$3(d,e,f){return this.a.a4r(this.b)},
$S:61}
C.buM.prototype={
$1(d){var x,w=null,v=d.b,u=this.a,t=v.c,s=u>G.Tf(t),r=u===G.Tf(t)
if(s)x=A.a1
else x=r?A.l:B.S(A.e.a6(76.5),A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255)
u=r?B.S(38,A.l.l()>>>16&255,A.l.l()>>>8&255,A.l.l()&255):A.G
t=B.bD(x,A.x,r?2:1)
return B.aC(B.ak(B.b([B.a4(w,B.ac(s?A.jO:v.a,x,w,w,14),A.j,w,w,new B.a9(u,w,t,w,w,w,A.be),w,28,w,w,w,w,w,28),A.kN,B.n(v.b,w,A.aq,w,w,B.w(w,w,x,w,w,w,w,w,w,w,w,9,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w)],y.p),A.k,A.h,A.N,0,A.n),1,w)},
$S:1070};(function aliases(){var x=C.a36.prototype
x.asu=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.ZE.prototype,"gaJ0","aJ1",0)
x(v,"gaC4","aC5",1)
w(v,"gaOt","aaP",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.y_,B.uA)
w(C.Ab,B.A)
w(C.a36,B.ry)
w(C.ZE,C.a36)
v(B.kv,[C.bpy,C.bpB,C.bpx,C.bpz,C.bpD])
v(B.hE,[C.bpA,C.bpC,C.bpG,C.bui,C.buM])
v(B.k7,[C.bpE,C.bpF])
v(B.a_,[C.aqz,C.Ml,C.asI,C.avn,C.a0T,C.awk])
x(C.a36,B.hx)})()
B.nf(b.typeUniverse,JSON.parse('{"Ml":{"a_":[],"d":[]},"y_":{"R":[],"d":[]},"ZE":{"X":["y_"]},"aqz":{"a_":[],"d":[]},"asI":{"a_":[],"d":[]},"avn":{"a_":[],"d":[]},"a0T":{"a_":[],"d":[]},"awk":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a6
return{x:x("bx<bh?>"),e:x("iT"),V:x("z<bL>"),O:x("z<I>"),K:x("z<+icon,label,status(ah,c,eK)>"),p:x("z<d>"),W:x("z<Ab>"),Q:x("dB<+icon,label,status(ah,c,eK)>"),B:x("fk"),l:x("d"),q:x("tW"),j:x("cX?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.a_g=new B.P(!0,A.aK,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aG6=new B.at("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.a_g,null,null,null,null,null,null,null,null)
D.a49=new B.l2(A.F,null,null,D.aG6,null)
D.x2=new B.I(1,1,0.26666666666666666,0.5333333333333333,A.m)
D.DR=new B.I(1,1,0.4196078431372549,0.615686274509804,A.m)
D.a8D=new B.a2(24,12,24,12)
D.FB=new B.ah(57900,"MaterialIcons",null,!1)
D.aeK=new B.ah(58571,"MaterialIcons",null,!1)
D.FZ=new B.ah(63047,"MaterialIcons",null,!1)
D.agi=new B.cu(E.lM,20,null,null,null,null)
D.aH_=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akF=x([D.agi,A.az,D.aH_],y.p)
D.ag0=new B.cu(D.FB,18,F.iH,null,null,null)
D.aCt=new B.P(!0,F.iH,null,null,null,null,null,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aH0=new B.at("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aCt,null,null,null,null,null,null,null,null)
D.all=x([D.ag0,A.aH,D.aH0],y.p)
D.a56=new B.I(1,0.8,0.06666666666666667,0.3333333333333333,A.m)
D.amW=x([D.DR,D.a56],y.O)
D.auc=new H.vE(A.F,0.5,A.a6,null,0,D.amW,null,null)
D.ayr=new B.cP(null,64,null,null)
D.aH5=new B.at("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.ayV=new B.fl(D.aH5,A.a1,null,null,null,null,null,null,null,null,null,null,null,A.af,!1,null,null,null,A.z,null)
D.aFC=new B.at("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.a_g,null,null,null,null,null,null,null,null)
D.aBU=new B.P(!0,A.l,null,null,null,null,22,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGy=new B.at("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aBU,null,null,null,null,null,null,null,null)
D.aBB=new B.P(!0,A.l,null,null,null,null,20,A.u,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aGZ=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aBB,null,null,null,null,null,null,null,null)})()};
(a=>{a["ZDeYdx03yvPU/o1yBdy5fi79oJY="]=a.current})($__dart_deferred_initializers__);