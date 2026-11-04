((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,B,A,C={
caD(d){return new C.xY(d,null)},
xY:function xY(d,e){this.d=d
this.a=e},
A5:function A5(d,e){this.a=d
this.b=e
this.c=!1},
Zn:function Zn(d,e,f,g,h,i){var _=this
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
bot:function bot(d,e){this.a=d
this.b=e},
bov:function bov(){},
bow:function bow(){},
bos:function bos(d,e){this.a=d
this.b=e},
bou:function bou(d){this.a=d},
boz:function boz(d){this.a=d},
boA:function boA(d,e){this.a=d
this.b=e},
boy:function boy(d){this.a=d},
box:function box(d,e){this.a=d
this.b=e},
aqj:function aqj(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
boB:function boB(d,e){this.a=d
this.b=e},
M7:function M7(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
bt3:function bt3(d,e){this.a=d
this.b=e},
asu:function asu(d,e){this.c=d
this.a=e},
btA:function btA(d){this.a=d},
av7:function av7(d,e,f){this.c=d
this.d=e
this.a=f},
a0D:function a0D(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
aw2:function aw2(d,e,f,g,h){var _=this
_.c=d
_.d=e
_.e=f
_.f=g
_.a=h},
a2R:function a2R(){}},D,G,F,H,I,E
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
C.xY.prototype={
a_(){var x=B.b([],y.W)
return new C.Zn(A.a5,x,A.wQ,A.S,null,null)}}
C.A5.prototype={}
C.Zn.prototype={
ga85(){var x=this.gd7().d6(0,$.hg(),y.j)
x=x==null?null:x.a
return"heart_game_best_"+(x==null?"guest":x)},
au(){var x,w=this
w.aI()
w.Iz()
x=w.yU(w.gaI2())
x.uD(0)
w.w!==$&&B.bg()
w.w=x},
Iz(){var x=0,w=B.u(y.H),v,u=this,t
var $async$Iz=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lk(),$async$Iz)
case 3:t=e
if(u.c==null){x=1
break}u.C(new C.bot(u,t))
case 1:return B.r(v,w)}})
return B.t($async$Iz,w)},
Cx(){var x=0,w=B.u(y.H),v=this
var $async$Cx=B.p(function(d,e){if(d===1)return B.q(e,w)
for(;;)switch(x){case 0:x=3
return B.i(B.lk(),$async$Cx)
case 3:x=2
return B.i(e.m_("Int",v.ga85(),v.ax),$async$Cx)
case 2:return B.r(null,w)}})
return B.t($async$Cx,w)},
aI3(d){var x=this,w=(d.a-x.x.a)/1e6
x.x=d
if(!x.ay||x.ch)return
if(w<=0||w>0.25||x.CW.ga2(0))return
x.aEP(0,w)},
aEP(d,e){var x,w,v,u,t,s,r,q,p,o=this,n=A.d.dP(0.16+o.at*0.006,0.16,0.5),m=A.d.dP(1.25-o.at*0.02,0.55,1.25)
if((o.as+=e)>=m){o.as=0
o.z.push(new C.A5(1.05,0.12+o.Q.ahF()*0.76))}for(x=o.z,w=x.length,v=n*e,u=0;u<w;++u){t=x[u]
t.a-=v}for(u=0;u<w;++u){t=x[u]
if(!t.c&&t.a<0.16){t.c=!0;++o.at}}A.b.eM(x,new C.bov())
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
o.Cx()}break}}if(o.c!=null)o.C(new C.bow())},
aB9(d){var x=this
if(!x.ay||x.CW.b===0)return
x.C(new C.bos(x,d))},
aa5(){this.C(new C.bou(this))},
m(){var x=this.w
x===$&&B.a()
x.m()
this.arG()},
E(d){var x=this,w=null,v=x.gd7(),u=$.bRG(),t=v.bj(u.$1(x.a.d),y.x),s=v.bj($.jZ(),y.B)
v.wu(u.$1(x.a.d),new C.boz(d))
u=$.fj
return B.eb(B.fM(w,!0,A.F,w,w,0,A.k,w,w,B.ae(D.akd,A.i,A.f,A.N,0,w)),u,B.z1(!0,B.am(B.b([new C.asu(B.dx(t),w),A.aq,new C.av7(x.at,x.ax,w),A.aq,B.aB(new B.aq(F.Ep,B.f8(B.ac(24),B.va(new C.boA(x,s)),A.aB),w),1,w)],y.p),A.i,A.f,A.h,0,A.n),A.ak,!0),w,!1,w)}}
C.aqj.prototype={
E(d){var x,w,v,u,t=this,s=null,r=t.e
if(r.ga2(0))return A.ap
x=r.a
r=r.b
w=Math.min(x,r)*0.075
v=w*2
u=t.f
u=u!=null&&u.length!==0?B.hT(u,A.E,new C.boB(t,v),A.ez,v,v):t.a3T(v)
return B.fR(s,u,s,s,t.d*x-w,s,t.c*r-w,s)},
a3T(d){var x=null,w=B.b([new B.bL(2,A.a4,B.S(153,D.wY.l()>>>16&255,D.wY.l()>>>8&255,D.wY.l()&255),A.m,16)],y.V)
return B.a7(x,B.ab(E.lL,A.k,x,x,d*0.6),A.j,x,x,new B.a9(x,x,x,x,w,D.atB,A.bj),x,d,x,x,x,x,x,d)}}
C.M7.prototype={
E(d){var x,w,v,u,t,s,r=this,q=null,p=r.d
if(p.ga2(0))return A.ap
x=p.a
p=p.b
w=Math.min(x,p)*0.055
v=w*2
u=r.c
t=u.a
s=r.e
s=s!=null&&s.length!==0?B.hT(s,A.E,new C.bt3(r,v),A.ez,v,v):r.a3U(v)
return B.fR(q,s,q,q,t*x-w,q,u.b*p-w,q)},
a3U(d){var x=null,w=B.bC(B.S(64,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),A.w,1.5),v=B.b([new B.bL(0,A.a4,B.S(A.d.a4(76.5),A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),A.m,8)],y.V)
return B.a7(x,B.ab(D.FQ,B.S(217,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),x,x,d*0.55),A.j,x,x,new B.a9(A.Dy,x,w,x,v,x,A.bj),x,d,x,x,x,x,x,d)}}
C.asu.prototype={
E(d){var x,w,v,u,t=null,s=this.c
if(s==null)return D.axp
x=s.y
if(x===A.d6)return B.a7(t,D.a3W,A.j,t,t,new B.a9(B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),t,t,B.ac(14),t,t,A.p),t,t,t,A.d2,H.xC,t,t,t)
w=I.bVE(x)
x=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
v=B.ac(16)
s=s.CW
u=s===A.f4?A.im:A.il
u=B.b([new B.wA(E.Fq,"\u0627\u0646\u062a\u0638\u0627\u0631",A.iN),new B.wA(E.FE,"\u062a\u0623\u0643\u064a\u062f",A.iO),new B.wA(A.dY,"\u062a\u062d\u0636\u064a\u0631",A.hu),new B.wA(u,"\u062c\u0627\u0647\u0632",A.du)],y.K)
if(s===A.cW)u.push(new B.wA(E.op,"\u062a\u0648\u0635\u064a\u0644",A.f3))
u.push(new B.wA(A.eK,"\u062a\u0633\u0644\u064a\u0645",A.cc))
s=new B.dA(u,y.Q)
return B.a7(t,B.ae(s.ges(s).dG(0,new C.btA(w),y.e).cK(0),A.i,A.ds,A.h,0,t),A.j,t,t,new B.a9(x,t,t,v,t,t,A.p),t,t,t,A.d2,A.fk,t,t,t)}}
C.av7.prototype={
E(d){var x=null
return new B.aq(A.d2,B.ae(B.b([B.aB(new C.a0D("\u0627\u0644\u0646\u0642\u0627\u0637",this.c,E.lL,D.Dz,x),1,x),A.by,B.aB(new C.a0D("\u0623\u0641\u0636\u0644 \u0646\u062a\u064a\u062c\u0629",this.d,D.Fo,F.iH,x),1,x)],y.p),A.i,A.f,A.h,0,x),x)}}
C.a0D.prototype={
E(d){var x=this,w=null,v=B.S(20,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255),u=B.ac(14)
return B.a7(w,B.ae(B.b([B.ab(x.e,x.f,w,w,18),A.ax,B.n(""+x.d,w,w,w,w,B.w(w,w,A.k,w,w,w,w,w,w,w,w,16,w,w,A.t,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),A.aE,B.aB(B.n(x.c,w,A.as,w,w,B.w(w,w,A.aN,w,w,w,w,w,w,w,w,11,w,w,w,w,w,!0,w,w,w,w,w,w,w,w),w,w,w),1,w)],y.p),A.i,A.f,A.h,0,w),A.j,w,w,new B.a9(v,w,w,u,w,w,A.p),w,w,w,w,A.fQ,w,w,w)}}
C.aw2.prototype={
E(d){var x,w,v,u=this,t=null,s=B.S(140,A.o.l()>>>16&255,A.o.l()>>>8&255,A.o.l()&255),r=y.p,q=B.b([],r),p=u.c
if(p){x=B.S(51,A.dR.l()>>>16&255,A.dR.l()>>>8&255,A.dR.l()&255)
w=B.bC(A.dR,A.w,2)
v=u.d
w=B.b([B.a7(t,B.ab(D.FQ,A.k,t,t,34),A.j,t,t,new B.a9(x,t,w,t,t,t,A.bj),t,64,t,t,t,t,t,64),A.dx,D.aFr,A.bZ,B.n("\u0646\u0642\u0627\u0637\u0643: "+v,t,t,t,t,B.w(t,t,A.aN,t,t,t,t,t,t,t,t,15,t,t,t,t,t,!0,t,t,t,t,t,t,t,t),t,t,t)],r)
if(v>0&&v>=u.e)A.b.K(w,B.b([A.aW,B.ae(D.akS,A.i,A.f,A.N,0,t)],r))
A.b.K(q,w)}else A.b.K(q,B.b([B.ab(E.lL,B.bt(4294929309),t,t,56),A.dx,D.aFS,A.bZ,D.aEt],r))
q.push(A.Zj)
r=B.ab(p?A.FA:D.aei,t,t,t,t)
q.push(B.a98(r,B.n(p?"\u0627\u0644\u0639\u0628 \u0645\u0631\u0629 \u0623\u062e\u0631\u0649":"\u0627\u0628\u062f\u0623 \u0627\u0644\u0644\u0639\u0628",t,t,t,t,t,t,t,t),u.f,B.hC(t,t,A.k,t,t,t,t,t,t,$.fj,t,t,D.a8h,t,new B.dD(B.ac(14),A.J),t,t,t,t,t)))
return B.bNu(0,B.a7(t,B.du(B.am(q,A.i,A.f,A.N,0,A.n),t,t),A.j,s,t,t,t,t,t,t,t,t,t,t))}}
C.a2R.prototype={
m(){var x=this,w=x.cl$
if(w!=null)w.O(0,x.ghX())
x.cl$=null
x.ar()},
cW(){this.dL()
this.dC()
this.hY()}}
var z=a.updateTypes(["~(bD)","~(oz)","~()","C(A5)","M7(A5)"])
C.bot.prototype={
$0(){var x=this.a,w=B.f3(J.aL(this.b.a,x.ga85()))
return x.ax=w==null?0:w},
$S:0}
C.bov.prototype={
$1(d){return d.a<-0.08},
$S:z+3}
C.bow.prototype={
$0(){},
$S:0}
C.bos.prototype={
$0(){var x=this.a
x.y=A.d.dP(x.y+this.b.d.b/x.CW.b,0.05,0.95)},
$S:0}
C.bou.prototype={
$0(){var x=this.a
A.b.X(x.z)
x.as=x.at=0
x.y=0.5
x.ch=!1
x.ay=!0},
$S:0}
C.boz.prototype={
$2(d,e){var x,w
if(d==null)x=null
else{w=B.dx(d)
x=w==null?null:w.y}w=B.dx(e)
if((w==null?null:w.y)===A.du&&x!==A.du)this.a.a3(y.q).f.d9(D.axT)},
$S:1053}
C.boA.prototype={
$2(d,e){var x,w,v,u=null,t=this.a
t.CW=new B.I(e.b,e.d)
x=B.b([$.fj,$.eq,$.uf],y.O)
w=t.z
v=this.b
w=B.Q(new B.G(w,new C.box(t,v),B.T(w).h("G<1,d>")),y.l)
w.push(new C.aqj(t.y,0.16,t.CW,v.dx,u))
if(!t.ay)w.push(new C.aw2(t.ch,t.at,t.ax,t.gaNu(),u))
return B.d7(A.bB,B.a7(u,new B.e2(A.br,u,A.bg,A.y,w,u),A.j,u,u,new B.a9(u,u,u,u,u,new B.cm(A.c0,A.cf,A.a2,x,u,u),A.p),u,u,u,u,u,u,u,u),A.z,!1,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,u,new C.boy(t),u,u,u,u,u,t.gaB8())},
$S:329}
C.boy.prototype={
$0(){var x=this.a
if(!x.ay)x.aa5()},
$S:0}
C.box.prototype={
$1(d){return new C.M7(d,this.a.CW,this.b.dy,null)},
$S:z+4}
C.boB.prototype={
$3(d,e,f){return this.a.a3T(this.b)},
$S:56}
C.bt3.prototype={
$3(d,e,f){return this.a.a3U(this.b)},
$S:56}
C.btA.prototype={
$1(d){var x,w,v=null,u=d.a,t=d.b,s=this.a,r=s>u,q=s===u
if(r)x=A.a0
else x=q?A.k:B.S(A.d.a4(76.5),A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255)
s=q?B.S(38,A.k.l()>>>16&255,A.k.l()>>>8&255,A.k.l()&255):A.F
w=B.bC(x,A.w,q?2:1)
return B.aB(B.am(B.b([B.a7(v,B.ab(r?A.jK:t.a,x,v,v,14),A.j,v,v,new B.a9(s,v,w,v,v,v,A.bj),v,28,v,v,v,v,v,28),A.kF,B.n(t.b,v,A.as,v,v,B.w(v,v,x,v,v,v,v,v,v,v,v,9,v,v,v,v,v,!0,v,v,v,v,v,v,v,v),v,v,v)],y.p),A.i,A.f,A.N,0,A.n),1,v)},
$S:1054};(function aliases(){var x=C.a2R.prototype
x.arG=x.m})();(function installTearOffs(){var x=a._instance_1u,w=a._instance_0u
var v
x(v=C.Zn.prototype,"gaI2","aI3",0)
x(v,"gaB8","aB9",1)
w(v,"gaNu","aa5",2)})();(function inheritance(){var x=a.mixinHard,w=a.inherit,v=a.inheritMany
w(C.xY,B.uB)
w(C.A5,B.A)
w(C.a2R,B.ry)
w(C.Zn,C.a2R)
v(B.ku,[C.bot,C.bow,C.bos,C.bou,C.boy])
v(B.hy,[C.bov,C.box,C.boB,C.bt3,C.btA])
v(B.k0,[C.boz,C.boA])
v(B.a_,[C.aqj,C.M7,C.asu,C.av7,C.a0D,C.aw2])
x(C.a2R,B.hq)})()
B.n4(b.typeUniverse,JSON.parse('{"M7":{"a_":[],"d":[]},"xY":{"R":[],"d":[]},"Zn":{"X":["xY"]},"aqj":{"a_":[],"d":[]},"asu":{"a_":[],"d":[]},"av7":{"a_":[],"d":[]},"a0D":{"a_":[],"d":[]},"aw2":{"a_":[],"d":[]}}'))
var y=(function rtii(){var x=B.a6
return{x:x("bG<bn?>"),e:x("iM"),V:x("z<bL>"),O:x("z<J>"),K:x("z<+icon,label,status(ai,c,eE)>"),p:x("z<d>"),W:x("z<A5>"),Q:x("dA<+icon,label,status(ai,c,eE)>"),B:x("fh"),l:x("d"),q:x("u0"),j:x("cX?"),H:x("~")}})();(function constants(){var x=a.makeConstList
D.ZY=new B.P(!0,A.aN,null,null,null,null,13,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aF_=new B.at("\u062a\u0645 \u0625\u0644\u063a\u0627\u0621 \u0647\u0630\u0627 \u0627\u0644\u0637\u0644\u0628",null,D.ZY,null,null,null,null,null,null,null,null)
D.a3W=new B.l_(A.E,null,null,D.aF_,null)
D.wY=new B.J(1,1,0.26666666666666666,0.5333333333333333,A.l)
D.Dz=new B.J(1,1,0.4196078431372549,0.615686274509804,A.l)
D.a8h=new B.a4(24,12,24,12)
D.Fo=new B.ai(57900,"MaterialIcons",null,!1)
D.aei=new B.ai(58571,"MaterialIcons",null,!1)
D.FQ=new B.ai(63047,"MaterialIcons",null,!1)
D.afN=new B.cr(E.lL,20,null,null,null,null)
D.aFT=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628",null,null,null,null,null,null,null,null,null,null)
D.akd=x([D.afN,A.ax,D.aFT],y.p)
D.afw=new B.cr(D.Fo,18,F.iH,null,null,null)
D.aBo=new B.P(!0,F.iH,null,null,null,null,null,A.t,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFV=new B.at("\u0631\u0642\u0645 \u0642\u064a\u0627\u0633\u064a \u062c\u062f\u064a\u062f!",null,D.aBo,null,null,null,null,null,null,null,null)
D.akS=x([D.afw,A.aE,D.aFV],y.p)
D.a4T=new B.J(1,0.8,0.06666666666666667,0.3333333333333333,A.l)
D.amr=x([D.Dz,D.a4T],y.O)
D.atB=new G.vA(A.E,0.5,A.a2,null,0,D.amr,null,null)
D.axp=new B.cM(null,64,null,null)
D.aG_=new B.at("\u0637\u0644\u0628\u0643 \u062c\u0627\u0647\u0632 \u0644\u0644\u0627\u0633\u062a\u0644\u0627\u0645!",null,null,null,null,null,null,null,null,null,null)
D.axT=new B.fT(D.aG_,A.a0,null,null,null,null,null,null,null,null,null,null,null,A.ah,!1,null,null,null,A.y,null)
D.aEt=new B.at("\u0627\u0633\u062d\u0628 \u0644\u0623\u0639\u0644\u0649 \u0648\u0623\u0633\u0641\u0644 \u0644\u062a\u0641\u0627\u062f\u064a \u0627\u0644\u0639\u0642\u0628\u0627\u062a",null,D.ZY,null,null,null,null,null,null,null,null)
D.aAP=new B.P(!0,A.k,null,null,null,null,22,A.t,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFr=new B.at("\u0627\u0646\u062a\u0647\u062a \u0627\u0644\u0644\u0639\u0628\u0629!",null,D.aAP,null,null,null,null,null,null,null,null)
D.aAw=new B.P(!0,A.k,null,null,null,null,20,A.t,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.aFS=new B.at("\u0627\u062d\u0645\u0650 \u0627\u0644\u0642\u0644\u0628 \u0645\u0646 \u0627\u0644\u0627\u0635\u0637\u062f\u0627\u0645",null,D.aAw,null,null,null,null,null,null,null,null)})()};
(a=>{a["b80RKrOq2c0hVS+HvQ6j6fdWUJQ="]=a.current})($__dart_deferred_initializers__);